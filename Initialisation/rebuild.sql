DROP DATABASE IF EXISTS o3fs CASCADE; 

CREATE DATABASE o3fs LOCATION 'o3fs://buckhive.volo3fs.localhost/' WITH DBPROPERTIES ('Auteur' = 'Nicolas Mathon', 'Date' = '2023-06-16', 'Description' = 'Base de données créée dans le système de fichier Ozone.');


DROP DATABASE IF EXISTS ozone CASCADE;

CREATE DATABASE ozone LOCATION 'o3fs://buckhive.volo3fs.localhost/' WITH DBPROPERTIES ('Auteur' = 'Nicolas Mathon', 'Date' = '2023-06-16', 'Description' = 'Base de données créée dans le système de fichier Ozone.');

USE o3fs;

CREATE EXTERNAL TABLE IF NOT EXISTS colele01
(hashid char(130), statuteleve char(1), sexe char(1))
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ';'
STORED AS TEXTFILE
LOCATION 'o3fs://buckhive.volo3fs.localhost/external/colele01/'
TBLPROPERTIES ("Auteur"="Nicolas Mathon","Source"="COBA.COLELE01","Description"="Table des étudiants du système COBA.");

CREATE EXTERNAL TABLE IF NOT EXISTS colbec01
(hashid char(130), anneemeq int, sessionmeq char(1), codemeq char(8), groupe string, notecours string, notecoursdec string, coderemarque string, moyennegroupe string, moygroupedec string, programmemeq char(5))
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ';'
STORED AS TEXTFILE
LOCATION 'o3fs://buckhive.volo3fs.localhost/external/colbec01/'
TBLPROPERTIES ("Auteur"="Nicolas Mathon","Source"="COBA.COLBEC01","Description"="Table des cours terminés du système COBA.");

-- MOODLE - MDL_USER
CREATE EXTERNAL TABLE IF NOT EXISTS mdl_user
(id bigint, hashid char(130), lastlogin bigint)
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ';'
STORED AS TEXTFILE
LOCATION 'o3fs://buckhive.volo3fs.localhost/external/mdl_user/'
TBLPROPERTIES ("Auteur"="Nicolas Mathon","Source"="MOODLE.MDL_USER","Description"="Table des utilisateurs du système MOODLE.");

-- MOODLE - MDL_GRADE_GRADES
CREATE EXTERNAL TABLE IF NOT EXISTS mdl_grade_grades
(itemid bigint, hashid char(130), userid bigint, finalgrade decimal(10, 4))
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ';'
STORED AS TEXTFILE
LOCATION 'o3fs://buckhive.volo3fs.localhost/external/mdl_grade_grades/'
TBLPROPERTIES ("Auteur"="Nicolas Mathon","Source"="MOODLE.MDL_GRADE_GRADES","Description"="Table des notes finales du système MOODLE.");

-- CECAP - VENPQ_MPulse_Rapport
CREATE EXTERNAL TABLE IF NOT EXISTS venpq_mpulse_rapport
(hashid char(130), hashnorme char(130), echelle string, coefris decimal(10, 4))
ROW FORMAT DELIMITED
FIELDS TERMINATED BY ';'
STORED AS TEXTFILE
LOCATION 'o3fs://buckhive.volo3fs.localhost/external/venpq_mpulse_rapport/'
TBLPROPERTIES ("Auteur"="Nicolas Mathon","Source"="CECAP.vENPQ_MPulse_Rapport","Description"="Vue des résultats au test psychométrique MPULSE du système CECAP.");
