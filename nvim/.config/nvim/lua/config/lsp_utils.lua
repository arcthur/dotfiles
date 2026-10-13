-- Thin wrapper over Neovim 0.11+ native LSP (vim.lsp.config / vim.lsp.enable).
-- Capabilities are not handled here: blink.cmp merges its own into vim.lsp.config("*")
-- when it loads (it is a dependency of nvim-lspconfig, so that happens first).
local M = {}

-- Apply optional per-server overrides on top of nvim-lspconfig's defaults, then enable all.
---@param servers string[]
---@param overrides? table<string, vim.lsp.Config>
function M.register_servers(servers, overrides)
  for server, config in pairs(overrides or {}) do
    vim.lsp.config(server, config)
  end
  vim.lsp.enable(servers)
end

return M
