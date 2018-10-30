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
filetype off 
syntax on
cmap w!! w !sudo tee > /dev/null %

" Vundle
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
Plugin 'VundleVim/Vundle.vim'

" Plugins
Plugin 'git@github.com:bogado/file-line.git'

" Vundle
call vundle#end()
filetype plugin indent on
