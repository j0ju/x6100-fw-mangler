if [ "$PS1" ]; then
	if [ "`id -u`" -eq 0 ]; then
		export PS1='[\u@\h:$PWD]# '
	else
		export PS1='[\u@\h:$PWD]$ '
	fi
fi
