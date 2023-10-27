#!/bin/bash

if [ $# -gt 0 ]

  then
    DN=$1

  else
    DN=1
   
fi

INDEX=$((DN-1))

pdsh -w 10.10.28.13[$INDEX] tail -n 100 $OBH/logs/ozone-USERNAME-datanode-servozone0$DN.log
