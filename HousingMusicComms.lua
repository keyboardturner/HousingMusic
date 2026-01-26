local _, HM = ...

local L = HM.L;
local DefaultsTable = HM.DefaultsTable;
local Print = HM.Print

local LRPM = LibStub("LibRPMedia-1.2")
HM.CommPrefix = "HousingMusic"

-- "HEADER:LocationKey:FileID,FileID,FileID..."
-- "H"- House Data
local MSG_TYPE_HOUSE = "H"

local MAX_MSG_BYTES = 250

local AUTO_SEND_COOLDOWN = 60
local AutoBroadcastTimer = 0
local BROADCAST_INTERVAL = 60

HM.SentTracker = {}

local ChunkBuffer = {}

local function GetCurrentLocationKey()
	if not C_Housing or not C_Housing.GetCurrentHouseInfo then return nil end
	
	local info = C_Housing.GetCurrentHouseInfo()
	
	if not info or not info.neighborhoodGUID or not info.plotID then return nil end

	-- format: Owner_NeighborhoodGUID_PlotID
	return string.format("%s_%d", info.neighborhoodGUID, info.plotID)
end

local CommsFrame = CreateFrame("Frame")
CommsFrame:RegisterEvent("ADDON_LOADED")
CommsFrame:RegisterEvent("CHAT_MSG_ADDON")


CommsFrame:SetScript("OnEvent", function(self, event, ...)
	if event == "ADDON_LOADED" then
		local addonName = ...
		if addonName == "HousingMusic" then
			HM_CachedMusic_DB = HM_CachedMusic_DB or {}
			HM_CachedMusic_Metadata = HM_CachedMusic_Metadata or {}
			
			C_ChatInfo.RegisterAddonMessagePrefix(HM.CommPrefix)
		end
	elseif event == "CHAT_MSG_ADDON" then
		HM.OnCommReceived(...)
	end
end)

local function ProcessReceivedPlaylist(sender, receivedLocationKey, chunkIndex, totalChunks, dataString)
	if not sender or not receivedLocationKey or not dataString then return end
	
	local myCurrentKey = GetCurrentLocationKey()

	if not myCurrentKey or myCurrentKey ~= receivedLocationKey then
		return
	end

	local bufferKey = string.format("%s:%s", receivedLocationKey, sender)
	
	if not ChunkBuffer[bufferKey] then
		ChunkBuffer[bufferKey] = {
			chunks = {},
			totalChunks = totalChunks,
			receivedCount = 0
		}
	end
	
	local buffer = ChunkBuffer[bufferKey]
	
	if chunkIndex == 1 then
		buffer.chunks = {}
		buffer.totalChunks = totalChunks
		buffer.receivedCount = 0
	end
	
	if not buffer.chunks[chunkIndex] then
		buffer.chunks[chunkIndex] = dataString
		buffer.receivedCount = buffer.receivedCount + 1
	end
	
	if buffer.receivedCount >= buffer.totalChunks then
		if not HM_CachedMusic_DB[receivedLocationKey] then
			HM_CachedMusic_DB[receivedLocationKey] = {}
		end
		
		HM_CachedMusic_DB[receivedLocationKey][sender] = {}
		local validSongs = HM_CachedMusic_DB[receivedLocationKey][sender]

		HM_CachedMusic_Metadata = HM_CachedMusic_Metadata or {}
		HM_CachedMusic_Metadata[receivedLocationKey] = HM_CachedMusic_Metadata[receivedLocationKey] or {}
		
		local isFav = false
		if HM_CachedMusic_Metadata[receivedLocationKey][sender] then
			isFav = HM_CachedMusic_Metadata[receivedLocationKey][sender].isFavorite
		end

		local houseInfo = C_Housing.GetCurrentHouseInfo()
		local currentHouseName = houseInfo and houseInfo.houseName or L["Unknown"]

		local isFriend = C_FriendList.GetFriendInfo(sender)
		local isGuild = C_GuildInfo.MemberExistsByName(sender)
		local isBNetFriend = HM.IsBNetFriend(sender)

		HM_CachedMusic_Metadata[receivedLocationKey][sender] = {
			lastSeen = GetServerTime(),
			isFavorite = isFav,
			houseName = currentHouseName,
			wasFriend = (isFriend ~= nil),
			wasGuild = (isGuild ~= nil and isGuild > 0),
			wasBNetFriend = (isBNetFriend == true)
		};

		local currentCount = 0
		local limit = HM.MAX_PLAYLIST_SIZE or 50
		
		for i = 1, buffer.totalChunks do
			local chunkData = buffer.chunks[i]
			if chunkData then
				for idStr in string.gmatch(chunkData, "([^,]+)") do
					if currentCount >= limit then
						break
					end
					
					local fileID = tonumber(idStr)
					
					if fileID then
						local info = LRPM:GetMusicInfoByID(fileID)
						if info then
							if not validSongs[fileID] then
								validSongs[fileID] = true
								currentCount = currentCount + 1
							end
						end
					end
				end
			end
			
			if currentCount >= limit then
				break
			end
		end
		
		ChunkBuffer[bufferKey] = nil
		
		local totalCount = 0
		for _ in pairs(validSongs) do totalCount = totalCount + 1 end

		--Print(string.format(L["ReceivedPlaylistFromSenderSongCount"], sender, totalCount))
		
		if HM.UpdateCachedMusicUI then
			HM.UpdateCachedMusicUI()
		end

		if HM and HM.CheckConditions then
			 HM.CheckConditions()
		end
	end
end

local function SendData(channel, target, locationKey, playlistTable)
	if not ChatThrottleLib then
		--Print(L["ChatThrottleLibNotFound"])
		return
	end

	local ids = {}
	for fileID, enabled in pairs(playlistTable) do
		if enabled then
			table.insert(ids, tostring(fileID))
		end
	end
	
	if #ids == 0 then return end
	
	local SAFE_BYTES = MAX_MSG_BYTES - 20 
	
	local headerBase = string.format("%s:%s", MSG_TYPE_HOUSE, locationKey)
	local availableBytes = SAFE_BYTES - #headerBase
	
	local chunks = {}
	local currentChunk = ""
	
	for _, idStr in ipairs(ids) do
		local nextLen = #currentChunk + #idStr + 1 -- +1 for comma
		
		if nextLen > availableBytes then
			table.insert(chunks, currentChunk)
			currentChunk = idStr
		else
			if currentChunk == "" then
				currentChunk = idStr
			else
				currentChunk = currentChunk .. "," .. idStr
			end
		end
	end
	
	if currentChunk ~= "" then
		table.insert(chunks, currentChunk)
	end
	
	local totalChunks = #chunks

	for i, chunkData in ipairs(chunks) do
		local payload = string.format("%s:%s:%d:%d:%s", MSG_TYPE_HOUSE, locationKey, i, totalChunks, chunkData)
		ChatThrottleLib:SendAddonMessage("NORMAL", HM.CommPrefix, payload, channel, target)
	end
	--print(channel, target, locationKey, playlistTable)
end

function HM.SharePlaylist(context)
	local playlistTable = HM.GetActivePlaylistTable()
	if not playlistTable then return end

	local locationKey = GetCurrentLocationKey()
	if not locationKey then
		--Print(L["InsideHouseToShare"])
		return
	end

	local channel = "WHISPER"
	local target = nil

	if context == "party" then
		if IsInGroup() then
			channel = IsInRaid() and "RAID" or "PARTY"
		else
			--print("|cffd7ad32HousingMusic:|r You are not in a group.")
			return
		end
	elseif context == "say" then
		channel = "SAY" 
	elseif context == "yell" then
		channel = "YELL" 
	elseif context == "mouseover" then
		if UnitExists("mouseover") and UnitIsPlayer("mouseover") then
			target = GetUnitName("mouseover", true)
			if not target then return end
		else
			return 
		end
	elseif context == "target" then
		if UnitExists("target") and UnitIsPlayer("target") then
			target = GetUnitName("target", true)
		else
			--print("|cffd7ad32HousingMusic:|r Invalid target.")
			return
		end
	else
		target = context
	end
	
	--if target then
	--	Print(string.format(L["SendingHouseMusicToTarget"], target))
	--else
	--	Print(string.format(L["BroadcastingHouseMusicDataViaChannel"], channel))
	--end

	SendData(channel, target, locationKey, playlistTable)
end

local TriggerFrame = CreateFrame("Frame")
TriggerFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
TriggerFrame:RegisterEvent("UPDATE_MOUSEOVER_UNIT")
TriggerFrame:RegisterEvent("NAME_PLATE_UNIT_ADDED")
TriggerFrame:RegisterEvent("HOUSE_PLOT_ENTERED")
TriggerFrame:RegisterEvent("HOUSE_PLOT_EXITED")

local function TryAutoShare(unitID)
	if not C_Housing.IsInsideHouse() then return end
	if not C_Housing.IsInsideOwnHouse() then return end

	if not UnitExists(unitID) or not UnitIsPlayer(unitID) then return end
	if UnitIsUnit(unitID, "player") then return end
	if UnitIsDeadOrGhost(unitID) then return end

	local default = (DefaultsTable and DefaultsTable.autosharePlaylist) or 1
	local setting = (HousingMusic_DB and HousingMusic_DB.autosharePlaylist) or default
	
	if setting == 4 then 
		--Print("Refusing to export all comms based on export settings 4.")
		return
	elseif setting == 2 then
		local isFriend = C_FriendList.IsFriend(UnitGUID(unitID))
		local isBnetFriend = C_BattleNet.GetAccountInfoByGUID(UnitGUID(unitID)) and C_BattleNet.GetAccountInfoByGUID(UnitGUID(unitID)).isBattleTagFriend
		local isGuild = UnitIsInMyGuild(unitID)

		--Print("Export comm based on export settings 2.")
		if not isFriend and not isGuild and not isBnetFriend then
			--Print("Refusing to export comms based on export settings 2.")
			return
		end
	elseif setting == 3 then
		local isFriend = C_FriendList.IsFriend(UnitGUID(unitID))
		local isBnetFriend = C_BattleNet.GetAccountInfoByGUID(UnitGUID(unitID)) and C_BattleNet.GetAccountInfoByGUID(UnitGUID(unitID)).isBattleTagFriend
		--Print("Export comm based on export settings 3.")
		if not isFriend and not isBnetFriend then
			--Print("Refusing to export comms based on export settings 3.")
			return
		end
	end

	local targetName = GetUnitName(unitID, true)
	if not targetName then return end

	if HM.IsPlayerIgnored(targetName) then
		--Print(string.format(L["PreventingSendingDataToTarget"], targetName))
		return 
	end

	local now = GetTime()
	local lastSent = HM.SentTracker[targetName] or 0

	if (now - lastSent) > AUTO_SEND_COOLDOWN then

		HM.SentTracker[targetName] = now
		
		HM.SharePlaylist(targetName)
	end
end

function HM.BroadcastToNameplates()
	local nameplates = C_NamePlate.GetNamePlates()
	if not nameplates then return end
	for _, plate in ipairs(nameplates) do
		local unit = plate.unitToken
		
		if unit and UnitExists(unit) then
			TryAutoShare(unit)
		end
	end
end

local BroadcastFrame = CreateFrame("Frame")
BroadcastFrame:SetScript("OnUpdate", function(self, elapsed)
	AutoBroadcastTimer = AutoBroadcastTimer + elapsed
	
	if AutoBroadcastTimer >= BROADCAST_INTERVAL then
		AutoBroadcastTimer = 0
		
		if C_Housing and C_Housing.IsInsideHouse() and C_Housing.IsInsideOwnHouse() then
			local default = (DefaultsTable and DefaultsTable.autosharePlaylist) or 1
			local setting = (HousingMusic_DB and HousingMusic_DB.autosharePlaylist) or default

			if setting ~= 4 then
				HM.BroadcastToNameplates()
				
				if IsInGroup() then
					HM.SharePlaylist("party")
				end
			end
		end
	end
end)

TriggerFrame:SetScript("OnEvent", function(self, event, ...)
	if event == "PLAYER_TARGET_CHANGED" then
		TryAutoShare("target")
	elseif event == "UPDATE_MOUSEOVER_UNIT" then
		TryAutoShare("mouseover")
	elseif event == "NAME_PLATE_UNIT_ADDED" then
		local unitToken = ...
		if unitToken then
			TryAutoShare(unitToken)
		end
	elseif event == "HOUSE_PLOT_ENTERED" or event == "HOUSE_PLOT_EXITED" then
		HM.SentTracker = {}
		ChunkBuffer = {}
	end
end)

function HM.OnCommReceived(prefix, text, channel, sender, target, zoneChannelID, localID, name, instanceID)
	if prefix ~= HM.CommPrefix then return end

	sender = Ambiguate(sender, "none")

	if target and not target == "" and HM.IsPlayerIgnored(target) then
		return 
	end
	
	if sender == UnitName("player") then return end

	local default = (DefaultsTable and DefaultsTable.autoImportPlaylist) or 1
	local setting = (HousingMusic_DB and HousingMusic_DB.autoImportPlaylist) or default

	if setting == 4 then
		--Print("Refusing to import all comms based on import settings 4.")
		return
	elseif setting == 2 then
		local isFriend = C_FriendList.GetFriendInfo(sender) or tonumber(Ambiguate(sender, "none"))
		local isGuild = C_GuildInfo.MemberExistsByName(sender)
		--Print("Import comm based on import settings 2.")
		if not isFriend and not isGuild then
			--Print("Refusing to import comms based on import settings 2.")
			return
		end
	elseif setting == 3 then
		local isFriend = C_FriendList.GetFriendInfo(sender) or tonumber(Ambiguate(sender, "none"))
		--Print("Import comm based on import settings 3.")
		if not isFriend then
			--Print("Refusing to import comms based on import settings 3.")
			return
		end
	end

	-- example: H:LocationKey:Index:Total:Data
	local msgType, locationKey, idx, total, data = strsplit(":", text, 5)
	
	if msgType == MSG_TYPE_HOUSE and locationKey and idx and total and data then
		ProcessReceivedPlaylist(sender, locationKey, tonumber(idx), tonumber(total), data)
	end
end