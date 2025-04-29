require("mason").setup({
    ui = {
        icons = {
            package_installed = "✓",
            package_pending = "➜",
            package_uninstalled = "✗",
        },
    },
})

local lsp_capabilities = require('cmp_nvim_lsp').default_capabilities()
require("mason-lspconfig").setup({
    ensure_installed = { "pylsp", "lua_ls", "clangd", "html", "cssls", "ts_ls", "bashls", "powershell_es", "gopls", "phpactor" },
    capabilities = lsp_capabilities,
})
