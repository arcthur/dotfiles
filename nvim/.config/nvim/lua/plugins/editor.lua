-- Editor enhancements
return {
  -- Bigfile: Disable features for large files
  {
    "lunarvim/bigfile.nvim",
    lazy = false,
    opts = {
      filesize = 5, -- size in MiB
      features = {
        {
          name = "ibl",
          disable = function(bufnr)
            local function apply()
              if not vim.api.nvim_buf_is_valid(bufnr) then
                return
              end
              local ok, ibl = pcall(require, "ibl")
              if ok then
                ibl.setup_buffer(bufnr, { enabled = false })
              end
            end

            if package.loaded["ibl"] then
              apply()
              return
            end

            vim.api.nvim_create_autocmd("User", {
              pattern = "LazyLoad",
              callback = function(event)
                if event.data == "indent-blankline.nvim" then
                  apply()
                end
              end,
              once = true,
            })
          end,
        },
        "lsp",
        "treesitter",
        "syntax",
        "matchparen",
        "vimopts",
      },
    },
  },

  -- File explorer (nvim-tree)
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    cmd = {
      "NvimTreeToggle",
      "NvimTreeOpen",
      "NvimTreeFocus",
      "NvimTreeFindFile",
      "NvimTreeRefresh",
    },
    keys = {
      { "<leader>e", "<cmd>NvimTreeToggle<cr>", desc = "File explorer" },
    },
    config = function()
      require("nvim-tree").setup({
        view = {
          width = 30,
          side = "left",
        },
        renderer = {
          group_empty = true,
          icons = {
            show = { file = true, folder = true, folder_arrow = true, git = true },
          },
        },
        filters = {
          dotfiles = false,
          custom = { ".git", "node_modules", ".cache" },
        },
        git = {
          enable = true,
          ignore = false,
        },
        actions = {
          open_file = {
            quit_on_open = false,
            resize_window = true,
          },
        },
      })
    end,
  },

  -- Icons
  { "nvim-tree/nvim-web-devicons", lazy = true },

  -- Comment
  {
    "numToStr/Comment.nvim",
    event = { "BufReadPost", "BufNewFile" },
    config = true,
  },

  -- Surround
  {
    "kylechui/nvim-surround",
    version = "*",
    event = "VeryLazy",
    config = true,
  },

  -- Matchup (better % matching)
  {
    "andymass/vim-matchup",
    event = "BufReadPost",
    config = function()
      vim.g.matchup_matchparen_offscreen = { method = "popup" }
    end,
  },

  -- Auto-detect indent
  {
    "tpope/vim-sleuth",
    event = { "BufReadPre", "BufNewFile" },
  },
}
