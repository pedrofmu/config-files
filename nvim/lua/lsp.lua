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
    ensure_installed = { "pylsp", "lua_ls", "clangd", "html", "cssls", "ts_ls", "denols", "bashls", "powershell_es", "gopls" },
    capabilities = lsp_capabilities,
})

local lspconfig = require("lspconfig");
-- Configuración para el servidor denols
lspconfig.denols.setup({
    settings = {
        completions = {
            completeFunctionCalls = true
        },
    },
    capabilities = lsp_capabilities,
    root_dir = lspconfig.util.root_pattern("deno.json", "deno.jsonc"),
    init_options = {
        lint = true,
        suggest = {
            imports = {
                hosts = {
                    ["https://deno.land"] = true,
                    ["https://cdn.nest.land"] = true,
                    ["https://crux.land"] = true,
                },
            },
        },
    },
})

-- Configuración para el servidor tsserver
lspconfig.ts_ls.setup({
    settings = {
        completions = {
            completeFunctionCalls = true
        },
    },
    capabilities = lsp_capabilities,
    root_dir = function(filename)
        local denoRootDir = lspconfig.util.root_pattern("deno.json", "deno.jsonc")(filename)
        if denoRootDir then
            -- Este es un proyecto Deno, no se adjunta tsserver
            return nil
        end

        -- Si no es Deno, entonces permitimos tsserver en cualquier carpeta (con o sin package.json)
        return lspconfig.util.root_pattern("package.json", ".git")(filename) or vim.loop.cwd()
    end,
    single_file_support = false,
})
