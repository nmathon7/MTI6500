#!/bin/bash

REP=$HOME/logs

mkdir -p $REP
rm -rf $REP/*

if [ $# -gt 0 ]

  then
    DN=$1

  else
    DN=0
   
fi

if [ $# -eq 0 ]

   then
      rpdcp -w 10.10.28.13[0-6] "$OBH/logs/ozone-USERNAME-datanode-servozone0*.log" $REP || true
   else
      INDEX=$((DN-1))
     rpdcp -w 10.10.28.13[$INDEX] "$OBH/logs/ozone-USERNAME-datanode-servozone0*.log" $REP  || true

fi

echo "Fichier(s) récupéré(s) dans le répertoire: $REP "
