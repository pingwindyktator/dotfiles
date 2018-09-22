# ~/.bashrc: executed by bash(1) for non-login shells.

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

HISTCONTROL=ignoredups
shopt -s histappend
shopt -s cmdhist
HISTSIZE=500000
HISTFILESIZE=100000

export VISUAL=vim
export EDITOR="$VISUAL"

shopt -s checkwinsize
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac

force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	color_prompt=yes
    else
	color_prompt=
    fi
fi

unset color_prompt force_color_prompt

case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

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
# export PATH="~/.pyenv/bin:$PATH"
# eval "$(pyenv init -)"
# eval "$(pyenv virtualenv-init -)"

# cuda
# export CUDA_HOME=/usr/local/cuda
# export PATH=${CUDA_HOME}/bin${PATH:+:${PATH}}
# export C_INCLUDE_PATH=${CUDA_HOME}/include:${C_INCLUDE_PATH}
# export LD_LIBRARY_PATH=${CUDA_HOME}/lib64${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}
# export LIBRARY_PATH=${CUDA_HOME}/lib64${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}
# export CUDACXX=$(which nvcc)

# nvm
# export NVM_DIR="$HOME/.nvm"
# [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
# [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# thefuck
# eval $(thefuck --alias)
# eval $(thefuck --alias FUCK)

# golang
# export GOROOT="/usr/local/go"
# export GOPATH=${HOME}/Sources/go
# export PATH=${GOROOT}/bin${PATH:+:${PATH}}
# export PATH=${GOPATH}/bin${PATH:+:${PATH}}

# dotnet
# export DOTNET_CLI_TELEMETRY_OPTOUT=1
# export PATH="~/.dotnet/tools${PATH:+:${PATH}}"
