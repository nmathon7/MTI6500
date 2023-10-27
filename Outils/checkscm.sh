#!/bin/bash

if [ $# -gt 0 ]

  then
    LI=$1

  else
    LI=100

fi

tail -n $LI $OBH/logs/ozone-USERNAME-scm-servozone0?.log
