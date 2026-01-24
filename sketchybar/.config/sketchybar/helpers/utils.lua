-- helpers/utils.lua
-- Utility functions for SketchyBar

local M = {}

-- Debounce timers storage
local debounce_timers = {}

--- Debounce a function call
--- Prevents rapid successive calls by waiting for a quiet period
--- @param key string Unique identifier for this debounce
--- @param delay number Delay in seconds (e.g., 0.1 for 100ms)
--- @param fn function Function to call after delay
function M.debounce(key, delay, fn)
    -- Cancel existing timer if any
    if debounce_timers[key] then
        -- Note: sbar.remove doesn't work for delays, so we use a flag
        debounce_timers[key].cancelled = true
    end

    -- Create new timer context
    local timer = { cancelled = false }
    debounce_timers[key] = timer

    sbar.exec("sleep " .. delay, function()
        if not timer.cancelled then
            fn()
        end
    end)
end

--- Pretty print a Lua table for debugging
--- @param obj any Object to print
--- @param name string|nil Optional name for the object
--- @param indent number|nil Indentation level
function M.pretty_print(obj, name, indent)
    indent = indent or 0
    local prefix = string.rep("  ", indent)

    if type(obj) == "table" then
        if name then
            print(prefix .. name .. " = {")
        else
            print(prefix .. "{")
        end

        for key, value in pairs(obj) do
            local key_str = type(key) == "string" and key or "[" .. tostring(key) .. "]"

            if type(value) == "table" then
                M.pretty_print(value, key_str, indent + 1)
            else
                local value_str = type(value) == "string" and '"' .. value .. '"' or tostring(value)
                print(prefix .. "  " .. key_str .. " = " .. value_str)
            end
        end

        print(prefix .. "}")
    else
        local value_str = type(obj) == "string" and '"' .. obj .. '"' or tostring(obj)
        if name then
            print(prefix .. name .. " = " .. value_str)
        else
            print(prefix .. value_str)
        end
    end
end

--- Throttle a function call
--- Ensures function is called at most once per interval
--- @param key string Unique identifier for this throttle
--- @param interval number Minimum interval between calls in seconds
--- @param fn function Function to call
function M.throttle(key, interval, fn)
    local now = os.time()
    local last = debounce_timers[key .. "_last"] or 0

    if now - last >= interval then
        debounce_timers[key .. "_last"] = now
        fn()
    end
end

--- Clamp a number between min and max
--- @param value number Value to clamp
--- @param min number Minimum value
--- @param max number Maximum value
--- @return number Clamped value
function M.clamp(value, min, max)
    if value < min then return min end
    if value > max then return max end
    return value
end

--- Interpolate between two values
--- @param a number Start value
--- @param b number End value
--- @param t number Interpolation factor (0-1)
--- @return number Interpolated value
function M.lerp(a, b, t)
    return a + (b - a) * M.clamp(t, 0, 1)
end

return M
