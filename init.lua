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

	local opts = {}
	local plugins = {
		{
			"folke/tokyonight.nvim",
			lazy = false,
			config = function() 
				vim.cmd[[colorscheme tokyonight-night]]
			end
		},
		{
			"voldikss/vim-floaterm",
			keys = {
				{ "<leader>t", vim.cmd.FloatermToggle, desc = "Float Terminal" },
			},
			config = function() 
				vim.g.floaterm_title = "[ SHELL ]"
				vim.g.floaterm_width = 0.9;
				vim.g.floaterm_height = 0.9
				vim.g.floaterm_borderchars = '-       '
				vim.cmd[[hi Floaterm guibg=black]]
				vim.cmd[[hi FloatermBorder guibg=black guifg=white]]
			end
		},
		{
			"nvim-neo-tree/neo-tree.nvim", branch = "v2.x",
			keys = {
				{ "<leader>e", "<cmd>NeoTreeFloatToggle<cr>", desc = "Neotree" },
			},
			dependencies = { 
				"nvim-lua/plenary.nvim",
				"nvim-tree/nvim-web-devicons",
				"MunifTanjim/nui.nvim",
			},
			config = function()
				require("neo-tree").setup()
			end,
		},
		{
			"nvim-treesitter/nvim-treesitter",
			cmd = "TSUpdate",
			keys = {
				{ "<leader>e", "<cmd>NeoTreeFloatToggle<cr>", desc = "Treesitter" },
			},
			config = function()
				require'nvim-treesitter.configs'.setup {
					ensure_installed = { "c", "nix", "python", "cmake", "lua", "vim", "vimdoc", "query" },
					sync_install = false,
					auto_install = true,
					highlight = {
						enable = true,
						additional_vim_regex_highlighting = false,
					},
				}
			end,
		},
		{
			'nvim-telescope/telescope.nvim', tag = '0.1.1',
			dependencies = { 'nvim-lua/plenary.nvim' },
			keys = {
				{ "<leader>pf", "<cmd>Telescope find_files<cr>" },
				{ "<leader>pg", "<cmd>Telescope git_files<cr>" },
				{ "<leader>ps", "<cmd>Telescope grep_string<cr>" },
			}
		},
		{
			'ThePrimeagen/harpoon',
			keys = {
				{ "<leader>a", "<cmd>:lua require('harpoon.mark').add_file()<cr>" },
				{ "<leader>j", "<cmd>:lua require('harpoon.ui').nav_next()<cr>" },
				{ "<leader>k", "<cmd>:lua require('harpoon.ui').nav_prev()<cr>" },
				{ "<leader>m", "<cmd>:lua require('harpoon.ui').toggle_quick_menu()<cr>" },
			}
		},
		{
			'VonHeikemen/lsp-zero.nvim',
			branch = 'v1.x',
			dependencies = {
				-- LSP Support
				'neovim/nvim-lspconfig',
				'williamboman/mason.nvim',
				'williamboman/mason-lspconfig.nvim',

				-- Autocompletion
				'hrsh7th/nvim-cmp',
				'hrsh7th/cmp-buffer',
				'hrsh7th/cmp-path',
				'saadparwaiz1/cmp_luasnip',
				'hrsh7th/cmp-nvim-lsp',
				'hrsh7th/cmp-nvim-lua',

				-- Snippets
				'L3MON4D3/LuaSnip',
				'rafamadriz/friendly-snippets',
			},
		},
		{
			'fb87/flutter-tools.nvim', branch = "support_nested_dart_sdk",
			lazy = false,
			keys = {
			},
			config = function()
				require("flutter-tools").setup {}
			end
		},
	}

	require("lazy").setup(plugins, opts)
end

function _setup_key_binding()
	local keys = vim.keymap

	keys.set("t", "jk", vim.cmd.FloatermToggle)
	keys.set("t", "<Esc><Esc>", [[<C-\><C-n>]])

	keys.set("n", "<leader>c", vim.cmd.bd)
	keys.set("n", "<leader><leader>", function()
		vim.cmd("so")
	end)
end

function _setup_vim_options()
	local opts = vim.opt

	opts.rnu = true

	-- vim.cmd [[colorscheme murphy]]
end

function main()
	_install_packages()
	_setup_vim_options()
	_setup_key_binding()
end

-- run everything
main()
