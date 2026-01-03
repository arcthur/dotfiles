-- Centralized settings (inspired by nvimdots)
-- All user-configurable options in one place

local settings = {}

-- ============================================
-- Theme & Appearance
-- ============================================

-- Colorscheme: "catppuccin", "catppuccin-mocha", "tokyonight"
---@type string
settings.colorscheme = "catppuccin"

-- Catppuccin flavour: "latte", "frappe", "macchiato", "mocha"
---@type string
settings.catppuccin_flavour = "mocha"

-- Enable transparent background
---@type boolean
settings.transparent_background = false

-- Background mode: "dark" or "light"
---@type "dark"|"light"
settings.background = "dark"

-- ============================================
-- Editor Behavior
-- ============================================

-- Format on save
---@type boolean
settings.format_on_save = true

-- Format timeout in milliseconds
---@type number
settings.format_timeout = 500

-- Show diagnostics virtual text
---@type boolean
settings.diagnostics_virtual_text = true

-- ============================================
-- LSP Servers
-- ============================================

-- LSP servers to install via Mason
---@type string[]
settings.lsp_servers = {
  "lua_ls",
  "ts_ls",
  "pyright",
  "jsonls",
  "yamlls",
  "html",
  "cssls",
}

-- ============================================
-- Formatters (conform.nvim)
-- ============================================

---@type table<string, string[]>
settings.formatters_by_ft = {
  lua = { "stylua" },
  javascript = { "prettier" },
  typescript = { "prettier" },
  javascriptreact = { "prettier" },
  typescriptreact = { "prettier" },
  json = { "prettier" },
  yaml = { "prettier" },
  markdown = { "prettier" },
  html = { "prettier" },
  css = { "prettier" },
  python = { "black" },
}

-- Extra tools to install via mason-tool-installer (formatters are inferred from formatters_by_ft)
---@type string[]
settings.mason_tools = {
  "stylua",     -- Lua formatter
  "prettier",   -- JS/TS/JSON/YAML/MD formatter
  "black",      -- Python formatter
  "shfmt",      -- Shell formatter
}

-- ============================================
-- Treesitter Parsers
-- ============================================

---@type string[]
settings.treesitter_parsers = {
  "lua", "vim", "vimdoc", "query",
  "javascript", "typescript", "tsx",
  "python", "go", "rust", "c", "cpp",
  "json", "yaml", "toml", "markdown", "markdown_inline",
  "html", "css", "bash", "regex",
}

-- ============================================
-- GUI Settings (Neovide, etc.)
-- ============================================

---@type { font_name: string, font_size: number }
settings.gui_config = {
  font_name = "JetBrainsMono Nerd Font",
  font_size = 14,
}

return settings
