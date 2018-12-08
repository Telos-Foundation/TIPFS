#!/bin/bash
DIR=`pwd`

if [ -f $DIR"/validator.pid" ]; then
  pid=$(cat $DIR"/validator.pid")
  echo $pid
  kill $pid
  rm -r $DIR"/validator.pid"

  echo -ne "Stoping Validator"

  while true; do
    [ ! -d "/proc/$pid/fd" ] && break
    echo -ne "."
    sleep 1
  done
  echo -ne "\rValidator stopped. \n"

fi

