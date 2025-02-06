#!/bin/sh
if ( loginctl | head -n -2 | tail -n +2 | cut -c 14- | cut -f 1 -d ' ' | grep -Fx "$USER" > /dev/null ) ; then
    zenity --error --text="User $1 is already logged in."
    exit 1
fi
