#!/bin/bash

platform=""
backup_dir="$HOME/dotfilesbackup"

install_unix() {
    sudo apt-get install xdotool wmctrl awk -y
    base_url="https://raw.githubusercontent.com/pingwindyktator/dotfiles/master/unix/"
    mkdir "~/bin"

    for dotfilename in ".bash_aliases" ".bash_funcs" ".bash_profile" ".bashrc" ".gitconfig" ".vimrc" "bin/init_git_sign_repo" "bin/terminal_quick_access"; do
        wget -q "$base_url/$dotfilename" -O "$HOME/$dotfilename"
    done
    
    chmod u+x ~/bin/init_git_sign_repo
    chmod u+x ~/bin/terminal_quick_access
}

install_cygwin() {
    base_url="https://raw.githubusercontent.com/pingwindyktator/dotfiles/master/cygwin"

    for dotfilename in ".bash_aliases" ".bash_funcs" ".bashrc" ".gitconfig" ".inputrc" ".vimrc" ".vs_for_bash"; do
        wget -q "$base_url/$dotfilename" -O "$HOME/$dotfilename"
    done
}

install_macos() {
    echo "Mac OS is currently not supported"
}

install_win() {
    echo "Windows is currently not supported"
}

backup_existing_files() {
    mkdir -p "$backup_dir"
    for dotfilename in ".bash_aliases" ".bash_funcs" ".bash_profile" ".bashrc" ".gitconfig" ".inputrc" ".vimrc" ".vs_for_bash" "bin/init_git_sign_repo" "bin/terminal_quick_access"; do
        if [ -f "$HOME/$dotfilename" ]; then
            echo "backuping $dotfilename to $backup_dir..."
            mv "$HOME/$dotfilename" "$backup_dir/$dotfilename"
        fi
    done
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

read -p "backup existing files to $backup_dir? [Y/n] "
if [[ $REPLY =~ ^[Yy]$ ]]; then
    backup_existing_files
fi

preinstall
$func
postinstall
