" Author: Arcthur <arthurtemptation@gmail.com>
" Description: Arcthur's vim config
" Last Change: 2016/12/29

" Preamble {{{
" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Use Vim settings, rather then Vi settings
set nocompatible

" Set augroup
augroup MyAutoCmd
  autocmd!
augroup END

augroup MyWindow
  autocmd!
augroup END

let s:use_dein = 1
" }}}

" Utils {{{
" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function! s:current_git() "{{{
  let current_dir = getcwd()
  let s:git_root_cache = get(s:, 'git_root_cache', {})
  if has_key(s:git_root_cache, current_dir)
    return s:git_root_cache[current_dir]
  endif

  let git_root = system('git rev-parse --show-toplevel')
  if git_root =~ 'fatal: Not a git repository'
    " throw "No a git repository."
    return ''
  endif

  let s:git_root_cache[current_dir] = substitute(git_root, '\n', '', 'g')

  return s:git_root_cache[current_dir]
endfunction

function! s:complement_delimiter_of_directory(path)
  return isdirectory(a:path) ? a:path . '/' : a:path
endfunction

function! s:reltime()
  return str2float(reltimestr(reltime()))
endfunction

function! s:on_init()
  return has('vim_starting') || !exists('s:loaded_vimrc')
endfunction
"}}}

" Initialize "{{{
" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
if s:on_init()
  let g:my = {}

  " user information
  let g:my.info = {
        \ 'author':  'Arcthur',
        \ 'email':   'arthurtemptation@gmail.com',
        \ 'github':  'arcthur'
        \ }

  let g:my.bin = {
        \ 'ctags' : '/usr/local/bin/ctags',
        \ 'git' : executable('hub') ? 'hub' : 'git',
        \ }

  let g:my.dir = {
        \ 'bundle':       expand('~/.vim/bundle'),
        \ 'tmp_dir':      expand('~/.vim_tmp/'),
        \ 'viminfo':      expand('~/.vim_tmp/viminfo'),
        \ 'undodir':      expand('~/.vim_tmp/undodir'),
        \ 'unite':        expand('~/.vim_tmp/unite'),
        \ 'vimfiler':     expand('~/.vim_tmp/vimfiler'),
        \ 'nerdtree':     expand('~/.vim_tmp/nerdtree'),
        \ 'vimshell':     expand('~/.vim_tmp/vimshell'),
        \ 'neomru':       expand('~/.vim_tmp/neomru'),
        \ 'neoyank':      expand('~/.vim_tmp/neoyank')
        \ }

  let g:my.ft = {
        \ 'html_files':      ['html', 'php', 'haml'],
        \ 'ruby_files':      ['ruby', 'Gemfile', 'haml', 'eruby', 'yaml'],
        \ 'js_files':        ['javascript', 'node', 'json', 'typescript'],
        \ 'python_files':    ['python', 'python*'],
        \ 'sh_files':        ['sh'],
        \ 'c_files':         ['c', 'cpp'],
        \ 'php_files':       ['php'],
        \ 'tex_files':       ['tex'],
        \ 'style_files':     ['css', 'stylus', 'less', 'scss', 'sass'],
        \ 'markup_files':    ['html', 'haml', 'erb', 'php', 'xhtml'],
        \ 'english_files':   ['markdown', 'help', 'text'],
        \ 'program_files':   ['ruby', 'tex', 'php', 'python', 'vim', 'javascript', 'go', 'cpp', 'haml'],
        \ 'ignore_patterns': ['vimfiler', 'unite'],
        \ }
endif

function! s:initialize_directory(directories)
  for dir_path in a:directories
    if !isdirectory(dir_path)
      call mkdir(dir_path, 'p')
      echomsg 'create directory : ' . dir_path
    endif
  endfor
endfunction

if s:on_init()
  call s:initialize_directory(values(g:my.dir))
endif

" Open .vimrc
nnoremap <silent>vv <esc>:e $MYVIMRC<CR>
nnoremap <silent>vs <esc>:source $MYVIMRC<CR>

" Source the vimrc file after saving it
autocmd BufWritePost .vimrc source $MYVIMRC
"}}}

" Initialize Dein {{{
" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let s:dein_enabled  = 0

if s:use_dein
  let s:dein_enabled = 1

  " Set dein paths
  let s:dein_dir = g:my.dir.bundle
  let s:dein_github = s:dein_dir . '/repos/github.com'
  let s:dein_repo_name = "Shougo/dein.vim"
  let s:dein_repo_dir = s:dein_github . '/' . s:dein_repo_name

  if !isdirectory(s:dein_repo_dir)
    echo "dein is not installed, install now "
    let s:dein_repo = "https://github.com/" . s:dein_repo_name
    echo "git clone " . s:dein_repo . " " . s:dein_repo_dir
    call system("git clone " . s:dein_repo . " " . s:dein_repo_dir)
  endif
  let &runtimepath = &runtimepath . "," . s:dein_repo_dir

  if dein#load_state(s:dein_dir)
    call dein#begin(s:dein_dir)

    " Dein
    call dein#add('Shougo/dein.vim')

    " Vimproc to asynchronously run commands
    call dein#add('Shougo/vimproc', {'build': 'make'})

    " Webapi
    call dein#add('mattn/webapi-vim')

    "call dein#add("editorconfig/editorconfig-vim")

    " Languages {{
    call dein#add('elixir-lang/vim-elixir', {
          \ 'on_ft': 'ex'
          \ })

    " Ruby
    call dein#add("vim-ruby/vim-ruby.git", {
          \ 'on_ft': 'ruby'
          \ })

    " Javascript
    call dein#add("pangloss/vim-javascript", {
          \ 'on_ft': 'javascript'
          \ })

    call dein#add("othree/yajs.vim", {
          \ 'on_ft': 'javascript'
          \ })

    call dein#add("mxw/vim-jsx", {
          \ 'on_ft': 'javascript'
          \ })

    call dein#add("isRuslan/vim-es6", {
          \ 'on_ft': 'javascript'
          \ })

    " Markdown
    call dein#add("plasticboy/vim-markdown" , {
          \ 'on_ft': 'markdown'
          \ })

    " HTML, CSS
    call dein#add("lilydjwg/colorizer", {
          \ 'on_ft': g:my.ft.style_files
          \ })

    call dein#add("cakebaker/scss-syntax.vim", {
          \ 'on_ft': 'sass'
          \ })

    call dein#add('mattn/emmet-vim', {
          \ 'on_ft': g:my.ft.html_files + g:my.ft.style_files,
          \ 'on_map': ['i', '<Plug>(EmmetExpandAbbr)']
          \ })

    call dein#add('othree/html5.vim', {
          \ 'on_ft': g:my.ft.markup_files,
          \ })

    call dein#add('hail2u/vim-css3-syntax', {
          \ 'on_ft': g:my.ft.style_files
          \ })

    call dein#add('juanpabloaj/vim-istanbul', {
          \ 'on_cmd': ['IstanbulShow', 'IstanbulHide'],
          \ 'lazy': 1
          \ })
    " }}

    " DCVS {{
    " Admin Git
    call dein#add('tpope/vim-fugitive', {
          \ 'on_cmd': ['Gcommit', 'Gblame', 'Ggrep', 'Gdiff', 'Gbrowse'],
          \ 'lazy': 1
          \ })

    call dein#add('motemen/git-vim')

    " Git viewer
    call dein#add('gregsexton/gitv', {
          \ 'depdens': ['tpope/vim-fugitive'],
          \ 'on_cmd': ['Gitv'],
          \ 'lazy': 1
          \ })

    " Github Gist
    call dein#add('mattn/gist-vim', {
          \ 'depends': ['webapi-vim'],
          \ 'on_cmd' : ['Gist'],
          \ 'lazy': 1
          \ })

    " Shows a diff via Vim's sign column
    call dein#add("mhinz/vim-signify", {
          \ 'on_cmd' : ['SignifyToggle'],
          \ 'lazy': 1
          \ })

    " Transform syntax
    call dein#add("t9md/vim-transform", {
          \ 'on_map' : [ '<Plug>(transform)', '<Plug>(transform)'],
          \ 'lazy': 1
          \ })
    " }}

    " General text editing improvements... {{

    " Completion {{{
    call dein#add('Shougo/neocomplete.vim', {
          \ 'on_i': 1,
          \ 'lazy': 1
          \ })

    call dein#add('ujihisa/neco-look', {
          \ 'depends': ['neocomplete.vim']
          \ })

    " Text filtering and alignment
    call dein#add("junegunn/vim-easy-align", {
          \ 'on_cmd' : ['EasyAlign'],
          \ 'lazy': 1
          \ })
    " Comments
    call dein#add('tyru/caw.vim', {
          \   'on_map' : ['<Plug>(caw:prefix)', '<Plug>(caw:i:toggle)'],
          \ })

    " Motions
    call dein#add('justinmk/vim-sneak')

    " Snippet
    call dein#add('Shougo/neosnippet')
    call dein#add('Shougo/neosnippet-snippets', {'depdens': ['neosnippet']})
    call dein#add('honza/vim-snippets', {'depdens': ['neosnippet']})
    call dein#add("justinj/vim-react-snippets", {'depdens': ['neosnippet']})

    " Substitute
    call dein#add('osyo-manga/vim-over', {
          \ 'on_cmd' : ['OverCommandLine'],
          \ 'lazy': 1
          \ })

    " }}

    " General vim improvements {{
    " Open large file
    call dein#add("markwu/largefile")

    " move current dir to root
    call dein#add('airblade/vim-rooter')

    " The awesome plugin looks for one of a few specific patterns under the cursor and performs
    " a substition depending on the pattern.
    call dein#add("AndrewRadev/switch.vim", {
          \ 'on_cmd' : ['Switch'],
          \ })
    call dein#add('t9md/vim-textmanip', {
          \ 'on_cmd' : [
          \   '<Plug>(textmanip-move-down)', '<Plug>(textmanip-move-up)',
          \   '<Plug>(textmanip-move-left)', '<Plug>(textmanip-move-right)'
          \ ]
          \ })
    " True Sublime Text style multiple selections
    call dein#add('terryma/vim-multiple-cursors')

    " Visually select increasingly larger regions of text using the same key combination
    call dein#add("terryma/vim-expand-region", {
          \ 'on_cmd' : ['<Plug>(expand_region_expand)']
          \ })

    call dein#add('scrooloose/nerdtree', {
          \ 'on_cmd': ['NERDTreeToggle'],
          \ 'lazy': 1
          \ })

    call dein#add('Xuyuanp/nerdtree-git-plugin', {
          \ 'depends' : ['nerdtree'],
          \ })

    call dein#add('Shougo/vimshell.vim', {
          \ 'depends': ['vimproc'],
          \ 'on_cmd' : ['VimShell', "VimShellPop", "VimShellInteractive"],
          \ 'lazy': 1
          \ })

    " Syntax checker
    call dein#add('w0rp/ale', {
          \ 'on_ft' : g:my.ft.program_files
          \ })

    " Run commands quickly
    call dein#add('thinca/vim-quickrun', {
          \ 'depends' : ['vimproc'],
          \ 'on_map' : [['nxo', '<Plug>(quickrun)']],
          \ 'on_cmd' : ['QuickRun'],
          \ 'lazy': 1
          \ })

    " Extends % operator to match html tags and others.
    call dein#add('tmhedberg/matchit', {
          \ 'on_ft': g:my.ft.program_files,
          \ 'on_map' : ['nx', '%']
          \ })

    " visualize your Vim undo tree
    call dein#add('sjl/gundo.vim', {
          \ 'on_cmd': ['GundoToggle'],
          \ 'lazy': 1
          \ })
    " Displays tags in a window, ordered by class
    " Need to fix bug in jsctags/jsctags/ctags/writter.js:67 Trait.required -> []
    call dein#add("majutsushi/tagbar", {
          \ 'on_cmd': ["TagbarToggle"],
          \ 'lazy': 1
          \ })

    " A fancy start screen for Vim
    call dein#add("mhinz/vim-startify")

    " Move 'up' or 'down' without changing the cursor column.
    " Cursor *always* stays in the same column.
    call dein#add("bruno-/vim-vertical-move")

    call dein#add('Shougo/unite.vim', {
            \ 'depends': ['vimproc'],
            \ 'on_cmd': ['Unite'],
            \ 'lazy': 1
            \ })

    " Unite Sources
    " " Source for unite: tag
    call dein#add('tsukkee/unite-tag', { 'depdens': ['unite.vim'] })

    " Source for unite: help
    call dein#add('tsukkee/unite-help', { 'depdens': ['unite.vim'] })

    " Source for unite: mru
    call dein#add('Shougo/neomru.vim', { 'depends': ['unite.vim'] })

    " Source for unite: outline
    call dein#add('Shougo/unite-outline', { 'depends': ['unite.vim'] })

    " Source for unite: session
    call dein#add('Shougo/unite-session', { 'depends': ['unite.vim'] })

    " Source for unite: quickfix
    call dein#add('osyo-manga/unite-quickfix', { 'depends': ['unite.vim'] })

    " Source for unite: history
    call dein#add('thinca/vim-unite-history', { 'depends': ['unite.vim'] })

    " Source for unite: mark
    call dein#add('tacroe/unite-mark', { 'depends': ['unite.vim'] })

    " Source for unite: giti
    call dein#add('kmnk/vim-unite-giti', { 'depends': ['unite.vim'] })

    " Source for unite: yank
    call dein#add('Shougo/neoyank.vim', { 'depends': ['unite.vim'] })
    " }}

    " Text objects {{
    " extend repetitions by the 'dot' key
    call dein#add("tpope/vim-repeat.git", {
          \ 'on_map' : '.'
          \ })
    " to surround vim objects with a pair of identical chars
    call dein#add('tpope/vim-surround', {
          \ 'on_map' : [
          \     ['nx', '<Plug>Dsurround'], ['nx', '<Plug>Csurround' ],
          \     ['nx', '<Plug>Ysurround' ], ['nx', '<Plug>YSurround' ],
          \     ['nx', '<Plug>Yssurround'], ['nx', '<Plug>YSsurround'],
          \     ['nx', '<Plug>YSsurround'], ['nx', '<Plug>VgSurround'],
          \     ['nx', '<Plug>VSurround']
          \ ]
          \ })
    call dein#add('Yggdroot/indentLine', {
          \ 'on_cmd' : ['IndentLinesReset', 'IndentLinesToggle'],
          \ 'on_ft': g:my.ft.program_files,
          \ 'lazy': 1
          \ })
    call dein#add("wellle/targets.vim")

    " Improved incremental searching
    call dein#add('haya14busa/incsearch.vim')

    call dein#add('haya14busa/incsearch-fuzzy.vim', { 'depends': ['incsearch.vim'] })

    " }}

    " GUI {{
    " Color scheme
    call dein#add("junegunn/seoul256.vim")
    call dein#add("morhetz/gruvbox")

    " Make terminal themes from GUI themes
    call dein#add('godlygeek/csapprox', {
          \ 'on_cmd' : ['CSApprox', 'CSApproxSnapshot'],
          \ 'lazy': 1
          \ })

    " Lean & mean statusline for vim
    call dein#add('itchyny/lightline.vim')
    " }}

    " Tools {{
    call dein#add("vimwiki/vimwiki")
    " }}

    call dein#end()
    call dein#save_state()
  endif

  " Installation check.
  if dein#check_install()
    call dein#install()
  endif
endif

" Other Plugins
if !exists('loaded_matchit')
  runtime macros/matchit.vim
endif
" }}}

" General {{{
" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Filetype plugin indent on is required by Dein
filetype plugin indent on

" Turn on syntax highlighting
syntax on

" Mapleader
let mapleader = ","
let maplocalleader = "\\"

" Performance Enhancement and Terseness
set shortmess+=a
set lazyredraw  " Speed up macros
set ttyfast     " Improves redrawing for newer computers

set history=100

" No sound on errors
set noerrorbells
set novisualbell
set t_vb=   "close visual bell

" Make backspace work
set backspace=indent,eol,start

" Number
set numberwidth=5
" Shows relative line numbers except for current line.
set number
set relativenumber

" Set Shell
set shell=/bin/zsh

" Always cd to the current file's directory
" set autochdir

" Display the current mode
set showmode

" Enable mouse support
set mouse=a

" Hide mouse pointer while typing
set mousehide
set mousemodel=popup

" Spell
set nospell
set spelllang=en
set dictionary+=spell " very useful, but requires ':set spell' once

noremap <silent><Leader>sp :set spell!<CR><bar>:echo "Spell check: ".strpart("OFFON", 3 * &spell, 3)<CR>

" Backup
set noswapfile
set nobackup
set nowritebackup

" Add Mac's temporary space
let &backupskip="/private/tmp/*," . &backupskip

" Timeout
set ttimeout
set ttimeoutlen=50

" Show the cursor position all the time
set ruler

" Don't try to highlight lines longer than 800 characters.
set synmaxcol=800

" Better modes.  Remeber where we are, support yankring
set viminfo='1000,<800,s300,\"1000,f1,:1000,/1000
execute 'set viminfo+=n' . g:my.dir.viminfo . '/.viminfo'

" Buffer {{
" Make switching buffers to use tabs and open windows
set switchbuf=useopen,usetab

" Enable hidden buffers
set hidden

" automatically reload a file when it has changed externally
set autoread
" }}

" Disable unused plugins
let g:loaded_gzip      = 1
let g:loaded_tar       = 1
let g:loaded_tarPlugin = 1
let g:loaded_zip       = 1
let g:loaded_zipPlugin = 1

if has('multi_byte_ime')
  set iminsert=0 imsearch=0
endif

augroup MyWindow
  " Resize splits when the window is resized
  autocmd VimResized * execute "normal! \<c-w>="
augroup END
" }}}

" Registers {{{
" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Use the OS clipboard by default
set clipboard+=unnamed

" Copy to X11 primary clipboard
map <Leader>y "*y
map <Leader>p "*p

" Paste from unnamed register and fix indentation
nmap <Leader>P pV`]=

" Make Y consistent with C and D.
noremap Y y$

" copy selection to gui-clipboard
xnoremap Y "+y

" copy/paste to clipboard and osx copy/paste
vmap <silent> <M-c> y:call system("pbcopy", getreg("\""))<CR>
nmap <silent> <M-v> :call setreg("\"",system("pbpaste"))<CR>p

" alias yw to yank the entire word 'yank inner word'
" even if the cursor is halfway inside the word
nnoremap <Leader>yw yiww

" 'overwrite word', replace a word with what's in the yank buffer
nnoremap <Leader>ow viwp
" }}}


" Undo {{{
" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
set undofile
set undodir=g:my.dir.undodir
set undolevels=1000
set undoreload=10000
" }}}

" Encoding {{{
" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
set encoding=utf-8
set fileencodings=utf-8,ucs-bom,gb18030,gbk,gb2312,cp936,latin-1
set nobomb " Don't use unicode sign

if v:lang =~? '^\(zh\)\|\(ja\)\|\(ko\)'
  set ambiwidth=double
endif
" }}}

" Indentation {{{
" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Indent {{
set autoindent
set smartindent

" shift units on indent
set shiftround
set shiftwidth=2

" Indenting or Outdenting
" while keeping the original selection in visual mode
vmap > >gv
vmap < <gv

" Tab
set smarttab
set expandtab
set tabpagemax=50
set tabstop=4
set softtabstop=4
set showtabline=1

" TabLine {{{
set tabline=%!MakeTabLine()

function! MakeTabLine()
    let s = ''

    for n in range(1, tabpagenr('$'))
        if n == tabpagenr()
            let s .= '%#TabLineSel#'
        else
            let s .= '%#TabLine#'
        endif

        let s .= '%' . n . 'T'

        let s .= ' %{MakeTabLabel(' . n . ')} '

        let s .= '%#TabLineFill#%T'
        let s .= '|'
    endfor

    let s .= '%#TabLineFill#%T'
    let s .= '%=%#TabLine#'
    let s .= '%{fnamemodify(getcwd(), ":~:h")}%<'
    return s
endfunction

function! MakeTabLabel(n)
    let bufnrs = tabpagebuflist(a:n)
    let bufnr = bufnrs[tabpagewinnr(a:n) - 1]

    let bufname = bufname(bufnr)
    if bufname == ''
        let bufname = '[No Name]'
    else
        let bufname = fnamemodify(bufname, ":t")
    endif

    let no = len(bufnrs)
    if no == 1
        let no = ''
    endif

    let mod = len(filter(bufnrs, 'getbufvar(v:val, "&modified")')) ? '+' : ''
    let sp = (no . mod) == '' ? '' : ' '

    let s = no . mod . sp . bufname
    return s
endfunction
"}}}

nnoremap [tab] <Nop>
nmap <C-t> [tab]

nnoremap <silent>[tab]t :<C-u>tabnew<CR>
nnoremap <silent>[tab]n :<C-u>tabnext<CR>
nnoremap <silent>[tab]p :<C-u>tabprevious<CR>
nnoremap <silent>[tab]c :<C-u>tabclose<CR>
nnoremap <silent>[tab]o :<C-u>tabonly<CR>

autocmd MyAutoCmd TabEnter * if exists('t:cwd') | execute "cd" fnameescape(t:cwd) | endif
autocmd MyAutoCmd TabLeave * let t:cwd = getcwd()
autocmd MyAutoCmd BufEnter * if !exists('t:cwd') | call InitTabpageCd() | endif
function! InitTabpageCd()
    if !s:on_init()
        if @% != ''
            let curdir = input('Current directory: ', expand("%:p:h"), 'file')
            silent! cd `=fnameescape(curdir)`
        else
            cd ~
        endif
    endif
    let t:cwd = getcwd()
endfunction

" Column width indicator
set textwidth=80
set colorcolumn=81
set conceallevel=2
set concealcursor=iv

func! EnterIndent()
  let EnterIndentActive = [
        \ {'left' : '[\{\[\(]','right' : '[\)\]\}]'},
        \ {'left' : '<[^>]*>', 'right' : '</[^>]*>'},
        \ {'left' : '<?\(php\)\?', 'right' : '?>'},
        \ {'left' : '<%', 'right' : '%>'},
        \ {'left' : '\[[^\]]*\]', 'right' : '\[/[^\]]*\]'},
        \ {'left' : '<!--', 'right' : '-->'},
        \ {'left' : '\(#\)\?{[^\}]*\}', 'right' : '\(#\)\?{[^\}]*\}'},
        \ ]

  let GetLine = getline('.')
  let ColNow = col('.') - 1

  let RightGetLine = substitute(
        \ strpart(GetLine, ColNow, col('$')),
        \ '^[ ]*', '', ''
        \ )

  if RightGetLine == "" | call feedkeys("\<CR>", 'n') | return '' | endif

  for value in EnterIndentActive
    if matchstr(RightGetLine, '^' . value.right) != ""
      let EnterIndentRun = 1 | break
    endif
  endfor

  if !exists('EnterIndentRun') | call feedkeys("\<CR>", 'n') | return '' | endif

  let LeftGetLine = substitute(
        \ strpart(GetLine, 0, ColNow),
        \ '[ ]*$', '', ''
        \ )

  if matchstr(LeftGetLine, value.left . '$') == ""
    call feedkeys("\<CR>", 'n') | return ''
  endif

  let LineNow = line('.')
  let Indent = substitute(LeftGetLine, '^\([ |\t]*\).*$', '\1', '')

  call setline(LineNow, LeftGetLine)
  call append(LineNow, Indent . RightGetLine)
  call append(LineNow, Indent)
  call feedkeys("\<Down>\<Esc>\A\<Tab>", 'n')

  return ''
endf
inoremap <silent> <CR> <c-r>=EnterIndent()<cr>
" }}

" List {{
" Changes what Vim displays for special chars like trailing space & tabs
set list
let &listchars = "tab:>-,trail:\u2591,extends:>,precedes:<,nbsp:\u00b7"

" Vertical splits
set fillchars+=vert:│
" }}

" Wrap {{
set nowrap         " don't wrap lines
set nojoinspaces   " don't add two spaces after ., ?, !

" Some file types should wrap their text
function! WrapToggle()
    if (&wrap == 1)
        set nowrap
    else
        set wrap linebreak nolist
        set showbreak=...
        set formatoptions+=jmM
    endif
endfunction
nnoremap <silent> <Leader>w :call WrapToggle()<CR>
" }}

" Fold {{
set nofoldenable
set foldmethod=indent
set foldcolumn=1

function! NeatFoldText()
  let line = ' ' . substitute(getline(v:foldstart), '^\s*"\?\s*\|\s*"\?\s*{{' . '{\d*\s*', '', 'g') . ' '
  let lines_count = v:foldend - v:foldstart + 1
  let lines_count_text = '| ' . printf("%10s", lines_count . ' lines') . ' |'
  let foldchar = matchstr(&fillchars, 'fold:\zs.')
  let foldtextstart = strpart('+' . repeat(foldchar, v:foldlevel*2) . line, 0, (winwidth(0)*2)/3)
  let foldtextend = lines_count_text . repeat(foldchar, 8)
  let foldtextlength = strlen(substitute(foldtextstart . foldtextend, '.', 'x', 'g')) + &foldcolumn
  return foldtextstart . repeat(foldchar, winwidth(0)-foldtextlength) . foldtextend
endfunction
set foldtext=NeatFoldText()

" Toggle folds.
nnoremap \ za
vnoremap \ za

" Make zO recursively open whatever top level fold we're in, no matter where the
" cursor happens to be.
nnoremap zO zCzO
" }}

" Extra whitespace
augroup MyAutoCmd
  " Deletes all trailing whitespace on save.
  au BufWritePre * :%s/\s\+$//e
augroup END

" Cursorline
augroup MyAutoCmd
  " Turn on cursorline only on active window
  au WinLeave * setlocal nocursorline
  au WinEnter,BufRead * setlocal cursorline
augroup END

" Max columns for syntax search
" Such XML file has too much syntax which make vim drastically slow
set synmaxcol=200
" }}}

" Search {{{
" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
set hlsearch        " highlight search
set incsearch       " searching for highlight
set ignorecase      " make searches case-insensitive
set infercase       " case inferred by default
set smartcase       " unless they contain upper-case letters
set wrapscan        " Searches wrap around the end of the file

set gdefault        " use global matching by default in regexes (override adding a /g back)
set showmatch       " show matching brackets
set matchtime=3     " how many tenths of a second to blink
set magic
set regexpengine=1

" Range search
vnoremap <silent>/ :<C-u>call <SID>RangeSearch('/')<CR>
vnoremap <silent>? :<C-u>call <SID>RangeSearch('?')<CR>
function! s:RangeSearch(d)
    let s = input(a:d)
    if strlen(s) > 0
        let s = a:d . '\%V' . s . "\<CR>"
        call feedkeys(s, 'n')
    endif
endfunction

" do not move the cursor when highlighting
nnoremap * *Nzz
nnoremap # #Nzz

" redraw window so search terms are centered
nnoremap n nzzzv
nnoremap N Nzzzv

" cancel search highlighting
noremap <silent> <Leader>/ :noh<CR>:call clearmatches()<cr>

" Search
cnoremap <expr> / getcmdtype() == '/' ? '\/' : '/'
cnoremap <expr> ? getcmdtype() == '?' ? '\?' : '?
" }}}

" Completion {{{
" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
set wildmenu                " turn on wild command line completion (for :e)
set wildmode=longest,full   " Bash tab style completion is awesome
set showcmd                 " display partially-typed commands

" Ignore these filenames during enhanced command line completion
set wildignore+=*.DS_Store                  " OSX bullshit
set wildignore+=*.aux,*.out,*.toc           " LaTeX intermediate files
set wildignore+=*.jpe?g,*.bmp,*.gif,*.png   " binary images
set wildignore+=*.o,*.obj                   " compiled object files
set wildignore+=*.py[co]                    " Python byte code
set wildignore+=*.bak,*.?~,*.??~,*.???~,*.~ " Backup files
set wildignore+=*.git,.hg,.svn              " Version control
set wildignore+=*.stats                     " Pylint stats

" only complete to the longest unambiguous match, and show a menu
set complete=.,w,b,k,t,i
set completeopt=longest,menuone,preview
set omnifunc=syntaxcomplete#Complete
" }}}

" Moving {{{
" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
set virtualedit+=block
set whichwrap=b,s,h,l,~,<,>,[,]

" Scroll
set scrolloff=3
set sidescrolloff=10
set sidescroll=1

" prevent jumping over wrapped lines
nnoremap j gj
nnoremap k gk

" Faster Esc
" inoremap jk <esc>

" Move around {{
nnoremap J mzJ`z

" Bach like (Emacs bindings)
inoremap <C-a> <Home>
inoremap <C-e> <End>
inoremap <C-b> <Left>
inoremap <C-f> <Right>
inoremap <C-d> <Del>
inoremap <C-h> <BS>

" Command line (Emacs bindings)
cnoremap <C-a> <Home>
cnoremap <C-e> <End>
cnoremap <C-b> <Left>
cnoremap <C-f> <Right>
cnoremap <C-d> <Del>
cnoremap <C-h> <BS>

" Windows
noremap <C-j> <C-w>j
noremap <C-k> <C-w>k
noremap <C-h> <C-w>h
noremap <C-l> <C-w>l

" Zoom in and out of current window with ,,
nnoremap <Leader>, <C-w>o

" Create window splits easier
" nnoremap <silent> vv <C-w>v
" nnoremap <silent> ss <C-w>s

" Fix vertsplit window sizing
nmap <D-Left> <C-W>><C-W>>
nmap <D-Right> <C-W><<C-W><

" Moving up/down by func, unfolding current func but folding all else
noremap [[ [[zMzvz.
noremap ]] ]]zMzvz.

" Same when jumping around
nnoremap g; g;zz
nnoremap g, g,zz

" Easier linewise reselection
nnoremap gm `[v`]
vnoremap <silent>gm :<C-u>normal gm<CR>
onoremap <silent>gm :<C-u>normal gm<CR>

" Substitute
nnoremap re :OverCommandLine<CR>%s!!!<Left><Left>
xnoremap :s :OverCommandLine<CR>s!!!<Left><Left>
xnoremap re "zy:OverCommandLine<CR>%s!<C-R>=substitute(@z, '!', '\\!', 'g')<CR>!!gI<Left><Left><Left>
" }}

augroup MyAutoCmd
  " jump to last cursor position when opening a file
  " except when writing a svn/git commit log entry
  au BufReadPost * if &filetype !~ '^git\c' && line("'\"") > 0 && line("'\"") <= line("$")
              \| exe 'normal! g`"zvzz' | endif
augroup END
" }}}

" GUI {{{
" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Status bar
set laststatus=2

" Color theme
" colorscheme seoul256
colorscheme gruvbox
set background=dark
let g:gruvbox_contrast_dark='soft'

if has("gui_running") " GUI color and font settings
  set guioptions=c         " use console dialogs
  set guicursor=a:blinkon0 " disable cursor blink

  " Transparency
  set transparency=5

  " Full screen (MacVim)
  set fuoptions=maxvert,maxhorz

  " Font config
  set guifont=Mensch:h12
  " set guifont=Fantasque\ Sans\ Mono:h14

  " Show tab number (useful for Cmd-1, Cmd-2.. mapping)
  " For some reason this doesn't work as a regular set command,
  " (the numbers don't show up) so I made it a VimEnter event
  autocmd VimEnter * set guitablabel=%N:\ %t\ %M
else
  " Explicitly tell vim that the terminal has 256 colors
  set t_Co=256
endif
" }}}

" Abbreviations {{{
" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
iab imail   arthurtemptation@gmail.com
iab iauthor Arcthur Chen
iab xdate <c-r>=strftime("%Y/%m/%d %H:%M:%S")<CR>
" }}}

" Key Mappings {{{
" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Swap ' and ` keys (` is much more useful)
noremap ` '
noremap ' `

" General vim sanity improvements {{

" Allow undo for Insert Mode ^u (thanks, osse!) - see: :help i_CTRL-G_u
inoremap <C-u> <C-g>u<C-u>

" match it region
nmap <tab> %
vmap <tab> %
" }}

" Shortcuts for everyday tasks {{
" format the entire file
" nnoremap <Leader>fe ggVG=

" CmdLine
cnoremap $h e ~/
cnoremap $w e ~/Work
cnoremap $g e ~/Gitlab
cnoremap $c e <C-\>CurrentFileDir("e")<CR>
func! CurrentFileDir(cmd)
  return a:cmd . " " . expand("%:p:h") . "/"
endf

" upper/lower word
nnoremap <Leader>u viwU
nnoremap <Leader>l viwu

" upper/lower first char of word
nnoremap <Leader>U gewvU
nnoremap <Leader>L gewvu

" Column scroll-binding
noremap <silent> <Leader>sb :<C-u>let @z=&so<CR>:set so=0 noscb<cr>:bo vs<cr>Ljzt:setl scb<cr><C-w>p:setl scb<cr>:let &so=@z<cr>

" Swap two words
noremap <silent> gw :s/\(\%#\w\+\)\(\_W\+\)\(\w\+\)/\3\2\1/<CR>`'

" Delete trailing whitespaces {{{
" noremap <silent><Leader>tw :let _s=@/<Bar>:%s/\s\+$//e<Bar>:let @/=_s<Bar>:nohl<CR>

" Sudo write
command! -bar -nargs=0 W  silent! exec 'w !security execute-with-privileges /usr/bin/tee % > /dev/null'  | silent! edit!

" Write and make file executable
command! -bar -nargs=0 WX silent! exec "write !chmod a+x % >/dev/null" | silent! edit!

" Rename current file
command! -nargs=1 -complete=file Rename call rename(expand('%'), '<args>') | e <args>
" }}
" }}}

" Programming {{{
" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Help
augroup ft_help
  au!

  " Help file settings
  function! s:SetupHelpWindow()
    wincmd L
    vertical resize 80
    setl nonumber winfixwidth

    nnoremap <buffer> <SPACE> <C-]> " Space selects subject
    nnoremap <buffer> <BS>    <C-T> " Backspace to go back
  endfunction

  au FileType help au BufEnter,BufWinEnter <buffer> call <SID>SetupHelpWindow()
augroup END

" Vim
augroup ft_vim
  au!

  au BufLeave * if expand('%') !=# '' && &buftype ==# ''
    \ | mkview
    \ | endif
  au BufReadPost * if !exists('b:view_loaded') &&
    \ expand('%') !=# '' && &buftype ==# ''
    \ | silent! loadview
    \ | let b:view_loaded = 1
    \ | endif
  au VimLeave * call map(split(glob(&viewdir . '/*'), "\n"),  'delete(v:val)')

  " treat lines starting with a quote mark as comments (for `Vim' files, such as
  " this very one!), and colons as well so that reformatting usenet messages from
  " `Tin' users works OK:
  au FileType vim setlocal comments+=b:\"
  au FileType vim setlocal comments+=n::
augroup END

" Ruby
augroup ft_ruby
  au!

  au Filetype ruby setlocal foldmethod=syntax
  au Filetype ruby setlocal shiftwidth=2
  au Filetype ruby setlocal softtabstop=2

  " Thorfile, Rakefile, Vagrantfile and Gemfile are Ruby
  au BufRead,BufNewFile {Gemfile,Rakefile,Vagrantfile,Thorfile,Procfile,config.ru,*.rake} set ft=ruby
augroup END

" Markdown
augroup ft_markdown
  au!

  if s:dein_enabled && dein#tap("vim-markdown")
    let g:vim_markdown_math = 1
    let g:vim_markdown_frontmatter = 1
  endif

  au BufRead,BufNewFile *.{md,markdown,mdown,mkd,mkdn} setlocal filetype=markdown
augroup END

" Javascript
augroup ft_javascript
  au!

  au BufNewFile,BufRead *.json set ft=javascript
  let g:jsx_ext_required = 0
augroup END

" HTML
augroup ft_html
  au!

  au BufNewFile,BufRead *.html setlocal filetype=html
  au FileType html setlocal foldmethod=manual

  " Use <localleader>f to fold the current tag.
  au FileType html nnoremap <buffer> <localleader>f Vatzf
augroup END

" CSS
augroup ft_css
  au!

  au Filetype less,css setlocal omnifunc=csscomplete#CompleteCSS
  au Filetype less,css setlocal iskeyword+=-
  au BufNewFile,BufRead *.less,*.css nnoremap <buffer> <Leader>S ?{<CR>jV/\v^\s*\}?$<CR>k:sort<CR>:noh<CR>
augroup END
" }}}

" Surround {{{
" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
nmap cs  <Plug>Csurround
nmap ds  <Plug>Dsurround
nmap ySS <Plug>YSsurround
nmap ySs <Plug>YSsurround
nmap ys  <Plug>Ysurround
nmap yss <Plug>Yssurround

xmap S   <Plug>VSurround
xmap gS  <Plug>VgSurround
xmap s   <Plug>VSurround
" }}}

" TagBar {{{
" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
if s:dein_enabled && dein#tap("tagbar")
  nnoremap <F6> :<C-u>TagbarToggle<CR>
  inoremap <F6> <esc>:TagbarToggle<CR>

  let g:tagbar_ctags_bin   = g:my.bin.ctags
  let g:tagbar_compact     = 1 " Remove empty lines by default
  let g:tagbar_autofocus   = 1
  let g:tagbar_autoshowtag = 1
  let g:tagbar_iconchars   = ['▸', '▾']
  let g:tagbar_type_html = {
      \ 'ctagstype' : 'html',
      \ 'kinds' : [
      \ 'h:Headers',
      \ 'o:Objects(ID)',
      \ 'c:Classes'
      \ ]
      \ }

  let g:tagbar_type_css = {
      \ 'ctagstype' : 'css',
      \ 'kinds' : [
      \ 't:Tags(Elements)',
      \ 'o:Objects(ID)',
      \ 'c:Classes'
      \ ]
      \ }

  let g:tagbar_type_vimwiki = {
      \ 'ctagstype' : 'wiki',
      \ 'kinds' : [
      \ 'h:Headers'
      \ ]
      \ }

  let g:tagbar_type_ruby = {
      \ 'kinds' : [
      \ 'm:modules',
      \ 'c:classes',
      \ 'd:describes',
      \ 'C:contexts',
      \ 'f:methods',
      \ 'F:singleton methods'
      \ ]
      \ }

  let g:tagbar_type_tex = {
      \ 'ctagstype' : 'latex',
      \ 'kinds'     : [
      \ 's:sections',
      \ 'g:graphics',
      \ 'l:labels',
      \ 'r:refs:1',
      \ 'p:pagerefs:1'
      \ ],
      \ 'sort'    : 0,
      \ 'deffile' : expand('<sfile>:p:h:h') . '/ctags/latex.cnf'
      \ }

  let g:tagbar_type_go = {
      \ 'ctagstype' : 'go',
      \ 'kinds'     : [  'p:package', 'i:imports:1', 'c:constants', 'v:variables',
      \ 't:types',  'n:interfaces', 'w:fields', 'e:embedded', 'm:methods',
      \ 'r:constructor', 'f:functions' ],
      \ 'sro' : '.',
      \ 'kind2scope' : { 't' : 'ctype', 'n' : 'ntype' },
      \ 'scope2kind' : { 'ctype' : 't', 'ntype' : 'n' },
      \ 'ctagsbin'  : 'gotags',
      \ 'ctagsargs' : '-sort -silent'
      \ }
endif
" }}}

" Sneak {{{
" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
if s:dein_enabled && dein#tap("vim-sneak")
  let g:sneak#streak = 1

  "replace 'f' with inclusive 1-char Sneak
  nmap f <Plug>Sneak_f
  nmap F <Plug>Sneak_F
  xmap f <Plug>Sneak_f
  xmap F <Plug>Sneak_F
  omap f <Plug>Sneak_f
  omap F <Plug>Sneak_F
  "replace 't' with exclusive 1-char Sneak
  nmap t <Plug>Sneak_t
  nmap T <Plug>Sneak_T
  xmap t <Plug>Sneak_t
  xmap T <Plug>Sneak_T
  omap t <Plug>Sneak_t
  omap T <Plug>Sneak_T
endif
" }}}

" Git {{{
" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
nnoremap [git]     <Nop>
nmap     <Leader>g  [git]

" Git {{
if s:dein_enabled && dein#tap("git-vim")
  nnoremap [git]A :<C-u>GitAdd<SPACE>
  nnoremap [git]a :<C-u>GitAdd<CR>
  nnoremap [git]d :<C-u>GitDiff --no-prefix<CR>
  nnoremap [git]D :<C-u>GitDiff --no-prefix --cached<CR>
  nnoremap [git]p :<C-u>Git push<SPACE>
  nnoremap [git]r :<C-u>GitPullRebase<CR>
  nnoremap [git]f :<C-u>GitCatFile %<CR>

  let g:git_no_default_mappings = 1
  let g:git_bin                 = g:my.bin.git
  let g:git_command_edit        = 'vnew'

  autocmd FileType git set nofoldenable
endif
" }}

" Fugitive {{
if s:dein_enabled && dein#tap("vim-fugitive")
  nnoremap <silent> [git]c :Gcommit<CR>
  nnoremap <silent> [git]C :Gcommit --amend<CR>
  nnoremap <silent> [git]s :<C-U>Gstatus<CR>
  nnoremap <silent> [git]b :Gblame<CR>
  nnoremap <silent> [git]B :Gbrowse<CR>

  augroup MyGitCmd
    autocmd!
    autocmd FileType fugitiveblame vertical res 25
    autocmd FileType gitcommit,git-diff nnoremap <buffer>q :q<CR>
  augroup END

  let g:fugitive_git_executable = g:my.bin.git
endif
" }}

" Gist {{
" Send visual selection to gist.github.com as a private, filetyped Gist
if s:dein_enabled && dein#tap("gist-vim")
  vnoremap <silent> [git]g :w !gist -p -t %:e \| pbcopy<CR>
  vnoremap <silent> [git]G :w !gist -p \| pbcopy<CR>

  let g:gist_clip_command            = 'pbcopy'
  let g:gist_detect_filetype         = 1
  let g:gist_open_browser_after_post = 1
  let g:github_user                  = g:my.info.github
endif
" }}

" Gitv {{
if s:dein_enabled && dein#tap("gitv")
  nnoremap <silent> [git]v :Gitv --all<CR>
  nnoremap <silent> [git]V :Gitv! --all<CR>
  vnoremap <silent> [git]V :Gitv! --all<CR>

  let g:Gitv_OpenHorizontal  = 1
  let g:Gitv_WipeAllOnClose  = 1
  let g:Gitv_DoNotMapCtrlKey = 1

  autocmd FileType gitv call s:my_gitv_settings()
  function! s:my_gitv_settings()
    setlocal iskeyword+=/,-,.
    nnoremap <silent><buffer> C :<C-u>Git checkout <C-r><C-w><CR>
  endfunction
endif
" }}

" }}}

" AlE {{{
" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
if s:dein_enabled && dein#tap("ale")
  let g:ale_linters = {
    \   'sh' : ['shellcheck'],
    \   'vim' : ['vint'],
    \   'html' : ['tidy'],
    \   'python' : ['flake8'],
    \   'markdown' : ['mdl'],
    \   'javascript' : ['eslint'],
    \ }
  let g:ale_sign_error = '❌'
  let g:ale_sign_warning = '⭕'
  let g:ale_echo_msg_error_str = '✷ Error'
  let g:ale_echo_msg_warning_str = '⚠ Warning'
  let g:ale_echo_msg_format = '[#%linter%#] %s [%severity%]'
  let g:ale_statusline_format = ['⨉ %d', '⚠ %d', '⬥ ok']
endif
" }}}

" Rooter {{{
" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
if s:dein_enabled && dein#tap("vim-rooter")
  let g:rooter_use_lcd = 1
  let g:rooter_manual_only = 1

  augroup movecurrentdir
    autocmd!
    autocmd BufRead,BufEnter * call MoveRootDirOrCurrentFileDir()
  augroup END

  " Move project top directory with vim-rooter.
  " If can't, move current file's directory.
  function! MoveRootDirOrCurrentFileDir()
    let currentfile = expand("%:p")

    " Don't move if current file is an unnamed buffer
    if currentfile == ''
      return
    endif

    Rooter

    let cwd = getcwd()

    " Move current file's directory if could't move project top directory
    if (stridx(currentfile, cwd) != 0 ||
      \finddir('.git', cwd) == '') &&
      \isdirectory(expand('%:p:h'))
      lcd %:p:h
    endif
  endfunction
endif
" }}}

" Switch {{{
" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
if s:dein_enabled && dein#tap("switch.vim")
  nnoremap ! :Switch<CR>

  let s:switch_definition = {
        \ '_': [
        \   ['is', 'are'],
        \   { '\Cenable': '\Cdisable' },
        \   { '\CEnable': '\CDisable' },
        \   { '\Ctrue': 'false' },
        \   { '\CTrue': 'False' },
        \   { '\Cfalse': 'true' },
        \   { '\CFalse': 'True' },
        \   { '（\([^）]\+\)）' : '(\1)' },
        \ ],
        \ 'sass,scss,css' : [
        \   ['solid', 'dotted'],
        \   ['left', 'right']
        \ ],
        \ 'ruby,eruby,haml' : [
        \   ['if', 'unless'],
        \   ['while', 'until'],
        \   ['.blank?', '.present?'],
        \   ['include', 'extend'],
        \   ['class', 'module'],
        \   ['.inject', '.delete_if'],
        \   ['.map', '.map!'],
        \   ['attr_accessor', 'attr_reader', 'attr_writer'],
        \   { '%r\({[^}]\+\)}' : '/\1/' },
        \   { ':\(\k\+\)\s*=>\s*': '\1: ' },
        \   { '\<\(\k\+\): ':      ':\1 => ' },
        \   { '\.\%(tap\)\@!\(\k\+\)':   '.tap { |o| puts o.inspect }.\1' },
        \   { '\.tap { |o| \%(.\{-}\) }': '' },
        \   { '\(\k\+\)(&:\(\S\+\))': '\1 { |x| x\.\2 }' },
        \   { '\(\k\+\)\s\={ |\(\k\+\)| \2.\(\S\+\) }': '\1(&:\3)' }
        \ ],
        \ 'Gemfile,Berksfile' : [
        \   ['=', '<', '<=', '>', '>=', '~>']
        \ ],
        \ 'ruby.application_template' : [
        \   ['yes?', 'no?'],
        \   ['lib', 'initializer', 'file', 'vendor', 'rakefile'],
        \   ['controller', 'model', 'view', 'migration', 'scaffold']
        \ ],
        \ 'html,php' : [
        \   { '<!--\([a-zA-Z0-9 /]\+\)--></\(div\|ul\|li\|a\)>' : '</\2><!--\1-->' }
        \ ],
        \ 'apache': [
        \   ['None', 'All']
        \ ],
        \ 'c' : [
        \   ['signed', 'unsigned']
        \ ],
        \ 'css,scss,sass': [
        \   ['collapse', 'separate'],
        \   ['margin', 'padding']
        \ ],
        \ 'gitrebase' : [
        \   ['pick', 'reword', 'edit', 'squash', 'fixup', 'exec'],
        \   ['^p\s', 'pick '],
        \   ['^r\s', 'reword '],
        \   ['^e', 'edit '],
        \   ['^s', 'squash '],
        \   ['^f', 'fixup '],
        \   ['^e', 'exec ']
        \ ],
        \ 'rspec': [
        \   ['describe', 'context', 'specific', 'example'],
        \   ['before', 'after'],
        \   ['be_true', 'be_false'],
        \   ['get', 'post', 'put', 'delete'],
        \   ['==', 'eql', 'equal'],
        \   { '\.should_not': '\.should' },
        \   ['\.to_not', '\.to'],
        \   { '\([^. ]\+\)\.should\(_not\|\)': 'expect(\1)\.to\2' },
        \   { 'expect(\([^. ]\+\))\.to\(_not\|\)': '\1.should\2' }
        \ ],
        \ 'vim' : [
        \   { '\vhttps{,1}://github.com/([^/]+)/([^/]+)(\.git){,1}': '\1/\2' },
        \   ['call', 'return'],
        \   { 'let\s\+\([gstb]:\a\+\|\a\+\)\s*\(.\|+\|-\|*\|\\\)\{,1}=\s*\(\a\+\)\s*.*$' : 'unlet \1' },
        \   ['echo', 'echomsg'],
        \   ['if', 'elseif']
        \ ],
        \ 'markdown' : [
        \   ['[ ]', '[x]'],
        \   ['#', '##', '###', '####', '#####'],
        \   { '\(\*\*\|__\)\(.*\)\1': '_\2_' },
        \   { '\(\*\|_\)\(.*\)\1': '__\2__' }
        \ ]}

  function! s:separate_defenition_to_each_filetypes(ft_dictionary)
    let result = {}

    for [filetypes, value] in items(a:ft_dictionary)
      for ft in split(filetypes, ",")
        if !has_key(result, ft)
          let result[ft] = []
        endif

        call extend(result[ft], copy(value))
      endfor
    endfor

    return result
  endfunction

  let s:switch_definition = s:separate_defenition_to_each_filetypes(s:switch_definition)

  function! s:define_switch_mappings()
    if exists('b:switch_custom_definitions')
      unlet b:switch_custom_definitions
    endif

    let dictionary = []
    for filetype in split(&ft, '\.')
      if has_key(s:switch_definition, filetype)
        let dictionary = extend(dictionary, s:switch_definition[filetype])
      endif
    endfor

    if has_key(s:switch_definition, '_')
      let dictionary = extend(dictionary, s:switch_definition['_'])
    endif

    if !empty('dictionary')
      let s:gvn = 'b:switch_custom_definitions'
      if !exists(s:gvn)
        let cmd = 'let ' . s:gvn . ' = ' . string(dictionary)
        exe cmd
      endif
    endif
  endfunction

  autocmd MyAutoCmd Filetype * call <SID>define_switch_mappings()
endif
" }}}

" Unite {{{
" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
if s:dein_enabled && dein#tap("unite.vim")
  " Map space to the prefix for Unite
  nnoremap [unite] <Nop>
  xnoremap [unite] <Nop>
  nmap <SPACE> [unite]
  xmap <SPACE> [unite]

  nnoremap <silent> [unite]r :<C-u>Unite file_rec/async -buffer-name=file_rec/async<CR>
  nnoremap <silent> [unite]b :<C-u>Unite buffer -buffer-name=buffer<CR>
  nnoremap <silent> [unite]B :<C-u>Unite bookmark -buffer-name=bookmark<CR>
  nnoremap <silent> [unite]f :<C-u>Unite file_mru -buffer-name=file_mru<CR>
  nnoremap <silent> [unite]c :<C-u>Unite command -buffer-name=command<CR>
  nnoremap <silent> [unite]d :<C-u>Unite directory_mru -default-action=lcd -buffer-name=directory_mru<CR>
  nnoremap <silent> [unite], :<C-u>Unite grep -buffer-name=grep -no-quit -auto-preview<CR>
  "nnoremap <silent> [unite]m :<C-u>Unite mapping -buffer-name=mapping<CR>

  if dein#tap("neomru.vim")
    nnoremap <silent> [unite]<SPACE> :<C-u>Unite buffer file_mru bookmark file_rec/async<CR>
    nnoremap <silent> [unite]m :Unite file_mru<CR>
  endif

  if dein#tap("neosnipet")
    nnoremap <silent> [unite]pt :<C-u>Unite snippet -buffer-name=snippet<CR>
  endif

  if dein#tap("unite-mark")
    nnoremap <silent> [unite]M :<C-u>Unite mark -buffer-name=snippet<CR>
  endif

  if dein#tap("neoyank.vim")
    nnoremap <silent> [unite]/ :<C-u>Unite history/search -buffer-name=history_search -no-empty<CR>
    nnoremap <silent> [unite]: :<C-u>Unite history/command -buffer-name=history_command -no-empty<CR>
    nnoremap <silent> [unite]y :<C-u>Unite history/yank -buffer-name=history_yank -no-empty<CR>
  endif

  if dein#tap("unite-session")
    nnoremap <silent> [unite]s :<C-u>Unite session -buffer-name=session -no-empty<CR>
  endif

  if dein#tap("unite-help")
    nnoremap <silent> [unite]h :<C-u>Unite help -buffer-name=help<CR>
  endif

  if dein#tap("unite-outline")
    nnoremap <silent> [unite]o :<C-u>Unite outline -vertical -winwidth=40 -buffer-name=outline<CR>
  endif

  if dein#tap("unite-quickfix")
    nnoremap <silent> [unite]q :<C-u>Unite quickfix -buffer-name=quickfix<CR>
  endif

  if dein#tap("vim-unite-giti")
    nnoremap <silent> [unite]gb :<C-u>Unite giti/branch_all -buffer-name=giti_branchall -no-start-insert<CR>
    nnoremap <silent> [unite]gP :<C-u>Unite giti/pull_request/base -buffer-name=giti_pull_request -no-start-insert -horizontal<CR>
    nnoremap <silent> [unite]gl :<C-u>Unite giti/log -buffer-name=giti_log -no-start-insert -horizontal<CR>
    nnoremap <silent> [unite]gs :<C-u>Unite giti/status -buffer-name=giti_status -no-start-insert -horizontal<CR>
  endif

  if dein#tap("unite-tag")
    nnoremap <silent> [unite]t :<C-u>Unite tags -horizontal -buffer-name=tags -input='.expand("<cword>").'<CR>
  endif

  function! s:unite_git_root(...)
    let git_root = s:current_git()
    let path = empty(a:000) ? '' : a:1
    let absolute_path = s:complement_delimiter_of_directory(git_root) . path

    if isdirectory(absolute_path)
      execute 'Unite -buffer-name=file file_rec/async:'.absolute_path
      lcd `=absolute_path`
      file `='*unite* - ' . path`
    elseif filereadable(absolute_path)
      edit `=absolute_path`
    else
      echomsg path . ' is not exists!'
    endif
  endfunction

  function! s:unite_git_complete(arg_lead, cmd_line, cursor_pos)
    let git_root = s:complement_delimiter_of_directory(s:current_git())
    let files = globpath(git_root, a:arg_lead . '*')
    let file_list = split(files, '\n')
    let file_list = map(file_list, 's:complement_delimiter_of_directory(v:val)')
    let file_list = map(file_list, "substitute(v:val, git_root, '', 'g')")

    return file_list
  endfunction
  command! -nargs=? -complete=customlist,s:unite_git_complete UniteGit call <SID>unite_git_root(<f-args>)

  nnoremap <silent> [unite]<C-f> :UniteGit<CR>

  function! s:unite_with_same_syntax(cmd)
    let old_syntax = &syntax

    execute a:cmd

    if !empty(old_syntax)
      execute 'setl syntax=' . old_syntax
    endif
  endfunction

  nnoremap <silent>g/ :call <SID>unite_with_same_syntax('Unite -buffer-name=line_fast -hide-source-names -horizontal -no-empty -start-insert -no-quit line')<CR>
  nnoremap <silent>g* :call <SID>unite_with_same_syntax('Unite -buffer-name=line_fast -hide-source-names -horizontal -no-empty -start-insert -no-quit line -input=<C-R><C-W>')<CR>

  " Use the fuzzy matcher for everything
  call unite#filters#matcher_default#use(['matcher_fuzzy'])

  " Use the rank sorter for everything
  call unite#filters#sorter_default#use(['sorter_rank'])

  " Set up some custom ignores
  call unite#custom#source('file_mru,file_rec,file_rec/async,grep,locate',
    \ 'ignore_pattern', join([
    \ 'node_modules/',
    \ 'bower_components/',
    \ '.sass-cache',
    \ 'vendor/',
    \ '\.git/',
    \ '\.svn/',
    \ 'tmp/',
    \ 'bundle/'
    \ ], '\|'))

  let g:unite_enable_start_insert        = 0
  let g:unite_prompt                     = '>>> '
  let g:unite_update_time                = 200
  let g:unite_winheight                  = 15
  let g:unite_split_rule                 = 'botright'
  let g:unite_marked_icon                = '✓'
  " let g:unite_force_overwrite_statusline = 0
  let g:unite_data_directory             = g:my.dir.unite
  let g:unite_cursor_line_highlight      = 'UniteCursorLine'

  let g:unite_source_buffer_time_format        = '(%d-%m-%Y %H:%M:%S) '
  let g:unite_source_file_mru_time_format      = '(%d-%m-%Y %H:%M:%S) '
  let g:unite_source_file_mru_limit            = 1000
  let g:unite_source_directory_mru_time_format = '(%d-%m-%Y %H:%M:%S) '

  let g:unite_source_history_yank_enable       = 1
  let g:unite_source_history_yank_limit        = 100

  call unite#custom_source('file_rec', 'max_candidates', 5000)
  call unite#custom_source('file_rec/async', 'max_candidates', 5000)
  call unite#custom_source('giti/branch_all', 'max_candidates', 5000)
  call unite#custom_source('giti/log', 'max_candidates', 5000)
  call unite#custom_source('line', 'max_candidates', 5000)
  call unite#custom_source('line/fast', 'max_candidates', 5000)
  call unite#custom_source('tag', 'max_candidates', 5000)
  call unite#custom_source('tags', 'max_candidates', 5000)

  let g:giti_git_command = executable('hub') ? 'hub' : 'git'
  let g:giti_log_default_line_count = 500

  function! s:extend_file_rec_source() "{{{
    if exists('g:loaded_extend_file_rec_source')
      return
    endif
    let g:loaded_extend_file_rec_source = 1

    let filter_name = 'pre_filter'
    let pre_filter = { 'name' : filter_name }

    function! pre_filter.filter(candidates, context)
      let candidates = a:candidates
      if has_key(a:context, 'source__prefilters')
            \ && has_key(a:context, 'source__absolute_path') && has_key(a:context, 'source__project_root_path')
        let prefilters = a:context.source__prefilters

        let reg_multi =  '\*\*/'
        let reg_bad_pattern =  '\v(\*\*[^/])'
        let reg_single = '[^/*]\{,1}\*[^*]'

        for input in prefilters
          if input =~ reg_bad_pattern
            next
          elseif input =~ reg_multi
            " echo 'multi'
            let input = substitute(input, '.*/\([^/]\+\)$', '\1', 'g')
            let single = 1
          elseif input =~ reg_single
            " echo 'single'
            " let input = input
          else
            " echo 'non'
          endif

          if input =~ '\\\@<![*|]'
            let input = substitute(unite#util#escape_match(input), '\\\@<!|', '\\|', 'g')
            let expr = 'v:val.word =~ ' . string(input)
          else
            let input = substitute(input, '\\\(.\)', '\1', 'g')
            let expr = &ignorecase ?
                  \ printf('stridx(tolower(v:val.word), %s) != -1',
                  \     string(tolower(input))) :
                  \ printf('stridx(v:val.word, %s) != -1',
                  \     string(input))
          endif

          if exists('single')
            let input = '^' . single
          endif

          " let candidates = unite#filters#matcher_glob#glob_matcher(candidates, input, a:context)
          let candidates = unite#filters#filter_matcher(candidates, expr, a:context)
        endfor
      endif

      return candidates
    endfunction

    call unite#define_filter(pre_filter)
    let file_rec_filters = ['matcher_default', 'sorter_default', 'matcher_hide_hidden_files' , 'converter_relative_word']

    let file_filters = [ 'matcher_default', 'matcher_hide_hidden_files' ]
  endfunction
  call s:extend_file_rec_source()

  " Custom mappings for the unite buffer
  autocmd MyAutoCmd FileType unite call <SID>unite_settings()

  function! s:unite_settings()
    augroup MyUniteBufferCmd
      autocmd!
      autocmd! * <buffer>
      autocmd BufEnter <buffer> if winnr('$') == 1 |quit| endif
    augroup END

    setl nolist
    highlight link uniteMarkedLine Identifier
    highlight link uniteCandidateInputKeyword Statement

    nmap <silent><buffer><ESC> <Plug>(unite_exit)
    nmap <silent><buffer><C-c> <Plug>(unite_exit)
    imap <silent><buffer><C-j> <Plug>(unite_select_next_line)
    imap <silent><buffer><C-k> <Plug>(unite_select_previous_line)
    imap <silent><buffer>jk    <Plug>(unite_insert_leave)

    nmap <silent><buffer>f <Plug>(unite_toggle_mark_current_candidate)
    xmap <silent><buffer>f <Plug>(unite_toggle_mark_selected_candidates)
    nmap <silent><buffer><C-H> <Plug>(unite_toggle_transpose_window)
    nmap <silent><buffer>p <Plug>(unite_toggle_auto_preview)
    nnoremap <silent><buffer><expr>S unite#do_action('split')
    nnoremap <silent><buffer><expr>V unite#do_action('vsplit')
    nnoremap <silent><buffer><expr>,, unite#do_action('vimfiler')
    nnoremap <silent><buffer>C gg0wC
    nnoremap <silent><buffer><expr>re unite#do_action('replace')
    nnoremap <silent><buffer><expr> cd unite#do_action('lcd')

    for source in unite#get_current_unite().sources
      let source_name = substitute(source.name, '[-/]', '_', 'g')
      if !empty(source_name) && has_key(s:unite_hooks, source_name)
        call s:unite_hooks[source_name]()
      endif
    endfor
  endfunction

  " Hooks
  let s:unite_hooks = {}
  function! s:unite_hooks.file_mru()
    syntax match uniteSource__FileMru_Dir /.*\// containedin=uniteSource__FileMru contains=uniteSource__FileMru_Time,uniteCandidateInputKeyword nextgroup=uniteSource__FileMru_Dir

    highlight link uniteSource__FileMru_Dir Directory
    highlight link uniteSource__FileMru_Time Comment
    call unite#custom#source('file_mru', 'ignore_pattern', '')
  endfunction

  function! s:unite_hooks.file()
    nmap <buffer><Tab> <Plug>(unite_do_default_action)
    syntax match uniteFileDirectory '.*\/'
    highlight link uniteFileDirectory Directory
  endfunction

  function! s:unite_hooks.source_line()
    function! s:toggle_syntax()
      let syntax = empty(&syntax) ? b:original_syntax : ''
      let &syntax = syntax
      echomsg 'Current syntax is ' . syntax
    endfunction

    nnoremap <buffer><C-K> :call <SID>toggle_syntax()<CR>
    inoremap <buffer><C-K> <ESC>:call <SID>toggle_syntax()<CR>
  endfunction

  function! s:unite_hooks.history_command()
    setl syntax=vim
  endfunction

  " grep {{
  let g:unite_source_grep_max_candidates = 1000
  let g:unite_source_grep_command = 'ag'
  let g:unite_source_grep_default_opts =
        \ '-i --vimgrep --hidden --ignore ' .
        \  '''.hg'' --ignore ''.svn'' --ignore ''.git'' --ignore ''.bzr'''
  let g:unite_source_grep_recursive_opt = ''
  let g:unite_source_grep_search_word_highlight = 1

  function! s:unite_hooks.grep()
    nnoremap <expr><buffer>re unite#do_action('replace')
  endfunction
  " }}

  function! s:unite_hooks.outline()
    nnoremap <buffer><C-J> gj
  endfunction

  " vim-unite-giti
  function! s:unite_hooks.giti_status()
    nnoremap <silent><buffer><expr>gM unite#do_action('ammend')
    nnoremap <silent><buffer><expr>gm unite#do_action('commit')
    nnoremap <silent><buffer><expr>ga unite#do_action('stage')
    nnoremap <silent><buffer><expr>gc unite#do_action('checkout')
    nnoremap <silent><buffer><expr>gd unite#do_action('diff')
    nnoremap <silent><buffer><expr>gu unite#do_action('unstage')
  endfunction

  function! s:unite_hooks.source_giti_branch()
    nnoremap <silent><buffer><expr>d unite#do_action('delete')
    nnoremap <silent><buffer><expr>D unite#do_action('delete_force')
    nnoremap <silent><buffer><expr>rd unite#do_action('delete_remote')
    nnoremap <silent><buffer><expr>rD unite#do_action('delete_remote_force')
  endfunction

  function! s:unite_hooks.source_giti_branch_all()
    call s:unite_hooks.source_giti_branch()
  endfunction

  function! s:unite_hooks.giti_log()
    nnoremap <silent><buffer><expr>gd unite#do_action('diff')
    nnoremap <silent><buffer><expr>d unite#do_action('diff')
  endfunction
endif

if s:dein_enabled && dein#tap("unite-session")
  " Save session automatically.
  let g:unite_source_session_enable_auto_save = 1
  let g:unite_source_session_options          = 'buffers,curdir,tabpages'
endif

if s:dein_enabled && dein#tap("neomru.vim")
  let g:neomru#file_mru_path = g:my.dir.neomru . '/file'
  let g:neomru#directory_mru_path = g:my.dir.neomru . '/directory'
endif

if s:dein_enabled && dein#tap("neoyank.vim")
  let g:neoyank#file = g:my.dir.neoyank . 'neoyank.txt'
endif
" }}}

" Startify {{{
" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
if s:dein_enabled && dein#tap("vim-startify")
  let g:startify_session_persistence = 1
  let g:startify_session_autoload    = 1
  let g:startify_change_to_dir       = 1
  let g:startify_enable_special      = 0
  let g:startify_restore_position    = 1
  let g:startify_list_order          = ['files', 'bookmarks', 'sessions', 'dir']
  let g:startify_custom_indices      = ['a','s','d','f','g','q','w','e','r','z','x','c','v']
  let g:startify_skiplist = [
              \ 'COMMIT_EDITMSG',
              \ $VIMRUNTIME .'/doc',
              \ 'bundle/.*/doc'
              \ ]

  let g:startify_bookmarks = [
              \ '~/.vim/vimrc',
              \ '~/.zshrc'
              \ ]

  let g:startify_custom_footer = [''] + map(split(system('fortune | cowsay -f tux.cow'), '\n'), '"   ". v:val') + ['','']
endif
" }}}

" NerdTree {{{
" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
if s:dein_enabled && dein#tap("nerdtree")
  nnoremap <silent> <C-\> :<C-u>NERDTreeFind<CR>

  let g:NERDTreeWinSize = 36
  let g:NERDTreeBookmarksFile = g:my.dir.nerdtree . '/NERDTreeBookmarks'
  let g:NERDTreeMinimalUI = 1
  let g:NERDTreeIndicatorMapCustom = {
    \ "Modified"  : "✹",
    \ "Staged"    : "✚",
    \ "Untracked" : "✭",
    \ "Renamed"   : "➜",
    \ "Unmerged"  : "═",
    \ "Deleted"   : "✖",
    \ "Dirty"     : "✗",
    \ "Clean"     : "✔︎",
    \ "Unknown"   : "?"
    \ }
endif
" }}}

" Vimfiler {{{
" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
if s:dein_enabled && dein#tap("vimfiler.vim")
  nnoremap [vimfiler]  <Nop>
  nmap     <Leader>f  [vimfiler]

  nnoremap <silent> [vimfiler]f :<C-u>VimFiler -buffer-name=explorer -split -simple -winwidth=35 -toggle -no-quit<CR>
  nnoremap <silent> [vimfiler]g :call <SID>vim_filer_explorer_git()<CR>
  nnoremap <silent> [vimfiler]b :<C-u>VimFilerBufferDir<CR>
  nnoremap <silent> [vimfiler]c :<C-u>VimFilerCreate<CR>

  function! s:vim_filer_explorer_git()
    let path = (system('git rev-parse --is-inside-work-tree') == "true\n") ? s:current_git() : '.'
    execute 'VimFiler -buffer-name=explorer -split -simple -winwidth=35 -toggle -no-quit -find ' path
  endfunction
  command! VimFilerExplorerGit call <SID>vim_filer_explorer_git()

  let g:unite_kind_file_use_trashbox  = 1
  let g:vimfiler_data_directory       = g:my.dir.vimfiler
  let g:vimfiler_safe_mode_by_default = 0
  let g:vimfiler_as_default_explorer  = 1
  let g:vimfiler_preview_action       = ''
  let g:vimfiler_enable_auto_cd       = 1
  let g:vimfiler_tree_leaf_icon       = ' '
  let g:vimfiler_tree_opened_icon     = '▾'
  let g:vimfiler_tree_closed_icon     = '▸'
  let g:vimfiler_file_icon            = '-'
  let g:vimfiler_marked_file_icon     = '✓'
  let g:vimfiler_readonly_file_icon   = '✗'
  let g:vimfiler_ignore_pattern       = '^\%(.git\|.DS_Store\)$'

  autocmd MyAutoCmd FileType vimfiler call <SID>vimfiler_settings()
  function! s:vimfiler_settings()
    setl nonumber norelativenumber
    nmap <buffer><space> [unite]
    nmap <buffer><CR> <Plug>(vimfiler_edit_file)
    nmap <buffer> f   <Plug>(vimfiler_toggle_mark_current_line)
    vmap <buffer> f   <Plug>(vimfiler_toggle_mark_selected_lines)
    nnoremap <buffer>b :<C-U>UniteBookmarkAdd<CR>
    nnoremap <buffer>u :<C-U>Unite file -no-start-insert -buffer-name=file<CR>
    nnoremap <silent><buffer><expr> p    vimfiler#do_action('preview')
  endfunction
endif
" }}}

" Signify {{{
" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
if s:dein_enabled && dein#tap("vim-signify")
  nnoremap <F4> :<C-u>SignifyToggle<CR>

  nmap <Leader>gj <Plug>(signify-next-hunk)zz
  nmap <Leader>gk <Plug>(signify-prev-hunk)zz

  nmap <Leader>gh <Plug>(signify-toggle-highlight)
  nmap <Leader>gt <Plug>(signify-toggle)

  let g:signify_vcs_list = [ 'git', 'svn' ]
  let g:signify_difftool = 'gnudiff'

  let g:signify_skip_filetype = { 'vim': 1, 'c': 1 }
  let g:signify_skip_filename = { $MYVIMRC: 1 }

  let g:signify_sign_overwrite     = 1
  let g:signify_update_on_bufenter = 1
  let g:signify_line_highlight     = 1

  let g:signify_sign_add               = '+'
  let g:signify_sign_change            = '!'
  let g:signify_sign_delete            = '_'
  let g:signify_sign_delete_first_line = '‾'

  let g:signify_cursorhold_normal = 1
  let g:signify_cursorhold_insert = 1
endif
" }}}

" vim-transform {{{
" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
if s:dein_enabled && dein#tap("vim-transform")
  nmap <D-R> <Plug>(transform)
  xmap <D-R> <Plug>(transform)
  imap <D-R> <Plug>(transform)

  let g:transform = {}
  let g:transform.options = {}
  let g:transform.options.enable_default_config = 0
  let g:transform.options.path = "/Users/arcthur/transformer"

  function! g:transform._(e)
    let e = a:e
    let c = e.content
    let FILENAME = e.buffer.filename
    let FILETYPE = e.buffer.filetype

    if FILETYPE ==# 'go'
      if c.line_s =~# '\v^const\s*\(' && c.line_e =~# '\v\)\s*'
        call e.run("go/const_stringfy.rb")
      elseif c['line_s-1'] =~# '\v^import\s*\('
        call e.run("go/import.rb")
      endif
    endif

    if FILETYPE =~# 'markdown'
      " Dangerous example
      " if line is four leading space and '$', then execute string after '$' char.
      "  ex) '    $ ls -l' => trasnsformed result of 'ls -l'

      let pat = '\v^    \$(.*)$'
      if c.len ==# 1 && c.line_s =~# pat
        let cmd = substitute(c.line_s, pat, '\1', '')
        call e.run(cmd)
      endif

      " replace URL to actual content
      if c.len ==# 1 && c.line_s =~# '\v^\s*https?://\S*$'
        call e.run('curl ' . c.line_s)
      endif
    endif
  endfunction
endif
" }}}

" neocomplete
" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
if s:dein_enabled && dein#tap("neocomplete.vim")
  let g:neocomplete#enable_at_startup = 1
  let g:neocomplete#enable_smart_case = 1
  let g:neocomplete#enable_camel_case = 1
  let g:neocomplete#auto_complete_delay = 30
  let g:neocomplete#enable_fuzzy_completion = 1
  let g:neocomplete#auto_completion_start_length = 2
  let g:neocomplete#manual_completion_start_length = 0
  let g:neocomplete#min_keyword_length = 3
  let g:neocomplete#enable_auto_select = 1
  let g:neocomplete#enable_auto_delimiter = 1
  let g:neocomplete#max_list = 100

  if !exists('g:neocomplete#sources#omni#input_patterns')
    let g:neocomplete#sources#omni#input_patterns = {}
  endif

  let g:marching_enable_neocomplete = 1
  let g:neocomplete#sources#omni#input_patterns.python =
        \ '[^. *\t]\.\w*\|\h\w*'

  " Define keyword pattern.
  if !exists('g:neocomplete#keyword_patterns')
    let g:neocomplete#keyword_patterns = {}
  endif
  let g:neocomplete#keyword_patterns._ = '\h\k*(\?'
  let g:neocomplete#keyword_patterns.rst =
        \ '\$\$\?\w*\|[[:alpha:]_.\\/~-][[:alnum:]_.\\/~-]*\|\d\+\%(\.\d\+\)\+'

  call neocomplete#custom#source('look', 'min_pattern_length', 4)
  call neocomplete#custom#source('_', 'converters',
        \ ['converter_add_paren', 'converter_remove_overlap',
        \  'converter_delimiter', 'converter_abbr'])

  " <C-f>, <C-b>: page move.
  inoremap <expr><C-f>  pumvisible() ? "\<PageDown>" : "\<Right>"
  inoremap <expr><C-b>  pumvisible() ? "\<PageUp>"   : "\<Left>"
  " <C-h>, <BS>: close popup and delete backword char.
  " inoremap <expr> <C-h> neocomplete#smart_close_popup()."\<C-h>"
  inoremap <expr> <BS> neocomplete#smart_close_popup()."\<C-h>"
  " <C-n>: neocomplete.
  inoremap <expr> <C-n>  pumvisible() ? "\<C-n>" : "\<C-x>\<C-u>\<C-p>\<Down>"
  " <C-p>: keyword completion.
  inoremap <expr> <C-p>  pumvisible() ? "\<C-p>" : "\<C-p>\<C-n>"
  inoremap <expr> '  pumvisible() ? "\<C-y>" : "'"

  " <CR>: close popup and save indent.
  inoremap <silent> <CR> <C-r>=<SID>my_cr_function()<CR>
  function! s:my_cr_function() abort
    return neocomplete#smart_close_popup() . "\<CR>"
  endfunction

  " <TAB>: completion.
  inoremap <silent><expr> <TAB>
        \ pumvisible() ? "\<C-n>" :
        \ <SID>check_back_space() ? "\<TAB>" :
        \ neocomplete#start_manual_complete()

  function! s:check_back_space() abort
    let col = col('.') - 1
    return !col || getline('.')[col - 1]  =~ '\s'
  endfunction

  " <S-TAB>: completion back.
  inoremap <expr><S-TAB>  pumvisible() ? "\<C-p>" : "\<C-h>"
endif

" neosnippet {{{
" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
if s:dein_enabled && dein#tap("neosnippet")
  imap <C-s> <Plug>(neosnippet_expand_or_jump)
  smap <C-s> <Plug>(neosnippet_expand_or_jump)
  xmap <C-s> <Plug>(neosnippet_expand_target)

  let g:neosnippet#enable_snipmate_compatibility = 1
  let g:neosnippet#disable_runtime_snippets = {'_' : 1}
  let g:neosnippet#snippets_directory = []

  if dein#tap("neosnippet-snippets")
    let g:neosnippet#snippets_directory += [expand(s:dein_github . '/Shougo/neosnippet-snippets/neosnippets')]
  endif

  if dein#tap("vim-snippets")
    let g:neosnippet#snippets_directory += [expand(s:dein_github . '/honza/vim-snippets/snippets')]
  endif

  if dein#tap("vim-react-snippets")
    let g:neosnippet#snippets_directory += [expand(s:dein_github . '/justinj/vim-react-snippets/snippets')]
  endif
endif

" Vimshell
" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
if s:dein_enabled && dein#tap("vimshell.vim")
  nnoremap <Leader>v :<C-u>tabnew<CR>:<C-u>VimShell<CR>
  nnoremap <Leader>V :<C-U>VimShellBufferDir<CR>

  let g:vimshell_prompt            = $USER."% "
  let g:vimshell_user_prompt       = 'fnamemodify(getcwd(), ":~")'
  let g:vimshell_enable_smart_case = 1
  let g:vimshell_ignore_case       = 1
  let g:vimshell_temporary_directory = g:my.dir.vimshell

  autocmd MyAutoCmd FileType vimshell call s:vimshell_settings()
  function! s:vimshell_settings()
    nmap <silent><buffer> <C-j>  <Plug>(vimshell_next_prompt)
    nmap <silent><buffer> <C-k>  <Plug>(vimshell_previous_prompt)
    nnoremap <silent><buffer> <C-p>  gT
    nnoremap <silent><buffer> <C-n>  gt

    call vimshell#altercmd#define('g', 'git')
    call vimshell#altercmd#define('l', 'll')
    call vimshell#altercmd#define('ll', 'ls -lh')
  endfunction
endif


" Commentary {{{
" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
if s:dein_enabled && dein#tap("caw.vim")
  " Beggining of Line Comment Toggle
  nmap <Leader>cc <Plug>(caw:i:toggle)
  vmap <Leader>cc <Plug>(caw:i:toggle)

  " End of Line Comment Toggle
  nmap <Leader>ca <Plug>(caw:a:toggle)
  vmap <Leader>ca <Plug>(caw:a:toggle)

  " Block Comment Toggle
  nmap <Leader>cw <Plug>(caw:wrap:toggle)
  vmap <Leader>cw <Plug>(caw:wrap:toggle)

  " Break line and Comment
  nmap <Leader>co <Plug>(caw:jump:comment-next)
  nmap <Leader>cO <Plug>(caw:jump:comment-prev)

  let g:caw_no_default_keymappings = 1
endif
" }}}

" Gundo {{{
" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
if s:dein_enabled && dein#tap("gundo")
  noremap <F3> :<C-u>GundoToggle<CR>
  inoremap <F3> <esc>:GundoToggle<CR>

  let g:gundo_width          = 30
  let g:gundo_debug          = 1
  let g:gundo_preview_bottom = 1
endif
" }}}

" EasyAlign {{{
" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
if s:dein_enabled && dein#tap("vim-easy-align")
  let g:easy_align_delimiters = {
      \ '>': { 'pattern': '>>\|=>\|>' },
      \ '\': { 'pattern': '\\' },
      \ '/': { 'pattern': '//\+\|/\*\|\*/', 'ignores': ['String'] },
      \ '#': { 'pattern': '#\+', 'ignores': ['String'] },
      \ ']': {
      \     'pattern':       '[[\]]',
      \     'left_margin':   0,
      \     'right_margin':  0,
      \     'stick_to_left': 0
      \   },
      \ ')': {
      \     'pattern':       '[()]',
      \     'left_margin':   0,
      \     'right_margin':  0,
      \     'stick_to_left': 0
      \   },
      \ 'f': {
      \     'pattern': ' \(\S\+(\)\@=',
      \     'left_margin': 0,
      \     'right_margin': 0
      \   },
      \ 'd': {
      \     'pattern': ' \(\S\+\s*[;=]\)\@=',
      \     'left_margin': 0,
      \     'right_margin': 0
      \   }
      \ }
  vnoremap <silent> <Enter> :EasyAlign<cr>

  " help map-operator
  function! s:easy_align_1st_eq(type, ...)
    '[,']EasyAlign=
  endfunction
  nnoremap <Leader>= :set opfunc=<SID>easy_align_1st_eq<Enter>g@

  function! s:easy_align_1st_colon(type, ...)
    '[,']EasyAlign:
  endfunction
  nnoremap <Leader>: :set opfunc=<SID>easy_align_1st_colon<Enter>g@
endif
" }}}

" Vimwiki {{{
" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
if s:dein_enabled && dein#tap("vimwiki")
  nnoremap <silent> <Leader>dd :VimwikiIndex<CR>

  let screen = {'path': '~/Dropbox/vimwiki/wiki/',
              \ 'path_html': '~/Dropbox/public/wiki/screen/',
              \ 'html_header': '~/Dropbox/vimwiki/template/screen/header.tpl',
              \ 'html_footer': '~/Dropbox/vimwiki/template/screen/footer.tpl',
              \ 'syntax': 'default'}
  let g:vimwiki_list          = [screen]
  let g:vimwiki_camel_case    = 0
  let g:vimwiki_auto_checkbox = 0
endif
" }}}

" indentLine {{{
" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
if s:dein_enabled && dein#tap("indentLine")
  let g:indentLine_enabled = 1
  let g:indentLine_char = '┊'
  let g:indentLine_first_char = '┃'
  let g:indentLine_concealcursor='vc'
  let g:indentLine_color_gui = '#363636'
  let g:indentLine_fileType = g:my.ft.program_files

  nnoremap <Leader>i :IndentLinesToggle<CR>
endif
" }}}

" Textmanip {{{
" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
if s:dein_enabled && dein#tap("vim-textmanip")
  xmap <M-d> <Plug>(textmanip-duplicate-down)
  nmap <M-d> <Plug>(textmanip-duplicate-down)
  xmap <M-D> <Plug>(textmanip-duplicate-up)
  nmap <M-D> <Plug>(textmanip-duplicate-up)

  xmap <C-j> <Plug>(textmanip-move-down)
  xmap <C-k> <Plug>(textmanip-move-up)
  xmap <C-h> <Plug>(textmanip-move-left)
  xmap <C-l> <Plug>(textmanip-move-right)
endif
" }}}

" Expand-region {{{
" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
if s:dein_enabled && dein#tap("vim-expand-region")
  map K <Plug>(expand_region_expand)
endif
" }}}

" Multiple-cursors {{{
" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
if s:dein_enabled && dein#tap("vim-multiple-cursors")
  xnoremap <C-N> :call multiple_cursors#new('n')<CR>

  let g:multi_cursor_use_default_mapping = 0
  let g:multi_cursor_start_key = '<C-N>'
  let g:multi_cursor_next_key  = '<C-N>'
  let g:multi_cursor_prev_key  = '<C-P>'
  let g:multi_cursor_skip_key  = '<C-X>'
  let g:multi_cursor_quit_key  = '<Esc>'
endif
" }}}

" incsearch {{{
" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
if s:dein_enabled && dein#tap("incsearch-fuzzy.vim")
  function! s:config_fuzzyall(...) abort
    return extend(copy({
    \   'converters': [
    \     incsearch#config#fuzzy#converter(),
    \     incsearch#config#fuzzyspell#converter()
    \   ],
    \ }), get(a:, 1, {}))
  endfunction

  noremap <silent><expr> z/ incsearch#go(<SID>config_fuzzyall())
  noremap <silent><expr> z? incsearch#go(<SID>config_fuzzyall({'command': '?'}))
  noremap <silent><expr> zg? incsearch#go(<SID>config_fuzzyall({'is_stay': 1}))
endif
" }}}

" QuickRun {{{
" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
if s:dein_enabled && dein#tap("vim-quickrun")
  nnoremap <silent> <Leader>r  :<C-u>QuickRun -mode n<CR>
  vnoremap <silent> <Leader>r  :<C-u>QuickRun -mode v<CR>
  nnoremap <Leader>R           :<C-u>QuickRun -args ""<Left>

  let g:quickrun_config = {}
  let g:quickrun_no_default_key_mappings = 1
  let g:quickrun_config._ = {
        \ 'runner' : 'vimproc',
        \ 'outputter/buffer/split' : 'botright 10sp',
        \ 'runmode' : 'async:vimproc'
        \ }
  let g:quickrun_config.javascript = {
        \ 'command': 'node'}

  let g:quickrun_config.lisp = {
        \ 'command': 'clisp' }

  let g:quickrun_config.markdown = {
        \ 'outputter': 'browser',
        \ 'cmdopt': '-s' }

  let g:quickrun_config.applescript = {
        \ 'command' : 'osascript' , 'output' : '_'}

  let g:quickrun_config['ruby.rspec'] = {
        \ 'type' : 'ruby.rspec',
        \ 'command': 'rspec',
        \ 'exec': 'bundle exec %c %o %s', }
endif
" }}}

" vim-over {{{
" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
if s:dein_enabled && dein#tap("vim-over")
  let g:over_command_line_key_mappings = {
        \ "\<C-L>" : "\<C-F>",
        \ }

  OverCommandLineNoremap <C-J> <Plug>(over-cmdline-substitute-jump-pattern)
  OverCommandLineNoremap <C-K> <Plug>(over-cmdline-substitute-jump-string)

  command! -range -nargs=*
        \  OverCommandLine
        \  call over#command_line(
        \    g:over_command_line_prompt,
        \    <line1> != <line2> ? printf("'<,'>%s", <q-args>) : <q-args>
        \)
endif
" }}}

" emmet {{{
" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
if s:dein_enabled && dein#tap("emmet-vim")
  imap <buffer><C-e> <C-y>,

  let g:user_emmet_mode = 'iv'
  let g:user_emmet_leader_key = '<C-y>'
  let g:use_emmet_complete_tag = 1
  let g:user_emmet_settings = {
        \ 'html' : {
        \   'filters' : 'html',
        \ },
        \ 'php' : {
        \   'extends' : 'html',
        \   'filters' : 'html',
        \ },
        \}

  augroup EmmitVim
    autocmd!
    autocmd BufEnter,FileType * let g:user_emmet_settings.indentation = '               '[:&tabstop]
  augroup END
endif
" }}}

" lightline {{{
" """"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
if s:dein_enabled && dein#tap("lightline.vim")
  let s:lightline = { 'updatetime' : 5 }

  function! s:lightline.new(options)
    let options = a:options
    let instance = copy(self)
    call remove(instance, 'new')
    call extend(instance, options)

    return instance
  endfunction

  function! s:lightline.update(object)
    let object = a:object
    let now = s:reltime()
    let object.updatedtime = get(object, 'updatedtime', s:reltime())

    if !has_key(object, 'initialized') || (now - object.updatedtime >= object.updatetime)
      let object.initialized = 1
      let object.updatedtime = now
      return 1
    else
      return 0
    endif
  endfunction

  function! s:lightline.statusline()
    let self.cache = self.update(self) ? self.func() : get(self, 'cache', '')
    return self.cache
  endfunction

  let g:lightline#functions#file_size = s:lightline.new({ 'updatetime' : 1 })
  function! g:lightline#functions#file_size.func()
    return line('$')
  endfunction

  let g:lightline#functions#git_branch = s:lightline.new({ 'updatetime' : 5 })
  function! g:lightline#functions#git_branch.func()
    if exists("*giti#branch#current_name")
      let branch = giti#branch#current_name()
    elseif exists("*git#get_current_branch")
      let branch = git#get_current_branch()
    elseif exists("*fugitive#head")
      let branch = fugitive#head()
    else
      let branch = ''
    endif

    return branch
  endfunction

  let g:lightline#functions#ale = s:lightline.new({ 'updatetime' : 5 })
  function! g:lightline#functions#ale.func()
    return exists("*ale#statusline#Status") ? ale#statusline#Status() : ''
  endfunction

  let g:lightline#functions#tagbar = s:lightline.new({ 'updatetime' : 3 })
  function! g:lightline#functions#tagbar.func()
    return exists("*tagbar#currenttag") && bufwinnr('__Tagbar__') != -1 ? tagbar#currenttag('[%s]', '') : ''
  endfunction

  let g:lightline#functions#plugin_information = s:lightline.new({ 'updatetime' : 0.5 })
  function! g:lightline#functions#plugin_information.func()
    if &filetype == 'unite'
      return unite#get_status_string()
    elseif &filetype == 'vimfiler'
      return vimfiler#get_status_string()
    elseif &filetype == 'vimshell'
      return vimshell#get_status_string()
    else
      return empty(bufname('%')) ? '' : expand('%:p:~')
    endif
  endfunction

  let g:lightline = {
        \ 'colorscheme': 'wombat',
        \ 'active': {
        \   'left': [
        \     ['mode', 'paste'],
        \     ['information'],
        \     ['git_branch', 'tagbar', 'modified']
        \   ],
        \   'right': [
        \     ['ale', 'lineinfo', 'file_size'],
        \     ['percent'],
        \     ['fileformat', 'fileencoding', 'filetype']
        \   ],
        \ },
        \ 'component_function' : {
        \   'tagbar':      'g:lightline#functions#tagbar.statusline',
        \   'information': 'g:lightline#functions#plugin_information.statusline'
        \ },
        \ 'component_expand': {
        \   'git_branch':  'g:lightline#functions#git_branch.statusline',
        \   'ale':   'g:lightline#functions#ale.statusline',
        \   'file_size':   'g:lightline#functions#file_size.statusline'
        \ },
        \ }
endif
