#
# ~/.bashrc
#

[[ $- != *i* ]] && return

colors() {
	local fgc bgc vals seq0

	printf "Color escapes are %s\n" '\e[${value};...;${value}m'
	printf "Values 30..37 are \e[33mforeground colors\e[m\n"
	printf "Values 40..47 are \e[43mbackground colors\e[m\n"
	printf "Value  1 gives a  \e[1mbold-faced look\e[m\n\n"

	# foreground colors
	for fgc in {30..37}; do
		# background colors
		for bgc in {40..47}; do
			fgc=${fgc#37} # white
			bgc=${bgc#40} # black

			vals="${fgc:+$fgc;}${bgc}"
			vals=${vals%%;}

			seq0="${vals:+\e[${vals}m}"
			printf "  %-9s" "${seq0:-(default)}"
			printf " ${seq0}TEXT\e[m"
			printf " \e[${vals:+${vals+$vals;}}1mBOLD\e[m"
		done
		echo; echo
	done
}

[ -r /usr/share/bash-completion/bash_completion ] && . /usr/share/bash-completion/bash_completion

# Change the window title of X terminals
case ${TERM} in
	xterm*|rxvt*|Eterm*|aterm|kterm|gnome*|interix|konsole*)
		PROMPT_COMMAND='echo -ne "\033]0;${USER}@${HOSTNAME%%.*}:${PWD/#$HOME/\~}\007"'
		;;
	screen*)
		PROMPT_COMMAND='echo -ne "\033_${USER}@${HOSTNAME%%.*}:${PWD/#$HOME/\~}\033\\"'
		;;
esac

use_color=true

# Set colorful PS1 only on colorful terminals.
# dircolors --print-database uses its own built-in database
# instead of using /etc/DIR_COLORS.  Try to use the external file
# first to take advantage of user additions.  Use internal bash
# globbing instead of external grep binary.
safe_term=${TERM//[^[:alnum:]]/?}   # sanitize TERM
match_lhs=""
[[ -f ~/.dir_colors   ]] && match_lhs="${match_lhs}$(<~/.dir_colors)"
[[ -f /etc/DIR_COLORS ]] && match_lhs="${match_lhs}$(</etc/DIR_COLORS)"
[[ -z ${match_lhs}    ]] \
	&& type -P dircolors >/dev/null \
	&& match_lhs=$(dircolors --print-database)
[[ $'\n'${match_lhs} == *$'\n'"TERM "${safe_term}* ]] && use_color=true

bg1=128
fg1=206
bg2=55
fg2=69
bg3=17
fg3=34
#bg1=214
#fg1=226
#bg2=202
#fg2=88
#bg3=196
#fg3=17
if ${use_color} ; then
	# Enable colors for ls, etc.  Prefer ~/.dir_colors #64489
	if type -P dircolors >/dev/null ; then
		if [[ -f ~/.dir_colors ]] ; then
			eval $(dircolors -b ~/.dir_colors)
		elif [[ -f /etc/DIR_COLORS ]] ; then
			eval $(dircolors -b /etc/DIR_COLORS)
		fi
	fi
	# Check if ssh user
	ssh_flag=""
	export|grep SSH_TTY -i > /dev/null
	if [ $? == 0 ]; then
		#ssh_flag="\[\e[48;5;$bg2;38;5;27""m\]󱩜 "
		ssh_flag="\[\e[0m\]\[\e[38;5;27""m\]󱩜 "
	else
		#ssh_flag="\[\e[48;5;$bg2;38;5;160""m\]󰐂 "
		ssh_flag="\[\e[0m\]\[\e[38;5;160""m\]󰐂 "
	fi

	if [[ ${EUID} == 0 ]] ; then
		PS1="$ssh_flag\[\e[48;5;$bg1;38;5;$fg1""m\] \u \[\e[48;5;$bg2;38;5;$bg1""m\] \[\e[48;5;$bg2;38;5;$fg2""m\]  \[\e[48;5;$bg3;38;5;$bg2""m\] \[\e[48;5;$bg3;38;5;$fg3""m\] \W \[\e[0m\]\[\e[38;5;$bg3""m\]\[\e[0m\] "
	else
		PS1="$ssh_flag\[\e[48;5;$bg1;38;5;$fg1""m\] \u \[\e[48;5;$bg2;38;5;$bg1""m\] \[\e[48;5;$bg2;38;5;$fg2""m\]  \[\e[48;5;$bg3;38;5;$bg2""m\] \[\e[48;5;$bg3;38;5;$fg3""m\] \W \[\e[0m\]\[\e[38;5;$bg3""m\]\[\e[0m\] "
	fi

	alias ls='ls --color=auto'
	alias grep='grep --colour=auto'
	alias egrep='egrep --colour=auto'
	alias fgrep='fgrep --colour=auto'
else
	if [[ ${EUID} == 0 ]] ; then
		# show root@ when we don't have colors
		PS1='\u@\h \W \$ '
	else
		PS1='\u@\h \w \$ '
	fi
fi

function nice_ps1() {
    while true; do
        # ssh_flag
        ssh_flag=''
        export|grep SSH_TTY -i > /dev/null
        if [ $? == 0 ]; then
            ssh_flag='󱩜'
            ssh_color='[38;5;27m'
        else
            ssh_flag='󰐂'
            ssh_color='[38;5;160m'
        fi

        # username
        username=`whoami`

        # powerd
        if [[ $PWD == $HOME ]]; then
            powerd='~'
        else
            powerd=${PWD##*/}
        fi

        #root
        if [[ $EUID == 0 ]]; then
            root=''
        else
            root=''
        fi

        read -e -p $ssh_color$ssh_flag' [48;5;55;38;5;206m '$username' [48;5;17;38;5;55m  [48;5;17;38;5;69m'$root' [48;5;17;38;5;34m'$powerd' [0m[38;5;17m[0m ' cmd
        echo -e "\e[1A\r\e[38;5;239m$ssh_flag  $username   $root $powerd 󰄾\e[0m"
        eval "$cmd"
    done
}

unset use_color safe_term match_lhs sh

#alias cp="cp -i"                          # confirm before overwriting something
#alias df='df -h'                          # human-readable sizes
#alias free='free -m'                      # show sizes in MB
#alias np='nano -w PKGBUILD'
#alias more=less
alias ra=ranger
alias iam=neofetch
alias fb="source .bashrc"
alias bye="shutdown now"
alias hk="~/.scripts/hook.sh"
alias gk="~/.scripts/goHook.sh"
alias ck="~/.scripts/clHook.sh"

source ~/.profile

xhost +local:root > /dev/null 2>&1

# Bash won't get SIGWINCH if another process is in the foreground.
# Enable checkwinsize so that bash will check the terminal size when
# it regains control.  #65623
# http://cnswww.cns.cwru.edu/~chet/bash/FAQ (E11)
shopt -s checkwinsize

shopt -s expand_aliases

# export QT_SELECT=4

# Enable history appending instead of overwriting.  #139609
shopt -s histappend

#
# # ex - archive extractor
# # usage: ex <file>
ex ()
{
  if [ -f $1 ] ; then
    case $1 in
      *.tar.bz2)   tar xjf $1   ;;
      *.tar.gz)    tar xzf $1   ;;
      *.bz2)       bunzip2 $1   ;;
      *.rar)       unrar x $1     ;;
      *.gz)        gunzip $1    ;;
      *.tar)       tar xf $1    ;;
      *.tbz2)      tar xjf $1   ;;
      *.tgz)       tar xzf $1   ;;
      *.zip)       unzip $1     ;;
      *.Z)         uncompress $1;;
      *.7z)        7z x $1      ;;
      *)           echo "'$1' cannot be extracted via ex()" ;;
    esac
  else
    echo "'$1' is not a valid file"
  fi
}

nice_ps1
