-- Completion with blink.cmp
local icons = require("config.icons")

-- Source -> short label shown in the completion menu, so multi-source items are
-- easy to tell apart. AI slots ([AI]/[CPLT]) are pre-mapped so wiring copilot/minuet
-- later only needs a provider + a `sources.default` entry, no menu changes.
local source_labels = {
  lsp = "[LSP]",
  path = "[PATH]",
  snippets = "[SNIP]",
  buffer = "[BUF]",
  ripgrep = "[RG]",
  lazydev = "[LAZY]",
  minuet = "[AI]",
  copilot = "[CPLT]",
}

return {
  -- Lua/Neovim API completion + types (invaluable when editing this config itself).
  {
    "folke/lazydev.nvim",
    ft = "lua",
    opts = {
      library = {
        { path = "${3rd}/luv/library", words = { "vim%.uv" } },
        "lazy.nvim",
      },
    },
  },

  {
    "saghen/blink.cmp",
    dependencies = {
      "rafamadriz/friendly-snippets",
      "mikavilpas/blink-ripgrep.nvim",
      { "xzbdmw/colorful-menu.nvim", opts = {} },
    },
    version = "*",
    event = "InsertEnter",
    opts = {
      keymap = {
        preset = "default",
        ["<C-space>"] = { "show", "show_documentation", "hide_documentation" },
        ["<C-e>"] = { "hide" },
        ["<C-y>"] = { "select_and_accept" },
        ["<CR>"] = { "accept", "fallback" },
        ["<Tab>"] = { "select_next", "snippet_forward", "fallback" },
        ["<S-Tab>"] = { "select_prev", "snippet_backward", "fallback" },
        ["<C-n>"] = { "select_next", "fallback" },
        ["<C-p>"] = { "select_prev", "fallback" },
        ["<C-b>"] = { "scroll_documentation_up", "fallback" },
        ["<C-f>"] = { "scroll_documentation_down", "fallback" },
      },
      appearance = {
        use_nvim_cmp_as_default = true,
        nerd_font_variant = "mono",
        kind_icons = icons.kind,
      },
      sources = {
        default = { "lazydev", "lsp", "snippets", "path", "buffer", "ripgrep" },
        providers = {
          lsp = { max_items = 350 },
          lazydev = {
            name = "LazyDev",
            module = "lazydev.integrations.blink",
            score_offset = 100, -- prefer lazydev over lsp in Lua buffers
            enabled = function()
              return vim.bo.filetype == "lua"
            end,
          },
          buffer = {
            opts = {
              -- Skip huge buffers so buffer-completion scanning stays snappy.
              get_bufnrs = function()
                return vim.api.nvim_buf_line_count(0) < 15000 and vim.api.nvim_list_bufs() or {}
              end,
            },
          },
          ripgrep = {
            name = "Ripgrep",
            module = "blink-ripgrep",
            score_offset = -15, -- rank below lsp/snippets/path/buffer
            max_items = 3,
            opts = {
              prefix_min_len = 3,
              backend = {
                use = "gitgrep-or-ripgrep",
                ripgrep = {
                  max_filesize = "200K",
                  context_size = 3,
                  additional_rg_options = { "--max-count=5" },
                },
              },
            },
          },
        },
      },
      completion = {
        accept = {
          auto_brackets = { enabled = true },
        },
        menu = {
          border = "rounded",
          draw = {
            treesitter = { "lsp" },
            columns = {
              { "kind_icon" },
              { "label", "label_description", gap = 1 },
              { "source_name" },
            },
            components = {
              -- colorful-menu: syntax-aware coloring of the completion label.
              label = {
                text = function(ctx)
                  return require("colorful-menu").blink_components_text(ctx)
                end,
                highlight = function(ctx)
                  return require("colorful-menu").blink_components_highlight(ctx)
                end,
              },
              source_name = {
                text = function(ctx)
                  return source_labels[ctx.source_id] or ("[" .. ctx.source_id .. "]")
                end,
                highlight = "Comment",
              },
            },
          },
        },
        documentation = {
          auto_show = true,
          auto_show_delay_ms = 200,
          window = { border = "rounded" },
        },
        ghost_text = { enabled = true },
      },
      signature = {
        enabled = true,
        window = { border = "rounded" },
      },
    },
    opts_extend = { "sources.default" },
  },
}
