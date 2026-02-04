-- GUI-only settings (e.g., Neovide, nvim-qt)
local settings = require("config.settings")

local function is_gui()
  if vim.g.neovide then
    return true
  end
  if vim.g.GuiLoaded then
    return true
  end
  return vim.fn.has("gui_running") == 1
end

if is_gui() and settings.gui_config then
  local font_name = settings.gui_config.font_name
  local font_size = settings.gui_config.font_size

  if type(font_name) == "string" and font_name ~= "" and type(font_size) == "number" and font_size > 0 then
    vim.opt.guifont = string.format("%s:h%d", font_name, font_size)
  end
end

