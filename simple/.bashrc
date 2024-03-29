alias which='alias | /usr/bin/which --tty-only --read-alias --show-dot --show-tilde'
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'
alias grep='grep --color=auto'
alias l.='ls -d .* --color=auto'
alias ll='ls -l --color=auto'
alias ls='ls --color=auto'
alias cp='cp -i'
alias mv='mv -i'
alias rm='rm -i'

PS1='\e[90m\u:\e[94m\W $(if [[ $? == 0 ]]; then echo "\e[32m"; else echo "\e[31m"; fi)\]^\[\e[0m '

bind '"TAB":complete'
bind '"\e[Z":menu-complete'
