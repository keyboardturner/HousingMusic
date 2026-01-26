local _, HM = ...

local L = HM.L;
local DefaultsTable = HM.DefaultsTable;
local Print = HM.Print

local LRPM = LibStub:GetLibrary("LibRPMedia-1.2")

if not LRPM then
	return
end

local goldR, goldG, goldB, goldA = NORMAL_FONT_COLOR:GetRGBA()

--HousingMusic_DB = HousingMusic_DB or {}
--HousingMusic_DB.Playlists = HousingMusic_DB.Playlists or {}
-- DB Initialization is handled in HousingMusic.lua now

local UpdateSavedMusicList
local RefreshBrowserPlaylists
--local flatMusicList = {} -- trade for FindMusic func in librpmedia
local fullSavedList = {}
local ScrollBoxLeft
local ScrollViewLeft
local ScrollBoxRight
local ScrollViewRight
local B_ScrollBoxLeft
local B_ScrollBoxRight
local SearchBoxLeft
local SearchBoxRight
local FilterAvailableList
local FilterSavedList
local selectedFileID = nil
local selectedBrowserKey = nil
local Decor_Controls_Blank = "Interface\\AddOns\\HousingMusic\\Assets\\Textures\\Decor_Controls_Blank.png"
local Decor_Controls_Music_Active = "Interface\\AddOns\\HousingMusic\\Assets\\Textures\\Decor_Controls_Music_Active.png"
local Decor_Controls_Music_Default = "Interface\\AddOns\\HousingMusic\\Assets\\Textures\\Decor_Controls_Music_Default.png"
local Decor_Controls_Music_Pressed = "Interface\\AddOns\\HousingMusic\\Assets\\Textures\\Decor_Controls_Music_Pressed.png"
local favtex = "Interface\\AddOns\\HousingMusic\\Assets\\Textures\\FavoriteHeart.png"
local nofavtex = "Interface\\AddOns\\HousingMusic\\Assets\\Textures\\FavoriteHeart_Empty.png"
local NextTexture = "Interface\\AddOns\\HousingMusic\\Assets\\Textures\\Next.png"
local PreviousTexture = "Interface\\AddOns\\HousingMusic\\Assets\\Textures\\Previous.png"
local PlayTexture = "Interface\\AddOns\\HousingMusic\\Assets\\Textures\\Play.png"
local StopTexture = "Interface\\AddOns\\HousingMusic\\Assets\\Textures\\Stop.png"

local function RefreshUILists()
	if SearchBoxLeft then 
		FilterAvailableList(SearchBoxLeft) 
	end

	if SearchBoxRight then
		UpdateSavedMusicList(SearchBoxRight)
	end
end

local function UpdateSelectionHighlights()
	if ScrollBoxLeft then
		ScrollBoxLeft:ForEachFrame(function(frame)
			local d = frame:GetElementData()
			if d and frame.selectedTex then
				frame.selectedTex:SetShown(selectedFileID == d.file)
			end
		end)
	end
	
	if ScrollBoxRight then
		ScrollBoxRight:ForEachFrame(function(frame)
			local d = frame:GetElementData()
			if d and frame.selectedTex then
				frame.selectedTex:SetShown(selectedFileID == d.file)
			end
		end)
	end
	
	if B_ScrollBoxRight then
		B_ScrollBoxRight:ForEachFrame(function(frame)
			local d = frame:GetElementData()
			if d and frame.selectedTex then
				frame.selectedTex:SetShown(selectedFileID == d.file)
			end
		end)
	end
	
	if B_ScrollBoxLeft then
		B_ScrollBoxLeft:ForEachFrame(function(frame)
			local d = frame:GetElementData()
			if d then
				local key = d.locationKey .. "_" .. d.sender
				if frame.selectedTex then
					frame.selectedTex:SetShown(selectedBrowserKey == key)
				end
			end
		end)
	end
end

local function FormatDuration(seconds)
	if not seconds or seconds <= 0 then
		return "0:00"
	end
	seconds = math.floor(seconds)
	local minutes = math.floor(seconds / 60)
	local remainingSeconds = math.fmod(seconds, 60)
	return string.format("%d:%02d", minutes, remainingSeconds)
end

local function CleanString(str)
	if not str then return "" end
	str = str:lower()
	str = str:gsub("[_%s]+", " ")
	str = str:match("^%s*(.-)%s*$")
	return str
end

local function CheckMatch(musicInfo, query)
	if tostring(musicInfo.file):find(query, 1, true) then
		return musicInfo.names and musicInfo.names[1] or tostring(musicInfo.file)
	end

	if musicInfo.name and CleanString(musicInfo.name):find(query, 1, true) then
		return musicInfo.name
	end

	if musicInfo.names then
		for _, altName in ipairs(musicInfo.names) do
			if CleanString(altName):find(query, 1, true) then
				return altName
			end
		end
	end

	return nil
end

local function GetCurrentHouseKey()
	if not C_Housing or not C_Housing.GetCurrentHouseInfo then return nil end
	local info = C_Housing.GetCurrentHouseInfo()
	if not info or not info.ownerName or info.ownerName == "" then return nil end
	-- format: Owner_NeighborhoodGUID_PlotID
	return string.format("%s_%s_%d", info.ownerName, info.neighborhoodGUID, info.plotID)
end

local function IsEditingAllowed()
	if C_Housing and C_Housing.IsInsideOwnHouse then
		return C_Housing.IsInsideOwnHouse()
	end
	return false
end

local function NormalizeName(name) -- it's a bit wonky, so just don't use for now
	if not HousingMusic_DB or not HousingMusic_DB.normalizeNames or not name then 
		return name 
	end

	local newName = name

	newName = newName:gsub("^mus_%d+_", "")
	newName = newName:gsub("^mus_", "")
	newName = newName:gsub("[_%-]", " ")
	newName = newName:match("^%s*(.-)%s*$")
	newName = newName:gsub("(%w)(%w*)", function(first, rest)
		return first:upper() .. rest:lower()
	end)
	newName = newName:gsub("%s0+(%d+)", " %1")

	return newName
end

local function SearchBox_OnUpdate(self, elapsed)
	self.t = self.t + elapsed;
	if self.t >= 0.2 then
		self.t = 0;
		self:SetScript("OnUpdate", nil);
		RefreshUILists();
	end
end

local function SearchBox_OnTextChanged(self)
	self.t = 0;
	self:SetScript("OnUpdate", SearchBox_OnUpdate);
end

local function GetCurrentLocationKey()
	if not C_Housing or not C_Housing.GetCurrentHouseInfo then return nil end
	local info = C_Housing.GetCurrentHouseInfo()
	if not info or not info.neighborhoodGUID or not info.plotID then return nil end
	return string.format("%s_%d", info.neighborhoodGUID, info.plotID)
end

local function OpenSongContextMenu(owner, musicInfo)
	MenuUtil.CreateContextMenu(owner, function(owner, rootDescription)
		rootDescription:CreateTitle(musicInfo.name or L["UnknownSong"])
		
		local fileID = musicInfo.file
		if not fileID then return end

		local isIgnored = HM.IsSongIgnored(fileID)
		local ignoreText = isIgnored and L["UnmuteSong"] or L["MuteSong"]

		rootDescription:CreateButton(ignoreText, function()
			HM.SetSongIgnored(fileID, not isIgnored)
			if HM.UpdateCachedMusicUI then HM.UpdateCachedMusicUI() end
			HM.RefreshButtonForMusic(musicInfo)
		end)
	end)
end

local function GenerateExportString()
	local list = HM.GetActivePlaylistTable()
	if not list then return "" end
	
	local ids = {}
	for k, v in pairs(list) do
		if v then table.insert(ids, k) end
	end
	return table.concat(ids, ",")
end

local function ParseImportString(str)
	local ids = {}
	if not str then return ids end
	
	for id in str:gmatch("%d+") do
		local num = tonumber(id)
		if num then
			table.insert(ids, num)
		end
	end
	return ids
end

StaticPopupDialogs["HOUSINGMUSIC_RENAME_PLAYLIST"] = {
	text = L["RenamePlaylistTo"],
	button1 = L["Rename"],
	button2 = L["Cancel"],
	hasEditBox = true,
	OnShow = function(self, data)
		self.EditBox:SetText(data)
	end,
	OnAccept = function(self, oldName)
		local newName = self.EditBox:GetText()
		if HM.RenamePlaylist(oldName, newName) then
			UpdateSavedMusicList()
		else
			Print(L["PlaylistInvalidOrExists"])
		end
	end,
	timeout = 0,
	whileDead = true,
	hideOnEscape = true,
	preferredIndex = 3,
};

StaticPopupDialogs["HOUSINGMUSIC_NEW_PLAYLIST"] = {
	text = L["NewPlaylistName"],
	button1 = L["Create"],
	button2 = L["Cancel"],
	hasEditBox = true,
	OnAccept = function(self)
		local text = self.EditBox:GetText()
		if HM.CreatePlaylist(text) then
			HM.SetActivePlaylist(text) 
			UpdateSavedMusicList()
			RefreshUILists()
		else
			Print(L["PlaylistInvalidOrExists"])
		end
	end,
	timeout = 0,
	whileDead = true,
	hideOnEscape = true,
	preferredIndex = 3, 
};

StaticPopupDialogs["HOUSINGMUSIC_DELETE_PLAYLIST"] = {
	text = L["DeletePlaylist"],
	button1 = L["Yes"],
	button2 = L["No"],
	OnAccept = function()
		local data = HM.GetActivePlaylistName()
		if not data then return end
		HM.DeletePlaylist(data)
		UpdateSavedMusicList()
	end,
	timeout = 0,
	whileDead = true,
	hideOnEscape = true,
	preferredIndex = 3,
};

StaticPopupDialogs["HOUSINGMUSIC_IMPORT_DATA"] = {
	text = L["ImportPlaylistString"],
	button1 = L["Next"],
	button2 = L["Cancel"],
	hasEditBox = true,
	OnAccept = function(self)
		local text = self.EditBox:GetText()
		local ids = ParseImportString(text)
		
		if #ids > 0 then
			StaticPopup_Show("HOUSINGMUSIC_IMPORT_NAME", nil, nil, ids)
		else
			Print(L["InvalidImportString"])
		end
	end,
	timeout = 0,
	whileDead = true,
	hideOnEscape = true,
	preferredIndex = 3,
};

StaticPopupDialogs["HOUSINGMUSIC_IMPORT_NAME"] = {
	text = L["NewPlaylistName"],
	button1 = L["Import"],
	button2 = L["Cancel"],
	hasEditBox = true,
	OnAccept = function(self, songIDs)
		local name = self.EditBox:GetText()
		
		if HM.CreatePlaylist(name) then
			HM.SetActivePlaylist(name)
			
			local activeList = HM.GetActivePlaylistTable()
			local count = 0
			for _, fileID in ipairs(songIDs) do
				if count >= (HM.MAX_PLAYLIST_SIZE or 50) then break end
				
				if LRPM:GetMusicInfoByID(fileID) then
					activeList[fileID] = true
					count = count + 1
				end
			end
			
			UpdateSavedMusicList()
			RefreshUILists()
			Print(string.format(L["AddedSongsToPlaylist"], count, name))
		else
			Print(L["PlaylistInvalidOrExists"])
		end
	end,
	timeout = 0,
	whileDead = true,
	hideOnEscape = true,
	preferredIndex = 3,
};


local HM_CopyBoxMixin = {}

function HM_CopyBoxMixin:OnLoad()
	self:SetAutoFocus(false)
	self:SetFontObject("ChatFontNormal")
	self:SetTextInsets(5, 5, 0, 0)

	self.Label = self:CreateFontString(nil, "ARTWORK", "GameFontWhiteSmall")
	self.Label:SetJustifyH("LEFT")
	self.Label:SetText("")
	self.Label:SetWordWrap(false)
	self.Label:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 0, 2)
	self.Label:SetPoint("BOTTOMRIGHT", self, "TOPRIGHT", 0, 2)

	self:SetScript("OnEnterPressed", self.OnEnterPressed)
	self:SetScript("OnKeyDown", self.OnKeyDown)
	self:SetScript("OnTextChanged", self.OnTextChanged)
	self:SetScript("OnEscapePressed", self.ClearFocus)
end

function HM_CopyBoxMixin:SetLabel(text)
	self.Label:SetText(text)
	self.Label:Show()
end

function HM_CopyBoxMixin:OnEnterPressed()
	self:ClearFocus()
end

function HM_CopyBoxMixin:OnKeyDown(key)
	if IsControlKeyDown() and (key == "C" or key == "X") then
		PlaySound(SOUNDKIT.TUTORIAL_POPUP)
		
		C_Timer.After(0.1, function() 
			self:ClearFocus() 
		end)
	end
end

function HM_CopyBoxMixin:OnTextChanged(userInput)
	if userInput then
		self:SetText(self.contentString or "")
		self:HighlightText()
	else
		self.contentString = self:GetText()
	end
end

function HM.CreateCopyBox(parent, width)
	local copyBox = CreateFrame("EditBox", nil, parent, "InputBoxTemplate")
	copyBox:SetSize(width or 200, 20)
	
	Mixin(copyBox, HM_CopyBoxMixin)
	copyBox:OnLoad()
	
	return copyBox
end



-------------------------------------------------------------------------------
-- MAIN FRAME
-------------------------------------------------------------------------------

local MainFrame = CreateFrame("Frame", "HousingMusic_MainFrame", UIParent)
MainFrame:SetSize(620, 470)
MainFrame:SetPoint("CENTER")
MainFrame:EnableMouse(true)
HM.MainFrame = MainFrame;
tinsert(UISpecialFrames, MainFrame:GetName())
local Border = MainFrame:CreateTexture(nil, "BORDER", nil, 1);
Border:SetPoint("TOPLEFT", -6, 6);
Border:SetPoint("BOTTOMRIGHT", 6, -6);
Border:SetAtlas("housing-basic-container");
Border:SetTextureSliceMargins(20, 20, 20, 20);
Border:SetTextureSliceMode(Enum.UITextureSliceMode.Stretched);
MainFrame.Border = Border
local Backframe = CreateFrame("Frame", nil, MainFrame)
Backframe:SetPoint("TOPLEFT", MainFrame, "TOPLEFT", 0, -36)
Backframe:SetPoint("BOTTOMRIGHT", MainFrame, "BOTTOMRIGHT", 0, 0)
MainFrame.Backframe = Backframe
local SectionLeft = CreateFrame("Frame", nil, Backframe)
SectionLeft:SetPoint("TOPLEFT", Backframe, "TOPLEFT", 0, 0)
SectionLeft:SetPoint("BOTTOMRIGHT", Backframe, "BOTTOM", 0, 50)
SectionLeft.tex = SectionLeft:CreateTexture(nil, "BACKGROUND", nil, 0);
SectionLeft.tex:SetAtlas("catalog-list-preview-bg")
SectionLeft.tex:SetVertexColor(1,1,1,1)
SectionLeft.tex:SetAllPoints(SectionLeft)
MainFrame.SectionLeft = SectionLeft
local SectionRight = CreateFrame("Frame", nil, Backframe)
SectionRight:SetPoint("TOPLEFT", Backframe, "TOP", 0, 0)
SectionRight:SetPoint("BOTTOMRIGHT", Backframe, "BOTTOMRIGHT", 0, 50)
SectionRight.tex = SectionRight:CreateTexture(nil, "BACKGROUND", nil, 0);
SectionRight.tex:SetAtlas("catalog-list-preview-bg")
SectionRight.tex:SetAllPoints(SectionRight)
SectionRight.tex:SetVertexColor(1,1,1,1)
MainFrame.SectionRight = SectionRight
local DividerSections = CreateFrame("Frame", nil, Backframe)
DividerSections:SetPoint("TOPLEFT", SectionLeft, "TOPRIGHT", -5, 0);
DividerSections:SetPoint("BOTTOMRIGHT", SectionRight, "BOTTOMLEFT", 5, 0);
DividerSections.tex = DividerSections:CreateTexture(nil, "BACKGROUND", nil, 1);
DividerSections.tex:SetAtlas("CovenantSanctum-Divider-Necrolord");
DividerSections.tex:SetAllPoints(DividerSections)
MainFrame.DividerSections = DividerSections
local DividerFooter = CreateFrame("Frame", nil, Backframe)
DividerFooter:SetPoint("TOPLEFT", SectionLeft, "BOTTOMLEFT", 0, 10);
DividerFooter:SetPoint("BOTTOMRIGHT", SectionRight, "BOTTOMRIGHT", 0, -10);
DividerFooter.tex = DividerFooter:CreateTexture(nil, "BACKGROUND", nil, 1);
DividerFooter.tex:SetAtlas("CovenantSanctum-Renown-Divider-Necrolord");
DividerFooter.tex:SetAllPoints(DividerFooter)
MainFrame.DividerFooter = DividerFooter

local Header = MainFrame:CreateTexture(nil, "BORDER", nil, 2);
Header:SetPoint("TOPLEFT", MainFrame, "TOPLEFT", 0, 0);
Header:SetPoint("BOTTOMRIGHT", Backframe, "TOPRIGHT", 0, 0);
Header:SetAtlas("housing-basic-container-woodheader");
MainFrame.Header = Header

MainFrame.favButton = CreateFrame("Button", nil, MainFrame)
MainFrame.favButton:SetSize(30, 30)
MainFrame.favButton:SetPoint("LEFT", Header, "LEFT", 20, 0)
MainFrame.favButton:SetHighlightTexture(favtex) 
MainFrame.favButton:GetHighlightTexture():SetAlpha(0.5)
MainFrame.favButton:SetNormalTexture(nofavtex)
MainFrame.favButton:Hide()

local HeaderTitle = MainFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
HeaderTitle:SetPoint("CENTER", Header, "CENTER", 0, 0)
--HeaderTitle:SetJustifyH("LEFT")
HeaderTitle:SetText("")
HeaderTitle:SetFont(GameFontNormal:GetFont(), 17, "")
HeaderTitle:SetTextColor(1, 1, 1)
MainFrame.HeaderTitle = HeaderTitle

EventRegistry:RegisterFrameEventAndCallback("CURRENT_HOUSE_INFO_RECIEVED", function(arg1, arg2)
	local bingus = arg2;
	if not bingus or not bingus.ownerName then return end
	HeaderTitle:SetText(string.format(L["OwnerssHouseMusic"], bingus.ownerName))
end)

local Footer = CreateFrame("Frame", nil, MainFrame)
Footer:SetPoint("TOPLEFT", Backframe, "BOTTOMLEFT", 0, 0)
Footer:SetPoint("BOTTOMRIGHT", MainFrame, "BOTTOMRIGHT", 0, 0)
MainFrame.Footer = Footer

-- Because if the setting is turned off, the addon breaks
local BlockerFrame = CreateFrame("Frame", nil, MainFrame)
BlockerFrame:SetAllPoints(MainFrame)
BlockerFrame:SetFrameLevel(500)
BlockerFrame:EnableMouse(true)
BlockerFrame:SetScript("OnMouseWheel", function() end)
BlockerFrame:Hide()

BlockerFrame.bg = BlockerFrame:CreateTexture(nil, "BACKGROUND")
BlockerFrame.bg:SetAllPoints()
BlockerFrame.bg:SetColorTexture(0, 0, 0, 0.85)

BlockerFrame.icon = BlockerFrame:CreateTexture(nil, "ARTWORK")
BlockerFrame.icon:SetSize(40, 40)
BlockerFrame.icon:SetPoint("CENTER", BlockerFrame, "CENTER", 0, 40)
BlockerFrame.icon:SetAtlas("icons_64x64_important")

BlockerFrame.text = BlockerFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
BlockerFrame.text:SetPoint("TOP", BlockerFrame.icon, "BOTTOM", 0, -10)
BlockerFrame.text:SetWidth(450)
BlockerFrame.text:SetText(L["BlockerFrameText"])
BlockerFrame.text:SetTextColor(1, 0.2, 0.2)

BlockerFrame.subtext = BlockerFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
BlockerFrame.subtext:SetPoint("TOP", BlockerFrame.text, "BOTTOM", 0, -10)
BlockerFrame.subtext:SetWidth(300)
BlockerFrame.subtext:SetText(L["BlockerFrameSubtext"])
BlockerFrame.subtext:SetJustifyH("CENTER")

local FixButton = CreateFrame("Button", nil, BlockerFrame, "UIPanelButtonTemplate")
FixButton:SetSize(200, 30)
FixButton:SetPoint("TOP", BlockerFrame.subtext, "BOTTOM", 0, -20)
FixButton:SetText("Enable Sound in Background")
FixButton:SetScript("OnClick", function()
	C_CVar.SetCVar("Sound_EnableSoundWhenGameIsInBG", "1")
end)

--FixButton:SetScript("OnEnter", function(self)
--	GameTooltip:SetOwner(self, "ANCHOR_TOP")
--	GameTooltip:AddLine(ENABLE_BGSOUND, 1, 1, 1)
--	GameTooltip:AddLine(OPTION_TOOLTIP_ENABLE_BGSOUND, 1, 1, 1, true)
--	GameTooltip:Show()
--end)
--FixButton:SetScript("OnLeave", function()
--	GameTooltip:Hide()
--end)

local function UpdateCVarBlocker()
	local reason = nil
	local cvarToFix = nil
	local fixValue = "1"
	local btnText = "Fix Setting"

	if C_CVar.GetCVar("Sound_EnableAllSound") == "0" then
		reason = L["BlockerFrame_AllSound"]
		extraReason = ""
		cvarToFix = "Sound_EnableAllSound"
		btnText = L["BlockerFrame_EnableSound"]
	elseif C_CVar.GetCVar("Sound_MasterVolume") == "0" then
		reason = L["BlockerFrame_MasterVolume"]
		extraReason = ""
		cvarToFix = "Sound_MasterVolume"
		fixValue = "0.2"
		btnText = L["BlockerFrame_EnableMasterVolume"]
	elseif C_CVar.GetCVar("Sound_EnableMusic") == "0" then
		reason = L["BlockerFrame_EnableMusic"]
		extraReason = ""
		cvarToFix = "Sound_EnableMusic"
		btnText = L["BlockerFrame_EnableEnableMusic"]
	elseif C_CVar.GetCVar("Sound_MusicVolume") == "0" then
		reason = L["BlockerFrame_MusicVolume"]
		extraReason = ""
		cvarToFix = "Sound_MusicVolume"
		fixValue = "0.5"
		btnText = L["BlockerFrame_EnableMusicVolume"]
	elseif C_CVar.GetCVar("Sound_EnableSoundWhenGameIsInBG") == "0" then
		reason = L["BlockerFrameText"]
		extraReason = L["BlockerFrameSubtext"]
		cvarToFix = "Sound_EnableSoundWhenGameIsInBG"
		btnText = L["BlockerFrame_EnableSoundInBackground"]
	end

	if reason then
		BlockerFrame:Show()
		BlockerFrame.text:SetText(reason)
		BlockerFrame.subtext:SetText(extraReason)
		FixButton:SetText(btnText)
		FixButton:SetScript("OnClick", function()
			C_CVar.SetCVar(cvarToFix, fixValue)
		end)
	else
		BlockerFrame:Hide()
	end
end

local CVarListener = CreateFrame("Frame")
CVarListener:RegisterEvent("CVAR_UPDATE")
CVarListener:SetScript("OnEvent", function(self, event, arg1)
	if arg1 == "Sound_EnableSoundWhenGameIsInBG" 
	or arg1 == "Sound_EnableAllSound" 
	or arg1 == "Sound_MasterVolume"
	or arg1 == "Sound_EnableMusic"
	or arg1 == "Sound_MusicVolume" then
		UpdateCVarBlocker()
	end
end)

local ProgressBar = CreateFrame("StatusBar", nil, Footer)
ProgressBar:SetPoint("TOPLEFT", Footer, "BOTTOMLEFT", 75, 18)
ProgressBar:SetPoint("BOTTOMRIGHT", Footer, "BOTTOMRIGHT", -20, 15)
ProgressBar:SetHeight(8)
ProgressBar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
ProgressBar:SetStatusBarColor(1, 0.7, 0)
ProgressBar.bg = ProgressBar:CreateTexture(nil, "BACKGROUND")
ProgressBar.bg:SetAllPoints()
ProgressBar.bg:SetColorTexture(0.2, 0.2, 0.2, 0.5)

local PlayerToggleBtn = CreateFrame("Button", nil, Footer)
PlayerToggleBtn:SetSize(25, 25)
PlayerToggleBtn:SetPoint("RIGHT", ProgressBar, "LEFT", -25, 9)
PlayerToggleBtn:SetNormalTexture(PlayTexture)
PlayerToggleBtn:SetHighlightTexture(PlayTexture)
PlayerToggleBtn:GetHighlightTexture():SetAlpha(0.5)

local PlayerNextBtn = CreateFrame("Button", nil, Footer)
PlayerNextBtn:SetSize(20, 20)
PlayerNextBtn:SetPoint("LEFT", PlayerToggleBtn, "RIGHT", 0, 0)
PlayerNextBtn:SetNormalTexture(NextTexture)
PlayerNextBtn:SetHighlightTexture(NextTexture)

local PlayerPrevBtn = CreateFrame("Button", nil, Footer)
PlayerPrevBtn:SetSize(20, 20)
PlayerPrevBtn:SetPoint("RIGHT", PlayerToggleBtn, "LEFT", 0, 0)
PlayerPrevBtn:SetNormalTexture(PreviousTexture)
PlayerPrevBtn:SetHighlightTexture(PreviousTexture)

local PlayerTitle = ProgressBar:CreateFontString(nil, "OVERLAY", "GameFontNormal")
PlayerTitle:SetPoint("BOTTOMLEFT", ProgressBar, "TOPLEFT", 0, 5)
PlayerTitle:SetJustifyH("LEFT")
PlayerTitle:SetText(L["NoMusicPlaying"])
PlayerTitle:SetTextColor(1, 1, 1)

PlayerToggleBtn:SetScript("OnClick", function()
	local state = HM.GetPlaybackState()
	
	if state.isPlaying then
		HM.StopManualMusic()
		PlayerToggleBtn:SetNormalTexture(PlayTexture)
		PlayerToggleBtn:SetHighlightTexture(PlayTexture)
		PlayerTitle:SetText(L["NoMusicPlaying"])
	else
		if selectedFileID then
			HM.PlaySpecificMusic(selectedFileID)
			PlayerToggleBtn:SetNormalTexture(StopTexture)
			PlayerToggleBtn:SetHighlightTexture(StopTexture)
			
			local info = LRPM:GetMusicInfoByID(selectedFileID)
			if info then PlayerTitle:SetText(info.names[1] or L["UnknownSong"]) end
		end
	end
end)

function PlayerPrevBtn.PreviousSongTT(self)
	GameTooltip:SetOwner(self, "ANCHOR_TOP")
	GameTooltip:AddLine(L["PreviousSong"], 1, 1, 1)
	
	local prevName = HM.GetPreviousSongName()
	if prevName then
		GameTooltip:AddLine(prevName, 0.8, 0.8, 0.8)
	end
	GameTooltip:Show()
end

PlayerPrevBtn:SetScript("OnClick", function(self)
	if HM.PlayPreviousTrack then
		HM.PlayPreviousTrack()
		PlayerPrevBtn.PreviousSongTT(self)
	end
end)

PlayerPrevBtn:SetScript("OnEnter", function(self)
	PlayerPrevBtn.PreviousSongTT(self)
end)

PlayerPrevBtn:SetScript("OnLeave", function()
	GameTooltip:Hide()
end)

PlayerNextBtn:SetScript("OnClick", function()
	if HM.SkipTrack then
		HM.SkipTrack()
	end
end)

PlayerNextBtn:SetScript("OnEnter", function(self)
	GameTooltip:SetOwner(self, "ANCHOR_TOP")
	GameTooltip:AddLine(L["NextSong"], 1, 1, 1)
	GameTooltip:Show()
end)
PlayerNextBtn:SetScript("OnLeave", function()
	GameTooltip:Hide()
end)

local TimerText = ProgressBar:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
TimerText:SetPoint("BOTTOMRIGHT", ProgressBar, "TOPRIGHT", 0, 5)
TimerText:SetJustifyH("RIGHT")
TimerText:SetText("0:00 / 0:00")
TimerText:SetTextColor(1, 1, 1)

ProgressBar:SetScript("OnUpdate", function(self, elapsed)
	if not MainFrame:IsVisible() then return end

	local state = HM.GetPlaybackState()

	if state.isPlaying and state.duration > 0 then
		self:SetMinMaxValues(0, state.duration)
		self:SetValue(state.elapsed)
		
		TimerText:SetText(FormatDuration(state.elapsed) .. " / " .. FormatDuration(state.duration))
		
		PlayerTitle:SetText(state.name or L["Unknown"])
		
		PlayerToggleBtn:SetNormalTexture(StopTexture)
		PlayerToggleBtn:SetHighlightTexture(StopTexture)
	else
		self:SetValue(0)
		TimerText:SetText("0:00 / 0:00")
		PlayerTitle:SetText(L["NoMusicPlaying"])
		
		PlayerToggleBtn:SetNormalTexture(PlayTexture)
		PlayerToggleBtn:SetHighlightTexture(PlayTexture)
	end
end)

-------------------------------------------------------------------------------
-- PLAYLIST BROWSER FRAME (Cached Music)
-------------------------------------------------------------------------------

local BrowserFrame = CreateFrame("Frame", "HousingMusic_BrowserFrame", UIParent)
BrowserFrame:SetSize(620, 470)
BrowserFrame:SetPoint("CENTER")
BrowserFrame:EnableMouse(true)
BrowserFrame:Hide()
HM.BrowserFrame = BrowserFrame;
tinsert(UISpecialFrames, BrowserFrame:GetName())

local B_Border = BrowserFrame:CreateTexture(nil, "BORDER", nil, 1);
B_Border:SetPoint("TOPLEFT", -6, 6);
B_Border:SetPoint("BOTTOMRIGHT", 6, -6);
B_Border:SetAtlas("housing-basic-container");
B_Border:SetTextureSliceMargins(20, 20, 20, 20);
B_Border:SetTextureSliceMode(Enum.UITextureSliceMode.Stretched);

local B_Header = BrowserFrame:CreateTexture(nil, "BORDER", nil, 2);
B_Header:SetPoint("TOPLEFT", BrowserFrame, "TOPLEFT", 0, 0);
B_Header:SetPoint("BOTTOMRIGHT", BrowserFrame, "TOPRIGHT", 0, -36);
B_Header:SetAtlas("housing-basic-container-woodheader");

local B_HeaderTitle = BrowserFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
B_HeaderTitle:SetPoint("CENTER", B_Header, "CENTER", 0, 0)
B_HeaderTitle:SetFont(GameFontNormal:GetFont(), 17, "")
B_HeaderTitle:SetTextColor(1, 1, 1)
B_HeaderTitle:SetText(L["CachedPlaylists"])

local B_CloseButton = CreateFrame("Button", nil, BrowserFrame, "UIPanelCloseButtonNoScripts");
B_CloseButton:SetPoint("TOPRIGHT", 0, 0);
B_CloseButton:SetScript("OnClick", function() BrowserFrame:Hide() end);

local B_Backframe = CreateFrame("Frame", nil, BrowserFrame)
B_Backframe:SetPoint("TOPLEFT", BrowserFrame, "TOPLEFT", 0, -36)
B_Backframe:SetPoint("BOTTOMRIGHT", BrowserFrame, "BOTTOMRIGHT", 0, 0)

local B_SectionLeft = CreateFrame("Frame", nil, B_Backframe)
B_SectionLeft:SetPoint("TOPLEFT", B_Backframe, "TOPLEFT", 0, 0)
B_SectionLeft:SetPoint("BOTTOMRIGHT", B_Backframe, "BOTTOM", 0, 50)
B_SectionLeft.tex = B_SectionLeft:CreateTexture(nil, "BACKGROUND", nil, 0);
B_SectionLeft.tex:SetAtlas("catalog-list-preview-bg") 
B_SectionLeft.tex:SetVertexColor(1,1,1,1)
B_SectionLeft.tex:SetAllPoints(B_SectionLeft)

local B_SectionRight = CreateFrame("Frame", nil, B_Backframe)
B_SectionRight:SetPoint("TOPLEFT", B_Backframe, "TOP", 0, 0)
B_SectionRight:SetPoint("BOTTOMRIGHT", B_Backframe, "BOTTOMRIGHT", 0, 50)
B_SectionRight.tex = B_SectionRight:CreateTexture(nil, "BACKGROUND", nil, 0);
B_SectionRight.tex:SetAtlas("catalog-list-preview-bg")
B_SectionRight.tex:SetAllPoints(B_SectionRight)
B_SectionRight.tex:SetVertexColor(1,1,1,1)

local B_Divider = CreateFrame("Frame", nil, B_Backframe)
B_Divider:SetPoint("TOPLEFT", B_SectionLeft, "TOPRIGHT", -5, 0);
B_Divider:SetPoint("BOTTOMRIGHT", B_SectionRight, "BOTTOMLEFT", 5, 0);
B_Divider.tex = B_Divider:CreateTexture(nil, "BACKGROUND", nil, 1);
B_Divider.tex:SetAtlas("CovenantSanctum-Divider-Necrolord");
B_Divider.tex:SetAllPoints(B_Divider)

local B_DividerFooter = CreateFrame("Frame", nil, B_Backframe)
B_DividerFooter:SetPoint("TOPLEFT", B_SectionLeft, "BOTTOMLEFT", 0, 10);
B_DividerFooter:SetPoint("BOTTOMRIGHT", B_SectionRight, "BOTTOMRIGHT", 0, -10);
B_DividerFooter.tex = B_DividerFooter:CreateTexture(nil, "BACKGROUND", nil, 1);
B_DividerFooter.tex:SetAtlas("CovenantSanctum-Renown-Divider-Necrolord");
B_DividerFooter.tex:SetAllPoints(B_DividerFooter)

local B_Footer = CreateFrame("Frame", nil, BrowserFrame)
B_Footer:SetPoint("TOPLEFT", B_Backframe, "BOTTOMLEFT", 0, 0)
B_Footer:SetPoint("BOTTOMRIGHT", BrowserFrame, "BOTTOMRIGHT", 0, 0)

local B_ProgressBar = CreateFrame("StatusBar", nil, B_Footer)
B_ProgressBar:SetPoint("TOPLEFT", B_Footer, "BOTTOMLEFT", 75, 18)
B_ProgressBar:SetPoint("BOTTOMRIGHT", B_Footer, "BOTTOMRIGHT", -20, 15)
B_ProgressBar:SetHeight(8)
B_ProgressBar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
B_ProgressBar:SetStatusBarColor(1, 0.7, 0)
B_ProgressBar.bg = B_ProgressBar:CreateTexture(nil, "BACKGROUND")
B_ProgressBar.bg:SetAllPoints()
B_ProgressBar.bg:SetColorTexture(0.2, 0.2, 0.2, 0.5)

local B_PlayerToggleBtn = CreateFrame("Button", nil, B_ProgressBar)
B_PlayerToggleBtn:SetSize(25, 25)
B_PlayerToggleBtn:SetPoint("RIGHT", B_ProgressBar, "LEFT", -25, 9)
B_PlayerToggleBtn:SetNormalTexture(PlayTexture)
B_PlayerToggleBtn:SetHighlightTexture(PlayTexture)
B_PlayerToggleBtn:GetHighlightTexture():SetAlpha(0.5)

local B_PlayerNextBtn = CreateFrame("Button", nil, B_ProgressBar)
B_PlayerNextBtn:SetSize(20, 20)
B_PlayerNextBtn:SetPoint("LEFT", B_PlayerToggleBtn, "RIGHT", 0, 0)
B_PlayerNextBtn:SetNormalTexture(NextTexture)
B_PlayerNextBtn:SetHighlightTexture(NextTexture)

local B_PlayerPrevBtn = CreateFrame("Button", nil, B_ProgressBar)
B_PlayerPrevBtn:SetSize(20, 20)
B_PlayerPrevBtn:SetPoint("RIGHT", B_PlayerToggleBtn, "LEFT", 0, 0)
B_PlayerPrevBtn:SetNormalTexture(PreviousTexture)
B_PlayerPrevBtn:SetHighlightTexture(PreviousTexture)

local B_PlayerTitle = B_ProgressBar:CreateFontString(nil, "OVERLAY", "GameFontNormal")
B_PlayerTitle:SetPoint("BOTTOMLEFT", B_ProgressBar, "TOPLEFT", 0, 5)
B_PlayerTitle:SetJustifyH("LEFT")
B_PlayerTitle:SetText(L["NoMusicPlaying"])
B_PlayerTitle:SetTextColor(1, 1, 1)

local B_TimerText = B_ProgressBar:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
B_TimerText:SetPoint("BOTTOMRIGHT", B_ProgressBar, "TOPRIGHT", 0, 5)
B_TimerText:SetJustifyH("RIGHT")
B_TimerText:SetText("0:00 / 0:00")
B_TimerText:SetTextColor(1, 1, 1)

B_PlayerToggleBtn:SetScript("OnClick", function()
	local state = HM.GetPlaybackState()
	if state.isPlaying then
		HM.StopManualMusic()
		B_PlayerToggleBtn:SetNormalTexture(PlayTexture)
		B_PlayerToggleBtn:SetHighlightTexture(PlayTexture)
		B_PlayerTitle:SetText(L["NoMusicPlaying"])
	end
end)

B_PlayerPrevBtn:SetScript("OnClick", function(self)
	if HM.PlayPreviousTrack then
		HM.PlayPreviousTrack()
		PlayerPrevBtn.PreviousSongTT(self)
	end
end)

B_PlayerPrevBtn:SetScript("OnEnter", function(self)
	PlayerPrevBtn.PreviousSongTT(self)
end)

B_PlayerPrevBtn:SetScript("OnLeave", function()
	GameTooltip:Hide()
end)

B_PlayerNextBtn:SetScript("OnClick", function()
	if HM.SkipTrack then
		HM.SkipTrack()
	end
end)

B_PlayerNextBtn:SetScript("OnEnter", function(self)
	GameTooltip:SetOwner(self, "ANCHOR_TOP")
	GameTooltip:AddLine(L["NextSong"], 1, 1, 1)
	GameTooltip:Show()
end)
B_PlayerNextBtn:SetScript("OnLeave", function()
	GameTooltip:Hide()
end)

B_ProgressBar:SetScript("OnUpdate", function(self, elapsed)
	if not BrowserFrame:IsVisible() then return end

	local state = HM.GetPlaybackState()

	if state.isPlaying and state.duration > 0 then
		self:SetMinMaxValues(0, state.duration)
		self:SetValue(state.elapsed)
		
		B_TimerText:SetText(FormatDuration(state.elapsed) .. " / " .. FormatDuration(state.duration))
		B_PlayerTitle:SetText(state.name or L["Unknown"])
		
		B_PlayerToggleBtn:SetNormalTexture(StopTexture)
		B_PlayerToggleBtn:SetHighlightTexture(StopTexture)
	else
		self:SetValue(0)
		B_TimerText:SetText("0:00 / 0:00")
		B_PlayerTitle:SetText(L["NoMusicPlaying"])
		
		B_PlayerToggleBtn:SetNormalTexture(PlayTexture)
		B_PlayerToggleBtn:SetHighlightTexture(PlayTexture)
	end
end)

-------------------------------------------------------------------------------
-- BROWSER EVENTS
-------------------------------------------------------------------------------
BrowserFrame:SetScript("OnShow", function()
	RefreshBrowserPlaylists()
	PlaySound(305110)
end)

BrowserFrame:SetScript("OnHide", function()
	PlaySound(305110)
end)


-------------------------------------------------------------------------------
-- Toggle Button
-------------------------------------------------------------------------------

local MainframeToggleButton = CreateFrame("Button", "HousingMusic_MusicControlFrame", UIParent)
MainframeToggleButton:SetPoint("CENTER")
MainframeToggleButton:SetSize(36, 36)
MainframeToggleButton:SetScript("OnClick", function(self, button, down)
	if down then return end

	if MainFrame:IsShown() then
		MainFrame:Hide()
	else
		MainFrame:Show()
		if BrowserFrame and BrowserFrame:IsShown() then BrowserFrame:Hide() end
	end
end)
MainframeToggleButton:RegisterForClicks("AnyDown", "AnyUp")
MainframeToggleButton:SetNormalTexture(Decor_Controls_Music_Default)
MainframeToggleButton:SetPushedTexture(Decor_Controls_Music_Pressed)
MainframeToggleButton:SetHighlightTexture(Decor_Controls_Music_Default)
local MTB_zoomValue = .23
MainframeToggleButton:GetNormalTexture():SetTexCoord(0+MTB_zoomValue,1-MTB_zoomValue,0+MTB_zoomValue,1-MTB_zoomValue)
MainframeToggleButton:GetPushedTexture():SetTexCoord(0+MTB_zoomValue,1-MTB_zoomValue,0+MTB_zoomValue,1-MTB_zoomValue)
MainframeToggleButton:GetHighlightTexture():SetTexCoord(0+MTB_zoomValue,1-MTB_zoomValue,0+MTB_zoomValue,1-MTB_zoomValue)
--MainframeToggleButton:SetVertexColor(.81, .76, .66)
MainframeToggleButton:RegisterEvent("HOUSE_EDITOR_AVAILABILITY_CHANGED")
MainframeToggleButton:RegisterEvent("CURRENT_HOUSE_INFO_RECIEVED")
MainframeToggleButton:RegisterEvent("ZONE_CHANGED_NEW_AREA")
MainframeToggleButton:SetScript("OnEvent", function()
	if not HM.IsControlIconEnabled() then
		MainframeToggleButton:Hide()
		return
	end

	local HousingFrame
	local isVisitor = false
	if C_Housing.IsInsideOwnHouse() then
		HousingFrame = HousingControlsFrame and HousingControlsFrame.OwnerControlFrame and HousingControlsFrame.OwnerControlFrame.InspectorButton
		isVisitor = false
	elseif C_Housing.IsInsideHouse() then
		HousingFrame = HousingControlsFrame and HousingControlsFrame.VisitorControlFrame and HousingControlsFrame.VisitorControlFrame.VisitorInspectorButton
		isVisitor = true
	end
	local isInHouse = C_Housing.IsInsideHouse()
	if HousingFrame and isInHouse then
		MainframeToggleButton:ClearAllPoints()
		MainframeToggleButton:SetPoint("RIGHT", HousingFrame, "LEFT", 0, 0)
		MainframeToggleButton:SetFrameLevel(HousingFrame:GetFrameLevel())
		MainframeToggleButton:Show()
		MainFrame:ClearAllPoints()
		MainFrame:SetPoint("TOP", HousingControlsFrame, "BOTTOM", 0, -40)
		MainFrame.favButton:Show()
		BrowserFrame:ClearAllPoints()
		BrowserFrame:SetPoint("TOP", HousingControlsFrame, "BOTTOM", 0, -40)
	else
		MainframeToggleButton:Hide()
		MainFrame:Hide()
		MainFrame.favButton:Hide()
		BrowserFrame:Hide()
	end
end)

function MainframeToggleButton.Tooltip(self)
	GameTooltip:SetOwner(self, "ANCHOR_BOTTOM")
	GameTooltip:AddLine(L["TOC_Title"], 1, 1, 1)

	local state = HM.GetPlaybackState()
	if state.isPlaying and state.duration > 0 then
		GameTooltip:AddLine(" ", 1, 1, 1)
		GameTooltip:AddLine(state.name or L["Unknown"], 1, 1, 1)
	end

	GameTooltip:Show()
end

MainframeToggleButton:SetScript("OnEnter", function(self)
	MainframeToggleButton.Tooltip(self)
end)
MainframeToggleButton:SetScript("OnLeave", function()
	GameTooltip:Hide()
end)

MainframeToggleButton:Hide()

local PulseAnims = {}
PulseAnims.PulseTexture = MainframeToggleButton:CreateTexture(nil, "OVERLAY")
PulseAnims.PulseTexture:SetAllPoints()
PulseAnims.PulseTexture:SetTexture(Decor_Controls_Music_Active)
PulseAnims.PulseTexture:SetBlendMode("ADD")
PulseAnims.PulseTexture:SetAlpha(0)
MainframeToggleButton.PulseTexture = PulseAnims.PulseTexture

PulseAnims.PulseAnimGroup = PulseAnims.PulseTexture:CreateAnimationGroup()
MainframeToggleButton.PulseAnimGroup = PulseAnims.PulseAnimGroup

PulseAnims.s1 = PulseAnims.PulseAnimGroup:CreateAnimation("Scale")
PulseAnims.s1:SetOrder(1)
PulseAnims.s1:SetDuration(0.6)
PulseAnims.s1:SetScale(1.5, 1.5)
PulseAnims.s1:SetOrigin("CENTER", 0, 0)
PulseAnims.a1 = PulseAnims.PulseAnimGroup:CreateAnimation("Alpha")
PulseAnims.a1:SetOrder(1)
PulseAnims.a1:SetDuration(0.6)
PulseAnims.a1:SetFromAlpha(1)
PulseAnims.a1:SetToAlpha(0)

PulseAnims.s2 = PulseAnims.PulseAnimGroup:CreateAnimation("Scale")
PulseAnims.s2:SetOrder(2)
PulseAnims.s2:SetDuration(0.6)
PulseAnims.s2:SetScale(1.5, 1.5)
PulseAnims.s2:SetOrigin("CENTER", 0, 0)
PulseAnims.a2 = PulseAnims.PulseAnimGroup:CreateAnimation("Alpha")
PulseAnims.a2:SetOrder(2)
PulseAnims.a2:SetDuration(0.6)
PulseAnims.a2:SetFromAlpha(1)
PulseAnims.a2:SetToAlpha(0)

PulseAnims.s3 = PulseAnims.PulseAnimGroup:CreateAnimation("Scale")
PulseAnims.s3:SetOrder(3)
PulseAnims.s3:SetDuration(0.6)
PulseAnims.s3:SetScale(1.5, 1.5)
PulseAnims.s3:SetOrigin("CENTER", 0, 0)
PulseAnims.a3 = PulseAnims.PulseAnimGroup:CreateAnimation("Alpha")
PulseAnims.a3:SetOrder(3)
PulseAnims.a3:SetDuration(0.6)
PulseAnims.a3:SetFromAlpha(1)
PulseAnims.a3:SetToAlpha(0)

PulseAnims.PulseAnimGroup:SetScript("OnFinished", function(self)
	self:GetParent():Hide()
end)

function HM.TriggerPulseAnimation()
	local enabled = true
	if HousingMusic_DB and HousingMusic_DB.showMusicOnIcon ~= nil then
		enabled = HousingMusic_DB.showMusicOnIcon
	elseif HM.DefaultsTable and HM.DefaultsTable.showMusicOnIcon ~= nil then
		enabled = HM.DefaultsTable.showMusicOnIcon
	end
	
	if not enabled then return end
	
	if not MainframeToggleButton:IsVisible() then return end
	
	PulseAnims.PulseTexture:Show()
	PulseAnims.PulseAnimGroup:Stop()
	PulseAnims.PulseAnimGroup:Play()
end

local closeButton = CreateFrame("Button", nil, MainFrame, "UIPanelCloseButtonNoScripts");
closeButton:SetPoint("TOPRIGHT", 0, 0);
closeButton:SetScript("OnClick", function()
	if MainFrame then
		MainFrame:Hide();
	end
end);
MainFrame.closeButton = closeButton

function HM.IsPlayerIgnored(name)
	if not name or not HousingMusic_DB or not HousingMusic_DB.IgnoredPlayers then return false end
	return HousingMusic_DB.IgnoredPlayers[name]
end

function HM.IgnorePlayer(name)
	if not name then return end
	HousingMusic_DB.IgnoredPlayers[name] = true
	Print(string.format(L["PlayerAddedToMute"], name))
end

function HM.UnignorePlayer(name)
	if not name then return end
	HousingMusic_DB.IgnoredPlayers[name] = nil
	Print(string.format(L["PlayerRemovedFromMute"], name))
end

function HM.GetIgnoreList()
	local list = {}
	if HousingMusic_DB and HousingMusic_DB.IgnoredPlayers then
		for name, _ in pairs(HousingMusic_DB.IgnoredPlayers) do
			table.insert(list, name)
		end
	end
	table.sort(list)
	return list
end

local SettingsButton = CreateFrame("Button", nil, MainFrame);
SettingsButton:SetPoint("RIGHT", closeButton, "LEFT", -5, 0);
SettingsButton:SetSize(15,16)
SettingsButton:SetNormalAtlas("QuestLog-icon-setting")
SettingsButton:SetHighlightAtlas("QuestLog-icon-setting")

local SettingsFrame = CreateFrame("Frame", "HousingMusic_SettingsFrame", MainFrame)
SettingsFrame:SetSize(500, 420)
SettingsFrame:SetPoint("TOP", MainFrame, "TOP", 0, -15)
SettingsFrame:SetFrameLevel(600)
SettingsFrame:EnableMouse(true)

local SettingsSearchBox = CreateFrame("EditBox", nil, SettingsFrame, "SearchBoxTemplate")
SettingsSearchBox:SetPoint("TOPLEFT", SettingsFrame, "TOPLEFT", 20, -40)
SettingsSearchBox:SetPoint("BOTTOMRIGHT", SettingsFrame, "TOPRIGHT", -25, -60)
SettingsSearchBox:SetHeight(20)
SettingsSearchBox:SetAutoFocus(false)

local SettingsScrollBox = CreateFrame("Frame", nil, SettingsFrame, "WowScrollBoxList")
SettingsScrollBox:SetPoint("TOPLEFT", SettingsFrame, "TOPLEFT", 0, -60)
SettingsScrollBox:SetPoint("BOTTOMRIGHT", SettingsFrame, "BOTTOMRIGHT", -25, 30)

local SettingsScrollBar = CreateFrame("EventFrame", nil, SettingsFrame, "MinimalScrollBar")
SettingsScrollBar:SetPoint("TOPLEFT", SettingsScrollBox, "TOPRIGHT", 5, 0)
SettingsScrollBar:SetPoint("BOTTOMLEFT", SettingsScrollBox, "BOTTOMRIGHT", 5, 0)

local SettingsScrollView = CreateScrollBoxListLinearView()
ScrollUtil.InitScrollBoxListWithScrollBar(SettingsScrollBox, SettingsScrollBar, SettingsScrollView)

local allSettingsData = {}

local function CreateSettingData_CheckButton(settingKey, label, tooltip)
	return {
		type = "checkbox",
		key = settingKey,
		label = label,
		tooltip = tooltip,
		searchText = (label .. " " .. tooltip):lower()
	}
end

local function CreateSettingData_Dropdown(settingKey, label, options, tooltip)
	local searchText = (label .. " " .. tooltip):lower()
	for _, opt in ipairs(options) do
		if opt.text and opt.tooltip then
			searchText = searchText .. " " .. opt.text:lower() .. " " .. opt.tooltip:lower()
		end
	end
	
	return {
		type = "dropdown",
		key = settingKey,
		label = label,
		tooltip = tooltip,
		options = options,
		searchText = searchText
	}
end

local function CreateSettingData_Slider(settingKey, label, tooltip, cvar)
	return {
		type = "slider",
		key = settingKey,
		label = label,
		tooltip = tooltip,
		cvar = cvar,
		searchText = (label .. " " .. tooltip):lower()
	}
end

local function InitializeCheckboxSetting(button, data)
	button:SetHeight(30)
	
	if not button.checkbox then
		button.checkbox = CreateFrame("CheckButton", nil, button, "ChatConfigCheckButtonTemplate")
		button.checkbox:SetPoint("LEFT", 10, 0)
		button.checkbox:SetSize(24, 24)
		
		button.label = button.checkbox.Text
		button.label:ClearAllPoints()
		button.label:SetPoint("LEFT", button.checkbox, "RIGHT", 5, 0)
		button.label:SetPoint("RIGHT", button, "RIGHT", -5, 0)
		button.label:SetJustifyH("LEFT")
	end
	
	button.checkbox:Show()
	button.label:Show()
	
	button.label:SetText(data.label)
	button.checkbox.tooltip = WrapTextInColorCode(data.label, "ffffffff") .. "\n" .. data.tooltip
	
	local isChecked
	if data.get then
		isChecked = data.get()
	else
		if HousingMusic_DB[data.key] == nil then
			isChecked = DefaultsTable[data.key]
		else
			isChecked = HousingMusic_DB[data.key]
		end
	end
	button.checkbox:SetChecked(isChecked)
	button.checkbox:SetScript("OnClick", function(self)
		local val = self:GetChecked()
		
		if data.set then
			data.set(val)
		else
			HousingMusic_DB[data.key] = val
		end

		if data.key == "showControlFrameIcon" then
			MainframeToggleButton:GetScript("OnEvent")(MainframeToggleButton)
		end
	end)
end

local function InitializeDropdownSetting(button, data)
	button:SetHeight(30)
	
	if not button.dropdown then
		button.dropdown = CreateFrame("DropdownButton", nil, button, "WowStyle1DropdownTemplate")
		button.dropdown:SetPoint("LEFT", 10, 0)
		button.dropdown:SetWidth(170)
		
		button.dropdownLabel = button:CreateFontString(nil, "OVERLAY", "GameTooltipText")
		button.dropdownLabel:SetPoint("LEFT", button.dropdown, "RIGHT", 5, 0)
		button.dropdownLabel:SetPoint("RIGHT", button, "RIGHT", -5, 0)
		button.dropdownLabel:SetJustifyH("LEFT")
	end
	
	button.dropdown:Show()
	button.dropdownLabel:Show()
	
	button.dropdownLabel:SetText(data.label)
	
	button.dropdown:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_TOP")
		GameTooltip:AddLine(data.label, 1, 1, 1, true)
		GameTooltip:AddLine(data.tooltip, goldR, goldG, goldB, goldA, true)
		for _, tt in ipairs(data.options) do
			if tt.text and tt.tooltip then
				GameTooltip:AddLine(" ")
				GameTooltip:AddLine(string.format("%s: %s", tt.text, WrapTextInColorCode(tt.tooltip, NORMAL_FONT_COLOR:GenerateHexColor())), 1, 1, 1, true)
			end
		end
		GameTooltip:Show()
	end)
	button.dropdown:SetScript("OnLeave", function()
		GameTooltip:Hide()
	end)
	
	local function GetCurrentValue()
		if HousingMusic_DB[data.key] == nil then
			return (HM.DefaultsTable and HM.DefaultsTable[data.key]) or 1
		else
			return HousingMusic_DB[data.key]
		end
	end

	local function UpdateDropdownText()
		local currentValue = GetCurrentValue()
		for _, option in ipairs(data.options) do if option.value == currentValue then button.dropdown.Text:SetText(option.text) break end end
	end
	local function GeneratorFunction(dropdown, rootDescription)
		rootDescription:SetScrollMode(300)
		for _, option in ipairs(data.options) do
			rootDescription:CreateRadio(option.text, function() return GetCurrentValue() == option.value end, function() HousingMusic_DB[data.key] = option.value UpdateDropdownText() end, option.value)
		end
	end
	button.dropdown:SetupMenu(GeneratorFunction)
	UpdateDropdownText()
end

local function InitializeSliderSetting(button, data)
	button:SetHeight(30)
	
	if not button.slider then
		local options = Settings.CreateSliderOptions(0, 100, 1)
		options:SetLabelFormatter(MinimalSliderWithSteppersMixin.Label.Right, function(value) return value .. "%" end)
		
		button.slider = CreateFrame("Frame", nil, button, "MinimalSliderWithSteppersTemplate")
		button.slider:SetPoint("LEFT", 10, 0)
		button.slider:SetWidth(250)
		button.slider:Init(50, options.minValue, options.maxValue, options.steps, options.formatters)
		
		button.sliderLabel = button:CreateFontString(nil, "OVERLAY", "GameTooltipText")
		button.sliderLabel:SetPoint("LEFT", button.slider, "RIGHT", 50, 0)
		button.sliderLabel:SetText("Slider Label")
		button.sliderLabel:SetTextColor(1, 1, 1)


		button.slider.tooltip = WrapTextInColorCode(data.label, "ffffffff") .. "\n" .. data.tooltip
		
		button.slider.Slider:HookScript("OnEnter", function(self)
			if button.slider.tooltip then
				GameTooltip:SetOwner(self, "ANCHOR_TOP")
				GameTooltip:SetText(button.slider.tooltip, goldR, goldG, goldB, goldA, true)
				GameTooltip:Show()
			end
		end)
		button.slider.Slider:HookScript("OnLeave", function() GameTooltip:Hide() end)
	end
	
	button.slider:Show()
	button.sliderLabel:Show()
	button.sliderLabel:SetText(data.label)
	button.slider.tooltipText = button.slider.tooltip
	
	local dbValue
	if HousingMusic_DB.volumeControls and HousingMusic_DB.volumeControls[data.cvar] ~= nil then
		dbValue = HousingMusic_DB.volumeControls[data.cvar]
	else
		dbValue = 0.5
	end
	local sliderValue = math.floor(dbValue * 100)
	
	if button.slider.OnValueChangedCallback then
		button.slider:UnregisterCallback("OnValueChanged", button.slider.OnValueChangedCallback)
	end

	local function OnValueChanged(self, value)
		if button.slider.isInitializing then return end

		local normalized = value / 100
		HousingMusic_DB.volumeControls = HousingMusic_DB.volumeControls or {}
		HousingMusic_DB.volumeControls[data.cvar] = normalized
		
		HM.UpdateVolumeCVar(data.cvar, normalized)
	end

	button.slider.OnValueChangedCallback = OnValueChanged
	button.slider:RegisterCallback("OnValueChanged", OnValueChanged, button.slider)

	button.slider.isInitializing = true
	button.slider:SetValue(sliderValue)
	button.slider.isInitializing = false
end

local function SettingsRowInitializer(button, data)
	if button.checkbox then button.checkbox:Hide() end
	if button.checkboxLabel then button.checkboxLabel:Hide() end
	if button.dropdown then button.dropdown:Hide() end
	if button.dropdownLabel then button.dropdownLabel:Hide() end
	if button.slider then button.slider:Hide() end
	if button.sliderLabel then button.sliderLabel:Hide() end

	if data.type == "checkbox" then
		if button.checkbox then 
			button.checkbox:Show()
			if button.checkboxLabel then button.checkboxLabel:Show() end
		end
		if button.dropdown then 
			button.dropdown:Hide()
			if button.dropdownLabel then button.dropdownLabel:Hide() end
		end
		
		InitializeCheckboxSetting(button, data)
	elseif data.type == "dropdown" then
		if button.dropdown then 
			button.dropdown:Show()
			if button.dropdownLabel then button.dropdownLabel:Show() end
		end
		if button.checkbox then 
			button.checkbox:Hide()
			if button.checkboxLabel then button.checkboxLabel:Hide() end
		end
		
		InitializeDropdownSetting(button, data)
	elseif data.type == "slider" then
		InitializeSliderSetting(button, data)
	end
end

SettingsScrollView:SetElementInitializer("Button", SettingsRowInitializer)
SettingsScrollView:SetElementExtent(30)
SettingsScrollView:SetPadding(5, 5, 5, 5, 2)

local function FilterSettings()
	local query = SettingsSearchBox:GetText():lower()
	local filtered = {}
	
	for _, data in ipairs(allSettingsData) do
		if query == "" or data.searchText:find(query, 1, true) then
			table.insert(filtered, data)
		end
	end
	
	local dataProvider = CreateDataProvider(filtered)
	SettingsScrollView:SetDataProvider(dataProvider)
end

SettingsSearchBox:HookScript("OnTextChanged", function(self)
	self.t = 0
	self:SetScript("OnUpdate", function(self, elapsed)
		self.t = self.t + elapsed
		if self.t >= 0.2 then
			self.t = 0
			self:SetScript("OnUpdate", nil)
			FilterSettings()
		end
	end)
end)


local SettingsFrameTitle = SettingsFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
SettingsFrameTitle:SetPoint("TOP", 0, -15)
SettingsFrameTitle:SetFont(GameFontNormal:GetFont(), 17, "")
SettingsFrameTitle:SetTextColor(1, 1, 1)
SettingsFrameTitle:SetText(L["HousingMusicSettings"])


local closeButtonSettings = CreateFrame("Button", nil, SettingsFrame, "UIPanelCloseButtonNoScripts");
closeButtonSettings:SetPoint("TOPRIGHT", -5, -5);
closeButtonSettings:SetFrameLevel(SettingsFrame:GetFrameLevel()+1)
closeButtonSettings:SetScript("OnClick", function()
	if SettingsFrame then
		SettingsFrame:Hide();
	end
end);
SettingsFrame.closeButton = closeButtonSettings

local SettingsFrameBGTex = SettingsFrame:CreateTexture(nil, "BACKGROUND", nil, 0);
SettingsFrameBGTex:SetPoint("TOPLEFT", SettingsFrame, "TOPLEFT", 5, -5)
SettingsFrameBGTex:SetPoint("BOTTOMRIGHT", SettingsFrame, "BOTTOMRIGHT", -5, 5)
SettingsFrameBGTex:SetAtlas("Tooltip-Glues-NineSlice-Center");


local SettingsFrameTexture = SettingsFrame:CreateTexture(nil, "BACKGROUND", nil, 1);
SettingsFrameTexture:SetPoint("TOPLEFT", 0, 0);
SettingsFrameTexture:SetPoint("BOTTOMRIGHT", 0, 0);
SettingsFrameTexture:SetAtlas("housing-basic-container");
SettingsFrameTexture:SetTextureSliceMargins(64, 64, 64, 112);
SettingsFrameTexture:SetTextureSliceMode(Enum.UITextureSliceMode.Stretched);
SettingsFrame:Hide()

local IgnorePanelBtn = CreateFrame("Button", nil, SettingsFrame, "UIPanelButtonTemplate")
IgnorePanelBtn:SetSize(120, 22)
IgnorePanelBtn:SetPoint("BOTTOM", SettingsFrame, "BOTTOM", 0, 15)
IgnorePanelBtn:SetText(L["MuteList"])
IgnorePanelBtn:HookScript("OnEnter", function(self)
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
	GameTooltip:AddLine(L["MuteList"], 1, 1, 1, 1, true)
	GameTooltip:AddLine(L["MutePlayerExplanation"], goldR, goldG, goldB, goldA, true)
	GameTooltip:Show()

end)
IgnorePanelBtn:SetScript("OnLeave", function()
	GameTooltip:Hide()
end)

SettingsButton:RegisterEvent("ADDON_LOADED")
function SettingsButton.LoadSettings(self, event, addOnName, containsBindings)
	if addOnName == "HousingMusic" then
		allSettingsData = {}
		
		
		table.insert(allSettingsData, CreateSettingData_CheckButton("autoplayMusic", L["Setting_AutoplayMusic"], L["Setting_AutoplayMusicTT"]))
		table.insert(allSettingsData, CreateSettingData_CheckButton("showMusicOnIcon", L["Setting_ShowMusicOnIcon"], L["Setting_ShowMusicOnIconTT"]))
		table.insert(allSettingsData, CreateSettingData_CheckButton("showControlFrameIcon", L["Setting_ShowControlFrameIcon"], L["Setting_ShowControlFrameIconTT"]))
		--table.insert(allSettingsData, CreateSettingData_CheckButton("showMinimapIcon", L["Setting_ShowMinimapIcon"], L["Setting_ShowMinimapIconTT"])) -- NYI
		--table.insert(allSettingsData, CreateSettingData_CheckButton("toastPopup", L["Setting_ToastPopup"], L["Setting_ToastPopupTT"])) -- NYI
		--table.insert(allSettingsData, CreateSettingData_CheckButton("keepMinimized", L["Setting_KeepMinimized"], L["Setting_KeepMinimizedTT"])) -- NYI
		--table.insert(allSettingsData, CreateSettingData_CheckButton("normalizeNames", L["Setting_NormalizeNames"], L["Setting_NormalizeNamesTT"])) -- NYI
		--table.insert(allSettingsData, CreateSettingData_CheckButton("chatboxMessages", L["Setting_ChatboxMessages"], L["Setting_ChatboxMessagesTT"])) -- NYI
		
		table.insert(allSettingsData, CreateSettingData_Slider("vol_master", L["Setting_MasterVolume"], L["Setting_MasterVolumeTT"], "Sound_MasterVolume"))
		table.insert(allSettingsData, CreateSettingData_Slider("vol_music", L["Setting_MusicVolume"], L["Setting_MusicVolumeTT"], "Sound_MusicVolume"))
		table.insert(allSettingsData, CreateSettingData_Slider("vol_sfx", L["Setting_SFXVolume"], L["Setting_SFXVolumeTT"], "Sound_SFXVolume"))
		table.insert(allSettingsData, CreateSettingData_Slider("vol_ambience", L["Setting_AmbienceVolume"], L["Setting_AmbienceVolumeTT"], "Sound_AmbienceVolume"))
		table.insert(allSettingsData, CreateSettingData_Slider("vol_dialog", L["Setting_DialogVolume"], L["Setting_DialogVolumeTT"], "Sound_DialogVolume"))
		
		table.insert(allSettingsData, CreateSettingData_Dropdown(
			"autosharePlaylist",
			L["Setting_AutosharePlaylist"],
			{
				{ text = L["Setting_Everyone"], value = 1, tooltip = L["Setting_AS_EveryoneTT"] },
				{ text = L["Setting_FriendsandGuild"], value = 2, tooltip = L["Setting_AS_FriendsandGuildTT"] },
				{ text = L["Setting_Friends"], value = 3, tooltip = L["Setting_AS_FriendsTT"] },
				{ text = L["Setting_None"], value = 4, tooltip = L["Setting_AS_None"] }
			},
			L["Setting_AutosharePlaylistTT"]
		))
		
		table.insert(allSettingsData, CreateSettingData_Dropdown(
			"autoImportPlaylist",
			L["Setting_AutoImportPlaylist"],
			{
				{ text = L["Setting_Everyone"], value = 1, tooltip = L["Setting_AI_EveryoneTT"] },
				{ text = L["Setting_FriendsandGuild"], value = 2, tooltip = L["Setting_AI_FriendsandGuildTT"] },
				{ text = L["Setting_Friends"], value = 3, tooltip = L["Setting_AI_FriendsTT"] },
				{ text = L["Setting_None"], value = 4, tooltip = L["Setting_AI_None"] }
			},
			L["Setting_AutoImportPlaylistTT"]
		))

		table.insert(allSettingsData, {
			type = "checkbox",
			key = "FootstepSounds",
			label = L["Setting_Footsteps"],
			tooltip = L["Setting_FootstepsTT"],
			searchText = (L["Setting_Footsteps"] .. " " .. L["Setting_FootstepsTT"] ):lower(),
			get = function()
				local val = HousingMusic_DB.volumeControls["FootstepSounds"]
				if val == nil then val = DefaultsTable.volumeControls["FootstepSounds"] end
				return (val == 1 or val == "1")
			end,
			set = function(value)
				local num = value and 1 or 0
				HousingMusic_DB.volumeControls = HousingMusic_DB.volumeControls or {}
				HousingMusic_DB.volumeControls["FootstepSounds"] = num
				
				HM.UpdateVolumeCVar("FootstepSounds", num)
			end
		})

		table.insert(allSettingsData, {
			type = "checkbox",
			key = "softTargettingInteractKeySound",
			label = L["Setting_InteractKeySound"],
			tooltip = L["Setting_InteractKeySoundTT"],
			searchText = (L["Setting_InteractKeySound"] .. " " .. L["Setting_InteractKeySoundTT"] ):lower(),
			get = function()
				local val = HousingMusic_DB.volumeControls["softTargettingInteractKeySound"]
				if val == nil then val = DefaultsTable.volumeControls["softTargettingInteractKeySound"] end
				return (val == 1 or val == "1")
			end,
			set = function(value)
				local num = value and 1 or 0
				HousingMusic_DB.volumeControls = HousingMusic_DB.volumeControls or {}
				HousingMusic_DB.volumeControls["softTargettingInteractKeySound"] = num
				
				HM.UpdateVolumeCVar("softTargettingInteractKeySound", num)
			end
		})

		table.insert(allSettingsData, {
			type = "checkbox",
			key = "TRP3_StopMusic",

			label = string.format(L["AddonCompatibility"], L["TRP3"]),
			tooltip = string.format(L["AddonCompatibilityTT"], L["TRP3"]),
			searchText = (string.format(L["AddonCompatibility"], L["TRP3"]) .. " " .. string.format(L["AddonCompatibilityTT"], L["TRP3"])):lower(),
			get = function()
				if HousingMusic_DB.addonCompatibilities and HousingMusic_DB.addonCompatibilities.TotalRP3_StopMusic ~= nil then
					return HousingMusic_DB.addonCompatibilities.TotalRP3_StopMusic
				end
				if DefaultsTable.addonCompatibilities then
					return DefaultsTable.addonCompatibilities.TotalRP3_StopMusic
				end
				return true
			end,
			set = function(value)
				if not HousingMusic_DB.addonCompatibilities then
					HousingMusic_DB.addonCompatibilities = {}
				end
				HousingMusic_DB.addonCompatibilities.TotalRP3_StopMusic = value
			end
		})

		table.insert(allSettingsData, {
			type = "checkbox",
			key = "reduceCameraMovement",
			label = L["Setting_ReduceCameraMovement"],
			tooltip = L["Setting_ReduceCameraMovementTT"] or "Disables character centering and enables reduced camera movement while inside the house.",
			searchText = (L["Setting_ReduceCameraMovement"] .. " " .. L["Setting_ReduceCameraMovementTT"]):lower(),
			get = function()
				return HousingMusic_DB.reduceCameraMovement
			end,
			set = function(value)
				HousingMusic_DB.reduceCameraMovement = value
				if HM.UpdateCameraCVars then 
					HM.UpdateCameraCVars(value) 
				end
			end
		})
		
		--table.insert(allSettingsData, CreateSettingData_Dropdown( -- NYI
		--	"customImportPlaylist",
		--	L["Setting_CustomImportPlaylist"],
		--	{
		--		{ text = L["Setting_Everyone"], value = 1, tooltip = L["Setting_CI_EveryoneTT"] },
		--		{ text = L["Setting_FriendsandGuild"], value = 2, tooltip = L["Setting_CI_FriendsandGuildTT"] },
		--		{ text = L["Setting_Friends"], value = 3, tooltip = L["Setting_CI_FriendsTT"] },
		--		{ text = L["Setting_None"], value = 4, tooltip = L["Setting_CI_None"] }
		--	},
		--	L["Setting_CustomImportPlaylistTT"]
		--))
		
		 -- this is probably not a necessary option to have given that playlists can be favorited
		--table.insert(allSettingsData, CreateSettingData_Dropdown(
		--	"clearCache",
		--	L["Setting_ClearCache"],
		--	{
		--		{ text = L["Setting_ClearCache_1"], value = 1, tooltip = nil },
		--		{ text = L["Setting_ClearCache_2"], value = 2, tooltip = nil },
		--		{ text = L["Setting_ClearCache_3"], value = 3, tooltip = nil },
		--		{ text = L["Setting_ClearCache_4"], value = 4, tooltip = nil }
		--	},
		--	L["Setting_ClearCacheTT"]
		--))
		
		FilterSettings()
	end
end
SettingsButton:SetScript("OnEvent", SettingsButton.LoadSettings)


local IgnoreFrame = CreateFrame("Frame", "HousingMusic_IgnoreFrame", MainFrame)
IgnoreFrame:SetSize(250, 300)
IgnoreFrame:SetPoint("TOPLEFT", MainFrame, "TOPRIGHT", 5, 0)
IgnoreFrame:SetFrameLevel(600)
IgnoreFrame:EnableMouse(true)

local closeButtonIgnore = CreateFrame("Button", nil, IgnoreFrame, "UIPanelCloseButtonNoScripts");
closeButtonIgnore:SetPoint("TOPRIGHT", -5, -5);
closeButtonIgnore:SetFrameLevel(IgnoreFrame:GetFrameLevel()+1)
closeButtonIgnore:SetScript("OnClick", function()
	if IgnoreFrame then
		IgnoreFrame:Hide();
	end
end);
IgnoreFrame.closeButton = closeButtonIgnore

local IgnoreFrameTexture = IgnoreFrame:CreateTexture(nil, "BACKGROUND", nil, 1);
IgnoreFrameTexture:SetPoint("TOPLEFT", 0, 0);
IgnoreFrameTexture:SetPoint("BOTTOMRIGHT", 0, 0);
IgnoreFrameTexture:SetAtlas("housing-basic-container");
IgnoreFrameTexture:SetTextureSliceMargins(64, 64, 64, 112);
IgnoreFrameTexture:SetTextureSliceMode(Enum.UITextureSliceMode.Stretched);
IgnoreFrame:Hide()

local IgnoreFrameTitle = IgnoreFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
IgnoreFrameTitle:SetPoint("TOP", 0, -15)
IgnoreFrameTitle:SetText(L["MuteList"])

local IgnoreInput = CreateFrame("EditBox", nil, IgnoreFrame, "InputBoxTemplate")
IgnoreInput:SetSize(140, 30)
IgnoreInput:SetPoint("TOPLEFT", 20, -40)
IgnoreInput:SetAutoFocus(false)
IgnoreInput:SetTextInsets(5, 5, 0, 0)
IgnoreInput:SetText(L["Setting_NameRealm"])
IgnoreInput:HookScript("OnEnter", function(self)
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
	GameTooltip:AddLine(L["Setting_MutePlayer"], goldR, goldG, goldB, goldA, true)
	GameTooltip:AddLine(L["Setting_MutePlayerRealmAdded"], 1, 1, 1, 1, true)
	GameTooltip:Show()

end)
IgnoreInput:SetScript("OnLeave", function()
	GameTooltip:Hide()
end)

local AddIgnoreBtn = CreateFrame("Button", nil, IgnoreFrame, "UIPanelButtonTemplate")
AddIgnoreBtn:SetSize(60, 22)
AddIgnoreBtn:SetPoint("LEFT", IgnoreInput, "RIGHT", 5, 0)
AddIgnoreBtn:SetText(L["Mute"])

local IgnoreScrollBox = CreateFrame("Frame", nil, IgnoreFrame, "WowScrollBoxList")
IgnoreScrollBox:SetPoint("TOPLEFT", IgnoreInput, "BOTTOMLEFT", 0, -10)
IgnoreScrollBox:SetPoint("BOTTOMRIGHT", IgnoreFrame, "BOTTOMRIGHT", -25, 15)

local IgnoreScrollBar = CreateFrame("EventFrame", nil, IgnoreFrame, "MinimalScrollBar")
IgnoreScrollBar:SetPoint("TOPLEFT", IgnoreScrollBox, "TOPRIGHT", 5, 0)
IgnoreScrollBar:SetPoint("BOTTOMLEFT", IgnoreScrollBox, "BOTTOMRIGHT", 5, 0)

local IgnoreScrollView = CreateScrollBoxListLinearView()
ScrollUtil.InitScrollBoxListWithScrollBar(IgnoreScrollBox, IgnoreScrollBar, IgnoreScrollView)

local ExampleNameRealm = L["Setting_NameRealm"]

local function RefreshIgnoreUI()
	local list = HM.GetIgnoreList()
	local dataProvider = CreateDataProvider(list)
	IgnoreScrollBox:SetDataProvider(dataProvider)
end
function AddIgnoreBtn.OnClick()
	local nameToBlock = nil

	if UnitExists("target") and UnitIsPlayer("target") and not UnitIsUnit("target", "player") then
		local name, realm = UnitName("target")
		
		if not realm or realm == "" then
			realm = GetNormalizedRealmName()
		end
		
		nameToBlock = name .. "-" .. realm

	else
		local text = IgnoreInput:GetText()
		
		if text and text ~= "" and text ~= ExampleNameRealm then
			text = text:gsub("%s+", "")
			
			local namePart, realmPart = strsplit("-", text, 2)
			
			if namePart and namePart ~= "" then
				namePart = namePart:sub(1,1):upper() .. namePart:sub(2):lower()
				
				if not realmPart or realmPart == "" then
					realmPart = GetNormalizedRealmName()
				end
				
				nameToBlock = namePart .. "-" .. realmPart
			end
		end
	end

	if nameToBlock then
		HM.IgnorePlayer(nameToBlock)
		
		if HM_CachedMusic_DB then
			for k, v in pairs(HM_CachedMusic_DB) do
				if v[nameToBlock] then
					v[nameToBlock] = nil
				end
			end
		end

		IgnoreInput:SetText(ExampleNameRealm)
		IgnoreInput:ClearFocus()
		RefreshIgnoreUI()
	end
end

AddIgnoreBtn:SetScript("OnClick", function()
	AddIgnoreBtn.OnClick()
end)
IgnoreInput:SetScript("OnEnterPressed", function()
	AddIgnoreBtn.OnClick()
end)
IgnoreInput:SetScript("OnEditFocusLost", function()
	local text = IgnoreInput:GetText()
	if not text or text == "" then
		IgnoreInput:SetText(ExampleNameRealm)
	end
end)
IgnoreInput:SetScript("OnEditFocusGained", function()
	IgnoreInput:SetText("")
end)

IgnoreInput:RegisterEvent("UNIT_TARGET", function()

end)


local function IgnoreRowInitializer(button, name)
	if not button.tex then
		button.tex = button:CreateTexture(nil, "BACKGROUND", nil, 0)
		button.tex:SetAllPoints(button)
		button.tex:SetAtlas("Options_List_Hover")
		--button.tex:SetAlpha(0.3)
	end


	if not button.onEnter then
		button.onEnter = button:CreateTexture(nil, "BACKGROUND", nil, 1)
		button.onEnter:SetAllPoints(button)
		button.onEnter:SetAtlas("Options_List_Active")
		button.onEnter:Hide()
		button:SetScript("OnEnter", function()
			button.onEnter:Show()
		end)
		button:SetScript("OnLeave", function()
			button.onEnter:Hide()
		end)
	end

	if not button.text then
		button.text = button:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
		button.text:SetPoint("LEFT", 5, 0)
		button.text:SetPoint("RIGHT", -25, 0)
		button.text:SetJustifyH("LEFT")
	end
	button.text:SetText(name)

	if not button.deleteBtn then
		button.deleteBtn = CreateFrame("Button", nil, button)
		button.deleteBtn:SetSize(13, 13)
		button.deleteBtn:SetPoint("RIGHT", -5, 0)
		button.deleteBtn:SetNormalAtlas("common-search-clearbutton")
		button.deleteBtn:SetHighlightAtlas("common-search-clearbutton")
		button.deleteBtn:GetHighlightTexture():SetAlpha(0.5)
		
		button.deleteBtn:SetScript("OnEnter", function(self)
			GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
			GameTooltip:SetText(L["UnmutePlayer"])
			GameTooltip:Show()
		end)
		button.deleteBtn:SetScript("OnLeave", function() GameTooltip:Hide() end)
	end

	button.deleteBtn:SetScript("OnClick", function()
		HM.UnignorePlayer(name)
		RefreshIgnoreUI()
	end)
end

IgnoreScrollView:SetElementInitializer("Button", IgnoreRowInitializer)
IgnoreScrollView:SetElementExtent(24) -- Row height
IgnoreScrollView:SetPadding(5, 5, 5, 5, 2)

SettingsButton:SetScript("OnClick", function()
	if SettingsFrame:IsShown() then
		SettingsFrame:Hide()
	else
		SettingsFrame:Show()
		RefreshIgnoreUI()
	end
end);

IgnorePanelBtn:SetScript("OnClick", function()
	if IgnoreFrame:IsShown() then
		IgnoreFrame:Hide()
	else
		IgnoreFrame:Show()
		RefreshIgnoreUI()
	end
end);

SettingsButton:SetScript("OnMouseDown", function(self, button)
	SettingsButton:GetNormalTexture():SetTexCoord(-.075,.925,-.075,.925)
	SettingsButton:GetHighlightTexture():SetTexCoord(-.075,.925,-.075,.925)
end);
SettingsButton:SetScript("OnMouseUp", function(self, button)
	SettingsButton:GetNormalTexture():SetTexCoord(0,1,0,1)
	SettingsButton:GetHighlightTexture():SetTexCoord(0,1,0,1)
end);

MainFrame:Hide()
MainFrame:SetScript("OnShow", function()MainframeToggleButton:SetNormalTexture(Decor_Controls_Music_Active)
	PlaySound(305110)
	if not ScrollViewLeft:GetDataProvider() then
		RefreshUILists()
	end
	UpdateSavedMusicList()
	UpdateCVarBlocker()
end)
MainFrame:SetScript("OnHide", function()
	MainframeToggleButton:SetNormalTexture(Decor_Controls_Music_Default)
	PlaySound(305110)
end)

-------------------------------------------------------------------------------
-- MAIN FRAME - Left Scroll Box
-------------------------------------------------------------------------------

ScrollBoxLeft = CreateFrame("Frame", nil, MainFrame, "WowScrollBoxList")
ScrollBoxLeft:SetPoint("TOPLEFT", SectionLeft, "TOPLEFT", 5, -20)
ScrollBoxLeft:SetPoint("BOTTOMRIGHT", SectionLeft, "BOTTOMRIGHT", -20, 0)
ScrollBoxLeft:SetFrameLevel(500)

local ScrollBarLeft = CreateFrame("EventFrame", nil, MainFrame, "MinimalScrollBar")
ScrollBarLeft:SetPoint("TOPLEFT", ScrollBoxLeft, "TOPRIGHT", 5, 0)
ScrollBarLeft:SetPoint("BOTTOMLEFT", ScrollBoxLeft, "BOTTOMRIGHT", 5, 0)

ScrollViewLeft = CreateScrollBoxListLinearView() 
ScrollUtil.InitScrollBoxListWithScrollBar(ScrollBoxLeft, ScrollBarLeft, ScrollViewLeft)

SearchBoxLeft = CreateFrame("EditBox", nil, SectionLeft, "SearchBoxTemplate")
SearchBoxLeft:SetPoint("TOPLEFT", SectionLeft, "TOPLEFT", 10, 0)
SearchBoxLeft:SetPoint("TOPRIGHT", SectionLeft, "TOPRIGHT", -20, 0)
SearchBoxLeft:SetHeight(20)
SearchBoxLeft:SetAutoFocus(false)

function FilterAvailableList(editBox)
	local text = SearchBoxLeft:GetText() or ""
	local query = CleanString(text)
	
	local matches = {}
	local addedIDs = {}
	
	local queryID = tonumber(query)
	if queryID then
		local info = LRPM:GetMusicInfoByFile(queryID)
		if info then
			info.name = info.names and info.names[1] or tostring(info.file)
			table.insert(matches, info)
			addedIDs[info.file] = true
		end
	end

	if query == "" then
		for _, musicInfo in LRPM:EnumerateMusic() do
			musicInfo.name = musicInfo.names and musicInfo.names[1] or tostring(musicInfo.file)
			table.insert(matches, musicInfo)
		end
	else
		local function predicate(name)
			return CleanString(name):find(query, 1, true)
		end

		for musicInfo in LRPM:FindMusic(predicate) do
			if not addedIDs[musicInfo.file] then
				musicInfo.name = musicInfo.names and musicInfo.names[1] or tostring(musicInfo.file)
				table.insert(matches, musicInfo)
				addedIDs[musicInfo.file] = true
			end
		end
	end
	
	local musicDataProvider = CreateDataProvider(matches) 
	ScrollViewLeft:SetDataProvider(musicDataProvider)
end

-- Generally safer to use HookScript on EditBoxes inheriting a template as they likely already have OnTextChanged callbacks defined
-- As a side note, it may be worth debouncing this callback if your search method is particularly performance intensive
SearchBoxLeft:HookScript("OnTextChanged", SearchBox_OnTextChanged);
SearchBoxLeft:HookScript("OnEnter", function(self)
	GameTooltip:SetOwner(self, "ANCHOR_TOP")
	GameTooltip:AddLine(L["SearchByNameFileID"], 1, 1, 1)
	GameTooltip:Show()
end)
SearchBoxLeft:HookScript("OnLeave", function()
	GameTooltip:Hide()
end)

local function Initializer(button, musicInfo)

	local text = musicInfo.name or (string.format(L["FileID"], (musicInfo.file or L["Unknown"])))

	local activePlaylist = HM.GetActivePlaylistTable()
	local isSaved = activePlaylist[musicInfo.file]
	local isIgnored = HM.IsSongIgnored(musicInfo.file)

	local playlistCount = 0
	for _ in pairs(activePlaylist) do playlistCount = playlistCount + 1 end
	local isPlaylistFull = playlistCount >= (HM.MAX_PLAYLIST_SIZE or 50)
	
	button.tex = button.tex or button:CreateTexture(nil, "BACKGROUND", nil, 0)
	button.tex:SetAllPoints(button)
	--button.tex:SetPoint("TOPLEFT", button, "TOPLEFT", 1, -1)
	--button.tex:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -1, 1)
	button.tex:SetAtlas("ClickCastList-ButtonBackground")

	button.ignoredTex = button.ignoredTex or button:CreateTexture(nil, "ARTWORK", nil, 1)
	button.ignoredTex:SetAllPoints(button)
	button.ignoredTex:SetAtlas("ClickCastList-ButtonHighlight")
	button.ignoredTex:SetVertexColor(1, 0, 0, 1.00)
	button.ignoredTex:SetShown(isIgnored)

	button.selectedTex = button.selectedTex or button:CreateTexture(nil, "ARTWORK", nil, 2)
	button.selectedTex:SetAllPoints(button)
	button.selectedTex:SetAtlas("ReportList-ButtonSelect")
	button.selectedTex:SetShown(selectedFileID == musicInfo.file)

	button:RegisterForClicks("LeftButtonUp", "RightButtonUp")
	button:SetScript("OnClick", function(self, btn)
		if btn == "RightButton" then
			OpenSongContextMenu(self, musicInfo)
		else
			selectedFileID = musicInfo.file
			PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
			UpdateSelectionHighlights()
		end
	end)
	
	button.texHL = button.texHL or button:CreateTexture(nil, "OVERLAY", nil, 3)
	button.texHL:SetAllPoints(button)
	button.texHL:SetAtlas("ClickCastList-ButtonHighlight")
	button.texHL:SetVertexColor(0.42, 0.54, 1.00, 1.00)
	button.texHL:Hide()
	
	button.textFont = button.textFont or button:CreateFontString(nil, "OVERLAY")
	button.textFont:SetFontObject("GameTooltipTextSmall")
	button.textFont:SetPoint("TOPLEFT", button, "TOPLEFT", 15, 0)
	button.textFont:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -55, 0)
	button.textFont:SetJustifyH("LEFT")
	button.textFont:SetJustifyV("MIDDLE")
	button.textFont:SetText(text)
	button.textFont:SetTextColor(1, 1, 1, 1)


	local savedIndicator = button.savedIndicator
	if not savedIndicator then
		savedIndicator = button:CreateTexture(nil, "OVERLAY", nil, 1)
		savedIndicator:SetSize(20, 20)
		savedIndicator:SetPoint("TOPLEFT", button, "TOPLEFT", 0, 0)
		savedIndicator:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", 0, 0)
		savedIndicator:SetAtlas("ClickCastList-ButtonHighlight")
		savedIndicator:SetDesaturated(true)
		savedIndicator:SetVertexColor(0.83, 0.42, 1.00)
		button.savedIndicator = savedIndicator
	end
	savedIndicator:SetShown(isSaved)

	local addButton = button.addButton
	if not addButton then
		addButton = CreateFrame("Button", nil, button)
		addButton:SetSize(20, 20)
		addButton:SetPoint("RIGHT", button, "RIGHT", -10, 0)
		addButton:SetNormalAtlas("common-icon-plus")
		addButton:SetHighlightAtlas("common-icon-plus")
		addButton:GetHighlightTexture():SetAlpha(0.5)

		button.addButton = addButton
	end

	if isPlaylistFull and not isSaved then
		addButton:GetNormalTexture():SetDesaturated(true)
		addButton:GetHighlightTexture():SetDesaturated(true)
		addButton:SetAlpha(0.5)
	else
		addButton:GetNormalTexture():SetDesaturated(false)
		addButton:GetHighlightTexture():SetDesaturated(false)
		addButton:SetAlpha(1.0)
	end

	addButton:Hide()

	local playButton = button.playButton
	if not playButton then
		playButton = CreateFrame("Button", nil, button)
		playButton:SetSize(20, 20)
		playButton:SetPoint("RIGHT", addButton, "LEFT", -2, 0)
		playButton:SetNormalAtlas("common-dropdown-icon-play")
		playButton:SetHighlightAtlas("common-dropdown-icon-play")
		playButton:GetHighlightTexture():SetAlpha(0.5)

		button.playButton = playButton
	end
	playButton:Hide()

	playButton:SetScript("OnClick", function()
		HM.PlaySpecificMusic(musicInfo.file)
		selectedFileID = musicInfo.file
		UpdateSelectionHighlights()
	end)
	
	addButton:SetScript("OnClick", function()
		if isPlaylistFull and not isSaved then

			local playlistCount = 0
			for _ in pairs(activePlaylist) do playlistCount = playlistCount + 1 end
			--Print(string.format(L["PlaylistIsFull"], playlistCount, HM.MAX_PLAYLIST_SIZE or 50))
			return
		end

		local currentList = HM.GetActivePlaylistTable()

		if not currentList[musicInfo.file] then
			currentList[musicInfo.file] = true 
			local dataProvider = ScrollViewRight:GetDataProvider()
			if dataProvider then
				-- Create the data structure exactly as UpdateSavedMusicList does
				local primaryName = musicInfo.names and musicInfo.names[1] or (string.format(L["FileID"], musicInfo.file))
				local newData = { 
					name = primaryName, 
					file = musicInfo.file, 
					duration = musicInfo.duration,
					names = musicInfo.names,
				}
				-- Insert at the end (or Sort if you prefer)
				dataProvider:Insert(newData)
			end

			HM.RefreshButtonForMusic(musicInfo)
			--Print(string.format(L["AddedMusicToPlaylist"], musicInfo.name, HM.GetActivePlaylistName()))
			PlaySound(316551)

			if HM.BroadcastToNameplates then HM.BroadcastToNameplates() end
		--else
		--	print("|cffffcc00Warning:|r Music already saved.")
		end
	end)

	local function HideButtonElements(self)
		if self:IsMouseOver() then
			self.texHL:Show()
			if self.playButton then
				self.playButton:Show()
			end
			if not isSaved and self.addButton and C_Housing.IsInsideOwnHouse() then
				self.addButton:Show()
			end
		else
			self.texHL:Hide()
			if self.playButton then
				self.playButton:Hide()
			end
			if self.addButton and C_Housing.IsInsideOwnHouse() then
				self.addButton:Hide()
			end
		end
	end
	
	button:SetScript("OnEnter", function(self)
		HideButtonElements(button)
		
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:AddLine(musicInfo.name, 1, 1, 1)
		GameTooltip:AddLine(string.format(L["DurationNumber"], FormatDuration(musicInfo.duration)), 0.8, 0.8, 0.8)

		if isSaved then
			GameTooltip:AddLine(string.format(L["SongIsInPlaylist"], HM.GetActivePlaylistName()), 0.83, 0.42, 1.00)
		end

		if isIgnored then
			GameTooltip:AddLine(L["SongIsMuted"], 0.83, 0.00, 0.00)
		end
		
		if musicInfo.names and #musicInfo.names > 1 then
			GameTooltip:AddLine(" ")
			GameTooltip:AddLine(L["AlternateNames"], 0.8, 0.8, 0.8)
			
			for i = 2, #musicInfo.names do
				GameTooltip:AddLine(musicInfo.names[i], 0.7, 0.7, 0.7)
			end
		end
		
		GameTooltip:Show()
	end)
	
	button:SetScript("OnLeave", function(self)
		GameTooltip:Hide()
		HideButtonElements(button)
	end)

	addButton:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")

		local playlistCount = 0
		for _ in pairs(activePlaylist) do playlistCount = playlistCount + 1 end
		if isPlaylistFull and not isSaved then
			GameTooltip:AddLine(string.format(L["PlaylistIsFull"], playlistCount, HM.MAX_PLAYLIST_SIZE or 50), 1, 0.2, 0.2)
		else
			GameTooltip:AddLine(L["AddSongToPlaylist"], 1, 1, 1)
		end
		GameTooltip:Show()
		HideButtonElements(button)
	end)
	addButton:SetScript("OnLeave", function(self)
		GameTooltip:Hide()
		HideButtonElements(button)
	end)

	playButton:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:AddLine(L["PreviewSong"], 1, 1, 1)
		GameTooltip:Show()
		HideButtonElements(button)
	end)
	playButton:SetScript("OnLeave", function(self)
		GameTooltip:Hide()
		HideButtonElements(button)
	end)
end

ScrollViewLeft:SetElementInitializer("Button", Initializer)
ScrollViewLeft:SetElementExtent(36);

-- Looks for the button in the left scrollview associated with the provided musicInfo and updates its display
function HM.RefreshButtonForMusic(musicInfo)
	local button = ScrollViewLeft:FindFrameByPredicate(function(frame, data)
		return data.file == musicInfo.file;
	end);
	if button then
		Initializer(button, musicInfo);
	end
end

-------------------------------------------------------------------------------
-- MAIN FRAME - Right Scroll Box
-------------------------------------------------------------------------------

ScrollBoxRight = CreateFrame("Frame", nil, MainFrame, "WowScrollBoxList")
ScrollBoxRight:SetPoint("TOPLEFT", SectionRight, "TOPLEFT", 5, -20)
ScrollBoxRight:SetPoint("BOTTOMRIGHT", SectionRight, "BOTTOMRIGHT", -20, 0)
ScrollBoxRight:SetFrameLevel(500)

local ScrollBarRight = CreateFrame("EventFrame", nil, MainFrame, "MinimalScrollBar")
ScrollBarRight:SetPoint("TOPLEFT", ScrollBoxRight, "TOPRIGHT", 5, 0)
ScrollBarRight:SetPoint("BOTTOMLEFT", ScrollBoxRight, "BOTTOMRIGHT", 5, 0)

ScrollViewRight = CreateScrollBoxListLinearView()
ScrollUtil.InitScrollBoxListWithScrollBar(ScrollBoxRight, ScrollBarRight, ScrollViewRight)

SearchBoxRight = CreateFrame("EditBox", nil, SectionRight, "SearchBoxTemplate")
SearchBoxRight:SetPoint("TOPLEFT", SectionRight, "TOPLEFT", 10, 0)
SearchBoxRight:SetPoint("TOPRIGHT", SectionRight, "TOP", -12, 0)
SearchBoxRight:SetHeight(20)
SearchBoxRight:SetAutoFocus(false)

function FilterSavedList(editBox)
	local text = SearchBoxRight:GetText() or ""
	local query = CleanString(text)
	
	local matches = {}
	
	for _, musicInfo in ipairs(fullSavedList) do
		if query == "" then
			table.insert(matches, musicInfo)
		else
			local matchedName = CheckMatch(musicInfo, query)
			
			if matchedName then 
				local primaryName = musicInfo.names and musicInfo.names[1] or (string.format(L["FileID"], (musicInfo.file or L["Unknown"])))

				local displayItem = {
					file = musicInfo.file,
					duration = musicInfo.duration,
					names = musicInfo.names,
					name = primaryName
				}
				table.insert(matches, displayItem)
			end
		end
	end
	
	local musicDataProvider = CreateDataProvider(matches)
	ScrollViewRight:SetDataProvider(musicDataProvider)
end

-- Generally safer to use HookScript on EditBoxes inheriting a template as they likely already have OnTextChanged callbacks defined
-- As a side note, it may be worth debouncing this callback if your search method is particularly performance intensive
SearchBoxRight:HookScript("OnTextChanged", SearchBox_OnTextChanged);

local ExportFrame = CreateFrame("Frame", "HousingMusic_ExportFrame", UIParent)
ExportFrame:SetSize(400, 120)
ExportFrame:SetPoint("CENTER")
ExportFrame:SetFrameStrata("DIALOG")
ExportFrame:Hide()

ExportFrame.Bg = ExportFrame:CreateTexture(nil, "BACKGROUND")
ExportFrame.Bg:SetAllPoints()
ExportFrame.Bg:SetColorTexture(0, 0, 0, 0.9)

ExportFrame.Border = CreateFrame("Frame", nil, ExportFrame, "DialogBorderTemplate")

ExportFrame.Title = ExportFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
ExportFrame.Title:SetPoint("TOP", 0, -15)
ExportFrame.Title:SetText(L["ExportPlaylist"])

ExportFrame.CopyBox = HM.CreateCopyBox(ExportFrame, 350)
ExportFrame.CopyBox:SetPoint("CENTER", 0, 10)
ExportFrame.CopyBox:SetLabel(L["ExportPlaylistString"])

ExportFrame.CloseBtn = CreateFrame("Button", nil, ExportFrame, "UIPanelButtonTemplate")
ExportFrame.CloseBtn:SetSize(100, 25)
ExportFrame.CloseBtn:SetPoint("BOTTOM", 0, 15)
ExportFrame.CloseBtn:SetText(L["Close"])
ExportFrame.CloseBtn:SetScript("OnClick", function() ExportFrame:Hide() end)

function HM.ShowExportWindow(dataString)
	ExportFrame:Show()
	ExportFrame.CopyBox:SetText(dataString)
	ExportFrame.CopyBox:SetFocus()
	ExportFrame.CopyBox:HighlightText()
end

local PlaylistDropdown = CreateFrame("DropdownButton", "HM_PlaylistDropdown", SectionRight, "WowStyle1DropdownTemplate")
PlaylistDropdown:SetPoint("TOPLEFT", SectionRight, "TOP", -10, -2.5)
PlaylistDropdown:SetPoint("TOPRIGHT", SectionRight, "TOPRIGHT", -20, 0)
PlaylistDropdown.Text:ClearAllPoints()
PlaylistDropdown.Text:SetPoint("TOPLEFT",PlaylistDropdown,"TOPLEFT", 3, 6)
PlaylistDropdown.Text:SetPoint("BOTTOMRIGHT",PlaylistDropdown.Arrow,"BOTTOMLEFT", 0, 0)
PlaylistDropdown:SetHeight(16)

local MapIcons = {
	[2351] = "charcreatetest-logo-horde",
	[2352] = "charcreatetest-logo-alliance",
}

local function GeneratorFunction(dropdown, rootDescription)
	rootDescription:SetScrollMode(300)

	local isOwner = C_Housing.IsInsideOwnHouse()
	
	if isOwner then
		local active = HM.GetActivePlaylistName()

		rootDescription:CreateButton(WrapTextInColorCode(L["CreateNewPlaylist"],"ff00ff00"), function()
			StaticPopup_Show("HOUSINGMUSIC_NEW_PLAYLIST")
		end)

		if active ~= L["Default"] then
			rootDescription:CreateButton(WrapTextInColorCode(L["RenameCurrentPlaylist"],"ff00ff00"), function()
				StaticPopup_Show("HOUSINGMUSIC_RENAME_PLAYLIST", active, nil, active)
			end)
		end

		rootDescription:CreateButton(WrapTextInColorCode(L["ImportPlaylist"], "ff00ff00"), function()
			StaticPopup_Show("HOUSINGMUSIC_IMPORT_DATA")
		end)
		
		local exportString = GenerateExportString()
		if exportString and exportString ~= "" then
			rootDescription:CreateButton(WrapTextInColorCode(L["ExportPlaylist"], "ff00ff00"), function()
				HM.ShowExportWindow(exportString)
			end)
		end

		if active ~= L["Default"] then
			rootDescription:CreateDivider()
			rootDescription:CreateButton(WrapTextInColorCode(L["DeleteCurrentPlaylist"],"ffff0000"), function()
				StaticPopup_Show("HOUSINGMUSIC_DELETE_PLAYLIST", active)
			end)
		end

		rootDescription:CreateDivider()
		rootDescription:CreateTitle(L["SelectPlaylist"])

		local playlists = HM.GetPlaylistNames()
		if not playlists then return end
		for _, name in ipairs(playlists) do
			local playlistTable = HousingMusic_DB.Playlists[name] or {}
			local songCount = 0
			for _ in pairs(playlistTable) do
				songCount = songCount + 1
			end
			
			local displayName = string.format("(%d/%d) %s", songCount, HM.MAX_PLAYLIST_SIZE or 50, name)

			if HousingMusic_DB.HouseAssignments then
				local iconsString = ""
				
				for key, assignedName in pairs(HousingMusic_DB.HouseAssignments) do
					if assignedName == name then
						local parts = {strsplit("_", key)}
						
						if parts[2] and parts[3] then
							local mapID = C_Housing.GetUIMapIDForNeighborhood(parts[2])
							local iconAtlas = MapIcons[mapID]
							
							if iconAtlas then
								iconsString = iconsString .. string.format(" |A:%s:16:16|a", iconAtlas)
							else
								iconsString = iconsString .. string.format(" (#%s)", parts[3])
							end
						end
					end
				end

				if iconsString ~= "" then
					displayName = displayName .. iconsString
				end
			end

			rootDescription:CreateRadio(displayName, function(playlistName)
				return HM.GetActivePlaylistName() == playlistName
			end, function(playlistName)
				HM.SetActivePlaylist(playlistName)
				UpdateSavedMusicList()
				RefreshUILists()
			end, name)
		end
	else
		local locationKey = GetCurrentLocationKey()
		if not locationKey or not HM_CachedMusic_DB or not HM_CachedMusic_DB[locationKey] then
			rootDescription:CreateTitle(L["NoPlaylistsReceived"])
			return 
		end

		rootDescription:CreateTitle(L["SelectSource"])
		
		local currentPref = HousingMusic_DB.VisitorPreferences[locationKey]

		for senderName, _ in pairs(HM_CachedMusic_DB[locationKey]) do
			local cachedPlaylist = HM_CachedMusic_DB[locationKey][senderName] or {}
			local songCount = 0
			for _ in pairs(cachedPlaylist) do
				songCount = songCount + 1
			end
			
			local displayName = string.format("%s (%d songs)", senderName, songCount)
			
			rootDescription:CreateRadio(displayName, function(sName)
				return currentPref == sName
			end, function(sName)
				HousingMusic_DB.VisitorPreferences[locationKey] = sName
				
				UpdateSavedMusicList()
				RefreshUILists()
				if HM and HM.CheckConditions then HM.CheckConditions() end
			end, senderName)
		end
	end
end

PlaylistDropdown:SetupMenu(GeneratorFunction)

local function RemoveMusicEntry(musicFile, musicName)
	local currentList = HM.GetActivePlaylistTable()
	currentList[musicFile] = nil
	local dataProvider = ScrollViewRight:GetDataProvider()
	if dataProvider then
		local foundData = dataProvider:FindElementDataByPredicate(function(data)
			return data.file == musicFile
		end)
		
		if foundData then
			dataProvider:Remove(foundData)
		end
	end

	Print(string.format(L["RemovedSongFromPlaylist"], musicName, HM.GetActivePlaylistName()))

	if HM.BroadcastToNameplates then HM.BroadcastToNameplates() end
end

local function SavedInitializer(button, musicInfo)
	local text = musicInfo.name or (string.format(L["FileID"], (musicInfo.file or L["Unknown"])))
	local isIgnored = HM.IsSongIgnored(musicInfo.file)

	button.tex = button.tex or button:CreateTexture(nil, "BACKGROUND", nil, 0)
	button.tex:SetAllPoints(button)
	button.tex:SetAtlas("ClickCastList-ButtonBackground")

	button.ignoredTex = button.ignoredTex or button:CreateTexture(nil, "ARTWORK", nil, 1)
	button.ignoredTex:SetAllPoints(button)
	button.ignoredTex:SetAtlas("ClickCastList-ButtonHighlight")
	button.ignoredTex:SetVertexColor(1.00, 0.00, 0.00, 1.00)
	button.ignoredTex:SetShown(isIgnored)

	button.selectedTex = button.selectedTex or button:CreateTexture(nil, "ARTWORK", nil, 1)
	button.selectedTex:SetAllPoints(button)
	button.selectedTex:SetAtlas("ReportList-ButtonSelect")
	button.selectedTex:SetShown(selectedFileID == musicInfo.file)

	button:RegisterForClicks("LeftButtonUp", "RightButtonUp")
	button:SetScript("OnClick", function(self, btn)
		if btn == "RightButton" then
			OpenSongContextMenu(self, musicInfo)
		else
			selectedFileID = musicInfo.file
			PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
			UpdateSelectionHighlights()
		end
	end)
	
	button.texHL = button.texHL or button:CreateTexture(nil, "OVERLAY", nil, 3)
	button.texHL:SetAllPoints(button)
	button.texHL:SetAtlas("ClickCastList-ButtonHighlight")
	button.texHL:SetVertexColor(0.42, 0.54, 1.00, 1.00)
	button.texHL:Hide()
	
	button.textFont = button.textFont or button:CreateFontString(nil, "OVERLAY")
	button.textFont:SetFontObject("GameTooltipTextSmall")
	button.textFont:SetPoint("TOPLEFT", button, "TOPLEFT", 15, 0)
	button.textFont:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -55, 0)
	button.textFont:SetJustifyH("LEFT")
	button.textFont:SetJustifyV("MIDDLE")
	button.textFont:SetText(text)
	button.textFont:SetTextColor(1, 1, 1, 1)
	
	local removeButton = button.removeButton
	if not removeButton then
		removeButton = CreateFrame("Button", nil, button)
		removeButton:SetSize(20, 20)
		removeButton:SetPoint("RIGHT", button, "RIGHT", -10, 0)
		removeButton:SetNormalAtlas("common-icon-minus")
		removeButton:SetHighlightAtlas("common-icon-minus")
		removeButton:GetHighlightTexture():SetAlpha(0.5)
		
		button.removeButton = removeButton
	end
	removeButton:Hide()

	local playButton = button.playButton
	if not playButton then
		playButton = CreateFrame("Button", nil, button)
		playButton:SetSize(20, 20)
		playButton:SetPoint("RIGHT", removeButton, "LEFT", -2, 0)
		playButton:SetNormalAtlas("common-dropdown-icon-play")
		playButton:SetHighlightAtlas("common-dropdown-icon-play")
		playButton:GetHighlightTexture():SetAlpha(0.5)

		button.playButton = playButton
	end
	playButton:Hide()

	playButton:SetScript("OnClick", function()
		HM.PlaySpecificMusic(musicInfo.file)
		selectedFileID = musicInfo.file
		UpdateSelectionHighlights()
	end)

	local function HideButtonElements(self)
		if self:IsMouseOver() then
			self.texHL:Show()
			if self.playButton then
				self.playButton:Show()
			end
			if self.removeButton and C_Housing.IsInsideOwnHouse() then
				self.removeButton:Show()
			end
		else
			self.texHL:Hide()
			if self.playButton then
				self.playButton:Hide()
			end
			if self.removeButton and C_Housing.IsInsideOwnHouse() then
				self.removeButton:Hide()
			end
		end
	end
	
	removeButton:SetScript("OnClick", function()
		RemoveMusicEntry(musicInfo.file, musicInfo.name)
		HM.RefreshButtonForMusic(musicInfo)
		PlaySound(316562)
	end)
	
	button:SetScript("OnEnter", function(self)
		if IsEditingAllowed() then
			self.removeButton:Show()
		end
		
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:AddLine(musicInfo.name, 1, 1, 1)

		GameTooltip:AddLine(string.format(L["DurationNumber"], FormatDuration(musicInfo.duration)), 0.8, 0.8, 0.8)

		if isIgnored then
			GameTooltip:AddLine(L["SongIsMuted"], 0.83, 0.00, 0.00)
		end
		
		if musicInfo.names and #musicInfo.names > 1 then
			GameTooltip:AddLine(" ")
			GameTooltip:AddLine(L["AlternateNames"], 0.8, 0.8, 0.8)
			
			for i = 2, #musicInfo.names do
				GameTooltip:AddLine(musicInfo.names[i], 0.7, 0.7, 0.7)
			end
		end
		
		GameTooltip:Show()
		HideButtonElements(self)
	end)
	
	button:SetScript("OnLeave", function(self)
		GameTooltip:Hide()
		HideButtonElements(self)
	end)

	removeButton:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:AddLine(L["RemoveSongFromPlaylist"], 1, 1, 1)
		GameTooltip:Show()
		HideButtonElements(button)
	end)
	removeButton:SetScript("OnLeave", function(self)
		GameTooltip:Hide()
		HideButtonElements(button)
	end)

	playButton:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:AddLine(L["PreviewSong"], 1, 1, 1)
		GameTooltip:Show()
		HideButtonElements(button)
	end)
	playButton:SetScript("OnLeave", function(self)
		GameTooltip:Hide()
		HideButtonElements(button)
	end)
end

ScrollViewRight:SetElementInitializer("Button", SavedInitializer)
ScrollViewRight:SetElementExtent(36);



-------------------------------------------------------------------------------
-- BROWSER FRAME - Left Scroll Box
-------------------------------------------------------------------------------

local B_SearchBoxLeft = CreateFrame("EditBox", nil, B_SectionLeft, "SearchBoxTemplate")
B_SearchBoxLeft:SetPoint("TOPLEFT", B_SectionLeft, "TOPLEFT", 10, 0)
B_SearchBoxLeft:SetPoint("TOPRIGHT", B_SectionLeft, "TOPRIGHT", -20, 0)
B_SearchBoxLeft:SetHeight(20)
B_SearchBoxLeft:SetAutoFocus(false)

B_ScrollBoxLeft = CreateFrame("Frame", nil, BrowserFrame, "WowScrollBoxList")
B_ScrollBoxLeft:SetPoint("TOPLEFT", B_SectionLeft, "TOPLEFT", 5, -20)
B_ScrollBoxLeft:SetPoint("BOTTOMRIGHT", B_SectionLeft, "BOTTOMRIGHT", -20, 0)
B_ScrollBoxLeft:SetFrameLevel(500)

local B_ScrollBarLeft = CreateFrame("EventFrame", nil, BrowserFrame, "MinimalScrollBar")
B_ScrollBarLeft:SetPoint("TOPLEFT", B_ScrollBoxLeft, "TOPRIGHT", 5, 0)
B_ScrollBarLeft:SetPoint("BOTTOMLEFT", B_ScrollBoxLeft, "BOTTOMRIGHT", 5, 0)

local B_ScrollViewLeft = CreateScrollBoxListLinearView()
ScrollUtil.InitScrollBoxListWithScrollBar(B_ScrollBoxLeft, B_ScrollBarLeft, B_ScrollViewLeft)

-------------------------------------------------------------------------------
-- BROWSER FRAME - Right Scroll Box
-------------------------------------------------------------------------------

local B_SearchBoxRight = CreateFrame("EditBox", nil, B_SectionRight, "SearchBoxTemplate")
B_SearchBoxRight:SetPoint("TOPLEFT", B_SectionRight, "TOPLEFT", 10, 0)
B_SearchBoxRight:SetPoint("TOPRIGHT", B_SectionRight, "TOPRIGHT", -20, 0)
B_SearchBoxRight:SetHeight(20)
B_SearchBoxRight:SetAutoFocus(false)

B_ScrollBoxRight = CreateFrame("Frame", nil, BrowserFrame, "WowScrollBoxList")
B_ScrollBoxRight:SetPoint("TOPLEFT", B_SectionRight, "TOPLEFT", 5, -20)
B_ScrollBoxRight:SetPoint("BOTTOMRIGHT", B_SectionRight, "BOTTOMRIGHT", -20, 0)
B_ScrollBoxRight:SetFrameLevel(500)

local B_ScrollBarRight = CreateFrame("EventFrame", nil, BrowserFrame, "MinimalScrollBar")
B_ScrollBarRight:SetPoint("TOPLEFT", B_ScrollBoxRight, "TOPRIGHT", 5, 0)
B_ScrollBarRight:SetPoint("BOTTOMLEFT", B_ScrollBoxRight, "BOTTOMRIGHT", 5, 0)

local B_ScrollViewRight = CreateScrollBoxListLinearView()
ScrollUtil.InitScrollBoxListWithScrollBar(B_ScrollBoxRight, B_ScrollBarRight, B_ScrollViewRight)

local function BrowserSong_Initializer(button, data)
	local isIgnored = HM.IsSongIgnored(data.file)

	button.tex = button.tex or button:CreateTexture(nil, "BACKGROUND", nil, 0)
	button.tex:SetAllPoints(button)
	button.tex:SetAtlas("ClickCastList-ButtonBackground")

	button.ignoredTex = button.ignoredTex or button:CreateTexture(nil, "ARTWORK", nil, 1)
	button.ignoredTex:SetAllPoints(button)
	button.ignoredTex:SetAtlas("ClickCastList-ButtonHighlight")
	button.ignoredTex:SetVertexColor(1, 0, 0, 1.00)
	button.ignoredTex:SetShown(isIgnored)

	button.texHL = button.texHL or button:CreateTexture(nil, "OVERLAY", nil, 3)
	button.texHL:SetAllPoints(button)
	button.texHL:SetAtlas("ClickCastList-ButtonHighlight")
	button.texHL:SetVertexColor(0.42, 0.54, 1.00, 1.00)
	button.texHL:Hide()

	button.text = button.text or button:CreateFontString(nil, "OVERLAY")
	button.text:SetFontObject("GameTooltipTextSmall")
	button.text:SetPoint("TOPLEFT", button, "TOPLEFT", 15, 0)
	button.text:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -10, 0)
	button.text:SetJustifyH("LEFT")
	button.text:SetTextColor(1, 1, 1)
	
	button.text:SetText(data.name)

	button.selectedTex = button.selectedTex or button:CreateTexture(nil, "ARTWORK", nil, 2)
	button.selectedTex:SetAllPoints(button)
	button.selectedTex:SetAtlas("ReportList-ButtonSelect")
	button.selectedTex:SetShown(selectedFileID == data.file)

	button:RegisterForClicks("LeftButtonUp", "RightButtonUp")
	button:SetScript("OnClick", function(self, btn)
		if btn == "RightButton" then
			OpenSongContextMenu(self, data)
		else
			selectedFileID = data.file
			PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
			UpdateSelectionHighlights()
		end
	end)

	local playButton = button.playButton
	if not playButton then
		playButton = CreateFrame("Button", nil, button)
		playButton:SetSize(20, 20)
		playButton:SetPoint("RIGHT", button, "RIGHT", -10, 0)
		playButton:SetNormalAtlas("common-dropdown-icon-play")
		playButton:SetHighlightAtlas("common-dropdown-icon-play")
		playButton:GetHighlightTexture():SetAlpha(0.5)
		button.playButton = playButton
	end
	
	playButton:Hide()

	playButton:SetScript("OnClick", function()
		if HM.PlaySpecificMusic then
			local cachedContext = nil
			
			if selectedBrowserKey then
				local locKey, senderName = selectedBrowserKey:match("^(.+)_([^_]+)$")
				if locKey and senderName then
					cachedContext = {
						locationKey = locKey,
						senderName = senderName
					}
				end
			end
			
			HM.PlaySpecificMusic(data.file, cachedContext)
		end
	end)

	local function HideButtonElements(self)
		if self:IsMouseOver() then
			self.texHL:Show()
			self.playButton:Show()
		else
			self.texHL:Hide()
			GameTooltip:Hide()
			self.playButton:Hide()
		end
	end

	button:SetScript("OnEnter", function(self)
		HideButtonElements(self)

		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:AddLine(data.name, 1, 1, 1)
		
		if data.duration then
			 GameTooltip:AddLine(FormatDuration(data.duration), 0.8, 0.8, 0.8)
		end

		if isIgnored then
			GameTooltip:AddLine(L["SongIsMuted"], 0.83, 0.00, 0.00)
		end
		
		if data.names and #data.names > 1 then
			GameTooltip:AddLine(" ")
			GameTooltip:AddLine(L["AlternateNames"], 0.8, 0.8, 0.8)
			
			for i = 2, #data.names do
				GameTooltip:AddLine(data.names[i], 0.7, 0.7, 0.7)
			end
		end

		GameTooltip:Show()
	end)
	
	button:SetScript("OnLeave", function(self)
		HideButtonElements(self)
		GameTooltip:Hide()
	end)
	
	playButton:SetScript("OnEnter", function(self)
		HideButtonElements(button)
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:AddLine(L["PreviewSong"], 1, 1, 1)
		GameTooltip:Show()
	end)

	playButton:SetScript("OnLeave", function(self)
		HideButtonElements(button)
	end)
end

B_ScrollViewRight:SetElementInitializer("Button", BrowserSong_Initializer)
B_ScrollViewRight:SetElementExtent(36);

local rawBrowserSongs = {}
local rawBrowserPlaylists = {}

local function FilterBrowserPlaylists()
	local text = B_SearchBoxLeft:GetText() or ""
	local query = CleanString(text)
	local matches = {}

	for _, pl in ipairs(rawBrowserPlaylists) do
		if query == "" then
			table.insert(matches, pl)
		else
			if CleanString(pl.sender):find(query, 1, true) or CleanString(pl.houseName):find(query, 1, true) then
				table.insert(matches, pl)
			end
		end
	end

	local dataProvider = CreateDataProvider(matches)
	B_ScrollBoxLeft:SetDataProvider(dataProvider)
end

local function FilterBrowserSongs()
	local text = B_SearchBoxRight:GetText() or ""
	local query = CleanString(text)
	local matches = {}

	for _, song in ipairs(rawBrowserSongs) do
		if query == "" then
			table.insert(matches, song)
		else
			if CheckMatch(song, query) then
				table.insert(matches, song)
			end
		end
	end
	
	local dataProvider = CreateDataProvider(matches)
	if B_ScrollBoxRight then
		B_ScrollBoxRight:SetDataProvider(dataProvider)
	end
end

local function UpdateBrowserSongs(locationKey, senderName)
	rawBrowserSongs = {}
	if HM_CachedMusic_DB and HM_CachedMusic_DB[locationKey] and HM_CachedMusic_DB[locationKey][senderName] then
		for fileID, _ in pairs(HM_CachedMusic_DB[locationKey][senderName]) do
			local info = LRPM:GetMusicInfoByID(fileID)
			if info then
				local display = {
					file = fileID,
					names = info.names,
					name = info.names and info.names[1] or tostring(fileID),
					duration = info.duration
				}
				table.insert(rawBrowserSongs, display)
			end
		end
	end
	
	table.sort(rawBrowserSongs, function(a,b) return a.name < b.name end)
	FilterBrowserSongs()
end


function RefreshBrowserPlaylists()
	rawBrowserPlaylists = {}
	
	if HM_CachedMusic_DB then
		for locKey, senders in pairs(HM_CachedMusic_DB) do
			for senderName, songs in pairs(senders) do
				local count = 0
				for _ in pairs(songs) do count = count + 1 end
				
				local houseName = ""
				local isFav = false

				if HM_CachedMusic_Metadata and HM_CachedMusic_Metadata[locKey] and HM_CachedMusic_Metadata[locKey][senderName] then
					local meta = HM_CachedMusic_Metadata[locKey][senderName]
					houseName = meta.houseName or ""
					isFav = meta.isFavorite or false
				end

				table.insert(rawBrowserPlaylists, {
					locationKey = locKey,
					sender = senderName,
					count = count,
					houseName = houseName,
					isFavorite = isFav
				})
			end
		end
	end
	
	table.sort(rawBrowserPlaylists, function(a, b) 
		if a.isFavorite ~= b.isFavorite then
			return a.isFavorite
		end
		return a.sender < b.sender 
	end)
	
	FilterBrowserPlaylists() 
end

local function BrowserPlaylist_Initializer(button, data)
	button.tex = button.tex or button:CreateTexture(nil, "BACKGROUND", nil, 0)
	button.tex:SetAllPoints(button)
	button.tex:SetAtlas("ClickCastList-ButtonBackground")

	if not button.favButton then
		button.favButton = CreateFrame("Button", nil, button)
		button.favButton:SetSize(20, 20)
		button.favButton:SetPoint("LEFT", button, "LEFT", 5, 0)
		
		button.favButton:SetHighlightTexture(favtex) 
		button.favButton:GetHighlightTexture():SetAlpha(0.5)
	end

	if data.isFavorite then
		button.favButton:SetNormalTexture(favtex)
	else
		button.favButton:SetNormalTexture(nofavtex)
	end

	button.favButton:SetScript("OnClick", function()
		local newStatus = not data.isFavorite
		HM.SetCachedPlaylistFavorite(data.locationKey, data.sender, newStatus)
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
		RefreshBrowserPlaylists()
	end)


	button.texHL = button.texHL or button:CreateTexture(nil, "OVERLAY", nil, 3)
	button.texHL:SetAllPoints(button)
	button.texHL:SetAtlas("ClickCastList-ButtonHighlight")
	button.texHL:SetVertexColor(0.42, 0.54, 1.00, 1.00)
	button.texHL:Hide()

	button.selectedTex = button.selectedTex or button:CreateTexture(nil, "ARTWORK", nil, 2)
	button.selectedTex:SetAllPoints(button)
	button.selectedTex:SetAtlas("ReportList-ButtonSelect")
	
	local compositeKey = data.locationKey .. "_" .. data.sender
	button.selectedTex:SetShown(selectedBrowserKey == compositeKey)

	button.text = button.text or button:CreateFontString(nil, "OVERLAY")
	button.text:SetFontObject("GameTooltipTextSmall")
	button.text:SetPoint("LEFT", 30, 0)
	button.text:SetPoint("RIGHT", -10, 0)
	button.text:SetJustifyH("LEFT")
	button.text:SetTextColor(1, 1, 1)

	local displayLoc = ""
	if data.houseName and data.houseName ~= "" and data.houseName ~= L["Unknown"] then
		displayLoc = WrapTextInColorCode(data.houseName, "ffdac9a6")
	else
		local locationParts = { strsplit("_", data.locationKey) }
		local plotID = locationParts[#locationParts] or ""
		if plotID ~= "" then displayLoc = " [#ID" .. plotID .. "]" end
	end

	local splitName
	if data.sender then
		splitName = string.split("-",data.sender)
	end
	
	button.text:SetText(splitName .. " - " .. displayLoc .. " (" .. data.count .. ")")

	button:RegisterForClicks("LeftButtonUp", "RightButtonUp")
	button:SetScript("OnClick", function(self, btn)
		if btn == "RightButton" then
			MenuUtil.CreateContextMenu(self, function(owner, rootDescription)
				rootDescription:CreateTitle(data.sender)
				
				rootDescription:CreateButton(L["Mute"], function()
					HM.IgnorePlayer(data.sender)
					
					if HM_CachedMusic_DB then
						for k, v in pairs(HM_CachedMusic_DB) do
							if v[data.sender] then
								v[data.sender] = nil
							end
						end
					end
					
					RefreshBrowserPlaylists()
				end)
			end)
		else
			selectedBrowserKey = compositeKey
			PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
			UpdateSelectionHighlights()
			UpdateBrowserSongs(data.locationKey, data.sender)
		end
	end)
	
	button:SetScript("OnEnter", function(self)
		button.tex:SetAlpha(1)
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		
		if data.isFavorite then
			 GameTooltip:AddLine(L["Favorite"], 1, 0.8, 0)
		end

		GameTooltip:AddLine(data.sender, 1, 1, 1, true)
		GameTooltip:AddLine(displayLoc, 0.8, 0.8, 0.8, true)
		GameTooltip:AddLine(string.format(L["AmountSongs"], data.count), 0.8, 0.8, 0.8, true)

		
		GameTooltip:Show()
	end)
	button:SetScript("OnLeave", function()
		button.tex:SetAlpha(1)
		GameTooltip:Hide()
	end)
end

B_ScrollViewLeft:SetElementInitializer("Button", BrowserPlaylist_Initializer)
B_ScrollViewLeft:SetElementExtent(36);


B_SearchBoxRight:HookScript("OnTextChanged", function(self)
	self.t = 0;
	self:SetScript("OnUpdate", function(self, elapsed)
		self.t = self.t + elapsed;
		if self.t >= 0.2 then
			self.t = 0;
			self:SetScript("OnUpdate", nil);
			FilterBrowserSongs();
		end
	end);
end);


B_SearchBoxLeft:HookScript("OnTextChanged", function(self)
	self.t = 0;
	self:SetScript("OnUpdate", function(self, elapsed)
		self.t = self.t + elapsed;
		if self.t >= 0.2 then
			self.t = 0;
			self:SetScript("OnUpdate", nil);
			FilterBrowserPlaylists();
		end
	end);
end);

-------------------------------------------------------------------------------
-- MAIN FRAME - Update Music
-------------------------------------------------------------------------------

function UpdateSavedMusicList()
	local canEdit = IsEditingAllowed()
	local currentOwner = L["Unknown"]
	
	if C_Housing and C_Housing.GetCurrentHouseInfo then
		local info = C_Housing.GetCurrentHouseInfo()
		if info and info.ownerName then
			currentOwner = info.ownerName
		end
	end

	fullSavedList = {}
	local activeList = {}

	if canEdit then
		if MainFrame.favButton then MainFrame.favButton:Hide() end
		PlaylistDropdown:SetEnabled(true)
		
		activeList = HM.GetActivePlaylistTable()
		local songCount = 0
		if not activeList then return end
		for _ in pairs(activeList) do
			songCount = songCount + 1
		end
		
		local playlistName = HM.GetActivePlaylistName() or L["Default"]
		PlaylistDropdown.Text:SetText(string.format("(%d/%d) %s", songCount, HM.MAX_PLAYLIST_SIZE or 50, playlistName))
		
		if HousingMusic_DB then
			activeList = HM.GetActivePlaylistTable()
		end
	else
		PlaylistDropdown:SetEnabled(true)
		
		local locationKey = GetCurrentLocationKey()
		local selectedSender = nil
		
		if locationKey and HM_CachedMusic_DB and HM_CachedMusic_DB[locationKey] then
			selectedSender = HousingMusic_DB.VisitorPreferences[locationKey]
			
			if not selectedSender or not HM_CachedMusic_DB[locationKey][selectedSender] then
				selectedSender = next(HM_CachedMusic_DB[locationKey])
			end
		end
		if locationKey and selectedSender and MainFrame.favButton then
			MainFrame.favButton:Show()
			
			local isFav = false
			if HM_CachedMusic_Metadata and HM_CachedMusic_Metadata[locationKey] and HM_CachedMusic_Metadata[locationKey][selectedSender] then
				isFav = HM_CachedMusic_Metadata[locationKey][selectedSender].isFavorite
			end

			MainFrame.favButton:SetNormalTexture(isFav and favtex or nofavtex)

			MainFrame.favButton:SetScript("OnEnter", function(self)
				GameTooltip:SetOwner(self, "ANCHOR_TOP")
				GameTooltip:SetText(isFav and L["Unfavorite"] or L["Favorite"])
				GameTooltip:Show()
			end)
			MainFrame.favButton:SetScript("OnLeave", function() GameTooltip:Hide() end)

			MainFrame.favButton:SetScript("OnClick", function()
				local newStatus = not isFav
				
				HM.SetCachedPlaylistFavorite(locationKey, selectedSender, newStatus)
				PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
				
				UpdateSavedMusicList()

				if MainFrame.favButton:IsMouseOver() then
					local onEnter = MainFrame.favButton:GetScript("OnEnter")
					if onEnter then onEnter(MainFrame.favButton) end
				end
				
				if BrowserFrame and BrowserFrame:IsShown() then
					RefreshBrowserPlaylists()
				end
			end)

		else
			if MainFrame.favButton then MainFrame.favButton:Hide() end
		end

		if selectedSender then
			activeList = HM_CachedMusic_DB[locationKey][selectedSender] or {}
			
			local songCount = 0
			for _ in pairs(activeList) do
				songCount = songCount + 1
			end
			
			PlaylistDropdown.Text:SetText(string.format(L["SourceSenderSongCount"], selectedSender, songCount))
		else
			PlaylistDropdown.Text:SetText(L["NoData"])
			activeList = {}
		end
	end

	if PlaylistDropdown.GenerateMenu then
		PlaylistDropdown:GenerateMenu()
	end
	
	for fileID, _ in pairs(activeList) do
		local musicInfo = LRPM:GetMusicInfoByID(fileID)
		
		if musicInfo then
			local safeFile = musicInfo.file or L["Unknown"]

			local primaryName = musicInfo.names and musicInfo.names[1] or (string.format(L["FileID"], safeFile))
			
			local listItem = { 
				name = primaryName, 
				file = musicInfo.file, 
				duration = musicInfo.duration,
				names = musicInfo.names,
			}
			table.insert(fullSavedList, listItem)
		end
	end

	FilterSavedList(SearchBoxRight)
end

HM.UpdateCachedMusicUI = UpdateSavedMusicList

UpdateSavedMusicList()