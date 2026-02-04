-- Completion with blink.cmp
local icons = require("config.icons")

return {
  {
    "saghen/blink.cmp",
    dependencies = {
      "rafamadriz/friendly-snippets",
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
        default = { "lsp", "path", "snippets", "buffer" },
      },
      completion = {
        accept = {
          auto_brackets = { enabled = true },
        },
        menu = {
          border = "rounded",
          draw = {
            treesitter = { "lsp" },
            columns = { { "kind_icon" }, { "label", "label_description", gap = 1 } },
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
