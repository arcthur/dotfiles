-- helpers/wm.lua
-- Detect active window manager at startup (synchronous, runs before event loop)

local M = {}

local function detect()
    local handle = io.popen("pgrep -x AeroSpace 2>/dev/null")
    local result = handle:read("*a")
    handle:close()
    if result and result:match("%d") then return "aerospace" end

    handle = io.popen("pgrep -x paneru 2>/dev/null")
    result = handle:read("*a")
    handle:close()
    if result and result:match("%d") then return "paneru" end

    return nil
end

M.type = detect()

return M
