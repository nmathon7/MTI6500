!echo * Début du script Hive - SABOTAGES *;
!echo ;
!${env:OBH}/bin/ozone version
!echo ;
SET hive.execution.engine=MR;
set hive.exec.mode.local.auto.inputbytes.max = 200000000;
set hive.exec.mode.local.auto.input.files.max=100;
SET hive.support.concurrency=true;
SET hive.txn.manager=org.apache.hadoop.hive.ql.lockmgr.DbTxnManager;
SET hive.enforce.bucketing=true;
SET hive.exec.dynamic.partition.mode=nonstrict;
SET hive.compactor.initiator.on=true;
SET hive.compactor.worker.threads=1;

!echo * Validation des connexions SSH. *;
!pdsh -w 000.000.000.13[0-6] hostname;
!echo ;

!echo * Liste des variables pour export. *;
!echo Répertoire export: ${hivevar:repexport};
!echo Fichier collectl: ${hivevar:scpfichier};
!echo Collectl date début: ${hivevar:collectl_dtdebut};
!echo Collectl heure début: ${hivevar:collectl_hrdebut};
!echo ;
!echo * Liste des serveurs pour les sabotages. *;
!echo Serveur #1 (Stress-NG CPU) : ${hivevar:serv1};
!echo Serveur #2 (Stress-NG Mem) : ${hivevar:serv2};
!echo Serveur #3 (Fallocate)     : ${hivevar:serv3};
!echo Serveur #4 (Stop DN)       : ${hivevar:serv4};
!echo Serveur #5 (Netem delay)   : ${hivevar:serv5};
!echo Serveur #6 (Netem loss)    : ${hivevar:serv6};
!echo Serveur #7 (TBF)           : ${hivevar:serv7};
!echo Serveur #8 (Shutdown -r +m): ${hivevar:serv8};
!echo Serveur #9 (Corruption)    : ${hivevar:serv9};
!echo Serveur #10: (Reboot)      : ${hivevar:serv10};
!echo ;

!echo * Liste des variables *;
!echo Serveur #1: var1: ${hivevar:serv1var1} | var2: ${hivevar:serv1var2};
!echo Serveur #2: var1: ${hivevar:serv2var1} | var2: ${hivevar:serv2var2};
!echo Serveur #3: var1: ${hivevar:serv3var1};
!echo Serveur #4: - ;
!echo Serveur #5: var1: ${hivevar:serv5var1} | var2: ${hivevar:serv5var2};
!echo Serveur #6: var1: ${hivevar:serv6var1} | var2: ${hivevar:serv6var2};
!echo Serveur #7: -;
!echo Serveur #8: var1: ${hivevar:serv8var1};
!echo Serveur #9: var1: ${hivevar:serv9var1};
!echo Serveur #10: -;
!echo ;

-- Création des répertoires.
--!mkdir -p  ${hivevar:repexport}/colele01;
--!mkdir -p  ${hivevar:repexport}/colbec01;
--!mkdir -p  ${hivevar:repexport}/mdl_user;
--!mkdir -p  ${hivevar:repexport}/mdl_grade_grades;
--!mkdir -p  ${hivevar:repexport}/venpq_mpulse_rapport;
--!mkdir -p  ${hivevar:repexport}/_logs;
--!mkdir -p  ${hivevar:repexport}/_collectl;
--!echo ;

-- Réinitialiser les sabotages réseau.
!pdsh -w 000.000.000.13[0-6] sudo tc qdisc del dev ens160 root || true; 

!echo * Tronquer les fichiers audits *;
!pdsh -w 000.000.000.13[0-6] truncate -s 0 ${env:OBH}/logs/ozone-user-datanode-servozone0*.log;
!truncate -s 0 ${env:OBH}/logs/ozone-user-scm-servozone01.log;
!truncate -s 0 ${env:OBH}/logs/ozone-user-om-servozone01.log;

--!echo *** Pause vérification ***;
--select reflect("java.lang.Thread", "sleep", bigint(15000));

use ozone;

!echo Démarrage dans 60 secondes.;
select reflect("java.lang.Thread", "sleep", bigint(60000));

-- Ménage des tables temporaires.
!echo * Suppression tables temporaires *;
drop table if exists tmpcolele01;
drop table if exists tmpcolele01_2;
drop table if exists tmpcolbec01;
drop table if exists tmpmdl_grade_grades;
drop table if exists tmpenpq_mpulse_rapport;

-- Création des tables gérées.
!echo * Création des tables gérées. *;

-- colele01
drop table if exists colele01;
create table colele01 (hashid char(130), statuteleve char(1), sexe char(1)) clustered by (hashid) into 1 buckets stored as orc TBLPROPERTIES ('transactional'='true', 'Auteur'='Nicolas Mathon','Source'='COBA.COLELE01','Description'='Table des étudiants du système COBA.');
insert into colele01 select * from o3fs.colele01 order by hashid;

-- colbec01
drop table if exists colbec01;
create table colbec01 (hashid char(130), anneemeq int, sessionmeq char(1), codemeq char(8), groupe string, notecours string, notecoursdec string, coderemarque string, moyennegroupe string, moygroupedec string, programmemeq char(5)) clustered by (hashid) into 1 buckets stored as orc TBLPROPERTIES ('transactional'='true', 'Auteur'='Nicolas Mathon','Source'='COBA.COLBEC01','Description'='Table des cours terminés du système COBA.');
insert into colbec01 select * from o3fs.colbec01 order by HashID, anneemeq, sessionmeq, codemeq, groupe;

-- mdl_user
drop table if exists mdl_user;
create table mdl_user (id bigint, hashid char(130), lastlogin bigint) clustered by (hashid) into 1 buckets stored as orc TBLPROPERTIES ('transactional'='true', 'Auteur'='Nicolas Mathon','Source'='MOODLE.MDL_USER','Description'='Table des utilisateurs du système MOODLE.');
insert into mdl_user select * from o3fs.mdl_user order by hashid;

-- mdl_grade_grades
drop table if exists mdl_grade_grades;
create table mdl_grade_grades (itemid bigint, hashid char(130), userid bigint, finalgrade decimal(10, 4)) clustered by (hashid) into 1 buckets stored as orc TBLPROPERTIES ('transactional'='true', 'Auteur'='Nicolas Mathon','Source'='MOODLE.MDL_GRADE_GRADES','Description'='Table des notes finales du système MOODLE.');
insert into mdl_grade_grades select * from o3fs.mdl_grade_grades order by hashid, itemid;

-- venpq_mpulse_rapport
drop table if exists venpq_mpulse_rapport;
create table venpq_mpulse_rapport (hashid char(130), hashnorme char(130), echelle string, coefris decimal(10, 4)) clustered by (hashid) into 1 buckets stored as orc TBLPROPERTIES ('transactional'='true', 'Auteur'='Nicolas Mathon','Source'='CECAP.vENPQ_MPulse_Rapport','Description'='Vue des résultats au test psychométrique MPULSE du système CECAP.');
insert into venpq_mpulse_rapport select * from o3fs.venpq_mpulse_rapport order by hashid, hashnorme, echelle;


--!${env:OBH}/bin/ozone admin pipeline list;
-- SABOTAGE #1 - Stress-NG - CPU à X% pendant Y secondes.
!date;
!echo * 1 - Stress-NG CPU  ${hivevar:serv1var1}% pendant ${hivevar:serv1var2} secondes - ${hivevar:serv1} *;
!tmux new -d sudo -u ozone ssh ozone@${hivevar:serv1} stress-ng -c 1 -l ${hivevar:serv1var1} -t ${hivevar:serv1var2}s;

-- *** Début des opérations sur colele01. ***
!echo * Début des opérations sur colele01. *;

!echo * Ajout colonne *;
-- Ajout d'une colonne
alter table colele01 add columns (age int);

!echo * MAJ valeur defaut *;
-- Mise a jour avec une valeur par defaut.
update colele01 set age = 0;

!echo * Modif nom colonne *;
-- Modification du nom de la colonne.
alter table colele01 change age agemod int;

--!${env:OBH}/bin/ozone admin pipeline list;
-- SABOTAGE #2 - Stress-NG - Mémoire +X Mo pendant Y secondes.
!date;
!echo * 2 - Stress-NG Mémoire +${hivevar:serv2var1} Mo pendant ${hivevar:serv2var2} secondes - ${hivevar:serv2} *;
!tmux new -d sudo -u ozone ssh ozone@${hivevar:serv2} stress-ng --vm 1 --vm-bytes ${hivevar:serv2var1}M -t ${hivevar:serv2var2}s;

-- Suppression d'une colonne. Impossible de faire cela avec ORCSerde
!echo * Suppression colonne *;
drop table if exists tmpcolele01;
create table tmpcolele01 (hashid char(130), statuteleve char(1), sexe char(1), age int);
insert into tmpcolele01 select * from colele01 order by hashid;
alter table tmpcolele01 replace columns (hashid char(130), statuteleve char(1), sexe char(1));
delete from colele01;
drop table colele01;
create table colele01 (hashid char(130), statuteleve char(1), sexe char(1)) clustered by (hashid) into 1 buckets stored as orc TBLPROPERTIES ('transactional'='true', 'Auteur'='Nicolas Mathon','Source'='COBA.COLELE01','Description'='Table des étudiants du système COBA.');
insert into colele01 select * from tmpcolele01 order by hashid;

!echo * Suppression etudiant *;
-- Suppression des étudiants aux statut D - Décédé.
delete from colele01 where STATUTELEVE = 'D';

!echo * MAJ statuts *;
-- Mise à jour des statuts Inactif (I) à Actif (A).
update ozone.colele01 set statuteleve = 'A' where statuteleve='I';

!echo * Ajout etudiant *;
-- Ajout d'un étudiant.
drop table if exists tmpcolele01_2;
create table tmpcolele01_2 (id int, hashid char(130));
insert into tmpcolele01_2 select 1, concat('0x',upper(sha2('test12345678', 512)));
insert into colele01 select hashid, 'I', 'M' from tmpcolele01_2 where id = 1;

-- *** Fin des opérations sur colele01. ***

-- *** Début des opérations sur colbec01. ***
!echo * Début des opérations sur colbec01. *;

!echo * MAJ notes *;
-- 1 - Mise à jour des notes 59 à 60.
update colbec01 set notecours = cast((notecours+1) as int) where notecours = '59';

!echo * Suppression programmes base *;
-- 2 - Suppression des résultats des programmes de base (BAS00 et BASE0).
delete from colbec01 where programmemeq in ('BAS00', 'BASE0');

--!${env:OBH}/bin/ozone admin pipeline list;
-- SABOTAGE #3 - Remplissage du disque.
!date;
!echo * 3 - Fallocate /hdd2/ - Remplissage +${hivevar:serv3var1} Go fin du script. - ${hivevar:serv3} *;
!tmux new -d sudo -u ozone ssh ozone@${hivevar:serv3} sudo fallocate -l ${hivevar:serv3var1}G /hdd2/fichier.test || true;

!echo * Ajout notes nouvel etudiant *;
-- 3 - Ajout des notes de l'étudiant créé précédemment en copiant celles d'un autre étudiant (70).
insert into colbec01
select '0x53ED1D440AC5A799387AC50CF01F234ACCA80261F436D852DEE41298835 38F380863A2815E3A502C54A8359D3F7E337B3F6F40EA53E81CF38C820AEB47DB92D8', anneemeq, sessionmeq, codemeq, groupe, notecours, notecoursdec, coderemarque, moyennegroupe, moygroupedec, programmemeq
from colbec01 where hashid='0xE8FFC5DC5D0BAB527D1968B148FA9B89091CBF4CF91B3911F616736C326 98388E38B33F3F06C80374725FDF2E6520EA9334947D45C1D9A599192EAD4487077AF';

!echo * Modification type colonne *;
-- 4 - Modifier le type de la colonne sessionmeq.
alter table colbec01 change sessionmeq sessionmeq string;

--!${env:OBH}/bin/ozone admin pipeline list;
-- SABOTAGE #4 - Arrêt d'une Datanode jusqu'à la fin du script.
!date;
!echo * 4 - Arrêt DN - ${hivevar:serv4} *;
--!tmux new -d sudo -u ozone ssh ozone@${hivevar:serv4} sudo -u user $OBH/bin/ozone --daemon stop datanode;
!pdsh -w ${hivevar:serv4} sudo -u user ${env:OBH}/bin/ozone --daemon stop datanode;

!echo * Suppression moyennes *;
-- 5 - Suppression des champs des moyennes. Impossible de faire cela avec ORCSerde
drop table if exists tmpcolbec01;
create table tmpcolbec01 (hashid char(130), anneemeq int, sessionmeq string, codemeq char(8), groupe string, notecours string, notecoursdec string, coderemarque string, moyennegroupe string, moygroupedec string, programmemeq char(5));
-- Ici on a inversé les 2 lignes ci-dessous pour retirer la colonne avant l'ajout des données sinon le PROGRAMMEMEQ était aussi supprimé.
alter table tmpcolbec01 replace columns (hashid char(130), anneemeq int, sessionmeq string, codemeq char(8), groupe string, notecours string, notecoursdec string, coderemarque string, programmemeq char(5));
insert into tmpcolbec01 select hashid, anneemeq, sessionmeq, codemeq, groupe, notecours, notecoursdec, coderemarque, programmemeq from colbec01 order by HashID, anneemeq, sessionmeq, codemeq, groupe;
delete from colbec01;
drop table colbec01;
create table colbec01 (hashid char(130), anneemeq int, sessionmeq char(1), codemeq char(8), groupe string, notecours string, notecoursdec string, coderemarque string, programmemeq char(5)) clustered by (hashid) into 1 buckets stored as orc TBLPROPERTIES ('transactional'='true', 'Auteur'='Nicolas Mathon','Source'='COBA.COLBEC01','Description'='Table des cours terminés du système COBA.');
insert into colbec01 select * from tmpcolbec01 order by HashID, anneemeq, sessionmeq, codemeq, groupe;

-- *** Fin des opérations sur colbec01. ***

--!${env:OBH}/bin/ozone admin pipeline list;
-- SABOTAGE #5 - Ajout d'un délai sur la carte réseau d'une Datanode.
!date;
!tmux new -d sudo -u ozone ssh ozone@${hivevar:serv5} sudo tc qdisc del dev ens160 root || true;
!echo * 5 - TC/Netem - Délais réseau ${hivevar:serv5var1} ms plus ou moins ${hivevar:serv5var2} ms - ${hivevar:serv5} *;
!tmux new -d sudo -u ozone ssh ozone@${hivevar:serv5} sudo tc qdisc add dev ens160 root netem delay ${hivevar:serv5var1}ms ${hivevar:serv5var2}ms distribution normal;
!pdsh -w ${hivevar:serv5} sudo tc -s -d qdisc show dev ens160 || true;

-- *** Début des opérations sur mdl_user. ***
!echo * Début des opérations sur mdl_user. *;

!echo * Ajout colonne nbrjours *;
-- 1 - Ajout d'un champ nbrjours pour calculer le nombre de jours depuis la dernière connexion (lastlogin).
alter table mdl_user add columns (nbrjours int);

!echo * MAJ nbrjours *;
-- 2 - Mise à jour des enregistrements de la colonne NbrJours. Une valeur de -1 signifie que la personne ne s'est jamais connectée.
-- select to_date(from_unixtime(lastlogin)) from mdl_user limit 10;
-- Ci-dessous est en fonction du jour de l'exécution. Pour plus de simplicité pour ne pas regénérer les données à chaque jour, cette date a été fixée au 2022-01-01 (1641013200) par un timestamp statique.
-- update mdl_user set nbrjours = if (lastlogin=0,-1,datediff(to_date(current_timestamp()), to_date(to_utc_timestamp(from_unixtime(lastlogin),'America/Montreal'))));
update mdl_user set nbrjours = if (lastlogin=0,-1,datediff(to_date(to_utc_timestamp(from_unixtime(1641013200), 'America/Montreal')), to_date(to_utc_timestamp(from_unixtime(lastlogin),'America/Montreal'))));

--select current_timestamp(), to_utc_timestamp(from_unixtime(lastlogin),'America/Montreal'), datediff(to_date(current_timestamp()), to_date(to_utc_timestamp(from_unixtime(lastlogin),'America/Montreal'))) from mdl_user where id=12855;

!echo * Suppression nbrjours *;
-- 3 - Delete nbrjours > 1826 -- 35 137
-- select count(*) from mdl_user where ((nbrjours > 1826) or (nbrjours = -1));
delete from mdl_user where ((nbrjours > 1826) or (nbrjours = -1));

--!${env:OBH}/bin/ozone admin pipeline list;

-- SABOTAGE #6 - Ajout d'une perte de paquets sur la carte réseau d'une Datanode.
!date;
!tmux new -d sudo -u ozone ssh ozone@${hivevar:serv6} sudo tc qdisc del dev ens160 root || true;
!echo * 6 - TC/Netem - Perte de paquets réseau - ${hivevar:serv6var1}% probablité ${hivevar:serv6var2}% - ${hivevar:serv6} *;
!tmux new -d sudo -u ozone ssh ozone@${hivevar:serv6} sudo tc qdisc add dev ens160 root netem loss ${hivevar:serv6var1}% ${hivevar:serv6var2}%;
!pdsh -w ${hivevar:serv6} sudo tc -s -d qdisc show dev ens160 || true;

!echo * Renommer nbrjours  *;
-- 4 - Renommer la colonne nbrjours pour nbrannees et modifier le type.
-- alter table colele01 change nbrjours nbrannees decimal(10,4);
alter table mdl_user add columns (nbrannees decimal(10,4));

!echo * MAJ nbrannees *;
-- 5 - Mise à jour du nombre d'années.
-- Arrondissement à 2 décimales seulement car Hive arrondissait automatiquement les 4 décimales en fonction de la cinquième lors de la division.
--SELECT to_date(from_unixtime(lastlogin, 'yyyy-MM-dd HH:mm:ss')), lastlogin from mdl_user where id=12855;
--update mdl_user set nbrannees = round((nbrjours / 365.25),2);
update mdl_user set nbrannees = cast((cast(nbrjours as decimal(10,4))/ cast(365.25 as decimal(10,4))) as decimal(10,4));

-- *** Fin des opérations sur mdl_user. ***

-- *** Début des opérations sur mdl_grade_grades. ***
!echo * Début des opérations sur mdl_grade_grades. *;

!echo * Supprimer notes 0 *;
-- 1 - Supprimer les résultats à 0. -- 710 609
-- select count(*) from mdl_grade_grades where finalgrade = 0; -- 710609
delete from mdl_grade_grades where finalgrade = 0;

!echo * Ajout colonne notes arrondies *;
-- 2 - Création d'un nouveau champ avec des notes arrondies à 2 décimales.
alter table mdl_grade_grades add columns (fgarrondie decimal(10,2));

!echo * MAJ notes arrondies *;
-- 3 - Mise à jour des données arrondies.
update mdl_grade_grades set fgarrondie = round(finalgrade,2);

--!${env:OBH}/bin/ozone admin pipeline list;
-- SABOTAGE #7 - Réduction de la bande passante d'une Datanode.
!echo * 7 - TBF - ${hivevar:serv7} *;
!tmux new -d sudo -u ozone ssh ozone@${hivevar:serv5} sudo tc qdisc del dev ens160 root || true;
!date;
!tmux new -d sudo -u ozone ssh ozone@${hivevar:serv7} sudo tc qdisc add dev ens160 root tbf rate 128kbit burst 16kbit latency 50ms;
!pdsh -w ${hivevar:serv7} sudo tc -s -d qdisc show dev ens160 || true;

!echo * Calcul des moyennes *;
-- 4 - Calcule moyennes

create table tmpmdl_grade_grades as
select q.hashid, cast(round(avg(q.fgarrondie), 2) as decimal(10,2)) as moyenne
from (
select hashid, fgarrondie
from mdl_grade_grades) q
group by q.hashid
order by q.hashid;

!echo * Suppression mdl_grade_grades *;
-- 5 - Supprimer le table mdl_grade_grades et renommer la table temporaire.
drop table if exists mdl_grade_grades;
alter table tmpmdl_grade_grades rename to mdl_grade_grades;

-- *** Fin des opérations sur mdl_grade_grades. ***

-- *** Début des opérations sur venpq_mpulse_rapport. ***
!echo * Début des opérations sur venpq_mpulse_rapport. *;

!echo * Suppression echelles *;
-- 1 - Supprimer des échelles.
-- select distinct(echelle) from venpq_mpulse_rapport where echelle rlike '^[f][0-9]';
delete from venpq_mpulse_rapport where echelle rlike '^[f][0-9]';

!echo * Supprimer donnees echelles coefris 0 *;
-- 2 - Supprimer les données des échelles dont la moyenne de coefris est 0.
-- select code as moyenne from capp.dbo.enpq_mpulse_rapport group by code having avg(coefris) = 0
-- select count(*) from capp.dbo.enpq_mpulse_rapport where code in (select code as moyenne from capp.dbo.enpq_mpulse_rapport group by code having avg(coefris) = 0) -- 34552

delete from venpq_mpulse_rapport where echelle in (select echelle from venpq_mpulse_rapport group by echelle having avg(coefris) = 0); 
-- 34552

--!${env:OBH}/bin/ozone admin pipeline list;
-- SABOTAGE #8 - Redémarrage d'une Datanode au hasard avec délai.
!echo * 8 - Redémarrage avec délai  - ${hivevar:serv8} - ${hivevar:serv8var1} secondes *;
!date;
-- Malheureusement shutdown termine la connexion avec une erreur et le script arrête.
!tmux new -d sudo -u ozone ssh ozone@${hivevar:serv8} sleep ${hivevar:serv8var1} && sudo reboot;

!echo * Supprimer coefris 0 *;
-- 3 - Suppression des enregistrements a 0 pour ne pas affecter les moyennes.
delete from venpq_mpulse_rapport where coefris = 0; 
-- 141430

--!${env:OBH}/bin/ozone admin pipeline list;
-- SABOTAGE #9 -Corruption de paquets au hasard.
!echo * 9 - Corruption - ${hivevar:serv9} - ${hivevar:serv9var1}% *;
!tmux new -d sudo -u ozone ssh ozone@${hivevar:serv9} sudo tc qdisc del dev ens160 root || true;
!date;
!tmux new -d sudo -u ozone ssh ozone@${hivevar:serv9} sudo tc qdisc add dev ens160 root netem corrupt ${hivevar:serv9var1}%;
!pdsh -w ${hivevar:serv9} sudo tc -s -d qdisc show dev ens160 || true;

!echo * Selectionner min et max *;
-- 4 - Sélection des min/max/moyenne de chaque échelle dans une table temporaire
create table tmpenpq_mpulse_rapport as
select *
from (
select echelle, 'min' as type, min(coefris) as valeur from venpq_mpulse_rapport group by echelle
union
select echelle, 'max' as type, max(coefris) as valeur from venpq_mpulse_rapport group by echelle
union
select echelle, 'moyenne' as type, max(coefris) as valeur from venpq_mpulse_rapport group by echelle) q
order by q.echelle, type;

--!${env:OBH}/bin/ozone admin pipeline list;
-- SABOTAGE #10 - Redémarrage d'une Datanode au hasard.
!echo * 10 - Redémarrage de noeud au hasard - ${hivevar:serv10} *;
!date;
!tmux new -d sudo -u ozone ssh ozone@${hivevar:serv10} sudo reboot;

!echo * Supprimer et renommer table. *;
-- 5 - Drop et rename
drop table venpq_mpulse_rapport;
alter table tmpenpq_mpulse_rapport rename to venpq_mpulse_rapport;

-- *** Fin des opérations sur venpq_mpulse_rapport. ***

!echo Temps de pause 1/2 le temps que les noeuds soient redémarrés et synchronisés (2 minutes)...;
select reflect("java.lang.Thread", "sleep", bigint(120000));

-- Réinitialisation des sabotages.
!date;
--!tmux new -d sudo -u ozone ssh ozone@${hivevar:serv4} sudo -u user /home/user/ozone-1.2.1/bin/ozone --daemon start datanode;
!pdsh -w ${hivevar:serv4} sudo -u user ${env:OBH}/bin/ozone --daemon start datanode;

!tmux new -d sudo -u ozone ssh ozone@${hivevar:serv3} sudo rm -f /hdd2/fichier.test;

!pdsh -w 000.000.000.13[0-6] sudo tc qdisc del dev ens160 root;

!echo Temps de pause 2/2 le temps que les noeuds soient redémarrés et synchronisés (2 minutes)...;
select reflect("java.lang.Thread", "sleep", bigint(120000));

!echo * Export *;
-- Export des données.
insert overwrite local directory '${hivevar:repexport}/colele01/' row format delimited fields terminated by ';' select * from colele01 order by hashid;
insert overwrite local directory '${hivevar:repexport}/colbec01/' row format delimited fields terminated by ';' select * from colbec01 order by HashID, anneemeq, sessionmeq, codemeq, groupe;
insert overwrite local directory '${hivevar:repexport}/mdl_user/' row format delimited fields terminated by ';' select * from mdl_user order by HashID;
insert overwrite local directory '${hivevar:repexport}/mdl_grade_grades/' row format delimited fields terminated by ';' select * from mdl_grade_grades order by HashID;
insert overwrite local directory '${hivevar:repexport}/venpq_mpulse_rapport/' row format delimited fields terminated by ';' select * from venpq_mpulse_rapport order by echelle, type;

--!echo *  Arrêt du service Collectl. *;
--!pdsh -w 000.000.000.13[0-6] sudo systemctl stop collectl.service;

--!echo * Récupération des journaux Collectl. *;
--!pdsh -w 000.000.000.13[0-6] sudo rm -r /var/log/collectl/tmp/*;
--!pdsh -w 000.000.000.13[0-6] sudo cp "$(ls -t /var/log/collectl/*.raw.gz | head -1)" /var/log/collectl/tmp/"$(ls -t /var/log/collectl/*.raw.gz  | xargs -n 1 basename | head -1)";
--!rpdcp -w 000.000.000.13[0-6] /var/log/collectl/tmp/*.raw.gz ${hivevar:repexport}/_collectl/;
--!pdsh -w 000.000.000.13[0-6] sudo rm -r /var/log/collectl/tmp/*;

--!echo * Création des fichiers pour Colplot. *;
--set hivevar test:select 'collectl -scdn -p ''/var/log/collectl/*${hivevar:COLLECTL_DTDEBUT}*.raw.gz'' --from ${hivevar:COLLECTL_DTDEB>
--!pdsh -w 000.000.000.13[0-6] sudo collectl -scdn -p '/var/log/collectl/*${hivevar:collectl_dtdebut}*.raw.gz' --from ${hivevar:collectl_dtdebut}:${hivevar:collectl_hrdebut}- ${hivevar:collectl_dtdebut}:23:59 -oTm -f /var/log/collectl/tmp/Collectl -P;

--!echo * Récupération des journaux Collectl. *;
--!rpdcp -w 000.000.000.13[0-6] /var/log/collectl/tmp/*.tab.gz ${hivevar:repexport}/_collectl/;

--!echo * Démarrage du service Collectl. *;
--!pdsh -w 000.000.000.13[0-6] sudo systemctl start collectl.service;

-- Récupération des journaux des noeuds.
--!echo * Récupération des journaux des noeuds. *;
--!rpdcp -w 000.000.000.13[0-6] /home/user/ozone-1.2.1/logs/ozone-user-datanode-servozone0*.log ${hivevar:repexport}/_logs/;

-- Récupération des journaux OM et SCM.
--!echo * Récupération des journaux des noeuds. *;
--!cp ${env:OBH}/logs/ozone-user-om-servozone01.log ${hivevar:repexport}/_logs/;
--!cp ${env:OBH}/logs/ozone-user-scm-servozone01.log ${hivevar:repexport}/_logs/;

!date;
!echo * Fin du script Hive *
