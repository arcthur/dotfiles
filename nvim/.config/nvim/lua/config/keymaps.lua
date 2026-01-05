-- Keymaps using chainable DSL (inspired by nvimdots)
local bind = require("config.bind")

-- Shorthand aliases
local cr = bind.map_cr       -- :cmd<CR>
local cmd = bind.map_cmd     -- raw command
local cu = bind.map_cu       -- :<C-u>cmd<CR>
local cb = bind.map_callback -- Lua function

-- ============================================
-- All Keymaps
-- ============================================
bind.load({
  -- === FILE OPERATIONS ===
  ["n|<C-s>"]       = cr("w"):with_desc("Save file"),
  ["i|<C-s>"]       = cmd("<Esc><cmd>w<CR>a"):with_desc("Save file"),
  ["n|<C-q>"]       = cr("q"):with_desc("Quit"),
  ["n|<leader>bn"]  = cr("enew"):with_desc("buffer: New"),

  -- === QUICK ACCESS (Ctrl+) ===
  ["n|<C-p>"]       = cr("Telescope find_files"):with_desc("Find files"),
  ["n|<C-b>"]       = cr("NvimTreeToggle"):with_desc("Toggle file tree"),

  -- === VISUAL SELECTION SEARCH ===
  ["v|<leader>fs"]  = cb(function()
    vim.cmd('noau normal! "vy')
    local text = vim.fn.getreg("v")
    text = vim.fn.trim(text:gsub("\n", " "))
    if text ~= "" then
      require("telescope.builtin").grep_string({ search = text })
    end
  end):with_desc("Search selection"),

  -- === BUFFER (leader+b) ===
  ["n|<leader>bd"]  = cr("bdelete"):with_desc("buffer: Delete"),
  ["n|<leader>bo"]  = cr("BufferLineCloseOthers"):with_desc("buffer: Close others"),
  ["n|<leader>bp"]  = cr("BufferLinePick"):with_desc("buffer: Pick"),
  ["n|<A-i>"]       = cr("BufferLineCycleNext"):with_silent():with_desc("buffer: Next"),
  ["n|<A-o>"]       = cr("BufferLineCyclePrev"):with_silent():with_desc("buffer: Prev"),
  ["n|<A-S-i>"]     = cr("BufferLineMoveNext"):with_silent():with_desc("buffer: Move next"),
  ["n|<A-S-o>"]     = cr("BufferLineMovePrev"):with_silent():with_desc("buffer: Move prev"),
  ["n|<A-1>"]       = cr("BufferLineGoToBuffer 1"):with_silent():with_desc("buffer: Goto 1"),
  ["n|<A-2>"]       = cr("BufferLineGoToBuffer 2"):with_silent():with_desc("buffer: Goto 2"),
  ["n|<A-3>"]       = cr("BufferLineGoToBuffer 3"):with_silent():with_desc("buffer: Goto 3"),
  ["n|<A-4>"]       = cr("BufferLineGoToBuffer 4"):with_silent():with_desc("buffer: Goto 4"),
  ["n|<A-5>"]       = cr("BufferLineGoToBuffer 5"):with_silent():with_desc("buffer: Goto 5"),
  ["n|<A-q>"]       = cr("bdelete"):with_silent():with_desc("buffer: Close"),

  -- === TAB ===
  ["n|<leader>tn"]  = cr("tabnew"):with_desc("tab: New"),
  ["n|<leader>tc"]  = cr("tabclose"):with_desc("tab: Close"),
  ["n|<leader>to"]  = cr("tabonly"):with_desc("tab: Close others"),
  ["n|]<Tab>"]      = cr("tabnext"):with_desc("tab: Next"),
  ["n|[<Tab>"]      = cr("tabprevious"):with_desc("tab: Prev"),

  -- === EDITOR ===
  ["n|<C-/>"]       = cmd("gcc"):with_remap():with_desc("Toggle comment"),
  ["v|<C-/>"]       = cmd("gc"):with_remap():with_desc("Toggle comment"),
  ["n|<C-a>"]       = cmd("ggVG"):with_desc("Select all"),

  -- === LINE OPERATIONS (Alt+Arrow) ===
  ["n|<A-Up>"]      = cmd("<cmd>m .-2<CR>=="):with_silent():with_desc("Move line up"),
  ["n|<A-Down>"]    = cmd("<cmd>m .+1<CR>=="):with_silent():with_desc("Move line down"),
  ["i|<A-Up>"]      = cmd("<Esc><cmd>m .-2<CR>==gi"):with_silent():with_desc("Move line up"),
  ["i|<A-Down>"]    = cmd("<Esc><cmd>m .+1<CR>==gi"):with_silent():with_desc("Move line down"),
  ["v|<A-Up>"]      = cmd(":m '<-2<CR>gv=gv"):with_silent():with_desc("Move lines up"),
  ["v|<A-Down>"]    = cmd(":m '>+1<CR>gv=gv"):with_silent():with_desc("Move lines down"),
  ["n|<A-S-Up>"]    = cmd("yyP"):with_desc("Duplicate line up"),
  ["n|<A-S-Down>"]  = cmd("yyp"):with_desc("Duplicate line down"),
  ["v|J"]           = cmd(":m '>+1<CR>gv=gv"):with_silent():with_desc("Move lines down"),
  ["v|K"]           = cmd(":m '<-2<CR>gv=gv"):with_silent():with_desc("Move lines up"),

  -- === WINDOW/SPLIT ===
  ["n|<C-\\>"]      = cr("vsplit"):with_desc("Split right"),
  ["n|<leader>wv"]  = cr("vsplit"):with_desc("window: Split vertical"),
  ["n|<leader>ws"]  = cr("split"):with_desc("window: Split horizontal"),
  ["n|<leader>wc"]  = cr("close"):with_desc("window: Close"),
  ["n|<leader>wo"]  = cr("only"):with_desc("window: Close others"),

  -- === BETTER DEFAULTS ===
  ["n|<Esc>"]       = cr("nohlsearch"):with_silent():with_desc("Clear search highlight"),
  ["v|<"]           = cmd("<gv"):with_desc("Indent left"),
  ["v|>"]           = cmd(">gv"):with_desc("Indent right"),
  ["n|J"]           = cmd("mzJ`z"):with_desc("Join lines (keep cursor)"),
  ["n|n"]           = cmd("nzzzv"):with_desc("Next match (centered)"),
  ["n|N"]           = cmd("Nzzzv"):with_desc("Prev match (centered)"),
  ["n|<C-d>"]       = cmd("<C-d>zz"):with_desc("Half page down (centered)"),
  ["n|<C-u>"]       = cmd("<C-u>zz"):with_desc("Half page up (centered)"),
  ["n|Y"]           = cmd("y$"):with_desc("Yank to EOL"),
  ["n|D"]           = cmd("d$"):with_desc("Delete to EOL"),

  -- === FILETREE (leader+n) ===
  ["n|<leader>nf"]  = cr("NvimTreeFindFile"):with_desc("filetree: Find file"),
  ["n|<leader>nr"]  = cr("NvimTreeRefresh"):with_desc("filetree: Refresh"),

  -- === LSP (leader+l) ===
  ["n|<leader>li"]  = cr("LspInfo"):with_desc("lsp: Info"),
  ["n|<leader>lr"]  = cr("LspRestart"):with_desc("lsp: Restart"),
  ["n|gK"]          = cb(function()
    local ok, blink = pcall(require, "blink.cmp")
    if not ok then return end
    if blink.is_signature_visible() then
      blink.hide_signature()
    else
      blink.show_signature()
    end
  end):with_desc("Signature help (blink)"),

  -- === WHICH-KEY GROUPS ===
  ["n|<leader>f"]   = cmd(""):with_desc("+find"),
  ["n|<leader>g"]   = cmd(""):with_desc("+git"),
  ["n|<leader>s"]   = cmd(""):with_desc("+search/replace"),
  ["n|<leader>q"]   = cmd(""):with_desc("+session"),
  ["n|<leader>x"]   = cmd(""):with_desc("+diagnostics"),
  ["n|<leader>b"]   = cmd(""):with_desc("+buffer"),
  ["n|<leader>w"]   = cmd(""):with_desc("+window"),
  ["n|<leader>n"]   = cmd(""):with_desc("+filetree"),
  ["n|<leader>l"]   = cmd(""):with_desc("+lsp"),
  ["n|<leader>t"]   = cmd(""):with_desc("+tab"),
})
