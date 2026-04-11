-- Treesitter - Syntax highlighting & structure
local settings = require("config.settings")

return {
  -- Main treesitter
  {
    "nvim-treesitter/nvim-treesitter",
    lazy = false, -- Treesitter does NOT support lazy-loading
    build = ":TSUpdate",
    config = function()
      local treesitter = require("nvim-treesitter")

      treesitter.setup({
        install_dir = vim.fs.joinpath(vim.fn.stdpath("data"), "site"),
      })

      local installed = {} ---@type table<string, boolean>
      for _, lang in ipairs(treesitter.get_installed("parsers")) do
        installed[lang] = true
      end

      local missing = vim.tbl_filter(function(lang)
        return not installed[lang]
      end, settings.treesitter_parsers)

      if #missing > 0 then
        treesitter.install(missing, { summary = #missing > 1 })
      end

      local group = vim.api.nvim_create_augroup("dotfiles_treesitter", { clear = true })

      vim.api.nvim_create_autocmd("FileType", {
        group = group,
        pattern = "*",
        callback = function(event)
          if vim.bo[event.buf].buftype ~= "" then
            return
          end

          if not pcall(vim.treesitter.start, event.buf) then
            return
          end

          vim.bo[event.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end,
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
