#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# Source .bash_profile
if [[ -f ~/.bash_profile ]]; then
    . ~/.bash_profile
fi

alias ls='ls --color=auto'
alias grep='grep --color=auto'
PS1='[\u@\h \W]\$ '


export EDITOR=vim
export VISUAL=vim
export TERMINAL=kitty

export JAVA_HOME=/usr/lib/jvm/java-22-openjdk
