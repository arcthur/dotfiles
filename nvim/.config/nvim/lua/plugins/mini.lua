-- Mini plugins - lightweight utilities
return {
  -- mini.pairs: Auto-pair brackets
  {
    "nvim-mini/mini.pairs",
    event = "InsertEnter",
    opts = {},
  },

  -- mini.ai: Better text objects
  {
    "nvim-mini/mini.ai",
    event = "VeryLazy",
    opts = {
      n_lines = 500,
    },
  },
}
