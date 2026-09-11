--local colorscheme = "moonfly"
--
--local is_ok, _ = pcall(vim.cmd, "colorscheme " .. colorscheme)
--if not is_ok then
--	vim.notify("colorscheme " .. colorscheme .. " not found!")
--	return
--end
--
require("onedarkpro").setup({
  options = {
    transparency = false,
  },
  on_highlights = function(highlights, colors)
    highlights.Normal = { bg = colors.bg }
    highlights.NormalNC = { bg = colors.bg }
    highlights.NormalFloat = { bg = colors.bg }
    highlights.FloatBorder = { bg = colors.bg }

    highlights.NvimTreeRootFolder = { fg = colors.purple }
    highlights.NvimTreeFolderIcon = { fg = colors.purple }
    highlights.NvimTreeOpenedFolderName = { fg = colors.purple }
    highlights.NvimTreeOpenedFile = { fg = colors.purple }
  end
})

vim.cmd("colorscheme onedark")
