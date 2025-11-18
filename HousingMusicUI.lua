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
local flatMusicList = {}
local fullSavedList = {}
local SearchBoxLeft
local SearchBoxRight
local FilterAvailableList
local FilterSavedList

local function FormatDuration(seconds)
    if not seconds or seconds <= 0 then
        return "0:00"
    end
    seconds = math.floor(seconds)
    local minutes = math.floor(seconds / 60)
    local remainingSeconds = math.fmod(seconds, 60)
    return string.format("%d:%02d", minutes, remainingSeconds)
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
local Divider = CreateFrame("Frame", nil, Backframe)
Divider:SetPoint("TOP", Backframe, "TOP", 0, 0);
Divider:SetPoint("BOTTOM", Backframe, "BOTTOM", 0, 0);
Divider:SetWidth(16)
Divider:SetFrameLevel(100)
Divider.tex = Divider:CreateTexture(nil, "BACKGROUND", nil, 1);
Divider.tex:SetAtlas("housing-basic-vertical-divider");
MainFrame.Divider = Divider

local Header = MainFrame:CreateTexture(nil, "BORDER", nil, 2);
Header:SetPoint("TOPLEFT", MainFrame, "TOPLEFT", 0, 0);
Header:SetPoint("BOTTOMRIGHT", Backframe, "TOPRIGHT", 0, 0);
Header:SetAtlas("housing-basic-container-woodheader");
MainFrame.Header = Header
--local Footer = MainFrame:CreateTexture(nil, "BORDER", nil, 2); -- idk if i like this look
--Footer:SetPoint("TOPLEFT", SectionLeft, "BOTTOMLEFT", 0, 0);
--Footer:SetPoint("BOTTOMRIGHT", Backframe, "BOTTOMRIGHT", 0, 0);
--Footer:SetAtlas("housing-basic-container-woodheader");
--MainFrame.Footer = Footer

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

SearchBoxLeft = CreateFrame("EditBox", nil, SectionLeft, "SearchBoxTemplate")
SearchBoxLeft:SetPoint("TOPLEFT", SectionLeft, "TOPLEFT", 10, 0)
SearchBoxLeft:SetPoint("TOPRIGHT", SectionLeft, "TOPRIGHT", -20, 0)
SearchBoxLeft:SetHeight(20)
SearchBoxLeft:SetAutoFocus(false)
SearchBoxLeft:SetScript("OnTextChanged", FilterAvailableList)

local ScrollBox = CreateFrame("Frame", nil, MainFrame, "WowScrollBoxList")
ScrollBox:SetPoint("TOPLEFT", SectionLeft, "TOPLEFT", 5, -20)
ScrollBox:SetPoint("BOTTOMRIGHT", SectionLeft, "BOTTOMRIGHT", -20, 0)
ScrollBox:SetFrameLevel(500)

local ScrollBar = CreateFrame("EventFrame", nil, MainFrame, "MinimalScrollBar")
ScrollBar:SetPoint("TOPLEFT", ScrollBox, "TOPRIGHT", 5, 0)
ScrollBar:SetPoint("BOTTOMLEFT", ScrollBox, "BOTTOMRIGHT", 5, 0)

local ScrollView = CreateScrollBoxListLinearView() 
ScrollUtil.InitScrollBoxListWithScrollBar(ScrollBox, ScrollBar, ScrollView)

local function escapePattern(text)
	return text:gsub("([%(%)%.%%%+%-%*%?%[%]%^%$])", "%%%1")
end

function FilterAvailableList(editBox)
	print(editBox)
	local query = editBox:GetText()
	query = escapePattern(query)
	
	local matches = {}
	for _, musicInfo in ipairs(flatMusicList) do
		if musicInfo.name and string.find(musicInfo.name:lower(), query:lower()) then
			table.insert(matches, musicInfo)
		end
	end
	
	local musicDataProvider = CreateDataProvider(matches) 
	ScrollView:SetDataProvider(musicDataProvider)
end

local function Initializer(button, musicInfo)
	local text = musicInfo.name or ("File ID: " .. (musicInfo.file or "N/A"))
	
	button.tex = button.tex or button:CreateTexture(nil, "BACKGROUND", nil, 0)
	button.tex:SetAllPoints(button)
	button.tex:SetAtlas("PetList-ButtonBackground")
	
	button.texHL = button.texHL or button:CreateTexture(nil, "OVERLAY", nil, 3)
	button.texHL:SetAllPoints(button)
	button.texHL:SetAtlas("PetList-ButtonHighlight")
	button.texHL:Hide()
	
	button.textFont = button.textFont or button:CreateFontString(nil, "OVERLAY")
	button.textFont:SetFontObject("GameTooltipTextSmall")
	button.textFont:SetPoint("LEFT", button, "LEFT", 5, 0)
	button.textFont:SetJustifyH("LEFT")
	button.textFont:SetJustifyV("MIDDLE")
	button.textFont:SetText(text)
	button.textFont:SetTextColor(1, 1, 1, 1)
	
	local playButton = button.playButton
	if not playButton then
		playButton = CreateFrame("Button", nil, button)
		playButton:SetSize(15, 15)
		playButton:SetPoint("RIGHT", button, "RIGHT", -5, 0)
		
		playButton.icon = playButton:CreateTexture(nil, "ARTWORK")
		playButton.icon:SetAllPoints()
		
		playButton.hl = playButton:CreateTexture(nil, "HIGHLIGHT")
		playButton.hl:SetAtlas("UI-Common-MouseHOver")
		playButton.hl:SetAllPoints()
		playButton.hl:SetAlpha(0.7)
		
		button.playButton = playButton
	end
	
	if currentlyPlayingFile == musicInfo.file then
		playButton.icon:SetAtlas("common-dropdown-icon-stop")
	else
		playButton.icon:SetAtlas("common-dropdown-icon-play")
	end
	
	playButton:SetScript("OnClick", function()
		local wasPlayingThis = (currentlyPlayingFile == musicInfo.file)
		StopMusic()
		
		if wasPlayingThis then
			currentlyPlayingFile = nil
		else
			LRPM:PlayMusic(musicInfo.file)
			currentlyPlayingFile = musicInfo.file
		end
	end)
	playButton:SetScript("OnMouseUp", function(self, mouseButtonName)
		if mouseButtonName == "RightButton" then 
			StopMusic()
			currentlyPlayingFile = nil
		end
	end)
	playButton:Show()
	
	local addButton = button.addButton
	if not addButton then
		addButton = CreateFrame("Button", nil, button)
		addButton:SetSize(15, 15)
		addButton:SetPoint("RIGHT", playButton, "LEFT", -2, 0)
		
		addButton.icon = addButton:CreateTexture(nil, "ARTWORK")
		addButton.icon:SetAllPoints()
		addButton.icon:SetAtlas("common-icon-plus")

		addButton.hl = addButton:CreateTexture(nil, "HIGHLIGHT")
		addButton.hl:SetAtlas("UI-Common-MouseHOver")
		addButton.hl:SetAllPoints()
		addButton.hl:SetAlpha(0.7)

		button.addButton = addButton
	end
	
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
	addButton:Show()
	
	button:SetScript("OnEnter", function(self)
		button.texHL:Show()
		
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
	
	button:SetScript("OnLeave", function()
		button.texHL:Hide()
		GameTooltip:Hide()
	end)
end

ScrollView:SetElementInitializer("Button", Initializer)
ScrollView:SetElementExtent(36);
SearchBoxRight = CreateFrame("EditBox", nil, SectionRight, "SearchBoxTemplate")
SearchBoxRight:SetPoint("TOPLEFT", SectionRight, "TOPLEFT", 10, 0)
SearchBoxRight:SetPoint("TOPRIGHT", SectionRight, "TOPRIGHT", -20, 0)
SearchBoxRight:SetHeight(20)
SearchBoxRight:SetAutoFocus(false)
SearchBoxRight:SetScript("OnTextChanged", FilterSavedList)

local SavedScrollBox = CreateFrame("Frame", nil, MainFrame, "WowScrollBoxList")
SavedScrollBox:SetPoint("TOPLEFT", SectionRight, "TOPLEFT", 5, -20)
SavedScrollBox:SetPoint("BOTTOMRIGHT", SectionRight, "BOTTOMRIGHT", -20, 0)
SavedScrollBox:SetFrameLevel(500)

local SavedScrollBar = CreateFrame("EventFrame", nil, MainFrame, "MinimalScrollBar")
SavedScrollBar:SetPoint("TOPLEFT", SavedScrollBox, "TOPRIGHT", 5, 0)
SavedScrollBar:SetPoint("BOTTOMLEFT", SavedScrollBox, "BOTTOMRIGHT", 5, 0)

local SavedScrollView = CreateScrollBoxListLinearView()
ScrollUtil.InitScrollBoxListWithScrollBar(SavedScrollBox, SavedScrollBar, SavedScrollView)

function FilterSavedList(editBox)
	local query = editBox:GetText()
	query = escapePattern(query)
	
	local matches = {}
	for _, musicInfo in ipairs(fullSavedList) do
		if musicInfo.name and string.find(musicInfo.name:lower(), query:lower()) then
			table.insert(matches, musicInfo)
		end
	end
	
	SavedDataProvider = CreateDataProvider(matches) 
	SavedScrollView:SetDataProvider(SavedDataProvider)
end

local function RemoveMusicEntry(musicFile, musicName)
	HousingMusic_DB.PlayerMusic[musicFile] = nil
	UpdateSavedMusicList()
	print("|cffff0000Removed:|r " .. musicName)
end

local function SavedInitializer(button, musicInfo)
	local text = musicInfo.name or ("File ID: " .. (musicInfo.file or "N/A"))

	button.tex = button.tex or button:CreateTexture(nil, "BACKGROUND", nil, 0)
	button.tex:SetAllPoints(button)
	button.tex:SetAtlas("PetList-ButtonBackground")
	
	button.texHL = button.texHL or button:CreateTexture(nil, "OVERLAY", nil, 3)
	button.texHL:SetAllPoints(button)
	button.texHL:SetAtlas("PetList-ButtonHighlight")
	button.texHL:Hide()
	
	button.textFont = button.textFont or button:CreateFontString(nil, "OVERLAY")
	button.textFont:SetFontObject("GameTooltipTextSmall")
	button.textFont:SetPoint("LEFT", button, "LEFT", 5, 0)
	button.textFont:SetJustifyH("LEFT")
	button.textFont:SetJustifyV("MIDDLE")
	button.textFont:SetText(text)
	button.textFont:SetTextColor(1, 1, 1, 1)

	local playButton = button.playButton
	if not playButton then
		playButton = CreateFrame("Button", nil, button)
		playButton:SetSize(15, 15)
		playButton:SetPoint("RIGHT", button, "RIGHT", -5, 0)
		
		playButton.icon = playButton:CreateTexture(nil, "ARTWORK")
		playButton.icon:SetAllPoints()
		
		playButton.hl = playButton:CreateTexture(nil, "HIGHLIGHT")
		playButton.hl:SetAtlas("UI-Common-MouseHOver")
		playButton.hl:SetAllPoints()
		playButton.hl:SetAlpha(0.7)
		
		button.playButton = playButton
	end
	
	if currentlyPlayingFile == musicInfo.file then
		playButton.icon:SetAtlas("common-dropdown-icon-stop")
	else
		playButton.icon:SetAtlas("common-dropdown-icon-play")
	end

	playButton:SetScript("OnClick", function()
		local wasPlayingThis = (currentlyPlayingFile == musicInfo.file)
		StopMusic()
		
		if wasPlayingThis then
			currentlyPlayingFile = nil
		else
			LRPM:PlayMusic(musicInfo.file)
			currentlyPlayingFile = musicInfo.file
		end
		
	end)
	playButton:SetScript("OnMouseUp", function(self, mouseButtonName)
		if mouseButtonName == "RightButton" then 
			StopMusic()
			currentlyPlayingFile = nil
		end
	end)
	playButton:Show()
	
	local removeButton = button.removeButton
	if not removeButton then
		removeButton = CreateFrame("Button", nil, button)
		removeButton:SetSize(15, 15)
		removeButton:SetPoint("RIGHT", playButton, "LEFT", -5, 0)
		
		removeButton.icon = removeButton:CreateTexture(nil, "ARTWORK")
		removeButton.icon:SetAllPoints()
		removeButton.icon:SetAtlas("common-icon-minus")
		
		removeButton.hl = removeButton:CreateTexture(nil, "HIGHLIGHT")
		removeButton.hl:SetAtlas("UI-Common-MouseHOver")
		removeButton.hl:SetAllPoints()
		removeButton.hl:SetAlpha(0.7)
		
		button.removeButton = removeButton
	end
	
	removeButton:SetScript("OnClick", function()
		RemoveMusicEntry(musicInfo.file, musicInfo.name)
		PlaySound(316562)
	end)
	removeButton:Show()
	
	button:SetScript("OnEnter", function(self)
		button.texHL:Show()
		
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
	
	button:SetScript("OnLeave", function()
		button.texHL:Hide()
		GameTooltip:Hide()
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

--local flatMusicList = {}
for _, musicResult in LRPM:EnumerateMusic() do 
	local safeFile = musicResult.file or "N/A"
	local primaryName = musicResult.names and musicResult.names[1] or ("File ID: " .. safeFile)
	
	local musicInfo = { 
		name = primaryName, 
		file = musicResult.file, 
		duration = musicResult.duration,
		names = musicResult.names,
	}
	table.insert(flatMusicList, musicInfo)
end

FilterAvailableList(SearchBoxLeft)
UpdateSavedMusicList()