#!/bin/bash

platform=""
backup_dir="$HOME/dotfilesbackup"
update_dir="$HOME/.dotfiles"

confirm() {
    read -r -p "${1} [y/N] " response
    case "$response" in
        [yY][eE][sS]|[yY])
            true
            ;;
        *)
            false
            ;;
    esac
}

generic_install() {
    cd ${update_dir}/${platform} > /dev/null
    find . ! -path . -and ! -path './.git/*' -and ! -path './.git' -type d | xargs -i mkdir -p ${HOME}/{}
    find -type f | xargs -i cp {} ${HOME}/{}
}

install_unix() {
    sudo apt-get install git vim -y
    sudo apt-get install xdotool wmctrl colordiff -y
    generic_install
}

install_bash_for_windows() {
    sudo apt-get install git vim colordiff -y
    generic_install
}

install_cygwin() {
    generic_install
}

backup_existing_files() {
    mkdir -p ${backup_dir}
    cd ${update_dir}/${platform} > /dev/null
    find . ! -path . -and ! -path './.git/*' -and ! -path './.git' -type d | xargs -i mkdir -p ${backup_dir}/{}
    find -type f | xargs -i cp ${HOME}/{} ${backup_dir}/{} 2> /dev/null
}

view_diff() {
    cd ${update_dir}/${platform} > /dev/null
    find -type f | xargs -i diff {} ${HOME}/{} 2> /dev/null
}

preinstall() {
    mkdir -p ${update_dir}
    cd ${update_dir} > /dev/null
    git init -q
    git remote add -f origin https://github.com/pingwindyktator/dotfiles > /dev/null
    git config core.sparseCheckout true
    echo ${platform} >> .git/info/sparse-checkout
    git pull -q origin master
    cd ${platform} > /dev/null

    read -r -p "Enter git user.name: " response
    find -type f | xargs -i sed -i "s/##git_name##/${response}/g" {}
    read -r -p "Enter git user.email: " response
    find -type f | xargs -i sed -i "s/##git_email##/${response}/g" {}
    read -r -p "Enter git user.signingKey: " response
    find -type f | xargs -i sed -i "s/##git_signingKey##/${response}/g" {}
}

postinstall() {
    rm -rf ${update_dir}
}




if [[ "$(expr substr $(uname -s) 1 5)" == "Linux" && "$(uname -a)" == *"Microsoft"* ]]; then
    platform="bash_for_windows"

elif [[ "$(expr substr $(uname -s) 1 5)" == "Linux" ]]; then
    platform="unix"

elif [[ "$(expr substr $(uname -s) 1 9)" == "CYGWIN_NT" ]]; then
    platform="cygwin"

else
    echo "unknown platform"
    exit 1
fi

confirm "Install dotfiles of $platform platform?" || exit 0
preinstall
confirm "Backup existing files to $backup_dir?" && backup_existing_files
confirm "View diff of replaces files?" && view_diff
install_${platform}
postinstall
