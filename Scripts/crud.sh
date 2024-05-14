#!/bin/bash
#
# Utilisation: ./crud.sh PASSES MODE SUPPHIST
# PASSES  : 1 à N: Nombre de passes (boucle)
# MODE    : Si le mode est -s, on lance le mode simulation seulement, si -o en mode opérations seulement 
#           sinon c'est par défaut en mode production.
# SUPPHIST: Si cet argument est -c, les répertoires temporaires des passes antéreures seront supprimés. Par défaut on les conserve.   

SECONDS=0
COLLECTL_DTDEBUT=$(date +%Y%m%d)
COLLECTL_HRDEBUT=$(date +%H:%M)

declare -a SERVEURS_TOUS=('10.10.28.131' '10.10.28.132' '10.10.28.133' '10.10.28.134' '10.10.28.135' '10.10.28.136');
declare -a SERVEURS=();
declare -a LISTE=();

echo "*** Début du script bash - $(date +%F) $(date +%T) ***"

if [ $# -gt 0 ]

  then
    PASSES=$1
    MODE=$2
    SUPPHIST=$3

  else
    PASSES=1
    MODE=""
    SUPPHIST="Non"
    echo "Aucun argument saisi, valeurs par défaut utilisées."

fi

echo "Nombre de passes: $PASSES"
echo "Mode: $MODE"
echo "Supprimer historique: $SUPPHIST"

if [ "$SUPPHIST" = "-c" ]
   then
      # Suppression des fichiers exportés lors d'un lancement précédent.
      rm -r -f $HOME/export/tmp/* >/dev/null || true 
fi

export HADOOP_CLIENT_OPTS=" -Xmx3072m"

for ((i=1;i<=$PASSES;i++));

do

   echo "Début - Passe - #$i"

   # Retrait de 1 serveur au hasard de la liste.
   SERVEURS=("${SERVEURS_TOUS[@]}");
   RND=$(( $RANDOM % ${#SERVEURS[@]}))

   # Création des répertoires.
   REP_EXPORT=$HOME/export/tmp/$(date +%Y%m%d_%H%M%S)
   SCP_FICHIER=$(date +%Y%m%d) 

   echo "$COLLECTL_DTDEBUT:$COLLECTL_HRDEBUT"
   echo $SCP_FICHIER  
   echo $REP_EXPORT
   mkdir -p $REP_EXPORT

   mkdir -p  $REP_EXPORT/colele01;
   mkdir -p  $REP_EXPORT/colbec01;
   mkdir -p  $REP_EXPORT/mdl_user;
   mkdir -p  $REP_EXPORT/mdl_grade_grades;
   mkdir -p  $REP_EXPORT/venpq_mpulse_rapport;
   mkdir -p  $REP_EXPORT/_logs;
   mkdir -p  $REP_EXPORT/_collectl;
   
   # Liste des pipelines.
   echo "Pipelines au début du script:" >> $REP_EXPORT/_logs/pipelines.log
   $OBH/bin/ozone admin pipeline list >> $REP_EXPORT//_logs/pipelines.log

   # Utilisation des datanodes.
   echo "Datanodes au début du script:" >> $REP_EXPORT/_logs/datanodes.log
   $OBH/bin/ozone admin datanode usageinfo -c=7 -m >> $REP_EXPORT/_logs/datanodes.log

   # Liste des conteneurs.
   echo "Conteneurs au début du script:" >> $REP_EXPORT/_logs/containers.log
   $OBH/bin/ozone admin container list -c=1000000 >> $REP_EXPORT/_logs/containers.log

   # Rapport sommaire des conteneurs. 1.3.0 uniquement.
   echo "Conteneurs - Rapport au début du script:" >> $REP_EXPORT/_logs/cont_rapport.log
   $OBH/bin/ozone admin container report >> $REP_EXPORT/_logs/cont_rapport.log

   # Génération de la liste des serveurs de façon aléatoire.
   x=1
   while [ $x -le 10 ]
      do

         RND=$(( $RANDOM % ${#SERVEURS[@]} ))

         LISTE=("${LISTE[@]}" "${SERVEURS[$RND]}")
          

         x=$(( $x + 1 ))
   done

   # Génération des variables de durée aléatoires.

   # serv1 - Processeur
   serv1var1=$(( $RANDOM % 30 + 50 ))
   serv1var2=$(( $RANDOM % 90 + 30 ))

   # serv2 - Mémoire
   serv2var1=$(( $RANDOM % 1024 + 1024 ))
   serv2var2=$(( $RANDOM % 90 + 30 ))

   # serv3 - Espace disque
   serv3var1=$(( $RANDOM % 2 + 6 ))

   # serv4 - Arrêt du service DN

   # serv5 - Délai
   serv5var1=$(( $RANDOM % 50 + 50 ))
   serv5var2=$(( $RANDOM % 10 + 10 ))

   # serv6 - Perte de paquets
   serv6var1=$(( $RANDOM % 15 + 15 ))
   serv6var2=$(( $RANDOM % 10 + 10 ))

   # serv8 - Sleep / reboot
   serv8var1=$(( $RANDOM % 90 + 30 ))


   # serv9 - Corruption de paquets
   serv9var1=$(( $RANDOM % 10 + 1 ))
 

   # Suppression du stagingdir dans Ozone.
   $OBH/bin/ozone fs -rm -r o3fs://buckhive.volo3fs.localhost/tmp

   # Tronquer le log Hive.
   truncate -s 0 /tmp/USERNAME/hive.log

   if [ "$MODE" = "-s" ]
      then
	  
         echo "MODE TEST DES SABOTAGES"
         $HIVE_HOME/bin/hive -f $HOME/scripts/test.hql --hivevar collectl_dtdebut=$COLLECTL_DTDEBUT --hivevar collectl_hrdebut=$COLLECTL_HRDEBUT --hivevar repexport=$REP_EXPORT --hivevar scpfichier=$SCP_FICHIER --hivevar serv1=${LISTE[0]} --hivevar serv1var1=$serv1var1 --hivevar serv1var2=$serv1var2 --hivevar serv2=${LISTE[1]} --hivevar serv2var1=$serv2var1 --hivevar serv2var2=$serv2var2 --hivevar serv3=${LISTE[2]} --hivevar serv3var1=$serv3var1 --hivevar serv4=${LISTE[3]} --hivevar serv5=${LISTE[4]} --hivevar serv5var1=$serv5var1 --hivevar serv5var2=$serv5var2 --hivevar serv6=${LISTE[5]} --hivevar serv6var1=$serv6var1 --hivevar serv6var2=$serv6var2 --hivevar serv7=${LISTE[6]} --hivevar serv8=${LISTE[7]} --hivevar serv8var1=$serv8var1 --hivevar serv9=${LISTE[8]} --hivevar serv9var1=$serv9var1 --hivevar serv10=${LISTE[9]}
      
	  else

         if [ "$MODE" = "-o" ] 
            then   

               echo "MODE OPÉRATIONS"
               $HIVE_HOME/bin/hive -f $HOME/scripts/crud.hql --hivevar collectl_dtdebut=$COLLECTL_DTDEBUT --hivevar collectl_hrdebut=$COLLECTL_HRDEBUT --hivevar repexport=$REP_EXPORT --hivevar scpfichier=$SCP_FICHIER --hivevar serv1=${LISTE[0]} --hivevar serv1var1=$serv1var1 --hivevar serv1var2=$serv1var2 --hivevar serv2=${LISTE[1]} --hivevar serv2var1=$serv2var1 --hivevar serv2var2=$serv2var2 --hivevar serv3=${LISTE[2]} --hivevar serv3var1=$serv3var1 --hivevar serv4=${LISTE[3]} --hivevar serv5=${LISTE[4]} --hivevar serv5var1=$serv5var1 --hivevar serv5var2=$serv5var2 --hivevar serv6=${LISTE[5]} --hivevar serv6var1=$serv6var1 --hivevar serv6var2=$serv6var2 --hivevar serv7=${LISTE[6]} --hivevar serv8=${LISTE[7]} --hivevar serv8var1=$serv8var1 --hivevar serv9=${LISTE[8]} --hivevar serv9var1=$serv9var1 --hivevar serv10=${LISTE[9]}
			   
         else

               echo "MODE SABOTAGES"
               $HIVE_HOME/bin/hive -f $HOME/scripts/sab.hql --hivevar collectl_dtdebut=$COLLECTL_DTDEBUT --hivevar collectl_hrdebut=$COLLECTL_HRDEBUT --hivevar repexport=$REP_EXPORT --hivevar scpfichier=$SCP_FICHIER --hivevar serv1=${LISTE[0]} --hivevar serv1var1=$serv1var1 --hivevar serv1var2=$serv1var2 --hivevar serv2=${LISTE[1]} --hivevar serv2var1=$serv2var1 --hivevar serv2var2=$serv2var2 --hivevar serv3=${LISTE[2]} --hivevar serv3var1=$serv3var1 --hivevar serv4=${LISTE[3]} --hivevar serv5=${LISTE[4]} --hivevar serv5var1=$serv5var1 --hivevar serv5var2=$serv5var2 --hivevar serv6=${LISTE[5]} --hivevar serv6var1=$serv6var1 --hivevar serv6var2=$serv6var2 --hivevar serv7=${LISTE[6]} --hivevar serv8=${LISTE[7]} --hivevar serv8var1=$serv8var1 --hivevar serv9=${LISTE[8]} --hivevar serv9var1=$serv9var1 --hivevar serv10=${LISTE[9]}

         fi  

   fi

   # Collectl.
   echo "* Initialisaion des journaux Collectl. *"
   pdsh -w 10.10.28.13[0-6] sudo rm -r '/var/log/collectl/tmp/*'

   echo "* Création des fichiers pour Colplot depuis $COLLECTL_DTDEBUT à $COLLECTL_HRDEBUT. *"
   pdsh -w 10.10.28.13[0-6] sudo collectl -scdn -p "'/var/log/collectl/*$COLLECTL_DTDEBUT*.raw.gz'" --from $COLLECTL_DTDEBUT:$COLLECTL_HRDEBUT-$COLLECTL_DTDEBUT:23:59 -oTm -f /var/log/collectl/tmp/Collectl -P

#   sleep 300

   echo "* Récupération des journaux Collectl. *"
   rpdcp -w 10.10.28.13[0-6] '/var/log/collectl/tmp/*.tab.gz' $REP_EXPORT/_collectl/

   # Journaux des noeuds.
   echo "* Récupération des journaux des noeuds. *"
   rpdcp -w 10.10.28.13[0-6] "$OBH/logs/ozone-USERNAME-datanode-servozone0*.log" $REP_EXPORT/_logs/

   # Liste des pipelines.
   echo "Pipelines à la fin du script:" >> $REP_EXPORT/_logs/pipelines.log
   $OBH/bin/ozone admin pipeline list >> $REP_EXPORT/_logs/pipelines.log

   # Utilisation des datanodes.
   echo "Datanodes à la fin du script:" >> $REP_EXPORT/_logs/datanodes.log
   $OBH/bin/ozone admin datanode usageinfo -c=7 -m >> $REP_EXPORT/_logs/datanodes.log

   # Liste des conteneurs.
   echo "Conteneurs à la fin du script:" >> $REP_EXPORT/_logs/containers.log
   $OBH/bin/ozone admin container list -c=1000000 >> $REP_EXPORT/_logs/containers.log

   # Liste des clés.
   echo "Clés à la fin du script:" >> $REP_EXPORT/_logs/keys.log
   $OBH/bin/ozone sh key list /volo3fs/buckhive -l=1000 >> $REP_EXPORT/_logs/keys.log

   # Rapport sommaire des conteneurs. 1.3.0 uniquement.
   echo "Conteneurs - Rapport à la fin du script:" >> $REP_EXPORT/_logs/cont_rapport.log
   $OBH/bin/ozone admin container report >> $REP_EXPORT/_logs/cont_rapport.log

   # Validation des sommes de contrôle.
   $HOME/export/validation.sh $REP_EXPORT > $REP_EXPORT/validation.log

   # Récupération des journaux SCM et OM.
   cp /tmp/USERNAME/hive.log $REP_EXPORT/_logs/hive.log
   cp $OBH/logs/ozone-USERNAME-scm-servozone01.log $REP_EXPORT/_logs/scm.log
   cp $OBH/logs/ozone-USERNAME-om-servozone01.log $REP_EXPORT/_logs/om.log

   # Suppression des fichiers temporaires locaux.
   rm -r -f /hdd2/data/hdfs/mapred/local/localRunner/*
   rm -r -f /hdd2/data/hdfs/mapred/staging/*

echo "Fin - Passe - #$i"

done

duration=$SECONDS

echo "Durée totale: $(($duration / 60)) minutes et $(($duration % 60)) seconde(s)"
echo "*** Fin du script bash - $(date +%F) $(date +%T) ***"

# Copie du journal d'audits.
cp $HOME/scripts/journal.log $REP_EXPORT/journal.log
