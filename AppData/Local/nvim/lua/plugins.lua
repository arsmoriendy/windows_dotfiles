-- [[ automatically download lazy vim (package manager)
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
else
  vim.keymap.set({ "n" }, "<Leader>l", "<Cmd>Lazy<CR>")
end
vim.opt.rtp:prepend(lazypath)
-- ]]

-- [[ lazy options
local lazy_options = {
}
-- ]]

require("lazy").setup(
  {
    {
      "ellisonleao/gruvbox.nvim", -- colorscheme
      lazy = true,
      priority = 1000,
      config = function()
        require("gruvbox").setup({
          contrast = "hard",
          transparent_mode = true,
          overrides = {
            -- borders
            VertSplit = { bg = "None" },
            -- [[ float
            NormalFloat = { bg = "#3C3836", fg = "#EBDBB2", },
            FloatTitle = { bg = "#3C3836", fg = "#EBDBB2", },
            FloatBorder = { bg = "#3C3836", fg = "#7C6F64", },
            -- ]]
            -- [[ winbar
            WinBar = { bg = "None", fg = "#a89984", },
            NavicText = { fg = "#a89984", },
            NavicSeparator = { fg = "#7C6F64", },
            -- ]]
          }
        })
        vim.cmd("colorscheme gruvbox")
      end,
    },

    {
      "nvim-treesitter/nvim-treesitter", -- basic syntax logic
      config = function()
        require("nvim-treesitter.configs").setup({
          auto_install = true,
          highlight = {
            enable = true
          },
          indent = {
            enable = true,
          },
          -- disable if file size > max_filesize
          disable = function(_, buf)
            local max_filesize = 1048576 -- 1 MiB
            local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
            if ok and stats and stats.size > max_filesize then
              return true
            end
          end
        })
      end
    },

    {
      "lukas-reineke/indent-blankline.nvim", -- indent lines
      dependencies = "ellisonleao/gruvbox.nvim",
      main = "ibl",
      config = function()
        vim.cmd.highlight({ "IblScope", "guifg=#fb4934" })
        require("ibl").setup({
          scope = {
            highlight = {
              "IblScope"
            }
          },
          exclude = {
            filetypes = {
              -- defaults
              'lspinfo',
              "packer",
              "checkhealth",
              "help",
              "man",
              "gitcommit",
              "TelescopePrompt",
              "TelescopeResults",
              "''",
              -- custom
              "norg",
            }
          },
        })
      end
    },

    {
      "SmiteshP/nvim-navic", -- location in current file specifier
      config = function()
        require("nvim-navic").setup({
          separator = "  ",
          click = true,
          highlight = true,
        })
      end,
    },

    {
      "nvim-lualine/lualine.nvim", -- statusline
      dependencies = {
        "nvim-tree/nvim-web-devicons",
        "SmiteshP/nvim-navic",
        "rcarriga/nvim-notify",
      },
      config = function()
        require("lualine").setup({
          options = {
            section_separators = { left = "", right = "" },
            component_separators = { left = "╲", right = "╱" },
          },
          -- statusline
          sections = {
            lualine_a = {
              -- vim logo
              {
                function()
                  return ""
                end
              },
              -- extra symbols for submodes (eg. visual line)
              {
                function()
                  local symbol = {
                    V = "LINE",      -- visual line
                    [""] = "BLOCK", -- visual block
                    s = "SELECT"     -- select
                  }
                  -- return symbol table according to current mode or empty string if nil
                  return symbol[vim.fn.mode()] or ""
                end
              },
              -- snippet indicator
              {
                function() return require("luasnip").in_snippet() and "" or "" end
              },
              -- notification indicator
              {
                function()
                  local nvim_notify = require("notify")
                  if nvim_notify.notification_is_supressed then
                    local indicator = ""
                    if #nvim_notify.supressed_notifications ~= 0 then
                      indicator = indicator .. " " .. #nvim_notify.supressed_notifications
                    end
                    return indicator
                  end
                  return "󰂚"
                end,
                on_click = function()
                  require("notify").toggle_notification_supress()
                  require("lualine").refresh({ place = { "statusline" } })
                end
              },
            },
            lualine_c = {
              {
                "filename",
                newfile_status = true,
                path = 1, --relative path
                symbols = {
                  modified = "●",
                  readonly = "[RO]"
                }
              }
            }
          },
          -- winbar
          winbar = {
            lualine_c = {
              {
                function()
                  local navic_location = require("nvim-navic").get_location()
                  local filename = vim.fn.expand("%:t")
                  local filetype_icon, filetype_icon_color = require("nvim-web-devicons").get_icon(filename)

                  return "%#" ..
                      filetype_icon_color ..
                      "#" .. filetype_icon .. " %#NavicText#" .. filename .. "%#NavicSeparator#  " .. navic_location
                end,
                cond = function()
                  return require("nvim-navic").is_available()
                end,
              },
            },
          },
          -- tabline
          tabline = {
            lualine_a = {
              {
                "tabs",
                max_length = vim.o.columns,
                mode = 1,
                fmt = function(name, context)
                  local buflist = vim.fn.tabpagebuflist(context.tabnr)
                  local winnr = vim.fn.tabpagewinnr(context.tabnr)
                  local bufnr = buflist[winnr]

                  local is_modified = vim.fn.getbufvar(bufnr, "&modified")

                  local filetype_icon = require("nvim-web-devicons").get_icon(name)

                  return (filetype_icon or "") .. " " .. name .. (is_modified == 1 and " ●" or "")
                end,
              }
            }
          },
        })
      end,
    },

    {
      "NvChad/nvim-colorizer.lua", -- color indicator
      config = function()
        require("colorizer").setup({
          user_default_options = {
            mode = "virtualtext",
            css = true
          }
        })
      end
    },

    {
      "uga-rosa/ccc.nvim", -- color picker
      cmd = "Ccc",
      config = function()
        require("ccc").setup({
          point_char = "⠶",
          point_color = "#7C6F64",
          win_opts = {
            border = "single",
            title = "Color Picker",
          }
        })
      end
    },

    {
      "folke/twilight.nvim", -- focus on scope
      cmd = "Twilight",
      config = function()
        require("twilight").setup()
      end,
    },

    {
      "numToStr/Comment.nvim", -- commenting helper
      config = function()
        require("Comment").setup()
        local ft = require("Comment.ft")
        ft.kdl = { "// %s" }
      end
    },

    {
      "nvim-tree/nvim-tree.lua", -- file explorer
      config = function()
        vim.keymap.set("n", "<SPACE>", ":NvimTreeToggle<CR>", { silent = true })
        -- on VimEnter, if file is directory, open nvim-tree and cd into directory
        vim.api.nvim_create_autocmd({ "VimEnter" }, {
          callback = function(data)
            if vim.fn.isdirectory(data.file) == 1 then
              vim.cmd.cd(data.file)
              require("nvim-tree.api").tree.open()
            end
          end
        })
        -- highlights
        vim.cmd.highlight({ "NvimTreeIndentMarker", "guifg=#504945" })
        -- setup
        require("nvim-tree").setup({
          disable_netrw = true, -- disable netrw (vim's built-in manager; as recomended by nvim-tree documentation)
          hijack_netrw = true,
          hijack_cursor = true,
          actions = {
            open_file = {
              quit_on_open = true,
            },
          },
          tab = {
            sync = {
              open = true,
              close = true,
            }
          },
          update_focused_file = {
            enable = true,
            update_root = true,
          },
          renderer = {
            root_folder_label = false,
            indent_markers = {
              enable = true,
            }
          },
        })
      end,
      dependencies = "nvim-tree/nvim-web-devicons",
    },

    {
      "windwp/nvim-autopairs", -- auto pairing
      config = function()
        require("nvim-autopairs").setup()
      end
    },

    {
      "neovim/nvim-lspconfig",               -- LSP
      dependencies = {
        "williamboman/mason.nvim",           -- mason.nvim (LSP auto installer)
        "williamboman/mason-lspconfig.nvim", -- mason-lspconfig.nvim (Bridges mason.nvim and nvim-lspconfig)
        "SmiteshP/nvim-navic",               -- winbar
      },
      config = function()
        -- dependency ordering matters
        require("mason").setup()
        require("mason-lspconfig").setup({})
        -- automatic server config setup (:h mason-lspconfig-automatic-server-setup)
        require("mason-lspconfig").setup_handlers({
          function(server_name)
            -- specific server configs
            local configs = {
              lua_ls = {
                settings = {
                  Lua = {
                    diagnostics = {
                      -- Get the language server to recognize the `vim` global
                      globals = { "vim" },
                    },
                    workspace = {
                      -- Make the server aware of Neovim runtime files
                      library = vim.api.nvim_get_runtime_file("", true),
                      checkThirdParty = false,
                    },
                    -- Do not send telemetry data containing a randomized but unique identifier
                    telemetry = {
                      enable = false,
                    },
                  }
                }
              },
              emmet_ls = {
                -- add php for emmet
                filetypes = { "html", "typescriptreact", "javascriptreact", "css", "sass", "scss", "less", "eruby", "php" },
              },
              intelephense = {
                telemetry = {
                  enabled = false,
                },
              },
            };
            -- current config
            local config = configs[server_name] or {};
            -- append default configs
            config.capabilities = require("cmp_nvim_lsp").default_capabilities(); -- cmp lsp capabilities
            config.on_attach = function(client, bufnr)                            -- attach nvim-navic if possible
              if client.server_capabilities.documentSymbolProvider then
                require("nvim-navic").attach(client, bufnr)
              end
            end;
            require("lspconfig")[server_name].setup(config);
          end
        })

        require("lspconfig").dartls.setup({
          root_dir = function()
            return vim.fn.getcwd()
          end
        })
        require("lspconfig").glslls.setup({})

        -- summon ui mapping
        vim.keymap.set({ "n" }, "<Leader>m", "<Cmd>Mason<CR>")
      end
    },

    {
      "L3MON4D3/LuaSnip", -- snippet engine
      dependencies = { "rafamadriz/friendly-snippets" },
      config = function()
        -- atuo load snippets from friendly-snippets
        require("luasnip.loaders.from_vscode").lazy_load()
        local luasnip = require("luasnip")
        -- jump forwards in snippets / tab
        vim.keymap.set({ "i", "s" }, "<Tab>", function()
          require("lualine").refresh({ place = { "statusline" } })
          if luasnip.locally_jumpable() then
            return "<Plug>luasnip-jump-next"
          else
            return "<Tab>"
          end
        end, { silent = true, expr = true })
        -- jump backwards in snippets
        vim.keymap.set({ "i", "s" }, "<S-Tab>", function()
          if luasnip.jumpable() then
            luasnip.jump(-1)
          end
        end)
      end
    },

    {
      "hrsh7th/nvim-cmp",           -- dropdown completion
      dependencies = {
        "saadparwaiz1/cmp_luasnip", -- for integration with luasnip
        "hrsh7th/cmp-nvim-lsp",     -- for integration with lsp
        "hrsh7th/cmp-path",
        "hrsh7th/cmp-buffer"
      },
      config = function()
        local cmp = require("cmp")
        local cmp_map_function = function(action)
          return function(fallback)
            if cmp.visible() then action() else fallback() end
          end
        end

        cmp.setup({
          mapping = {
            ["<C-n>"] = cmp.mapping({ i = cmp_map_function(cmp.select_next_item) }),
            ["<Down>"] = cmp.mapping({ i = cmp_map_function(cmp.select_next_item) }),
            ["<C-p>"] = cmp.mapping({ i = cmp_map_function(cmp.select_prev_item) }),
            ["<Up>"] = cmp.mapping({ i = cmp_map_function(cmp.select_prev_item) }),
            ["<C-down>"] = cmp.mapping({ i = cmp_map_function(function() cmp.scroll_docs(1) end) }),
            ["<C-up>"] = cmp.mapping({ i = cmp_map_function(function() cmp.scroll_docs(-1) end) }),
            ["<C-d>"] = cmp.mapping({ i = cmp.complete }),
            ["<CR>"] = cmp.mapping({ i = cmp_map_function(function() cmp.confirm({ select = true }) end) }),
            ["<C-x>"] = cmp.mapping({ i = cmp_map_function(cmp.abort) }),
            ["<C-c>"] = cmp.mapping({ i = cmp_map_function(function()
              cmp.abort()
              vim.cmd("stopinsert")
            end) }),
            ["<Esc>"] = cmp.mapping({ i = cmp_map_function(function()
              cmp.abort()
              vim.cmd("stopinsert")
            end) }),
          },
          snippet = {
            expand = function(args)
              require("luasnip").lsp_expand(args.body)
            end
          },
          sources = {
            { name = "luasnip" },
            { name = "path" },
            { name = "buffer" },
            { name = "nvim_lsp" },
          },
          --[[ experimental = {
          ghost_text = true
        }, ]]
        })
      end
    },

    {
      "petertriho/nvim-scrollbar",   -- scrollbar
      dependencies = {
        "kevinhwang91/nvim-hlslens", -- search handler
        "lewis6991/gitsigns.nvim"    -- git signs handler
      },
      config = function()
        require("scrollbar.handlers.search").setup({}) -- need table parameter
        require("scrollbar.handlers.gitsigns").setup()
        require("scrollbar").setup({
          hide_if_all_visible = false,
          excluded_filetypes = {
            -- disable scrollbar for alpha (blank startup plugin)
            "alpha",
            "ccc-ui",
          },
          handle = {
            highlight = "Visual"
          }
        })
      end
    },

    {
      "lewis6991/gitsigns.nvim", -- git signs (next to number column) and git mappings
      config = function()
        local gitsigns = require("gitsigns")
        gitsigns.setup()
        -- mappings
        local map = vim.keymap.set
        map("n", "gn", gitsigns.next_hunk)
        map("n", "gN", gitsigns.prev_hunk)
        map("n", "gp", gitsigns.preview_hunk)
        map("n", "gd", gitsigns.diffthis)
        map("n", "gs", gitsigns.stage_hunk)
        -- stage selected
        map("x", "gs", [[<ESC>:lua require("gitsigns").stage_hunk({vim.fn.line("'<"), vim.fn.line("'>")})<CR>gv]])
        -- reset hunk
        map("n", "gr", gitsigns.reset_hunk)
        map("x", "gr", [[<ESC>:lua require("gitsigns").reset_hunk({vim.fn.line("'<"), vim.fn.line("'>")})<CR>gv]])
        map("n", "gR", gitsigns.reset_buffer)
      end
    },

    {
      "goolord/alpha-nvim", -- startup splash screen
      config = function()
        -- highlights
        vim.cmd([[
      highlight AlphaLogo guifg=#504945
      highlight AlphaText guifg=#665C54
      highlight AlphaTextItalic guifg=#665C54 gui=italic
      highlight AlphaTextBold guifg=#665C54 gui=bold
      highlight AlphaTextBoldItalic guifg=#665C54 gui=bold,italic
      ]])

        -- header
        local header = {
          type = "text",
          val = {
            [[     ▗▛                                            ▜▖     ]],
            [[    ▟▛                                              ▜▙    ]],
            [[   ▟▛               ▗▟█████▄▄▄▄█████▙▖               ▜▙   ]],
            [[  ▟█              ▗▟██████████████████▙▖              █▙  ]],
            [[ ▐██             ▟██████████████████████▙             ██▌ ]],
            [[  ██▙          ▗▟████████████████████████▙▖          ▟██  ]],
            [[  ▐███▙▂▂   ▂▂▟████████████████████████████▙▂▂   ▂▂▟███▌  ]],
            [[    ▜████████████████████████████████████████████████▛    ]],
            [[      ▀▀▀▀██████████████████████████████████████▀▀▀▀      ]],
            [[              ▀▀▀▀▀██   ▝▜██████▛▘   ██▀▀▀▀▀              ]],
            [[                    ▜▙    ██████    ▟▛                    ]],
            [[                     ▜██▆▆██████▆▆██▛                     ]],
            [[                      ▜████████████▛                      ]],
            [[                       ▜██████████▛                       ]],
            [[                        ▜████████▛                        ]],
            [[                        ██████████                        ]],
            [[                         ▜█▅██▅█▛                         ]],
          },
          opts = {
            position = "center",
            hl = "AlphaLogo",
          },
        }

        -- subheader
        local subheader = {
          type = "text",
          val = function()
            -- neovim version
            local nvim_version_table = vim.version()
            -- if version is under 15
            -- convert version decimal to hex for 1 digit numbers
            -- else replace with "X" as placeholder
            local parsed_major = nvim_version_table.major <= 15
                and string.upper(string.format("%x ", nvim_version_table.major))
                or " X"
            local parsed_minor = nvim_version_table.minor <= 15
                and string.upper(string.format("%x ", nvim_version_table.minor))
                or " X"
            local parsed_patch = nvim_version_table.patch <= 15
                and string.upper(string.format("%x ", nvim_version_table.patch))
                or " X"

            local lazy_stats = require("lazy").stats()

            -- redraw alpha when lazy has finished calculating startuptime
            vim.api.nvim_create_autocmd("User", {
              pattern = "LazyVimStarted",
              command = "AlphaRedraw",
            })

            return {
              "NEOVIM INFORMATION        + + + + +",
              "------------------------- + N E O +",
              string.format("%-28s",
                " v" .. nvim_version_table.major .. "." .. nvim_version_table.minor .. "." .. nvim_version_table
                .patch) .. "+ V I M +",
              string.format("%-29s", "󰒲 " .. lazy_stats.count .. " plugins installed") ..
              "+ " .. parsed_major .. parsed_minor .. parsed_patch .. "+",
              string.format("%-29s", "󰀠 " .. string.format("%.2f", lazy_stats.startuptime) .. "ms startuptime") ..
              "+ + + + +",
            }
          end,
          opts = {
            position = "center",
            hl = "AlphaTextBold",
          },
        }

        -- button factory
        local button = function(val, action)
          local shortcut = string.lower(string.sub(val, 1, 1))
          local shortcut_string = "[" .. shortcut .. "]"

          return {
            type = "button",
            val = val,
            on_press = function() vim.api.nvim_input(action) end,
            opts = {
              position = "center",
              width = 35,
              hl = "AlphaTextBold",
              shortcut = shortcut_string,
              align_shortcut = "right",
              hl_shortcut = "AlphaTextBold",
              keymap = { "n", shortcut, action, { silent = true } },
            }
          }
        end

        -- button group
        local buttonGroup = {
          type = "group",
          val = {
            button("New File", ":enew <CR>"),
            button("Plugins Profile", ":Lazy profile<CR>"),
            button("Check Plugins", ":Lazy check<CR>"),
            button("Update Plugins", ":Lazy update<CR>"),
            button("Quit", ":q <CR>"),
          },
          opts = {
            spacing = 1,
          }
        }

        local theme = {
          layout = {
            { type = "padding", val = 8 },
            header,
            { type = "padding", val = 2 },
            subheader,
            { type = "padding", val = 2 },
            {
              type = "text",
              val = {
                "ACTIONS",
                "-----------------------------------"
              },
              opts = {
                position = "center",
                hl = "AlphaTextBold",
              },
            },
            buttonGroup,
            { type = "padding", val = 10 },
          }
        }

        require("alpha").setup(theme)
      end
    },

    {
      "rcarriga/nvim-notify", -- notification
      config = function()
        local nvim_notify = require("notify")
        nvim_notify.setup({
          background_colour = "#00000000",
        })
        vim.notify = nvim_notify -- implement

        -- suppress notifications [[
        nvim_notify.notification_is_supressed = false
        nvim_notify.supressed_notifications = {}

        nvim_notify.insert_supressed_notifications = function(msg, level, opts)
          local local_supressed_notifications = nvim_notify.supressed_notifications
          table.insert(local_supressed_notifications, {
            msg = msg,
            level = level,
            opts = opts
          })
          nvim_notify.supressed_notifications = local_supressed_notifications
        end

        nvim_notify.toggle_notification_supress = function()
          if nvim_notify.notification_is_supressed then
            vim.notify = nvim_notify
            for _, notification in pairs(nvim_notify.supressed_notifications) do
              vim.notify(notification.msg, notification.level, notification.opts)
            end
            nvim_notify.supressed_notifications = {}
          else
            vim.notify = nvim_notify.insert_supressed_notifications
          end
          nvim_notify.notification_is_supressed = not nvim_notify.notification_is_supressed
        end

        vim.keymap.set("n", "<Leader>ns", function()
          nvim_notify.toggle_notification_supress()
          require("lualine").refresh({ place = { "statusline" } })
        end)
        -- ]]

        -- dismiss all notifications
        vim.keymap.set("n", "<Leader>nd", function()
          nvim_notify.dismiss()
        end)
      end,
    },

    {
      "stevearc/dressing.nvim", -- vim.ui.select vim.ui.input
      event = "VeryLazy",
      config = function()
        require("dressing").setup({
          input = {
            -- When true, <Esc> will close the modal
            insert_only = false,

            win_options = {
              -- Window transparency (0-100)
              winblend = 0,
            },

            -- Set to `false` to disable
            mappings = {
              n = {
                ["q"] = "Close",
              },
            },

            override = function(conf)
              conf.border = "single";
              return conf
            end,
          },
          select = {
            -- Options for built-in selector
            builtin = {
              win_options = {
                -- Window transparency (0-100)
                winblend = 0,
              },

              -- These can be integers or a float between 0 and 1 (e.g. 0.4 for 40%)
              -- the min_ and max_ options can be a list of mixed types.
              -- max_width = {140, 0.8} means "the lesser of 140 columns or 80% of total"
              max_height = 0.8,

              mappings = {
                ["q"] = "Close",
              },

              override = function(conf)
                conf.border = "single";
                return conf
              end,
            },
          },
        })
      end,
    },

    {
      "ellisonleao/glow.nvim", -- markdown viewer
      cmd = "Glow",
      config = function()
        require("glow").setup({
          border = "single",
        })
        vim.keymap.set("n", "<Leader>g", "<CMD>Glow<CR>")
      end,
    },

    {
      "kevinhwang91/nvim-ufo", -- fold handling
      dependencies = {
        "neovim/nvim-lspconfig",
        "nvim-treesitter/nvim-treesitter",
        "kevinhwang91/promise-async",
      },
      config = function()
        vim.o.foldlevel = 99 -- Using ufo provider need a large value, feel free to decrease the value
        vim.o.foldlevelstart = 99
        -- Using ufo provider need remap `zR` and `zM`. If Neovim is 0.6.1, remap yourself
        vim.keymap.set("n", "zR", require("ufo").openAllFolds)
        vim.keymap.set("n", "zM", require("ufo").closeAllFolds)
        require("ufo").setup({
          provider_selector = function(_, filetype, _)
            if (filetype == "norg") then
              return { "treesitter" }
            end
          end
        })
      end
    },

    {
      "nvim-telescope/telescope.nvim", -- telescope
      event = "VeryLazy",
      dependencies = {
        "nvim-lua/plenary.nvim",
        "nvim-telescope/telescope-fzf-native.nvim",
        "nvim-tree/nvim-web-devicons",
        "rcarriga/nvim-notify",
      },
      config = function()
        require("telescope").setup({
          defaults = {
            borderchars = { "─", "│", "─", "│", "┌", "┐", "┘", "└" },
            prompt_prefix = " ",
          },
          pickers = {
            man_pages = {
              sections = { "ALL" },
            },
          },
        })
        require("telescope").load_extension("notify")
        require("telescope").load_extension("fzf")
        -- highlights
        vim.cmd([[
        highlight! link TelescopeNormal NormalFloat
        highlight! link TelescopeBorder FloatBorder
        highlight! link TelescopeResultsBorder TelescopeBorder
        highlight! link TelescopePreviewBorder TelescopeBorder
        highlight! link TelescopePromptBorder TelescopeBorder
        highlight! link TelescopeTitle FloatTitle
        highlight! link TelescopeResultsDiffUntracked GruvboxFg4
        highlight! link TelescopePromptCounter GruvboxFg4
        highlight! link TelescopePreviewHyphen GruvboxFg4
        ]])
        -- keymaps [[
        local builtin = require("telescope.builtin")
        vim.keymap.set("n", "<C-p>", builtin.find_files)
        vim.keymap.set("n", "<Leader>h", builtin.help_tags)
        vim.keymap.set("n", "<Leader>nh", require("telescope").extensions.notify.notify)
        vim.keymap.set("n", "<Leader>p", function() builtin.builtin({ include_extensions = true, }) end)
        -- ]]
      end,
    },

    {
      "nvim-telescope/telescope-fzf-native.nvim", -- telescope
      build = "make",
    },

    {
      "nvim-neorg/neorg", -- neorg (emacs org)
      build = ":Neorg sync-parsers",
      dependencies = { "nvim-lua/plenary.nvim" },
      config = function()
        vim.api.nvim_create_autocmd("BufWinEnter", {
          pattern = "*.norg",
          callback = function()
            vim.wo.conceallevel = 2
          end
        })
        require("neorg").setup({
          load = {
            ["core.defaults"] = {},  -- Loads default behaviour
            ["core.concealer"] = {}, -- Adds pretty icons to your documents
            ["core.dirman"] = {      -- Manages Neorg workspaces
              config = {
                workspaces = {
                  notes = "~/Documents/notes",
                },
              },
            },
          },
        })
      end,
    },
  },
  lazy_options
)
