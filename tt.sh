function once() {
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

    read -e -p $ssh_color$ssh_flag' [31m'$username' '$root' '$powerd' [0m: ' cmd
    echo -e "\e[1A\r$ssh_flag $username $root $powerd\e[0m"
    eval "$cmd"
}
while true; do
    once
done
