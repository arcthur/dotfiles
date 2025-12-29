-- =============================================================================
-- Unified Navigation: Neovim + Tmux + Zsh
-- =============================================================================
--
-- First Principles:
--   Ctrl+h/j/k/l = move left/down/up/right (consistent across all layers)
--   Each layer detects boundary and delegates to outer layer
--
-- Layer Model:
--   Neovim splits ──(boundary)──> Tmux panes
--   Zsh buffer ────(boundary)──> Tmux panes
--
-- Keybindings:
--   Ctrl+h/j/k/l     = Navigate splits/panes
--   Alt+h/j/k/l      = Resize splits
--   Leader+wH/J/K/L  = Swap buffers
--
return {
  {
    "mrjones2014/smart-splits.nvim",
    lazy = false,
    opts = {
      ignored_filetypes = { "nofile", "quickfix", "prompt" },
      ignored_buftypes = { "NvimTree" },
      at_edge = "stop",
      multiplexer_integration = "tmux",
      disable_multiplexer_nav_when_zoomed = true,
      cursor_follows_swapped_bufs = true,
    },
    keys = {
      -- Navigation: Ctrl+h/j/k/l (consistent with zsh)
      {
        "<C-h>",
        function() require("smart-splits").move_cursor_left() end,
        desc = "Navigate left",
        mode = { "n", "i", "t" },
      },
      {
        "<C-j>",
        function() require("smart-splits").move_cursor_down() end,
        desc = "Navigate down",
        mode = { "n", "i", "t" },
      },
      {
        "<C-k>",
        function() require("smart-splits").move_cursor_up() end,
        desc = "Navigate up",
        mode = { "n", "i", "t" },
      },
      {
        "<C-l>",
        function() require("smart-splits").move_cursor_right() end,
        desc = "Navigate right",
        mode = { "n", "i", "t" },
      },
      -- Resize: Alt+h/j/k/l (consistent with tmux prefix+H/J/K/L)
      {
        "<A-h>",
        function() require("smart-splits").resize_left() end,
        desc = "Resize left",
        mode = { "n", "i", "t" },
      },
      {
        "<A-j>",
        function() require("smart-splits").resize_down() end,
        desc = "Resize down",
        mode = { "n", "i", "t" },
      },
      {
        "<A-k>",
        function() require("smart-splits").resize_up() end,
        desc = "Resize up",
        mode = { "n", "i", "t" },
      },
      {
        "<A-l>",
        function() require("smart-splits").resize_right() end,
        desc = "Resize right",
        mode = { "n", "i", "t" },
      },
      -- Swap: Leader+wH/J/K/L (window operations)
      {
        "<leader>wH",
        function() require("smart-splits").swap_buf_left() end,
        desc = "Swap buffer left",
      },
      {
        "<leader>wJ",
        function() require("smart-splits").swap_buf_down() end,
        desc = "Swap buffer down",
      },
      {
        "<leader>wK",
        function() require("smart-splits").swap_buf_up() end,
        desc = "Swap buffer up",
      },
      {
        "<leader>wL",
        function() require("smart-splits").swap_buf_right() end,
        desc = "Swap buffer right",
      },
    },
  },
}
