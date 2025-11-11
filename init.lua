-- vim: tabstop=4 autoindent tabstop=4 shiftwidth=4 expandtab
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

    local opts = { default = { lockfile = vim.fn.stdpath("data") .. "/lazy-lock.json", } }
    local plugins = {
        {
            "gmml-org/llama.vim"
        },
        {
            "NStefan002/screenkey.nvim",
            lazy = false,
            version = "*",
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
                { "<leader>jk", "<cmd>ToggleTerm direction=float<cr>", desc = "Toggle Terminal" },
            }
        },
        {
            "nvim-treesitter/nvim-treesitter",
            lazy = false,
            cmd = "TSUpdate",
            config = function()
                require'nvim-treesitter.configs'.setup {
                    ensure_installed = { "c", "nix", "python", "cmake", "lua", "vim", "vimdoc", "dart" },
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
            'nvim-telescope/telescope.nvim',
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
            lazy = false,
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
            config = function() 
                local lsp = require('lsp-zero').preset({})
                lsp.on_attach(function(client, bufnr)
                    lsp.default_keymaps({buffer = bufnr})
                end)

                lsp.setup()

                -- setup autocomplete
                local cmp = require('cmp')

                cmp.setup({
                    snippet = {
                        -- REQUIRED - you must specify a snippet engine
                        expand = function(args)
                            vim.fn["vsnip#anonymous"](args.body) -- For `vsnip` users.
                            require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
                            -- require('snippy').expand_snippet(args.body) -- For `snippy` users.
                            -- vim.fn["UltiSnips#Anon"](args.body) -- For `ultisnips` users.
                            vim.snippet.expand(args.body) -- For native neovim snippets (Neovim v0.10+)
                        end,
                    },
                    window = {
                        -- completion = cmp.config.window.bordered(),
                        -- documentation = cmp.config.window.bordered(),
                    },
                    mapping = cmp.mapping.preset.insert({
                        ['<C-b>'] = cmp.mapping.scroll_docs(-4),
                        ['<C-f>'] = cmp.mapping.scroll_docs(4),
                        ['<C-Space>'] = cmp.mapping.complete(),
                        ['<C-e>'] = cmp.mapping.abort(),
                        ['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
                    }),
                    sources = cmp.config.sources({
                        { name = 'nvim_lsp' },
                        { name = 'vsnip' }, -- For vsnip users.
                        { name = 'luasnip' }, -- For luasnip users.
                        -- { name = 'ultisnips' }, -- For ultisnips users.
                        -- { name = 'snippy' }, -- For snippy users.
                    }, {
                        { name = 'buffer' },
                    })
                })
            end
        },

        { 'vimwiki/vimwiki' },
        { 'stevearc/oil.nvim', dependencies = { { "echasnovski/mini.icons", opts = {} } },
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
                -- optionally override the oil buffers window title with custom function: fun(winid: integer): string
                get_win_title = nil,
                -- preview_split: Split direction: "auto", "left", "right", "above", "below".
                preview_split = "auto",
                -- This is the config that will be passed to nvim_open_win.
                -- Change values here to customize the layout
                override = function(conf)
                    return conf
                end,
            },

            -- Configuration for the file preview window
            preview_win = {
                -- Whether the preview window is automatically updated when the cursor is moved
                update_on_cursor_moved = true,
                -- How to open the preview window "load"|"scratch"|"fast_scratch"
                preview_method = "fast_scratch",
                -- A function that returns true to disable preview on a file e.g. to avoid lag
                disable_preview = function(filename)
                    return false
                end,
                -- Window-local options to use for preview window buffers
                win_options = {},
            },
        }) end },
    }

    require("lazy").setup(plugins, opts)
    require'lspconfig'.nixd.setup{}
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
    vim.cmd [[Screenkey toggle]]

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
