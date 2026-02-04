-- Autocmds (inspired by nvimdots)

local autocmd = vim.api.nvim_create_autocmd
local augroup = vim.api.nvim_create_augroup

-- Auto close special filetypes with 'q'
autocmd("FileType", {
  group = augroup("close_with_q", { clear = true }),
  pattern = {
    "qf", "help", "man", "notify",
    "lspinfo", "spectre_panel", "startuptime",
    "checkhealth", "grug-far", "grug-far-help", "grug-far-history",
    "trouble",
  },
  callback = function(event)
    vim.bo[event.buf].buflisted = false
    vim.keymap.set("n", "q", "<cmd>close<CR>", { buffer = event.buf, silent = true })
  end,
})

-- Auto jump to last edit position
autocmd("BufReadPost", {
  group = augroup("last_edit_position", { clear = true }),
  callback = function()
    local mark = vim.api.nvim_buf_get_mark(0, '"')
    local lcount = vim.api.nvim_buf_line_count(0)
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

-- Highlight on yank
autocmd("TextYankPost", {
  group = augroup("highlight_yank", { clear = true }),
  callback = function()
    vim.highlight.on_yank({ higroup = "IncSearch", timeout = 200 })
  end,
})

-- Check if file changed when focused
autocmd("FocusGained", {
  group = augroup("checktime", { clear = true }),
  pattern = "*",
  command = "checktime",
})

-- Resize splits when window resized
autocmd("VimResized", {
  group = augroup("resize_splits", { clear = true }),
  callback = function()
    vim.cmd("tabdo wincmd =")
  end,
})

-- Auto create parent directories when saving
autocmd("BufWritePre", {
  group = augroup("auto_create_dir", { clear = true }),
  callback = function(event)
    if event.match:match("^%w%w+://") then
      return
    end
    local file = vim.uv.fs_realpath(event.match) or vim.fs.abspath(event.match)
    local dir = vim.fs.dirname(file)
    if dir and dir ~= "" then
      vim.fn.mkdir(dir, "p")
    end
  end,
})

-- Disable undo for certain files
autocmd("BufWritePre", {
  group = augroup("no_undo_temp", { clear = true }),
  pattern = { "/tmp/*", "*.tmp", "*.bak", "COMMIT_EDITMSG", "MERGE_MSG" },
  callback = function()
    vim.opt_local.undofile = false
  end,
})

-- Highlight cursorline only in active window
autocmd({ "WinEnter", "BufEnter", "InsertLeave" }, {
  group = augroup("cursorline_active", { clear = true }),
  callback = function()
    if vim.bo.filetype ~= "alpha" and not vim.wo.previewwindow then
      vim.wo.cursorline = true
    end
  end,
})

autocmd({ "WinLeave", "BufLeave", "InsertEnter" }, {
  group = augroup("cursorline_inactive", { clear = true }),
  callback = function()
    if vim.bo.filetype ~= "alpha" and not vim.wo.previewwindow then
      vim.wo.cursorline = false
    end
  end,
})

-- Wrap and spell check in text files
autocmd("FileType", {
  group = augroup("wrap_text", { clear = true }),
  pattern = { "markdown", "text", "gitcommit" },
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.spell = true
  end,
})

-- Auto close NvimTree when it's the last window
-- From nvimdots: prevents leaving an empty file tree
autocmd("BufEnter", {
  group = augroup("nvimtree_auto_close", { clear = true }),
  pattern = "NvimTree_*",
  callback = function()
    local layout = vim.api.nvim_call_function("winlayout", {})
    -- layout[1] == "leaf" means only one window remains
    -- Check if that window is NvimTree
    if
      layout[1] == "leaf"
      and vim.bo[vim.api.nvim_win_get_buf(layout[2])].filetype == "NvimTree"
      and layout[3] == nil
    then
      vim.api.nvim_command([[confirm quit]])
    end
  end,
})
