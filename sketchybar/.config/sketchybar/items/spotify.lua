-- items/spotify.lua
-- Spotify now playing display using native macOS notifications
-- Works on macOS 15.4+ (does not rely on MediaRemote framework)

local colors = require("colors")
local settings = require("settings")
local icons = require("icons")

local SHELL_PATH = settings.shell_path or "/opt/homebrew/bin:/opt/homebrew/sbin:/usr/local/bin:/usr/local/sbin:/usr/bin:/bin"

-- ============================================================================
-- Configuration
-- ============================================================================

local MAX_CHARS = 40
local POLL_INTERVAL = 5
local SCRIPT_PATH = "/tmp/sketchybar_spotify.scpt"

-- ============================================================================
-- Initialize AppleScript (write once, reuse)
-- ============================================================================

local script = [[
tell application "System Events"
    if not (exists process "Spotify") then
        return "NOT_RUNNING"
    end if
end tell

tell application "Spotify"
    if player state is playing then
        set trackName to name of current track
        set artistName to artist of current track
        return trackName & " · " & artistName
    else
        return "NOT_PLAYING"
    end if
end tell
]]

local f = io.open(SCRIPT_PATH, "w")
if f then
    f:write(script)
    f:close()
end

-- ============================================================================
-- Register Spotify Native Event
-- ============================================================================

sbar.add("event", "spotify_change", "com.spotify.client.PlaybackStateChanged")

-- ============================================================================
-- Create Items
-- ============================================================================

local spotify = sbar.add("item", "spotify", {
    position = "left",
    drawing = false,
    updates = "on",
    update_freq = POLL_INTERVAL,
    icon = {
        string = icons.media.spotify,
        font = {
            family = settings.font.text,
            style = settings.font.style.bold,
            size = 16.0,
        },
        color = colors.green,
    },
    label = {
        font = {
            family = settings.font.label,
            style = settings.font.style.regular,
            size = 12.0,
        },
        color = colors.text,
        max_chars = MAX_CHARS,
    },
    background = {
        color = colors.surface0,
        corner_radius = 7,
        height = 32,
    },
    click_script = "osascript -e 'tell application \"Spotify\" to playpause'",
})

-- Divider after spotify
sbar.add("item", "spotify.divider", {
    position = "left",
    width = 4,
    background = { drawing = false },
    icon = { drawing = false },
    label = { drawing = false },
})

-- Move spotify after front_app (front_app moves at 1s)
sbar.exec("sleep 1.5", function()
    sbar.exec("export PATH=" .. SHELL_PATH .. " && sketchybar --move spotify after front_app && sketchybar --move spotify.divider after spotify")
end)

-- ============================================================================
-- Update Logic
-- ============================================================================

local function update_spotify()
    sbar.exec("osascript " .. SCRIPT_PATH .. " 2>/dev/null", function(output)
        output = output and output:gsub("%s+$", "") or ""

        if output == "" or output == "NOT_RUNNING" or output == "NOT_PLAYING" then
            spotify:set({ drawing = false })
            return
        end

        spotify:set({
            drawing = true,
            label = { string = output },
        })
    end)
end

-- ============================================================================
-- Event Subscriptions
-- ============================================================================

spotify:subscribe("spotify_change", update_spotify)
spotify:subscribe("routine", update_spotify)
spotify:subscribe({ "forced", "system_woke" }, update_spotify)

-- Initial update
sbar.exec("sleep 0.5", update_spotify)
