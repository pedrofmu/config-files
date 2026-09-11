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
lsp_capabilities.general = lsp_capabilities.general or {}
lsp_capabilities.general.positionEncodings = { "utf-16" }

local function get_python_path(root_dir)
    local candidates = {}

    if root_dir then
        table.insert(candidates, root_dir .. "/.venv/bin/python")
        table.insert(candidates, root_dir .. "/.venv/bin/python3")
    end

    if vim.env.VIRTUAL_ENV then
        table.insert(candidates, vim.env.VIRTUAL_ENV .. "/bin/python")
        table.insert(candidates, vim.env.VIRTUAL_ENV .. "/bin/python3")
    end

    table.insert(candidates, vim.fn.exepath("python3"))
    table.insert(candidates, vim.fn.exepath("python"))

    for _, path in ipairs(candidates) do
        if path and path ~= "" and (vim.uv or vim.loop).fs_stat(path) then
            return path
        end
    end
end

require("mason-lspconfig").setup({
    ensure_installed = { "lua_ls", "clangd", "html", "cssls", "ts_ls", "bashls", "powershell_es", "gopls", "intelephense", "pyright", "ruff" },
})

local lspconfig = require("lspconfig");

for _, server in ipairs({ "lua_ls", "clangd", "html", "cssls", "bashls", "powershell_es", "gopls" }) do
    if lspconfig[server] then
        lspconfig[server].setup({
            capabilities = lsp_capabilities,
        })
    end

end

lspconfig.pyright.setup({
    capabilities = lsp_capabilities,
    on_new_config = function(config, root_dir)
        local python_path = get_python_path(root_dir)
        if python_path then
            config.settings = config.settings or {}
            config.settings.python = config.settings.python or {}
            config.settings.python.pythonPath = python_path
        end
    end,
    settings = {
        python = {
            analysis = {
                autoImportCompletions = true,
                autoSearchPaths = true,
                diagnosticMode = "workspace",
                typeCheckingMode = "basic",
                useLibraryCodeForTypes = true,
            },
        },
    },
})

lspconfig.ruff.setup({
    capabilities = lsp_capabilities,
    on_attach = function(client)
        client.server_capabilities.hoverProvider = false
    end,
})

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
