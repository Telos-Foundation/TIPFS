#!/bin/bash
DATADIR=`pwd`
$DATADIR/stop.sh
node index.js "$@" &> $DATADIR/validator.log & echo $! > $DATADIR/validator.pid
echo Validator started.

