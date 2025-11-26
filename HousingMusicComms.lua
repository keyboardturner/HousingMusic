local _, HM = ...

local LRPM = LibStub("LibRPMedia-1.2")

HMGlobal = HM
HM.CommPrefix = "HousingMusic"

-- "HEADER:LocationKey:FileID,FileID,FileID..."
-- "H"- House Data
local MSG_TYPE_HOUSE = "H"

local MAX_MSG_BYTES = 250

local AUTO_SEND_COOLDOWN = 30

HM.SentTracker = {} 

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
			
			C_ChatInfo.RegisterAddonMessagePrefix(HM.CommPrefix)
		end
	elseif event == "CHAT_MSG_ADDON" then
		HM.OnCommReceived(...)
	end
end)

local function ProcessReceivedPlaylist(sender, receivedLocationKey, chunkIndex, totalChunks, dataString)
	if not sender or not receivedLocationKey or not dataString then return end
	
	local myCurrentKey = GetCurrentLocationKey()

	if not myCurrentKey then return end

	if myCurrentKey ~= receivedLocationKey then
		return
	end

	if not HM_CachedMusic_DB[receivedLocationKey] then
		HM_CachedMusic_DB[receivedLocationKey] = {}
	end

	if chunkIndex == 1 then
		HM_CachedMusic_DB[receivedLocationKey][sender] = {}
	end

	if not HM_CachedMusic_DB[receivedLocationKey][sender] then
		HM_CachedMusic_DB[receivedLocationKey][sender] = {}
	end

	local validSongs = HM_CachedMusic_DB[receivedLocationKey][sender]
	local count = 0
	
	for idStr in string.gmatch(dataString, "([^,]+)") do
		local fileID = tonumber(idStr)
		
		if fileID then
			local info = LRPM:GetMusicInfoByID(fileID)
			if info then
				validSongs[fileID] = true
				count = count + 1
			end
		end
	end
	
	if chunkIndex == totalChunks then
		local totalCount = 0
		for _ in pairs(validSongs) do totalCount = totalCount + 1 end

		print(string.format("|cff00ff00HousingMusic:|r Received playlist from %s (%d songs).", sender, totalCount))
		
		if HM.UpdateCachedMusicUI then
			HM.UpdateCachedMusicUI()
		end

		if HMGlobal and HMGlobal.CheckConditions then
			 HMGlobal.CheckConditions()
		end
	end
end

local function SendData(channel, target, locationKey, playlistTable)
	if not ChatThrottleLib then
		print("|cffff0000HousingMusic:|r ChatThrottleLib not found.")
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
end

function HM.SharePlaylist(context)
	local playlistTable = HM.GetActivePlaylistTable()
	if not playlistTable then return end

	local locationKey = GetCurrentLocationKey()
	if not locationKey then
		print("|cffff0000HousingMusic:|r You must be inside a housing plot to share its music.")
		return
	end

	local channel = "WHISPER"
	local target = nil

	if context == "party" then
		if IsInGroup() then
			channel = IsInRaid() and "RAID" or "PARTY"
		else
			print("|cffff0000HousingMusic:|r You are not in a group.")
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
			print("|cffff0000HousingMusic:|r Invalid target.")
			return
		end
	else
		target = context
	end
	
	if target then
		print("|cff00ff00HousingMusic:|r Sending house music data to "..target.."...")
	else
		print("|cff00ff00HousingMusic:|r Broadcasting house music data via "..channel.."...")
	end

	SendData(channel, target, locationKey, playlistTable)
end

local TriggerFrame = CreateFrame("Frame")
TriggerFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
TriggerFrame:RegisterEvent("UPDATE_MOUSEOVER_UNIT")
TriggerFrame:RegisterEvent("HOUSE_PLOT_ENTERED")
TriggerFrame:RegisterEvent("HOUSE_PLOT_EXITED")

local function TryAutoShare(unitID)
	if not C_Housing.IsInsideHouse() then return end
	if not C_Housing.IsInsideOwnHouse() then return end

	if not UnitExists(unitID) or not UnitIsPlayer(unitID) then return end
	if UnitIsUnit(unitID, "player") then return end
	if UnitIsDeadOrGhost(unitID) then return end

	local targetName = GetUnitName(unitID, true)
	if not targetName then return end

	print(targetName)
	if HM.IsPlayerIgnored(targetName) then
		print("preventing sending data to "..targetName)
		return 
	end

	local now = GetTime()
	local lastSent = HM.SentTracker[targetName] or 0

	if (now - lastSent) > AUTO_SEND_COOLDOWN then

		HM.SentTracker[targetName] = now
		
		HM.SharePlaylist(targetName)
	end
end

TriggerFrame:SetScript("OnEvent", function(self, event, ...)
	if event == "PLAYER_TARGET_CHANGED" then
		TryAutoShare("target")
	elseif event == "UPDATE_MOUSEOVER_UNIT" then
		TryAutoShare("mouseover")
	elseif event == "HOUSE_PLOT_ENTERED" or event == "HOUSE_PLOT_EXITED" then
		HM.SentTracker = {}
	end
end)

function HM.OnCommReceived(prefix, text, channel, sender, target, zoneChannelID, localID, name, instanceID)
	if prefix ~= HM.CommPrefix then return end

	if not target or target == "" then return end

	if HM.IsPlayerIgnored(target) then
		return 
	end
	
	if sender == UnitName("player") then return end

	-- example: H:LocationKey:Index:Total:Data
	local msgType, locationKey, idx, total, data = strsplit(":", text, 5)
	
	if msgType == MSG_TYPE_HOUSE and locationKey and idx and total and data then
		ProcessReceivedPlaylist(sender, locationKey, tonumber(idx), tonumber(total), data)
	end
end