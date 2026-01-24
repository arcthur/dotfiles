-- items/widgets/ram.lua
-- RAM usage with graph display

local colors = require("colors")
local settings = require("settings")

-- RAM graph
local ram_graph = sbar.add("graph", "ram.graph", 35, {
    position = "right",
    width    = 0,
    padding_right = 0,
    graph = {
        color      = colors.text,
        fill_color = colors.overlay2_50,
    },
    label = { drawing = false },
    icon  = { drawing = false },
    background = {
        height  = 30,
        drawing = false,
        color   = colors.transparent,
    },
})

-- RAM label (top)
local ram_top = sbar.add("item", "ram.top", {
    position = "right",
    width    = 0,
    padding_right = 5,
    y_offset = 6,
    label = {
        string = "RAM",
        font = {
            family = settings.font.label,
            style  = settings.font.style.regular,
            size   = 8,
        },
        color = colors.white,
    },
    icon = { drawing = false },
})

-- RAM percentage
local ram_percent = sbar.add("item", "ram.percent", {
    position    = "right",
    width       = 40,
    padding_right = 5,
    y_offset    = -4,
    update_freq = settings.update.fast,
    label = {
        font = {
            family = settings.font.label,
            style  = settings.font.style.regular,
            size   = 12,
        },
        color = colors.white,
    },
    icon = { drawing = false },
})

-- RAM spacer
sbar.add("item", "ram.spacer", {
    position = "right",
    width    = 10,
    background = { drawing = false },
    icon     = { drawing = false },
    label    = { drawing = false },
})

-- Sysinfo bracket (groups battery, storage, cpu, ram)
sbar.add("bracket", "sysinfo", {
    "battery", "storage",
    "cpu.graph", "cpu.top", "cpu.percent",
    "ram.graph", "ram.top", "ram.percent"
}, {
    background = {
        color         = colors.surface0,
        corner_radius = 7,
        height        = 32,
    },
    shadow = false,
})

-- Divider after sysinfo bracket
sbar.add("item", "sysinfo.divider", {
    position = "right",
    width    = 8,
    background = { drawing = false },
    icon     = { drawing = false },
    label    = { drawing = false },
})

-- Update RAM usage
local function update_ram()
    sbar.exec("memory_pressure | awk '/System-wide memory free percentage:/ {gsub(/%/,\"\"); print $5; exit}'", function(output)
        if not output or output == "" then
            ram_percent:set({ label = "--" })
            return
        end

        local mem_free = tonumber(output:match("%d+")) or 0
        local mem_used = 100 - mem_free

        -- Color based on usage
        local color
        if mem_used >= 70 then
            color = colors.red
        elseif mem_used >= 30 then
            color = colors.peach
        else
            color = colors.white
        end

        ram_percent:set({
            label = { string = mem_used .. "%", color = color },
        })

        -- Push graph value (0.XX format)
        ram_graph:push({ mem_used / 100 })
    end)
end

ram_percent:subscribe({ "routine", "forced" }, update_ram)
