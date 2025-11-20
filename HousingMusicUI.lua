local _, HM = ...
local LRPM = LibStub:GetLibrary("LibRPMedia-1.2")

if not LRPM then
	return
end

HousingMusic_DB = HousingMusic_DB or {}
HousingMusic_DB.PlayerMusic = HousingMusic_DB.PlayerMusic or {}

local SavedDataProvider
local UpdateSavedMusicList

local SavedScrollView
local currentlyPlayingFile = nil
--local flatMusicList = {} -- trade for FindMusic func in librpmedia
local fullSavedList = {}
local SearchBoxLeft
local SearchBoxRight
local FilterAvailableList
local FilterSavedList
local selectedFileID = nil

local function RefreshUILists()
	if SearchBoxLeft then 
		FilterAvailableList(SearchBoxLeft) 
	end

	if SearchBoxRight then
		UpdateSavedMusicList(SearchBoxRight)
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

local function escapePattern(text)
	return text:gsub("([%(%)%.%%%+%-%*%?%[%]%^%$])", "%%%1")
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

local MainFrame = CreateFrame("Frame", "HousingMusicFrame", UIParent)
MainFrame:SetSize(620, 470)
MainFrame:SetPoint("CENTER")
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

local Footer = CreateFrame("Frame", nil, MainFrame)
Footer:SetPoint("TOPLEFT", Backframe, "BOTTOMLEFT", 0, 0)
Footer:SetPoint("BOTTOMRIGHT", MainFrame, "BOTTOMRIGHT", 0, 0)
MainFrame.Footer = Footer

local ProgressBar = CreateFrame("StatusBar", nil, Footer)
ProgressBar:SetPoint("TOPLEFT", Footer, "BOTTOMLEFT", 40, 18)
ProgressBar:SetPoint("BOTTOMRIGHT", Footer, "BOTTOMRIGHT", -20, 15)
ProgressBar:SetHeight(8)
ProgressBar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
ProgressBar:SetStatusBarColor(1, 0.7, 0)
ProgressBar.bg = ProgressBar:CreateTexture(nil, "BACKGROUND")
ProgressBar.bg:SetAllPoints()
ProgressBar.bg:SetColorTexture(0.2, 0.2, 0.2, 0.5)

local PlayerToggleBtn = CreateFrame("Button", nil, ProgressBar)
PlayerToggleBtn:SetSize(35, 35)
PlayerToggleBtn:SetPoint("RIGHT", ProgressBar, "LEFT", -3, 9)
PlayerToggleBtn:SetNormalAtlas("common-dropdown-icon-play") 
PlayerToggleBtn:SetHighlightAtlas("common-dropdown-icon-play")
PlayerToggleBtn:GetHighlightTexture():SetAlpha(0.5)

local PlayerTitle = ProgressBar:CreateFontString(nil, "OVERLAY", "GameFontNormal")
PlayerTitle:SetPoint("BOTTOMLEFT", ProgressBar, "TOPLEFT", 0, 5)
PlayerTitle:SetJustifyH("LEFT")
PlayerTitle:SetText("No Music Playing")
PlayerTitle:SetTextColor(1, 1, 1)

PlayerToggleBtn:SetScript("OnClick", function()
	local state = HM.GetPlaybackState()
	
	if state.isPlaying then
		HM.StopManualMusic()
		PlayerToggleBtn:SetNormalAtlas("common-dropdown-icon-play")
		PlayerToggleBtn:SetHighlightAtlas("common-dropdown-icon-play")
		PlayerTitle:SetText("No Music Playing")
	else
		if selectedFileID then
			HM.PlaySpecificMusic(selectedFileID)
			PlayerToggleBtn:SetNormalAtlas("common-dropdown-icon-stop")
			PlayerToggleBtn:SetHighlightAtlas("common-dropdown-icon-stop")
			
			local info = LRPM:GetMusicInfoByID(selectedFileID)
			if info then PlayerTitle:SetText(info.names[1] or "Unknown Track") end
		end
	end
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
		
		PlayerTitle:SetText(state.name or "Unknown Track")
		
		PlayerToggleBtn:SetNormalAtlas("common-dropdown-icon-stop")
		PlayerToggleBtn:SetHighlightAtlas("common-dropdown-icon-stop")
	else
		self:SetValue(0)
		TimerText:SetText("0:00 / 0:00")
		PlayerTitle:SetText("No Music Playing")
		
		PlayerToggleBtn:SetNormalAtlas("common-dropdown-icon-play")
		PlayerToggleBtn:SetHighlightAtlas("common-dropdown-icon-play")
	end
end)

local MainframeToggleButton = CreateFrame("Button", nil, UIParent)
MainframeToggleButton:SetPoint("CENTER")
MainframeToggleButton:SetSize(36, 36)
MainframeToggleButton:SetScript("OnClick", function(self, button, down)
	if MainFrame:IsShown() and not down then
		MainFrame:Hide()
	elseif not down then
		MainFrame:Show()
	end
end)
MainframeToggleButton:RegisterForClicks("AnyDown", "AnyUp")
MainframeToggleButton:SetPushedAtlas("keybind-bg_active")
MainframeToggleButton:SetNormalAtlas("keybind-bg")
--MainframeToggleButton:SetVertexColor(.81, .76, .66)
MainframeToggleButton.tex = MainframeToggleButton:CreateTexture(nil, "OVERLAY", nil, 2)
MainframeToggleButton.tex:SetPoint("TOPLEFT",MainframeToggleButton,"TOPLEFT",8,-8)
MainframeToggleButton.tex:SetPoint("BOTTOMRIGHT",MainframeToggleButton,"BOTTOMRIGHT",-8,8)
MainframeToggleButton.tex:SetAtlas("common-icon-sound")
MainframeToggleButton.tex:SetDesaturated(true)
MainframeToggleButton.tex:SetVertexColor(.81, .76, .66)
MainframeToggleButton:SetScript("OnEnter", function()
	--MainframeToggleButton:SetVertexColor(.81, .76, .66)
	MainframeToggleButton.tex:SetVertexColor(1, 1, 1)
end)
MainframeToggleButton:SetScript("OnLeave", function()
	--MainframeToggleButton:SetVertexColor(1, 1, 1)
	MainframeToggleButton.tex:SetVertexColor(.81, .76, .66)
end)
MainframeToggleButton:RegisterEvent("HOUSE_EDITOR_AVAILABILITY_CHANGED")
MainframeToggleButton:RegisterEvent("CURRENT_HOUSE_INFO_RECIEVED")
MainframeToggleButton:RegisterEvent("ZONE_CHANGED_NEW_AREA")
MainframeToggleButton:SetScript("OnEvent", function()
	local HousingFrame = HousingControlsFrame and HousingControlsFrame.OwnerControlFrame and HousingControlsFrame.OwnerControlFrame.InspectorButton
	local isInHouse = C_Housing.IsInsideOwnHouse()
	if HousingFrame and isInHouse then
		MainframeToggleButton:ClearAllPoints()
		MainframeToggleButton:SetPoint("RIGHT", HousingFrame, "LEFT", 0, 0)
		MainframeToggleButton:Show()
		MainFrame:ClearAllPoints()
		MainFrame:SetPoint("TOP", HousingControlsFrame, "BOTTOM", 0, -40)
	else
		MainframeToggleButton:Hide()
		MainFrame:Hide()
	end
end)
MainframeToggleButton:Hide()
local closeButton = CreateFrame("Button", nil, MainFrame, "UIPanelCloseButtonNoScripts");
closeButton:SetPoint("TOPRIGHT", 0, 0);
closeButton:SetScript("OnClick", function()
	if MainFrame then
		MainFrame:Hide();
	end
end);
MainFrame.closeButton = closeButton
MainFrame:Hide()
MainFrame:SetScript("OnShow", function()
	PlaySound(305110)
	UpdateSavedMusicList()
end)
MainFrame:SetScript("OnHide", function()
	PlaySound(305110)
end)

local ScrollBox = CreateFrame("Frame", nil, MainFrame, "WowScrollBoxList")
ScrollBox:SetPoint("TOPLEFT", SectionLeft, "TOPLEFT", 5, -20)
ScrollBox:SetPoint("BOTTOMRIGHT", SectionLeft, "BOTTOMRIGHT", -20, 0)
ScrollBox:SetFrameLevel(500)

local ScrollBar = CreateFrame("EventFrame", nil, MainFrame, "MinimalScrollBar")
ScrollBar:SetPoint("TOPLEFT", ScrollBox, "TOPRIGHT", 5, 0)
ScrollBar:SetPoint("BOTTOMLEFT", ScrollBox, "BOTTOMRIGHT", 5, 0)

local ScrollView = CreateScrollBoxListLinearView() 
ScrollUtil.InitScrollBoxListWithScrollBar(ScrollBox, ScrollBar, ScrollView)

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
				musicInfo.name = musicInfo.matchingName or (musicInfo.names and musicInfo.names[1])
				table.insert(matches, musicInfo)
				addedIDs[musicInfo.file] = true
			end
		end
	end
	
	local musicDataProvider = CreateDataProvider(matches) 
	ScrollView:SetDataProvider(musicDataProvider)
end

-- Generally safer to use HookScript on EditBoxes inheriting a template as they likely already have OnTextChanged callbacks defined
-- As a side note, it may be worth debouncing this callback if your search method is particularly performance intensive
SearchBoxLeft:HookScript("OnTextChanged", SearchBox_OnTextChanged);

local function Initializer(button, musicInfo)
	local text = musicInfo.name or ("File ID: " .. (musicInfo.file or "N/A"))
	
	button.tex = button.tex or button:CreateTexture(nil, "BACKGROUND", nil, 0)
	button.tex:SetAllPoints(button)
	button.tex:SetAtlas("ClickCastList-ButtonBackground")

	button.selectedTex = button.selectedTex or button:CreateTexture(nil, "ARTWORK", nil, 1)
	button.selectedTex:SetAllPoints(button)
	button.selectedTex:SetAtlas("ReportList-ButtonSelect")
	button.selectedTex:SetShown(selectedFileID == musicInfo.file)

	button:SetScript("OnClick", function()
		selectedFileID = musicInfo.file
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
		RefreshUILists()
	end)
	
	button.texHL = button.texHL or button:CreateTexture(nil, "OVERLAY", nil, 3)
	button.texHL:SetAllPoints(button)
	button.texHL:SetAtlas("ClickCastList-ButtonHighlight")
	button.texHL:SetVertexColor(0.42, 0.54, 1.00, 1.00)
	button.texHL:Hide()
	
	button.textFont = button.textFont or button:CreateFontString(nil, "OVERLAY")
	button.textFont:SetFontObject("GameTooltipTextSmall")
	button.textFont:SetPoint("LEFT", button, "LEFT", 15, 0)
	button.textFont:SetPoint("RIGHT", button, "RIGHT", -55, 0)
	button.textFont:SetJustifyH("LEFT")
	button.textFont:SetJustifyV("MIDDLE")
	button.textFont:SetText(text)
	button.textFont:SetTextColor(1, 1, 1, 1)

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
		RefreshUILists()
	end)
	
	addButton:SetScript("OnClick", function()
		if not HousingMusic_DB.PlayerMusic[musicInfo.file] then
			HousingMusic_DB.PlayerMusic[musicInfo.file] = true 
			UpdateSavedMusicList()
			print("|cff00ff00Added:|r " .. musicInfo.name)
			PlaySound(316551)
		else
			print("|cffffcc00Warning:|r Music already saved.")
		end
	end)

	local function HideButtonElements(self)
		if not self.isHovering then
			self.texHL:Hide()
			GameTooltip:Hide()
			self.addButton:Hide()
			self.playButton:Hide()
		end
	end
	
	button:SetScript("OnEnter", function(self)
		self.texHL:Show()
		self.addButton:Show()
		self.playButton:Show()
		self.isHovering = true
		
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:AddLine(musicInfo.name, 1, 1, 1)
		GameTooltip:AddLine("Duration: " .. FormatDuration(musicInfo.duration), 0.8, 0.8, 0.8)
		
		if musicInfo.names and #musicInfo.names > 1 then
			GameTooltip:AddLine(" ")
			GameTooltip:AddLine("Alternate Names:", 0.8, 0.8, 0.8)
			
			for i = 2, #musicInfo.names do
				GameTooltip:AddLine(musicInfo.names[i], 0.7, 0.7, 0.7)
			end
		end
		
		GameTooltip:Show()
	end)
	
	button:SetScript("OnLeave", function(self)
		self.isHovering = nil
		button.texHL:Hide()
		GameTooltip:Hide()
		HideButtonElements(button)
	end)

	addButton:SetScript("OnEnter", function(self)
		button.texHL:Show() 
		button.addButton:Show()
		button.playButton:Show()
		button.isHovering = true
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:AddLine("Add Song to Playlist", 1, 1, 1)
		GameTooltip:Show()
	end)
	addButton:SetScript("OnLeave", function(self)
		button.isHovering = nil
		HideButtonElements(button)
	end)

	playButton:SetScript("OnEnter", function(self)
		button.texHL:Show() 
		button.addButton:Show()
		button.playButton:Show()
		button.isHovering = true
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:AddLine("Preview Song", 1, 1, 1)
		GameTooltip:Show()
	end)
	playButton:SetScript("OnLeave", function(self)
		button.isHovering = nil
		HideButtonElements(button)
	end)
end

ScrollView:SetElementInitializer("Button", Initializer)
ScrollView:SetElementExtent(36);

local SavedScrollBox = CreateFrame("Frame", nil, MainFrame, "WowScrollBoxList")
SavedScrollBox:SetPoint("TOPLEFT", SectionRight, "TOPLEFT", 5, -20)
SavedScrollBox:SetPoint("BOTTOMRIGHT", SectionRight, "BOTTOMRIGHT", -20, 0)
SavedScrollBox:SetFrameLevel(500)

local SavedScrollBar = CreateFrame("EventFrame", nil, MainFrame, "MinimalScrollBar")
SavedScrollBar:SetPoint("TOPLEFT", SavedScrollBox, "TOPRIGHT", 5, 0)
SavedScrollBar:SetPoint("BOTTOMLEFT", SavedScrollBox, "BOTTOMRIGHT", 5, 0)

local SavedScrollView = CreateScrollBoxListLinearView()
ScrollUtil.InitScrollBoxListWithScrollBar(SavedScrollBox, SavedScrollBar, SavedScrollView)

SearchBoxRight = CreateFrame("EditBox", nil, SectionRight, "SearchBoxTemplate")
SearchBoxRight:SetPoint("TOPLEFT", SectionRight, "TOPLEFT", 10, 0)
SearchBoxRight:SetPoint("TOPRIGHT", SectionRight, "TOPRIGHT", -20, 0)
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
				local displayItem = {
					file = musicInfo.file,
					duration = musicInfo.duration,
					names = musicInfo.names,
					name = matchedName
				}
				table.insert(matches, displayItem)
			end
		end
	end
	
	local musicDataProvider = CreateDataProvider(matches)
	SavedScrollView:SetDataProvider(musicDataProvider)
end

-- Generally safer to use HookScript on EditBoxes inheriting a template as they likely already have OnTextChanged callbacks defined
-- As a side note, it may be worth debouncing this callback if your search method is particularly performance intensive
SearchBoxRight:HookScript("OnTextChanged", SearchBox_OnTextChanged);

local function RemoveMusicEntry(musicFile, musicName)
	HousingMusic_DB.PlayerMusic[musicFile] = nil
	UpdateSavedMusicList()
	print("|cffff0000Removed:|r " .. musicName)
end

local function SavedInitializer(button, musicInfo)
	local text = musicInfo.name or ("File ID: " .. (musicInfo.file or "N/A"))

	button.tex = button.tex or button:CreateTexture(nil, "BACKGROUND", nil, 0)
	button.tex:SetAllPoints(button)
	button.tex:SetAtlas("ClickCastList-ButtonBackground")

	button.selectedTex = button.selectedTex or button:CreateTexture(nil, "ARTWORK", nil, 1)
	button.selectedTex:SetAllPoints(button)
	button.selectedTex:SetAtlas("ReportList-ButtonSelect")
	button.selectedTex:SetShown(selectedFileID == musicInfo.file)

	button:SetScript("OnClick", function()
		selectedFileID = musicInfo.file
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
		RefreshUILists()
	end)
	
	button.texHL = button.texHL or button:CreateTexture(nil, "OVERLAY", nil, 3)
	button.texHL:SetAllPoints(button)
	button.texHL:SetAtlas("ClickCastList-ButtonHighlight")
	button.texHL:SetVertexColor(0.42, 0.54, 1.00, 1.00)
	button.texHL:Hide()
	
	button.textFont = button.textFont or button:CreateFontString(nil, "OVERLAY")
	button.textFont:SetFontObject("GameTooltipTextSmall")
	button.textFont:SetPoint("LEFT", button, "LEFT", 15, 0)
	button.textFont:SetPoint("RIGHT", button, "RIGHT", -55, 0)
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
		RefreshUILists()
	end)

	local function HideButtonElements(self)
		if not self.isHovering then
			self.texHL:Hide()
			GameTooltip:Hide()
			self.removeButton:Hide()
			self.playButton:Hide()
		end
	end
	
	removeButton:SetScript("OnClick", function()
		RemoveMusicEntry(musicInfo.file, musicInfo.name)
		PlaySound(316562)
	end)
	
	button:SetScript("OnEnter", function(self)
		self.texHL:Show()
		self.removeButton:Show()
		self.playButton:Show()
		self.isHovering = true
		
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:AddLine(musicInfo.name, 1, 1, 1)
		GameTooltip:AddLine("Duration: " .. FormatDuration(musicInfo.duration), 0.8, 0.8, 0.8)
		
		if musicInfo.names and #musicInfo.names > 1 then
			GameTooltip:AddLine(" ")
			GameTooltip:AddLine("Alternate Names:", 0.8, 0.8, 0.8)
			
			for i = 2, #musicInfo.names do
				GameTooltip:AddLine(musicInfo.names[i], 0.7, 0.7, 0.7)
			end
		end
		
		GameTooltip:Show()
	end)
	
	button:SetScript("OnLeave", function(self)
		self.isHovering = nil
		button.texHL:Hide()
		GameTooltip:Hide()
		HideButtonElements(button)
	end)

	removeButton:SetScript("OnEnter", function(self)
		button.texHL:Show() 
		button.removeButton:Show()
		button.playButton:Show()
		button.isHovering = true
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:AddLine("Remove Song From Playlist", 1, 1, 1)
		GameTooltip:Show()
	end)
	removeButton:SetScript("OnLeave", function(self)
		button.isHovering = nil
		HideButtonElements(button)
	end)

	playButton:SetScript("OnEnter", function(self)
		button.texHL:Show() 
		button.removeButton:Show()
		button.playButton:Show()
		button.isHovering = true
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:AddLine("Preview Song", 1, 1, 1)
		GameTooltip:Show()
	end)
	playButton:SetScript("OnLeave", function(self)
		button.isHovering = nil
		HideButtonElements(button)
	end)
end

SavedScrollView:SetElementInitializer("Button", SavedInitializer)
SavedScrollView:SetElementExtent(36);

function UpdateSavedMusicList()
	
	fullSavedList = {}
	
	for fileID, _ in pairs(HousingMusic_DB.PlayerMusic) do
		local musicInfo = LRPM:GetMusicInfoByID(fileID)
		
		if musicInfo then
			local safeFile = musicInfo.file or "N/A"
			local primaryName = musicInfo.names and musicInfo.names[1] or ("File ID: " .. safeFile)
			
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

FilterAvailableList(SearchBoxLeft)
UpdateSavedMusicList(SearchBoxRight)