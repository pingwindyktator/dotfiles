# Interactive operation...
alias rm='rm -I'
alias cp='cp -i'
alias mv='mv -i'

# Default to human readable figures
alias df='df -h'
alias du='du -h'

# Misc :)
alias less='less -r'                          # raw control characters
alias whence='type -a'                        # where, of a sort
alias grep='grep --color'                     # show differences in colour
alias egrep='egrep --color=auto'              # show differences in colour
alias fgrep='fgrep --color=auto'              # show differences in colour
alias weather='curl wttr.in/krakow'
alias ipext='curl -s http://checkip.dyndns.org/ | grep -o '[0-9][0-9]*.[0-9][0-9]*.[0-9][0-9]*.[0-9]*''

# Some shortcuts for different directory listings
alias ls='ls -hF --color=tty'                 # classify files in colour
alias dir='ls --color=auto --format=vertical'
alias vdir='ls --color=auto --format=long'
alias ll='ls -AlhGrti'                        # long list
alias la='ls -A'                              # all but . and ..
alias l='ls -CF'
alias free='free -h'

# Custom ones
alias py3='python3'
alias py2='python2'
alias ip='ipconfig.exe /all ; getmac ; echo > /dev/null'
alias sudo=''
alias su='echo > /dev/null'
alias bf='bg ; fg'
alias cds='cd "$src"'
alias car='cat'
alias lwatch='watch -t -n 0.1 tail -n 50'  # watch logs
alias gedit='atom'
alias li='l *'
alias pyg='pygmentize -g'
alias utf8='chcp.com 65001 & bash'
alias cwd='cygpath -aw "$(pwd)"'
alias vscode='code'
alias wpath='cygpath -wp "$PATH" | sed "s/;/\n/g"'
alias cpath='echo -e ${PATH//:/\\n}'
alias rm_tr_sp="sed 's/^[ \t]*//;s/[ \t]*$//'"
