CONFIG = {
  ui = {theme = 'onedark', style = 'dark'},
  completion = function(cpu)
    if cpu > 4 then
      return 'coq_nvim'
    else
      return 'nvim-compe'
    end
  end
}

-- UTILITIES {{{

PROCESSORS = 1
if vim.fn.empty("$NUMBER_OF_PROCESSORS") == true then
  PROCESSORS = os.getenv("NUMBER_OF_PROCESSORS")
elseif vim.fn.filereadable('/proc/cpuinfo') then
  PROCESSORS = vim.fn.system('grep -c ^processor /proc/cpuinfo') + 0
elseif vim.fn.executable('/usr/sbin/psrinfo') then
  PROCESSORS = vim.fn.system('/usr/sbin/psrinfo -p')
end

function map(mode, lhs, rhs, opts)
    opts = vim.tbl_extend('keep', opts or {}, {noremap = true, silent = true})
    local bufnr = opts['buffer']
    opts['buffer'] = nil
    if bufnr ~= nil then
        vim.api.nvim_buf_set_keymap(bufnr, mode, lhs, rhs, opts)
    else
        vim.api.nvim_set_keymap(mode, lhs, rhs, opts)
    end
end
__wk_mappings = {}
function wkmap(...) __wk_mappings[#__wk_mappings + 1] = {...} end
function wkapply()
    local p0, wk = pcall(require, 'which-key')
    if not p0 then return end
    for _, args in ipairs(__wk_mappings) do wk.register(unpack(args)) end
end
function nmap(...) map('n', ...) end
function imap(...) map('i', ...) end
function tmap(...) map('t', ...) end
function smap(...) map('s', ...) end
function xmap(...) map('x', ...) end
function augroup(name, lines)
    vim.api.nvim_command('augroup ' .. name)
    vim.api.nvim_command('autocmd!')
    for _, def in ipairs(lines) do
        vim.api.nvim_command(
            table.concat(vim.tbl_flatten({'autocmd', def}), ' '))
    end
    vim.api.nvim_command('augroup END')
end

-- }}}
-- OPTIONS {{{

if vim.fn.executable('pyenv') then
    vim.g.python_host_prog = vim.fn.trim(vim.fn.system('pyenv root')) ..
                                 '/versions/neovim2/bin/python'
    vim.g.python3_host_prog = vim.fn.trim(vim.fn.system('pyenv root')) ..
                                  '/versions/neovim3/bin/python'
end

if vim.fn.executable('rbenv') then
    vim.g.ruby_host_prog = vim.fn.trim(vim.fn.system('rbenv root')) ..
                               '/versions/2.7.1/bin/neovim-ruby-host'
end

vim.opt.undofile = true
vim.opt.hidden = true
vim.opt.signcolumn = 'yes'
vim.opt.splitbelow = true
vim.opt.splitright = true
vim.opt.timeoutlen = 300
vim.opt.shortmess:append('c')
vim.opt.updatetime = 300
vim.opt.scrolloff = 5
vim.opt.wildmode = {'longest', 'full'}
vim.opt.wildignore:append({
    '*.o', '*~', '*.pyc', '*.aux', '*.out', '*.toc', '*.orig', '*.sw?',
    '*/.git/*', '*/.hg/*', '*/.svg/*'
})
vim.opt.whichwrap:append({
    ['<'] = true,
    ['>'] = true,
    ['h'] = true,
    ['l'] = true
})
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.hlsearch = true
vim.opt.inccommand = 'split'
vim.opt.lazyredraw = true
vim.opt.magic = true
vim.opt.showmatch = true
vim.opt.mat = 2
vim.opt.foldmethod = 'expr'
vim.opt.foldlevel = 99
vim.opt.mouse = 'a'
vim.opt.completeopt = {'menuone', 'noselect'}

if vim.fn.has('termguicolors') then vim.opt.termguicolors = true end
vim.opt.colorcolumn = '81,121'
vim.opt.background = 'dark'
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.cursorline = true
vim.opt.foldcolumn = '0'
vim.opt.conceallevel = 2
vim.opt.concealcursor = 'nc'
vim.opt.ffs = 'unix,dos,mac'
vim.opt.expandtab = true
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2
vim.opt.linebreak = true
vim.opt.wrap = true
vim.opt.breakindent = true
vim.opt.breakindentopt = 'shift:4,min:40'
vim.opt.showbreak = '…'
vim.opt.autoindent = true
vim.opt.smartindent = true

vim.g.mapleader = ' '
vim.g.maplocalleader = ','

-- }}}
-- MAPPINGS {{{

nmap("<space>", "<nop>")
xmap("<space>", "<nop>")
xmap("<bs>", "x", {noremap = false})

wkmap({
    name = 'buffers',
    n = {[[:e<space>]], 'new', silent = false},
    o = {[[:e<space>]], 'open', silent = false},
    w = {[[:w<cr>]], 'write'},
    x = {[[:w<cr>:bd<cr>]], 'write-close'},
    q = {[[:bd<cr>]], 'quit'},
    c = {[[:bd<cr>]], 'close'},
    Q = {[[:bd!<cr>]], 'force-quit'},
    C = {[[:bd!<cr>]], 'force-close'}
}, {prefix = '<leader>b'})

nmap('t', [[:tabnew<cr>]])
nmap('<tab>', [[:tabnext<cr>]])
nmap('<s-tab>', [[:tabprevious<cr>]])
wkmap({
    name = 'tabs',
    n = {[[:tabnew<cr>]], 'new'},
    o = {[[:tabnew<space>]], 'open', silent = false},
    c = {[[:tabclose<cr>]], 'close'},
    e = {[[:tabedit<space>]], 'edit', silent = false},
    k = {[[:tabnext<cr>]], 'next'},
    j = {[[:tabprevious<cr>]], 'prev'}
}, {prefix = '<leader>t'})

nmap('<C-h>', '<C-w>h', {noremap = false})
nmap('<C-l>', '<C-w>l', {noremap = false})
nmap('<C-j>', '<C-w>j', {noremap = false})
nmap('<C-k>', '<C-w>k', {noremap = false})

-- }}}
-- PLUGIN-CONFIGURATIONS {{{

-- wbthomason/packer.nvim {{{
local packer_path = vim.fn.stdpath('data') ..
                        '/site/pack/packer/opt/packer.nvim'

if vim.fn.empty(vim.fn.glob(packer_path)) then
    vim.fn.delete(packer_path, 'rf')
    vim.fn.system({
        'git', 'clone', 'https://github.com/wbthomason/packer.nvim', '--depth',
        '20', packer_path
    })
end

vim.cmd('packadd packer.nvim')
local has_packer, packer = pcall(require, 'packer')

if not has_packer then
    error("Failed to load packer!\nPacker path: " .. packer_path)
end
-- }}}
-- neovim/nvim-lspconfig {{{
__nvim_lspconfig_config = {}
local function __nvim_lspconfig_on_attach(client, bufnr)
    local wk = require('which-key')

    wk.register({
        ['<leader>'] = {
            j = {
                name = 'lsp',
                D = {
                    '<cmd>lua vim.lsp.buf.declaration()<cr>', 'goto-declaration'
                },
                d = {'<cmd>lua vim.lsp.buf.definition()<cr>', 'goto-definition'},
                i = {
                    '<cmd>lua vim.lsp.buf.implementation()<cr>',
                    'goto-implementation'
                },
                r = {'<cmd>lua vim.lsp.buf.references()<cr>', 'goto-references'}
            }
        },
        ['[d'] = {
            '<cmd>lua vim.lsp.diagnostics.goto_prev()<cr>',
            'prev-lsp-diagnostic'
        },
        [']d'] = {
            '<cmd>lua vim.lsp.diagnostics.goto_prev()<cr>',
            'next-lsp-diagnostic'
        }
    }, {buffer = bufnr})
end
function nvim_lspconfig()
    vim.lsp.handlers['textDocument/publishDiagnostics'] =
        vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics, {
            underline = true,
            virtual_text = false,
            signs = true,
            update_in_insert = false
        })
    vim.fn.sign_define('LspDiagnosticsSignError', {text = ""})
    vim.fn.sign_define('LspDiagnosticsSignWarning', {text = ""})
    vim.fn.sign_define('LspDiagnosticsSignHint', {text = ""})
    vim.fn.sign_define('LspDiagnosticsSignInformation', {text = ""})
    vim.fn.sign_define('LspDiagnosticsSignOther', {text = "﫠"})

    __nvim_lspconfig_config['sumneko_lua'] = {
        settings = {
            Lua = {
                diagnostics = {globals = {"vim"}},
                workspace = {
                    library = {
                        [vim.fn.expand("$VIMRUNTIME/lua")] = true,
                        [vim.fn.expand("$VIMRUNTIME/lua/vim/lsp")] = true
                    },
                    maxPreload = 100000,
                    preloadFileSize = 10000
                },
                telemetry = {enable = false}
            }
        }
    }
    __nvim_lspconfig_config['ccls'] = {
        init_options = {highlight = {lsRanges = true}}
    }
end
-- }}}
-- kabouzeid/nvim-lspinstall {{{
function __nvim_lspinstall_setup_servers()
    local lspinstall = require('lspinstall')
    local lspconfig = require('lspconfig')

    lspinstall.setup()
    for _, lang in pairs(lspinstall.installed_servers()) do
        lspconfig[lang].setup(vim.tbl_deep_extend('keep',
                                                  __nvim_lspconfig_config[lang] or
                                                      {}, {
            on_attach = __nvim_lspconfig_on_attach,
            root_dir = vim.loop.cwd
        }))
    end
end
function nvim_lspinstall()
    __nvim_lspinstall_setup_servers()
    require('lspinstall').post_install_hook = function()
        __nvim_lspinstall_setup_servers()
        vim.cmd('bufdo e')
    end
end
-- }}}
-- williamboman/nvim-lsp-installer {{{
function nvim_lsp_installer()
    local lsp_installer = require('nvim-lsp-installer')
    local servers = require('nvim-lsp-installer.server')
    local shell = require('nvim-lsp-installer.installers.shell')
    local path = require "nvim-lsp-installer.path"

    local ccls_path = servers.get_server_root_path('ccls')
    lsp_installer.register(servers.Server:new({
        name = 'ccls',
        root_dir = ccls_path,
        installer = shell.bash([[
          git clone --depth=1 --recursive https://github.com/MaskRay/ccls;
          cmake -H. -S ccls -B ccls/build -G Ninja -DCMAKE_CXX_COMPILER=clang++ -DCMAKE_PREFIX_PATH=/usr/lib/llvm-12 -DLLVM_INCLUDE_DIR=/usr/lib/llvm-12/include -DLLVM_BUILD_INCLUDE_DIR=/usr/include/llvm-12/;
          cmake --build ccls/build;
        ]]),
        default_options = {
            cmd = {path.concat {ccls_path, 'ccls', 'build', 'ccls'}}
        }
    }))

    if CONFIG.completion(PROCESSORS) == 'coq_nvim' then
      local coq = require('coq')
      lsp_installer.on_server_ready(function(server)
          server:setup(coq.lsp_ensure_capabilities(
                           vim.tbl_deep_extend('keep',
                                               __nvim_lspconfig_config[server.name] or
                                                   {}, {
                  on_attach = __nvim_lspconfig_on_attach,
                  root_dir = vim.loop.cwd
              })))
          vim.cmd([[ do User LspAttachBuffers ]])
      end)
    else
      lsp_installer.on_server_ready(function(server)
          server:setup(
                           vim.tbl_deep_extend('keep',
                                               __nvim_lspconfig_config[server.name] or
                                                   {}, {
                  on_attach = __nvim_lspconfig_on_attach,
                  root_dir = vim.loop.cwd
              }))
          vim.cmd([[ do User LspAttachBuffers ]])
      end)
    end
    local present, _ = pcall(require, 'nvim-tree')
    if present then
        require('nvim-lsp-installer.adapters.nvim-tree').connect()
    end
end
-- }}}
-- folke/lsp-colors.nvim {{{
function lsp_colors_nvim() require('lsp-colors').setup({}) end
-- }}}
-- folke/trouble.nvim {{{
function trouble_nvim_config() require('trouble').setup({}) end
function trouble_nvim_setup()
    local wk = require('which-key')
    wk.register({
        name = 'trouble',
        x = {'<cmd>Trouble<cr>', 'toggle'},
        w = {'<cmd>Trouble lsp_workspace_diagnostics<cr>', 'workspace'},
        d = {'<cmd>Trouble lsp_document_diagnostics<cr>', 'document'},
        l = {'<cmd>Trouble loclist<cr>', 'loclist'},
        q = {'<cmd>Trouble quickfix<cr>', 'quickfix'},
        r = {'<cmd>Trouble lsp_references<cr>', 'references'}
    }, {prefix = '<leader>x'})
end
-- }}}
-- glepnir/lspsaga.nvim {{{
function lspsaga_nvim()
    wk = require('which-key')

    wk.register({
        ['[e'] = {
            "<cmd>lua require'lspsaga.diagnostic'.lsp_jump_diagnostic_prev()",
            'prev-lsp-diagnostic'
        },
        [']e'] = {
            "<cmd>lua require'lspsaga.diagnostic'.lsp_jump_diagnostic_next()",
            'next-lsp-diagnostic'
        },
        ['<leader>'] = {
            f = {
                name = 'fix',
                j = {
                    "<cmd>lua require'lspsaga.codeaction'.code_action()<cr>",
                    'lsp-action'
                },
                r = {"<cmd>lua require'lspsaga.rename'.rename()<cr>", 'rename'}
            },
            j = {
                name = 'lsp',
                f = {
                    "<cmd>lua require'lspsaga.provider'.lsp_finder()<cr>",
                    'find'
                },
                a = {
                    "<cmd>lua require'lspsaga.codeaction'.code_action()<cr>",
                    'action'
                },
                s = {
                    "<cmd>lua require'lspsaga.signaturehelp'.signature_help()<cr>",
                    'signature-help'
                },
                p = {
                    "<cmd>lua require'lspsaga.provider'.preview_definition()<cr>",
                    'preview-definition'
                },
                k = {
                    "<cmd>lua require'lspsaga.hover'.render_hover_doc()<cr>",
                    'documentation'
                },
                r = {"<cmd>lua require'lspsaga.rename'.rename()<cr>", 'rename'},
                c = {
                    "<cmd>lua require'lspsaga.diagnostic'.show_cursor_diagnostic()<cr>",
                    'cursor-diagnostics'
                },
                j = {
                    "<cmd>lua require'lspsaga.diagnostic'.show_line_diagnostics()<cr>",
                    'line-diagnostics'
                }
            }
        }
    })
    wk.register({
        ['<leader>'] = {
            f = {
                name = 'fix',
                j = {
                    "<cmd>lua require'lspsaga.codeaction'.range_code_action()<cr>",
                    'lsp-action'
                }
            },
            j = {
                name = 'lsp',
                a = {
                    "<cmd>lua require'lspsaga.codeaction'.range_code_action()<cr>",
                    'action'
                }
            }
        }
    }, {mode = 'v'})
end
-- }}}
-- liuchengxu/vista.vim {{{
function vista_vim()
    local wk = require('which-key')
    vim.g.vista_default_executive = 'nvim_lsp'
    wk.register({name = 'lsp', t = {[[:Vista!!<cr>]], 'tags'}},
                {prefix = '<leader>j'})
end
-- }}}
-- onsails/lspkind-nvim {{{
function lspkind_nvim() require('lspkind').init() end
-- }}}
-- hrsh7th/nvim-compe {{{
local __check_back_space = function()
    local col = vim.fn.col('.') - 1
    return col == 0 or vim.fn.getline('.'):sub(col, col):match('%s') ~= nil
end

function _G.__nvim_compe_tab_complete()
    if vim.fn.pumvisible() == 1 then
        return vim.api.nvim_replace_termcodes("<C-n>", true, true, true)
    elseif __check_back_space() then
        return vim.api.nvim_replace_termcodes("<Tab>", true, true, true)
    else
        return vim.fn['compe#complete']()
    end
end
function _G.__nvim_compe_shift_tab_complete()
    if vim.fn.pumvisible() == 1 then
        return vim.api.nvim_replace_termcodes("<C-p>", true, true, true)
    else
        return vim.api.nvim_replace_termcodes("<S-Tab>", true, true, true)
    end
end
function nvim_compe()
    require('compe').setup({
        enabled = true,
        autocomplete = true,
        source = {
            path = true,
            buffer = true,
            calc = true,
            nvim_lsp = true,
            nvim_lua = true,
            spell = true,
            tags = true,
            treesitter = true
        }
    })

    imap('<c-space>', [[compe#complete()]], {expr = true})
    imap('<cr>',
         [[compe#confirm(luaeval("require 'nvim-autopairs'.autopairs_cr()"))]],
         {expr = true})
    imap('<C-e>', [[compe#close('<C-e>')]], {expr = true})
    imap('<C-f>', [[compe#scroll({'delta': +4})]], {expr = true})
    imap('<C-d>', [[compe#scroll({'delta': -4})]], {expr = true})
    imap('<tab>', [[v:lua.__nvim_compe_tab_complete()]], {expr = true})
    imap('<S-tab>', [[v:lua.__nvim_compe_shift_tab_complete()]], {expr = true})
    smap('<tab>', [[v:lua.__nvim_compe_tab_complete()]], {expr = true})
    smap('<S-tab>', [[v:lua.__nvim_compe_shift_tab_complete()]], {expr = true})
end
-- }}}
-- ms-jpq/coq_nvim {{{
function _G.__coq_nvim_cr()
    local npairs = require('nvim-autopairs')
    if vim.fn.pumvisible() ~= 0 then
        if vim.fn.complete_info({'selected'}).selected ~= -1 then
            return npairs.esc('<c-y>')
        else
            return npairs.esc('<c-g><c-g>') .. npairs.autopairs_cr()
        end
    else
        return npairs.autopairs_cr()
    end
end
function _G.__coq_nvim_bs()
    local npairs = require('nvim-autopairs')
    if vim.fn.pumvisible() ~= 0 and vim.fn.complete_info({'mode'}).mode ==
        'eval' then
        return npairs.esc('<c-e>') .. npairs.autopairs_bs()
    else
        return npairs.autopairs_bs()
    end
end
function coq_nvim()
    vim.g.coq_settings = {
        keymap = {
          recommended = false,
          jump_to_mark = '<c-n>'
        },
        auto_start = false,
        display = {
            icons = {
                mode = 'short',
                mappings = {
                    Text = "",
                    Method = "",
                    Function = "",
                    Constructor = "",
                    Field = "ﰠ",
                    Class = "",
                    Interface = "",
                    Variable = "",
                    Module = "",
                    Property = "ﰠ",
                    Unit = "塞",
                    Value = "",
                    Enum = "",
                    Keyword = "",
                    Snippet = "",
                    Color = "",
                    File = "",
                    Reference = "",
                    Folder = "",
                    EnumMember = "",
                    Constant = "",
                    Struct = "ﯟ",
                    Operator = "",
                    Event = "",
                    TypeParameter = ""
                }
            }
        }
    }
    imap('<esc>', [[pumvisible() ? "<c-e><esc>" : "<esc>"]], {expr = true})
    imap('<c-c>', [[pumvisible() ? "<c-e><c-c>" : "<c-c>"]], {expr = true})
    imap('<tab>', [[pumvisible() ? "<c-n>" : "<tab>"]], {expr = true})
    imap('<s-tab>', [[pumvisible() ? "<c-p>" : "<bs>"]], {expr = true})
    imap('<cr>', [[v:lua.__coq_nvim_cr()]], {expr = true})
    imap('<bs>', [[v:lua.__coq_nvim_bs()]], {expr = true})
    vim.cmd([[COQnow --shut-up]])
end
-- }}}
-- kkoomen/vim-doge {{{
function vim_doge_config() vim.g.doge_enable_mappings = 0 end
function vim_doge_setup()
    local wk = require('which-key')

    wk.register({name = 'fix', d = {':DogeGenerate<cr>', 'generate-docs'}},
                {prefix = '<leader>f'});
end
-- }}}
-- windwp/nvim-autopairs {{{
function nvim_autopairs()
    require('nvim-autopairs').setup({map_bs = false, check_ts = true})
end
-- }}}
-- nvim-treesitter/nvim-treesitter {{{
function nvim_treesitter()
    require('nvim-treesitter.configs').setup({
        ensure_installed = "maintained",
        highlight = {enabled = true, use_languagetree = true},
        incremental_selection = {enabled = true},
        indent = {enabled = true},
        autopairs = {enabled = true}
    })
end
-- }}}
-- akinsho/nvim-toggleterm.lua {{{
function _G.__nvim_toggleterm_lua_mappings(bufnr)
    tmap('<esc>', [[<C-\><C-n>]], {buffer = bufnr})
    tmap('jk', [[<C-\><C-n>]], {buffer = bufnr})
    tmap('kj', [[<C-\><C-n>]], {buffer = bufnr})
    tmap('jj', [[<C-\><C-n>]], {buffer = bufnr})
    tmap('<C-h>', [[<C-\><C-n><C-W>h]], {buffer = bufnr})
    tmap('<C-j>', [[<C-\><C-n><C-W>j]], {buffer = bufnr})
    tmap('<C-k>', [[<C-\><C-n><C-W>k]], {buffer = bufnr})
    tmap('<C-l>', [[<C-\><C-n><C-W>l]], {buffer = bufnr})
end
function nvim_toggleterm_lua_config()
    local tt = require('toggleterm')

    tt.setup({
        size = function(term)
            if term.direction == "horizontal" then
                return 15
            elseif term.direction == "vertical" then
                return vim.opt.columns:get() * 0.4
            end
        end
    })

    augroup('toggletermMappings', {
        {
            'TermOpen', 'term://*',
            "call v:lua.__nvim_toggleterm_lua_mappings(bufnr('%'))"
        }
    })
end
function nvim_toggleterm_lua_setup()
    local wk = require('which-key')

    wk.register({
        name = 'terminal',
        w = {[[:ToggleTerm direction=window<cr>]], 'window'},
        v = {[[:ToggleTerm direction=vertical<cr>]], 'vertical'},
        h = {[[:ToggleTerm direction=horizontal<cr>]], 'horizontal'},
        f = {[[:ToggleTerm direction=float<cr>]], 'float'}
    }, {prefix = '<leader>c'})
end
-- }}}
-- nvim-telescope/telescope.nvim {{{
function _G.__telescope_nvim_project_files()
    if vim.fn.executable('git') then
        vim.fn.system('git rev-parse')
        if vim.api.nvim_get_vvar('shell_error') == 0 then
            require'telescope.builtin'.git_files {}
        else
            require'telescope.builtin'.find_files {}
        end
    else
        require'telescope.builtin'.find_files {}
    end
end
function telescope_nvim_config()
    local telescope = require('telescope')
    telescope.setup({
        defaults = {
            layout_strategy = 'flex',
            mappings = {i = {['<esc>'] = require('telescope.actions').close}}
        },
        extensions = {
            fzf = {
                fuzzy = true,
                override_generic_sorter = false,
                override_file_sorter = true,
                case_mode = 'smart_case'
            }
        }
    })
    -- telescope.load_extension('fzf')
end
function telescope_nvim_setup()
    local wk = require('which-key')

    nmap('<C-p>', [[:lua require('telescope.builtin').find_files()<cr>]])
    wk.register({
        name = "list",
        f = {[[:call v:lua.__telescope_nvim_project_files()<cr>]], 'find-files'},
        F = {[[:lua require('telescope.builtin').find_files()<cr>]], 'find-all-files'},
        G = {[[:lua require('telescope.builtin').git_files()<cr>]], 'git-files'},
        a = {[[:lua require('telescope.builtin').live_grep()<cr>]], 'live-grep'},
        A = {
            [[:lua require('telescope.builtin').current_buffer_fuzzy_find()<cr>]],
            'current-buffer-live-grep'
        },
        b = {[[:lua require('telescope.builtin').buffers()<cr>]], 'buffers'},
        c = {[[:lua require('telescope.builtin').commands()<cr>]], 'command'},
        h = {[[:lua require('telescope.builtin').help_tags()<cr>]], 'help-tags'},
        m = {[[:lua require('telescope.builtin').man_pages()<cr>]], 'man-pages'},
        C = {[[:lua require('telescope.builtin').colorscheme()<cr>]], 'colorscheme'},
        S = {[[:lua require('telescope.builtin').spell_suggest()<cr>]], 'spell-suggest'},
        t = {[[:lua require('telescope.builtin').treesitter()<cr>]], 'treesitter'},
        r = {[[:lua require('telescope.builtin').registers()<cr>]], 'registers'},
        l = {
            name = "lsp",
            r = {[[:lua require('telescope.builtin').lsp_references()<cr>]], 'references'},
            a = {[[:lua require('telescope.builtin').lsp_code_actions()<cr>]], 'code-actions'},
            D = {
                [[:lua require('telescope.builtin').lsp_document_diagnostics()<cr>]],
                'document-diagnostics'
            },
            W = {
                [[:lua require('telescope.builtin').lsp_workspace_diagnostics()<cr>]],
                'workspace-diagnostics'
            },
            i = {[[:lua require('telescope.builtin').lsp_implementations()<cr>]], 'implementation'},
            d = {[[:lua require('telescope.builtin').lsp_definitions()<cr>]], 'definitions'}
        },
        g = {
            name = 'git',
            c = {[[:lua require('telescope.builtin').git_commits()<cr>]], 'commits'},
            C = {[[:lua require('telescope.builtin').git_bcommits()<cr>]], 'buffer-commits'},
            b = {[[:lua require('telescope.builtin').git_branches()<cr>]], 'branches'},
            s = {[[:lua require('telescope.builtin').git_status()<cr>]], 'status'},
            S = {[[:lua require('telescope.builtin').git_stash()<cr>]], 'stash'}
        }
    }, {prefix = '<leader>l'})
end
-- }}}
-- norcalli/nvim-colorizer.lua {{{
function nvim_colorizer_lua_config() require('colorizer').setup() end
function nvim_colorizer_lua_setup()
    local wk = require('which-key')
    wk.register({
        name = "mode",
        c = {[[:ColorizerToggle<cr>]], 'colorizer-toggle'}
    }, {prefix = '<leader>m'})
end
-- }}}
-- folke/twilight.nvim {{{
function twilight_nvim_config() require('twilight').setup() end
function twilight_nvim_setup()
    local wk = require('which-key')
    wk.register({name = "mode", t = {[[:Twilight<cr>]], 'twilight'}},
                {prefix = '<leader>m'})
end
-- }}}
-- rafamadriz/neon {{{
function neon()
    vim.g.neon_style = CONFIG.ui.style or "default"
    vim.g.neon_italic_comment = true
    vim.g.neon_bold = true
    if CONFIG.ui.theme == "neon" then
        if vim.g.neon_style == "light" then
            vim.opt.background = "light"
        else
            vim.opt.background = 'dark'
        end
        vim.cmd([[colorscheme neon]])
    end
end
-- }}}
-- marko-cerovac/material.nvim {{{
function material_nvim()
    vim.g.material_style = CONFIG.ui.style or "oceanic"
    -- vim.g.material_italic_comments = true
    if CONFIG.ui.theme == "material" then
        require('material').setup({italics = {comments = true}})
        if vim.g.material_style == "lighter" then
            vim.opt.background = "light"
        else
            vim.opt.background = 'dark'
        end
        vim.cmd([[colorscheme material]])
    end
end
-- }}}
-- bluz71/vim-nightfly-guicolors {{{
function vim_nightfly_guicolors()
    vim.g.nightflyItalics = 1
    if CONFIG.ui.theme == "nightfly" then
        vim.opt.background = "dark"
        vim.cmd([[colorscheme nightfly]])
    end
end
-- }}}
-- bluz71/vim-moonfly-colors {{{
function vim_moonfly_colors()
    vim.g.moonflyItalics = 1
    if CONFIG.ui.theme == "moonfly" then
        vim.opt.background = "dark"
        vim.cmd([[colorscheme moonfly]])
    end
end
-- }}}
-- folke/tokyonight.nvim {{{
function tokyonight_nvim()
    vim.g.tokyonight_style = CONFIG.ui.style or "storm"
    if CONFIG.ui.theme == "tokyonight" then
        if vim.g.tokyonight_style == "day" then
            vim.opt.background = "light"
        else
            vim.opt.background = 'dark'
        end
        vim.cmd([[colorscheme tokyonight]])
    end
end
-- }}}
-- sainnhe/sonokai {{{
function sonokai()
    vim.g.sonokai_style = 'default'
    vim.g.sonokai_enable_italic = 1
    if CONFIG.ui.theme == "sonokai" then
        vim.opt.background = "dark"
        vim.cmd([[colorscheme sonokai]])
    end
end
-- }}}
-- mhartington/oceanic-next {{{
function oceanic_next()
    vim.g.oceanic_next_terminal_bold = 1
    vim.g.oceanic_next_terminal_italic = 1
    if CONFIG.ui.theme == "oceanic-next" then
        if CONFIG.ui.style == "light" then
            vim.opt.background = "light"
            vim.cmd([[colorscheme OceanicNextLight]])
        else
            vim.opt.background = "dark"
            vim.cmd([[colorscheme OceanicNext]])
        end
    end
end
-- }}}
-- glepnir/zephyr-nvim {{{
function zephyr_nvim()
    if CONFIG.ui.theme == "zephyr" then
        vim.opt.background = "dark"
        require('zephyr')
    end
end
-- }}}
-- sainnhe/edge {{{
function edge()
    vim.g.edge_style = CONFIG.ui.style or 'default'
    vim.g.enable_italic = 1
    if CONFIG.ui.theme == "edge" then
        if vim.g.edge_style == "light" then
            vim.opt.background = "light"
        else
            vim.opt.background = 'dark'
        end
        vim.cmd([[colorscheme edge]])
    end
end
-- }}}
-- savq/melange {{{
function melange()
    if CONFIG.ui.theme == 'melange' then
        if CONFIG.ui.style == 'light' then
            vim.opt.background = 'light'
        else
            vim.opt.background = 'dark'
        end
        vim.cmd([[colorscheme melange]])
    end
end
-- }}}
-- fenetikm/falcon {{{
function falcon()
    if CONFIG.ui.theme == 'falcon' then
        vim.opt.background = 'dark'
        vim.cmd([[colorscheme falcon]])
    end
end
-- }}}
-- shaunsingh/nord.nvim {{{
function nord_nvim()
    vim.g.nord_italic = true
    if CONFIG.ui.theme == 'nord' then
        vim.opt.background = 'dark'
        vim.cmd([[colorscheme nord]])
    end
end
-- }}}
-- navarasu/onedark.nvim {{{
function onedark_nvim()
    vim.g.onedark_style = CONFIG.ui.style or "dark"
    vim.g.disable_toggle_style = true
    if CONFIG.ui.theme == 'onedark' then
        vim.opt.background = 'dark'
        vim.cmd([[colorscheme onedark]])
    end
end
-- }}}
-- sainnhe/gruvbox-material {{{
function gruvbox_material()
    local bg = 'dark'
    if CONFIG.ui.style ~= nil then
        local delim = CONFIG.ui.style:find('-')
        if delim ~= nil then
            bg = CONFIG.ui.style:sub(1, delim)
            vim.g.gruvbox_material_background = CONFIG.ui.style:sub(delim + 1)
        else
            vim.g.gruvbox_material_background = CONFIG.ui.style
        end
    else
        vim.g.gruvbox_material_background = 'medium'
    end
    vim.g.gruvbox_material_italic_comment = 1
    vim.g.gruvbox_material_enable_bold = 1
    vim.g.gruvbox_material_enable_italic = 1
    if CONFIG.ui.theme == 'gruvbox-material' then
        vim.opt.background = bg
        vim.cmd([[colorscheme gruvbox-material]])
    end
end
-- }}}
-- sainnhe/everforest {{{
function everforest()
    local bg = 'dark'
    if CONFIG.ui.style ~= nil then
        local delim = CONFIG.ui.style:find('-')
        if delim ~= nil then
            bg = CONFIG.ui.style:sub(1, delim)
            vim.g.everforest_background = CONFIG.ui.style:sub(delim + 1)
        else
            vim.g.everforest_background = CONFIG.ui.style
        end
    else
        vim.g.everforest_background = 'medium'
    end
    vim.g.everforest_italic_comment = 1
    vim.g.everforest_enable_bold = 1
    vim.g.everforest_enable_italic = 1
    if CONFIG.ui.theme == 'everforest' then
        vim.opt.background = bg
        vim.cmd([[colorscheme everforest]])
    end
end
-- }}}
-- dracula/vim {{{
function dracula()
    if CONFIG.ui.theme == 'dracula' then
        vim.opt.background = 'dark'
        vim.cmd([[colorscheme dracula]])
    end
end
-- }}}
-- projekt0n/github-nvim-theme {{{
function github_nvim_theme()
    if CONFIG.ui.theme == 'github-theme' then
        if CONFIG.ui.style == "light" then
            vim.opt.background = 'light'
        else
            vim.opt.background = 'dark'
        end
        require('github-theme').setup({themeStyle = CONFIG.ui.style or "dark"})
    end
end
-- }}}
-- Pocco81/AbbrevMan.nvim {{{
function abbrevman_nvim()
    require('abbrev-man').setup({
        load_natural_dictionaries_at_startup = true,
        load_programming_dictionaries_at_startup = true,
        natural_dictionaries = {["nt_en"] = {}},
        programming_dictionaries = {
            ["pr_py"] = {},
            ["pr_java"] = {},
            ["pr_lua"] = {}
        }
    })
end
-- }}}
-- farmergreg/vim-lastplace {{{
function vim_lastplace()
    vim.g.lastplace_ignore = "gitcommit,gitrebase,svn,hgcommit"
    vim.g.lastplace_ignore_buftype = "quickfix,nofile,help"
end
-- }}}
-- kyazdani42/nvim-web-devicons {{{
function nvim_web_devicons() require('nvim-web-devicons').setup({default = true}) end
-- }}}
-- akinsho/nvim-bufferline.lua {{{
function nvim_bufferline_lua()
    require('bufferline').setup({
        options = {
            view = "default",
            numbers = "none",
            diagnostics = 'nvim_lsp',
            always_show_bufferline = true,
            sort_by = 'directory',
            show_close_icon = true,
            custom_filter = function(buf_number)
                if vim.fn.bufname(buf_number) == '' then
                    return false
                else
                    return true
                end
            end,
            offsets = {
                {
                    filetype = "NvimTree",
                    text = "File Explorer",
                    text_align = "left"
                },
                {
                    filetype = "vista_kind",
                    text = "LSP Tags",
                    text_align = "right"
                }
            }
        }
    })
end
-- }}}
-- hoob3rt/lualine.nvim {{{
function lualine_nvim()
    require('lualine').setup({
        options = {
            icons_enabled = true,
            theme = CONFIG.ui.theme or 'auto',
            component_separators = {'', ''},
            section_separators = {'', ''}
        },
        sections = {
            lualine_a = {{'mode', upper = true}},
            lualine_b = {'filename'},
            lualine_c = {
                {
                    'diagnostics',
                    sources = {'nvim_lsp'},
                    sections = {'error', 'warn', 'info', 'hint'}
                }
            },
            lualine_x = {'filetype'},
            lualine_y = {'branch', 'diff'},
            lualine_z = {'progress'}
        },
        extensions = {'nvim-tree'}
    })
end
-- }}}
-- glepnir/dashboard-nvim {{{
function _G.__dashboard_nvim_mappings(bufnr)
    nmap('n', [[:DashboardNewFile<cr>]], {buffer = bufnr})
    nmap('f', [[:lua require('telescope.builtin').find_files()<cr>]], {buffer = bufnr})
    nmap('h', [[:lua require('telescope.builtin').oldfiles()<cr>]], {buffer = bufnr})
    nmap('g', [[:lua require('telescope.builtin').live_grep()<cr>]], {buffer = bufnr})
    nmap('q', [[:qa!<cr>]], {buffer = bufnr})
end

function dashboard_nvim()
    local version = vim.version()
    local version_msg = '[Neovim version : v' .. version['major'] .. '.' ..
                            version['minor'] .. '.' .. version['patch'] .. ']'
    version_msg =
        string.rep(' ', (55 - version_msg:len()) / 2) .. version_msg ..
            string.rep(' ', (55 - version_msg:len()) / 2)
    vim.g.dashboard_custom_header = {
        ' ███╗   ██╗ ███████╗ ██████╗  ██╗   ██╗ ██╗ ███╗   ███╗',
        ' ████╗  ██║ ██╔════╝██╔═══██╗ ██║   ██║ ██║ ████╗ ████║',
        ' ██╔██╗ ██║ █████╗  ██║   ██║ ██║   ██║ ██║ ██╔████╔██║',
        ' ██║╚██╗██║ ██╔══╝  ██║   ██║ ╚██╗ ██╔╝ ██║ ██║╚██╔╝██║',
        ' ██║ ╚████║ ███████╗╚██████╔╝  ╚████╔╝  ██║ ██║ ╚═╝ ██║',
        ' ╚═╝  ╚═══╝ ╚══════╝ ╚═════╝    ╚═══╝   ╚═╝ ╚═╝     ╚═╝',
        '                                                       ', version_msg
    }
    vim.g.dashboard_default_executive = 'telescope'
    vim.g.dashboard_custom_section = {
        ['1_new'] = {
            ['description'] = {'洛 New File                        [n]'},
            ['command'] = ':DashboardNewFile'
        },
        ['2_file'] = {
            ['description'] = {'  Find File                       [f]'},
            ['command'] = ':lua require(\'telescope.builtin\').find_files()'
        },
        ['2_history'] = {
            ['description'] = {'  Recently opened files           [h]'},
            ['command'] = ':lua require(\'telescope.builtin\').oldfiles()'
        },
        ['3_word'] = {
            ['description'] = {'  Find Word                       [g]'},
            ['command'] = ':lua require(\'telescope.builtin\').live_grep()'
        },
        ['9_quit'] = {
            ['description'] = {'  Quit                            [q]'},
            ['command'] = ':qa!'
        }
    }
    augroup('dashboardMappings', {
        {
            "FileType", "dashboard",
            "call v:lua.__dashboard_nvim_mappings(bufnr('%'))"
        }
    })
end
-- }}}
-- lukas-reineke/indent-blankline.nvim {{{
function indent_blankline_nvim()
    vim.g.indent_blankline_use_treesitter = true
    vim.g.indent_blankline_show_current_context = true
    vim.g.indent_blankline_filetype_exclude = {
        'help', 'fzf', 'openterm', 'neoterm', 'calendar', 'startify', 'packer',
        'vista', 'help', 'dashboard', 'lsp-installer'
    }
    vim.g.indent_blankline_buftype_exclude = {'terminal'}
end
-- }}}
-- kyazdani42/nvim-tree.lua {{{
function nvim_tree_lua_config()
    vim.g.nvim_tree_ignore = {'.git', 'node_modues', '.cache'}
    vim.g.nvim_tree_gitignore = 1
    vim.g.nvim_tree_auto_open = 1
    vim.g.nvim_tree_auto_close = 1
    vim.g.nvim_tree_auto_ignore_ft = {'startify', 'dashboard'}
    vim.g.nvim_tree_hide_dotfiles = 1
    vim.g.nvim_tree_git_hl = 1
    vim.g.nvim_tree_highlight_opened_files = 1
    vim.g.nvim_tree_group_empty = 1
    vim.g.nvim_tree_lsp_diagnostics = 1
    vim.g.nvim_tree_window_picker_exclude = {
        filetype = {'packer', 'qf'},
        buftype = {'terminal'}
    }
    vim.g.nvim_tree_show_icons = {
        git = 1,
        folders = 1,
        files = 1,
        folder_arrows = 0
    }
    local present, _ = pcall(require, 'nvim-lsp-installer')
    if present then
        require('nvim-lsp-installer.adapters.nvim-tree').connect()
    end
end
function nvim_tree_lua_setup()
    local wk = require('which-key')
    wk.register({["<leader>e"] = {':NvimTreeToggle<cr>', 'explorer'}})
end
-- }}}
-- sindrets/diffview.nvim {{{
function diffview_nvim_config() require('diffview').setup({}) end
function diffview_nvim_setup()
    local wk = require('which-key')
    wk.register({name = 'git', d = {[[:DiffviewOpen<cr>]], 'diff'}},
                {prefix = '<leader>g'})
end
-- }}}
-- lewis6991/gitsigns.nvim {{{
function gitsigns_nvim()
    require('gitsigns').setup({keymaps = {}})
    local wk = require('which-key')
    wk.register({
        [']c'] = {
            [[&diff ? ']c' : '<cmd>lua require\"gitsigns.actions\".next_hunk()<cr>']],
            'Next hunk'
        },
        ['[c'] = {
            [[&diff ? '[c' : '<cmd>lua require\"gitsigns.actions\".next_hunk()<cr>']],
            'Previous hunk'
        }
    })
    wk.register({
        ['ih'] = {
            [[:<C-U>lua require"gitsigns.actions".select_hunk()<cr>]],
            'inner hunk'
        }
    }, {mode = 'x'})
end
-- }}}
-- f-person/git-blame.nvim {{{
function git_blame_nvim()
    vim.g.gitblame_enabled = 0
    vim.g.gitblame_date_format = '%r'
    local wk = require('which-key')
    wk.register({name = 'git', b = {[[:GitBlameToggle<cr>]], 'blame'}},
                {prefix = '<leader>g'})
end
-- }}}
-- TimUntersberger/neogit {{{
function neogit_config()
    require('neogit').setup({integrations = {diffview = true}})
end
function neogit_setup()
    local wk = require('which-key')
    wk.register({g = {[[:Neogit kind=split<cr>]], 'neogit'}},
                {prefix = '<leader>g'})
end
-- }}}
-- folke/todo-comments.nvim {{{
function todo_comments_nvim()
    require('todo-comments').setup({})

    local wk = require('which-key')
    wk.register({name = 'trouble', t = {[[:TodoTrouble<cr>]], 'todo'}},
                {prefix = '<leader>x'})
    wk.register({name = 'list', T = {[[:TodoTelescope<cr>]], 'todo'}},
                {prefix = '<leader>l'})
end
-- }}}
-- b3nj5m1n/kommentary {{{
function kommentary()
    vim.g.kommentary_create_default_mappings = false
    require('kommentary.config').setup({})

    nmap('<C-_>', [[<Plug>kommentary_line_default]], {noremap = false})
    xmap('<C-_>', [[<Plug>kommentary_visual_default]], {noremap = false})
    nmap('gcc', [[<Plug>kommentary_line_default]], {noremap = false})
    nmap('gc', [[<Plug>kommentary_motion_default]], {noremap = false})
    xmap('gc', [[<Plug>kommentary_visual_default]], {noremap = false})

    local wk = require('which-key')
    wk.register({name = 'Comment'}, {prefix = 'g'})
    wk.register({name = 'Comment'}, {mode = 'v', prefix = 'g'})
end
-- }}}
-- phaazon/hop.nvim {{{
function hop_nvim()
    require('hop').setup()

    local wk = require('which-key')
    wk.register({
        ['<leader><space>'] = {
            name = 'Hop',
            w = {[[:HopWord<cr>]], 'Word'},
            l = {[[:HopLine<cr>]], 'Line'},
            c = {[[:HopChar1<cr>]], 'Character'}
        },
        ['dh'] = {
            name = 'hop',
            w = {[[:HopWord<cr>]], 'Word'},
            l = {[[:HopLine<cr>]], 'Line'},
            c = {[[:HopChar1<cr>]], 'Character'}
        },
        ['yh'] = {
            name = 'hop',
            w = {[[:HopWord<cr>]], 'Word'},
            l = {[[:HopLine<cr>]], 'Line'},
            c = {[[:HopChar1<cr>]], 'Character'}
        },
        ['ch'] = {
            name = 'hop',
            w = {[[:HopWord<cr>]], 'Word'},
            l = {[[:HopLine<cr>]], 'Line'},
            c = {[[:HopChar1<cr>]], 'Character'}
        },
        ['gh'] = {
            name = 'hop',
            w = {[[:HopWord<cr>]], 'Word'},
            l = {[[:HopLine<cr>]], 'Line'},
            c = {[[:HopChar1<cr>]], 'Character'}
        }
    })
end
-- }}}
-- haya14busa/incsearch.vim {{{
function incsearch_vim()
    vim.g['incsearch#auto_nohlsearch'] = 1
    nmap('/', [[<Plug>(incsearch-forward)]], {noremap = false, silent = false})
    nmap('?', [[<Plug>(incsearch-backward)]], {noremap = false, silent = false})
    nmap('n', [[<Plug>(incsearch-nohl-n)]], {noremap = false, silent = false})
    nmap('N', [[<Plug>(incsearch-nohl-N)]], {noremap = false, silent = false})
    nmap('*', [[<Plug>(incsearch-nohl-*)]], {noremap = false, silent = false})
    nmap('#', [[<Plug>(incsearch-nohl-#)]], {noremap = false, silent = false})
    nmap('g*', [[<Plug>(incsearch-nohl-g*)]], {noremap = false, silent = false})
    nmap('g#', [[<Plug>(incsearch-nohl-g#)]], {noremap = false, silent = false})
end
-- }}}
-- monaqa/dial.nvim {{{
function dial_nvim()
    nmap('<C-a>', [[<Plug>(dial-increment)]], {noremap = false})
    nmap('<C-x>', [[<Plug>(dial-decrement)]], {noremap = false})
    xmap('<C-a>', [[<Plug>(dial-increment)]], {noremap = false})
    xmap('<C-x>', [[<Plug>(dial-decrement)]], {noremap = false})
end
-- }}}
-- Pocco81/TrueZen.nvim {{{
function truezen_nvim_config()
    require('true-zen').setup({
        modes = {
            ataraxis = {ideal_writing_area_width = {81}, auto_padding = true}
        },
        integrations = {nvim_bufferline = true, lualine = true, twilight = true}
    })
end
function truezen_nvim_setup()
    local wk = require('which-key')
    wk.register({
        name = 'mode',
        f = {[[:TZFocus<cr>]], 'focus'},
        m = {[[:TZMinimalist<cr>]], 'minimalist'},
        a = {[[:TZAtaraxis<cr>]], 'ataraxis'}
    }, {prefix = '<leader>m'})
end
-- }}}
-- fidian/hexmode {{{
function hexmode()
    vim.g.hexmode_autodetect = 1
    vim.g.hexmode_patterns =
        '*.bin,*.exe,*.dat,*.o,*.a,*.mp4,*.png,*.jpg,*.jpeg,*.heic,*.spirv'
    local wk = require('which-key')
    wk.register({name = 'mode', h = {[[:Hexmode<cr>]], 'Hex'}},
                {prefix = '<leader>m'})
end
-- }}}
-- junegunn/vim-easy-align {{{
function vim_easy_align()
    local wk = require('which-key')
    wk.register({
        name = 'fix',
        a = {
            [[<Plug>(LiveEasyAlign)]],
            'align',
            noremap = false,
            silent = false
        }
    }, {prefix = '<leader>f'})
    wk.register({
        name = 'fix',
        a = {
            [[<Plug>(LiveEasyAlign)]],
            'align',
            noremap = false,
            silent = false
        }
    }, {mode = 'x', prefix = '<leader>f'})
end
-- }}}
-- sbdchd/neoformat {{{
function neoformat()
    local wk = require('which-key')
    wk.register({
        name = 'fix',
        f = {[[:Neoformat<cr>]], 'formatting'},
        s = {[[:Neoformat<cr>]], 'styling'}
    }, {prefix = '<leader>f'})
end
-- }}}
-- jdhao/better-escape.vim {{{
function better_escape_nvim()
    vim.g.better_escape_nvim = 150
    vim.g.better_escape_shortcut = {'jk', 'kj', 'jj'}
end
-- }}}
-- folke/which-key.nvim {{{
function which_key_nvim()
    local wk = require('which-key')
    wk.setup({
        plugins = {marks = true, registers = true, spelling = {enabled = true}},
        layout = {align = 'center', height = {min = 1, max = 10}},
        triggers = 'auto',
        key_labels = {["<space>"] = "SPC", ["<cr>"] = "RET", ["<tab>"] = "TAB"}
    })

    wk.register({
        name = "plugin",
        c = {[[:PackerCompile<cr>]], 'compile'},
        C = {[[:PackerClean<cr>]], 'clean'},
        i = {[[:PackerInstall<cr>]], 'install'},
        s = {[[:PackerSync<cr>]], 'sync'},
        S = {[[:PackerStatus<cr>]], 'status'},
        P = {[[:PackerProfile<cr>]], 'profile'},
        u = {[[:PackerUpdate<cr>]], 'update'}
    }, {prefix = '<leader>p'})

    for _, args in ipairs(__wk_mappings) do wk.register(unpack(args)) end
end
-- }}}
-- Nedra1998/loci.nvim {{{
function loci_nvim_config()
    require('loci').setup({auto_link = false, auto_index = true})
end
function loci_nvim_setup()
    local wk = require('which-key')
    wk.register({
        name = 'wiki',
        w = {[[:lua require'loci.workspace'.open_index()<cr>]], 'index'},
        i = {[[:lua require'loci.diary'.open_diary_index()<cr>]], 'diary-index'},
        d = {[[:lua require'loci.diary'.open_diary()<cr>]], 'diary-today'},
        y = {
            [[:lua require'loci.diary'.open_diary(nil, nil, 'yesterday')<cr>]],
            'diary-yesterday'
        },
        t = {
            [[:lua require'loci.diary'.open_diary(nil, nil, 'tomorrow')<cr>]],
            'diary-tomorrow'
        }
    }, {prefix = '<leader>v'})
end
-- }}}

-- }}}
-- PLUGIN-LIST {{{

packer.startup(function(use)
    -- Plugin Managers
    use {'wbthomason/packer.nvim', opt = true}

    -- LSP
    use {'neovim/nvim-lspconfig', config = nvim_lspconfig}
    --[[ use {
        'kabouzeid/nvim-lspinstall',
        after = {'nvim-lspconfig', 'which-key.nvim'},
        config = nvim_lspinstall
    } ]]
    use {
        'williamboman/nvim-lsp-installer',
        after = {'nvim-lspconfig', 'which-key.nvim'},
        config = nvim_lsp_installer
    }
    use {
        'glepnir/lspsaga.nvim',
        after = {'nvim-lspconfig', 'which-key.nvim'},
        config = lspsaga_nvim
    }
    use {
        'liuchengxu/vista.vim',
        after = {'which-key.nvim'},
        cmd = 'Vista',
        setup = vista_vim
    }
    use {
        'onsails/lspkind-nvim',
        after = {'nvim-lspconfig'},
        config = lspkind_nvim
    }
    use {
        'folke/lsp-colors.nvim',
        after = {
            'neon', 'material.nvim', 'vim-nightfly-guicolors',
            'vim-moonfly-colors', 'tokyonight.nvim', 'sonokai', 'oceanic-next',
            'zephyr-nvim', 'edge', 'melange', 'falcon', 'nord.nvim',
            'onedark.nvim', 'gruvbox-material', 'everforest', 'vim',
            'github-nvim-theme'
        },
        config = lsp_colors_nvim
    }
    use {
        'folke/trouble.nvim',
        after = {'which-key.nvim'},
        requires = {'kyazdani42/nvim-web-devicons'},
        cmd = {'Trouble', 'TroubleToggle'},
        config = trouble_nvim_config,
        setup = trouble_nvim_setup
    }

    -- Completion
    use {
        'ms-jpq/coq_nvim',
        branch = 'coq',
        requires = {{'ms-jpq/coq.artifacts', branch = 'artifacts'}},
        after = {'which-key.nvim'},
        config = coq_nvim,
        disable = CONFIG.completion(PROCESSORS) ~= 'coq_nvim'
    }
    use {'hrsh7th/nvim-compe', event = {'InsertEnter'}, config = nvim_compe,
        disable = CONFIG.completion(PROCESSORS) ~= 'nvim-compe'
  }
    use {
        'kkoomen/vim-doge',
        after = {'which-key.nvim'},
        cmd = {'DogeGenerate'},
        config = vim_doge_config,
        setup = vim_doge_setup
    }
    use {
        'windwp/nvim-autopairs',
        event = {'InsertEnter'},
        after = {CONFIG.completion(PROCESSORS), 'nvim-treesitter'},
        config = nvim_autopairs
    }

    -- Syntax
    use {
        'nvim-treesitter/nvim-treesitter',
        event = {'BufNewFile', 'BufRead'},
        config = nvim_treesitter
    }
    use {'jackguo380/vim-lsp-cxx-highlight'}

    -- Terminal Integration
    use {
        'akinsho/nvim-toggleterm.lua',
        after = {'which-key.nvim'},
        cmd = {'ToggleTerm'},
        config = nvim_toggleterm_lua_config,
        setup = nvim_toggleterm_lua_setup
    }

    -- Fuzzy Finder
    use {
        'nvim-telescope/telescope.nvim',
        requires = {
            {'nvim-lua/plenary.nvim'}, {
                'nvim-telescope/telescope-fzf-native.nvim',
                run = 'make',
                cmd = {"Telescope"},
                module = {'telescope.builtin'}
            }
        },
        after = {"which-key.nvim", 'telescope-fzf-native.nvim'},
        cmd = {"Telescope"},
        module = {'telescope.builtin'},
        setup = telescope_nvim_setup,
        config = telescope_nvim_config
    }

    -- Note Taking
    use {
        'Nedra1998/loci.nvim',
        branch = "treesitter",
        module = {'loci.workspace', 'loci.diary'},
        config = loci_nvim_config,
        setup = loci_nvim_setup
    }

    -- Colors
    use {
        'norcalli/nvim-colorizer.lua',
        after = {'which-key.nvim'},
        cmd = {'ColorizerToggle'},
        config = nvim_colorizer_lua_config,
        setup = nvim_colorizer_lua_setup
    }
    use {
        "folke/twilight.nvim",
        after = {'which-key.nvim'},
        cmd = {'Twilight', 'TwilightEnable'},
        setup = twilight_nvim_setup,
        config = twilight_nvim_config
    }

    -- Colorscheme
    use {'rafamadriz/neon', config = neon}
    use {'marko-cerovac/material.nvim', config = material_nvim}
    use {'bluz71/vim-nightfly-guicolors', config = vim_nightfly_guicolors}
    use {'bluz71/vim-moonfly-colors', config = vim_moonfly_colors}
    use {'folke/tokyonight.nvim', config = tokyonight_nvim}
    use {'sainnhe/sonokai', config = sonokai}
    use {'mhartington/oceanic-next', config = oceanic_next}
    use {'glepnir/zephyr-nvim', config = zephyr_nvim}
    use {'sainnhe/edge', config = edge}
    use {'savq/melange', config = melange}
    use {'fenetikm/falcon', config = falcon}
    use {'shaunsingh/nord.nvim', config = nord_nvim}
    use {'navarasu/onedark.nvim', config = onedark_nvim}
    use {'sainnhe/gruvbox-material', config = gruvbox_material}
    use {'sainnhe/everforest', config = everforest}
    use {'dracula/vim', config = dracula}
    use {'projekt0n/github-nvim-theme', config = github_nvim_theme}

    -- Utility
    use {
        'Pocco81/AbbrevMan.nvim',
        event = {'InsertEnter'},
        config = abbrevman_nvim
    }
    use {'farmergreg/vim-lastplace', setup = vim_lastplace}

    -- Icons
    use {'kyazdani42/nvim-web-devicons', config = nvim_web_devicons}

    -- Tabline
    use {
        'akinsho/nvim-bufferline.lua',
        requires = {'kyazdani42/nvim-web-devicons'},
        config = nvim_bufferline_lua
    }

    use {
        'hoob3rt/lualine.nvim',
        requires = {'kyazdani42/nvim-web-devicons'},
        after = {
            'neon', 'material.nvim', 'vim-nightfly-guicolors',
            'vim-moonfly-colors', 'tokyonight.nvim', 'sonokai', 'oceanic-next',
            'zephyr-nvim', 'edge', 'melange', 'falcon', 'nord.nvim',
            'onedark.nvim', 'gruvbox-material', 'everforest', 'vim',
            'github-nvim-theme'
        },
        config = lualine_nvim
    }

    -- Startup
    use {'glepnir/dashboard-nvim', setup = dashboard_nvim}

    -- Indent
    use {
        'lukas-reineke/indent-blankline.nvim',
        event = {'BufRead', 'BufNewFile'},
        config = indent_blankline_nvim
    }

    -- File Explorer
    use {
        'kyazdani42/nvim-tree.lua',
        after = {'nvim-web-devicons', 'which-key.nvim'},
        requires = {'kyazdani42/nvim-web-devicons'},
        cmd = 'NvimTreeToggle',
        config = nvim_tree_lua_config,
        setup = nvim_tree_lua_setup
    }

    -- Git
    use {
        'sindrets/diffview.nvim',
        after = {'nvim-web-devicons', 'which-key.nvim'},
        requires = {'kyazdani42/nvim-web-devicons'},
        cmd = {'DiffviewOpen'},
        module = {'diffview'},
        config = diffview_nvim_config,
        setup = diffview_nvim_setup
    }
    use {
        'lewis6991/gitsigns.nvim',
        after = {'which-key.nvim'},
        requires = {'nvim-lua/plenary.nvim'},
        event = {"BufRead", "BufNewFile"},
        config = gitsigns_nvim
    }
    use {
        'f-person/git-blame.nvim',
        after = {'which-key.nvim'},
        cmd = {'GitBlameToggle'},
        setup = git_blame_nvim
    }
    use {
        'TimUntersberger/neogit',
        after = {'which-key.nvim'},
        cmd = {'Neogit'},
        config = neogit_config,
        setup = neogit_setup
    }

    -- Comment
    use {
        'folke/todo-comments.nvim',
        after = {'which-key.nvim'},
        event = {'BufRead', 'BufNewFile'},
        config = todo_comments_nvim
    }
    use {
        'b3nj5m1n/kommentary',
        after = {'which-key.nvim'},
        event = {'BufEnter', 'BufNewFile'},
        config = kommentary
    }

    -- Motions
    use {
        'phaazon/hop.nvim',
        event = {'BufEnter', 'BufNewFile'},
        config = hop_nvim
    }

    -- Search
    use {
        'haya14busa/incsearch.vim',
        event = {'VimEnter'},
        config = incsearch_vim
    }

    -- Editing Supports
    use {
        'monaqa/dial.nvim',
        event = {'BufEnter', 'BufNewFile'},
        config = dial_nvim
    }
    use {
        'Pocco81/TrueZen.nvim',
        after = {'which-key.nvim'},
        cmd = {'TZMinimalist', 'TZFocus', 'TZAtaraxis'},
        config = truezen_nvim_config,
        setup = truezen_nvim_setup
    }
    use {'fidian/hexmode', config = hexmode}
    use {'tpope/vim-abolish', event = {'BufEnter', 'BufNewFile'}}

    -- Formatting
    use {
        'junegunn/vim-easy-align',
        after = {'which-key.nvim'},
        event = {'BufEnter', 'BufNewFile'},
        config = vim_easy_align
    }
    use {
        'sbdchd/neoformat',
        after = {'which-key.nvim'},
        cmd = {'Neoformat'},
        setup = neoformat
    }

    -- Keybindings
    use {
        'jdhao/better-escape.vim',
        event = {'InsertEnter'},
        setup = better_escape_nvim
    }
    use {"folke/which-key.nvim", config = which_key_nvim}

    -- Tmux
    use {'christoomey/vim-tmux-navigator', after = {'which-key.nvim'}}

end)

-- }}}
-- FUNCTIONS {{{

-- text_mode {{{
function _G.text_mode()
    vim.opt.spell = true
    vim.opt.textwidth = 80
end

wkmap({name = 'mode', t = {[[:call v:lua.text_mode()<cr>]], 'Text'}},
      {prefix = '<leader>m'})

augroup('textMode', {{'FileType', 'markdown,txt,rst', 'call v:lua.text_mode()'}})

-- }}}

wkapply()
-- }}}

-- vim:foldmethod=marker foldlevel=0
