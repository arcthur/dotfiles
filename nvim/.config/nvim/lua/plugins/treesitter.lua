-- Treesitter - Syntax highlighting & structure
local settings = require("config.settings")

return {
  -- Main treesitter
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "master", -- Use master branch as recommended
    lazy = false, -- Treesitter does NOT support lazy-loading
    build = ":TSUpdate",
    config = function()
      ---@diagnostic disable-next-line: missing-fields
      require("nvim-treesitter.configs").setup({
        ensure_installed = settings.treesitter_parsers,
        sync_install = false,
        auto_install = true,
        highlight = {
          enable = true,
          additional_vim_regex_highlighting = false,
        },
        indent = { enable = true },
        incremental_selection = {
          enable = true,
          keymaps = {
            init_selection = "<leader>v",
            node_incremental = "<leader>v",
            scope_incremental = false,
            node_decremental = "<bs>",
          },
        },
      })
    end,
  },

  -- Treesitter context (sticky header)
  {
    "nvim-treesitter/nvim-treesitter-context",
    event = { "BufReadPost", "BufNewFile" },
    opts = {
      enable = true,
      max_lines = 3,
      min_window_height = 0,
      line_numbers = true,
      multiline_threshold = 20,
      trim_scope = "outer",
      mode = "cursor",
    },
    keys = {
      { "[c", function() require("treesitter-context").go_to_context() end, desc = "Go to context" },
    },
  },

  -- Indent guides
  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      require("ibl").setup({
        indent = { char = "│", tab_char = "│" },
        scope = { enabled = true, show_start = false, show_end = false },
        exclude = {
          filetypes = {
            "help",
            "lazy",
            "mason",
            "NvimTree",
            "alpha",
            "trouble",
            "grug-far",
            "grug-far-help",
            "grug-far-history",
            "qf",
            "lspinfo",
          },
        },
      })
    end,
  },
}
