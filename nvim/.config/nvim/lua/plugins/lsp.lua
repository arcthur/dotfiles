-- LSP Configuration
local settings = require("config.settings")
local icons = require("config.icons")

return {
  -- Mason: Package manager for LSP servers
  -- Lazy-loaded, will be triggered by mason-lspconfig
  {
    "williamboman/mason.nvim",
    cmd = "Mason",
    build = ":MasonUpdate",
    opts = {
      ui = {
        icons = {
          package_installed = icons.ui.Check,
          package_pending = icons.ui.ChevronRight,
          package_uninstalled = icons.ui.Close,
        },
        border = "rounded",
      },
    },
  },

  -- Bridge between mason and lspconfig
  -- Loaded as dependency of lspconfig
  {
    "williamboman/mason-lspconfig.nvim",
    opts = {
      ensure_installed = settings.lsp_servers,
      automatic_installation = true,
    },
  },

  -- Auto-install formatters, linters, etc.
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    event = "VeryLazy",
    dependencies = { "williamboman/mason.nvim" },
    config = function()
      local tool_set = {}
      local function add_tool(tool)
        if tool and tool ~= "" then
          tool_set[tool] = true
        end
      end

      for _, formatters in pairs(settings.formatters_by_ft or {}) do
        for _, tool in ipairs(formatters) do
          add_tool(tool)
        end
      end

      for _, tool in ipairs(settings.mason_tools or {}) do
        add_tool(tool)
      end

      local ensure_installed = vim.tbl_keys(tool_set)
      table.sort(ensure_installed)

      require("mason-tool-installer").setup({
        ensure_installed = ensure_installed,
        auto_update = false,
        run_on_start = true,
      })
    end,
  },

  -- LSP setup
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
    },
    config = function()
      -- LSP keymaps on attach
      local lsp_attach_group = vim.api.nvim_create_augroup("lsp_attach", { clear = true })
      vim.api.nvim_create_autocmd("LspAttach", {
        group = lsp_attach_group,
        callback = function(args)
          local bufnr = args.buf
          local client = vim.lsp.get_client_by_id(args.data.client_id)
          local map = function(mode, lhs, rhs, desc)
            vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
          end

          map("n", "gd", vim.lsp.buf.definition, "Go to definition")
          map("n", "gD", vim.lsp.buf.declaration, "Go to declaration")
          map("n", "gi", vim.lsp.buf.implementation, "Go to implementation")
          map("n", "gr", vim.lsp.buf.references, "Go to references")
          map("n", "K", vim.lsp.buf.hover, "Hover documentation")
          map("n", "<leader>rn", vim.lsp.buf.rename, "Rename symbol")
          map("n", "<leader>ca", vim.lsp.buf.code_action, "Code action")
          -- Note: <leader>cf handled by Conform plugin (respects formatters_by_ft)
          map("n", "<F2>", vim.lsp.buf.rename, "Rename symbol")
          map("n", "[d", vim.diagnostic.goto_prev, "Previous diagnostic")
          map("n", "]d", vim.diagnostic.goto_next, "Next diagnostic")

          if client and client.supports_method and client:supports_method("textDocument/inlayHint") then
            map("n", "<leader>lh", function()
              local enabled = vim.lsp.inlay_hint.is_enabled({ bufnr = bufnr })
              vim.lsp.inlay_hint.enable(not enabled, { bufnr = bufnr })
            end, "Inlay hints (toggle)")
          end
        end,
      })

      -- Configure + enable all servers (Neovim 0.11+ native LSP) via a small helper.
      -- register_servers merges blink.cmp capabilities and per-server overrides, then
      -- calls vim.lsp.config()/enable() for each. See lua/config/lsp_utils.lua.
      local server_overrides = {
        lua_ls = {
          settings = {
            Lua = {
              diagnostics = { globals = { "vim" } },
              workspace = { checkThirdParty = false },
              telemetry = { enable = false },
            },
          },
        },
      }
      require("config.lsp_utils").register_servers(settings.lsp_servers, server_overrides)

      -- Diagnostic config (virtual_text handled by tiny-inline-diagnostic in ux.lua)
      local diag_icons = icons.diagnostics
      vim.diagnostic.config({
        signs = {
          text = {
            [vim.diagnostic.severity.ERROR] = diag_icons.Error,
            [vim.diagnostic.severity.WARN] = diag_icons.Warn,
            [vim.diagnostic.severity.HINT] = diag_icons.Hint,
            [vim.diagnostic.severity.INFO] = diag_icons.Info,
          },
        },
        underline = true,
        update_in_insert = false,
        severity_sort = true,
        float = { border = "rounded" },
      })
    end,
  },

  -- Conform: Formatting (format-on-save policy lives in lua/config/format.lua)
  {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    cmd = { "ConformInfo", "Format", "FormatToggle" },
    keys = {
      {
        "<leader>cf",
        function()
          require("config.format").format(0, { async = true, whole = true })
        end,
        desc = "Format buffer",
      },
    },
    opts = {
      formatters_by_ft = settings.formatters_by_ft,
    },
    config = function(_, opts)
      require("conform").setup(opts)
      require("config.format").setup()
    end,
  },

  -- Trouble: Better diagnostics list
  {
    "folke/trouble.nvim",
    cmd = { "Trouble", "TroubleToggle" },
    dependencies = { "nvim-tree/nvim-web-devicons" },
    keys = {
      { "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", desc = "Diagnostics (Trouble)" },
      { "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", desc = "Buffer Diagnostics" },
      { "<leader>xL", "<cmd>Trouble loclist toggle<cr>", desc = "Location List" },
      { "<leader>xQ", "<cmd>Trouble qflist toggle<cr>", desc = "Quickfix List" },
    },
    opts = {},
  },
}
