-- helpers/init.lua
-- Helper utilities and event provider management

local M = {}

local home = os.getenv("HOME")

-- Global config directory
M.config_dir = home .. "/.config/sketchybar"
M.plugin_dir = M.config_dir .. "/plugins"
M.provider_dir = M.config_dir .. "/helpers/event_providers"

-- Start event providers (compile if needed and launch)
-- Called automatically when this module is loaded
function M.start_providers(base_interval)
    base_interval = base_interval or 2

    -- Kill existing providers first
    os.execute("killall cpu memory network battery 2>/dev/null")

    -- Compile and start each provider
    -- CPU provider
    sbar.exec(string.format(
        "(cd %s/cpu_load && make -s 2>/dev/null); %s/cpu_load/cpu %d cpu_update &",
        M.provider_dir, M.provider_dir, base_interval
    ))

    -- Memory provider
    sbar.exec(string.format(
        "(cd %s/memory_load && make -s 2>/dev/null); %s/memory_load/memory %d memory_update &",
        M.provider_dir, M.provider_dir, base_interval
    ))

    -- Network provider
    sbar.exec(string.format(
        "(cd %s/network_load && make -s 2>/dev/null); %s/network_load/network en0 %d network_update &",
        M.provider_dir, M.provider_dir, base_interval
    ))

    -- Battery provider (adaptive interval, no base_interval needed)
    sbar.exec(string.format(
        "(cd %s/battery_load && make -s 2>/dev/null); %s/battery_load/battery battery_update &",
        M.provider_dir, M.provider_dir
    ))
end

return M
