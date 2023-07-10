local packpath = vim.fn.stdpath("data") .. "/packer/packer.nvim"
if not vim.loop.fs_stat(packpath) then
  vim.fn.system({ "git", "clone", "--filter=blob:none", "https://github.com/wbthomason/packer.nvim", "--branch=master", packpath })
end

vim.opt.rtp:prepend(packpath)

vim.g.mapleader = " "

-- let packer does all thing
vim.cmd [[packadd packer.nvim]]

require('packer').startup(function(use)
  use { 
    'wbthomason/packer.nvim', 
    config = function() 
      vim.keymap.set("n", "<leader>ps", vim.cmd.PackerSync)
    end 
  }

  use {
    'VonHeikemen/lsp-zero.nvim',
    branch = 'v2.x',
    requires = {
      {
        'fb87/flutter-tools.nvim',
        branch = 'support_nested_dart_sdk',
        requires = {
          'nvim-lua/plenary.nvim',
          'stevearc/dressing.nvim',
        },
      },
      {'neovim/nvim-lspconfig'},
      {
        'williamboman/mason.nvim',
        config = function() vim.cmd[[MasonUpdate]] end,
      },

      -- Autocompletion
      {'hrsh7th/nvim-cmp'},   -- Required
      {'hrsh7th/cmp-nvim-lsp'}, -- Required
      {'L3MON4D3/LuaSnip'},   -- Required
    },
    config = function()
      local lsp = require('lsp-zero').preset({})

      lsp.on_attach(function(client, bufnr)
        lsp.default_keymaps({buffer = bufnr})
      end)

      lsp.setup()

      local dart_lsp = lsp.build_options('dartls', {})
      require('flutter-tools').setup({
        lsp = {
          capabilities = dart_lsp.capabilities
        }
      })
    end
  }

  use {
    'voldikss/vim-floaterm',
    config = function()
      vim.keymap.set('n', '<leader>t', vim.cmd.FloatermToggle)
      vim.keymap.set('t', '<leader>jk', vim.cmd.FloatermToggle)
      vim.keymap.set('t', 'jk', [[<C-\><C-n>]])

      vim.g.floaterm_title = "[ SHELL ]"
      vim.g.floaterm_width = 0.9;
      vim.g.floaterm_height = 0.9
      vim.g.floaterm_borderchars = '-     '
      vim.cmd[[hi Floaterm guibg=black]]
      vim.cmd[[hi FloatermBorder guibg=black guifg=white]]

    end
  }

  use {
    'folke/tokyonight.nvim',
    config = function()
      vim.cmd[[colorscheme tokyonight-night]] 
    end
  }

  use {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v2.x",
    requires = { 
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
      "MunifTanjim/nui.nvim",
    },
    config = function()
      require("neo-tree").setup()
      vim.keymap.set('n', '<leader>e', vim.cmd.NeoTreeFloatToggle)
    end,
  }

  use {
    "nvim-treesitter/nvim-treesitter",
    config = function()
      require('nvim-treesitter.configs').setup {
        ensure_installed = { "c", "nix", "python", "cmake", "lua", "vim", "vimdoc", "query" },
        sync_install = false,
        auto_install = true,
        highlight = {
          enable = true,
          additional_vim_regex_highlighting = false,
        },
      }
      config = function() 
        vim.cmd[[TSUpdate]] 
      end
    end
  }

  use {
    'ThePrimeagen/harpoon',
    config = function()
      vim.keymap.set('n', "<leader>a", "<cmd>:lua require('harpoon.mark').add_file()<cr>")
      vim.keymap.set('n', "<leader>j", "<cmd>:lua require('harpoon.ui').nav_next()<cr>")
      vim.keymap.set('n', "<leader>k", "<cmd>:lua require('harpoon.ui').nav_prev()<cr>")
      vim.keymap.set('n', "<leader>m", "<cmd>:lua require('harpoon.ui').toggle_quick_menu()<cr>")
    end
  }

  use {
    'nvim-telescope/telescope.nvim',
    tag = '0.1.1',
    requires = { 'nvim-lua/plenary.nvim' },
    config = function()
      vim.keymap.set('n', "<leader>pf", "<cmd>Telescope find_files<cr>")
      vim.keymap.set('n', "<leader>pg", "<cmd>Telescope git_files<cr>")
      vim.keymap.set('n', "<leader>ps", "<cmd>Telescope grep_string<cr>")
    end
  }

end)

-- keybinding
vim.opt.rnu = true
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.expandtab = true

