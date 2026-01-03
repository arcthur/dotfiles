-- Productivity plugins
return {
  -- Flash: Fast navigation
  {
    "folke/flash.nvim",
    event = "VeryLazy",
    opts = {
      modes = {
        char = { enabled = true },
        search = { enabled = false },
      },
    },
    keys = {
      { "s", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash" },
      { "S", mode = { "n", "x", "o" }, function() require("flash").treesitter() end, desc = "Flash Treesitter" },
      { "r", mode = "o", function() require("flash").remote() end, desc = "Remote Flash" },
      { "R", mode = { "o", "x" }, function() require("flash").treesitter_search() end, desc = "Treesitter Search" },
      { "<c-s>", mode = { "c" }, function() require("flash").toggle() end, desc = "Toggle Flash Search" },
    },
  },

  -- Grug-far: Search and replace
  {
    "MagicDuck/grug-far.nvim",
    cmd = "GrugFar",
    keys = {
      { "<leader>sr", function() require("grug-far").open() end, desc = "Search & replace" },
      { "<leader>sw", function() require("grug-far").open({ prefills = { search = vim.fn.expand("<cword>") } }) end, desc = "Search word" },
      { "<leader>sf", function() require("grug-far").open({ prefills = { paths = vim.fn.expand("%") } }) end, desc = "Search in file" },
    },
    opts = {
      headerMaxWidth = 80,
    },
  },

  -- Persistence: Session management
  {
    "folke/persistence.nvim",
    event = "BufReadPre",
    opts = {
      dir = vim.fn.stdpath("state") .. "/sessions/",
      options = { "buffers", "curdir", "tabpages", "winsize" },
    },
    keys = {
      { "<leader>qs", function() require("persistence").load() end, desc = "Restore session" },
      { "<leader>ql", function() require("persistence").load({ last = true }) end, desc = "Restore last session" },
      { "<leader>qd", function() require("persistence").stop() end, desc = "Don't save session" },
    },
  },

  -- Smart-splits: Unified tmux/neovim navigation
  {
    "mrjones2014/smart-splits.nvim",
    lazy = false,
    config = function()
      require("smart-splits").setup({
        ignored_filetypes = { "NvimTree", "neo-tree", "qf" },
        ignored_buftypes = { "nofile", "quickfix", "prompt", "terminal" },
        -- Disable tmux integration - tmux already forwards C-hjkl to neovim
        at_edge = "stop",
      })

      -- Navigation keymaps
      vim.keymap.set("n", "<C-h>", require("smart-splits").move_cursor_left, { desc = "Move to left split" })
      vim.keymap.set("n", "<C-j>", require("smart-splits").move_cursor_down, { desc = "Move to lower split" })
      vim.keymap.set("n", "<C-k>", require("smart-splits").move_cursor_up, { desc = "Move to upper split" })
      vim.keymap.set("n", "<C-l>", require("smart-splits").move_cursor_right, { desc = "Move to right split" })

      -- Resize keymaps
      vim.keymap.set("n", "<A-h>", require("smart-splits").resize_left, { desc = "Resize left" })
      vim.keymap.set("n", "<A-j>", require("smart-splits").resize_down, { desc = "Resize down" })
      vim.keymap.set("n", "<A-k>", require("smart-splits").resize_up, { desc = "Resize up" })
      vim.keymap.set("n", "<A-l>", require("smart-splits").resize_right, { desc = "Resize right" })
    end,
  },
}
