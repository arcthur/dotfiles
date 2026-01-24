-- items/widgets/storage.lua
-- Disk storage display

local colors = require("colors")
local settings = require("settings")
local icons = require("icons")

-- Storage item
local storage = sbar.add("item", "storage", {
    position    = "right",
    update_freq = settings.update.slow,
    padding_left = 10,
    icon = {
        string = icons.storage,
        color  = colors.green,
    },
})

-- Update storage status
local function update_storage()
    local script = [[
        MOUNT_POINT="/System/Volumes/Data"
        [ ! -d "$MOUNT_POINT" ] && MOUNT_POINT="/"
        df -H "$MOUNT_POINT" | awk 'NR==2 {gsub(/%/,""); print $5}'
    ]]

    sbar.exec(script, function(output)
        if not output or output == "" then
            storage:set({
                label = { string = "--" },
                icon  = { color = colors.white },
            })
            return
        end

        local disk_used = tonumber(output:match("%d+")) or 0
        local disk_free = 100 - disk_used

        -- Color based on free space
        local color
        if disk_free < 10 then
            color = colors.red      -- Critical
        elseif disk_free < 20 then
            color = colors.peach    -- Warning
        elseif disk_free < 30 then
            color = colors.yellow   -- Caution
        else
            color = colors.white    -- OK
        end

        storage:set({
            label = { string = disk_free .. "%", color = color },
            icon  = { color = color },
        })
    end)
end

storage:subscribe({ "routine", "forced", "system_woke" }, update_storage)
