-- LSP Configuration
local settings = require("config.settings")
local icons = require("config.icons")

return {
  -- Mason: Package manager for LSP servers
  {
    "williamboman/mason.nvim",
    lazy = false,
    config = function()
      require("mason").setup({
        ui = {
          icons = {
            package_installed = icons.ui.Check,
            package_pending = icons.ui.ChevronRight,
            package_uninstalled = icons.ui.Close,
          },
          border = "rounded",
        },
      })
    end,
  },

  -- Bridge between mason and lspconfig
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = { "williamboman/mason.nvim" },
    config = function()
      require("mason-lspconfig").setup({
        ensure_installed = settings.lsp_servers,
        automatic_installation = true,
      })
    end,
  },

  -- Auto-install formatters, linters, etc.
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    dependencies = { "williamboman/mason.nvim" },
    event = "VeryLazy",
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
      "williamboman/mason-lspconfig.nvim",
    },
    config = function()
      -- LSP keymaps on attach
      local lsp_attach_group = vim.api.nvim_create_augroup("lsp_attach", { clear = true })
      vim.api.nvim_create_autocmd("LspAttach", {
        group = lsp_attach_group,
        callback = function(args)
          local bufnr = args.buf
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
        end,
      })

      -- Default capabilities with blink.cmp enhancements
      local capabilities = vim.lsp.protocol.make_client_capabilities()
      local ok, blink = pcall(require, "blink.cmp")
      if ok then
        capabilities = blink.get_lsp_capabilities(capabilities)
      end

      -- Server configs using vim.lsp.config (Neovim 0.11+)
      -- Use function call to merge with nvim-lspconfig defaults (preserves cmd/filetypes/root_markers)
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

      -- Configure each server with vim.lsp.config() function (merges with defaults)
      for _, server in ipairs(settings.lsp_servers) do
        local config = server_overrides[server] or {}
        config = vim.tbl_deep_extend("force", {}, config, { capabilities = capabilities })
        vim.lsp.config(server, config)
      end

      -- Enable all configured servers
      vim.lsp.enable(settings.lsp_servers)

      -- Diagnostic config
      local diag_icons = icons.diagnostics
      vim.diagnostic.config({
        virtual_text = settings.diagnostics_virtual_text and { prefix = "●" } or false,
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

  -- Conform: Formatting
  {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    cmd = { "ConformInfo" },
    keys = {
      { "<leader>cf", function() require("conform").format({ async = true, lsp_fallback = true }) end, desc = "Format" },
    },
    opts = {
      formatters_by_ft = settings.formatters_by_ft,
      format_on_save = settings.format_on_save and {
        timeout_ms = settings.format_timeout,
        lsp_fallback = true,
      } or nil,
    },
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
