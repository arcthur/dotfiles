-- Format-on-save policy layer on top of conform.nvim.
-- Adds: runtime toggle (global + per-buffer), directory blocklist, filetype
-- blocklist, and "only format Git-changed lines" (gitsigns hunks + conform range).
local M = {}

local settings = require("config.settings")

-- Global on/off; per-buffer override lives in `vim.b.disable_autoformat`.
local enabled = settings.format_on_save ~= false

---@param bufnr integer
---@return boolean
local function in_disabled_dir(bufnr)
  local dirs = settings.format_disabled_dirs or {}
  if #dirs == 0 then
    return false
  end
  local name = vim.api.nvim_buf_get_name(bufnr)
  if name == "" then
    return false
  end
  local filedir = vim.fs.normalize(vim.fs.dirname(name))
  for _, dir in ipairs(dirs) do
    local ok, re = pcall(vim.regex, vim.fs.normalize(dir))
    if ok and re:match_str(filedir) ~= nil then
      return true
    end
  end
  return false
end

-- Changed line ranges (1-indexed, inclusive) from gitsigns hunks; nil if unavailable.
---@param bufnr integer
---@return { s: integer, e: integer }[]|nil
local function changed_ranges(bufnr)
  local ok, gitsigns = pcall(require, "gitsigns")
  if not ok then
    return nil
  end
  local hunks = gitsigns.get_hunks(bufnr)
  if not hunks or #hunks == 0 then
    return nil
  end
  local ranges = {}
  for _, hunk in ipairs(hunks) do
    -- Only added/changed lines exist in the current buffer (pure deletions have count 0).
    if hunk.type ~= "delete" and hunk.added and hunk.added.count > 0 then
      local s = hunk.added.start
      ranges[#ranges + 1] = { s = s, e = s + hunk.added.count - 1 }
    end
  end
  return ranges
end

-- Format a buffer, honoring the policy.
---@param bufnr? integer
---@param opts? { async?: boolean, whole?: boolean }
function M.format(bufnr, opts)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  opts = opts or {}

  local ft = vim.bo[bufnr].filetype
  if (settings.formatter_block_list or {})[ft] == true then
    return
  end

  local conform = require("conform")
  local base = {
    bufnr = bufnr,
    async = opts.async == true,
    timeout_ms = settings.format_timeout,
    lsp_format = "fallback",
  }

  local scope = "buffer"
  local ranges = (settings.format_modifications_only and not opts.whole) and changed_ranges(bufnr) or nil
  if ranges and #ranges > 0 then
    -- Format each hunk; bottom-to-top so earlier line numbers stay valid as text shifts.
    table.sort(ranges, function(a, b)
      return a.s > b.s
    end)
    for _, r in ipairs(ranges) do
      local last_line = vim.api.nvim_buf_get_lines(bufnr, r.e - 1, r.e, false)[1] or ""
      conform.format(vim.tbl_extend("force", base, {
        range = { start = { r.s, 0 }, ["end"] = { r.e, #last_line } },
      }))
    end
    scope = "changed lines"
  else
    conform.format(base)
  end

  if settings.format_notify then
    vim.notify("Formatted " .. scope, vim.log.levels.INFO, { title = "conform" })
  end
end

---@return boolean
function M.enabled()
  return enabled and not vim.b.disable_autoformat
end

---@param buffer? boolean @Toggle only the current buffer instead of the global switch.
function M.toggle(buffer)
  if buffer then
    vim.b.disable_autoformat = not vim.b.disable_autoformat
  else
    enabled = not enabled
  end
  vim.notify(
    ("format-on-save (%s): %s"):format(buffer and "buffer" or "global", M.enabled() and "on" or "off"),
    vim.log.levels.INFO,
    { title = "conform" }
  )
end

function M.setup()
  vim.api.nvim_create_autocmd("BufWritePre", {
    group = vim.api.nvim_create_augroup("user_format_on_save", { clear = true }),
    callback = function(args)
      if M.enabled() and not in_disabled_dir(args.buf) then
        M.format(args.buf, { async = false })
      end
    end,
  })

  vim.api.nvim_create_user_command("Format", function()
    M.format(0, { async = true, whole = true })
  end, { desc = "Format the whole buffer now" })

  vim.api.nvim_create_user_command("FormatToggle", function(a)
    M.toggle(a.bang)
  end, { bang = true, desc = 'Toggle format-on-save ("!" = current buffer only)' })
end

return M
