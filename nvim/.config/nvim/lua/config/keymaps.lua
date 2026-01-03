-- Keymaps
local map = vim.keymap.set

-- === FILE OPERATIONS ===
map("n", "<C-s>", "<cmd>w<CR>", { desc = "Save file" })
map("i", "<C-s>", "<Esc><cmd>w<CR>a", { desc = "Save file" })
map("n", "<C-q>", "<cmd>q<CR>", { desc = "Quit" })
map("n", "<leader>bn", "<cmd>enew<CR>", { desc = "buffer: New" })

-- === QUICK ACCESS (Ctrl+) ===
map("n", "<C-p>", "<cmd>Telescope find_files<CR>", { desc = "Find files" })
map("n", "<C-b>", "<cmd>NvimTreeToggle<CR>", { desc = "Toggle file tree" })

-- Note: <leader>f* Telescope keymaps are defined in plugins/telescope.lua
-- Visual mode grep selection (not in telescope.lua)
map("v", "<leader>fs", function()
  -- Get actual visual selection
  vim.cmd('noau normal! "vy')
  local text = vim.fn.getreg("v")
  text = vim.fn.trim(text:gsub("\n", " "))
  if text == "" then
    return
  end
  require("telescope.builtin").grep_string({ search = text })
end, { desc = "Search selection" })

-- === BUFFER (leader+b) ===
map("n", "<leader>bd", "<cmd>bdelete<CR>", { desc = "buffer: Delete" })
map("n", "<leader>bo", "<cmd>BufferLineCloseOthers<CR>", { desc = "buffer: Close others" })
map("n", "<leader>bp", "<cmd>BufferLinePick<CR>", { desc = "buffer: Pick" })
map("n", "<A-i>", "<cmd>BufferLineCycleNext<CR>", { desc = "buffer: Next", silent = true })
map("n", "<A-o>", "<cmd>BufferLineCyclePrev<CR>", { desc = "buffer: Prev", silent = true })
map("n", "<A-S-i>", "<cmd>BufferLineMoveNext<CR>", { desc = "buffer: Move next", silent = true })
map("n", "<A-S-o>", "<cmd>BufferLineMovePrev<CR>", { desc = "buffer: Move prev", silent = true })
map("n", "<A-1>", "<cmd>BufferLineGoToBuffer 1<CR>", { silent = true, desc = "buffer: Goto 1" })
map("n", "<A-2>", "<cmd>BufferLineGoToBuffer 2<CR>", { silent = true, desc = "buffer: Goto 2" })
map("n", "<A-3>", "<cmd>BufferLineGoToBuffer 3<CR>", { silent = true, desc = "buffer: Goto 3" })
map("n", "<A-4>", "<cmd>BufferLineGoToBuffer 4<CR>", { silent = true, desc = "buffer: Goto 4" })
map("n", "<A-5>", "<cmd>BufferLineGoToBuffer 5<CR>", { silent = true, desc = "buffer: Goto 5" })
map("n", "<A-q>", "<cmd>bdelete<CR>", { desc = "buffer: Close", silent = true })

-- === TAB (<leader>t prefix, avoids breaking t{char} motion) ===
map("n", "<leader>tn", "<cmd>tabnew<CR>", { desc = "tab: New" })
map("n", "<leader>tc", "<cmd>tabclose<CR>", { desc = "tab: Close" })
map("n", "<leader>to", "<cmd>tabonly<CR>", { desc = "tab: Close others" })
map("n", "]<Tab>", "<cmd>tabnext<CR>", { desc = "tab: Next" })
map("n", "[<Tab>", "<cmd>tabprevious<CR>", { desc = "tab: Prev" })

-- === EDITOR ===
-- Note: <C-a> overrides number increment; use g<C-a> for visual increment if needed
map("n", "<C-/>", "gcc", { desc = "Toggle comment", remap = true })
map("v", "<C-/>", "gc", { desc = "Toggle comment", remap = true })
map("n", "<C-a>", "ggVG", { desc = "Select all" })

-- === LINE OPERATIONS (Alt+Arrow) ===
map("n", "<A-Up>", "<cmd>m .-2<CR>==", { desc = "Move line up", silent = true })
map("n", "<A-Down>", "<cmd>m .+1<CR>==", { desc = "Move line down", silent = true })
map("i", "<A-Up>", "<Esc><cmd>m .-2<CR>==gi", { desc = "Move line up", silent = true })
map("i", "<A-Down>", "<Esc><cmd>m .+1<CR>==gi", { desc = "Move line down", silent = true })
map("v", "<A-Up>", ":m '<-2<CR>gv=gv", { desc = "Move lines up", silent = true })
map("v", "<A-Down>", ":m '>+1<CR>gv=gv", { desc = "Move lines down", silent = true })
map("n", "<A-S-Up>", "yyP", { desc = "Duplicate line up" })
map("n", "<A-S-Down>", "yyp", { desc = "Duplicate line down" })
map("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move lines down", silent = true })
map("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move lines up", silent = true })

-- === WINDOW/SPLIT ===
map("n", "<C-\\>", "<cmd>vsplit<CR>", { desc = "Split right" })
map("n", "<leader>wv", "<cmd>vsplit<CR>", { desc = "window: Split vertical" })
map("n", "<leader>ws", "<cmd>split<CR>", { desc = "window: Split horizontal" })
map("n", "<leader>wc", "<cmd>close<CR>", { desc = "window: Close" })
map("n", "<leader>wo", "<cmd>only<CR>", { desc = "window: Close others" })

-- === BETTER DEFAULTS ===
map("n", "<Esc>", "<cmd>nohlsearch<CR>", { silent = true, desc = "Clear search highlight" })
map("v", "<", "<gv", { desc = "Indent left" })
map("v", ">", ">gv", { desc = "Indent right" })
map("n", "J", "mzJ`z", { desc = "Join lines (keep cursor)" })
map("n", "n", "nzzzv", { desc = "Next match (centered)" })
map("n", "N", "Nzzzv", { desc = "Prev match (centered)" })
map("n", "<C-d>", "<C-d>zz", { desc = "Half page down (centered)" })
map("n", "<C-u>", "<C-u>zz", { desc = "Half page up (centered)" })
map("n", "Y", "y$", { desc = "Yank to EOL" })
map("n", "D", "d$", { desc = "Delete to EOL" })

-- === FILETREE (leader+n) ===
-- Note: <leader>e is mapped in editor.lua (nvim-tree plugin)
map("n", "<leader>nf", "<cmd>NvimTreeFindFile<CR>", { desc = "filetree: Find file" })
map("n", "<leader>nr", "<cmd>NvimTreeRefresh<CR>", { desc = "filetree: Refresh" })

-- === LSP (leader+l) ===
map("n", "<leader>li", "<cmd>LspInfo<CR>", { desc = "lsp: Info" })
map("n", "<leader>lr", "<cmd>LspRestart<CR>", { desc = "lsp: Restart" })
map("n", "gK", function()
  local ok, blink = pcall(require, "blink.cmp")
  if not ok then
    return
  end
  if blink.is_signature_visible() then
    blink.hide_signature()
  else
    blink.show_signature()
  end
end, { desc = "Signature help (blink)" })

-- === WHICH-KEY GROUPS ===
map("n", "<leader>f", "", { desc = "+find" })
map("n", "<leader>g", "", { desc = "+git" })
map("n", "<leader>s", "", { desc = "+search/replace" })
map("n", "<leader>q", "", { desc = "+session" })
map("n", "<leader>x", "", { desc = "+diagnostics" })
map("n", "<leader>b", "", { desc = "+buffer" })
map("n", "<leader>w", "", { desc = "+window" })
map("n", "<leader>n", "", { desc = "+filetree" })
map("n", "<leader>l", "", { desc = "+lsp" })
