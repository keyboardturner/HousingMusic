local _, HM = ...

local L = {};
HM.L = L;

local function defaultFunc(L, key)
 -- If this function was called, we have no localization for this key.
 -- We could complain loudly to allow localizers to see the error of their ways, 
 -- but, for now, just return the key as its own localization. This allows you to—avoid writing the default localization out explicitly.
 return key;
end
setmetatable(L, {__index=defaultFunc});

local LOCALE = GetLocale()


if LOCALE == "enUS" then
	-- The EU English game client also
	-- uses the US English locale code.
	L["TOC_Title"] = "Housing Music"
	L["TOC_Notes"] = "Shareable music players for Player Housing."
	L["SLASH_HM1"] = "housingmusic"
	L["SLASH_HM2"] = "housingmusic"
	L["SLASH_HM3"] = "housingmusic"

	L["HousingMusic_Colored"] = "|cffd7ad32HousingMusic|r"
	L["Default"] = DEFAULT
	L["CantDeleteDefault"] = "Cannot delete Default playlist."
	L["PlaylistExists"] = "A playlist with that name already exists."
	L["PlaylistRenamed"] = "Playlist renamed to: %s"
	L["HousingPlot"] = "Housing Plot"
	L["MyHouse"] = "My House (%s)"
	L["Unknown"] = UNKNOWN
	L["OwnersHouse"] = "%s's House (%s)"
	L["CannotRetrieveInfo"] = "Could not retrieve info for ID: %s"
	L["FileID"] = "File ID: %s"
	L["GameMusic"] = "Game Music (ID: %s)"
	L["EnteredCustomZone"] = "Entered custom zone: %s"
	L["UnknownSong"] = "Unknown Song"
	L["UnmuteSong"] = "Unmute Song"
	L["MuteSong"] = "Mute Song"
	L["Mute"] = "Mute"
	L["RenamePlaylistTo"] = "Rename playlist %s to:"
	L["Rename"] = TRANSMOG_CUSTOM_SET_RENAME
	L["Cancel"] = CANCEL
	L["PlaylistInvalidOrExists"] = "PlayList name invalid or already exists."
	L["Create"] = COMMUNITIES_CREATE
	L["NewPlaylistName"] = "Enter new playlist name:"
	L["DeletePlaylist"] = "Delete playlist %s?"
	L["Yes"] = YES
	L["No"] = NO
	L["OwnerssHouseMusic"] = "%s's House Music"
	L["BlockerFrameText"] = string.format("%s requires 'Sound in Background' to function correctly.", L["HousingMusic_Colored"])
	L["BlockerFrameSubtext"] = "Without this setting, music will stop when you tab out, breaking the current song playing."
	L["NoMusicPlaying"] = "No Music Playing"
	L["PlayerAddedToMute"] = "Player %s added to mute list."
	L["PlayerRemovedFromMute"] = "Player %s removed from mute list."
	L["HousingMusicSettings"] = "Housing Music Settings"
	L["MuteList"] = "Mute List"
	L["Setting_AutoplayMusic"] = "Auto-play Music"
	L["Setting_AutoplayMusicTT"] = "Automatically play music from a selected playlist when entering a house."
	L["Setting_ShowMusicOnIcon"] = "Show Music Playing on Icon"
	L["Setting_ShowMusicOnIconTT"] = "Display an animation on the music icon button when music is playing."
	L["Setting_ShowMinimapIcon"] = "Show Button on Minimap"
	L["Setting_ShowMinimapIconTT"] = "Toggle the Housing Music addon button on the minimap."
	L["Setting_ShowControlFrameIcon"] = "Show Button on Housing Controls"
	L["Setting_ShowControlFrameIconTT"] = "Toggle the Housing Music addon button on the housing controls."
	L["Setting_ToastPopup"] = "\"Now Playing\" Toast Popup"
	L["Setting_ToastPopupTT"] = "Display the toast popup frame that occurs when a song begins playing."
	L["Setting_KeepMinimized"] = "Keep Frame Minimized"
	L["Setting_KeepMinimizedTT"] = "When opening the Housing Music interface, keep the frame minimized if the frame was minimized previously."
	L["Setting_NormalizeNames"] = "Normalize Song Names"
	L["Setting_NormalizeNamesTT"] = "Many names of songs will be normalized in the song list to remove underscores, capitalize each word, and removing leading zeros from song numbers."
	L["Setting_ChatboxMessages"] = "Chat Frame Messages"
	L["Setting_ChatboxMessagesTT"] = "Toggle addon messages in the chat box."
	L["Setting_AutosharePlaylist"] = "Auto-Share Playlists"
	L["Setting_AutosharePlaylistTT"] = "Control who you automatically share playlists to."
	L["Setting_AutoImportPlaylist"] = "Auto-Receive Playlist"
	L["Setting_AutoImportPlaylistTT"] = "Control who you automatically receive playlists from."
	L["Setting_CustomImportPlaylist"] = "Allow Custom Playlist"
	L["Setting_CustomImportPlaylistTT"] = "Control who you automatically receive custom playlists from."
	L["Setting_Everyone"] = "Everyone"
	L["Setting_FriendsandGuild"] = "Friends and Guild"
	L["Setting_Friends"] = "Friends"
	L["Setting_None"] = "None"
	L["Setting_AS_EveryoneTT"] = "Share your playlist to all players."
	L["Setting_AS_FriendsandGuildTT"] = "Only share your playlist to guild members and friends."
	L["Setting_AS_FriendsTT"] = "Only share your playlist to friends."
	L["Setting_AS_None"] = "Never share your playlist."
	L["Setting_AI_EveryoneTT"] = "Receive playlists from all players."
	L["Setting_AI_FriendsandGuildTT"] = "Only receive playlists from guild members and friends."
	L["Setting_AI_FriendsTT"] = "Only receive playlists from friends."
	L["Setting_AI_None"] = "Never receive playlists."
	L["Setting_CI_EveryoneTT"] = "Receive custom playlists from all players."
	L["Setting_CI_FriendsandGuildTT"] = "Only receive custom playlists from guild members and friends."
	L["Setting_CI_FriendsTT"] = "Only receive custom playlists from friends."
	L["Setting_CI_None"] = "Never receive custom playlists."
	L["Setting_NameRealm"] = "Name-Realm"
	L["Setting_MutePlayerRealmAdded"] = "If a realm is not specified, your own realm will be used. If you have a target, this will automatically mute your target."
	L["Setting_MutePlayer"] = "Mute Player"
	L["UnmutePlayer"] = "Unmute Player"
	L["SearchByNameFileID"] = "Search by name or filedata ID"
	L["PlaylistIsFull"] = "Playlist is full (Max %d songs)"
	L["AddedMusicToPlaylist"] = "Added %s to %s"
	L["DurationNumber"] = "Duration: %s"
	L["SongIsInPlaylist"] = "Song is in Playlist: %s"
	L["SongIsMuted"] = "Song is muted"
	L["AlternateNames"] = "Alternate Names:"
	L["PlaylistIsFull"] = "Playlist is Full (%d/%d)"
	L["AddSongToPlaylist"] = "Add Song to Playlist"
	L["PreviewSong"] = "Preview Song"
	L["NextSong"] = "Next Song"
	L["PreviousSong"] = "Previous Song"
	L["SelectPlaylist"] = "Select Playlist"
	L["NoPlaylistsReceived"] = "No Playlists Received"
	L["SelectSource"] = "Select Source"
	L["RemovedSongFromPlaylist"] = "Removed %s from %s"
	L["RemoveSongFromPlaylist"] = "Remove Song From Playlist"
	L["SourceSenderSongCount"] = "Source: %s (%d songs)"
	L["NoData"] = "No Data"
	L["ReceivedPlaylistFromSenderSongCount"] = "Received playlist from %s (%d songs)."
	L["ChatThrottleLibNotFound"] = "ChatThrottleLib not found."
	L["InsideHouseToShare"] = "You must be inside a house to share its music."
	L["SendingHouseMusicToTarget"] = "Sending house music playlist to %s..."
	L["BroadcastingHouseMusicDataViaChannel"] = "Broadcasting house music playlist via %s..."
	L["PreventingSendingDataToTarget"] = "Preventing sending data to %s"
	L["MutePlayerExplanation"] = "Muting a player will prevent all playlists to be sent to them and prevent all playlists to be received by them."
	L["Setting_ClearCache"] = "Other Player Playlists Purge"
	L["Setting_ClearCacheTT"] = "Purge playlists sent by other players saved in your cached data after a period of time."
	L["Setting_ClearCache_1"] = "1 Week"
	L["Setting_ClearCache_2"] = "2 Weeks"
	L["Setting_ClearCache_3"] = "4 Weeks"
	L["Setting_ClearCache_4"] = "8 Weeks"
	L["FavoritedPlaylistsNoPurge"] = "Favorited playlists will never be purged."
	L["PurgedOldPlaylists"] = "Purged %ds playlists not seen in %d days."
	L["AmountSongs"] = "%s Songs"
	L["CreateNewPlaylist"] = "Create New Playlist"
	L["RenameCurrentPlaylist"] = "Rename Current Playlist"
	L["DeleteCurrentPlaylist"] = "Delete Current Playlist"
	L["CachedPlaylists"] = "Cached Playlists"


return end

if LOCALE == "esES" or LOCALE == "esMX" then
	-- Spanish translations go here


return end

if LOCALE == "deDE" then
	-- German translations go here


return end

if LOCALE == "frFR" then
	-- French translations go here

return end

if LOCALE == "itIT" then
	-- Italian translations go here


return end

if LOCALE == "ptBR" then
	-- Brazilian Portuguese translations go here


-- Note that the EU Portuguese WoW client also
-- uses the Brazilian Portuguese locale code.
return end

if LOCALE == "ruRU" then
	-- Russian translations go here


return end

if LOCALE == "koKR" then
	-- Korean translations go here


return end

if LOCALE == "zhCN" then
	-- Simplified Chinese translations go here


return end

if LOCALE == "zhTW" then
	-- Traditional Chinese translations go here


return end
