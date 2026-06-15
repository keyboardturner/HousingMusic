local _, HM = ...

local PLACEHOLDER = 1

local AmbienceData = {


    {
        name = "AhnQirajCthunStomach",
        path = 539135,
        duration = 60.000,
    },
    {
        name = "AhnQirajExteriorA",
        path = 539099,
        duration = 60.000,
    },
    {
        name = "AmaniPassDay",
        path = 594393,
        duration = 60.000,
    },
    {
        name = "AmaniPassNight",
        path = 594468,
        duration = 60.000,
    },
    {
        name = "AmanvaleDay",
        path = 594414,
        duration = 60.000,
    },
    {
        name = "AmanvalenNight",
        path = 594405,
        duration = 60.000,
    },
    --[[
    {
        name = "amb_12eversonglightbloomathran_7291387",
        path = 7291387,
        duration = 84.940,
    },
    {
        name = "amb_12eversonglightbloomathran_7291389",
        path = 7291389,
        duration = 90.562,
    },
    {
        name = "amb_12eversonglightbloomathran_7291391",
        path = 7291391,
        duration = 90.249,
    },
    {
        name = "amb_12eversonglightbloomathran_7291393",
        path = 7291393,
        duration = 90.562,
    },
    {
        name = "amb_12eversonglightbloomathran_7291395",
        path = 7291395,
        duration = 96.495,
    },
    {
        name = "amb_12eversonglightbloomathran_7295918",
        path = 7295918,
        duration = 109.732,
    },
    ]]
    {
        name = "amb_80_zulnazman_underrot_01",
        path = 1890855,
        duration = 115.424,
    },
    {
        name = "AMB_Arakkoa_Dungeon",
        path = 982837,
        duration = 64.644,
    },
    {
        name = "amb_ardenweald_3500703",
        path = 3500703,
        duration = 77.049,
    },
    {
        name = "AMB_ArgusRaid_ShivanTemple_Varimathras",
        path = 1707631,
        duration = 109.603,
    },
    {
        name = "AMB_Argus_Base",
        path = 1674976,
        duration = 114.853,
    },
    {
        name = "AMB_Argus_LegionManufactory",
        path = 1684121,
        duration = 116.092,
    },
    {
        name = "AMB_Argus_MacAree",
        path = 1674977,
        duration = 100.913,
    },
    {
        name = "AMB_Argus_PetrifiedForest",
        path = 1675117,
        duration = 116.891,
    },
    {
        name = "AMB_Argus_Raid_Exterior",
        path = 1678284,
        duration = 114.045,
    },
    {
        name = "AMB_ASHRAN_BASE_DAY",
        path = 1050965,
        duration = 150.000,
    },
    {
        name = "AMB_ASHRAN_BASE_NIGHT",
        path = 1050966,
        duration = 150.000,
    },
    {
        name = "AMB_Auchindoun_Dungeon_WAD_Base",
        path = 1001863,
        duration = 107.775,
    },
    {
        name = "AMB_Azshara_BlackmawHold_INT",
        path = 539022,
        duration = 87.969,
    },
    {
        name = "AMB_Azshara_TempleOfZinMalor_INT",
        path = 539136,
        duration = 59.628,
    },
    {
        name = "AMB_Azsuna_Day_Base",
        path = 1246791,
        duration = 119.711,
    },
    {
        name = "AMB_Azsuna_Lagoon_Day_Base",
        path = 1360723,
        duration = 119.958,
    },
    {
        name = "AMB_Azsuna_Lagoon_Night_Base",
        path = 1361043,
        duration = 119.979,
    },
    {
        name = "AMB_Azsuna_Night_Base",
        path = 1259918,
        duration = 120.021,
    },
    {
        name = "amb_babylonzone_3190862",
        path = 3190862,
        duration = 147.971,
    },
    {
        name = "amb_babylonzone_3190863",
        path = 3190863,
        duration = 125.361,
    },
    {
        name = "amb_bastiontempleofcourageoutskirts_3493746",
        path = 3493746,
        duration = 88.000,
    },
    {
        name = "AMB_BlackrockCaverns",
        path = 539129,
        duration = 85.036,
    },
    {
        name = "AMB_Blackrock_TrainDepot_Base",
        path = 968465,
        duration = 90.000,
    },
    {
        name = "AMB_BlackwingDescentLava_01",
        path = 539043,
        duration = 91.566,
    },
    {
        name = "AMB_BlackwingDescent_02",
        path = 539000,
        duration = 103.084,
    },
    {
        name = "amb_boralus_city_day_02",
        path = 1853185,
        duration = 115.478,
    },
    {
        name = "amb_boralus_city_night_01",
        path = 1853186,
        duration = 116.088,
    },
    {
        name = "amb_boralus_harbor_01",
        path = 1838478,
        duration = 116.008,
    },
    {
        name = "AMB_BrokenIsles_Coastal_Day",
        path = 1362407,
        duration = 120.001,
    },
    {
        name = "AMB_BrokenIsles_Coastal_Night",
        path = 1363070,
        duration = 120.001,
    },
    {
        name = "AMB_BrokenShore_Base",
        path = 1247840,
        duration = 119.770,
    },
    {
        name = "AMB_BurningLegion_Base_01",
        path = 1250795,
        duration = 118.860,
    },
    {
        name = "AMB_ChamberofIncineration",
        path = 539138,
        duration = 89.315,
    },
    {
        name = "AMB_CityBilgewaterHarbor_Day01",
        path = 539091,
        duration = 94.995,
    },
    {
        name = "AMB_CityBilgewaterHarbor_Night01",
        path = 539040,
        duration = 95.000,
    },
    {
        name = "AMB_CityGilneas_Day01",
        path = 539090,
        duration = 117.207,
    },
    {
        name = "AMB_CityGilneas_Night01",
        path = 539046,
        duration = 117.398,
    },
    {
        name = "amb_cityofgold_ext_base_day",
        path = 1724073,
        duration = 130.144,
    },
    {
        name = "AMB_CityofOrgrimmarGoblinSlums_Day03",
        path = 539032,
        duration = 171.274,
    },
    {
        name = "AMB_CityofOrgrimmarGoblinSlums_Night03",
        path = 539008,
        duration = 171.906,
    },
    {
        name = "AMB_CityofOrgrimmarValleyofHonor_Day04",
        path = 539020,
        duration = 129.210,
    },
    {
        name = "AMB_CityofOrgrimmarValleyofHonor_Night02",
        path = 539086,
        duration = 127.488,
    },
    {
        name = "AMB_CityofOrgrimmarValleyofSpirits_Day03",
        path = 539082,
        duration = 126.526,
    },
    {
        name = "AMB_CityofOrgrimmarValleyofSpirits_Night01",
        path = 539014,
        duration = 126.742,
    },
    {
        name = "AMB_CityofOrgrimmarValleyofStrength_Day03",
        path = 539035,
        duration = 130.482,
    },
    {
        name = "AMB_CityofOrgrimmarValleyofStrength_Day05",
        path = 539109,
        duration = 125.567,
    },
    {
        name = "AMB_CityofOrgrimmarValleyofStrength_Night02",
        path = 539057,
        duration = 126.902,
    },
    {
        name = "AMB_CityofOrgrimmarValleyofWisdom_Day03",
        path = 539130,
        duration = 120.560,
    },
    {
        name = "AMB_CityofOrgrimmarValleyofWisdom_Night01",
        path = 539105,
        duration = 131.708,
    },
    {
        name = "AMB_CityOrgrimmarCleftofShadows_01",
        path = 539063,
        duration = 137.670,
    },
    {
        name = "AMB_CoastalBarren_Day01",
        path = 539110,
        duration = 60.000,
    },
    {
        name = "AMB_CoastalBarren_Night01",
        path = 539140,
        duration = 60.000,
    },
    {
        name = "AMB_CoastalGrasslands_Day01",
        path = 539104,
        duration = 90.000,
    },
    {
        name = "AMB_CoastalGrasslands_Night01",
        path = 539083,
        duration = 90.000,
    },
    {
        name = "AMB_CoastalNormal_Day02",
        path = 539016,
        duration = 91.634,
    },
    {
        name = "AMB_CoastalNormal_Night01",
        path = 538995,
        duration = 91.634,
    },
    {
        name = "AMB_CoastalRainy_Day01",
        path = 539075,
        duration = 105.828,
    },
    {
        name = "AMB_CoastalRainy_Night01",
        path = 539116,
        duration = 99.484,
    },
    {
        name = "AMB_CoastalStormy_Day01",
        path = 539066,
        duration = 90.000,
    },
    {
        name = "AMB_CoastalStormy_Night01",
        path = 539101,
        duration = 90.000,
    },
    {
        name = "AMB_CrystalMine_Loop",
        path = 944722,
        duration = 118.515,
    },
    {
        name = "AMB_CT_EndTime",
        path = 594543,
        duration = 61.115,
    },
    {
        name = "AMB_DeathwebHollow_Day",
        path = 940614,
        duration = 97.402,
    },
    {
        name = "AMB_DeathwebHollow_Night",
        path = 940616,
        duration = 96.659,
    },
    {
        name = "AMB_Deepholm_02",
        path = 539088,
        duration = 85.000,
    },
    {
        name = "AMB_DEPOT_TRAINCAR_EXT",
        path = 1000902,
        duration = 50.000,
    },
    {
        name = "AMB_DEPOT_TRAINCAR_INT",
        path = 1000903,
        duration = 60.000,
    },
    {
        name = "AMB_DesertEnchanted_Day03",
        path = 538998,
        duration = 90.000,
    },
    {
        name = "AMB_DesertEnchanted_Night02",
        path = 539069,
        duration = 90.000,
    },
    {
        name = "AMB_DesertHighFlooded_NIGHT01",
        path = 539087,
        duration = 90.000,
    },
    {
        name = "AMB_DesertHigh_Day05",
        path = 539127,
        duration = 90.000,
    },
    {
        name = "AMB_DesertHigh_Night03",
        path = 539080,
        duration = 90.000,
    },
    {
        name = "AMB_DH_Character_Selection_Wasteland",
        path = 1305294,
        duration = 118.860,
    },
    {
        name = "AMB_Draenei_Interior_General_Loop",
        path = 942752,
        duration = 71.612,
    },
    {
        name = "AMB_Draenei_LargeInterior_Loop",
        path = 946399,
        duration = 69.690,
    },
    {
        name = "AMB_DraenorOceanUnderwaterGlobal_Loop",
        path = 982352,
        duration = 114.094,
    },
    {
        name = "Amb_DreadWastes_AmberSolar_Loop",
        path = 612365,
        duration = 106.000,
    },
    {
        name = "AMB_DreadWastes_Base",
        path = 605323,
        duration = 119.461,
    },
    {
        name = "amb_drustvar_clearing_day",
        path = 1724738,
        duration = 125.486,
    },
    {
        name = "amb_drustvar_clearing_day02",
        path = 1729538,
        duration = 128.509,
    },
    {
        name = "amb_drustvar_clearing_night",
        path = 1724739,
        duration = 138.934,
    },
    {
        name = "amb_drustvar_clearing_night02",
        path = 1729539,
        duration = 126.149,
    },
    {
        name = "amb_drustvar_crimsonforest",
        path = 1935153,
        duration = 139.558,
    },
    {
        name = "amb_drustvar_forest_day",
        path = 1724740,
        duration = 137.054,
    },
    {
        name = "amb_drustvar_forest_day02",
        path = 1729540,
        duration = 125.398,
    },
    {
        name = "amb_drustvar_forest_night",
        path = 1724741,
        duration = 130.566,
    },
    {
        name = "amb_drustvar_forest_night02",
        path = 1729541,
        duration = 127.354,
    },
    {
        name = "amb_ephemeralplains_4392101",
        path = 4392101,
        duration = 119.995,
    },
    {
        name = "amb_eternalwatch_4392103",
        path = 4392103,
        duration = 120.011,
    },
    {
        name = "AMB_Fel_Jailor_Cage_Ambience_Loop_01",
        path = 1579904,
        duration = 102.081,
    },
    {
        name = "AMB_Firelands",
        path = 539050,
        duration = 60.000,
    },
    {
        name = "AMB_FirelandsLavaCavernsInterior",
        path = 539113,
        duration = 60.000,
    },
    {
        name = "AMB_FirelandsMoltenFields",
        path = 594579,
        duration = 60.000,
    },
    {
        name = "AMB_FirelandsSpiderCanyons",
        path = 594495,
        duration = 60.000,
    },
    {
        name = "AMB_FirelandsSulfuronKeepInterior",
        path = 594582,
        duration = 60.000,
    },
    {
        name = "AMB_FirelandsWindy",
        path = 594459,
        duration = 60.000,
    },
    {
        name = "AMB_ForestBlackwald",
        path = 539062,
        duration = 138.989,
    },
    {
        name = "AMB_ForestCleansed_Day04",
        path = 539126,
        duration = 84.940,
    },
    {
        name = "AMB_ForestCleansed_Night02",
        path = 539005,
        duration = 82.931,
    },
    {
        name = "AMB_ForestDryLakeMennar_DAY01",
        path = 539117,
        duration = 82.193,
    },
    {
        name = "AMB_ForestDryLakeMennar_NIGHT01",
        path = 539027,
        duration = 82.193,
    },
    {
        name = "AMB_ForestDryRavencrest_DAY01",
        path = 539072,
        duration = 60.000,
    },
    {
        name = "AMB_ForestDryRavencrest_NIGHT01",
        path = 539081,
        duration = 60.000,
    },
    {
        name = "AMB_ForestDryRuinsOfEldarath_DAY01",
        path = 539053,
        duration = 59.628,
    },
    {
        name = "AMB_ForestDryRuinsOfEldarath_NIGHT01",
        path = 539120,
        duration = 59.628,
    },
    {
        name = "AMB_ForestDry_Day03",
        path = 538991,
        duration = 91.351,
    },
    {
        name = "AMB_ForestDry_Night02",
        path = 539093,
        duration = 91.327,
    },
    {
        name = "AMB_ForestPlagued_Day03",
        path = 539042,
        duration = 90.000,
    },
    {
        name = "AMB_ForestPlagued_Night02",
        path = 539049,
        duration = 90.000,
    },
    {
        name = "AMB_ForestRainy_Day01",
        path = 539107,
        duration = 105.251,
    },
    {
        name = "AMB_ForestRainy_Night02",
        path = 539068,
        duration = 99.763,
    },
    {
        name = "AMB_ForestStormyEerie_Day01",
        path = 538992,
        duration = 90.000,
    },
    {
        name = "AMB_ForestStormyEerie_Night01",
        path = 539051,
        duration = 90.000,
    },
    {
        name = "AMB_ForestStormyHeavy_Day02",
        path = 539085,
        duration = 90.000,
    },
    {
        name = "AMB_ForestStormyHeavy_Night01",
        path = 539106,
        duration = 90.000,
    },
    {
        name = "AMB_ForestStormy_DAY03",
        path = 539100,
        duration = 90.000,
    },
    {
        name = "AMB_ForestStormy_Night01",
        path = 539134,
        duration = 90.000,
    },
    {
        name = "AMB_ForestWet_Day04",
        path = 539060,
        duration = 83.071,
    },
    {
        name = "AMB_ForestWet_Night03",
        path = 539017,
        duration = 83.336,
    },
    {
        name = "AMB_FrostFire_BoneTown_Int_base_loop",
        path = 919025,
        duration = 118.422,
    },
    {
        name = "AMB_FrostFire_Cave_loop",
        path = 921246,
        duration = 122.601,
    },
    {
        name = "AMB_FrostFire_Heavy_Wind_base_loop",
        path = 918050,
        duration = 110.713,
    },
    {
        name = "AMB_FrostFire_LightSheltered_Med_Wind_loop",
        path = 918052,
        duration = 107.741,
    },
    {
        name = "AMB_FrostFire_Valleys_Wind_loop",
        path = 918054,
        duration = 102.539,
    },
    {
        name = "AMB_Gorgrond_Base",
        path = 944962,
        duration = 110.000,
    },
    {
        name = "AMB_Gorgrond_Base_Night",
        path = 1045702,
        duration = 110.000,
    },
    {
        name = "AMB_Gorgrond_Jungle_Day",
        path = 1001941,
        duration = 70.000,
    },
    {
        name = "AMB_GrasslandsDryBattlescar_DAY01",
        path = 539137,
        duration = 90.000,
    },
    {
        name = "AMB_GrasslandsDryBattlescar_NIGHT01",
        path = 538997,
        duration = 90.000,
    },
    {
        name = "AMB_GrasslandsDry_Day01",
        path = 539059,
        duration = 90.000,
    },
    {
        name = "AMB_GrasslandsDry_Night01",
        path = 539021,
        duration = 90.000,
    },
    {
        name = "amb_grazinghills_3500702",
        path = 3500702,
        duration = 77.049,
    },
    {
        name = "AMB_GreatWallDungeon_ClosedInterior_Loop",
        path = 608339,
        duration = 60.000,
    },
    {
        name = "AMB_GreatWallDungeon_OpenInterior_Loop",
        path = 608341,
        duration = 60.000,
    },
    {
        name = "AMB_GrimBatol_Day05",
        path = 539037,
        duration = 87.947,
    },
    {
        name = "AMB_HallofAwakening",
        path = 539030,
        duration = 110.687,
    },
    {
        name = "AMB_HallsOfOrigination_02",
        path = 539054,
        duration = 85.000,
    },
    {
        name = "AMB_Helheim_Boat_Base_Interior",
        path = 1347126,
        duration = 114.453,
    },
    {
        name = "AMB_Hellheim_Boat_Base",
        path = 1267617,
        duration = 119.979,
    },
    {
        name = "amb_hewnkoboldcatacombs_5872164",
        path = 5872164,
        duration = 54.500,
    },
    {
        name = "amb_hewnkoboldcatacombs_5872166",
        path = 5872166,
        duration = 54.500,
    },
    {
        name = "amb_hewnkoboldcatacombs_5873715",
        path = 5873715,
        duration = 60.750,
    },
    {
        name = "AMB_Highmountain_Day_Base",
        path = 1247251,
        duration = 120.000,
    },
    {
        name = "AMB_Highmountain_Day_Base_LowAltitude",
        path = 1338499,
        duration = 120.000,
    },
    {
        name = "AMB_Highmountain_Night_Base",
        path = 1260828,
        duration = 120.000,
    },
    {
        name = "AMB_Highmountain_Night_Base_LowAltitude",
        path = 1339682,
        duration = 120.011,
    },
    {
        name = "amb_houseoftaam_3493747",
        path = 3493747,
        duration = 90.000,
    },
    {
        name = "amb_immortalhearth_4392105",
        path = 4392105,
        duration = 119.997,
    },
    {
        name = "AMB_IndustrialDocks_Day01",
        path = 539025,
        duration = 146.209,
    },
    {
        name = "AMB_IndustrialDrillingPlatform_Day01",
        path = 539036,
        duration = 90.000,
    },
    {
        name = "AMB_IndustrialDrillingPlatform_Night01",
        path = 539018,
        duration = 90.000,
    },
    {
        name = "AMB_IndustrialMining_Day01",
        path = 539112,
        duration = 72.464,
    },
    {
        name = "AMB_IndustrialMining_Night01",
        path = 539124,
        duration = 72.464,
    },
    {
        name = "AMB_JadeForest_Base_Day01",
        path = 591674,
        duration = 137.000,
    },
    {
        name = "AMB_JadeForest_Base_Night01",
        path = 591680,
        duration = 114.334,
    },
    {
        name = "AMB_JadeForest_SerpentSpine_Day01",
        path = 591676,
        duration = 60.000,
    },
    {
        name = "AMB_JadeTemple_EastTemple_Loop",
        path = 608343,
        duration = 105.000,
    },
    {
        name = "Amb_JadeTemple_East_MainHall_Loop",
        path = 609826,
        duration = 90.000,
    },
    {
        name = "Amb_JadeTemple_Library_Loop",
        path = 610177,
        duration = 60.000,
    },
    {
        name = "Amb_JadeTemple_MeditationChamber_Loop",
        path = 610884,
        duration = 90.000,
    },
    {
        name = "AMB_JF_Coastal",
        path = 621867,
        duration = 60.000,
    },
    {
        name = "AMB_JungleOasis_Day01",
        path = 539132,
        duration = 90.000,
    },
    {
        name = "AMB_JungleOasis_Night01",
        path = 539067,
        duration = 90.000,
    },
    {
        name = "AMB_KezanChaos_Day01",
        path = 539038,
        duration = 94.995,
    },
    {
        name = "AMB_KezanChaos_Night01",
        path = 539065,
        duration = 95.000,
    },
    {
        name = "AMB_KL_Inkgill_Mere",
        path = 621869,
        duration = 56.187,
    },
    {
        name = "AMB_KL_Zouchin_Province",
        path = 621871,
        duration = 60.536,
    },
    {
        name = "amb_korthiavault_4060187",
        path = 4060187,
        duration = 120.003,
    },
    {
        name = "amb_korthia_4060185",
        path = 4060185,
        duration = 120.001,
    },
    {
        name = "AMB_KrasarangWilds_Base_Day01",
        path = 591721,
        duration = 105.598,
    },
    {
        name = "AMB_KrasarangWilds_Base_Night01",
        path = 591723,
        duration = 121.567,
    },
    {
        name = "amb_kultiras_waningglacier_day_night",
        path = 1888895,
        duration = 125.755,
    },
    {
        name = "AMB_KunlaiSummit_Base_Day01",
        path = 591725,
        duration = 111.797,
    },
    {
        name = "AMB_KunlaiSummit_Base_Night01",
        path = 591727,
        duration = 113.767,
    },
    {
        name = "AMB_KunlaiSummit_Monkaris",
        path = 593383,
        duration = 114.490,
    },
    {
        name = "AMB_KunlaiSummit_Mountains_Base",
        path = 593385,
        duration = 60.000,
    },
    {
        name = "AMB_KunlaiSummit_Shadopan_Base",
        path = 593387,
        duration = 59.999,
    },
    {
        name = "AMB_KunLaiSummit_Valley_Day01",
        path = 593936,
        duration = 60.000,
    },
    {
        name = "AMB_KunLaiSummit_Valley_Night01",
        path = 593938,
        duration = 60.000,
    },
    {
        name = "AMB_LEGION_CONTAGION_BASE",
        path = 1339482,
        duration = 119.871,
    },
    {
        name = "AMB_Legion_Interior_Base_01",
        path = 1268738,
        duration = 104.296,
    },
    {
        name = "AMB_Legion_Swamp_Base",
        path = 1342058,
        duration = 119.377,
    },
    {
        name = "AMB_LEYLINE_BASE",
        path = 1332508,
        duration = 109.639,
    },
    {
        name = "AMB_LostCityOfTheTolvir_Day02",
        path = 539044,
        duration = 85.000,
    },
    {
        name = "AMB_LostCityOfTheTolvir_Night01",
        path = 539007,
        duration = 85.000,
    },
    {
        name = "AMB_Maelstrom",
        path = 539052,
        duration = 85.000,
    },
    {
        name = "amb_malabominationhouse_3493749",
        path = 3493749,
        duration = 90.000,
    },
    {
        name = "amb_maldraxxuslibrary_3493748",
        path = 3493748,
        duration = 90.000,
    },
    {
        name = "amb_maldraxxus_3489393",
        path = 3489393,
        duration = 88.000,
    },
    {
        name = "amb_manaforgeomega_6726558",
        path = 6726558,
        duration = 50.100,
    },
    {
        name = "amb_manaforgeomega_6726560",
        path = 6726560,
        duration = 48.133,
    },
    {
        name = "AMB_MantidDungeon_MainChamber_Loop",
        path = 608515,
        duration = 105.000,
    },
    {
        name = "AMB_MantidDungeon_NarrowTunnel_Loop",
        path = 608517,
        duration = 105.000,
    },
    {
        name = "Amb_MantidRaid_HeartOfFear_LL_Loop",
        path = 611410,
        duration = 80.000,
    },
    {
        name = "amb_mawmaxlevel_3561137",
        path = 3561137,
        duration = 83.131,
    },
    {
        name = "amb_mawmaxlevel_3812893",
        path = 3812893,
        duration = 90.000,
    },
    {
        name = "Amb_Mogudungeon_Intensity1_Loop",
        path = 612377,
        duration = 105.000,
    },
    {
        name = "Amb_Mogudungeon_Intensity3_Loop",
        path = 612381,
        duration = 105.000,
    },
    {
        name = "Amb_MoguRaid_Interior_Loop",
        path = 614029,
        duration = 105.000,
    },
    {
        name = "AMB_Nagrand_Canyon_Day_Loop",
        path = 973341,
        duration = 96.494,
    },
    {
        name = "AMB_Nagrand_Day_General_Loop",
        path = 948412,
        duration = 108.632,
    },
    {
        name = "AMB_Nagrand_Night_General_Loop",
        path = 948414,
        duration = 124.411,
    },
    {
        name = "AMB_Nagrand_Wetlands_Day_Loop",
        path = 973343,
        duration = 131.896,
    },
    {
        name = "AMB_Nagrand_Wetlands_Night_Loop",
        path = 973345,
        duration = 125.827,
    },
    {
        name = "amb_nazjatar_loop_base_day_sky",
        path = 2982859,
        duration = 116.000,
    },
    {
        name = "amb_nazjatar_loop_base_night_sky",
        path = 2982860,
        duration = 108.715,
    },
    {
        name = "amb_nazmir_beachnearswamp_day",
        path = 1943357,
        duration = 115.778,
    },
    {
        name = "amb_nazmir_beachnearswamp_night",
        path = 1943375,
        duration = 105.016,
    },
    {
        name = "amb_nazmir_marsh_base_day",
        path = 1725826,
        duration = 121.357,
    },
    {
        name = "amb_nazmir_marsh_night",
        path = 1758244,
        duration = 150.336,
    },
    {
        name = "amb_nazmir_necropolis_base",
        path = 1725215,
        duration = 139.117,
    },
    {
        name = "amb_nazmir_necropolis_int",
        path = 1725216,
        duration = 138.955,
    },
    {
        name = "amb_nazmir_swamp_day",
        path = 1723327,
        duration = 134.710,
    },
    {
        name = "amb_nazmir_swamp_night",
        path = 1723328,
        duration = 143.263,
    },
    {
        name = "amb_niffinhub_5142337",
        path = 5142337,
        duration = 97.093,
    },
    {
        name = "Amb_OGRaid_GarroshCompound_Base",
        path = 894564,
        duration = 122.197,
    },
    {
        name = "AMB_OGRaid_OrgrimmarOutside_Base",
        path = 895783,
        duration = 119.072,
    },
    {
        name = "AMB_OGRaid_Orgrimmar_City_Int_Loop",
        path = 895786,
        duration = 117.764,
    },
    {
        name = "amb_oribos_3571655",
        path = 3571655,
        duration = 120.938,
    },
    {
        name = "AMB_PA_BambooForest",
        path = 570794,
        duration = 60.000,
    },
    {
        name = "amb_phproveyourworthstormapproaches_6938989",
        path = 6938989,
        duration = 51.938,
    },
    {
        name = "AMB_PlainsRainy_Day01",
        path = 539064,
        duration = 104.821,
    },
    {
        name = "AMB_PlainsRainy_Night01",
        path = 539026,
        duration = 106.925,
    },
    {
        name = "amb_primalisttomorow_4695824",
        path = 4695824,
        duration = 46.000,
    },
    {
        name = "AMB_ScaroftheWorldbreaker",
        path = 539102,
        duration = 93.086,
    },
    {
        name = "AMB_SeatOfTheTriumvirate",
        path = 1678283,
        duration = 140.421,
    },
    {
        name = "amb_sepulcherofthefirstones_4317714",
        path = 4317714,
        duration = 56.684,
    },
    {
        name = "AMB_ShadoPanDungeon_Interior_Loop",
        path = 614031,
        duration = 90.000,
    },
    {
        name = "AMB_ShadowmoonDungeon_Base",
        path = 972584,
        duration = 105.140,
    },
    {
        name = "AMB_ShadowmoonIronHordeBattle_Loop",
        path = 930539,
        duration = 113.285,
    },
    {
        name = "AMB_Shadowmoon_BlademoonBloom_Loop",
        path = 1014589,
        duration = 81.120,
    },
    {
        name = "AMB_ShadowMoon_Plains_Loop",
        path = 917981,
        duration = 92.246,
    },
    {
        name = "AMB_ShadowMoon_StandingStones_Loop",
        path = 917983,
        duration = 79.704,
    },
    {
        name = "AMB_ShadowMoon_Swampy_Loop",
        path = 917985,
        duration = 81.525,
    },
    {
        name = "AMB_ShadowMoon_ThickForestArea_Loop",
        path = 917987,
        duration = 76.063,
    },
    {
        name = "AMB_SilithusWound_Base_Day_01",
        path = 1725888,
        duration = 56.935,
    },
    {
        name = "AMB_SilithusWound_Base_Night_01",
        path = 1725889,
        duration = 56.842,
    },
    {
        name = "AMB_Skywall_02",
        path = 539119,
        duration = 85.000,
    },
    {
        name = "AMB_Spires_Base_Day_Loop",
        path = 942965,
        duration = 151.308,
    },
    {
        name = "AMB_Spires_Base_Night_Loop",
        path = 942967,
        duration = 124.721,
    },
    {
        name = "AMB_Stormheim_Day_Base",
        path = 1245654,
        duration = 119.999,
    },
    {
        name = "AMB_Stormheim_Forest_Day",
        path = 1357934,
        duration = 120.001,
    },
    {
        name = "AMB_Stormheim_Forest_Night_Base",
        path = 1360203,
        duration = 120.025,
    },
    {
        name = "AMB_Stormheim_Night_Base",
        path = 1260587,
        duration = 120.026,
    },
    {
        name = "amb_stormsongvalley_day",
        path = 1849036,
        duration = 117.963,
    },
    {
        name = "amb_stormsongvalley_night",
        path = 1849037,
        duration = 115.875,
    },
    {
        name = "amb_stormsongvalley_quilboar_area_day",
        path = 1939518,
        duration = 117.737,
    },
    {
        name = "AMB_StormstoutBrewery_FoyerInterior_Loop",
        path = 608347,
        duration = 105.000,
    },
    {
        name = "AMB_StormstoutBrewery_MainHallInterior_Loop",
        path = 608349,
        duration = 105.000,
    },
    {
        name = "Amb_StormStoutBrewery_WheelhouseFloor1_Interior_Loop",
        path = 610179,
        duration = 90.000,
    },
    {
        name = "Amb_StormStoutBrewery_WheelhouseFloor2_Interior_Loop",
        path = 610181,
        duration = 86.000,
    },
    {
        name = "Amb_STVMine_LavaPoolArea_Loop",
        path = 614033,
        duration = 60.000,
    },
    {
        name = "Amb_STVMine_MainAmb_Loop",
        path = 614035,
        duration = 100.000,
    },
    {
        name = "Amb_STVMine_WaterPoolArea_Loop",
        path = 614037,
        duration = 60.000,
    },
    {
        name = "AMB_Suramar_City_Night",
        path = 1452932,
        duration = 120.001,
    },
    {
        name = "AMB_Suramar_Forest_Day",
        path = 1350008,
        duration = 120.511,
    },
    {
        name = "AMB_Suramar_Forest_Night",
        path = 1354734,
        duration = 119.913,
    },
    {
        name = "AMB_Suramar_Moonguard_Day",
        path = 1352522,
        duration = 119.985,
    },
    {
        name = "AMB_Suramar_Moonguard_Night",
        path = 1356864,
        duration = 120.014,
    },
    {
        name = "Amb_Talador_Base_Day",
        path = 940610,
        duration = 95.915,
    },
    {
        name = "Amb_Talador_Base_Night",
        path = 940612,
        duration = 98.081,
    },
    {
        name = "AMB_TanaanJungle_62_Base",
        path = 1115883,
        duration = 99.527,
    },
    {
        name = "AMB_TanaanJungle_Day",
        path = 937204,
        duration = 89.663,
    },
    {
        name = "AMB_TanaanJungle_Night",
        path = 937206,
        duration = 80.062,
    },
    {
        name = "amb_thecataractriver_5660260",
        path = 5660260,
        duration = 48.000,
    },
    {
        name = "amb_theendmire_3557821",
        path = 3557821,
        duration = 80.000,
    },
    {
        name = "amb_theforbiddenreach_4521366",
        path = 4521366,
        duration = 96.614,
    },
    {
        name = "amb_thegranddesign_4392099",
        path = 4392099,
        duration = 119.760,
    },
    {
        name = "amb_thejailersarmory_3747983",
        path = 3747983,
        duration = 72.000,
    },
    {
        name = "amb_thejailersarmory_3752556",
        path = 3752556,
        duration = 90.000,
    },
    {
        name = "amb_thejailersarmory_3755937",
        path = 3755937,
        duration = 95.115,
    },
    {
        name = "amb_thepulsingpit_day_5850089",
        path = 5850089,
        duration = 46.000,
    },
    {
        name = "amb_thepulsingpit_day_5850098",
        path = 5850098,
        duration = 55.000,
    },
    {
        name = "AMB_ThroneoftheTides_Day04",
        path = 539002,
        duration = 90.000,
    },
    {
        name = "AMB_Thunderisle_Graveyard_Crypt",
        path = 795737,
        duration = 58.197,
    },
    {
        name = "AMB_ThunderKingIsland_Base",
        path = 794813,
        duration = 184.661,
    },
    {
        name = "AMB_Thunderkingisle_Swamp",
        path = 795739,
        duration = 102.573,
    },
    {
        name = "amb_tiragardesound_day",
        path = 1724074,
        duration = 141.811,
    },
    {
        name = "AMB_TKRaid_Sewers",
        path = 798129,
        duration = 89.999,
    },
    {
        name = "AMB_TKRaid_Subterranean",
        path = 796984,
        duration = 90.000,
    },
    {
        name = "AMB_TKRaid_ThunderKingRoom",
        path = 796986,
        duration = 80.000,
    },
    {
        name = "AMB_Townlong_Steppes_Base",
        path = 605325,
        duration = 118.027,
    },
    {
        name = "AMB_TwilightForge",
        path = 539010,
        duration = 85.001,
    },
    {
        name = "amb_umbralbazaarcityofthreadsdungeon_5706674",
        path = 5706674,
        duration = 58.000,
    },
    {
        name = "AMB_UniBreezy_Day01",
        path = 539095,
        duration = 94.000,
    },
    {
        name = "AMB_UniBreezy_Night01",
        path = 539004,
        duration = 94.000,
    },
    {
        name = "AMB_ValeofEternalBlossoms_Base_Day01",
        path = 603473,
        duration = 124.889,
    },
    {
        name = "AMB_ValeofEternalBlossoms_Base_Night01",
        path = 603475,
        duration = 115.000,
    },
    {
        name = "AMB_Valhallas_Base",
        path = 1273426,
        duration = 120.008,
    },
    {
        name = "AMB_Valleyofthefourwinds_Base_Day01",
        path = 591729,
        duration = 101.956,
    },
    {
        name = "AMB_Valleyofthefourwinds_Base_Night01",
        path = 591731,
        duration = 113.920,
    },
    {
        name = "AMB_ValSharah_DayTime_Base_01",
        path = 1250632,
        duration = 67.025,
    },
    {
        name = "AMB_ValSharah_MildCorruption_Base_01",
        path = 1466399,
        duration = 61.549,
    },
    {
        name = "AMB_ValSharah_NightTime_Base_01",
        path = 1250633,
        duration = 103.053,
    },
    {
        name = "AMB_Vashjir_02",
        path = 539012,
        duration = 90.000,
    },
    {
        name = "Amb_VaultWardens_Creepy_01",
        path = 1267616,
        duration = 146.752,
    },
    {
        name = "AMB_VFW_Paoquan_Hollow_Base",
        path = 603575,
        duration = 114.953,
    },
    {
        name = "AMB_VFW_Springroad",
        path = 621873,
        duration = 58.000,
    },
    {
        name = "AMB_VoidElfZone_01",
        path = 1841374,
        duration = 101.368,
    },
    {
        name = "amb_voldun_desert_day",
        path = 1822949,
        duration = 119.401,
    },
    {
        name = "amb_voldun_desert_night",
        path = 1822950,
        duration = 117.574,
    },
    {
        name = "AMB_VS_Nightmare_Base",
        path = 1282880,
        duration = 122.586,
    },
    {
        name = "AMB_WALLA_ALLIANCE_TAVERN_MEDIUM",
        path = 1575952,
        duration = 55.267,
    },
    {
        name = "AMB_WALLA_HORDE_ALLIANCE_TAVERN_MEDIUM",
        path = 1575953,
        duration = 50.167,
    },
    {
        name = "AMB_WALLA_HORDE_TAVERN_MEDIUM",
        path = 1575954,
        duration = 51.905,
    },
    {
        name = "AMB_WanderingIsle_Base_Day01",
        path = 604735,
        duration = 115.466,
    },
    {
        name = "AMB_WastelandHauntedHeavy_Day04",
        path = 539078,
        duration = 79.319,
    },
    {
        name = "AMB_WastelandHauntedHeavy_Night03",
        path = 539139,
        duration = 94.449,
    },
    {
        name = "AMB_WastelandNormal_Day02",
        path = 539029,
        duration = 118.885,
    },
    {
        name = "AMB_WastelandNormal_Night02",
        path = 539079,
        duration = 138.554,
    },
    {
        name = "AMB_Wasteland_Scorched_Day02",
        path = 539070,
        duration = 120.000,
    },
    {
        name = "AMB_Wasteland_Scorched_Night03",
        path = 539096,
        duration = 119.997,
    },
    {
        name = "amb_webwarrensnerubiancrypt_5706676",
        path = 5706676,
        duration = 52.000,
    },
    {
        name = "amb_webwarrensnerubiancrypt_5706680",
        path = 5706680,
        duration = 48.000,
    },
    {
        name = "AMB_WI_CentralTemple",
        path = 621875,
        duration = 60.000,
    },
    {
        name = "AMB_WI_TheRows_Base",
        path = 603577,
        duration = 60.000,
    },
    {
        name = "AMB_WI_TheSingingPools_Base",
        path = 603689,
        duration = 60.000,
    },
    {
        name = "AMB_WoodsEerie_Day03",
        path = 539111,
        duration = 90.000,
    },
    {
        name = "AMB_WoodsEerie_Night03",
        path = 539089,
        duration = 90.000,
    },
    {
        name = "amb_zandalar_beachjungle_day_01",
        path = 1827835,
        duration = 114.679,
    },
    {
        name = "amb_zandalar_beachjungle_night_01",
        path = 1827836,
        duration = 119.085,
    },
    {
        name = "amb_zandalar_junglelite_day_01",
        path = 1827837,
        duration = 112.411,
    },
    {
        name = "amb_zandalar_junglelite_night_01",
        path = 1827838,
        duration = 116.887,
    },
    {
        name = "amb_zandalar_jungle_base_day",
        path = 1724071,
        duration = 127.021,
    },
    {
        name = "amb_zandalar_jungle_base_night",
        path = 1724072,
        duration = 125.484,
    },
    {
        name = "AmmenValeCrashSiteDay",
        path = 594585,
        duration = 60.000,
    },
    {
        name = "AmmenValeCrashSiteNight",
        path = 594411,
        duration = 60.000,
    },
    {
        name = "ArgentArena",
        path = 539039,
        duration = 65.952,
    },
    {
        name = "ArgentDawn_UnderArea",
        path = 594420,
        duration = 113.799,
    },
    {
        name = "AzurebreezeCoastDay",
        path = 594546,
        duration = 60.000,
    },
    {
        name = "AzurebreezeCoastNight",
        path = 594513,
        duration = 59.985,
    },
    {
        name = "BeachDay",
        path = 539048,
        duration = 56.842,
    },
    {
        name = "BeachNight",
        path = 539125,
        duration = 56.935,
    },
    {
        name = "BlackMorass",
        path = 594531,
        duration = 79.000,
    },
    {
        name = "BladesEdgeForest",
        path = 594390,
        duration = 144.000,
    },
    {
        name = "BladesEdgeGlobal",
        path = 539094,
        duration = 110.000,
    },
    {
        name = "BladesEdgeSylvanaar",
        path = 594588,
        duration = 144.000,
    },
    {
        name = "BloodMystDay",
        path = 594576,
        duration = 68.000,
    },
    {
        name = "BloodMystNight",
        path = 594525,
        duration = 69.000,
    },
    {
        name = "BoneWastes1",
        path = 594399,
        duration = 71.000,
    },
    {
        name = "BoreanTundraGeneralDay",
        path = 594432,
        duration = 90.000,
    },
    {
        name = "BoreanTundraGeneralNight",
        path = 594477,
        duration = 80.000,
    },
    {
        name = "CanyonDesertDay",
        path = 539024,
        duration = 56.471,
    },
    {
        name = "CanyonDesertNight",
        path = 539061,
        duration = 56.471,
    },
    {
        name = "ColdaraNightDay",
        path = 594591,
        duration = 110.356,
    },
    {
        name = "CrystalSongForestDayNight",
        path = 594384,
        duration = 111.403,
    },
    {
        name = "DalaranCityDay",
        path = 594573,
        duration = 89.284,
    },
    {
        name = "DalaranCityNight",
        path = 594369,
        duration = 116.979,
    },
    {
        name = "DarkPortal",
        path = 539011,
        duration = 59.443,
    },
    {
        name = "DeadMines",
        path = 539071,
        duration = 56.935,
    },
    {
        name = "DeadWindPassDay",
        path = 539031,
        duration = 46.904,
    },
    {
        name = "DeadWindPassNight",
        path = 539003,
        duration = 47.601,
    },
    {
        name = "DragonblightEmeraldDragonshrine",
        path = 594342,
        duration = 106.717,
    },
    {
        name = "DragonBlightGeneralDay",
        path = 594441,
        duration = 120.000,
    },
    {
        name = "DragonBlightGeneralNight",
        path = 594522,
        duration = 115.448,
    },
    {
        name = "DragonblightPlainsNightDay",
        path = 594438,
        duration = 110.000,
    },
    {
        name = "DragonblightRubyDragonshrine",
        path = 594333,
        duration = 105.000,
    },
    {
        name = "EbonHoldStage1day",
        path = 594501,
        duration = 75.449,
    },
    {
        name = "EbonHoldStage1Night",
        path = 594567,
        duration = 75.449,
    },
    {
        name = "EbonHoldStage2",
        path = 594498,
        duration = 75.449,
    },
    {
        name = "EbonHoldStage3",
        path = 594339,
        duration = 75.379,
    },
    {
        name = "EbonHoldStage4",
        path = 594348,
        duration = 75.449,
    },
    {
        name = "EcoDomeAll",
        path = 594351,
        duration = 102.000,
    },
    {
        name = "EnchangedForestDay",
        path = 539058,
        duration = 76.904,
    },
    {
        name = "EnchantedForestNight",
        path = 538990,
        duration = 76.904,
    },
    {
        name = "EversongAmbienceDay",
        path = 594528,
        duration = 60.000,
    },
    {
        name = "EversongAmbienceNight",
        path = 594456,
        duration = 59.979,
    },
    {
        name = "ForestDarkEnchantedDay",
        path = 539114,
        duration = 59.629,
    },
    {
        name = "ForestDarkEnchantedNight",
        path = 539028,
        duration = 59.722,
    },
    {
        name = "ForestHighDay",
        path = 539047,
        duration = 60.000,
    },
    {
        name = "ForestHighNight",
        path = 538994,
        duration = 60.000,
    },
    {
        name = "ForestNormalDay",
        path = 539131,
        duration = 60.000,
    },
    {
        name = "ForestNormalNight",
        path = 539108,
        duration = 60.000,
    },
    {
        name = "ForestScaryDay",
        path = 539098,
        duration = 59.443,
    },
    {
        name = "ForestScaryNight",
        path = 538996,
        duration = 59.536,
    },
    {
        name = "ForestSnowDay",
        path = 539013,
        duration = 60.000,
    },
    {
        name = "ForestSnowNight",
        path = 539023,
        duration = 59.629,
    },
    {
        name = "GhostlandsDay",
        path = 594492,
        duration = 59.966,
    },
    {
        name = "GhostlandsDay2",
        path = 594534,
        duration = 59.881,
    },
    {
        name = "GhostlandsNight",
        path = 594483,
        duration = 59.983,
    },
    {
        name = "GhostlandsNight2",
        path = 594354,
        duration = 60.000,
    },
    {
        name = "GrasslandsDay",
        path = 539056,
        duration = 60.000,
    },
    {
        name = "GrassLandsNight",
        path = 539128,
        duration = 60.000,
    },
    {
        name = "GrizzlyHillsDayGeneral",
        path = 594345,
        duration = 109.151,
    },
    {
        name = "GrizzlyHillsLumberNightday",
        path = 594519,
        duration = 75.638,
    },
    {
        name = "GrizzlyHillsNightGeneral",
        path = 594540,
        duration = 110.000,
    },
    {
        name = "GrizzlyHillsOpenDay",
        path = 594387,
        duration = 66.358,
    },
    {
        name = "GrizzlyHillsOpenNight",
        path = 594435,
        duration = 81.366,
    },
    {
        name = "Hellfire",
        path = 539045,
        duration = 60.000,
    },
    {
        name = "HowlingFjordColdNightDay",
        path = 539041,
        duration = 94.795,
    },
    {
        name = "HowlingFjordDay",
        path = 594504,
        duration = 59.970,
    },
    {
        name = "HowlingFjordFireArea",
        path = 594375,
        duration = 65.000,
    },
    {
        name = "HowlingFjordNight",
        path = 594378,
        duration = 60.000,
    },
    {
        name = "HyjalPastDay",
        path = 594489,
        duration = 97.000,
    },
    {
        name = "HyjalPastNight",
        path = 594366,
        duration = 93.000,
    },
    {
        name = "IceCrownGlacier",
        path = 594510,
        duration = 115.108,
    },
    {
        name = "IsleOfConquest_DayNight",
        path = 594549,
        duration = 113.842,
    },
    {
        name = "JungleDay",
        path = 539097,
        duration = 60.000,
    },
    {
        name = "JungleNight",
        path = 539092,
        duration = 60.000,
    },
    {
        name = "LakeWintergraspDay",
        path = 594429,
        duration = 132.631,
    },
    {
        name = "LakeWintergraspNight",
        path = 594363,
        duration = 128.361,
    },
    {
        name = "LostIslesPhase1_Day",
        path = 594417,
        duration = 108.450,
    },
    {
        name = "LostIslesPhase1_Night",
        path = 594474,
        duration = 83.335,
    },
    {
        name = "MarshDay",
        path = 539084,
        duration = 56.935,
    },
    {
        name = "MarshNight",
        path = 539103,
        duration = 56.935,
    },
    {
        name = "NagrandDay",
        path = 539001,
        duration = 61.000,
    },
    {
        name = "NagrandNight",
        path = 538999,
        duration = 61.000,
    },
    {
        name = "NetherStorm1",
        path = 594423,
        duration = 144.000,
    },
    {
        name = "NewHearthglen",
        path = 594444,
        duration = 130.000,
    },
    {
        name = "NortherndCoastGenericDayNight",
        path = 594561,
        duration = 82.299,
    },
    {
        name = "NorthrendScourgeGeneral",
        path = 594426,
        duration = 96.174,
    },
    {
        name = "PlagueLandsDay",
        path = 539019,
        duration = 60.000,
    },
    {
        name = "PlagueLandsNight",
        path = 539115,
        duration = 60.000,
    },
    {
        name = "PlainsDesertDay",
        path = 539015,
        duration = 56.935,
    },
    {
        name = "PlainsDesertNight",
        path = 539034,
        duration = 56.842,
    },
    {
        name = "RubySanctumNightDay",
        path = 594462,
        duration = 85.060,
    },
    {
        name = "SaltFlatsDay",
        path = 539009,
        duration = 56.935,
    },
    {
        name = "SaltFlatsNight",
        path = 539074,
        duration = 56.935,
    },
    {
        name = "ScorchLineDay",
        path = 594402,
        duration = 60.000,
    },
    {
        name = "ScorchLineNight",
        path = 594555,
        duration = 60.000,
    },
    {
        name = "ShadowFang",
        path = 539122,
        duration = 59.629,
    },
    {
        name = "ShadowMoonValley1",
        path = 594360,
        duration = 92.000,
    },
    {
        name = "ShalandisIsle",
        path = 594570,
        duration = 60.000,
    },
    {
        name = "Shattrath",
        path = 594408,
        duration = 113.721,
    },
    {
        name = "SholazarBasinDay",
        path = 594471,
        duration = 70.000,
    },
    {
        name = "SholazarBasinNight",
        path = 594381,
        duration = 70.000,
    },
    {
        name = "SilvermoonRuinsDay",
        path = 594336,
        duration = 65.000,
    },
    {
        name = "SilvermoonRuinsNight",
        path = 594558,
        duration = 60.000,
    },
    {
        name = "StormPeaksDayNight",
        path = 594465,
        duration = 113.996,
    },
    {
        name = "TerokkarDay",
        path = 594450,
        duration = 60.000,
    },
    {
        name = "TerokkarNight",
        path = 594480,
        duration = 60.000,
    },
    {
        name = "ThePitofSaron",
        path = 594564,
        duration = 143.587,
    },
    {
        name = "TheVibrantGlade",
        path = 594486,
        duration = 60.000,
    },
    {
        name = "UlduarRaid_FreyaZone",
        path = 594552,
        duration = 65.440,
    },
    {
        name = "ValianceKeep",
        path = 539118,
        duration = 103.123,
    },
    {
        name = "VolcanicDay",
        path = 539073,
        duration = 56.935,
    },
    {
        name = "VolcanicNight",
        path = 539077,
        duration = 56.935,
    },
    {
        name = "WailingCaverns",
        path = 537442,
        duration = 56.842,
    },
    {
        name = "WestfallDay",
        path = 539006,
        duration = 60.000,
    },
    {
        name = "WetlandsDay",
        path = 539133,
        duration = 60.000,
    },
    {
        name = "WetlandsNight",
        path = 538993,
        duration = 60.000,
    },
    {
        name = "WhisperGulchDayNight",
        path = 594453,
        duration = 58.664,
    },
    {
        name = "ZangarMarsh1",
        path = 594396,
        duration = 104.000,
    },
    {
        name = "ZangarMarsh2",
        path = 594447,
        duration = 104.000,
    },
    {
        name = "ZangarMarsh3",
        path = 594537,
        duration = 98.000,
    },
    {
        name = "ZulDrakGeneralDay",
        path = 594516,
        duration = 99.288,
    },
    {
        name = "ZulDrakGeneralNight",
        path = 594357,
        duration = 117.496,
    },

    -- WMO data
    {
        name = "AhnQirajRuinsBareRoomTone",
        path = 537321,
        duration = 59.443,
    },
    {
        name = "AhnQirajRuinsTriangleRoom",
        path = 537322,
        duration = 59.977,
    },
    {
        name = "AuchindounDemonWing",
        path = 537323,
        duration = 90.000,
    },
    {
        name = "AuchindounDraineiWing",
        path = 537324,
        duration = 87.000,
    },
    {
        name = "AuchindounEtherialWing",
        path = 537325,
        duration = 74.000,
    },
    {
        name = "AuchindounShadowWing",
        path = 537326,
        duration = 60.987,
    },
    {
        name = "AzjulNerubUpperCity",
        path = 537327,
        duration = 150.000,
    },
    {
        name = "Blackfathom",
        path = 537328,
        duration = 74.628,
    },
    {
        name = "BlackRockJail",
        path = 537329,
        duration = 110.000,
    },
    {
        name = "BlackrockSpire",
        path = 537330,
        duration = 75.000,
    },
    {
        name = "BlackRockSpireDrakeCalls",
        path = 537331,
        duration = 109.227,
    },
    {
        name = "BlackSmith",
        path = 537332,
        duration = 59.536,
    },
    {
        name = "BlackTempleCenterRoom",
        path = 537333,
        duration = 69.000,
    },
    {
        name = "BlackTempleCHUD",
        path = 537334,
        duration = 63.965,
    },
    {
        name = "BlackTempleIllidanTower1",
        path = 537335,
        duration = 96.000,
    },
    {
        name = "BlackTempleReliquaryofSouls",
        path = 537336,
        duration = 73.000,
    },
    {
        name = "BlackTemple_Aqueduct",
        path = 537337,
        duration = 60.000,
    },
    {
        name = "CavernsOfTimeBasic",
        path = 537338,
        duration = 60.000,
    },
    {
        name = "CavernsOfTimeCore",
        path = 537339,
        duration = 64.042,
    },
    {
        name = "CaveVolcanic",
        path = 537345,
        duration = 63.731,
    },
    {
        name = "CoilFangReservoir",
        path = 537346,
        duration = 92.000,
    },
    {
        name = "CoilFangStandard",
        path = 537347,
        duration = 92.000,
    },
    {
        name = "CoilFangSteamVault",
        path = 537348,
        duration = 92.000,
    },
    {
        name = "DalaranPrison",
        path = 537349,
        duration = 110.000,
    },
    {
        name = "DalaranSewers",
        path = 537350,
        duration = 75.374,
    },
    {
        name = "DarnassusDay",
        path = 537351,
        duration = 56.935,
    },
    {
        name = "DarnassusNight",
        path = 537352,
        duration = 56.935,
    },
    {
        name = "DireMaulChamber",
        path = 537353,
        duration = 59.536,
    },
    {
        name = "DrakTharonKeep",
        path = 537354,
        duration = 60.000,
    },
    {
        name = "DungeonCatheadral",
        path = 537355,
        duration = 59.443,
    },
    {
        name = "DungeonCrypt",
        path = 537356,
        duration = 88.978,
    },
    {
        name = "DwarvenDistrict",
        path = 537357,
        duration = 56.935,
    },
    {
        name = "ExodarCity1",
        path = 537358,
        duration = 75.000,
    },
    {
        name = "Gnomeregan",
        path = 537359,
        duration = 58.495,
    },
    {
        name = "GundrakGeneral",
        path = 537360,
        duration = 103.701,
    },
    {
        name = "GundrakWaterSteam",
        path = 537361,
        duration = 103.701,
    },
    {
        name = "HellFireBloodFurnace",
        path = 537362,
        duration = 104.000,
    },
    {
        name = "HellfireCitadelMilitary",
        path = 537363,
        duration = 60.000,
    },
    {
        name = "HellfireMagtheradonsLair",
        path = 537364,
        duration = 78.000,
    },
    {
        name = "IceCrownRaidGeneral",
        path = 537365,
        duration = 89.119,
    },
    {
        name = "IceCrownRaidPlagueWorks",
        path = 537366,
        duration = 87.701,
    },
    {
        name = "IceCrownRaid_CrimsonHall",
        path = 537367,
        duration = 84.606,
    },
    {
        name = "IceCrownRaid_Frostmourne_AMB",
        path = 537368,
        duration = 66.915,
    },
    {
        name = "IceCrownRaid_TheForgeOfSouls",
        path = 537369,
        duration = 84.030,
    },
    {
        name = "Ironforge",
        path = 537370,
        duration = 88.563,
    },
    {
        name = "IronforgeTheGreatForge",
        path = 537371,
        duration = 58.182,
    },
    {
        name = "KarazhanBasementHorseStables",
        path = 537372,
        duration = 72.000,
    },
    {
        name = "KarazhanDemonArea",
        path = 537373,
        duration = 70.000,
    },
    {
        name = "KarazhanDiningRoom",
        path = 537374,
        duration = 75.000,
    },
    {
        name = "KarazhanFacade",
        path = 537375,
        duration = 60.000,
    },
    {
        name = "KarazhanGreatHall",
        path = 537376,
        duration = 60.000,
    },
    {
        name = "KarazhanGuestChambers",
        path = 537377,
        duration = 73.000,
    },
    {
        name = "KarazhanLibraryExterior",
        path = 537378,
        duration = 70.000,
    },
    {
        name = "KarazhanNetherwindeBossRoom",
        path = 537379,
        duration = 59.849,
    },
    {
        name = "KarazhanOperaBackstage",
        path = 537380,
        duration = 60.000,
    },
    {
        name = "Karazhan_GeneralAmbience",
        path = 537381,
        duration = 55.026,
    },
    {
        name = "LargeRoomTone",
        path = 537382,
        duration = 56.935,
    },
    {
        name = "LargeRoomToneNew",
        path = 537383,
        duration = 59.536,
    },
    {
        name = "MineStandard02",
        path = 537385,
        duration = 59.993,
    },
    {
        name = "MineStandard03",
        path = 537386,
        duration = 59.993,
    },
    {
        name = "MineStandardDungeon",
        path = 537387,
        duration = 56.935,
    },
    {
        name = "MineStandardNorthrend",
        path = 537388,
        duration = 80.000,
    },
    {
        name = "mini-hive",
        path = 537389,
        duration = 52.716,
    },
    {
        name = "NaxxramasAbominationWing",
        path = 537390,
        duration = 60.000,
    },
    {
        name = "NaxxramasDeathknightWing",
        path = 537391,
        duration = 59.988,
    },
    {
        name = "NaxxramasEntrance",
        path = 537392,
        duration = 59.951,
    },
    {
        name = "NaxxramasFrostWyrm",
        path = 537393,
        duration = 60.000,
    },
    {
        name = "NaxxramasPlagueWing",
        path = 537394,
        duration = 59.919,
    },
    {
        name = "NaxxramasSpiderWing",
        path = 537395,
        duration = 59.855,
    },
    {
        name = "Nexus70EnergyRoom",
        path = 537396,
        duration = 86.137,
    },
    {
        name = "Nexus70General",
        path = 537397,
        duration = 60.000,
    },
    {
        name = "Nexus70_Library",
        path = 537398,
        duration = 93.918,
    },
    {
        name = "OldStrathHolme1",
        path = 537399,
        duration = 133.379,
    },
    {
        name = "OldStrathHolme2",
        path = 537400,
        duration = 73.423,
    },
    {
        name = "OrgrimmarDay",
        path = 537401,
        duration = 56.842,
    },
    {
        name = "OrgrimmarNight",
        path = 537402,
        duration = 56.935,
    },
    {
        name = "RazorfenKraul",
        path = 537403,
        duration = 56.935,
    },
    {
        name = "ShipExterior",
        path = 537404,
        duration = 60.000,
    },
    {
        name = "ShipInterior",
        path = 537405,
        duration = 60.000,
    },
    {
        name = "Sholazar_MakersOverlook",
        path = 537406,
        duration = 73.423,
    },
    {
        name = "Sholazar_TheTribunalofAges",
        path = 537407,
        duration = 73.423,
    },
    {
        name = "SilverMoonGeneralDay1",
        path = 537408,
        duration = 59.971,
    },
    {
        name = "SilverMoonGeneralNight1",
        path = 537409,
        duration = 55.000,
    },
    {
        name = "StormwindDay",
        path = 537411,
        duration = 56.935,
    },
    {
        name = "StormWindJail",
        path = 537412,
        duration = 59.629,
    },
    {
        name = "StormwindNight",
        path = 537413,
        duration = 56.935,
    },
    {
        name = "Stratholme",
        path = 537414,
        duration = 70.935,
    },
    {
        name = "SunkenTemple",
        path = 537417,
        duration = 59.629,
    },
    {
        name = "SunwellProgressionLight1",
        path = 537418,
        duration = 105.589,
    },
    {
        name = "SunwellProgressionLight2",
        path = 537419,
        duration = 105.000,
    },
    {
        name = "Sunwell_GrandMagistersAsylum",
        path = 537420,
        duration = 90.000,
    },
    {
        name = "Sunwell_INT_Generic1",
        path = 537421,
        duration = 94.052,
    },
    {
        name = "Tavern",
        path = 537422,
        duration = 60.000,
    },
    {
        name = "TavernCrowded",
        path = 537423,
        duration = 55.897,
    },
    {
        name = "TempestKeepGeneral",
        path = 537424,
        duration = 74.000,
    },
    {
        name = "TempestKeepRaidPhoenix01",
        path = 537425,
        duration = 74.000,
    },
    {
        name = "ThunderBluffDay",
        path = 537426,
        duration = 60.000,
    },
    {
        name = "ThunderBluffNight",
        path = 537427,
        duration = 60.000,
    },
    {
        name = "Ulduar77Main",
        path = 537428,
        duration = 107.770,
    },
    {
        name = "UlduarRaid_EngineRoom",
        path = 537429,
        duration = 102.602,
    },
    {
        name = "UlduarRaid_General",
        path = 537430,
        duration = 145.074,
    },
    {
        name = "UlduarRaid_LichKingWing",
        path = 537431,
        duration = 67.276,
    },
    {
        name = "UlduarRaid_PlanetariumHallway",
        path = 537432,
        duration = 60.536,
    },
    {
        name = "ULduarRaid_StormwindWing",
        path = 537433,
        duration = 68.986,
    },
    {
        name = "UlduarRaid_Tram",
        path = 537434,
        duration = 86.420,
    },
    {
        name = "UlduarRaid_Wyrmrest_Temple",
        path = 537435,
        duration = 70.408,
    },
    {
        name = "UlduarRaid_Yogg_Saron_BrainRoom",
        path = 537436,
        duration = 90.675,
    },
    {
        name = "Undercity",
        path = 537437,
        duration = 45.883,
    },
    {
        name = "UnderCityThorneRoom",
        path = 537439,
        duration = 118.700,
    },
    {
        name = "UtegardeGeneral",
        path = 537440,
        duration = 60.000,
    },
    {
        name = "VordrassilsTears",
        path = 537441,
        duration = 70.000,
    },
    {
        name = "WailingCaverns",
        path = 537442,
        duration = 75.000,
    },
    {
        name = "WarsongGulch",
        path = 537443,
        duration = 90.000,
    },
};

HM.AmbienceData = AmbienceData
