-- helpers/popup.lua
-- Minimal hover-driven popup toggling.
-- The popups in this config are informational (no clickable children), so we
-- show on mouse.entered and hide on mouse.exited -- there is no need to move the
-- cursor into the popup, which keeps the interaction predictable and avoids the
-- flicker that comes with tracking mouse.exited.global.

local M = {}

--- Wire a host item's popup to hover.
--- @param host table SbarLua item that hosts the popup (children use position="popup.<host>")
--- @param on_show function|nil optional callback to refresh popup content when shown
function M.hover(host, on_show)
    host:subscribe("mouse.entered", function()
        host:set({ popup = { drawing = true } })
        if on_show then on_show() end
    end)
    host:subscribe("mouse.exited", function()
        host:set({ popup = { drawing = false } })
    end)
end

return M
