#!/bin/bash

# Arrêt des DN.
pdsh -w 10.10.28.13[0-6] $HOME/stopdn.sh

# Arrêt SCM, OM et RECON (servozone01)
$OBH/bin/ozone --daemon stop recon
$OBH/bin/ozone --daemon stop om
$OBH/bin/ozone --daemon stop scm

# Initialisation des logs.
pdsh -w 10.10.28.13[0-6] sudo $HOME/logs.sh

# Initialisation des répertoires.
pdsh -w 10.10.28.13[0-6] sudo /hdd2/init.sh

# Initialisation et démarrage SCM.
$OBH/bin/ozone scm --init
$OBH/bin/ozone --daemon start scm

# Initialisation et démarrage OM.
$OBH/bin/ozone om --init
$OBH/bin/ozone --daemon start om

# Démarrage RECON.
$OBH/bin/ozone --daemon start recon

# Démarrage des DN.
pdsh -w 10.10.28.13[0-6] $HOME/startdn.sh

sleep 60

# Création du volume.
$OBH/bin/ozone sh volume create volo3fs

# Création du bucket.
$OBH/bin/ozone sh bucket create /volo3fs/buckhive

# Création de l'arborescence.

# External
$OBH/bin/ozone fs -mkdir o3fs://buckhive.volo3fs.localhost/external

# Colele01
$OBH/bin/ozone fs -mkdir o3fs://buckhive.volo3fs.localhost/external/colele01
$OBH/bin/ozone fs -put $HOME/import/colele01.csv o3fs://buckhive.volo3fs.localhost/external/colele01/colele01.csv

# Colbec01
$OBH/bin/ozone fs -mkdir o3fs://buckhive.volo3fs.localhost/external/colbec01
$OBH/bin/ozone fs -put $HOME/import/colbec01.csv o3fs://buckhive.volo3fs.localhost/external/colbec01/colbec01.csv

# MDL_User
$OBH/bin/ozone fs -mkdir o3fs://buckhive.volo3fs.localhost/external/mdl_user
$OBH/bin/ozone fs -put $HOME/import/mdl_user.csv o3fs://buckhive.volo3fs.localhost/external/mdl_user/mdl_user.csv

# MDL_Grade_Grades
$OBH/bin/ozone fs -mkdir o3fs://buckhive.volo3fs.localhost/external/mdl_grade_grades
$OBH/bin/ozone fs -put $HOME/import/mdl_grade_grades.csv o3fs://buckhive.volo3fs.localhost/external/mdl_grade_grades/mdl_grade_grades.csv

# VENPQ_MPulse_Rapport
$OBH/bin/ozone fs -mkdir o3fs://buckhive.volo3fs.localhost/external/venpq_mpulse_rapport
$OBH/bin/ozone fs -put $HOME/import/venpq_mpulse_rapport.csv o3fs://buckhive.volo3fs.localhost/external/venpq_mpulse_rapport/venpq_mpulse_rapport.csv

# Création de bases de données o3fs.

$HIVE_HOME/bin/hive -f rebuild.sql
