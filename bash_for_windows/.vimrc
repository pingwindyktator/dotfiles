set nocompatible
set ignorecase
set smartcase
set incsearch
set shiftwidth=4
set tabstop=4
set expandtab
set nocp
set nu
set hlsearch
set updatetime=100
set hidden
set history=1000
set wildmenu
set title
set titleold=
set visualbell
set autoindent
set smartindent
autocmd StdinReadPre * let s:std_in=1
syntax on

" Plug plugin manager
if empty(glob('~/.vim/autoload/plug.vim'))
      silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
      autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

" Install missing plugins automatically
autocmd VimEnter *
  \  if len(filter(values(g:plugs), '!isdirectory(v:val.dir)'))
  \|   PlugInstall --sync | q
  \| endif
  
call plug#begin('~/.vim/plugged')

Plug 'tomlion/vim-solidity'
Plug 'bogado/file-line'
Plug 'tpope/vim-sensible'
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --bin' }
Plug 'junegunn/fzf.vim'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'scrooloose/nerdtree'
Plug 'jistr/vim-nerdtree-tabs'
Plug 'farmergreg/vim-lastplace'
Plug 'tpope/vim-eunuch'
Plug 'tpope/vim-fugitive'
Plug 'ekalinin/Dockerfile.vim'
Plug 'haya14busa/incsearch.vim'
Plug 'Raimondi/delimitMate'
Plug 'sheerun/vim-polyglot'
Plug 'tpope/vim-surround'
Plug 'fidian/hexmode'
Plug 'airblade/vim-gitgutter'
Plug 'cespare/vim-sbd'

call plug#end()

" Fzf plugin
function! s:tags_sink(line)
  let parts = split(a:line, '\t\zs')
  let excmd = matchstr(parts[2:], '^.*\ze;"\t')
  execute 'silent e' parts[1][:-2]
  let [magic, &magic] = [&magic, 0]
  execute excmd
  let &magic = magic
endfunction

function! s:tags()
  if empty(tagfiles())
    echohl WarningMsg
    echom 'Preparing tags'
    echohl None
    call system('ctags -R -a -f .ctags')
  endif

call fzf#run({
  \ 'source':  'cat '.join(map(tagfiles(), 'fnamemodify(v:val, ":S")')).
  \            '| grep -v -a ^!',
  \ 'options': '+m -d "\t" --with-nth 1,4.. -n 1 --tiebreak=index',
  \ 'down':    '40%',
  \ 'sink':    function('s:tags_sink')})
endfunction

command! Tags call s:tags()
set tags=.ctags
let $FZF_DEFAULT_COMMAND = 'ag --ignore-case --hidden --ignore={.git,node_modules,vendor,.idea} -l -g ""'

" NerdTree plugin
let NERDTreeShowHidden=1
let NERDTreeIgnore = ['\.swp$']
let NERDTreeMinimalUI = 1
let NERDTreeDirArrows = 1
let g:nerdtree_tabs_focus_on_files=1
let g:nerdtree_tabs_autofind=1
let g:nerdtree_tabs_open_on_console_startup=1

" airline plugin
let g:airline#extensions#tabline#enabled = 1
let g:airline_powerline_fonts = 1



if has('persistent_undo')  " Keep backups in one place making undo work cross sessions
  silent !mkdir ~/.vim/backups > /dev/null 2>&1
  set undodir=~/.vim/backups
  set undofile
endif

if !has('nvim')        
    set ttymouse=xterm2
else
    set guicursor=a:ver100-blinkon0,i-ci-sm-c:ver100-blinkon1
endif

map ; :Files<CR>
map ' :Tags<CR>
map <silent> <C-n> :NERDTreeTabsToggle<CR>
map <silent> <C-\> :tab split<CR>:exec("tag ".expand("<cword>"))<CR>  " Open tag definition in a new tab

cmap hex Hexmode
cmap w!! SudoWrite
" cmap x Sbd  " Close buffer
" cmap x! Sbdm  " Force close buffer

nmap <silent> <A-Up> :wincmd k<CR>
nmap <silent> <A-Down> :wincmd j<CR>
nmap <silent> <A-Left> :wincmd h<CR>
nmap <silent> <A-Right> :wincmd l<CR>
nmap <silent> <C-S-Up> :m-2<CR>        " Move line up
nmap <silent> <C-S-Down> :m+<CR>       " Move line down

nnoremap <silent> <Tab> :bnext<CR>        " Next buffer
nnoremap <silent> <S-Tab> :bprevious<CR>  " Prev buffer

let &t_SI = "\<Esc>[6 q"  " Cursor shape
let &t_SR = "\<Esc>[6 q"  " Cursor shape
let &t_EI = "\<Esc>[6 q"  " Cursor shape
