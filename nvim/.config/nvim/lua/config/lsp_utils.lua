-- Thin wrappers over Neovim 0.11+ native LSP (vim.lsp.config / vim.lsp.enable).
-- Keeps lsp.lua declarative as the server list grows.
local M = {}

-- Default client capabilities, merged with blink.cmp's if it is available.
---@return lsp.ClientCapabilities
function M.get_capabilities()
  local capabilities = vim.lsp.protocol.make_client_capabilities()
  local ok, blink = pcall(require, "blink.cmp")
  if ok then
    capabilities = blink.get_lsp_capabilities(capabilities)
  end
  return capabilities
end

-- Configure and enable a single server in one call.
-- `config` is merged on top of the shared capabilities and nvim-lspconfig defaults.
-- `capabilities` may be passed in to avoid recomputing it per server.
---@param server string
---@param config? table
---@param capabilities? lsp.ClientCapabilities
function M.register_server(server, config, capabilities)
  capabilities = capabilities or M.get_capabilities()
  vim.lsp.config(server, vim.tbl_deep_extend("force", { capabilities = capabilities }, config or {}))
  vim.lsp.enable(server)
end

-- Configure + enable many servers, applying optional per-server overrides.
-- Capabilities are computed once and shared across all servers.
---@param servers string[]
---@param overrides? table<string, table>
function M.register_servers(servers, overrides)
  overrides = overrides or {}
  local capabilities = M.get_capabilities()
  for _, server in ipairs(servers) do
    M.register_server(server, overrides[server], capabilities)
  end
end

return M
