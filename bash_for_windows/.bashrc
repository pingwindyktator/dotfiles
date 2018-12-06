# ~/.bashrc: executed by bash(1) for non-login shells.

if (( ${BASH_VERSION%%.*} < 4 )) ; then
    >&2 echo "Requires bash version 4.0.0 or higher, you've got ${BASH_VERSION}"
    return
fi

case $- in
    *i*) ;;
      *) return;;
esac

# PS1 switches
PS_RESET='\[\033[0m\]'
PS_RED='\[\033[1;31m\]'
PS_GREEN='\[\033[1;32m\]'
PS_YELLOW='\[\033[1;33m\]'
PS_PURPLE='\[\033[1;35m\]'
PS_WHITE='\[\033[1;37m\]'
PS_BLUE='\[\033[1;34m\]'
PS_CYAN='\[\033[1;36m\]'
PS_CLOCK="\A"
PS_USERNAME="\u"
PS_CMD_PROMPT="\\$"
PS_HOSTNAME="\H"
PS_PWD="\w"

# Append to the history file, don't overwrite it
shopt -s histappend
# Append to the history file, don't overwrite it
shopt -s cmdhist
# Prepend cd to directory names automatically
shopt -s autocd 2> /dev/null
# Update window size after every command
shopt -s checkwinsize
# This allows you to bookmark your favorite places across the file system
# Define a variable containing a path and you will be able to cd into it regardless of the directory you're in
shopt -s cdable_vars
# Prevent file overwrite on stdout redirection
# Use `>|` to force redirection to an existing file
set -o noclobber
# Enable history expansion with space
# E.g. typing !!<space> will replace the !! with your last command
bind Space:magic-space
# Use case-insensitive filename globbing
shopt -s nocaseglob

HISTCONTROL=ignoredups; HISTCONTROL="erasedups:ignoreboth"
HISTTIMEFORMAT='%F %T '
HISTSIZE=500000
HISTFILESIZE=100000
export VISUAL=vim
export EDITOR="${VISUAL}"
export GPG_TTY="$(tty)"

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

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

if [ -f ~/.bash_funcs ]; then
  . ~/.bash_funcs
fi

if [ -f ~/.privaterc ]; then
  . ~/.privaterc
fi

if [ -f ~/.pythonrc ]; then
  export PYTHONSTARTUP=~/.pythonrc
fi

if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

export PS1="${PS_BLUE}[${PS_CLOCK}] ${PS_GREEN}${PS_USERNAME}${PS_WHITE}:${PS_YELLOW}${PS_PWD}${PS_BLUE}\`parse_git_branch\`${PS_WHITE}${PS_CMD_PROMPT} ${PS_RESET}"

# pyenv
# export PYENV_VIRTUALENV_DISABLE_PROMPT=1
# export PATH="${HOME}/.pyenv/bin:${PATH}"
# eval "$(pyenv init -)"
# eval "$(pyenv virtualenv-init -)"

# cuda
# export CUDA_HOME="/usr/local/cuda"
# export PATH="${CUDA_HOME}/bin${PATH:+:${PATH}}"
# export C_INCLUDE_PATH="${CUDA_HOME}/include:${C_INCLUDE_PATH}"
# export LD_LIBRARY_PATH="${CUDA_HOME}/lib64${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}"
# export LIBRARY_PATH="${CUDA_HOME}/lib64${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}"
# export CUDACXX=$(which nvcc)

# nvm
# export NVM_DIR="${HOME}/.nvm"
# [ -s "${NVM_DIR}/nvm.sh" ] && \. "${NVM_DIR}/nvm.sh"  # This loads nvm
# [ -s "${NVM_DIR}/bash_completion" ] && \. "${NVM_DIR}/bash_completion"  # This loads nvm bash_completion

# thefuck
# eval $(thefuck --alias)
# eval $(thefuck --alias FUCK)

# golang
# export GOROOT="/usr/local/go"
# export GOPATH="${HOME}/Sources/go"
# export PATH="${GOROOT}/bin${PATH:+:${PATH}}"
# export PATH="${GOPATH}/bin${PATH:+:${PATH}}"

# dotnet
export DOTNET_CLI_TELEMETRY_OPTOUT=1
# export PATH="${HOME}/.dotnet/tools${PATH:+:${PATH}}"

# docker
# export PATH="${HOME}/bin:${HOME}/.local/bin:${PATH}"
# export PATH="${PATH}:/mnt/c/Program\ Files/Docker/Docker/resources/bin"
# alias docker='docker.exe'
# alias docker-compose='docker-compose.exe'
