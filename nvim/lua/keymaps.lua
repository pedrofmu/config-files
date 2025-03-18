-- define common options
local opts = {
	noremap = true, -- non-recursive
	silent = true, -- do not show message
}

-- definir la tecla leader
vim.g.mapleader = " "

-----------------
-- Normal mode --
-----------------

-- Hint: see `:h vim.map.set()`
-- Better window navigation
--vim.keymap.set("n", "<leader>j", "<C-w>h", opts)
--vim.keymap.set("n", "<leader>k", "<C-w>j", opts)
--vim.keymap.set("n", "<leader>l", "<C-w>k", opts)
--vim.keymap.set("n", "<leader>ñ", "<C-w>l", opts)

-- Resize with arrows
-- delta: 2 lines
vim.keymap.set("n", "<C-Up>", ":resize +2<CR>", opts)
vim.keymap.set("n", "<C-Down>", ":resize -2<CR>", opts)
vim.keymap.set("n", "<C-Left>", ":vertical resize +2<CR>", opts)
vim.keymap.set("n", "<C-Right>", ":vertical resize -2<CR>", opts)

-- Open windows
vim.keymap.set("n", "<leader>h", "<C-w>n", opts)
vim.keymap.set("n", "<leader>v", "<C-w>v", opts)

-- Change navigation
--vim.keymap.set("n", "j", "h", opts)
--vim.keymap.set("n", "k", "j", opts)
--vim.keymap.set("n", "l", "k", opts)
--vim.keymap.set("n", "ñ", "l", opts)
--
--vim.keymap.set("x", "j", "h", opts)
--vim.keymap.set("x", "k", "j", opts)
--vim.keymap.set("x", "l", "k", opts)
--vim.keymap.set("x", "ñ", "l", opts)

-- Usar neo tree
vim.keymap.set("n", "<leader>t", ":NvimTreeToggle<CR>", opts)
-- vim.keymap.set("n", "<leader>ct", ":Neotree close<CR>", opts)

-- Usar telescope
local builtin = require("telescope.builtin")
vim.keymap.set("n", "<leader>ff", builtin.find_files, opts)
vim.keymap.set("n", "<leader>fg", builtin.live_grep, opts)
vim.keymap.set("n", "<leader>fb", builtin.buffers, opts)

-- format
local conform = require("conform")
vim.keymap.set("n", "<leader>mp", function()
	conform.format({
		lsp_fallback = true,
		async = false,
		timeout_ms = 500,
	})
end, opts)

-- renombrar varibles
vim.api.nvim_set_keymap("n", "<leader>rn", "<cmd>lua vim.lsp.buf.rename()<CR>", opts)

-- Asigna un atajo para ver las sugerencias de cambio del cliente LSP
vim.api.nvim_set_keymap('n', '<leader>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)

-- Ver propiedades el elemento LSP
vim.api.nvim_set_keymap('n', '<leader>sd', '<cmd>lua vim.lsp.buf.hover()<CR>', opts)

-- Keymaps para harpoon
vim.api.nvim_set_keymap('n', '<leader>ha', '<cmd>lua require("harpoon.mark").add_file()<CR>', opts)
vim.api.nvim_set_keymap('n', '<leader>hs', '<cmd>lua require("harpoon.ui").toggle_quick_menu()<CR>', opts)
