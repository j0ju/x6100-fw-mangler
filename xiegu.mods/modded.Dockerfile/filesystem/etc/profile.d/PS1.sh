# (C) 2023 Joerg Jungermann, GPLv2 see LICENSE

if [ "$PS1" ]; then
	if [ "`id -u`" -eq 0 ]; then
		export PS1='[\u@\h:$PWD]# '
	else
		export PS1='[\u@\h:$PWD]$ '
	fi
fi
