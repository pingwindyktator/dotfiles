#!/bin/bash

platform=""
backup_dir="$HOME/dotfilesbackup"

install_unix() {
    base_url="https://raw.githubusercontent.com/pingwindyktator/dotfiles/master/unix/"

    for dotfilename in ".bash_aliases" ".bash_funcs" ".bash_profile" ".bashrc" ".gitconfig" ".vimrc"; do
        if [ -f "$HOME/$dotfilename" ]; then
            echo "backuping $dotfilename to $backup_dir..."
            mkdir -p "$backup_dir"
            mv "$HOME/$dotfilename" "$backup_dir"
        fi

        wget -q "$base_url/$dotfilename" -O "$HOME/$dotfilename"
    done
}

install_cygwin() {
    base_url="https://raw.githubusercontent.com/pingwindyktator/dotfiles/master/cygwin"

    for dotfilename in ".bash_aliases" ".bash_funcs" ".bashrc" ".gitconfig" ".inputrc" ".vimrc" ".vs_for_bash"; do
        if [ -f "$HOME/$dotfilename" ]; then
            echo "backuping $dotfilename to $backup_dir..."
            mkdir -p "$backup_dir"
            mv "$HOME/$dotfilename" "$backup_dir"
        fi
        
        echo "downloading $dotfilename..."
        wget -q "$base_url/$dotfilename" -O "$HOME/$dotfilename"
    done
}

install_macos() {
    echo "Mac OS is currently not supported"
}

install_win() {
    echo "Windows is currently not supported"
}

preinstall() {
    echo ""
}

postinstall() {
    source "$HOME/.bashrc"
}


if [[ "$(uname)" == "Darwin" ]]; then
    platform="macos"
    func=install_macos

elif [[ "$(expr substr $(uname -s) 1 5)" == "Linux" ]]; then
    platform="unix"
    func=install_unix

elif [[ "$(expr substr $(uname -s) 1 10)" == "MINGW32_NT" ]]; then
    platform="win32"
    func=install_win

elif [[ "$(expr substr $(uname -s) 1 10)" == "MINGW64_NT" ]]; then
    platform="win64"
    func=install_win

elif [[ "$(expr substr $(uname -s) 1 9)" == "CYGWIN_NT" ]]; then
    platform="cygwin"
    func=install_cygwin

else
    echo "unknown platform"
    exit 1
fi

read -p "install dotfiles of $platform platform? [Y/n] "
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    exit 0
fi

preinstall
$func
postinstall
