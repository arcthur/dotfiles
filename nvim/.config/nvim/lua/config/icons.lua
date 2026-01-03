-- Centralized icons module (inspired by nvimdots)
-- Usage: require("config.icons").get("kind") or require("config.icons").kind

local M = {}

local data = {
  kind = {
    Text = "󰉿",
    Method = "󰆧",
    Function = "󰊕",
    Constructor = "",
    Field = "󰜢",
    Variable = "󰀫",
    Class = "󰠱",
    Interface = "",
    Module = "",
    Property = "󰜢",
    Unit = "󰑭",
    Value = "󰎠",
    Enum = "",
    Keyword = "󰌋",
    Snippet = "",
    Color = "󰏘",
    File = "󰈙",
    Reference = "󰈇",
    Folder = "󰉋",
    EnumMember = "",
    Constant = "󰏿",
    Struct = "󰙅",
    Event = "",
    Operator = "󰆕",
    TypeParameter = "",
    -- Extra
    Namespace = "󰌗",
    Package = "",
    String = "",
    Number = "",
    Boolean = "",
    Array = "󰅪",
    Object = "󰅩",
    Key = "󰌋",
    Null = "󰟢",
  },

  type = {
    Array = "󰅪",
    Boolean = "",
    Null = "󰟢",
    Number = "",
    Object = "󰅩",
    String = "󰉿",
  },

  documents = {
    Default = "",
    File = "",
    Files = "",
    Folder = "",
    FolderOpen = "",
    Import = "",
    Symlink = "",
  },

  git = {
    Add = "",
    Branch = "",
    Diff = "",
    Git = "󰊢",
    Ignore = "",
    Mod = "M",
    Remove = "",
    Rename = "",
    Repo = "",
    Untracked = "󰞋",
    Unstaged = "",
    Staged = "",
    Conflict = "",
  },

  ui = {
    ArrowClosed = "",
    ArrowOpen = "",
    Bookmark = "󰃃",
    Bug = "",
    Calendar = "",
    Check = "󰄳",
    ChevronRight = "",
    Circle = "",
    Close = "󰅖",
    Code = "",
    Comment = "",
    Dashboard = "",
    Fire = "",
    Gear = "",
    History = "",
    Lightbulb = "",
    List = "",
    Lock = "",
    NewFile = "",
    Note = "",
    Package = "",
    Pencil = "",
    Project = "",
    Search = "",
    SignIn = "",
    Table = "",
    Telescope = "",
  },

  diagnostics = {
    Error = " ",
    Warn = " ",
    Hint = "󰌵 ",
    Info = " ",
  },

  misc = {
    Robot = "󰚩",
    Squirrel = "",
    Tag = "",
    Watch = "",
    Ghost = "",
    Vim = "",
  },
}

---Get icons by category
---@param category "kind"|"type"|"documents"|"git"|"ui"|"diagnostics"|"misc"
---@return table
function M.get(category)
  return data[category] or {}
end

-- Allow direct access: icons.kind, icons.git, etc.
setmetatable(M, {
  __index = function(_, key)
    return data[key]
  end,
})

return M
