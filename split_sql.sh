#!/bin/bash

# RUN SCRIPT AS ./split_sql.sh [file]

# DEFINE VARIABLES FOR LOGS
LOGSTART="`date +%Y%m%d%H%M`"
MYLOG="$LOGSTART.split_sql.log"

# SET VARIABLE FOR ARGUMENT FOR NAME OF FILE TO SPLIT
# AND FOR SQLFILES DIRECTORY
FILE=$1
SQLDIR="sqlfiles"

# MAKE SURE SQLFILES DIRECTORY EXISTS
if [ ! -d $SQLDIR ]; then
  mkdir -p $SQLDIR || exit 1
fi

# SPLIT FILE INTO SEPARATE FILES BY TABLE
# AND STORE THEM IN SQLFILES DIRECTORY
split -p '^DROP TABLE IF EXISTS' $FILE $SQLDIR/ >>$MYLOG 2>&1

# MOVE TO SQLFILES DIRECTORY
cd $SQLDIR 

# ITERATE THROUGH EACH FILE
for filename in $(find . -type f); do
  
  # IF FILE DOES NOT CONTAIN DROP TABLE TEXT, REMOVE IT
  grep -q '^DROP TABLE IF EXISTS' $filename >>../$MYLOG 2>&1
  rc=$?
  # IF FILE DOES NOT CONTAIN DROP TABLE TEXT, REMOVE IT
  if [ $rc != 0 ]; then
    rm -f $filename >>../$MYLOG 2>&1
  
  # OTHERWISE GET THE NAME OF TABLE FROM FILE
  # AND RENAME FILE TO TABLE NAME
  else
    table=$(grep '^DROP TABLE IF EXISTS' $filename | cut -f2 -d '`') >>../$MYLOG 2>&1
    mv $filename $table.sql >>../$MYLOG 2>&1

  fi

done

