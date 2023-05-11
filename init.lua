-- bootstrap packer
local packer_path = vim.fn.stdpath("data") .. "/packer/packer.nvim"
if not vim.loop.fs_stat(packer_path) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/wbthomason/packer.nvim",
    "--branch=master",
    packer_path,
  })
end
vim.opt.rtp:prepend(packer_path)

-- let's add submodules
require("singoc.pkgs")

-- make sure all plugins get sync, otherwise keys/opts will complain
vim.cmd [[PackerUpdate]]

-- ok, do some extra things
require("singoc.keys")
require("singoc.opts")
