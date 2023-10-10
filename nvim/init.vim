" Abuelwafa's Neovim init.vim config

set nocompatible

" download vim-plug if its not present
let data_dir = has('nvim') ? stdpath('data') . '/site' : '~/.vim'
if empty(glob(data_dir . '/autoload/plug.vim'))
  silent execute '!curl -fLo '.data_dir.'/autoload/plug.vim --create-dirs  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC | q!
endif

" Run PlugInstall if there are missing plugins
autocmd VimEnter * if len(filter(values(g:plugs), '!isdirectory(v:val.dir)'))
  \| PlugInstall --sync | source $MYVIMRC | q | q!
\| endif

" TODO: configure pyright and python linting with coc

" initiate vim-plug
call plug#begin()
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim', { 'tag': '0.1.0' }
Plug 'ANGkeith/telescope-terraform-doc.nvim'
Plug 'lpoto/telescope-docker.nvim'
Plug 'nvim-telescope/telescope-file-browser.nvim'
Plug 'neoclide/coc.nvim', { 'branch': 'release' }
Plug 'lukas-reineke/indent-blankline.nvim'
Plug 'ZhiyuanLck/smart-pairs'
Plug 'phaazon/hop.nvim'
Plug 'mg979/vim-visual-multi', {'branch': 'master'}
Plug 'christoomey/vim-tmux-navigator'
Plug 'rest-nvim/rest.nvim'
Plug 'editorconfig/editorconfig-vim'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-git'
Plug 'moll/vim-bbye'
Plug 'ntpeters/vim-better-whitespace'
Plug 'prisma/vim-prisma'
Plug 'iamcco/markdown-preview.nvim', { 'do': 'cd app && yarn install' }
Plug 'christoomey/vim-system-copy'
Plug 'numToStr/Comment.nvim'
Plug 'airblade/vim-gitgutter'
Plug 'tinted-theming/base16-vim'
Plug 'MarcWeber/vim-addon-mw-utils'
Plug 'mattn/emmet-vim'
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
Plug 'nvim-lualine/lualine.nvim'
Plug 'nacro90/numb.nvim'
Plug 'MunifTanjim/nui.nvim'
Plug 'szw/vim-maximizer'
Plug 'nvim-tree/nvim-tree.lua'
Plug 'akinsho/bufferline.nvim', { 'tag': 'v3.*' }
Plug 'jparise/vim-graphql'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'norcalli/nvim-colorizer.lua'
Plug 'f-person/git-blame.nvim'
Plug 'eandrju/cellular-automaton.nvim'
Plug 'rcarriga/nvim-notify'
Plug 'preservim/tagbar'
Plug 'tpope/vim-dadbod'
Plug 'kristijanhusak/vim-dadbod-ui'
" Plug 'pwntester/octo.nvim'
" Plug 'github/copilot.vim'
" Plug 'haishanh/night-owl.vim'

"-- to be explored
" Plug 'numToStr/FTerm.nvim'
" Plug 'neovim/nvim-lspconfig'

call plug#end()

"===================================================
" basic vim configuration
"===================================================

set t_Co=256
set termguicolors
syntax on
set ruler
set lazyredraw
set nofsync

" Indentation
set autoindent
set smartindent
set cindent

" Search
set hlsearch
set incsearch
set smartcase
set ignorecase
" set gdefault
set showmatch

set colorcolumn=101
" set relativenumber

" disable code folding
set foldenable
set foldmethod=indent
set foldnestmax=10
set foldlevel=20
set foldminlines=2

set lbr
set noshowmode

set tabstop=4
set softtabstop=4
set shiftwidth=4
set expandtab

set nopaste

set number " show line numbers
set cursorline " highlight current line

set completeopt="menuone,noinsert,noselect"

" sets backspace key functions, allows it to backspace over end of line
" characters, start of line, and indentation
set backspace=indent,eol,start

" movement keys will take you to the next or previous line
set whichwrap+=<,>,h,l

" scrolls the buffer before you reach the last line of the window
set scrolloff=4

" remember more commands and search history
set history=1000
" use many much of levels of undo  "
set undolevels=1000
set undofile

" hide buffers instead of closing them, allows for changing files without saving
set hidden

" disable backup and swap files
set backup
set noswapfile
set nowritebackup
set backupdir^=~/.nvim/_backup/
set directory=~/.nvim/_temp/
set undodir=~/.nvim/_undo/

" File name tab completion functions like bash, it gives you a list of
" options instead of automatically filling in the first possible match.
set wildmenu
" It will however, with this option, complete up to the first character of ambiguity.
set wildmode=list:longest

" Disable archive files
set wildignore+=*.zip,*.tar.gz,*.tar.bz2,*.rar,*.tar.xz
" Ignore bundler and sass cache
set wildignore+=*/vendor/gems/*,*/vendor/cache/*,*/.bundle/*,*/.sass-cache/*
" Ignore rails temporary asset caches
set wildignore+=*/tmp/cache/assets/*/sprockets/*,*/tmp/cache/assets/*/sass/*
" Disable temp and backup files
set wildignore+=*.swp,*~,._*

set signcolumn=yes

" Having longer updatetime (default is 4000 ms = 4 s) leads to noticeable delays and poor user experience. try experimenting with decreasing it to 200ms and check the performance
set updatetime=50

" don't give |ins-completion-menu| messages.
set shortmess+=c

" Better display for messages
" set cmdheight=2

" set nolist
set list
" makes cursor on the begining of tab characters. makes it behaves like other editors
" view tabs with pipe character and three spaces to proper view indent guides
set listchars+=extends:>
set listchars+=trail:\ ,tab:\|\ ,nbsp:␣
match errorMsg /\s\+$/

" Open new windows on the bottom and right instead of the top and left.
set splitbelow
set splitright

"====================================================================
" COC configuration
let g:coc_global_extensions = [
    \ 'coc-swagger',
    \ 'coc-html',
    \ 'coc-styled-components',
    \ 'coc-tsserver',
    \ 'coc-json',
    \ 'coc-go',
    \ 'coc-rust-analyzer',
    \ 'coc-prettier',
    \ 'coc-css',
    \ 'coc-docker',
    \ 'coc-pyright',
    \ 'coc-eslint',
    \ 'coc-sql',
    \ 'coc-db',
    \ 'coc-highlight',
    \ 'coc-clangd',
    \ 'coc-sh',
    \ 'coc-svg',
    \ 'coc-yaml',
    \ 'coc-prisma',
    \ 'coc-xml',
    \ 'coc-vimlsp',
    \ 'coc-styled-components',
    \ '@yaegassy/coc-nginx',
    \ 'coc-fzf-preview',
    \ 'coc-sqlfluff',
    \ 'coc-toml',
\ ]

" Use tab for trigger completion with characters ahead and navigate
inoremap <silent><expr> <TAB>
      \ coc#pum#visible() ? coc#pum#next(1) :
      \ CheckBackspace() ? "\<Tab>" :
      \ coc#refresh()
inoremap <expr><S-TAB> coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"

lua vim.keymap.set("i", "<cr>", [[coc#pum#visible() ? coc#pum#confirm() : "<cmd>lua require('pairs.enter').type()<cr>"]], { silent = true, noremap = true, expr = true, replace_keycodes = false })

function! CheckBackspace() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

" Use <c-space> to trigger completion
inoremap <silent><expr> <c-space> coc#refresh()

" Use K to show documentation in preview window
nnoremap <silent> K :call ShowDocumentation()<CR>

function! ShowDocumentation()
  if CocAction('hasProvider', 'hover')
    call CocActionAsync('doHover')
  else
    call feedkeys('K', 'in')
  endif
endfunction

" Highlight the symbol and its references when holding the cursor
autocmd CursorHold * silent call CocActionAsync('highlight')

" Symbol renaming
nmap <leader>rn <Plug>(coc-rename)

" GoTo code navigation
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

" Remap keys for applying code actions at the cursor position
nmap <leader>a  <Plug>(coc-codeaction-cursor)

" Use `[g` and `]g` to navigate diagnostics
" Use `:CocDiagnostics` to get all diagnostics of current buffer in location list
nmap <silent> [g <Plug>(coc-diagnostic-prev)
nmap <silent> ]g <Plug>(coc-diagnostic-next)

" Remap keys for applying refactor code actions
nmap <silent> <leader>re <Plug>(coc-codeaction-refactor)
xmap <silent> <leader>r  <Plug>(coc-codeaction-refactor-selected)
nmap <silent> <leader>r  <Plug>(coc-codeaction-refactor-selected)

" Run the Code Lens action on the current line
nmap <leader>cl  <Plug>(coc-codelens-action)

" Add `:Format` command to format current buffer
command! -nargs=0 Format :call CocActionAsync('format')

" Add `:Fold` command to fold current buffer
command! -nargs=? Fold :call CocAction('fold', <f-args>)

" Add `:OrganizeImports` command for organize imports of the current buffer
command! -nargs=0 OrganizeImports :call CocActionAsync('runCommand', 'editor.action.organizeImport')

autocmd FileType sql autocmd BufWritePost * :CocCommand sqlfluff.fix

augroup mygroup
  autocmd!
  " Setup formatexpr specified filetype(s)
  autocmd FileType typescript,json setl formatexpr=CocAction('formatSelected')
  " Update signature help on jump placeholder
  autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
augroup end

" Remap <C-f> and <C-b> to scroll float windows/popups
if has('nvim-0.4.0') || has('patch-8.2.0750')
  nnoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1) : <Nop>
  nnoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : <Nop>
endif

"====================================================================
"====================================================================

" set mouse shape to block in insert mode
set guicursor=i:block

" editor config configuration
let g:EditorConfig_exclude_patterns = ['fugitive://.*', 'scp://.*']
au FileType gitcommit let b:EditorConfig_disable = 1

" " remove vim background - makes it transparent if the colorscheme has no background
" highlight nonText ctermbg=NONE


" " git blame configuration
" Plug 'f-person/git-blame.nvim'
" let g:gitblame_date_format = '%d %b %y'
" let g:gitblame_message_when_not_committed = ''


" setting font for gvim and macvim
if has('gui_running')
    set guifont=Meslo\ LG\ S\ for\ Powerline:h18
endif

" disable automatic comment insertion on newlines after a comment
autocmd FileType * setlocal formatoptions-=c formatoptions-=r formatoptions-=o

" available mappings
" R
" z
" Z
" g
" ,
" nmap <leader>,
" <leader>,
" <leader>i
" <leader>c
inoremap <silent><script><expr> <leader><space> copilot#Accept()
let g:copilot_no_tab_map = v:true

set background=dark
if filereadable(expand("~/.vimrc_background"))
    let base16colorspace=256
    source ~/.vimrc_background
endif

if !executable('pbcopy') && executable('xclip')
    " change system-copy plugin copy commands to use xclip when not on macos
    let g:system_copy#copy_command='xclip -sel clipboard'
    let g:system_copy#paste_command='xclip -sel clipboard -o'
endif

" ===================================================================================
" ===================================================================================
" lua configuration
" ===================================================================================
lua << EOF
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- hop setup
require('hop').setup()

require('Comment').setup()
require('pairs'):setup({ enter = { enable_mapping = false } })
require('numb').setup()
require('colorizer').setup({
    '*';
}, {
    RGB = true;
    RRGGBB = true;
    RRGGBBAA = true;
    names = true;
    rgb_fn = true;
    hsl_fn = true;
    css = true;
    css_fn = true;
})

require('nvim-treesitter.configs').setup({
    ensure_installed = {
        -- "astro",
        "bash",
        -- "c",
        -- "c_sharp",
        -- "cmake",
        "comment",
        -- "cpp",
        "css",
        "diff",
        "dockerfile",
        "git_config",
        "git_rebase",
        "gitattributes",
        "gitcommit",
        "gitignore",
        "go",
        "gomod",
        "gosum",
        "gowork",
        "graphql",
        -- "groovy",
        "html",
        -- "htmldjango",
        "http",
        "java",
        "javascript",
        "jq",
        "jsdoc",
        "json",
        "json5",
        "jsonc",
        "kotlin",
        "lua",
        "luadoc",
        -- "make",
        "markdown",
        "markdown_inline",
        -- "objc",
        -- "pem",
        -- "php",
        -- "phpdoc",
        -- "po",
        "prisma",
        "python",
        "query",
        "regex",
        -- "rust",
        "scss",
        "sql",
        -- "svelte",
        -- "swift",
        "terraform",
        "toml",
        "tsx",
        "typescript",
        "vim",
        "vimdoc",
        -- "vue",
        "yaml"
    },
    auto_install = true,
    sync_install = false,
    ignore_install = {},
    highlight = {
        enable = true,
        disable = {},
        additional_vim_regex_highlighting = false
    },
    indent = {
        enable = true
    }
})

function fxJSONFormat(content)
    return vim.fn.system({ "fx", "." }, content)
end

require("rest-nvim").setup({
    result_split_horizontal = false,
    result_split_in_place = true,
    skip_ssl_verification = true,
    encode_url = true,
    highlight = { enabled = true, timeout = 1000 },
    result = {
        show_url = true,
        show_http_info = true,
        show_headers = true,
        formatters = {
            json = fxJSONFormat,
            vnd = fxJSONFormat,
            html = function(body)
                return vim.fn.system({ "tidy", "-i", "-q", "-" }, body)
            end,
        }
    },
    jump_to_request = false,
    env_file = '.env',
    custom_dynamic_variables = {},
    yank_dry_run = true,
})

vim.diagnostic.config({ virtual_text = true })

-- telescope setup
require('telescope').setup({
    extensions = {
        file_browser = {
            hijack_netrw = true,
        },
    },
    defaults = {
        mappings = {
            i = {
                ["jj"] = { "<esc>", type = "command" },
                ["<C-j>"] = require('telescope.actions').move_selection_next,
                ["<C-k>"] = require('telescope.actions').move_selection_previous
            }
        },
        layout_strategy = 'flex',
        sorting_strategy = "ascending",
        layout_config = { width = 0.95, prompt_position = 'top' }
    },
    pickers = {
        buffers = {
            sort_lastused = true,
        }
    }
})

function vim.getVisualSelection()
	vim.cmd('noau normal! "vy"')
	local text = vim.fn.getreg('v')
	vim.fn.setreg('v', {})

	text = string.gsub(text, "\n", "")
	if #text > 0 then
		return text
	else
		return ''
	end
end

vim.keymap.set('n', '<leader>fb', function()
    vim.cmd('normal! viw')
    local text = vim.getVisualSelection()
    require('telescope.builtin').live_grep({ default_text = text })
end, { noremap = true, silent = true })

vim.keymap.set('v', '<leader>fb', function()
	local text = vim.getVisualSelection()
	require('telescope.builtin').live_grep({ default_text = text })
end, { noremap = true, silent = true })

-- live grep using Telescope inside the current directory under
-- the cursor (or the parent directory of the current file)
local function grep_in()
    local api = require('nvim-tree.api')
    local node = api.tree.get_node_under_cursor()

    if not node then
        return
    end

    local path = node.absolute_path or uv.cwd()
    if node.type ~= 'directory' and node.parent then
        path = node.parent.absolute_path
    end

    require('telescope.builtin').live_grep({
        search_dirs = { path },
        prompt_title = string.format('Grep in [%s]', vim.fs.basename(path)),
    })
end

require('telescope').load_extension('terraform_doc')
require("telescope").load_extension "docker"
require("telescope").load_extension "file_browser"

---------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------

-- nvim-tree setup
require("nvim-tree").setup {
    hijack_cursor = true,
    hijack_netrw = false,
    reload_on_bufenter = true,
    update_focused_file = {
        enable = true,
    },
    git = {
        ignore = false,
        timeout = 999
    },
    modified = { enable = true },
    actions = {
        expand_all = {
            exclude = { ".git", "node_modules", "dist", "build" }
        },
    },

    diagnostics = {
        enable = true,
        show_on_dirs = true,
        show_on_open_dirs = true,
    },
    on_attach = function(bufnr)
        local api = require('nvim-tree.api')

        local function opts(desc)
            return { desc = 'nvim-tree: ' .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
        end

        vim.keymap.set('n', 'a', api.fs.create, opts('Create'))
        vim.keymap.set('n', 'R', api.tree.reload, opts('Refresh'))
        vim.keymap.set('n', 'd', api.fs.remove, opts('Delete'))
        vim.keymap.set('n', 'c', api.fs.cut, opts('Cut'))
        vim.keymap.set('n', 'r', api.fs.rename, opts('Rename'))
        vim.keymap.set('n', 'y', api.fs.copy.node, opts('Copy'))
        vim.keymap.set('n', 'p', api.fs.paste, opts('Paste'))
        vim.keymap.set('n', '?', api.tree.toggle_help, opts('Help'))
        vim.keymap.set('n', 'E', api.tree.expand_all, opts('Expand all'))
        vim.keymap.set('n', 'X', api.tree.collapse_all, opts('Collapse all'))
        vim.keymap.set('n', 'x', api.node.navigate.parent_close, opts('Close Directory'))
        vim.keymap.set('n', '<', api.node.navigate.parent_close, opts('Close Directory'))
        vim.keymap.set('n', ']', api.tree.change_root_to_node, opts('CD'))
        vim.keymap.set('n', '[', api.tree.change_root_to_parent, opts('Up'))
        vim.keymap.set('n', 'K', api.node.show_info_popup, opts('Info'))
        vim.keymap.set('n', '<C-v>', api.node.open.vertical, opts('Open: Vertical Split'))
        vim.keymap.set('n', 'v', api.node.open.vertical, opts('Open: Vertical Split'))
        vim.keymap.set('n', 's', api.node.open.horizontal, opts('Open: Horizontal Split'))
        vim.keymap.set('n', '<C-s>', api.node.open.horizontal, opts('Open: Horizontal Split'))
        vim.keymap.set('n', 'O', api.node.open.edit, opts('Open'))
        vim.keymap.set('n', 'o', api.node.open.no_window_picker, opts('Open: No Window Picker'))
        vim.keymap.set('n', '<CR>', api.node.open.no_window_picker, opts('Open: No Window Picker'))
        vim.keymap.set('n', '>', api.node.open.no_window_picker, opts('Open: No Window Picker'))
        vim.keymap.set('n', '<2-LeftMouse>', api.node.open.no_window_picker, opts('Open: No Window Picker'))
        vim.keymap.set('n', '<C-f>', grep_in, opts('Search in directory'))
    end,
    view = {
        adaptive_size = false,
        centralize_selection = false,
        width = {
            min = 30,
            max = 42,
            padding = 1,
        },
        side = "left",
    },
    renderer = {
        highlight_git = false,
        add_trailing = true,
        full_name = true,
        group_empty = false,
        highlight_opened_files = "name",
        root_folder_label = ":t:r",
        special_files = {},
        indent_markers = {
            enable = true,
        },
        icons = {
            git_placement = "after",
            modified_placement = "before",
            show = {
                file = false,
                folder = false,
            },
        },
    },
}

-- Indent blankline
local hooks = require "ibl.hooks"
-- create the highlight groups in the highlight setup hook, so they are reset
-- every time the colorscheme changes
hooks.register(
    hooks.type.HIGHLIGHT_SETUP, function()
        vim.api.nvim_set_hl(0, "RainbowRed", { fg = "#E06C75" })
        vim.api.nvim_set_hl(0, "RainbowYellow", { fg = "#E5C07B" })
        vim.api.nvim_set_hl(0, "RainbowBlue", { fg = "#61AFEF" })
        vim.api.nvim_set_hl(0, "RainbowOrange", { fg = "#D19A66" })
        vim.api.nvim_set_hl(0, "RainbowGreen", { fg = "#98C379" })
        vim.api.nvim_set_hl(0, "RainbowViolet", { fg = "#C678DD" })
        vim.api.nvim_set_hl(0, "RainbowCyan", { fg = "#56B6C2" })
    end
)

require("ibl").setup {
    indent = {
        char = "|",
        highlight =  {
            "RainbowRed",
            "RainbowYellow",
            "RainbowBlue",
            "RainbowOrange",
            "RainbowGreen",
            "RainbowViolet",
            "RainbowCyan",
        },
    },
    whitespace = {
        remove_blankline_trail = true,
    },
    scope = {
    }
}

-- winbar setup
vim.o.winbar = "%{expand(\"%:~:.\")} %m%=%{coc#status()} "

-- status line setup
require('lualine').setup {
    options = {
        -- theme = '16color',
        -- theme = 'gruvbox_dark',
        theme = 'material',
        -- theme = 'powerline',
        -- theme = 'papercolor_dark',
        icons_enabled = false,
        section_separators = { left = '', right = '' },
        component_separators = { left = '', right = '' }
    },
}

require('bufferline').setup({
    options = {
        mode = "buffers",
        indicator = {
            style = 'none'
        },
        enforce_regular_tabs = false,
        buffer_close_icon = 'x',
        close_icon = 'x',
        show_buffer_icons = false,
        show_buffer_default_icon = false,
        left_trunc_marker = '..',
        right_trunc_marker = '..',
        diagnostics = "coc",
        separator_style = {"", ""},
        name_formatter = function(buf)
            return '' .. buf.name .. ' '
        end,
        always_show_bufferline = true,
        max_name_length = 50,
        tab_size = 2,
        offsets = {
            {
                filetype = "NvimTree",
                text = "Explorer",
                highlight = "Directory",
                separator = '',
                text_align = "left"
            }
        },
    },
})

EOF

" ===========================================================
" Custom Mappings

let g:tmux_navigator_no_mappings = 1
let g:tmux_navigator_disable_when_zoomed = 1
nnoremap <silent> <c-h> :<C-U>TmuxNavigateLeft<cr>
nnoremap <silent> <c-d> :<C-U>TmuxNavigateDown<cr>
nnoremap <silent> <c-u> :<C-U>TmuxNavigateUp<cr>
nnoremap <silent> <c-l> :<C-U>TmuxNavigateRight<cr>

" Quickly go to normal mode
inoremap jj <Esc>

" adding new lines from normal mode - for speed factoring and cleaning
nnoremap <CR> o<esc>
nnoremap <leader><return> O<esc>
inoremap <leader><return> <esc>O

" make enter behave normally for quickfix
augroup QuickFix
     au FileType qf map <buffer> <CR> <CR>
augroup END

" faster movoment - multiple line jumping
nmap <C-j> 10j
vmap <C-j> 10j
nmap <C-k> 10k
vmap <C-k> 10k

" single and double quotes in normal mode navigate forward and backwards 24 lines
nnoremap ' 20j
nnoremap " 20k

"split resizing
" increase vertically
nnoremap == <C-w>3+
" decrease vertically
nnoremap -- <C-w>3-
" increase horizontally
nnoremap <leader>] <C-w>4>
" decrease horizontally
nnoremap <leader>[ <C-w>4<

" leader+tab inserts a literal tab character in insert mode
inoremap <leader><Tab> <C-V><Tab>

nnoremap <Tab> za

nnoremap <leader>sr <Plug>RestNvim

" w moves to the end of word not the begining of it
noremap w e

" e and r act as home and end keys
nnoremap e ^
vnoremap e ^
onoremap e ^
nnoremap r $
vnoremap r $
onoremap r $

" Remap j and k to act as expected when used on long, wrapped, lines
nnoremap <silent> j gj
vnoremap <silent> j gj
nnoremap <silent> k gk
vnoremap <silent> k gk
nnoremap <silent> <down> gj
vnoremap <silent> <down> gj
nnoremap <silent> <up> gk
vnoremap <silent> <up> gk

" redo with capital U
noremap U <C-r>

nnoremap <leader>g :enew<cr> " open new buffer

" search for selection
" use * for words under cursor
vnoremap <leader>f y/<C-R>"<cr>

" map leader+space to execute q macro quickly
nnoremap <leader><space> @q
vnoremap <leader><space> @q

" duplicate lines after
" without separator line
nnoremap <leader>d YP`[v`]<esc>l
vnoremap <leader>d YP`[v`]<esc>l

" swapping lines down and up respecting the top and bottom of the buffer
nnoremap <silent> H :m .+1<cr>==
vnoremap <expr><silent> H max([line('.'),line('v')]) < line('$') ? ':m ''>+1<cr>gv=gv' : ''
nnoremap <silent> L :m .-2<cr>==
vnoremap <expr><silent> L min([line('.'),line('v')]) > 1 ? ':m ''<-2<cr>gv=gv' : ''

"easier colons in normal mode
noremap <space> :

" enabling paste - note that this mapping doesn't work when paste is on
nnoremap <leader>v :set<space>invpaste<cr>
inoremap <leader>v <esc>:set<space>invpaste<cr>
vnoremap <leader>v <esc>:set<space>invpaste<cr>

" arrow mappings
:autocmd FileType js,javascript,blade,typescript,javascriptreact,typescriptreact,rust,php,go inoremap >> =>
:autocmd FileType js,javascript,typescript,javascriptreact,typescriptreact imap afkj () => {
:autocmd FileType js,javascript,typescript,javascriptreact,typescriptreact imap logkj console.log(
:autocmd FileType js,javascript,typescript,javascriptreact,typescriptreact imap imkj import  from '
:autocmd FileType js,javascript,typescript,javascriptreact,typescriptreact imap ifkj if () {
inoremap xx $
inoremap vv ``<esc>i

" mappings for speed buffer switching
nnoremap <leader>b :bprevious<CR>
nnoremap <leader>n :bnext<CR>

"mappings for saving files
nnoremap <leader>w :w<cr>
vnoremap <leader>w <esc>:w<cr>
inoremap <leader>w <esc>:w<cr>

" close current buffer without messing up with splits
function! DeleteBuffer()
    if &buftype ==# 'terminal'
        Bdelete!
    else
        Bdelete
    endif
endfunction

nnoremap <leader>q :call DeleteBuffer()<cr>
vnoremap <leader>q <esc>:call DeleteBuffer()<cr>
inoremap <leader>q <esc>:call DeleteBuffer()<cr>

" force close current buffer without saving and without messing up with splits
nnoremap <leader>z :Bdelete!<cr>
vnoremap <leader>z <esc>:Bdelete!<cr>
inoremap <leader>z <esc>:Bdelete!<cr>

" quit vim
nnoremap qqq <esc>:NvimTreeClose<cr>:q<CR>

" force quit vim
nnoremap <leader>fq <esc>:NvimTreeClose<CR>:q!<CR>

nmap <leader><leader>w :HopWord<cr>

"make < > keep selection after indentenation
vnoremap < <gv
vnoremap > >gv

" use single key stroke to indent single lines instead of double
nnoremap > >>
nnoremap < <<

" keeps what's yanked after pasting(putting)
nnoremap <expr> p 'p`[' . strpart(getregtype(), 0, 1) . '`]y'
vnoremap <expr> p 'p`[' . strpart(getregtype(), 0, 1) . '`]y'
nnoremap <leader>m :MaximizerToggle<cr>

nnoremap <leader>t :term<cr>
tnoremap <ESC><ESC> <C-\><C-N>

" move splits
nnoremap <silent> <leader>h <c-w>H
nnoremap <silent> <leader>u <c-w>K

nnoremap <C-p> <cmd>lua require"telescope.builtin".find_files({ hidden = true })<CR>
nnoremap <C-o> <cmd>Telescope buffers<CR>
nnoremap <C-f> <cmd>Telescope live_grep<CR>

" toggle tag bar
nnoremap <leader>i <cmd>TagbarToggle<CR>

nnoremap ff :NvimTreeToggle<cr>

" quickly switch currently open buffers
nnoremap <silent><leader>1 <Cmd>BufferLineGoToBuffer 1<CR>
nnoremap <silent><leader>2 <Cmd>BufferLineGoToBuffer 2<CR>
nnoremap <silent><leader>3 <Cmd>BufferLineGoToBuffer 3<CR>
nnoremap <silent><leader>4 <Cmd>BufferLineGoToBuffer 4<CR>
nnoremap <silent><leader>5 <Cmd>BufferLineGoToBuffer 5<CR>
nnoremap <silent><leader>6 <Cmd>BufferLineGoToBuffer 6<CR>
nnoremap <silent><leader>7 <Cmd>BufferLineGoToBuffer 7<CR>
nnoremap <silent><leader>8 <Cmd>BufferLineGoToBuffer 8<CR>
nnoremap <silent><leader>9 <Cmd>BufferLineGoToBuffer 9<CR>

" Save file with sudo
command! -nargs=0 WriteWithSudo :w !sudo tee % >/dev/null
" Use :ww instead of :WriteWithSudo
cnoreabbrev ww WriteWithSudo

" database UI
" nnoremap <leader>db <cmd>:DBUI<CR>
cnoreabbrev db DBUI
cnoreabbrev dbui DBUI
let g:db_ui_save_location = '~/projects/db-connections'
autocmd FileType dbout IndentBlanklineDisable

let g:better_whitespace_filetypes_blacklist=['NvimTree', 'diff', 'git', 'gitcommit', 'unite', 'qf', 'help', 'markdown', 'fugitive', 'dbout']
