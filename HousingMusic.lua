local _, HM = ...

local L = HM.L;

local function Print(...)
	local prefix = L["HousingMusic_Colored"] .. ": "
	DEFAULT_CHAT_FRAME:AddMessage(string.join(" ", prefix, ...));
end

HM.Print = Print

local DefaultsTable = { -- HousingMusic_DB
	autoplayMusic = true,
	showMusicOnIcon = true,
	showMinimapIcon = true,
	showControlFrameIcon = true,
	toastPopup = false,
	keepMinimized = false,
	autosharePlaylist = 1, -- 1 = everyone, 2 = friends and guild, 3 = friends,  4 = none
	autoImportPlaylist = 1,
	customImportPlaylist = 2,
	normalizeNames = false,
	chatboxMessages = false,
	clearCache = 2, -- 1 = 7 days, 2 = 14 days, 3 = 30 days, 4 = 60 days
	addonCompatibilities = { -- controls if addon should stop its own music during addon events
		Musician_StopMusic = true,
		Soundtrack_StopMusic = true,
		EpicMusicPlayer_StopMusic = true,
		Simscraft_StopMusic = true,
		TotalRP3_StopMusic = true,
		TotalRP3_ShowPlaylistOnProfile = true,
	},
	volumeControls = { -- first inherit the current user's CVar Values to restore them afterward
		Sound_MasterVolume = 1.0,
		Sound_MusicVolume = 0.4,
		Sound_SFXVolume = 1.0,
		Sound_AmbienceVolume = 0.6,
		FootstepSounds = 1,
		softTargettingInteractKeySound = 0, -- this might change with the interact key
	},

	--layout = {
	--	skin = {
	--		skinAtlas = "housing-basic-container",
	--		skinAtlasSliceMargins = {64, 64, 64, 112},
	--		skinAtlasSliceMode = Enum.UITextureSliceMode.Stretched,
	--		color = {1, 1, 1, 1},
	--	},
	--	fontSize_List = 12,
	--	fontSize_Player = 12,
	--	fontSize_Title = 12,
	--	fontSize_Time = 12,
	--	
	--	fontStyle_List = "",
	--	fontStyle_Player = "",
	--	fontStyle_Title = "",
	--	fontStyle_Time = "",
	--},

};

HM.DefaultsTable = DefaultsTable;

local f = CreateFrame("Frame")
f:RegisterEvent("ADDON_LOADED")
f:RegisterEvent("HOUSE_PLOT_ENTERED")
f:RegisterEvent("HOUSE_PLOT_EXITED")
f:RegisterEvent("PLAYER_LOGOUT")
f:RegisterEvent("CURRENT_HOUSE_INFO_UPDATED")

local LRPM = LibStub:GetLibrary("LibRPMedia-1.2")

local silentMusicPath = "Interface\\AddOns\\HousingMusic\\Assets\\Sound\\silenttrack.mp3"
local silentMusicActive = false
HM.MAX_PLAYLIST_SIZE = 50

--EventRegistry:RegisterFrameEventAndCallback("CURRENT_HOUSE_INFO_RECIEVED", function(...) DevTools_Dump({...}) end) -- test function for querying housing
-- another similar event - CURRENT_HOUSE_INFO_UPDATED
-- fired upon entering house, even though it says plot -  HOUSE_PLOT_ENTERED
-- fired upon exiting house, even though it says plot - HOUSE_PLOT_EXITED


-- C_Housing.RequestCurrentHouseInfo() function dumps info as follows:
--[[
... = {
	ownerName="Keyboarddh",
	plotID = 39, -- plot location on the map
	neighborhoodName="Brittle Pilgrim Cornucopia", -- can be custom
	houseName="39 Brittle Prilgrim Cornucopia", -- plotID + neighborhoodName
	neighborhoodGUID="Housing-4-1-69-19C6B", -- GUID, obviously
	houseGUID="Opaque-2", -- Reworked entirely - It's now an "anonymous" ID. Number increments with what the client has seen
}

-- or, if nothing present
... = {
	plotID = -1 -- no house present
}

-- in general
... = {
	{ Name = plotID, Type = "number", Nilable = false },
	{ Name = houseName, Type = "string", Nilable = false },
	{ Name = ownerName, Type = "string", Nilable = false },
	{ Name = plotCost, Type = "number", Nilable = false }, -- unknown
	{ Name = neighborhoodName, Type = "string", Nilable = false },
	{ Name = moveOutTime, Type = "time_t", Nilable = false }, -- unknown
	{ Name = plotReserved, Type = "bool", Nilable = false }, -- unknown
	{ Name = neighborhoodGUID, Type = "WOWGUID", Nilable = false },
	{ Name = houseGUID, Type = "WOWGUID", Nilable = false },
},
]]

-- C_Housing.IsInsideHouseOrPlot() can be used to see if a player is in the plot/house
-- C_Housing.IsInsideHouse() can be used to see if a player is in the house
-- C_Housing.IsInsidePlot() can be used to see if a player is in the plot

--EventRegistry:RegisterFrameEventAndCallback("HOUSE_PLOT_ENTERED", function(...) print("entered plot"); C_Housing.RequestCurrentHouseInfo() end) -- test function for querying housing
--EventRegistry:RegisterFrameEventAndCallback("HOUSE_PLOT_EXITED", function(...) print("exited plot"); C_Housing.RequestCurrentHouseInfo() end) -- test function for querying housing
--EventRegistry:RegisterFrameEventAndCallback("CURRENT_HOUSE_INFO_UPDATED", function(...) DevTools_Dump({...}); print("updated info"); C_Housing.RequestCurrentHouseInfo() end) -- test function for querying housing
--EventRegistry:RegisterFrameEventAndCallback("HOUSING_LAYOUT_PIN_FRAME_RELEASED", function(...) DevTools_Dump({...}); print("pinframe released"); end) -- query pin frame released during floorplan editor
--EventRegistry:RegisterFrameEventAndCallback("HOUSING_LAYOUT_PIN_FRAME_ADDED", function(...) DevTools_Dump({...}); print("pinframe added"); end) -- query pin frame released during floorplan editor

----------------------------------------------------------
-- volume sliders
----------------------------------------------------------

local VolumeCVars = {
	"Sound_MasterVolume",
	"Sound_MusicVolume",
	"Sound_SFXVolume",
	"Sound_AmbienceVolume",
	"Sound_DialogVolume",
};

function HM.StoreVolumeSettings()
	HousingMusic_DB.restoreVolumes = HousingMusic_DB.restoreVolumes or {}
	
	local hasStored = false
	for _, cvar in ipairs(VolumeCVars) do
		if HousingMusic_DB.restoreVolumes[cvar] == nil then
			local currentVal = GetCVar(cvar)
			HousingMusic_DB.restoreVolumes[cvar] = currentVal
			hasStored = true
		end
	end
end

function HM.RestoreVolumeSettings()
	if not HousingMusic_DB or not HousingMusic_DB.restoreVolumes then return end
	
	for cvar, val in pairs(HousingMusic_DB.restoreVolumes) do
		SetCVar(cvar, val)
	end
	
	HousingMusic_DB.restoreVolumes = nil
end

function HM.ApplyHouseVolumeSettings()
	if not HousingMusic_DB or not HousingMusic_DB.volumeControls then return end
	
	for _, cvar in ipairs(VolumeCVars) do
		local val = HousingMusic_DB.volumeControls[cvar]
		if val then
			SetCVar(cvar, val)
		end
	end
end

function HM.UpdateVolumeCVar(cvar, value)
	if C_Housing.IsInsideHouse() then
		SetCVar(cvar, value)
	end
end

----------------------------------------------------------
-- profiles
----------------------------------------------------------

function HM.PurgeOldPlaylists()
	if not HM_CachedMusic_DB then return end
	
	HM_CachedMusic_Metadata = HM_CachedMusic_Metadata or {}

	local setting = (HousingMusic_DB and HousingMusic_DB.clearCache) or 2
	local days = 14

	if setting == 1 then days = 7
	elseif setting == 2 then days = 14
	elseif setting == 3 then days = 30
	elseif setting == 4 then days = 60
	end

	local secondsLimit = days * 24 * 60 * 60
	local now = GetServerTime()

	local cleanedCount = 0

	for locationKey, senders in pairs(HM_CachedMusic_DB) do
		
		HM_CachedMusic_Metadata[locationKey] = HM_CachedMusic_Metadata[locationKey] or {}

		for senderName, _ in pairs(senders) do
			
			if not HM_CachedMusic_Metadata[locationKey][senderName] then
				HM_CachedMusic_Metadata[locationKey][senderName] = {
					lastSeen = now,
					isFavorite = false
				}
			end

			local meta = HM_CachedMusic_Metadata[locationKey][senderName]
			
			local timeDiff = now - (meta.lastSeen or 0)
			
			if timeDiff > secondsLimit then
				if meta.isFavorite then
				else
					HM_CachedMusic_DB[locationKey][senderName] = nil
					HM_CachedMusic_Metadata[locationKey][senderName] = nil
					cleanedCount = cleanedCount + 1
				end
			end
		end

		if next(HM_CachedMusic_DB[locationKey]) == nil then
			HM_CachedMusic_DB[locationKey] = nil
			HM_CachedMusic_Metadata[locationKey] = nil
		end
	end

	--if cleanedCount > 0 then
	--	Print(string.format(L["PurgedOldPlaylists"], cleanedCount, days))
	--end
end

function HM.SetCachedPlaylistFavorite(locationKey, senderName, isFavorite)
	if HM_CachedMusic_Metadata and HM_CachedMusic_Metadata[locationKey] and HM_CachedMusic_Metadata[locationKey][senderName] then
		HM_CachedMusic_Metadata[locationKey][senderName].isFavorite = isFavorite
		return true
	end
	return false
end

function HM.InitializeDB()
	HousingMusic_DB = HousingMusic_DB or {}
	
	if HM.DefaultsTable then
		for key, value in pairs(HM.DefaultsTable) do
			if HousingMusic_DB[key] == nil then
				HousingMusic_DB[key] = value
			end
		end
	end

	HousingMusic_DB.volumeControls = HousingMusic_DB.volumeControls or {}
	
	for _, cvar in ipairs(VolumeCVars) do
		if HousingMusic_DB.volumeControls[cvar] == nil then
			local currentVal = tonumber(GetCVar(cvar))
			if currentVal then
				HousingMusic_DB.volumeControls[cvar] = currentVal
			else
				HousingMusic_DB.volumeControls[cvar] = 0.5 
			end
		end
	end

	HousingMusic_DB.IgnoredPlayers = HousingMusic_DB.IgnoredPlayers or {}
	HousingMusic_DB.IgnoredSongs = HousingMusic_DB.IgnoredSongs or {}
	HousingMusic_DB.FavoritedSongs = HousingMusic_DB.FavoritedSongs or {}

	HousingMusic_DB.Playlists = HousingMusic_DB.Playlists or {}
	HousingMusic_DB.ActivePlaylist = HousingMusic_DB.ActivePlaylist or L["Default"]
	HousingMusic_DB.HouseAssignments = HousingMusic_DB.HouseAssignments or {}
	
	HousingMusic_DB.VisitorPreferences = HousingMusic_DB.VisitorPreferences or {}

	if not HousingMusic_DB.Playlists[L["Default"]] then
		HousingMusic_DB.Playlists[L["Default"]] = {}
	end

	HM.PurgeOldPlaylists()
end

local function GetOwnerHouseKey()
	if not C_Housing or not C_Housing.GetCurrentHouseInfo then return nil end
	
	local info = C_Housing.GetCurrentHouseInfo()
	
	if not info or not info.ownerName or info.ownerName == "" then return nil end
	if not info.neighborhoodGUID or not info.plotID then return nil end

	-- ownerName_NeighborhoodGUID_plotID
	return string.format("%s_%s_%d", info.ownerName, info.neighborhoodGUID, info.plotID)
end

local function GetLocationKey()
	if not C_Housing or not C_Housing.GetCurrentHouseInfo then return nil end
	local info = C_Housing.GetCurrentHouseInfo()
	if not info or not info.neighborhoodGUID or not info.plotID then return nil end
	return string.format("%s_%d", info.neighborhoodGUID, info.plotID)
end

function HM.GetActivePlaylistName() return HousingMusic_DB and HousingMusic_DB.ActivePlaylist or L["Default"] end

function HM.GetActivePlaylistTable()
	local name = HM.GetActivePlaylistName()
	local DB = HousingMusic_DB and HousingMusic_DB.Playlists
	if not DB then return end
	if DB and not HousingMusic_DB.Playlists[name] then
		HousingMusic_DB.Playlists[name] = {}
	end
	return HousingMusic_DB.Playlists[name]
end

function HM.IsSongIgnored(fileID)
	if not fileID then return false end
	return HousingMusic_DB and HousingMusic_DB.IgnoredSongs and HousingMusic_DB.IgnoredSongs[fileID]
end

function HM.SetSongIgnored(fileID, ignored)
	if not fileID then return end
	HousingMusic_DB.IgnoredSongs = HousingMusic_DB.IgnoredSongs or {}
	
	if ignored then
		HousingMusic_DB.IgnoredSongs[fileID] = true
	else
		HousingMusic_DB.IgnoredSongs[fileID] = nil
	end
end

function HM.IsSongFavorited(fileID)
	if not fileID then return false end
	return HousingMusic_DB and HousingMusic_DB.FavoritedSongs and HousingMusic_DB.FavoritedSongs[fileID]
end

function HM.SetSongFavorited(fileID, favorited)
	if not fileID then return end
	HousingMusic_DB.FavoritedSongs = HousingMusic_DB.FavoritedSongs or {}
	
	if favorited then
		HousingMusic_DB.FavoritedSongs[fileID] = true
	else
		HousingMusic_DB.FavoritedSongs[fileID] = nil
	end
end

function HM.SetActivePlaylist(playlistName)
	if HousingMusic_DB.Playlists[playlistName] then
		HousingMusic_DB.ActivePlaylist = playlistName
		
		if C_Housing and C_Housing.IsInsideOwnHouse and C_Housing.IsInsideOwnHouse() then
			local houseKey = GetOwnerHouseKey()
			if houseKey then
				HousingMusic_DB.HouseAssignments[houseKey] = playlistName
			end
		end
		if HM.BroadcastToNameplates then HM.BroadcastToNameplates() end

		return true
	end
	return false
end

function HM.CreatePlaylist(playlistName)
	if not playlistName or playlistName == "" then return false end
	if HousingMusic_DB.Playlists[playlistName] then return false end
	
	HousingMusic_DB.Playlists[playlistName] = {}
	HousingMusic_DB.ActivePlaylist = playlistName
	return true
end

function HM.DeletePlaylist(playlistName)
	if playlistName == L["Default"] then 
		Print(L["CantDeleteDefault"])
		return false 
	end
	
	HousingMusic_DB.Playlists[playlistName] = nil
	
	if HousingMusic_DB.ActivePlaylist == playlistName then
		HousingMusic_DB.ActivePlaylist = L["Default"]
		if not HousingMusic_DB.Playlists[L["Default"]] then
			HousingMusic_DB.Playlists[L["Default"]] = {}
		end
	end
	return true
end

function HM.GetPlaylistNames()
	local names = {}
	if not HousingMusic_DB then return end
	for k, v in pairs(HousingMusic_DB.Playlists) do
		table.insert(names, k)
	end
	table.sort(names)
	return names
end

function HM.RenamePlaylist(oldName, newName)
	if not oldName or not newName or newName == "" then return false end
	if oldName == newName then return true end
	if HousingMusic_DB.Playlists[newName] then 
		Print(L["PlaylistExists"])
		return false 
	end
	if not HousingMusic_DB.Playlists[oldName] then return false end
	
	HousingMusic_DB.Playlists[newName] = HousingMusic_DB.Playlists[oldName]
	HousingMusic_DB.Playlists[oldName] = nil
	
	if HousingMusic_DB.ActivePlaylist == oldName then
		HousingMusic_DB.ActivePlaylist = newName
	end
	
	for houseKey, assignedPlaylist in pairs(HousingMusic_DB.HouseAssignments) do
		if assignedPlaylist == oldName then
			HousingMusic_DB.HouseAssignments[houseKey] = newName
		end
	end
	Print(string.format(L["PlaylistRenamed"], WrapTextInColorCode(newName, "ff91cbfa")))
	return true
end

function HM.IsAutoplayEnabled()
	if HousingMusic_DB and HousingMusic_DB.autoplayMusic ~= nil then
		return HousingMusic_DB.autoplayMusic
	end
	
	if DefaultsTable and DefaultsTable.autoplayMusic ~= nil then
		return DefaultsTable.autoplayMusic
	end
	
	return true
end

function HM.IsControlIconEnabled()
	if HousingMusic_DB and HousingMusic_DB.showControlFrameIcon ~= nil then
		return HousingMusic_DB.showControlFrameIcon
	end
	
	-- Fallback to Defaults
	if DefaultsTable and DefaultsTable.showControlFrameIcon ~= nil then
		return DefaultsTable.showControlFrameIcon
	end
	
	return true 
end

----------------------------------------------------------
-- playback
----------------------------------------------------------

 -- not needed for now, remnant of older playlist creation
--local DAY_START_HOUR = 6 -- 6:00 AM
--local NIGHT_START_HOUR = 18 -- 6:00 PM

--local function IsDay()
--	local hour = GetGameTime()
--	return hour >= DAY_START_HOUR and hour < NIGHT_START_HOUR
--end

--local function IsNight()
--	return not IsDay()
--end

local function StartSilentMusic()
	--if silentMusicActive then return end -- there's no need to check this
	PlayMusic(silentMusicPath)
	silentMusicActive = true
end

local function StopSilentMusic()
	if silentMusicActive then
		StopMusic()
		silentMusicActive = false
	end
end

-- the ones on top will be called first down the list in priority
-- these probably won't be added to the final version
local zones = {
};

local currentTrackIndex = 1
local musicPlaying = false
local musicTimer = 0
local timerElapsed = 0
local checkInterval = 1
local lastCheck = 0
local soundHandle = nil
local fadeoutTime = 5000
local lastTrackIndex = nil
local manualStop = false
local manualPlayback = false
local activeZone = nil -- previously removed
local currentTrackName = nil

local function GetPlayerHouseZone()
	if not (C_Housing and C_Housing.IsInsideHouse and C_Housing.IsInsideHouse()) then
		return nil
	end
	
	local dynamicPlaylist = {}
	local displayZoneName = L["HousingPlot"]

	if C_Housing.IsInsideOwnHouse and C_Housing.IsInsideOwnHouse() then
		if not HousingMusic_DB or not HousingMusic_DB.Playlists then return nil end

		local ownerKey = GetOwnerHouseKey()
		local targetPlaylistName = L["Default"]
		
		if ownerKey then
			if HousingMusic_DB.HouseAssignments[ownerKey] then
				targetPlaylistName = HousingMusic_DB.HouseAssignments[ownerKey]
			else
				targetPlaylistName = L["Default"]
			end
			
			if HousingMusic_DB.ActivePlaylist ~= targetPlaylistName then
				 HousingMusic_DB.ActivePlaylist = targetPlaylistName
			end
		else
			targetPlaylistName = HM.GetActivePlaylistName()
		end

		local activeList = HousingMusic_DB.Playlists[targetPlaylistName] or {}
		
		for fileID, enabled in pairs(activeList) do
			if enabled then table.insert(dynamicPlaylist, { fileID = fileID }) end
		end

		displayZoneName = string.format(L["MyHouse"], targetPlaylistName)

	else
		local locationKey = GetLocationKey()
		if not locationKey then return nil end

		if HM_CachedMusic_DB and HM_CachedMusic_DB[locationKey] then
			
			local houseInfo = C_Housing.GetCurrentHouseInfo()
			local ownerName = houseInfo and houseInfo.ownerName or L["Unknown"]
			
			local preferredSender = HousingMusic_DB.VisitorPreferences[locationKey]
			local selectedSender = nil
			local senders = HM_CachedMusic_DB[locationKey]

			if preferredSender and senders[preferredSender] then
				selectedSender = preferredSender
			else
				-- Try matching owner
				for senderName, _ in pairs(senders) do
					if string.find(senderName, ownerName) then
						selectedSender = senderName
						break
					end
				end
				if not selectedSender then
					selectedSender = next(senders)
				end
			end

			if selectedSender then
				local cachedList = senders[selectedSender]
				for fileID, enabled in pairs(cachedList) do
					if enabled then table.insert(dynamicPlaylist, { fileID = fileID }) end
				end

				displayZoneName = string.format(L["OwnersHouse"], ownerName, selectedSender)
				
				HousingMusic_DB.VisitorPreferences[locationKey] = selectedSender
			end
		end
	end

	if #dynamicPlaylist == 0 then
		return nil
	end
	
	return {
		name = displayZoneName,
		playlist = dynamicPlaylist,
	}
end

local function IsInZone(zone)
	local mapID = C_Map.GetBestMapForUnit("player")
	if not mapID then return false end
	if mapID ~= zone.mapID then return false end

	if not zone.subzone and not zone.minX then
		return true
	end

	if zone.subzone then
		local currentSubzone = GetSubZoneText()
		if currentSubzone ~= zone.subzone then
			return false 
		else
			return true
		end
	end

	if zone.minX and zone.maxX and zone.minY and zone.maxY then
		local pos = C_Map.GetPlayerMapPosition(mapID, "player")
		if not pos then return false end

		local x, y = pos:GetXY()
		if x and y then
			return x >= zone.minX and x <= zone.maxX and
				   y >= zone.minY and y <= zone.maxY
		end
	end
	return false
end


local function FindActiveZone()
	local houseZone = GetPlayerHouseZone()
	if houseZone then 
		return houseZone 
	end

	local mapID = C_Map.GetBestMapForUnit("player")
	if not mapID then return nil end

	if zones then
		for _, zone in ipairs(zones) do
			if zone.mapID == mapID and IsInZone(zone) then
				if zone.conditions then
					local valid = true
					for _, cond in ipairs(zone.conditions) do
						if not cond() then
							valid = false
							break
						end
					end
					if valid then
						return zone
					end
				else
					return zone
				end
			end
		end
	end

	return nil
end

HM.SongHistory = {}
local MAX_HISTORY_SIZE = 20

function HM.PushToHistory(fileID)
	if not fileID then return end
	
	if #HM.SongHistory > 0 and HM.SongHistory[#HM.SongHistory] == fileID then
		return
	end
	
	table.insert(HM.SongHistory, fileID)
	
	if #HM.SongHistory > MAX_HISTORY_SIZE then
		table.remove(HM.SongHistory, 1)
	end
end

function HM.GetPreviousSongName()
	if #HM.SongHistory == 0 then return nil end
	local id = HM.SongHistory[#HM.SongHistory]
	local info = LRPM:GetMusicInfoByID(id)
	return info and (info.names and info.names[1] or tostring(id)) or tostring(id)
end


local function StopCurrentMusic()
	musicPlaying = false;
	musicTimer = 0;
	timerElapsed = 0;
	currentTrackIndex = 1;
	currentTrackName = nil;
	-- activeZone = nil;
	silentMusicActive = false;

	if soundHandle then
		StopSound(soundHandle, fadeoutTime);
		soundHandle = nil;
	end
	
	if HousingMusic_DB and HousingMusic_DB.addonCompatibilities and HousingMusic_DB.addonCompatibilities.TotalRP3_StopMusic and C_AddOns.IsAddOnLoaded("totalRP3") then
		for _, handler in pairs(TRP3_API.utils.music.getHandlers()) do
			if handler.channel == "Music" then
				-- A music is currently playing
				return
			end
		end
	else
		StopMusic()
	end
end

function HM.PlaySpecificMusic(fileID, context)
	manualStop = false
	
	local isHistoryAction = context and context.isHistory
	if not isHistoryAction and HM.CurrentPlayingID then
		HM.PushToHistory(HM.CurrentPlayingID)
	end
	StopCurrentMusic()
	manualPlayback = true
	StartSilentMusic()

	local musicInfo = LRPM:GetMusicInfoByID(fileID)
	if not musicInfo or not musicInfo.duration then
		--Print(string.format(L["CannotRetrieveInfo"], fileID))
		manualPlayback = false
		return
	end

	local willPlay, handle = PlaySoundFile(fileID, "Music")
	if willPlay then
		soundHandle = handle
		musicTimer = musicInfo.duration
		timerElapsed = 0
		musicPlaying = true
		currentTrackName = musicInfo.names and musicInfo.names[1] or (string.format(L["FileID"], fileID))
		HM.CurrentPlayingID = fileID 
		if HM.TriggerPulseAnimation then
			HM.TriggerPulseAnimation()
		end
	else
		soundHandle = nil
		manualPlayback = false
	end
end

function HM.PlayPreviousTrack()
	if #HM.SongHistory > 0 then
		local prevID = table.remove(HM.SongHistory)
		HM.PlaySpecificMusic(prevID, { isHistory = true })
	end
end

function HM.StopManualMusic()
	manualStop = true
	manualPlayback = false
	
	StopCurrentMusic()
	HM.CurrentPlayingID = nil
end

function HM.GetPlaybackState()
	return {
		isPlaying = musicPlaying,
		elapsed = timerElapsed,
		duration = musicTimer,
		fileID = HM.CurrentPlayingID,
		name = currentTrackName,
	}
end

local function PlayNextTrack()
	if not activeZone then return end

	local playlist = activeZone.playlist
	local numTracks = #playlist
	if numTracks == 0 then return end

	local availableTracks = {}
	for i, track in ipairs(playlist) do
		if track.fileID then
			if not HM.IsSongIgnored(track.fileID) then
				table.insert(availableTracks, i)
			end
		elseif track.fileCustom then
			table.insert(availableTracks, i)
		end
	end

	if #availableTracks == 0 then
		StopCurrentMusic()
		return
	end

	if HM.CurrentPlayingID then
		HM.PushToHistory(HM.CurrentPlayingID)
	end

	local nextIndex
	if #availableTracks == 1 then
		nextIndex = availableTracks[1]
	else
		repeat
			local randomPick = math.random(1, #availableTracks)
			nextIndex = availableTracks[randomPick]
		until nextIndex ~= lastTrackIndex or #availableTracks == 1
	end

	local track = playlist[nextIndex]
	if not track then return end

	StartSilentMusic()

	local soundFileToPlay
	local soundDuration
	local trackNameForDebug

	if track.fileID then
		local musicInfo = LRPM:GetMusicInfoByID(track.fileID)
		if not musicInfo or not musicInfo.duration then
			--print("HousingMusic Error: Could not retrieve music info for fileID: " .. tostring(track.fileID))
			return
		end
		
		soundFileToPlay = track.fileID
		soundDuration = musicInfo.duration
		trackNameForDebug = musicInfo.names and musicInfo.names[1] or (string.format(L["GameMusic"], track.fileID))

	elseif track.fileCustom then
		local customTrackInfo = HM.customMusic and HM.customMusic[track.fileCustom]
		if not customTrackInfo then
			--print("HousingMusic Error: No custom music found for key: " .. tostring(track.fileCustom))
			return
		end

		soundFileToPlay = customTrackInfo.path
		soundDuration = customTrackInfo.duration
		trackNameForDebug = customTrackInfo.name

	else
		--print("HousingMusic Error: Unknown track type in playlist. Entry must have 'fileID' or 'fileCustom'.")
		return
	end

	if soundFileToPlay then
		local willPlay, handle = PlaySoundFile(soundFileToPlay, "Music")
		if willPlay then
			-- print("HousingMusic: Now playing '".. trackNameForDebug .."'")
			soundHandle = handle
			musicTimer = soundDuration
			timerElapsed = 0
			musicPlaying = true
			HM.CurrentPlayingID = soundFileToPlay
			currentTrackName = trackNameForDebug
			lastTrackIndex = nextIndex
			if HM.TriggerPulseAnimation then
				HM.TriggerPulseAnimation()
			end
		else
			soundHandle = nil
		end
	end
end

function HM.SkipTrack()
	StopCurrentMusic()
	PlayNextTrack()
end
local function CheckCVar()
	local CVar = C_CVar.GetCVar
	if CVar("Sound_EnableMusic") ~= "1" or CVar("Sound_EnableSoundWhenGameIsInBG") ~= "1" or CVar("Sound_MusicVolume") == "0" then
		StopCurrentMusic()
	end
end

local CVarListener = CreateFrame("Frame")
CVarListener:RegisterEvent("CVAR_UPDATE")
CVarListener:SetScript("OnEvent", function(self, event, arg1)
	if arg1 == "Sound_EnableSoundWhenGameIsInBG" or arg1 == "Sound_EnableMusic" or arg1 == "Sound_MusicVolume" then
		CheckCVar()
	end
end)

local function CheckConditions()

	if manualPlayback then return end

	local zone = FindActiveZone()

	if zone then
		local newZoneName = zone.name or zone.subzone
		local oldZoneName = activeZone and (activeZone.name or activeZone.subzone)

		if newZoneName ~= oldZoneName then
			manualStop = false
			
			StopCurrentMusic()
			activeZone = zone
			--Print(string.format(L["EnteredCustomZone"], newZoneName))
		else
			activeZone = zone 
		end
		
		if not musicPlaying and not manualStop then
			if HM.IsAutoplayEnabled() then
				PlayNextTrack()
			end
		end
	else
		if musicPlaying then
			StopCurrentMusic()
		end

		activeZone = nil
	end
end

f:SetScript("OnUpdate", function(_, elapsed)
	lastCheck = lastCheck + elapsed
	if lastCheck >= checkInterval then
		lastCheck = 0
		CheckConditions()
		if musicPlaying then
			StartSilentMusic()
		end
	end

	if musicPlaying then
		timerElapsed = timerElapsed + elapsed
		if timerElapsed >= musicTimer then
			if manualPlayback then
				manualPlayback = false
				StopCurrentMusic()
			else
				PlayNextTrack()
			end
		end
	end
end)

local function HM_SlashHandler(msg)
	if HM.MainFrame:IsShown() then
		HM.MainFrame:Hide()
	elseif C_Housing.IsInsideHouse() then
		HM.MainFrame:Show()
	else
		Print(L["InsideHouseToView"])
	end
end
SLASH_HOUSINGMUSIC1 = L["SLASH_HM1"];
SLASH_HOUSINGMUSIC2 = L["SLASH_HM2"];
SLASH_HOUSINGMUSIC2 = L["SLASH_HM3"];
SlashCmdList["HOUSINGMUSIC"] = HM_SlashHandler;

local function SetupTRP3Hook()
	if TRP3_API and TRP3_API.utils and TRP3_API.utils.music and TRP3_API.utils.music.playMusic then
		hooksecurefunc(TRP3_API.utils.music, "playMusic", function()
			if HousingMusic_DB and HousingMusic_DB.addonCompatibilities and HousingMusic_DB.addonCompatibilities.TotalRP3_StopMusic then
				HM.StopManualMusic()
			end
		end)
		hooksecurefunc(TRP3_API.utils.music, "stopMusic", function()
			if HousingMusic_DB and HousingMusic_DB.addonCompatibilities and HousingMusic_DB.addonCompatibilities.TotalRP3_StopMusic then
				manualStop = false
				CheckConditions()
			end
		end)
	end
end

f:SetScript("OnEvent", function(_, event, arg1)
	if event == "ADDON_LOADED" then
		if arg1 == "HousingMusic" then
			f:RegisterEvent("ZONE_CHANGED")
			f:RegisterEvent("PLAYER_ENTERING_WORLD")
			f:RegisterEvent("PLAYER_STARTED_MOVING")
			f:RegisterEvent("NEW_WMO_CHUNK")
			f:RegisterEvent("PLAYER_LEAVING_WORLD")
			f:RegisterEvent("ZONE_CHANGED_INDOORS")
			f:RegisterEvent("AREA_POIS_UPDATED")
			f:RegisterEvent("FOG_OF_WAR_UPDATED")
			f:RegisterEvent("MOUNT_JOURNAL_USABILITY_CHANGED")
			HM.InitializeDB()

			if C_Housing.IsInsideHouse() then
				HM.StoreVolumeSettings()
				HM.ApplyHouseVolumeSettings()
			end
			
			if C_AddOns.IsAddOnLoaded("TotalRP3") then
				SetupTRP3Hook()
			end
		elseif arg1 == "TotalRP3" then
			SetupTRP3Hook()
		end

	elseif event == "HOUSE_PLOT_ENTERED" then
		CheckConditions()

	elseif event == "PLAYER_ENTERING_WORLD" then
		if C_Housing.IsInsideHouse() then
			HM.StoreVolumeSettings()
			HM.ApplyHouseVolumeSettings()
		end
		CheckConditions()

	elseif event == "HOUSE_PLOT_EXITED" or event == "PLAYER_LOGOUT" then
		HM.RestoreVolumeSettings()
		if event == "HOUSE_PLOT_EXITED" then CheckConditions() end

	elseif event == "PLAYER_LEAVING_WORLD" then
		StopCurrentMusic()
	else
		CheckConditions()
	end
end)