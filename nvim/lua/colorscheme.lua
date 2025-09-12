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


-- Run shell command to detect KDE theme
local handle = io.popen("kreadconfig5 --file kdeglobals --group KDE --key LookAndFeelPackage")
local theme = handle:read("*a"):gsub("%s+", "")  -- trim spaces/newlines
handle:close()

if theme == "org.kde.breeze.desktop" then
  vim.cmd("colorscheme onelight")
  -- pick your light scheme
elseif theme == "org.kde.breezedark.desktop" then
  vim.cmd("colorscheme onedark") 
else
  vim.cmd("colorscheme onedark")
end

