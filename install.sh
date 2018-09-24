#!/bin/bash

platform=""
backup_dir="$HOME/dotfilesbackup"
update_dir="$HOME/.dotfiles"

confirm() {
    local prompt default reply
    prompt="${1}"

    if [ "${2:-}" = "Y" ]; then
        pdefault="Y/n"
        default=Y
    elif [ "${2:-}" = "N" ]; then
        pdefault="y/N"
        default=N
    else
        pdefault="y/n"
        default=
    fi

    while true; do

        # Ask the question (not using "read -p" as it uses stderr not stdout)
        echo -n "$prompt [$pdefault] "

        # Read the answer (use /dev/tty in case stdin is redirected from somewhere else)
        read reply </dev/tty

        # Default?
        if [ -z "$reply" ]; then
            reply=$default
        fi

        # Check if the reply is valid
        case "$reply" in
            Y*|y*) return 0 ;;
            N*|n*) return 1 ;;
        esac

    done
}

confirm_string() {
    local prompt default reply
    prompt="${1}"
    default="${2}"

    # Default?
    [[ ! -z "${default// }" ]] && pdefault=" [${default}]" || pdefault=""

    # Ask the question
    read -r -p "$prompt$pdefault " reply

    # Empty reply?
    echo ${reply:-$default}
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

    response=$(confirm_string "Enter git user.name" $(git config --get user.name))
    find -type f | xargs -i sed -i "s/##git_name##/${response}/g" {}

    response=$(confirm_string "Enter git user.email" $(git config --get user.email))
    find -type f | xargs -i sed -i "s/##git_email##/${response}/g" {}

    response=$(confirm_string "Enter git user.signingKey" $(git config --get user.signingKey))
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

confirm "Install dotfiles of $platform platform?" Y || exit 0
preinstall
confirm "Backup existing files to $backup_dir?" N && backup_existing_files
confirm "View diff of replaced files?" N && view_diff
install_${platform}
postinstall
echo "Done!"
