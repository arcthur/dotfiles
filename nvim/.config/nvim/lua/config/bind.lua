-- Keymap binding DSL (inspired by nvimdots)
-- Provides a fluent/chainable API for defining keymaps
--
-- Usage:
--   local bind = require("config.bind")
--
--   -- Simple command
--   bind.map_cr("Telescope find_files"):with_silent():with_desc("Find files")
--
--   -- With callback
--   bind.map_callback(function() print("hello") end):with_desc("Say hello")
--
--   -- Load mappings
--   bind.load({
--     ["n|<leader>ff"] = bind.map_cr("Telescope find_files"):with_silent():with_desc("Find files"),
--     ["nv|<leader>cf"] = bind.map_cr("ConformFormat"):with_desc("Format"),
--   })

---@class map_rhs
---@field cmd string
---@field options table
---@field buffer boolean|number
local rhs_options = {}

---Create new map_rhs instance
---@return map_rhs
function rhs_options:new()
  local instance = {
    cmd = "",
    options = {
      noremap = true,  -- Match vim.keymap.set default
      silent = false,
      expr = false,
      nowait = false,
      callback = nil,
      desc = nil,
    },
    buffer = false,
  }
  setmetatable(instance, self)
  self.__index = self
  return instance
end

---Map a raw command string
---@param cmd_string string
---@return map_rhs
function rhs_options:map_cmd(cmd_string)
  self.cmd = cmd_string
  return self
end

---Map a command with <CR> suffix (e.g., ":Telescope find_files<CR>")
---@param cmd_string string
---@return map_rhs
function rhs_options:map_cr(cmd_string)
  self.cmd = (":%s<CR>"):format(cmd_string)
  return self
end

---Map a command with <Space> suffix for arguments (e.g., ":Git<Space>")
---@param cmd_string string
---@return map_rhs
function rhs_options:map_args(cmd_string)
  self.cmd = (":%s<Space>"):format(cmd_string)
  return self
end

---Map a command with <C-u> prefix (clears range in visual mode)
---@param cmd_string string
---@return map_rhs
function rhs_options:map_cu(cmd_string)
  self.cmd = (":<C-u>%s<CR>"):format(cmd_string)
  return self
end

---Map a Lua callback function
---@param callback function
---@return map_rhs
function rhs_options:map_callback(callback)
  self.cmd = ""
  self.options.callback = callback
  return self
end

---Add silent option
---@return map_rhs
function rhs_options:with_silent()
  self.options.silent = true
  return self
end

---Add noremap option
---@return map_rhs
function rhs_options:with_noremap()
  self.options.noremap = true
  return self
end

---Add expr option (for expression mappings)
---@return map_rhs
function rhs_options:with_expr()
  self.options.expr = true
  return self
end

---Add nowait option
---@return map_rhs
function rhs_options:with_nowait()
  self.options.nowait = true
  return self
end

---Enable remap (allow recursive mapping)
---@return map_rhs
function rhs_options:with_remap()
  self.options.remap = true
  return self
end

---Add description
---@param desc string
---@return map_rhs
function rhs_options:with_desc(desc)
  self.options.desc = desc
  return self
end

---Set buffer-local mapping
---@param bufnr? number Buffer number (default: current buffer)
---@return map_rhs
function rhs_options:with_buffer(bufnr)
  self.buffer = bufnr or true
  return self
end

-- Module exports
local bind = {}

---Create a command mapping with <CR>
---@param cmd_string string
---@return map_rhs
function bind.map_cr(cmd_string)
  local ro = rhs_options:new()
  return ro:map_cr(cmd_string)
end

---Create a raw command mapping
---@param cmd_string string
---@return map_rhs
function bind.map_cmd(cmd_string)
  local ro = rhs_options:new()
  return ro:map_cmd(cmd_string)
end

---Create a command mapping with <C-u> prefix
---@param cmd_string string
---@return map_rhs
function bind.map_cu(cmd_string)
  local ro = rhs_options:new()
  return ro:map_cu(cmd_string)
end

---Create a command mapping with <Space> suffix
---@param cmd_string string
---@return map_rhs
function bind.map_args(cmd_string)
  local ro = rhs_options:new()
  return ro:map_args(cmd_string)
end

---Create a callback mapping
---@param callback function
---@return map_rhs
function bind.map_callback(callback)
  local ro = rhs_options:new()
  return ro:map_callback(callback)
end

---Escape terminal codes
---@param cmd_string string
---@return string
function bind.escape_termcode(cmd_string)
  return vim.api.nvim_replace_termcodes(cmd_string, true, true, true)
end

---Load a table of mappings
---Key format: "modes|keymap" (e.g., "n|<leader>ff", "nv|<C-s>")
---@param mappings table<string, map_rhs>
function bind.load(mappings)
  for key, value in pairs(mappings) do
    local modes, keymap = key:match("([^|]*)|?(.*)")
    if type(value) == "table" and value.cmd ~= nil then
      for _, mode in ipairs(vim.split(modes, "")) do
        local rhs = value.options.callback or value.cmd
        local opts = vim.tbl_extend("force", {}, value.options)

        -- Handle buffer-local mappings
        if value.buffer then
          opts.buffer = value.buffer == true and 0 or value.buffer
        end

        -- Use vim.keymap.set for all mappings (supports remap, callback, etc.)
        vim.keymap.set(mode, keymap, rhs, opts)
      end
    end
  end
end

return bind
