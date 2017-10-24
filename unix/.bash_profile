# pyenv
export PYENV_VIRTUALENV_DISABLE_PROMPT=1
export PATH="~/.pyenv/bin:$PATH"
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"

if [ -f ~/.bashrc ]; then
    . ~/.bashrc
fi
