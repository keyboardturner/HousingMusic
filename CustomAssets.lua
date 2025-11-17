local _, HM = ...

local PLACEHOLDER = 1

local customMusic = {
	[1] = {
		name = "Hearthstone - Journal",
		path = "Interface\\AddOns\\HousingMusic\\Assets\\Music\\Hearthstone\\Journal.mp3",
		duration = 121,
	},
	[2] = {
		name = "Hearthstone - Battlegrounds",
		path = "Interface\\AddOns\\HousingMusic\\Assets\\Music\\Hearthstone\\Battlegrounds.mp3",
		duration = 126,
	},
	[3] = {
		name = "Hearthstone - Better Hand",
		path = "Interface\\AddOns\\HousingMusic\\Assets\\Music\\Hearthstone\\Better Hand.mp3",
		duration = 234,
	},
	[4] = {
		name = "Hearthstone - Collection Manager",
		path = "Interface\\AddOns\\HousingMusic\\Assets\\Music\\Hearthstone\\Collection Manager.mp3",
		duration = 190,
	},
	[5] = {
		name = "Hearthstone - Duel",
		path = "Interface\\AddOns\\HousingMusic\\Assets\\Music\\Hearthstone\\Duel.mp3",
		duration = 191,
	},
	[6] = {
		name = "Hearthstone - Duels",
		path = "Interface\\AddOns\\HousingMusic\\Assets\\Music\\Hearthstone\\Duels.mp3",
		duration = 100,
	},
	[7] = {
		name = "Hearthstone - Main Title",
		path = "Interface\\AddOns\\HousingMusic\\Assets\\Music\\Hearthstone\\Main_Title.mp3",
		duration = 135,
	},
	[8] = {
		name = "Hearthstone - Main Title Solo",
		path = "Interface\\AddOns\\HousingMusic\\Assets\\Music\\Hearthstone\\Main_Title_Solo.mp3",
		duration = 87,
	},
	[9] = {
		name = "Hearthstone - Mulligan A",
		path = "Interface\\AddOns\\HousingMusic\\Assets\\Music\\Hearthstone\\Mulligan A.mp3",
		duration = 30,
	},
	[10] = {
		name = "Hearthstone - Mulligan B",
		path = "Interface\\AddOns\\HousingMusic\\Assets\\Music\\Hearthstone\\Mulligan B.mp3",
		duration = 30,
	},
	[11] = {
		name = "Hearthstone - Mulligan C",
		path = "Interface\\AddOns\\HousingMusic\\Assets\\Music\\Hearthstone\\Mulligan C.mp3",
		duration = 35,
	},
	[12] = {
		name = "Hearthstone - Mulligan",
		path = "Interface\\AddOns\\HousingMusic\\Assets\\Music\\Hearthstone\\Mulligan.mp3",
		duration = 42,
	},
	[13] = {
		name = "Hearthstone - On a Roll",
		path = "Interface\\AddOns\\HousingMusic\\Assets\\Music\\Hearthstone\\On a Roll.mp3",
		duration = 243,
	},
	[14] = {
		name = "Hearthstone - Tavern Brawl",
		path = "Interface\\AddOns\\HousingMusic\\Assets\\Music\\Hearthstone\\Tavern_Brawl.mp3",
		duration = 90,
	},
	[15] = {
		name = "Hearthstone - Victory",
		path = "Interface\\AddOns\\HousingMusic\\Assets\\Music\\Hearthstone\\Victory.mp3",
		duration = 42,
	},
};

HM.customMusic = customMusic