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
  local result = vim
    .system({
      "git",
      "clone",
      "--filter=blob:none",
      "https://github.com/folke/lazy.nvim.git",
      "--branch=stable",
      lazypath,
    }, { text = true })
    :wait()

  if result.code ~= 0 then
    vim.api.nvim_echo(
      { { ("Failed to clone lazy.nvim (exit=%d): %s"):format(result.code, result.stderr or ""), "ErrorMsg" } },
      true,
      { err = true }
    )
  end
end
vim.opt.rtp:prepend(lazypath)

-- ============================================
-- Load core config
-- ============================================
require("config.options")
require("config.gui")
require("config.keymaps")
require("config.autocmds")

-- ============================================
-- Load plugins with optimized settings
-- ============================================
require("lazy").setup("plugins", {
  defaults = {
    lazy = true, -- All plugins are lazy-loaded by default
  },
  rocks = {
    enabled = false, -- No plugin here needs luarocks; avoids hererocks health errors.
  },
  install = {
    colorscheme = { "catppuccin", "tokyonight" },
  },
  checker = {
    enabled = true,
    notify = false, -- Don't spam notifications
    frequency = 3600 * 24, -- Check once per day
  },
  change_detection = {
    enabled = true,
    notify = false, -- Silent reload
  },
  performance = {
    cache = {
      enabled = true,
    },
    reset_packpath = true, -- Reset packpath for faster startup
    rtp = {
      reset = true, -- Reset rtp to improve startup time
      -- Only names that exist under $VIMRUNTIME/plugin/ have any effect here.
      disabled_plugins = {
        "gzip",
        "matchit", -- replaced by vim-matchup
        "matchparen", -- replaced by vim-matchup
        "netrwPlugin", -- replaced by nvim-tree
        "rplugin", -- remote plugins unused (providers disabled above)
        "tarPlugin",
        "tutor",
        "zipPlugin",
      },
    },
  },
  ui = {
    border = "rounded",
    backdrop = 100,
  },
})
