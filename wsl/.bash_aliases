# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls="ls --color=auto 2> >(grep -Ev 'Brak dostępu|Brak dostępu|Permission denied' >&2)"
    alias dir='dir --color=auto'
    alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
else
    alias ls="ls 2> >(grep -Ev 'Brak dostępu|Brak dostępu|Permission denied' >&2)"
fi

# some more ls aliases
alias ll='ls -AlFh'
alias la='ls -A'
alias l='ls -CF'
alias li='l *'

# Misc :)
alias less='less -r'                          # raw control characters
alias whence='type -a'                        # where, of a sort
alias ipext='curl -s http://checkip.dyndns.org/ | grep -o '[0-9][0-9]*.[0-9][0-9]*.[0-9][0-9]*.[0-9]*''
alias free='free -h'
alias tailf='tail -f'

# Interactive operation...
alias rm='rm -I'
alias cp='cp -i'
alias mv='mv -i'

# Default to human readable figures
alias df='df -h'
alias du='du -h'

# Custom ones
alias bf='bg ; fg'
alias car='cat'
alias mkdir='mkdir -pv'
alias diff='colordiff'
alias rm='rm -I --preserve-root'
alias noh='sed -r "s/\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[mGK]//g"'
alias find="find 2> >(grep -Ev 'Brak dostępu|Brak dostępu|Permission denied' >&2)"
alias grep='grep -s --color'
alias topdu='du -hsx * | sort -rh | head -10'
alias diskfree='df -kh .'
alias dmesg='dmesg -T'
alias utf8='chcp.com 65001 & bash'
alias explorer='explorer.exe'
alias virtualbox_support='bcdedit /set hypervisorlaunchtype off'
alias docker_support='bcdedit /set hypervisorlaunchtype auto'
alias docker_remove_all='[[ -n $(docker ps -qa) ]] && docker stop $(docker ps -qa); docker rm $(docker ps -qa); docker rmi -f $(docker images -qa); docker volume rm $(docker volume ls -qf); docker network rm $(docker network ls -q)'
alias docker_stop_all='[[ -n $(docker ps -qa) ]] && docker stop $(docker ps -qa)'
alias xml_pp='xmllint --format -'
