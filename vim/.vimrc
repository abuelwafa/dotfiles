"Abuelwafa's vimrc file

set nocompatible

" download vim-plug if its not present
if empty(glob('~/projects/dotfiles/vim/autoload/plug.vim'))
  silent !curl -fLo ~/projects/dotfiles/vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
endif

" Run PlugInstall if there are missing plugins
autocmd VimEnter * if len(filter(values(g:plugs), '!isdirectory(v:val.dir)'))
  \| PlugInstall --sync | source $MYVIMRC
\| endif

" initiate vim-plug
call plug#begin()
Plug 'preservim/nerdtree'
Plug 'Xuyuanp/nerdtree-git-plugin'
Plug 'ctrlpvim/ctrlp.vim'
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'sheerun/vim-polyglot'
Plug 'christoomey/vim-tmux-navigator'
Plug 'editorconfig/editorconfig-vim'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-git'
" to be analyzed
" Plug 'mg979/vim-visual-multi', {'branch': 'master'}
Plug 'iamcco/markdown-preview.nvim', { 'do': 'cd app && yarn install' }
Plug 'christoomey/vim-system-copy'
Plug 'mileszs/ack.vim'
Plug 'Lokaltog/vim-easymotion'
Plug 'tomtom/tcomment_vim'
Plug 'airblade/vim-gitgutter'
Plug 'jiangmiao/auto-pairs'
Plug 'Yggdroot/indentLine'
Plug 'bronson/vim-trailing-whitespace'
Plug 'terryma/vim-multiple-cursors'
Plug 'tomtom/tlib_vim'
Plug 'tinted-theming/base16-vim'
Plug 'MarcWeber/vim-addon-mw-utils'
Plug 'jparise/vim-graphql'
Plug 'mattn/emmet-vim'

call plug#end()

"===================================================
" basic configuration
"===================================================

set t_Co=256
syntax on
set ruler
set ttyfast

" Indentation
set smartindent
set cindent
set autoindent

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
set foldmethod=indent
set foldnestmax=10
set nofoldenable
set foldlevel=20

set lbr
set showmode

set tabstop=4
set softtabstop=4
set shiftwidth=4
set expandtab
" set noexpandtab

" improve autocomplete menu color
" highlight Pmenu ctermbg=238 gui=bold

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

" set encoding
set fileencoding=utf8
set encoding=utf-8

" remember more commands and search history
set history=1000
" use many much of levels of undo  "
set undolevels=1000
set undofile
set undodir=$TEM

" hide buffers instead of closing them, allows for changing files without saving
set hidden

" disable backup and swap files
set nobackup
set noswapfile
set nowritebackup
" set backupdir^=~/.vim/_backup//    " where to put backup files.
" set directory^=~/.vim/_temp//      " where to put swap files.

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
set updatetime=200

" don't give |ins-completion-menu| messages.
set shortmess+=c

" Better display for messages
" set cmdheight=2

" set nolist
set list
" makes cursor on the begining of tab characters. makes it behaves like other editors
set listchars=tab:\ \
" view tabs with pipe character and three spaces to proper view indent guides
" set listchars=tab:\|\
" set listchars=tab:\|.
set listchars=tab:\|-
" set listchars=tab:\|_
" set listchars=tab:\>.
" set listchars=tab:\>-
" set listchars=tab:\>\
" set listchars=tab:.\
" set listchars+=trail:.
set listchars+=extends:>

" Open new windows on the bottom and right instead of the top and left.
set splitbelow
set splitright

" ctrlp plugin configuration
let g:ctrlp_custom_ignore = '\v[\/](node_modules|vendor|build|dist)|(\.(swp|ico|git|hg|svn|jpg|png|gif|ttf|otf|woff|pdf))$'
let g:ctrlp_match_window = 'order:ttb,results:100,max:10'
let g:ctrlp_show_hidden = 1
let g:ctrlp_follow_symlinks = 1
let g:ctrlp_lazy_update = 1
let g:ctrlp_cache_dir = $HOME.'/.cache/ctrlp'

nnoremap <C-o> :CtrlPBuffer<cr>

" mappings for easy window navigation
" don't have much of an effect now because they are configured by tmux navigation
map <C-h> <C-w>h
map <C-d> <C-w>j
map <C-u> <C-w>k
map <C-l> <C-w>l

"split resizing
nnoremap == <C-w>3+ " increase vertically
nnoremap -- <C-w>3- " decrease vertically
nnoremap <leader>] <C-w>4> " increase horizontally
nnoremap <leader>[ <C-w>4< " decrease horizontally

" nerdtree plugin configuration
let NERDTreeShowHidden=1 " show hidden files in nerdtree file plugin
let NERDTreeQuitOnOpen=0
let NERDTreeWinSize=32
let NERDTreeCaseSensitiveSort=1
let NERDTreeNaturalSort=1
" let NERDTreeWinPos="right"
let NERDTreeAutoDeleteBuffer=1
let NERDTreeDirArrows=1
" let NERDTreeMinimalUI=1
let NERDTreeCascadeOpenSingleChildDir=1
let NERDTreeCascadeSingleChildDir=0
let NERDTreeIgnore=['.DS_Store']

" If another buffer tries to replace NERDTree, put it in the other window, and bring back NERDTree.
autocmd BufEnter * if bufname('#') =~ 'NERD_tree_\d\+' && bufname('%') !~ 'NERD_tree_\d\+' && winnr('$') > 1 |
    \ let buf=bufnr() | buffer# | execute "normal! \<C-W>w" | execute 'buffer'.buf | endif

" Check if NERDTree is open or active
function! IsNERDTreeOpen()
  return exists("t:NERDTreeBufName") && (bufwinnr(t:NERDTreeBufName) != -1)
endfunction

" Call NERDTreeFind iff NERDTree is active, current window contains a modifiable
" file, and we're not in vimdiff
function! SyncTree()
  if &modifiable && IsNERDTreeOpen() && strlen(expand('%')) > 0 && !&diff
    NERDTreeFind
    wincmd p
  endif
endfunction

" Highlight currently open buffer in NERDTree
autocmd BufRead * call SyncTree()

" Start NERDTree and put the cursor back in the other window.
autocmd VimEnter * NERDTree | wincmd p
" autocmd VimEnter * NERDTree

" close vim if nerdtree is the only buffer left
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif

" nerdtree toggle mapping
nnoremap ff :NERDTreeToggle<CR>

" mappings for speed buffer switching
nnoremap <leader>b :bprevious<CR>
nnoremap <leader>n :bnext<CR>

"mappings for saving files
nnoremap <leader>w :w<cr>
vnoremap <leader>w <esc>:w<cr>
inoremap <leader>w <esc>:w<cr>


" close current buffer without messing up with splits
nnoremap <leader>q :bp<CR>:bd #<cr>
vnoremap <leader>q <esc>:bp<CR>:bd #<cr>
inoremap <leader>q <esc>:bp<CR>:bd #<cr>

" force close current buffer without saving and without messing up with splits
nnoremap <leader>z :bn<CR>:bd! #<cr>
vnoremap <leader>z <esc>:bn<CR>:bd! #<cr>
inoremap <leader>z <esc>:bn<CR>:bd! #<cr>

" quit vim
nnoremap qqq :q<CR>

" force quit vim
" nnoremap <leader>fq <esc>:NERDTreeClose<CR>:q!<CR>
nnoremap <leader>fq :qa!<CR>

"make < > keep selection after indentenation
vnoremap < <gv
vnoremap > >gv

" use single key stroke to indent single lines instead of double
nnoremap > v><Esc>
nnoremap < v<<Esc>

" keeps what's yanked(copied) after pasting(putting)
nnoremap <expr> p 'p`[' . strpart(getregtype(), 0, 1) . '`]y'
vnoremap <expr> p 'p`[' . strpart(getregtype(), 0, 1) . '`]y'

" disable automatic comment insertion on newlines after a comment
autocmd FileType * setlocal formatoptions-=c formatoptions-=r formatoptions-=o

" enable mouse in console
set mousemodel=extend
set mouse=a
set mousehide
set mouse+=a
if &term =~ '^screen'
    " tmux knows the extended mouse mode
    set ttymouse=xterm2
endif

" setting font for gvim and macvim
if has('gui_running')
    set guifont=Meslo\ LG\ S\ for\ Powerline:h18
endif

let g:tmux_navigator_no_mappings = 1
let g:tmux_navigator_disable_when_zoomed = 1

nnoremap <ctrl-h> :TmuxNavigateLeft<cr>
nnoremap <ctrl-d> :TmuxNavigateDown<cr>
nnoremap <ctrl-u> :TmuxNavigateUp<cr>
nnoremap <ctrl-l> :TmuxNavigateRight<cr>

" easymotion config
let g:EasyMotion_do_mapping = 0 " Disable default mappings
nmap <leader><leader>w <Plug>(easymotion-overwin-w)

" vim airline configuration
set fillchars+=stl:\ ,stlnc:\
" Always show status line
set laststatus=2
set ttimeoutlen=20
let g:airline_powerline_fonts = 1
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#branch#displayed_head_limit = 14
" let g:airline#extensions#tabline#fnamemod = ':t'
let g:airline#extensions#tabline#buffers_label = 'b'
let g:airline#extensions#tabline#tabs_label = 't'
let g:airline#extensions#tabline#show_tab_type = 0
let g:airline#extensions#whitespace#enabled = 1
let g:airline#extensions#tabline#left_sep = ''
let g:airline#extensions#tabline#left_alt_sep = ''
let g:airline#extensions#tabline#right_sep = ''
let g:airline#extensions#tabline#right_alt_sep = ''
let g:airline_theme='powerlineish'
let g:airline_inactive_collapse=1
let g:airline_skip_empty_sections = 1
let g:airline_highlighting_cache = 1
let g:airline_left_sep=' '
let g:airline_right_sep=' '

" enable jsx for .js files
let g:jsx_ext_required = 0

let g:EditorConfig_exclude_patterns = ['fugitive://.*', 'scp://.*']

set tags=./tags

" remove vim background - makes it transparent if the colorscheme has no background
highlight nonText ctermbg=NONE

let g:javascript_plugin_jsdoc = 1

" Highlight ES6 template strings
hi link javaScriptTemplateDelim String
hi link javaScriptTemplateVar Text
hi link javaScriptTemplateString String

augroup javascript_folding
    au!
    au FileType javascript setlocal foldmethod=syntax
    au FileType javascript.jsx setlocal foldmethod=syntax
augroup END

"===============================================================================
"===============================================================================
" COC configuration

  " \ 'coc-java',
  " \ 'coc-snippets',
let g:coc_global_extensions = [
  \ 'coc-prettier',
  \ 'coc-tsserver',
  \ 'coc-json',
  \ 'coc-eslint',
  \ 'coc-html',
  \ 'coc-css',
  \ 'coc-styled-components',
  \ 'coc-eslint',
  \ 'coc-db',
  \ 'coc-sql',
  \ 'coc-highlight',
  \ 'coc-clangd',
  \ 'coc-sh',
  \ 'coc-rust-analyzer',
  \ 'coc-go',
  \ 'coc-svg',
  \ 'coc-yaml',
  \ 'coc-xml',
  \ 'coc-swagger',
  \ 'coc-vimlsp',
  \ 'coc-restclient',
  \ ]

let g:vim_json_syntax_conceal = 0
let g:vim_markdown_conceal = 0
let g:vim_markdown_conceal_code_blocks = 0

" Use tab for trigger completion with characters ahead and navigate.
" NOTE: There's always complete item selected by default, you may want to enable
" no select by `"suggest.noselect": true` in your configuration file.
" NOTE: Use command ':verbose imap <tab>' to make sure tab is not mapped by
" other plugin before putting this into your config.
inoremap <silent><expr> <TAB>
  \ coc#pum#visible() ? coc#pum#next(1) :
  \ CheckBackspace() ? "\<Tab>" :
  \ coc#refresh()
inoremap <expr><S-TAB> coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"

" Make <CR> to accept selected completion item or notify coc.nvim to format
" <C-g>u breaks current undo, please make your own choice.
inoremap <silent><expr> <CR> coc#pum#visible() ? coc#pum#confirm()
  \: "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"

function! CheckBackspace() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

" map leader+space to omni completion in insert mode
" inoremap <leader><space> <C-x><C-o>

" Use <c-space> to trigger completion.
inoremap <silent><expr> <c-@> coc#refresh()
inoremap <silent><expr> <c-space> coc#refresh()

" Make <CR> auto-select the first completion item and notify coc.nvim to
" format on enter, <cr> could be remapped by other vim plugin
inoremap <silent><expr> <cr> pumvisible() ? coc#_select_confirm()
                              \: "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"

" Use <cr> to confirm completion, `<C-g>u` means break undo chain at current
" position. Coc only does snippet and additional edit on confirm.
" <cr> could be remapped by other vim plugin, try `:verbose imap <CR>`.
if exists('*complete_info')
  inoremap <expr> <cr> complete_info()["selected"] != "-1" ? "\<C-y>" : "\<C-g>u\<CR>"
else
  inoremap <expr> <cr> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"
endif

" Highlight the symbol and its references when holding the cursor.
autocmd CursorHold * silent call CocActionAsync('highlight')

" Symbol renaming.
nmap <leader>rn <Plug>(coc-rename)

" GoTo code navigation.
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

function! s:show_documentation()
  if (index(['vim','help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  elseif (coc#rpc#ready())
    call CocActionAsync('doHover')
  else
    execute '!' . &keywordprg . " " . expand('<cword>')
  endif
endfunction

" Use K to show documentation in preview window.
nnoremap <silent> K :call <SID>show_documentation()<CR>
" " show documentation tooltip on cursor hold
" autocmd CursorHold * silent call <SID>show_documentation()

augroup mygroup
  autocmd!
  " Setup formatexpr specified filetype(s).
  autocmd FileType typescript,json setl formatexpr=CocAction('formatSelected')
  " Update signature help on jump placeholder.
  autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
augroup end

" Remap keys for applying codeAction to the current buffer.
nmap <leader>a <Plug>(coc-codeaction)
nmap <leader>ac <Plug>(coc-codeaction-selected)
xmap <leader>ac <Plug>(coc-codeaction-selected)
" Apply AutoFix to problem on the current line.
" nmap <leader>f <Plug>(coc-fix-current)

" Add `:Format` command to format current buffer.
" command! -nargs=0 Format :call CocAction('format')

" Add `:Fold` command to fold current buffer.
command! -nargs=? Fold :call CocAction('fold', <f-args>)

" Add `:OR` command for organize imports of the current buffer.
command! -nargs=0 OR   :call CocAction('runCommand', 'editor.action.organizeImport')

" add prettier command
command! -nargs=0 Prettier :CocCommand prettier.formatFile

autocmd User EasyMotionPromptBegin :let b:coc_diagnostic_disable = 1
autocmd User EasyMotionPromptEnd :let b:coc_diagnostic_disable = 0

"===============================================================================
"===============================================================================
"===================================
" Custom Mappings
"===================================

" let mapleader=""

" Quickly get out of insert or visual mode without your fingers having to leave the home row (either use 'jj' or '\\')
vnoremap <leader><leader> <esc>
" inoremap <Bslash><Bslash> x<bs><esc>
" inoremap jj x<bs><Esc>
inoremap <leader><leader> <esc>
inoremap jj <Esc>

" nnoremap <bs> X " make backspace work in normal mode

" keep the whitespace indentation upon leaving the insert mode on blank lines
" nnoremap o ox<bs>
" nnoremap O Ox<bs>

" adding new lines from normal mode - for speed factoring and cleaning
" nnoremap <CR> ox<bs><esc>
nnoremap <CR> o<esc>
" nnoremap <leader><return> Ox<bs><esc>
nnoremap <leader><return> O<esc>
inoremap <leader><return> <esc>o
" inoremap <CR> x<bs>

" faster movoment - multiple line jumping
nmap <C-down> 10j
vmap <C-down> 10j
nmap <C-up> 10k
vmap <C-up> 10k
nmap <C-j> 10j
vmap <C-j> 10j
nmap <C-k> 10k
vmap <C-k> 10k

" single and double quotes in normal mode navigate forward and backwards 24 lines
nnoremap ' 20j
nnoremap " 20k

" leader+tab inserts a literal tab character in insert mode
inoremap <leader><Tab> <C-V><Tab>

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
nnoremap j gj
nnoremap k gk
nnoremap <down> gj
nnoremap <up> gk
" vnoremap j gj
" vnoremap k gk
" vnoremap <down> gj
" vnoremap <up> gk

noremap U <C-r> " redo with capital U

nnoremap <leader>g :enew<cr> " open new buffer

" search for selection
" use * for words under cursor
vnoremap <leader>f y/<C-R>"<cr>


" map leader+space to execute q macro quickly
nnoremap <leader><space> @q
vnoremap <leader><space> @q

" duplicate lines after
" without separator line
nnoremap <S-down> YP`[v`]<esc>l
vnoremap <S-down> YP`[v`]<esc>l
nnoremap <leader>d YP`[v`]<esc>l
vnoremap <leader>d YP`[v`]<esc>l
" and with separator line

" duplicate lines before
" without separator line
nnoremap <S-up> YP
vnoremap <S-up> YP

" swapping lines down
" nnoremap = Vdp
" vnoremap = Vdp`[v`]
nnoremap H Vdp
vnoremap H Vdp`[v`]

" swapping lines up
" nnoremap - VdkP
" vnoremap - VdkP`[v`]
nnoremap L VdkP
vnoremap L VdkP`[v`]

"easier colons in normal mode
noremap <space> :

" enabling paste - note that this mapping doesn't work when paste is on
nnoremap <leader>v :set<space>invpaste<cr>
inoremap <leader>v <esc>:set<space>invpaste<cr>
vnoremap <leader>v <esc>:set<space>invpaste<cr>

" arrow mappings
:autocmd FileType js,javascript,smarty,blade,typescript,javascriptreact,typescriptreact,rust,php,go inoremap >> =>
:autocmd FileType js,javascript,smarty,blade,typescript,javascriptreact,typescriptreact,rust,php,go inoremap ,, =>
:autocmd FileType js,javascript,typescript,javascriptreact,typescriptreact imap afkj () => {
:autocmd FileType js,javascript,typescript,javascriptreact,typescriptreact imap logkj console.log(
:autocmd FileType js,javascript,typescript,javascriptreact,typescriptreact imap imkj import  from '
:autocmd FileType js,javascript,typescript,javascriptreact,typescriptreact,rust,php,go,java imap ifkj if () {

:autocmd FileType js,javascript,scss,html,smarty,blade,typescript,sh,php,javascriptreact,typescriptreact inoremap xx $


" folding
nnoremap <C-i> za


" available mappings
" R
" z
" Z
" g
" ,
" <leader>s
" <leader>h
" <leader>,
" <leader>i
" <leader>c

set background=dark
if filereadable(expand("~/.vimrc_background"))
    let base16colorspace=256
    source ~/.vimrc_background
endif
