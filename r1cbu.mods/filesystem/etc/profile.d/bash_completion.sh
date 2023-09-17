#!/bin/sh

if [ -n "$BASH_VERSINFO" ]; then
  if [ -r /etc/bash_completion ]; then
    . /etc/bash_completion
  elif [ -r /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  fi
fi
