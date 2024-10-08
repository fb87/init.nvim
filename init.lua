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
            "nvim-neo-tree/neo-tree.nvim", branch="v3.x",
            keys = {
                { "<leader>e", "<cmd>Neotree toggle<cr>", desc = "Neotree" },
            },
            dependencies = { 
                "nvim-lua/plenary.nvim",
                "nvim-tree/nvim-web-devicons",
                "MunifTanjim/nui.nvim",
            },
            config = function()
                require("neo-tree").setup({
                    event_handlers = {{
                        event = "file_opened",
                        handler = function(file_path)
                          require("neo-tree.command").execute({ action = "close" })
                        end
                    },}
                })
            end,
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

                local cmp = require'cmp'

                cmp.setup({
                    snippet = {
                        -- REQUIRED - you must specify a snippet engine
                        expand = function(args)
                            vim.fn["vsnip#anonymous"](args.body) -- For `vsnip` users.
                            -- require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
                            -- require('snippy').expand_snippet(args.body) -- For `snippy` users.
                            -- vim.fn["UltiSnips#Anon"](args.body) -- For `ultisnips` users.
                            -- vim.snippet.expand(args.body) -- For native neovim snippets (Neovim v0.10+)
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
                        -- { name = 'luasnip' }, -- For luasnip users.
                        -- { name = 'ultisnips' }, -- For ultisnips users.
                        -- { name = 'snippy' }, -- For snippy users.
                    }, {
                        { name = 'buffer' },
                    })
                })
            end
        },
        {
            'fb87/flutter-tools.nvim', branch = "support_nested_dart_sdk",
            lazy = false,
            keys = {
                { "<leader>fr", "<cmd>FlutterRun<cr>" }
            },
            dependencies = {
                'nvim-lua/plenary.nvim',
            },
            config = function()
                require('flutter-tools').setup({
                    settings = {
                        showTodos = true,
                        completeFunctionCalls = true,
                        enableSnippets  = true,
                        updateImportsOnRename = true,
                    },
                    decorations = {
                        statusline = {
                            app_version = true,
                            device = true
                        }
                    },
                })
            end
        },
        { 'vimwiki/vimwiki' },
        { 'stsewd/sphinx.nvim' },

        {
            "folke/noice.nvim",
            event = "VeryLazy",
            opts = {
                -- add any options here
            },
            dependencies = {
                -- if you lazy-load any plugin below, make sure to add proper `module="..."` entries
                "MunifTanjim/nui.nvim",
                -- OPTIONAL:
                --   `nvim-notify` is only needed, if you want to use the notification view.
                --   If not available, we use `mini` as the fallback
                "rcarriga/nvim-notify",
            }
        },

        { 
            'folke/twilight.nvim' ,
            dependencies = {
                'folke/zen-mode.nvim' 
            },
            config = function()
                require('twilight').setup({
                    dimming = {
                        alpha = 0.25, -- amount of dimming
                        -- we try to get the foreground from the highlight groups or fallback color
                        color = { "Normal", "#ffffff" },
                        term_bg = "#000000", -- if guibg=NONE, this will be used to calculate text color
                        inactive = false, -- when true, other windows will be fully dimmed (unless they contain the same buffer)
                    },
                    context = 10, -- amount of lines we will try to show around the current line
                    treesitter = true, -- use treesitter when available for the filetype
                    -- treesitter is used to automatically expand the visible text,
                    -- but you can further control the types of nodes that should always be fully expanded
                    expand = { -- for treesitter, we we always try to expand to the top-most ancestor with these types
                    "function",
                    "method",
                    "table",
                    "if_statement",
                },
                exclude = {}, -- exclude these filetypes
            })
        end
    },
    { "frankroeder/parrot.nvim",
      dependencies = { "ibhagwan/fzf-lua" },
      config = function()
        require("parrot").setup {
          providers = {
            ollama = {
              endpoint = "http://localhost:11434/api/chat",
              topic_prompt = [[
              Summarize the chat above and only provide a short headline of 2 to 3
              words without any opening phrase like "Sure, here is the summary",
              "Sure! Here's a shortheadline summarizing the chat" or anything similar.
              ]],
              topic_model = "llama3.2:latest",
            },
          },
        }
      end
    }
  }
  require("lazy").setup(plugins, opts)
end

function _setup_key_binding()
    local keys = vim.keymap

    keys.set("t", "<leader>jk", "<cmd>ToggleTerm<cr>")
    keys.set("t", "jk", [[<C-\><C-n>]])

    keys.set("n", "<leader>c", vim.cmd.bd)
    keys.set("n", "<leader><leader>", function()
        vim.cmd("so")
    end)
end

function _setup_vim_options()
    local opts = vim.opt

    vim.cmd [[colorscheme rose-pine-main]]
    vim.cmd [[TwilightDisable]]
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
