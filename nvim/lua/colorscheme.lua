--local colorscheme = "moonfly"
--
--local is_ok, _ = pcall(vim.cmd, "colorscheme " .. colorscheme)
--if not is_ok then
--	vim.notify("colorscheme " .. colorscheme .. " not found!")
--	return
--end
--
require("onedarkpro").setup({
  highlights = {
    NvimTreeHighlights = { fg = "#FF0000" },
  }
})

vim.cmd("colorscheme onedark")
