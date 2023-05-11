vim.cmd[[packadd packer.nvim]]

return require('packer').startup(function(use)
        -- Packer can manage itself
        use 'wbthomason/packer.nvim'

        use {
                "nvim-neo-tree/neo-tree.nvim",
                branch = "v2.x",
                requires = { 
                        "nvim-lua/plenary.nvim",
                        "nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
                        "MunifTanjim/nui.nvim",

                        -- theme
                        use 'folke/tokyonight.nvim',

                        -- fancy terminal manager
                        use 'voldikss/vim-floaterm',

                        -- async lua
                        use "nvim-lua/plenary.nvim",

                        -- fast switching between openned buffer
                        use 'ThePrimeagen/harpoon',

                        -- flutter things
                        use {
                                'fb87/flutter-tools.nvim', branch = 'support_nested_dart_sdk',
                                config = function() require('flutter-tools').setup{} end
                        },

                        use {
                                'nvim-treesitter/nvim-treesitter',
                                run = ':TSUpdate',
                                config = function() 
                                        require'nvim-treesitter.configs'.setup {
                                                ensure_installed = { "c", "python", "lua", "vim", "vimdoc", "query" },
                                                sync_install = false,
                                                auto_install = true,
                                                highlight = {
                                                        enable = true,
                                                        additional_vim_regex_highlighting = false,
                                                },
                                        }
                                end
                        },
                }
        }
end)

