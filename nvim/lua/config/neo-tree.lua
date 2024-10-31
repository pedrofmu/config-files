require("neo-tree").setup({
    filesystem = {
        window = {
            mappings = {
                ["l"] = "noop"
            }
        }
    },
    event_handlers = {

        {
            event = "file_open_requested",
            handler = function()
                -- auto close
                -- vim.cmd("Neotree close")
                -- OR
                require("neo-tree.command").execute({ action = "close" })
            end
        },

    }
})
