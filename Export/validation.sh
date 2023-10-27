#!/bin/bash
# 2022/12/11 - Changement de crc32 pour sha512sum en raison d'une erreur connue du script.
# https://unix.stackexchange.com/questions/481141/why-does-crc32-say-some-of-my-files-are-bad
# 2022-12-13 - Ajout du CRC avec rhash.

if [ $# -eq 1 ]

  then
    REP_EXPORT=$1

echo "*** Début de la validation des sommes de contrôle. ***"
echo ""
echo "Répertoire: $REP_EXPORT "
echo ""

valides=0
total=5

# COLBEC01

sha512sumtmp=$(sha512sum $REP_EXPORT/colbec01/000000_0 | awk '{print $1}')
sha512sumval=$(sha512sum $HOME/export/valides/colbec01 | awk '{print $1}')

crctmp=$(rhash -C --simple $REP_EXPORT/colbec01/000000_0 | awk '{print $1}')
crcval=$(rhash -C --simple $HOME/export/valides/colbec01 | awk '{print $1}')

sha512result="Invalide"

if [[ "$sha512sumtmp" == "$sha512sumval" ]]; then
   sha512result="Valide"
   ((valides++))
fi

echo "|-- COLBEC01"
echo "| |- Valeurs script"
echo "| |- Fichier SHA-512   : $sha512sumtmp"
echo "| |- Validation SHA-512: $sha512sumval"
echo "| |- Fichier CRC       : $crctmp"
echo "| |- Validation CRC    : $crcval"
echo "| |- Résultat          : $sha512result"
echo "|"

# COLELE01

sha512sumtmp=$(sha512sum $REP_EXPORT/colele01/000000_0 | awk '{print $1}')
sha512sumval=$(sha512sum $HOME/export/valides/colele01 | awk '{print $1}')

crctmp=$(rhash -C --simple $REP_EXPORT/colele01/000000_0 | awk '{print $1}')
crcval=$(rhash -C --simple $HOME/export/valides/colele01 | awk '{print $1}')

sha512result="Invalide"

if [[ "$sha512sumtmp" == "$sha512sumval" ]]; then
   sha512result="Valide"
   ((valides++))
fi

echo "|-- COLELE01"
echo "| |- Valeurs script"
echo "| |- Fichier SHA-512   : $sha512sumtmp"
echo "| |- Validation SHA-512: $sha512sumval"
echo "| |- Fichier CRC       : $crctmp"
echo "| |- Validation CRC    : $crcval"
echo "| |- Résultat          : $sha512result"
echo "|"


# MDL_GRADE_GRADES

sha512sumtmp=$(sha512sum $REP_EXPORT/mdl_grade_grades/000000_0 | awk '{print $1}')
sha512sumval=$(sha512sum $HOME/export/valides/mdl_grade_grades | awk '{print $1}')

crctmp=$(rhash -C --simple $REP_EXPORT/mdl_grade_grades/000000_0 | awk '{print $1}')
crcval=$(rhash -C --simple $HOME/export/valides/mdl_grade_grades | awk '{print $1}')

sha512result="Invalide"

if [[ "$sha512sumtmp" == "$sha512sumval" ]]; then
   sha512result="Valide"
   ((valides++))
fi

echo "|-- MDL_GRADE_GRADES"
echo "| |- Valeurs script"
echo "| |- Fichier SHA-512   : $sha512sumtmp"
echo "| |- Validation SHA-512: $sha512sumval"
echo "| |- Fichier CRC       : $crctmp"
echo "| |- Validation CRC    : $crcval"
echo "| |- Résultat          : $sha512result"
echo "|"



# MDL_USER

sha512sumtmp=$(sha512sum $REP_EXPORT/mdl_user/000000_0 | awk '{print $1}')
sha512sumval=$(sha512sum $HOME/export/valides/mdl_user | awk '{print $1}')

crctmp=$(rhash -C --simple $REP_EXPORT/mdl_user/000000_0 | awk '{print $1}')
crcval=$(rhash -C --simple $HOME/export/valides/mdl_user | awk '{print $1}')

sha512result="Invalide"

if [[ "$sha512sumtmp" == "$sha512sumval" ]]; then
   sha512result="Valide"
   ((valides++))
fi

echo "|-- MDL_USER"
echo "| |- Valeurs script"
echo "| |- Fichier SHA-512   : $sha512sumtmp"
echo "| |- Validation SHA-512: $sha512sumval"
echo "| |- Fichier CRC       : $crctmp"
echo "| |- Validation CRC    : $crcval"
echo "| |- Résultat          : $sha512result"
echo "|"


# ENPQ_MPULSE_RAPPORT 

sha512sumtmp=$(sha512sum $REP_EXPORT/venpq_mpulse_rapport/000000_0 | awk '{print $1}')
sha512sumval=$(sha512sum $HOME/export/valides/enpq_mpulse_rapport | awk '{print $1}')

crctmp=$(rhash -C --simple $REP_EXPORT/venpq_mpulse_rapport/000000_0 | awk '{print $1}')
crcval=$(rhash -C --simple $HOME/export/valides/enpq_mpulse_rapport | awk '{print $1}')

sha512result="Invalide"

if [[ "$sha512sumtmp" == "$sha512sumval" ]]; then
   sha512result="Valide"
   ((valides++))
fi

echo "|-- VENPQ_MPULSE_RAPPORT"
echo "| |- Valeurs script"
echo "| |- Fichier SHA-512   : $sha512sumtmp"
echo "| |- Validation SHA-512: $sha512sumval"
echo "| |- Fichier CRC       : $crctmp"
echo "| |- Validation CRC    : $crcval"
echo "| |- Résultat          : $sha512result"


resultat=$((100*valides/total))

echo ""
echo "$valides / $total - $resultat%"
echo ""
echo "Liste des fichiers / dates"

ls -al $REP_EXPORT/colele01/000000_0
ls -al $REP_EXPORT/colbec01/000000_0
ls -al $REP_EXPORT/mdl_user/000000_0
ls -al $REP_EXPORT/mdl_grade_grades/000000_0
ls -al $REP_EXPORT/venpq_mpulse_rapport/000000_0


      echo ""
      echo "*** Fin de la validation des sommes de contrôle. ***"

      else 
         echo "Le répertoire \"$REP_EXPORT\" n'est pas valide." 
      fi 
