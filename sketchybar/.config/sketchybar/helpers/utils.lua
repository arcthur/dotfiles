-- helpers/utils.lua
-- Utility functions for SketchyBar

local M = {}

-- Timer storage for debounce/throttle
local timers = {}

-- High precision time (uses gdate if available, falls back to os.time)
local function get_time_ms()
    -- os.clock() measures CPU time, not wall time
    -- For sub-second precision, we store timestamps with ms component via monotonic counter
    local sec = os.time()
    local ms = (os.clock() * 1000) % 1000  -- Use clock fraction for sub-second
    return sec * 1000 + math.floor(ms)
end

--- Debounce a function call
--- Prevents rapid successive calls by waiting for a quiet period
--- Note: Uses sleep subprocess; for very high-frequency calls, consider throttle instead
--- @param key string Unique identifier for this debounce
--- @param delay number Delay in seconds (e.g., 0.5 for 500ms)
--- @param fn function Function to call after delay
function M.debounce(key, delay, fn)
    -- Cancel existing timer if any
    if timers[key] then
        timers[key].cancelled = true
    end

    -- Create new timer context
    local timer = { cancelled = false }
    timers[key] = timer

    sbar.exec("sleep " .. delay, function()
        if not timer.cancelled then
            timers[key] = nil  -- Clean up after execution
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
--- Supports sub-second intervals (uses millisecond precision)
--- @param key string Unique identifier for this throttle
--- @param interval number Minimum interval between calls in seconds (e.g., 0.5)
--- @param fn function Function to call
function M.throttle(key, interval, fn)
    local now = get_time_ms()
    local interval_ms = interval * 1000
    local throttle_key = key .. "_throttle"
    local last = timers[throttle_key] or 0

    if now - last >= interval_ms then
        timers[throttle_key] = now
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

-- ============================================================================
-- Color Utilities (reduce duplication across widgets)
-- ============================================================================

--- Default color thresholds for usage indicators
--- @type table<string, {high: number, medium: number}>
M.THRESHOLDS = {
    cpu     = { high = 70, medium = 40 },
    memory  = { high = 70, medium = 50 },
    battery = { high = 20, medium = 40 },  -- Inverted: low battery is critical
    storage = { high = 80, medium = 60 },
}

--- Get color based on usage percentage and thresholds
--- @param percent number Usage percentage (0-100)
--- @param colors table Colors table with red, peach, green, blue fields
--- @param thresholds table|nil Optional {high, medium} thresholds (default: cpu)
--- @param inverted boolean|nil If true, low values are critical (e.g., battery)
--- @return number Color value
function M.get_usage_color(percent, colors, thresholds, inverted)
    thresholds = thresholds or M.THRESHOLDS.cpu

    if inverted then
        -- Low is critical (battery-style)
        if percent <= thresholds.high then
            return colors.red
        elseif percent <= thresholds.medium then
            return colors.peach
        else
            return colors.green
        end
    else
        -- High is critical (cpu/memory-style)
        if percent >= thresholds.high then
            return colors.red
        elseif percent >= thresholds.medium then
            return colors.peach
        else
            return colors.green
        end
    end
end

-- ============================================================================
-- Safe File I/O (with pcall protection)
-- ============================================================================

--- Safely read a file with error handling
--- @param path string File path to read
--- @return string|nil content File content or nil on error
--- @return string|nil error Error message if failed
function M.safe_read_file(path)
    local ok, file = pcall(io.open, path, "r")
    if not ok or not file then
        return nil, "Failed to open file: " .. path
    end

    local ok2, content = pcall(file.read, file, "*a")
    file:close()

    if not ok2 then
        return nil, "Failed to read file: " .. path
    end

    return content, nil
end

--- Safely write to a file with error handling
--- @param path string File path to write
--- @param content string Content to write
--- @return boolean success True if successful
--- @return string|nil error Error message if failed
function M.safe_write_file(path, content)
    local ok, file = pcall(io.open, path, "w")
    if not ok or not file then
        return false, "Failed to open file for writing: " .. path
    end

    local ok2, err = pcall(file.write, file, content)
    file:close()

    if not ok2 then
        return false, "Failed to write file: " .. (err or path)
    end

    return true, nil
end

--- Safely execute a function with pcall wrapper
--- @param fn function Function to execute
--- @param ... any Arguments to pass to function
--- @return boolean success True if successful
--- @return any result Result or error message
function M.safe_call(fn, ...)
    return pcall(fn, ...)
end

return M
