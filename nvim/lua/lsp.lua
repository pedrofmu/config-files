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
    ensure_installed = { "lua_ls", "clangd", "html", "cssls", "ts_ls", "bashls", "powershell_es", "gopls", "intelephense" },
    capabilities = lsp_capabilities,
})

local lspconfig = require("lspconfig");

for _, server in ipairs({ "lua_ls", "clangd", "html", "cssls", "bashls", "powershell_es", "gopls" }) do
    if lspconfig[server] then
        lspconfig[server].setup({})
    end

end

-- Configuración para intelephense
local get_intelephense_license_key = function()
    local f = assert(io.open(os.getenv("HOME") .. "/intelephense/license.txt", "rb"))
    local content = f:read("*a")
    f:close()
    return string.gsub(content, "%s+", "")
end

lspconfig.intelephense.setup({
    capabilities = lsp_capabilities,
    init_options = {
        -- Licence key must be passed via init_options per lspconfig docs
        licenceKey = get_intelephense_license_key() 
    }
})

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

        -- Solo adjuntar tsserver en proyectos Node/TS
        return lspconfig.util.root_pattern("package.json", "tsconfig.json", "jsconfig.json", ".git")(filename)
    end,
    single_file_support = false,
})
