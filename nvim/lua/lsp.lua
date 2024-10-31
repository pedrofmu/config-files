require("mason").setup({
    ui = {
        icons = {
            package_installed = "✓",
            package_pending = "➜",
            package_uninstalled = "✗",
        },
    },
})

require("mason-lspconfig").setup({
    ensure_installed = { "pylsp", "lua_ls", "clangd", "html", "cssls", "tsserver", "denols" },
})

local lspconfig = require("lspconfig")

local function on_attach(client, bufnr)
end

-- Configuración para el servidor denols
lspconfig.denols.setup({
    root_dir = lspconfig.util.root_pattern("deno.json", "deno.jsonc"),
    init_options = {
        lint = true,
        unstable = true,
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
    on_attach = on_attach,  
})

-- Configuración para el servidor tsserver
lspconfig.tsserver.setup({
    on_attach = function(client, bufnr)
        on_attach(client, bufnr)  -- Se usa la función definida
        vim.keymap.set('n', '<leader>ro', function()
            vim.lsp.buf.execute_command({
                command = "_typescript.organizeImports",
                arguments = { vim.fn.expand("%:p") }
            })
        end, { buffer = bufnr, remap = false })
    end,
    root_dir = function(filename, bufnr)
        local denoRootDir = lspconfig.util.root_pattern("deno.json", "deno.jsonc")(filename)
        if denoRootDir then
            -- Este es un proyecto Deno, no se adjunta tsserver
            return nil
        end

        -- Si no es Deno, se verifica el package.json
        return lspconfig.util.root_pattern("package.json")(filename)
    end,
    single_file_support = false,
})

