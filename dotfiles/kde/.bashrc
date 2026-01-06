#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias grep='grep --color=auto'
# PS1='[\u@\h \W]\$ '

# ANSI color code for blue (color4)
BLUE="\[\033[1;95m\]"
RESET="\[\033[0m\]"

PS1='[\u@\h \W'$BLUE'$(__git_ps1 " %s")'$RESET']\$ '

export EDITOR=nvim
export VISUAL=nvim
export TERMINAL=konsole

# Git branch in prompt
source /usr/share/git/completion/git-prompt.sh

