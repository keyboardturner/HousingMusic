local _, HM = ...

local LRPM = LibStub("LibRPMedia-1.2")

HMGlobal = HM
HM.CommPrefix = "HousingMusic"

-- "HEADER:HouseKey:FileID,FileID,FileID..."
-- "H"- House Data
local MSG_TYPE_HOUSE = "H"

local MAX_MSG_BYTES = 250

local AUTO_SEND_COOLDOWN = 30 

HM.SentTracker = {} 

local function GetCurrentHouseKey()
	if not C_Housing or not C_Housing.GetCurrentHouseInfo then return nil end
	
	local info = C_Housing.GetCurrentHouseInfo()
	
	if not info or not info.ownerName or info.ownerName == "" then return nil end
	if not info.neighborhoodGUID or not info.plotID then return nil end

	-- format: Owner_NeighborhoodGUID_PlotID
	return string.format("%s_%s_%d", info.ownerName, info.neighborhoodGUID, info.plotID)
end

local CommsFrame = CreateFrame("Frame")
CommsFrame:RegisterEvent("ADDON_LOADED")
CommsFrame:RegisterEvent("CHAT_MSG_ADDON")

CommsFrame:SetScript("OnEvent", function(self, event, ...)
	if event == "ADDON_LOADED" then
		local addonName = ...
		if addonName == "HousingMusic" then
			CachedMusic_DB = CachedMusic_DB or {}
			
			C_ChatInfo.RegisterAddonMessagePrefix(HM.CommPrefix)
		end
	elseif event == "CHAT_MSG_ADDON" then
		HM.OnCommReceived(...)
	end
end)

local function ProcessReceivedPlaylist(receivedHouseKey, dataString)
	if not receivedHouseKey or not dataString then return end
	
	local myCurrentKey = GetCurrentHouseKey()

	if not myCurrentKey then return end

	if myCurrentKey ~= receivedHouseKey then
		-- print("HousingMusic Debug: Ignored data for mismatching plot.")
		return
	end

	local validSongs = {}
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
	
	if count > 0 then
		CachedMusic_DB[receivedHouseKey] = validSongs
		print(string.format("|cff00ff00HousingMusic:|r Received %d songs for this house.", count))
		
		if HM.UpdateCachedMusicUI then
			HM.UpdateCachedMusicUI()
		end
	end
end

local function SendData(channel, target, houseKey, playlistTable)
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
	
	local headerFmt = MSG_TYPE_HOUSE .. ":%s:"
	local baseOverhead = string.format(headerFmt, houseKey)
	local availableBytes = MAX_MSG_BYTES - #baseOverhead
	
	local currentChunk = ""
	
	for _, idStr in ipairs(ids) do
		local nextLen = #currentChunk + #idStr + 1 -- +1 for comma
		
		if nextLen > availableBytes then
			local payload = string.format(headerFmt .. "%s", houseKey, currentChunk)
			ChatThrottleLib:SendAddonMessage("NORMAL", HM.CommPrefix, payload, channel, target)

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
		local payload = string.format(headerFmt .. "%s", houseKey, currentChunk)
		ChatThrottleLib:SendAddonMessage("NORMAL", HM.CommPrefix, payload, channel, target)
	end
end

function HM.SharePlaylist(context)
	local playlistTable = HM.GetActivePlaylistTable()
	if not playlistTable then return end

	local houseKey = GetCurrentHouseKey()
	if not houseKey then
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

	SendData(channel, target, houseKey, playlistTable)
end

local TriggerFrame = CreateFrame("Frame")
TriggerFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
TriggerFrame:RegisterEvent("UPDATE_MOUSEOVER_UNIT")
TriggerFrame:RegisterEvent("HOUSE_PLOT_ENTERED")
TriggerFrame:RegisterEvent("HOUSE_PLOT_EXITED")

local function TryAutoShare(unitID)
	if not C_Housing.IsInsideHouse() then return end

	if not UnitExists(unitID) or not UnitIsPlayer(unitID) then return end
	if UnitIsUnit(unitID, "player") then return end
	if UnitIsDeadOrGhost(unitID) then return end

	local targetName = GetUnitName(unitID, true)
	if not targetName then return end

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

	if sender == UnitName("player") or sender == GetUnitName("player", true) then return end

	-- example: H:Keyboarddh_Housing-4-1-69-19C6B_39:123,456,789
	local msgType, houseKey, data = strsplit(":", text, 3)
	
	if msgType == MSG_TYPE_HOUSE and houseKey and data then
		ProcessReceivedPlaylist(houseKey, data)
	end
end