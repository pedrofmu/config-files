local lsp_zero = require('lsp-zero')

lsp_zero.extend_lspconfig()

lsp_zero.on_attach(function(client, bufnr)
  -- see :help lsp-zero-keybindings
  -- to learn the available actions
  lsp_zero.default_keymaps({buffer = bufnr})
end)

--lsp_zero.tsserver.setup{
--  -- Omitting some options
--  root_dir = lsp_zero.util.root_pattern("package.json")
--}
--
--lsp_zero.denols.setup {
--  -- Omitting some options
--  root_dir = lsp_zero.util.root_pattern("deno.json"),
--}

require('mason').setup({})
require('mason-lspconfig').setup({
  ensure_installed = {},
  handlers = {
    lsp_zero.default_setup,
  },
})
