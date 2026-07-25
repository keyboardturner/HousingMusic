[Full Changelog & Previous Releases](https://github.com/keyboardturner/HousingMusic/releases)

# 0.1.5

Regen LibRPMedia database

12.1.0 toc update

Fixed the in-house volume sliders overwriting the game's sound settings upon entering a house
 - The slider values were only ever copied from the game once, so any volume changed afterwards in the game's own sound options was pushed back to that old copy on every house entry (usually upwards, which made everything sound maxed out)
 - The sliders now follow the current game volumes again, and only the ones deliberately moved are applied inside the house
 - Slider values are clamped before being applied, so a bad saved value can no longer force a channel to maximum
 - Leaving the house now only reverts the settings the addon changed itself, instead of everything it had copied

# 0.1.4

Added Cached Playlist tab
 - Allows viewing cached playlists
 - Functions to favorite and delete playlists

Added Dropdown menu entry to copy track File ID

# 0.1.3

Added Ambience selection feature
 - An ambience track can be selected and shared for each home, similar to music playlists
 - There are currently 566 ambience options to choose from

Regen LibRPMedia database

12.0.7 toc update

# 0.1.2

Regen LibRPMedia database

12.0.5 toc update

# 0.1.1

Added support for Musician addon to stop housing music playback when Musician begins its own playback

Added an "outline mode" option to adjust outline mode while inside the house (does not apply in Edit Mode)

# 0.1.0

why are realm names sometime nil blizz

# 0.0.9

Added 481 musics (LibRPMedia)

12.0.1 toc update

# 0.0.8

Quick fix to "attempt to compare number with boolean" error that occurred when checking if a playlist was sent by a guild member.

# 0.0.7

Added option to reduce camera movement while in the house (should help with stairs and the like)

Potential fix to auto-share playlists

Adjusted some logic to save playlist data from others if they're friends/guild members

Added checks to see if the player has certain sound settings disabled because some of you can't behave

# 0.0.6

Regen LibRPMedia database (midnight prepatch title screen music)

# 0.0.5

Correctly set the default values of the in-house sliders (was being set to game defaults instead of copying the existing game volume slider values)

# 0.0.4

Added slider settings to temporarily adjust volume while inside the house

Added options to temporarily toggle footstep and interact key cue sounds while inside the house

# 0.0.3

Adjusted playlist upon creation

Added an icon to the playlist assigned to a plot in a neighborhood faction

Added compatibility with Total RP3's music API play function

# 0.0.2

Fixed potential issue where comms were not sharing playlist if relying on default settings

# 0.0.1

- the test is complete, release the pigeons