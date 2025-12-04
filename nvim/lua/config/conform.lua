local conform = require("conform")

conform.setup({
    formatters_by_ft = {
        sh = { "shfmt" },
        javascript = { "prettier" },
        typescript = { "prettier" },
        javascriptreact = { "prettier" },
        typescriptreact = { "prettier" },
        svelte = { "prettier" },
        css = { "prettier" },
        html = { "prettier" },
        json = { "prettier" },
        yaml = { "prettier" },
        markdown = { "prettier" },
        graphql = { "prettier" },
        lua = { "stylua" },
        python = { "isort" },
        c = { "clang-format" },
        cpp = { "clang-format" },
        php = { "php-cs-fixer" },
    },
})
