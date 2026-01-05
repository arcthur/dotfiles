-- Neovim Config (pure lazy.nvim)
-- Optimized for fast startup (inspired by nvimdots)

-- ============================================
-- Performance: Early optimizations
-- ============================================

-- Enable faster Lua loader (Neovim 0.9+)
if vim.loader then
  vim.loader.enable()
end

-- Disable unused providers (saves ~10-20ms)
vim.g.loaded_python3_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_node_provider = 0

-- Leader key (must be before lazy)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- ============================================
-- Bootstrap lazy.nvim
-- ============================================
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.uv.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- ============================================
-- Load core config
-- ============================================
require("config.options")
require("config.keymaps")
require("config.autocmds")

-- ============================================
-- Load plugins with optimized settings
-- ============================================
require("lazy").setup("plugins", {
  defaults = {
    lazy = true,  -- All plugins are lazy-loaded by default
  },
  install = {
    colorscheme = { "catppuccin", "tokyonight" },
  },
  checker = {
    enabled = true,
    notify = false,  -- Don't spam notifications
    frequency = 3600 * 24,  -- Check once per day
  },
  change_detection = {
    enabled = true,
    notify = false,  -- Silent reload
  },
  performance = {
    cache = {
      enabled = true,
    },
    reset_packpath = true,  -- Reset packpath for faster startup
    rtp = {
      reset = true,  -- Reset rtp to improve startup time
      disabled_plugins = {
        -- Disable unused built-in plugins
        "2html_plugin",
        "tohtml",
        "getscript",
        "getscriptPlugin",
        "gzip",
        "logipat",
        "netrw",
        "netrwPlugin",
        "netrwSettings",
        "netrwFileHandlers",
        "matchit",
        "matchparen",
        "tar",
        "tarPlugin",
        "rrhelper",
        "spellfile_plugin",
        "vimball",
        "vimballPlugin",
        "zip",
        "zipPlugin",
        "tutor",
        "rplugin",
        "syntax",
        "synmenu",
        "optwin",
        "compiler",
        "bugreport",
        "ftplugin",
        -- Keep these if needed:
        -- "editorconfig",  -- Useful for project settings
      },
    },
  },
  ui = {
    border = "rounded",
    backdrop = 100,
  },
})
