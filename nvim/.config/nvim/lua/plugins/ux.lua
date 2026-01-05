-- UX Enhancements (inspired by nvimdots)
-- Improves visual feedback and user experience

local icons = require("config.icons")

return {
  -- Notify: Beautiful notifications
  {
    "rcarriga/nvim-notify",
    event = "VeryLazy",
    opts = {
      stages = "fade",
      timeout = 3000,
      max_height = function()
        return math.floor(vim.o.lines * 0.75)
      end,
      max_width = function()
        return math.floor(vim.o.columns * 0.75)
      end,
      on_open = function(win)
        vim.api.nvim_win_set_config(win, { zindex = 100 })
      end,
      icons = {
        ERROR = icons.diagnostics.Error,
        WARN = icons.diagnostics.Warn,
        INFO = icons.diagnostics.Info,
        DEBUG = icons.ui.Bug,
        TRACE = icons.ui.Pencil,
      },
    },
    config = function(_, opts)
      local notify = require("notify")
      notify.setup(opts)
      vim.notify = notify
    end,
  },

  -- Alpha: Dashboard/Start screen
  {
    "goolord/alpha-nvim",
    event = "VimEnter",
    opts = function()
      local dashboard = require("alpha.themes.dashboard")

      -- ASCII art header
      dashboard.section.header.val = {
        [[                                                    ]],
        [[ ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗ ]],
        [[ ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║ ]],
        [[ ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║ ]],
        [[ ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║ ]],
        [[ ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║ ]],
        [[ ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝ ]],
        [[                                                    ]],
      }

      -- Buttons
      dashboard.section.buttons.val = {
        dashboard.button("f", icons.documents.File .. " Find file", "<cmd>Telescope find_files<CR>"),
        dashboard.button("n", icons.ui.NewFile .. " New file", "<cmd>enew<CR>"),
        dashboard.button("r", icons.ui.History .. " Recent files", "<cmd>Telescope oldfiles<CR>"),
        dashboard.button("g", icons.ui.Search .. " Find text", "<cmd>Telescope live_grep<CR>"),
        dashboard.button("c", icons.ui.Gear .. " Config", "<cmd>e $MYVIMRC<CR>"),
        dashboard.button("s", icons.misc.Watch .. " Restore session", [[<cmd>lua require("persistence").load()<CR>]]),
        dashboard.button("l", icons.ui.Package .. " Lazy", "<cmd>Lazy<CR>"),
        dashboard.button("q", icons.ui.Close .. " Quit", "<cmd>qa<CR>"),
      }

      -- Footer with stats
      dashboard.section.footer.val = function()
        local stats = require("lazy").stats()
        local ms = (math.floor(stats.startuptime * 100 + 0.5) / 100)
        return "  Neovim loaded " .. stats.loaded .. "/" .. stats.count .. " plugins in " .. ms .. "ms"
      end

      dashboard.section.header.opts.hl = "AlphaHeader"
      dashboard.section.buttons.opts.hl = "AlphaButtons"
      dashboard.section.footer.opts.hl = "AlphaFooter"

      dashboard.opts.layout[1].val = 4
      return dashboard
    end,
    config = function(_, dashboard)
      -- Close Lazy and re-open when the dashboard is ready
      if vim.o.filetype == "lazy" then
        vim.cmd.close()
        vim.api.nvim_create_autocmd("User", {
          pattern = "AlphaReady",
          callback = function()
            require("lazy").show()
          end,
        })
      end

      require("alpha").setup(dashboard.opts)

      -- Update footer after lazy loads
      vim.api.nvim_create_autocmd("User", {
        pattern = "LazyDone",
        callback = function()
          local stats = require("lazy").stats()
          local ms = (math.floor(stats.startuptime * 100 + 0.5) / 100)
          dashboard.section.footer.val = "  Neovim loaded " .. stats.loaded .. "/" .. stats.count .. " plugins in " .. ms .. "ms"
          pcall(vim.cmd.AlphaRedraw)
        end,
      })
    end,
  },

  -- Todo-comments: Highlight TODO, FIXME, etc.
  {
    "folke/todo-comments.nvim",
    event = { "BufReadPost", "BufNewFile" },
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {
      signs = true,
      keywords = {
        FIX = { icon = icons.ui.Bug, color = "error", alt = { "FIXME", "BUG", "FIXIT", "ISSUE" } },
        TODO = { icon = icons.ui.Check, color = "info" },
        HACK = { icon = icons.ui.Fire, color = "warning" },
        WARN = { icon = icons.diagnostics.Warn, color = "warning", alt = { "WARNING", "XXX" } },
        PERF = { icon = icons.ui.Dashboard, alt = { "OPTIM", "PERFORMANCE", "OPTIMIZE" } },
        NOTE = { icon = icons.ui.Note, color = "hint", alt = { "INFO" } },
        TEST = { icon = icons.ui.Lock, color = "test", alt = { "TESTING", "PASSED", "FAILED" } },
      },
      highlight = {
        multiline = false,
        keyword = "wide",
        after = "",
        comments_only = true,
      },
    },
    keys = {
      { "]t", function() require("todo-comments").jump_next() end, desc = "Next todo comment" },
      { "[t", function() require("todo-comments").jump_prev() end, desc = "Previous todo comment" },
      { "<leader>xt", "<cmd>TodoTrouble<CR>", desc = "Todo (Trouble)" },
      { "<leader>xT", "<cmd>TodoTrouble keywords=TODO,FIX,FIXME<CR>", desc = "Todo/Fix/Fixme (Trouble)" },
      { "<leader>ft", "<cmd>TodoTelescope<CR>", desc = "Find todos" },
    },
  },

  -- Tiny-inline-diagnostic: Better inline diagnostics
  {
    "rachartier/tiny-inline-diagnostic.nvim",
    event = "LspAttach",
    priority = 1000,  -- Load before other LSP plugins
    opts = {
      preset = "modern",
      options = {
        show_source = true,
        use_icons_from_diagnostic = true,
        add_messages = true,
        throttle = 50,
        multilines = {
          enabled = true,
          always_show = false,
        },
        show_all_diags_on_cursorline = false,
        enable_on_insert = false,
        break_line = {
          enabled = true,
          after = 80,
        },
      },
    },
    config = function(_, opts)
      require("tiny-inline-diagnostic").setup(opts)
      -- Disable default virtual_text since we're using tiny-inline-diagnostic
      vim.diagnostic.config({ virtual_text = false })
    end,
  },
}
