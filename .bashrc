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

# autocomplete
#bind 'TAB:menu-complete'
bind '"\e[Z":menu-complete'
#bind 'set show-all-if-ambiguous on'

# set true or false
use_color=true
echo_git_branch=true
echo_git_sha1=true
echo_git_sha1_len=3
echo_git_pushed=true

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

if ${use_color} ; then
	# Enable colors for ls, etc.  Prefer ~/.dir_colors #64489
	if type -P dircolors >/dev/null ; then
		if [[ -f ~/.dir_colors ]] ; then
			eval $(dircolors -b ~/.dir_colors)
		elif [[ -f /etc/DIR_COLORS ]] ; then
			eval $(dircolors -b /etc/DIR_COLORS)
		fi
	fi

	alias ls='ls --color=auto'
	alias grep='grep --colour=auto'
	alias egrep='egrep --colour=auto'
	alias fgrep='fgrep --colour=auto'

	# Check if ssh user
	export|grep SSH_CONNECTION -i > /dev/null
	if [ $? == 0 ]; then
		ssh_flag="󱩜 "
		ssh_color="\[\e[0m\]\[\e[38;5;27m\]"
	else
		ssh_flag="󰐂 "
		ssh_color="\[\e[0m\]\[\e[38;5;160m\]"
	fi

	bg1=128 # not use for now
	fg1=206
	bg2=55
	fg2=69
	bg3=17 # dir
	fg3=34
    fg4=3 # root color
    fg5=172 # branch color
    fg6=172 # sha1 color

	if [[ ${EUID} == 0 ]]; then
		PS1="$ssh_color$ssh_flag\[\e[48;5;$bg2;38;5;$fg1""m\]▌\[\e[38;5;$fg4""m\] \u\[\e[48;5;$bg3;38;5;$bg2""m\]  \[\e[48;5;$bg3;38;5;$fg3""m\]\W$git_flag \[\e[0m\]\[\e[38;5;$bg3""m\]\[\e[0m\] "
	else
		PS1="$ssh_color$ssh_flag\[\e[48;5;$bg2;38;5;$fg1""m\]▌\[\e[38;5;$fg2""m\] \u\[\e[48;5;$bg3;38;5;$bg2""m\]  \[\e[48;5;$bg3;38;5;$fg5""m\]\$(get_git)\[\e[48;5;$bg3;38;5;$fg3""m\]\W \[\e[0m\]\[\e[38;5;$bg3""m\]\[\e[0m\] "
	fi

	if [[ -n $TMUX ]]; then
		PROMPT_COMMAND=grey_last_prompt
	fi


else
	export|grep SSH_TTY -i > /dev/null
	if [ $? == 0 ]; then
		ssh_flag="󱩜 "
	else
		ssh_flag="󰐂 "
	fi
	if [[ ${EUID} == 0 ]]; then
		PS1="$ssh_flag▌ \u  \$(get_git)\W 󰄾 "
	else
		PS1="$ssh_flag▌ \u  \$(get_git)\W 󰄾 "
	fi
fi

# grey last command's prompt
function grey_last_prompt() {
    status=$?
	screen=`tmux capturep -p`
	last=`grep -n  <<< "$screen"| tail -n 1| cut -d ':' -f 1`
	if [[ -n $last ]]; then
		grey=`grep  <<< "$screen"| tail -n 1`;grey=${grey//};grey=`cut -d ':' -f 1 <<< ${grey//:}`
		echo -n "x\r"
		now=`tmux capturep -p| grep -n x| tail -n 1| cut -d ':' -f 1`

        if [[ $status == 0 ]]; then
            st_color="\e[38;5;2m"
        else
            st_color="\e[38;5;1m"
        fi

		diff=$((now - last))
		echo -n -e "\e[$diff""A\r\e[38;5;239m$grey$st_color󰄾\e[$diff""B\r"
	fi

}

function get_git() {
    # git branch
    branch_flag=""
    if $echo_git_branch ; then
        branch=`git branch 2> /dev/null`
        if [ $? == 0 ]; then
            branch_flag="${branch/* /} "
        fi
    fi

    sha1_flag=""
    if $echo_git_sha1 ; then
        sha1=`git rev-parse HEAD 2> /dev/null`
        if [ $? == 0 ]; then
            sha1_flag="${sha1:1:$echo_git_sha1_len}"
        fi
    fi

    push_flag=""
    if $echo_git_pushed ; then
        st=`git status 2> /dev/null`
        if [ $? == 0 ]; then
            grep -q -E "nothing to commit, working tree clean" <<< $st
            if [ $? == 0 ]; then
                grep -q -E "git push" <<< $st
                if [ $? == 0 ]; then
                    push_flag="⇑ "
                else
                    push_flag="✔️ "
                fi
            else
                push_flag="✗ "
            fi
        fi
    fi

    echo "$sha1_flag$branch_flag$push_flag"
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
