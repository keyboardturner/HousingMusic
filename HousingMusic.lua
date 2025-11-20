local _, HM = ...

local f = CreateFrame("Frame")
f:RegisterEvent("ZONE_CHANGED")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:RegisterEvent("PLAYER_STARTED_MOVING")
f:RegisterEvent("NEW_WMO_CHUNK")
f:RegisterEvent("PLAYER_LEAVING_WORLD")
f:RegisterEvent("ZONE_CHANGED_INDOORS")
f:RegisterEvent("AREA_POIS_UPDATED")
f:RegisterEvent("FOG_OF_WAR_UPDATED")
f:RegisterEvent("MOUNT_JOURNAL_USABILITY_CHANGED")
f:RegisterEvent("HOUSE_PLOT_ENTERED")
f:RegisterEvent("HOUSE_PLOT_EXITED")
f:RegisterEvent("CURRENT_HOUSE_INFO_UPDATED")

local LRPM = LibStub:GetLibrary("LibRPMedia-1.2")

local silentMusicPath = "Interface\\AddOns\\HousingMusic\\Assets\\Sound\\silenttrack.mp3"
local silentMusicActive = false

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

local DAY_START_HOUR = 6 -- 6:00 AM
local NIGHT_START_HOUR = 18 -- 6:00 PM

function IsDay()
	local hour = GetGameTime()
	return hour >= DAY_START_HOUR and hour < NIGHT_START_HOUR
end

function IsNight()
	return not IsDay()
end

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
	{
		subzone = "Wizard's Sanctum",
		mapID = 84, -- Stormwind City
		conditions = { IsIndoors },
		playlist = {
			{ fileID = 1417251 },
			{ fileID = 1417252 },
			{ fileID = 1417253 },
			{ fileID = 1417254 },
			{ fileID = 1417255 },
			{ fileID = 1417256 },
			{ fileID = 1417257 },
			{ fileID = 1417258 },
			{ fileID = 1417262 },
			{ fileID = 1417264 },
			{ fileID = 1417266 },
			{ fileID = 1417267 },
			{ fileID = 1417268 },
			{ fileID = 1417269 },
		},
	},

	{
		name = "The Blue Recluse",
		mapID = 84,
		minX = 0.50, maxX = 0.53,
		minY = 0.88, maxY = 0.97,
		conditions = { IsIndoors },
		playlist = {
			{ fileID = 53737 },
			{ fileID = 53738 },
			{ fileID = 53739 },
			{ fileID = 53740 },
			{ fileID = 53741 },
			{ fileID = 53742 },
			{ fileID = 53743 },
			{ fileID = 53748 },
			{ fileID = 53749 },
			{ fileID = 53750 },
			{ fileID = 53751 },
			{ fileID = 53752 },
			{ fileID = 53753 },
		},
	},
	{
		name = "The Golden Keg",
		mapID = 84,
		minX = 0.63, maxX = 0.67,
		minY = 0.30, maxY = 0.37,
		conditions = { IsIndoors },
		playlist = {
			{ fileID = 53737 },
			{ fileID = 53738 },
			{ fileID = 53739 },
			{ fileID = 53740 },
			{ fileID = 53741 },
			{ fileID = 53742 },
			{ fileID = 53743 },
			{ fileID = 53748 },
			{ fileID = 53749 },
			{ fileID = 53750 },
			{ fileID = 53751 },
			{ fileID = 53752 },
			{ fileID = 53753 },
		},
	},
	{
		name = "The Gilded Rose",
		mapID = 84,
		minX = 0.59, maxX = 0.61,
		minY = 0.73, maxY = 0.77,
		conditions = { IsIndoors },
		playlist = {
			{ fileID = 53737 },
			{ fileID = 53738 },
			{ fileID = 53739 },
			{ fileID = 53740 },
			{ fileID = 53741 },
			{ fileID = 53742 },
			{ fileID = 53743 },
			{ fileID = 53748 },
			{ fileID = 53749 },
			{ fileID = 53750 },
			{ fileID = 53751 },
			{ fileID = 53752 },
			{ fileID = 53753 },
		},
	},
	{
		subzone = "The Slaughtered Lamb",
		mapID = 84,
		conditions = { IsIndoors },
		playlist = {
			{ fileID = 53737 },
			{ fileID = 53738 },
			{ fileID = 53739 },
			{ fileID = 53740 },
			{ fileID = 53741 },
			{ fileID = 53742 },
			{ fileID = 53743 },
			{ fileID = 53748 },
			{ fileID = 53749 },
			{ fileID = 53750 },
			{ fileID = 53751 },
			{ fileID = 53752 },
			{ fileID = 53753 },
		},
	},
	{
		subzone = "Pig and Whistle Tavern",
		mapID = 84,
		conditions = { IsIndoors },
		playlist = {
			{ fileID = 53737 },
			{ fileID = 53738 },
			{ fileID = 53739 },
			{ fileID = 53740 },
			{ fileID = 53741 },
			{ fileID = 53742 },
			{ fileID = 53743 },
			{ fileID = 53748 },
			{ fileID = 53749 },
			{ fileID = 53750 },
			{ fileID = 53751 },
			{ fileID = 53752 },
			{ fileID = 53753 },
		},
	},

	--[[ -- test
	{
		name = "Cathedral Garden",
		mapID = 84,
		minX = 0.001, maxX = 0.002,
		minY = 0.001, maxY = 0.002,
		playlist = {
			{ fileID = 53737 },
			{ fileID = 53738 },
			{ fileID = 53739 },
		},
	},
	]]

	{
		subzone = "Dwarven District",
		conditions = { IsDay },
		mapID = 84, -- Stormwind City
		playlist = {
			{ fileID = 53192 },
			{ fileID = 53193 },
			{ fileID = 53194 },
			{ fileID = 53195 },
		},
	},
	{
		subzone = "Dwarven District",
		conditions = { IsNight },
		mapID = 84, -- Stormwind City
		playlist = {
			{ fileID = 441565 },
			{ fileID = 441566 },
			{ fileID = 441567 },
			{ fileID = 441568 },
			{ fileID = 441569 },
			{ fileID = 441570 },
			{ fileID = 441571 },
		},
	},

	{
		name = "Trading Post",
		mapID = 84,
		minX = 0.488, maxX = 0.52,
		minY = 0.70, maxY = 0.75,
		conditions = { IsIndoors },
		playlist = {
			{ fileID = 4889877 },
			{ fileID = 4889879 },
			{ fileID = 4889881 },
			{ fileID = 4887953 },
			{ fileID = 4887955 },
			{ fileID = 4887957 },
			{ fileID = 5168460 },
			{ fileID = 5168462 },
		},
	},

	{ -- requires defining map coords due to borked frequent subzone changes
		name = "Mage Quarter Area Day",
		mapID = 84,
		minX = 0.39, maxX = 0.56,
		minY = 0.75, maxY = 0.91,
		conditions = { IsDay },
		playlist = {
			{ fileID = 229800 },
			{ fileID = 229801 },
			{ fileID = 229802 },
			{ fileID = 229803 },
			{ fileID = 1417233 },
			{ fileID = 1417234 },
			{ fileID = 1417235 },
		},
	},
	{ -- requires defining map coords due to borked frequent subzone changes
		name = "Mage Quarter Area Night",
		mapID = 84,
		minX = 0.39, maxX = 0.56,
		minY = 0.75, maxY = 0.91,
		conditions = { IsNight },
		playlist = {
			{ fileID = 229800 },
			{ fileID = 229801 },
			{ fileID = 229802 },
			{ fileID = 229803 },
			{ fileID = 1417236 },
			{ fileID = 1417237 },
			{ fileID = 1417238 },
			{ fileID = 1417239 },
		},
	},

	{
		subzone = "The Seer's Library",
		mapID = 111, -- Shattrath City
		conditions = { IsIndoors },
		playlist = {
			{ fileID = 53806 },
			{ fileID = 53807 },
			{ fileID = 53808 },
			{ fileID = 53809 },
			{ fileID = 53810 },
			{ fileID = 53811 },
		},
	},

	{
		name = "Infinite Bazaar - Dalaran",
		mapID = 619, -- Broken Isles (Outer Dalaran, Legion Remix)
		minX = 0.451, maxX = 0.461,
		minY = 0.673, maxY = 0.689,
		playlist = {
			{ fileID = 4872432 },
			{ fileID = 4872434 },
			{ fileID = 4872442 },
			{ fileID = 4880323 },
			{ fileID = 4880325 },
			{ fileID = 4887909 },
			{ fileID = 4887913 },
			{ fileID = 4887915 },
			{ fileID = 4887927 },
			{ fileID = 4887929 },
		},
	},

	{
		subzone = "A Hero's Welcome",
		mapID = 627, -- Dalaran
		playlist = {
			{ fileID = 53737 },
			{ fileID = 53738 },
			{ fileID = 53739 },
			{ fileID = 53740 },
			{ fileID = 53741 },
			{ fileID = 53742 },
			{ fileID = 53743 },
			{ fileID = 53748 },
			{ fileID = 53749 },
			{ fileID = 53750 },
			{ fileID = 53751 },
			{ fileID = 53752 },
			{ fileID = 53753 },
		},
	},
	{
		name = "Garrison (Alliance)",
		mapID = 582, -- Garrison (Alliance)
		playlist = {
			{ fileID = 53737 },
			{ fileID = 53738 },
			{ fileID = 53739 },
			{ fileID = 53740 },
			{ fileID = 53741 },
			{ fileID = 53742 },
			{ fileID = 53743 },
			{ fileID = 53748 },
			{ fileID = 53749 },
			{ fileID = 53750 },
			{ fileID = 53751 },
			{ fileID = 53752 },
			{ fileID = 53753 },
		},
	},
	{
		name = "Alliance Housing District",
		mapID = 2352, -- Alliance Housing District
		playlist = {
			{ fileID = 53737 },
			{ fileID = 53738 },
			{ fileID = 53739 },
			{ fileID = 53740 },
			{ fileID = 53741 },
			{ fileID = 53742 },
			{ fileID = 53743 },
			{ fileID = 53748 },
			{ fileID = 53749 },
			{ fileID = 53750 },
			{ fileID = 53751 },
			{ fileID = 53752 },
			{ fileID = 53753 },
			{ fileID = 4889877 },
			{ fileID = 4889879 },
			{ fileID = 4889881 },
			{ fileID = 4887953 },
			{ fileID = 4887955 },
			{ fileID = 4887957 },
			{ fileID = 5168460 },
			{ fileID = 5168462 },
		},
	},
	{
		name = "Horde Housing District",
		mapID = 2351, -- Horde Housing District
		playlist = {
			{ fileID = 441768 },
			{ fileID = 441769 },
			{ fileID = 441770 },
			{ fileID = 441771 },
			{ fileID = 441772 },
			{ fileID = 441773 },
			{ fileID = 441774 },
			{ fileID = 441775 },
			{ fileID = 53541 },
			{ fileID = 53542 },
			{ fileID = 53543 },
			{ fileID = 53544 },
			{ fileID = 53545 },
			{ fileID = 53546 },
		},
	},
	{
		name = "(TEMP) Silvermoon City",
		mapID = 2393, -- Silvermoon City (Midnight)
		playlist = {
			{ fileID = 53474 },
			{ fileID = 53475 },
			{ fileID = 53476 },
			{ fileID = 53477 },
			{ fileID = 53478 },
			{ fileID = 53479 },
		},
	},
	{
		name = "(TEMP) Eversong Woods",
		mapID = 2395, -- Eversong Woods (Midnight)
		playlist = {
			{ fileID = 53480 },
			{ fileID = 53481 },
			{ fileID = 53482 },
			{ fileID = 53483 },
			{ fileID = 53484 },
			{ fileID = 53485 },
		},
	},
	{
		name = "(TEMP) Harandar",
		mapID = 2413, -- Harandar
		playlist = {
			{ fileID = 6065816 },
			{ fileID = 53819 },
			{ fileID = 53820 },
			{ fileID = 53821 },
			{ fileID = 53822 },
			{ fileID = 53823 },
			{ fileID = 53824 },
			{ fileID = 53803 },
			{ fileID = 53804 },
			{ fileID = 53805 },
			{ fileID = 53630 },
			{ fileID = 53631 },
			{ fileID = 53632 },
		},
	},
	--[[ test
	{
		name = "Nagrand Zone Flying",
		zone = "Nagrand",
		conditions = { IsFlying },
		mapID = 107, -- Nagrand
		playlist = {
			{ fileID = 441565 },
			{ fileID = 441566 },
			{ fileID = 441567 },
			{ fileID = 441568 },
			{ fileID = 441569 },
			{ fileID = 441570 },
			{ fileID = 441571 },
		},
	},
	]]
	{
		name = "Arcantina (Hearthstone Tavern)",
		mapID = 2541, -- Hearthstone Tavern / Arcantina
		playlist = {
			{ fileCustom = 1 },
			{ fileCustom = 2 },
			{ fileCustom = 3 },
			{ fileCustom = 4 },
			{ fileCustom = 5 },
			{ fileCustom = 6 },
			{ fileCustom = 7 },
			{ fileCustom = 8 },
			{ fileCustom = 13 },
			{ fileCustom = 14 },
		},
	},
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

local function GetPlayerHouseZone()
	if not (C_Housing and C_Housing.IsInsideOwnHouse and C_Housing.IsInsideOwnHouse()) then
		return nil
	end

	if not HousingMusic_DB or not HousingMusic_DB.PlayerMusic then
		return nil
	end

	local dynamicPlaylist = {}
	for fileID, enabled in pairs(HousingMusic_DB.PlayerMusic) do
		if enabled then
			table.insert(dynamicPlaylist, { fileID = fileID })
		else
		end
	end

	if #dynamicPlaylist == 0 then
		return nil
	end
	return {
		name = "My Personal House",
		playlist = dynamicPlaylist,
	}
end

local function IsInZone(zone)
	local mapID = C_Map.GetBestMapForUnit("player")
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
				if not valid then
				else
					return zone
				end
			else
				return zone
			end
		end
	end

	return nil
end

local function StopCurrentMusic()
	musicPlaying = false;
	musicTimer = 0;
	timerElapsed = 0;
	currentTrackIndex = 1;
	activeZone = nil;
	silentMusicActive = false;

	if soundHandle then
		StopSound(soundHandle, fadeoutTime);
		soundHandle = nil;
	end
	
	StopMusic()
end

function HM.PlaySpecificMusic(fileID)
	StopCurrentMusic()
	StartSilentMusic()

	local musicInfo = LRPM:GetMusicInfoByID(fileID)
	if not musicInfo or not musicInfo.duration then
		print("HousingMusic Error: Could not retrieve info for ID:", fileID)
		return
	end

	local willPlay, handle = PlaySoundFile(fileID, "Music")
	if willPlay then
		soundHandle = handle
		musicTimer = musicInfo.duration
		timerElapsed = 0
		musicPlaying = true
		
		HM.CurrentPlayingID = fileID 
	else
		soundHandle = nil
	end
end

function HM.StopManualMusic()
	StopCurrentMusic()
	HM.CurrentPlayingID = nil
end

function HM.GetPlaybackState()
	return {
		isPlaying = musicPlaying,
		elapsed = timerElapsed,
		duration = musicTimer,
		fileID = HM.CurrentPlayingID
	}
end

local function PlayNextTrack()
	if not activeZone then return end

	StartSilentMusic()

	local playlist = activeZone.playlist
	local numTracks = #playlist
	if numTracks == 0 then return end

	local nextIndex
	repeat
		nextIndex = math.random(1, numTracks)
	until numTracks == 1 or nextIndex ~= lastTrackIndex

	local track = playlist[nextIndex]
	if not track then return end

	local soundFileToPlay
	local soundDuration
	local trackNameForDebug

	if track.fileID then
		if type(track.fileID) ~= "number" then
			print("Debug: Track ID is not a number:", track.fileID)
		end
		local musicInfo = LRPM:GetMusicInfoByID(track.fileID)
		if not musicInfo or not musicInfo.duration then
			print("HousingMusic Error: Could not retrieve music info for fileID: " .. tostring(track.fileID))
			return
		end
		
		soundFileToPlay = track.fileID
		soundDuration = musicInfo.duration
		trackNameForDebug = "Game Music (ID: " .. track.fileID .. ")"

	elseif track.fileCustom then
		local customTrackInfo = HM.customMusic[track.fileCustom]
		if not customTrackInfo then
			print("HousingMusic Error: No custom music found for key: " .. tostring(track.fileCustom))
			return
		end

		soundFileToPlay = customTrackInfo.path
		soundDuration = customTrackInfo.duration
		trackNameForDebug = customTrackInfo.name

	else
		print("HousingMusic Error: Unknown track type in playlist. Entry must have 'fileID' or 'fileCustom'.")
		return
	end

	local willPlay, handle = PlaySoundFile(soundFileToPlay, "Music")
	if willPlay then
		print("HousingMusic: Now playing '".. trackNameForDebug .."'")
		soundHandle = handle
		musicTimer = soundDuration
		timerElapsed = 0
		musicPlaying = true
		lastTrackIndex = nextIndex
	else
		soundHandle = nil
		return
	end
end

local function CheckConditions()
	if C_CVar.GetCVar("Sound_EnableMusic") ~= "1" then
		if musicPlaying then
			StopCurrentMusic()
		end
		return
	end

	local zone = FindActiveZone()

	if zone then
		local newZoneName = zone.name or zone.subzone
		local oldZoneName = activeZone and (activeZone.name or activeZone.subzone)

		if newZoneName ~= oldZoneName then
			StopCurrentMusic()
			activeZone = zone
			print("Entered custom zone:", newZoneName)
		else
			activeZone = zone 
		end
		if not musicPlaying then
			PlayNextTrack()
		end
	else
		if musicPlaying then
			StopCurrentMusic()
		end
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
			PlayNextTrack()
		end
	end
end)

f:SetScript("OnEvent", function(_, event)
	if event == "PLAYER_LEAVING_WORLD" then
		StopCurrentMusic()
	else
		CheckConditions()
	end
end)
