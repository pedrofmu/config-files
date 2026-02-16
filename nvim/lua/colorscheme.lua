--local colorscheme = "moonfly"
--
--local is_ok, _ = pcall(vim.cmd, "colorscheme " .. colorscheme)
--if not is_ok then
--	vim.notify("colorscheme " .. colorscheme .. " not found!")
--	return
--end
--
require("onedarkpro").setup({
  on_highlights = function(highlights, colors)
    highlights.NvimTreeRootFolder = { fg = colors.purple }
    highlights.NvimTreeFolderIcon = { fg = colors.purple }
    highlights.NvimTreeOpenedFolderName = { fg = colors.purple }
    highlights.NvimTreeOpenedFile = { fg = colors.purple }
  end
})

vim.cmd("colorscheme onedark")
