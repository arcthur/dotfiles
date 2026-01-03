-- UI plugins - theme, bufferline, statusline
local settings = require("config.settings")

return {
  -- Catppuccin theme
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    lazy = false,
    config = function()
      local transparent = settings.transparent_background

      require("catppuccin").setup({
        flavour = settings.catppuccin_flavour,
        background = { light = "latte", dark = "mocha" },
        transparent_background = transparent,
        term_colors = true,
        styles = {
          comments = { "italic" },
          functions = { "bold" },
          keywords = { "italic" },
          operators = { "bold" },
          conditionals = { "bold" },
          loops = { "bold" },
          booleans = { "bold", "italic" },
        },
        integrations = {
          blink_cmp = true,
          flash = true,
          gitsigns = true,
          grug_far = true,
          indent_blankline = { enabled = true, colored_indent_levels = false },
          mason = true,
          mini = { enabled = true },
          native_lsp = {
            enabled = true,
            virtual_text = {
              errors = { "italic" },
              hints = { "italic" },
              warnings = { "italic" },
              information = { "italic" },
            },
            underlines = {
              errors = { "underline" },
              hints = { "underline" },
              warnings = { "underline" },
              information = { "underline" },
            },
          },
          nvimtree = true,
          telescope = { enabled = true },
          treesitter = true,
          treesitter_context = true,
          which_key = true,
        },
        highlight_overrides = {
          all = function(cp)
            return {
              -- Floating windows
              NormalFloat = { fg = cp.text, bg = transparent and cp.none or cp.mantle },
              FloatBorder = {
                fg = transparent and cp.blue or cp.mantle,
                bg = transparent and cp.none or cp.mantle,
              },
              -- Cursor line number
              CursorLineNr = { fg = cp.green },
              -- Diagnostics
              DiagnosticVirtualTextError = { bg = cp.none },
              DiagnosticVirtualTextWarn = { bg = cp.none },
              DiagnosticVirtualTextInfo = { bg = cp.none },
              DiagnosticVirtualTextHint = { bg = cp.none },
              -- Mason
              MasonNormal = { link = "NormalFloat" },
              -- Indent blankline
              IblIndent = { fg = cp.surface0 },
              IblScope = { fg = cp.surface2, style = { "bold" } },
              -- Telescope
              TelescopeBorder = { fg = cp.blue, bg = transparent and cp.none or cp.mantle },
              TelescopeNormal = { bg = transparent and cp.none or cp.mantle },
              TelescopePromptNormal = { bg = transparent and cp.none or cp.surface0 },
              TelescopePromptBorder = { fg = cp.blue, bg = transparent and cp.none or cp.surface0 },
              TelescopePromptTitle = { fg = cp.base, bg = cp.blue },
              TelescopePreviewTitle = { fg = cp.base, bg = cp.green },
              TelescopeResultsTitle = { fg = cp.base, bg = cp.lavender },
              -- Pmenu
              Pmenu = { bg = transparent and cp.none or cp.surface0 },
              PmenuSel = { bg = cp.surface1, style = { "bold" } },
            }
          end,
        },
      })
      vim.cmd.colorscheme(settings.colorscheme)
    end,
  },

  -- Tokyonight (alternative theme)
  {
    "folke/tokyonight.nvim",
    lazy = true,
    opts = {
      style = "night",
      transparent = settings.transparent_background,
    },
  },

  -- Lualine: Statusline
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    event = "VeryLazy",
    opts = {
      options = {
        theme = "catppuccin",
        component_separators = { left = "", right = "" },
        section_separators = { left = "", right = "" },
        globalstatus = true,
      },
      sections = {
        lualine_a = { "mode" },
        lualine_b = { "branch", "diff", "diagnostics" },
        lualine_c = { { "filename", path = 1 } },
        lualine_x = { "encoding", "fileformat", "filetype" },
        lualine_y = { "progress" },
        lualine_z = { "location" },
      },
      extensions = { "nvim-tree", "lazy", "trouble" },
    },
  },

  -- Bufferline: Buffer tabs
  {
    "akinsho/bufferline.nvim",
    version = "*",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    event = "VeryLazy",
    opts = {
      options = {
        mode = "buffers",
        diagnostics = "nvim_lsp",
        offsets = {
          { filetype = "NvimTree", text = "Explorer", text_align = "center" },
        },
        show_buffer_close_icons = true,
        show_close_icon = false,
        separator_style = "thin",
      },
    },
  },

  -- Which-key: Keybind discovery
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      preset = "helix",
      delay = 300,
      icons = {
        breadcrumb = "»",
        separator = "➜",
        group = "+",
      },
    },
  },
}
