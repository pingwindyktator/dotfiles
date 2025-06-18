#!/bin/bash

platform=""
backup_dir="${HOME}/dotfilesbackup"
update_dir="${HOME}/.dotfiles"
system_deps=""

install_system_package() {
    [[ -z "${*// }" ]] && return 0
    
    if [[ "${platform}" == "wsl" ]] || [[ "${platform}" == "unix" ]]; then        
        if [ -n "$(command -v apt-get)" ]; then
            sudo apt-get update -qq && sudo apt-get install ${@} -y
        elif [ -n "$(command -v yum)" ]; then
            sudo yum update && sudo yum install ${@}
        else
            >&2 echo "Installing system packages currently not compatibile with your package manager"
            return 1
        fi
        
    else
        >&2 echo "Unknown platform"
        return 1
    fi
}

confirm() {
    local prompt default reply pdefault
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
        read -r reply </dev/tty

        # Default?
        [ -z "${reply// }" ] && reply=$default

        # Check if the reply is valid
        case "$reply" in
            Y*|y*) return 0 ;;
            N*|n*) return 1 ;;
        esac

    done
}

confirm_string() {
    local prompt default reply pdefault
    prompt="${1}"
    default="${2}"

    # Default?
    [[ -n "${default// }" ]] && pdefault=" [${default}]" || pdefault=""

    # Ask the question
    read -r -p "$prompt$pdefault " reply

    # Empty reply?
    echo "${reply:-$default}"
}

generic_install() {
    cd "${update_dir}/${platform}" > /dev/null || return
    
    # Create directory structure in $HOME
    find . ! -path . -and ! -path "./.git/*" -and ! -path "./.git" -type d | xargs -i mkdir -p "${HOME}/{}"
    
    # Copy files to $HOME
    find . -type f | xargs -i cp "{}" "${HOME}/{}"
    
    # install vim plug
    curl -fLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
}

backup_existing_files() {
    mkdir -p "${backup_dir}" || return
    cd "${update_dir}/${platform}" > /dev/null || return
    
    # Create directory structure in $backup_dir
    find . ! -path . -and ! -path "./.git/*" -and ! -path "./.git" -type d | xargs -i mkdir -p "${backup_dir}/{}"
    
    # Copy files to $backup_dir
    find . -type f | xargs -i cp "${HOME}/{}" "${backup_dir}/{}" 2> /dev/null
}

view_diff() {
    cd "${update_dir}/${platform}" > /dev/null || return
    find . -type f | xargs -i colordiff "${HOME}/{}" "{}" 2> /dev/null
}

preinstall() {
    mkdir -p "${update_dir}" || return
    cd "${update_dir}" > /dev/null || return
    git init -q
    git remote add -f origin https://github.com/pingwindyktator/dotfiles > /dev/null
    git config core.sparseCheckout true
    echo "${platform}" >> .git/info/sparse-checkout
    git pull -q origin master
    cd "${platform}" > /dev/null || return

    response=$(confirm_string "Enter git user.name" "$(git config --get user.name)")
    find . -type f | xargs -i sed -i "s/##git_name##/${response}/g" "{}"

    response=$(confirm_string "Enter git user.email" "$(git config --get user.email)")
    find . -type f | xargs -i sed -i "s/##git_email##/${response}/g" "{}"

    response=$(confirm_string "Enter git user.signingKey" "$(git config --get user.signingKey)")
    find . -type f | xargs -i sed -i "s/##git_signingKey##/${response}/g" "{}"
}

postinstall() {
    rm -rf "${update_dir}"
    sudo -k  # No need for `sudo` anymore
}

detect_platform() {
    if [[ "$(expr substr "$(uname -s)" 1 5)" == "Linux" && ("$(uname -a)" == *"Microsoft"* || "$(uname -a)" == *"microsoft"*) ]]; then
        platform="wsl"
        system_deps="git vim colordiff mawk gawk silversearcher-ag exuberant-ctags fonts-powerline curl"

    elif [[ "$(expr substr "$(uname -s)" 1 5)" == "Linux" ]]; then
        platform="unix"
        system_deps="git vim colordiff xdotool wmctrl mawk gawk silversearcher-ag exuberant-ctags fonts-powerline curl libnotify-bin"

    else
        >&2 echo "Unknown platform"
        return 1
    fi
}

assert_compatibility() {
    if [[ ! $(git --version | awk '{print $3}') > 1.7.0 ]]; then
        >&2 echo "Requires git version 1.7.0 or higher, you've got $(git --version | awk '{print $3}')"
        return 1
    fi
}

main() {
    detect_platform || exit 1
    confirm "Install dotfiles of $platform platform?" Y || exit 0
    install_system_package "${system_deps}" || exit 1
    assert_compatibility || exit 1
    preinstall
    confirm "View diff of replaced files?" N && view_diff
    confirm "Backup existing files to $backup_dir?" N && backup_existing_files
    generic_install
    postinstall && echo "Done!"
}




if (( ${BASH_VERSION%%.*} < 4 )) ; then
    >&2 echo "Requires bash version 4.0.0 or higher, you've got ${BASH_VERSION}"
    return 1
fi

main
