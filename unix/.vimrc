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
filetype plugin on
filetype plugin indent on
syntax on
cmap w!! w !sudo tee > /dev/null %

" Return to last edit position when opening files
autocmd BufReadPost *
            \ if line("'\"") > 0 && line("'\"") <= line("$") |
            \   exe "normal! g`\"" |
            \ endif

execute pathogen#infect()
