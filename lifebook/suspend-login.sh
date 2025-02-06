#!/bin/sh

idleTime=0
suspendTime=300

while true ; do
  echo suspend-login $idleTime / $suspendTime
  loginctl
  if (loginctl | head -n -2 | tail -n +2 | grep -v lightdm > /dev/null) ; then
    idleTime=0
  else
    idleTime=$((idleTime+5))
    if [ $idleTime -gt $suspendTime ] ; then
      echo suspend-login suspend
      idleTime=0
      systemctl suspend
    fi
  fi
  sleep 5
done
