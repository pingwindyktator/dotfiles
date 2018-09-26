#!/bin/bash

platform=""
backup_dir="$HOME/dotfilesbackup"
update_dir="$HOME/.dotfiles"
system_deps=""
default_pyenv_dir=""
default_cuda_home=""
default_nvm_dir=""
default_goroot=""
default_gopath=""
default_dotnet_dir=""

install_system_package() {
    [[ -z "${*// }" ]] && return 0

    if [[ "${platform}" == "bash_for_windows" ]] || [[ "${platform}" == "unix" ]]; then
        if [ -n "$(command -v apt-get)" ]; then
            sudo apt-get update -qq && sudo apt-get install ${@} -y
        elif [ -n "$(command -v yum)" ]; then
            sudo yum update && sudo yum install ${@}
        else
            >&2 echo "Installing system packages currently not compatibile with your package manager"
            return 1
        fi

    elif [[ "${platform}" == "cygwin" ]]; then
        if [ -n "$(command -v apt-cyg)" ]; then
            apt-cyg update && apt-cyg install ${@}
        elif [ -n "$(command -v cyg-apt)" ]; then
            cyg-apt update && cyg-apt install ${@}
        elif [ -n "$(command -v cyg-get)" ]; then
            cyg-get ${@}
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
}

backup_existing_files() {
    mkdir -p "${backup_dir}"
    cd "${update_dir}/${platform}" > /dev/null || return

    # Create directory structure in $backup_dir
    find . ! -path . -and ! -path "./.git/*" -and ! -path "./.git" -type d | xargs -i mkdir -p "${backup_dir}/{}"

    # Copy files to $backup_dir
    find . -type f | xargs -i cp "${HOME}/{}" "${backup_dir}/{}" 2> /dev/null
}

view_diff() {
    cd "${update_dir}/${platform}" > /dev/null || return
    find . -type f | xargs -i diff "{}" "${HOME}/{}" 2> /dev/null
}

preinstall() {
    [ -f "${HOME}/.bashrc" ] && . "${HOME}/.bashrc"
    mkdir -p "${update_dir}"
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

    [ -n "$(command -v pyenv)" ] || [ -d "${default_pyenv_dir}" ] && default_answer=Y || default_answer=N
    confirm "Enable dotfiles pyenv support?" "${default_answer}" && enable_pyenv_support
    
    [ -n "$(command -v nvcc)" ] || [ -d "${default_cuda_home}" ] || [[ -n "${CUDA_HOME// }" ]] && default_answer=Y || default_answer=N
    confirm "Enable dotfiles cuda support?" "${default_answer}" && enable_cuda_support
    
    [ -n "$(command -v nvm)" ] || [ -d "${default_nvm_dir}" ] && default_answer=Y || default_answer=N
    confirm "Enable dotfiles nvm support?" "${default_answer}" && enable_nvm_support
    
    [ -n "$(command -v thefuck)" ] && default_answer=Y || default_answer=N
    confirm "Enable dotfiles thefuck support?" "${default_answer}" && enable_thefuck_support
    
    [ -n "$(command -v go)" ] || [ -d "${default_goroot}" ] || [ -d "${default_gopath}" ] && default_answer=Y || default_answer=N
    confirm "Enable dotfiles Golang support?" "${default_answer}" && enable_golang_support
    
    [ -n "$(command -v dotnet)" ] || [ -d "${default_dotnet_dir}" ] && default_answer=Y || default_answer=N
    confirm "Enable dotfiles dotnet support?" "${default_answer}" && enable_dotnet_support

    # TODO other platforms, check for /usr/local/go-1.10...
    # TODO return error if one of dotfile is not correct (check syntax, bash -n?)
    # TODO cygwin?
}

enable_dotnet_support() {
    cd "${update_dir}/${platform}" > /dev/null || return
    
    if [[ -n "${DOTNET_DIR// }" ]]; then
        default_answer="${DOTNET_DIR// }"
    elif [ -d "${default_dotnet_dir}" ]; then
        default_answer="${default_dotnet_dir}"
    else
        default_answer=""
    fi
    
    response=$(confirm_string "Enter dotnet dir" "${default_answer}")
    
    echo ""                                                   >> ".bashrc" && \
    echo "# dotnet"                                           >> ".bashrc" && \
    echo "export DOTNET_DIR=\"${response}\""                  >> ".bashrc" && \
    echo "export DOTNET_CLI_TELEMETRY_OPTOUT=1"               >> ".bashrc" && \
    echo 'export PATH="${DOTNET_DIR}/tools${PATH:+:${PATH}}"' >> ".bashrc" || return
}

enable_golang_support() {
    cd "${update_dir}/${platform}" > /dev/null || return
    
    if [ -n "$(command -v go env)" ]; then
        default_answer="$(go env GOROOT)"
    elif [[ -n "${GOROOT// }" ]]; then
        default_answer="${GOROOT// }"
    elif [ -d "${default_goroot}" ]; then
        default_answer="${default_goroot}"
    else
        default_answer=""
    fi
    
    response_goroot=$(confirm_string "Enter GOROOT" "${default_answer}")
    
    if [ -n "$(command -v go env)" ]; then
        default_answer="$(go env GOPATH)"
    elif [[ -n "${GOPATH// }" ]]; then
        default_answer="${GOPATH// }"
    elif [ -d "${default_gopath}" ]; then
        default_answer="${default_gopath}"
    else
        default_answer=""
    fi
    
    response_gopath=$(confirm_string "Enter GOPATH" "${default_answer}")
    
    echo ""                                             >> ".bashrc" && \
    echo "# golang"                                     >> ".bashrc" && \
    echo "export GOROOT=\"${response_goroot}\""         >> ".bashrc" && \
    echo "export GOPATH=\"${response_gopath}\""         >> ".bashrc" && \
    echo 'export PATH="${GOROOT}/bin${PATH:+:${PATH}}"' >> ".bashrc" && \
    echo 'export PATH="${GOPATH}/bin${PATH:+:${PATH}}"' >> ".bashrc" || return
}

enable_thefuck_support() {
    cd "${update_dir}/${platform}" > /dev/null || return
    
    echo ""                             >> ".bashrc" && \
    echo "# thefuck"                    >> ".bashrc" && \
    echo 'eval $(thefuck --alias)'      >> ".bashrc" && \
    echo 'eval $(thefuck --alias FUCK)' >> ".bashrc" || return
}

enable_nvm_support() {
    cd "${update_dir}/${platform}" > /dev/null || return
    
    if [[ -n "${NVM_DIR// }" ]]; then
        default_answer="${NVM_DIR// }"
    elif [ -d "${default_nvm_dir}" ]; then
        default_answer="${default_nvm_dir}"
    else
        default_answer=""
    fi
    
    response=$(confirm_string "Enter nvm dir" "${default_answer}")
    
    echo ""                                                                                                         >> ".bashrc" && \
    echo "# nvm"                                                                                                    >> ".bashrc" && \
    echo "export NVM_DIR=\"${response}\""                                                                           >> ".bashrc" && \
    echo '[ -s "${NVM_DIR}/nvm.sh" ] && \. "${NVM_DIR}/nvm.sh"                    # This loads nvm'                 >> ".bashrc" && \
    echo '[ -s "${NVM_DIR}/bash_completion" ] && \. "${NVM_DIR}/bash_completion"  # This loads nvm bash_completion' >> ".bashrc" || return
}

enable_pyenv_support() {
    cd "${update_dir}/${platform}" > /dev/null || return
    
    if [[ -n "${PYENV_DIR// }" ]]; then
        default_answer="${PYENV_DIR// }"
    elif [ -d "${default_pyenv_dir}" ]; then
        default_answer="${default_pyenv_dir}"
    else
        default_answer=""
    fi
    
    response=$(confirm_string "Enter pyenv dir" "${default_answer}")
    
    echo ""                                         >> ".bashrc" && \
    echo "# pyenv"                                  >> ".bashrc" && \
    echo "export PYENV_DIR=\"${response}\""         >> ".bashrc" && \
    echo 'export PYENV_VIRTUALENV_DISABLE_PROMPT=1' >> ".bashrc" && \
    echo 'export PATH="${PYENV_DIR}:$PATH"'         >> ".bashrc" && \
    echo 'eval "$(pyenv init -)"'                   >> ".bashrc" && \
    echo 'eval "$(pyenv virtualenv-init -)"'        >> ".bashrc" || return
}

enable_cuda_support() {
    cd "${update_dir}/${platform}" > /dev/null || return
    
    if [[ -n "${CUDA_HOME// }" ]]; then
        default_answer="${CUDA_HOME// }"
    elif [ -d "${default_cuda_home}" ]; then
        default_answer="${default_cuda_home}"
    else
        default_answer=""
    fi
        
    response=$(confirm_string "Enter CUDA_HOME dir" "${default_answer}")
    
    echo ""                                                                                   >> ".bashrc" && \
    echo "# cuda"                                                                             >> ".bashrc" && \
    echo "export CUDA_HOME=\"${response}\""                                                   >> ".bashrc" && \
    echo 'export PATH="${CUDA_HOME}/bin${PATH:+:${PATH}}"'                                    >> ".bashrc" && \
    echo 'export C_INCLUDE_PATH="${CUDA_HOME}/include:${C_INCLUDE_PATH}"'                     >> ".bashrc" && \
    echo 'export LD_LIBRARY_PATH="${CUDA_HOME}/lib64${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}"' >> ".bashrc" && \
    echo 'export LIBRARY_PATH="${CUDA_HOME}/lib64${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}"'    >> ".bashrc" && \
    echo 'export CUDACXX="$(which nvcc)"'                                                     >> ".bashrc" || return
}

postinstall() {
    rm -rf "${update_dir}"

    # No need for `sudo` anymore
    sudo -k
}

detect_platform() {
    if [[ "$(expr substr "$(uname -s)" 1 5)" == "Linux" && "$(uname -a)" == *"Microsoft"* ]]; then
        platform="bash_for_windows"
        system_deps="git vim colordiff mawk gawk"
        return 0

    elif [[ "$(expr substr "$(uname -s)" 1 5)" == "Linux" ]]; then
        platform="unix"
        system_deps="git vim colordiff xdotool wmctrl mawk gawk"
        default_pyenv_dir="${HOME}/.pyenv/bin"
        default_cuda_home="/usr/local/cuda"
        default_nvm_dir="${HOME}/.nvm"
        default_goroot="/usr/local/go"
        default_gopath="${HOME}/Sources/go"
        default_dotnet_dir="${HOME}/.dotnet"
        return 0

    elif [[ "$(expr substr "$(uname -s)" 1 9)" == "CYGWIN_NT" ]]; then
        platform="cygwin"
        system_deps=""
        return 0

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

    return 0
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
