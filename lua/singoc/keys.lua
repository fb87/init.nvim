local map = vim.keymap.set

local mark  = require("harpoon.mark")
local ui    = require("harpoon.ui")
local term  = require("harpoon.term")

-- space as leader key
vim.g.mapleader = " " 

-- the file browser
map("n", "<leader>e", vim.cmd.NeoTreeFloatToggle)

-- show terminal
map("n", "<leader>t", vim.cmd.FloatermToggle)

-- let make it quick to hide terminal
map("t", "jk", vim.cmd.FloatermToggle)
map("t", "<Esc><Esc>", [[<C-\><C-n>]])

-- harpoon mapping
map("n", "<leader>a", mark.add_file)
map("n", "<leader>j", ui.nav_next)
map("n", "<leader>k", ui.nav_prev)
