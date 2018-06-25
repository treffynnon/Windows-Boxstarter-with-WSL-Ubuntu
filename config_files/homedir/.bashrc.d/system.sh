# set directory colours
eval `dircolors ~/.dircolors/nord-dircolors-develop/src/dir_colors`

# an OK command prompt for bash
PS1='\[\033[0;32m\]\[\033[0m\033[0;32m\]\u\[\033[1;34m\] @ \[\033[1;34m\]\h \w\[\033[0;32m\]$(__git_ps1)\n\[\033[0;32m\]└─\[\033[0m\033[0;32m\]\[\033[0m\033[0;32m\] λ\[\033[0m\] '

# restarting Ubuntu inside WSL
alias reboot="sudo killall -r '.*'"