# ~/.bashrc: executed by bash(1) for non-login shells.

# Exit if non-interactive mode
[[ $- == *i* ]] || return 0

if (( ${BASH_VERSION%%.*} < 4 )) ; then
    >&2 echo "Requires bash version 4.0.0 or higher, you've got ${BASH_VERSION}"
    return
fi

shopt -s histappend          # Append to the history file, don't overwrite it
shopt -s cmdhist             # Append to the history file, don't overwrite it
shopt -s autocd 2> /dev/null # Prepend cd to directory names automatically
shopt -s checkwinsize        # Update window size after every command
shopt -s cdable_vars         # This allows you to bookmark your favorite places across the file system,
                             # define a variable containing a path and you will be able to cd into it regardless of the directory you're in
set -o noclobber             # Prevent file overwrite on stdout redirection,
                             # use `>|` to force redirection to an existing file
shopt -s nocaseglob          # Use case-insensitive filename globbing

export HISTCONTROL=ignoredups; HISTCONTROL="erasedups:ignoreboth"
export HISTTIMEFORMAT="[%F %T] "
export HISTSIZE=10000
export HISTFILESIZE=1000000
export VISUAL=vim
export EDITOR="${VISUAL}"
export GPG_TTY="$(tty)"
export WINHOME="$(wslpath "$(cmd.exe /c "<nul set /p=%UserProfile%" 2>/dev/null)")"

[ -x "/usr/bin/lesspipe" ] && eval "$(SHELL=/bin/sh lesspipe)"

if [ -z "${debian_chroot:-}" ] && [ -r "/etc/debian_chroot" ]; then
    debian_chroot="$(cat /etc/debian_chroot)"
fi

force_color_prompt=yes

if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
    color_prompt=yes
else
    color_prompt=
fi

export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

[ -f ~/.privaterc ] && . ~/.privaterc
[ -f ~/.bash_aliases ] && . ~/.bash_aliases
[ -f ~/.bash_funcs ] && . ~/.bash_funcs
[ -f ~/.pythonrc ] && export PYTHONSTARTUP="${HOME}/.pythonrc"

[ -d "$HOME/bin" ] && PATH="$HOME/bin:$PATH"
[ -d "$HOME/.local/bin" ] && PATH="$HOME/.local/bin:$PATH"


if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

export PROMPT_COMMAND="__prompt_command; "

__prompt_command() {
    local EXIT="$?"  # This needs to be first

    local PS_RESET='\[\033[0m\]'
    local PS_RED='\[\033[1;31m\]'
    local PS_GREEN='\[\033[1;32m\]'
    local PS_YELLOW='\[\033[1;33m\]'
    local PS_PURPLE='\[\033[1;35m\]'
    local PS_WHITE='\[\033[1;37m\]'
    local PS_BLUE='\[\033[1;34m\]'
    local PS_CYAN='\[\033[1;36m\]'
    local PS_CLOCK="\A"
    local PS_USERNAME="\u"
    local PS_CMD_PROMPT="\\$"
    local PS_HOSTNAME="\H"
    local PS_PWD="\w"

    if [ $EXIT != 0 ]; then
       local PS_EXIT="${PS_RED}[✕]"
    else
       local PS_EXIT="${PS_GREEN}[✔]"
    fi
    
    if [ -z "${PS1BREAK+x}" ]; then
        local PS_BREAK=""
    else
        local PS_BREAK="\n"
    fi

    export PS1="${PS_EXIT}${PS_BLUE}[${PS_CLOCK}] ${PS_GREEN}${PS_USERNAME}${PS_WHITE}:${PS_YELLOW}${PS_PWD}${PS_BLUE}$(parse_git_branch)${PS_BREAK}${PS_WHITE}${PS_CMD_PROMPT} ${PS_RESET}"
}

if [ ! -z "${DOTFILES_PYENV_SUPPORT+x}" ]; then
    export PYENV_VIRTUALENV_DISABLE_PROMPT=1
    export PATH="${HOME}/.pyenv/bin:${PATH}"
    eval "$(pyenv init -)"
    eval "$(pyenv virtualenv-init -)"
fi

if [ ! -z "${DOTFILES_CUDA_SUPPORT+x}" ]; then
    export CUDA_HOME="/usr/local/cuda"
    export PATH="${CUDA_HOME}/bin${PATH:+:${PATH}}"
    export C_INCLUDE_PATH="${CUDA_HOME}/include:${C_INCLUDE_PATH}"
    export LD_LIBRARY_PATH="${CUDA_HOME}/lib64${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}"
    export LIBRARY_PATH="${CUDA_HOME}/lib64${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}"
    export CUDACXX=$(which nvcc)
fi

if [ ! -z "${DOTFILES_NVM_SUPPORT+x}" ]; then
    export NVM_DIR="${HOME}/.nvm"
    [ -s "${NVM_DIR}/nvm.sh" ] && \. "${NVM_DIR}/nvm.sh"  # This loads nvm
    [ -s "${NVM_DIR}/bash_completion" ] && \. "${NVM_DIR}/bash_completion"  # This loads nvm bash_completion
fi

if [ ! -z "${DOTFILES_THEFUCK_SUPPORT+x}" ]; then
    eval $(thefuck --alias)
    eval $(thefuck --alias FUCK)
fi

if [ ! -z "${DOTFILES_GOLANG_SUPPORT+x}" ]; then
    export GOROOT="/usr/local/go"
    export GOPATH="${WINHOME}/Sources/go"
    export PATH="${GOROOT}/bin${PATH:+:${PATH}}"
    export PATH="${GOPATH}/bin${PATH:+:${PATH}}"
fi

if [ ! -z "${DOTFILES_DOTNET_SUPPORT+x}" ]; then
    export DOTNET_CLI_TELEMETRY_OPTOUT=1
    export PATH="${HOME}/.dotnet/tools${PATH:+:${PATH}}"
fi

if [ ! -z "${DOTFILES_DOCKER_SUPPORT+x}" ]; then
    export PATH="${HOME}/bin:${HOME}/.local/bin:${PATH}"
    export PATH="${PATH}:/mnt/c/Program\ Files/Docker/Docker/resources/bin"
    alias docker='docker.exe'
    alias docker-compose='docker-compose.exe'  
fi

if [ ! -z "${DOTFILES_RVM_SUPPORT+x}" ]; then
    export PATH="${HOME}/.rvm/bin${PATH:+:${PATH}}"
    [[ -s "${HOME}/.rvm/scripts/rvm" ]] && source "${HOME}/.rvm/scripts/rvm"  # Load RVM into a shell session *as a function*
fi

if [ ! -z "${DOTFILES_RUST_SUPPORT+x}" ]; then
    source "${HOME}/.cargo/env"
fi

