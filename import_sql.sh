#!/bin/bash

# RUN AS ./import_sql.sh [user] [password] [database] [-i-e-a] [directory] [file(s)]
# FIRST ARGUMENT IS MYSQL USERNAME
# SECOND ARGUMENT IS MYSQL PASSWORD
# THIRD ARGUMENT IS MYSQL DATABASE TO IMPORT TO
# FOURTH ARGUMENT IS i FOR INCLUDE LISTED FILES, e FOR EXCLUDE LISTED FILES, OR a TO IMPORT ALL FILES
# FIFTH ARGUMENT IS DIRECTORY WHERE SQL FILES ARE LOCATED

# DEFINE VARIABLES FOR LOGS
LOGSTART="`date +%Y%m%d%H%M`"
MYLOG="$LOGSTART.import_sql.log"

# DEFINE VARIABLES FOR SCRIPT FROM ARGUMENTS
USER=$1
shift
PASSWORD=$1
shift
DATABASE=$1
shift
ACTION=$1
shift
SQLDIR=$1
shift

cd $SQLDIR

# FILES LISTED SHOULD BE INCLUDED
if [ "$ACTION" = "-i" ]; then
  while [ "$#" -gt 0 ]; do
    ARG_FILE=$1
    shift
    echo "Importing $ARG_FILE" >>../$MYLOG 2>&1
    mysql -u $USER -p$PASSWORD $DATABASE < $ARG_FILE >>../$MYLOG 2>&1 
  done

# FILES LISTED SHOULD BE EXCLUDED
elif [ "$ACTION" = "-e" ]; then
  while [ "$#" -gt 0 ]; do
    ARG_FILE=$1
    shift
    # GET LIST OF ALL SQL FILES IN SQL DIRECTORY
    for filename in $(find . -type f -name "*.sql"); do
      #STRIP OF LEADING ./
      sql_file=$(basename $filename)

      # IF NEXT SQL FILE IS NOT ONE TO BE EXCLUDED, IMPORT IT
      if [ "$ARG_FILE" != "$sql_file" ]; then
        echo "Importing $sql_file" >>../$MYLOG 2>&1
	mysql -u $USER -p$PASSWORD $DATABASE < $sql_file >>../$MYLOG 2>&1
      fi
    done
  done

# ALL FILES IN SQL DIRECTORY SHOULD BE IMPORTED
elif [ "$ACTION" = "-a" ]; then
  # GET LIST OF ALL SQL FILES IN SQL DIRECTORY AND IMPORT EACH
  for sql_file in $(find . -type f); do
    echo "Importing $sql_file" >>../$MYLOG 2>&1
    mysql -u $USER -p$PASSWORD $DATABASE < $sql_file >>../$MYLOG 2>&1
  done

else
  echo "Invalid action argument."

fi

