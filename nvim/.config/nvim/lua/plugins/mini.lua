-- Mini plugins - lightweight utilities
return {
  -- mini.pairs: Auto-pair brackets
  {
    "echasnovski/mini.pairs",
    event = "InsertEnter",
    opts = {},
  },

  -- mini.ai: Better text objects
  {
    "echasnovski/mini.ai",
    event = "VeryLazy",
    opts = {
      n_lines = 500,
    },
  },
}
