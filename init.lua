-- vim: tabstop=2 autoindent tabstop=2 shiftwidth=2 expandtab colorcolumn=80
vim.g.mapleader = " "

function _install_packages()
  local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
  if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
      "git",
      "clone",
      "--filter=blob:none",
      "https://github.com/folke/lazy.nvim.git",
      "--branch=stable", -- latest stable release
      lazypath,
    })
  end
  vim.opt.rtp:prepend(lazypath)

  local opts = { lockfile = vim.fn.stdpath("data") .. "/lazy-lock.json", }
  local plugins = {
    {
      "ggml-org/llama.vim"
    },
    { 
      "rose-pine/neovim", name = "rose-pine",
      config = function()
        require("rose-pine").setup({
          variant = "main",
          styles = {
            bold = true,
            italic = false,
            transparency = false,
          }
        })
      end
    },
    {
      'akinsho/toggleterm.nvim', version = "*", config = true,
      keys = {
        { "<leader>jk", "<cmd>ToggleTerm direction=float<cr>",
        desc = "Toggle Terminal" },
      }
    },
    {
      'nvim-telescope/telescope.nvim',
      dependencies = { 'nvim-lua/plenary.nvim' },
      keys = {
        { "<leader>pf", "<cmd>Telescope find_files<cr>" },
        { "<leader>pg", "<cmd>Telescope git_files<cr>" },
        { "<leader>ps", "<cmd>Telescope grep_string<cr>" },

        -- map pb for telescope on buffer list
        { "<leader>pb", "<cmd>Telescope buffers<cr>" },
      }
    },
    {
      'theprimeagen/harpoon',
      keys = {
        { "<leader>a", "<cmd>:lua require('harpoon.mark').add_file()<cr>" },
        { "<leader>j", "<cmd>:lua require('harpoon.ui').nav_next()<cr>" },
        { "<leader>k", "<cmd>:lua require('harpoon.ui').nav_prev()<cr>" },
        { "<leader>m", "<cmd>:lua require('harpoon.ui').toggle_quick_menu()<cr>" },
      }
    },

    { 'vimwiki/vimwiki' },
    { 'stevearc/oil.nvim', dependencies = {
        { "echasnovski/mini.icons", opts = {} }
      },
      config = function() require("oil").setup({
        columns = {
          "icon",
          "permissions",
          "size",
          "mtime",
        },

        float = {
          -- Padding around the floating window
          padding = 10,
          max_width = 0,
          max_height = 0,
          border = "rounded",
          win_options = {
            winblend = 0,
          },
          get_win_title = nil,
          preview_split = "auto",
          override = function(conf)
            return conf
          end,
        },

        -- Configuration for the file preview window
        preview_win = {
          update_on_cursor_moved = true,
          preview_method = "fast_scratch",
          disable_preview = function(filename)
            return false
          end,
          win_options = {},
        },
      }
    ) end },
  }

  require("lazy").setup(plugins, opts)
end

function _setup_key_binding()
  local keys = vim.keymap

  keys.set("t", "<leader>jk", "<cmd>ToggleTerm<cr>")
  keys.set("t", "jk", [[<C-\><C-n>]])

  keys.set("n", "<leader>c", vim.cmd.bd)
  keys.set("n", "<leader>e", "<cmd>Oil --float<CR>")
  keys.set("n", "<leader><leader>", function()
    vim.cmd("so")
  end)
end

function _setup_vim_options()
  local opts = vim.opt

  vim.cmd [[colorscheme rose-pine-main]]

  opts.rnu = true
  -- reduce timeout between leader key to action
  opts.timeoutlen = 500 -- or 500 (Default: 1000)
end

function main()
  _install_packages()
  _setup_vim_options()
  _setup_key_binding()
end

-- run everything
main()
