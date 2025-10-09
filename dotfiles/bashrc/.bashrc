# ================================================================= #
#  Universal Bash Configuration (.bashrc)                           #
# ================================================================= #

# 1. INITIAL CHECKS
# ----------------------------------------------------------------- #
# If not running interactively, don't do anything.
[[ $- != *i* ]] && return


# 2. COLOR AND PROMPT CONFIGURATION
# ----------------------------------------------------------------- #
# Enable colors, but check if the terminal can truly handle them.
if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
    color_prompt=yes
fi

# Load the git-prompt functions for branch display, if available.
if [ -f /usr/share/git/completion/git-prompt.sh ]; then
    source /usr/share/git/completion/git-prompt.sh
fi

# Define the prompt (PS1) with colors and Git integration.
if [ "$color_prompt" = yes ]; then
    # Color definitions
    GREEN="\[\033[01;32m\]"
    BLUE="\[\033[01;34m\]"
    MAGENTA="\[\033[1;95m\]"
    RESET="\[\033[0m\]"
    
    # Structure: [user@host]:[directory] (git_branch) $
    PS1="${GREEN}\u@\h${RESET}:${BLUE}\w${RESET}${MAGENTA}\$(__git_ps1 ' (%s)')${RESET}\$ "
else
    PS1='\u@\h:\w\$ '
fi
unset color_prompt


# 3. COMMAND ALIASES: CREATING SHORTCUTS
# ----------------------------------------------------------------- #
# Enable color support for common commands.
alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'

# Shortcuts for file and directory listing.
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# Convenience aliases.
alias ..='cd ..'
alias ...='cd ../..'


# 4. SHELL HISTORY CONFIGURATION
# ----------------------------------------------------------------- #
# Increase history size.
HISTSIZE=10000
HISTFILESIZE=50000

# Avoid saving duplicate commands or commands starting with a space.
HISTCONTROL=ignoreboth:erasedups

# Ignore trivial commands from being saved.
HISTIGNORE="ls:clear:history:exit"


# 5. DEFAULT EDITOR CONFIGURATION
# ----------------------------------------------------------------- #
# Set a preferred text editor, with fallbacks to more common ones.
if command -v nvim &> /dev/null; then
    export EDITOR=nvim
elif command -v vim &> /dev/null; then
    export EDITOR=vim
elif command -v nano &> /dev/null; then
    export EDITOR=nano
fi
export VISUAL="$EDITOR"

# ================================================================= #
#  End of Universal Configuration                                   #
# ================================================================= #
