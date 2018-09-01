#!/usr/bin/bash

#CONSTANTS
LIBNAME=QPFRDATA
IFSPATH=/home/MYUSER/EWPFR
FILENAME=$IFSPATH/mlname.lst

QIBM_MULTI_THREADED='Y'
export QIBM_MULTI_THREADED

echo '----------------------------------------------------------------------------------------------'
echo "BEGIN"
echo '----------------------------------------------------------------------------------------------'


FILELINES=`sed -n "/$1/,/$2/p" $FILENAME`
# Listo los miembros a buscar procesar
echo 'Listing members for cycle'
ls -la /QSYS.LIB/$LIBNAME.LIB/QAPMSYSTEM.FILE/ |cut -c59-68 |grep -Fv -e 'R' -e '.' > $FILENAME

echo 'Creating auxiliary tables'
qsh -i -c "DB2 -t -f $IFSPATH/ewpfr_create_files.sql"


echo 'Deleting auxiliary tables'
qsh -i -c 'DB2 "DELETE FROM EWPFR.FLTRATOVR"'    &
qsh -i -c 'DB2 "DELETE FROM EWPFR.FLTRATOVR2"'   &
qsh -i -c 'DB2 "DELETE FROM EWPFR.DSKWAITOVR"'   &
qsh -i -c 'DB2 "DELETE FROM EWPFR.DSKOVR"'       &
qsh -i -c 'DB2 "DELETE FROM EWPFR.CPUWAITOVR"'   &
qsh -i -c 'DB2 "DELETE FROM EWPFR.LCKWAITOVR"'   &
wait

#Drop Alias
echo 'Drop alias'
qsh -i -c "DB2 'DROP ALIAS EWPFR.QAPMSYSTEMX';" &
qsh -i -c "DB2 'DROP ALIAS EWPFR.QAPMISUMX';"   &
qsh -i -c "DB2 'DROP ALIAS EWPFR.QAPMDISKX';"   &
qsh -i -c "DB2 'DROP ALIAS EWPFR.QAPMJOBMIX';"  &
wait

echo '----------------------------------------------------------------------------------------------'
echo 'Starting LOOP'

for MLNAME in $FILELINES; do
        echo '----------------------------------------------------------------------------------------------'
        #Alias Creation
        echo "Creating ALIAS $MLNAME"
        qsh -i -c "DB2 'create alias EWPFR.QAPMSYSTEMX  for $LIBNAME.QAPMSYSTEM ($MLNAME)';" &
        qsh -i -c "DB2 'CREATE ALIAS EWPFR.QAPMISUMX for $LIBNAME.QAPMISUM ($MLNAME)';"      &
        qsh -i -c "DB2 'CREATE ALIAS EWPFR.QAPMDISKX for $LIBNAME.QAPMDISK ($MLNAME)';"      &
        qsh -i -c "DB2 'create ALIAS EWPFR.QAPMJOBMIX for $LIBNAME.QAPMJOBMI ($MLNAME)';"    &
        wait

        echo 'Running SQL queries on alias'
        #Running SQL on alias
        qsh -i -c "DB2 -t -f $IFSPATH/ewpfrx_pgfltovr.sql"   &
        qsh -i -c "DB2 -t -f $IFSPATH/ewpfrx_fltratovr2.sql" &
        qsh -i -c "DB2 -t -f $IFSPATH/ewpfrx_dskwaitovr.sql" &
        qsh -i -c "DB2 -t -f $IFSPATH/ewpfrx_dskovr.sql"     &
        qsh -i -c "DB2 -t -f $IFSPATH/ewpfrx_cpuovrwait.sql" &
        qsh -i -c "DB2 -t -f $IFSPATH/ewpfrx_lckwait.sql"    &
        wait
        #Dropping Alias
        echo 'Dropping Alias'
        qsh -i -c "DB2 'DROP ALIAS EWPFR.QAPMSYSTEMX';" &
        qsh -i -c "DB2 'DROP ALIAS EWPFR.QAPMISUMX';"   &
        qsh -i -c "DB2 'DROP ALIAS EWPFR.QAPMDISKX';"   &
        qsh -i -c "DB2 'DROP ALIAS EWPFR.QAPMJOBMIX';"  &
        wait
done
# Export to CSV files

echo '----------------------------------------------------------------------------------------------'

system "CPYTOIMPF  FROMFILE(EWPFR/CPUWAITOVR) TOSTMF('$IFSPATH/CPUWAITOVR.csv' ) MBROPT(*REPLACE) STMFCCSID(*PCASCII) RCDDLM(*CRLF) DATFMT(*YYMD) TIMFMT(*JIS) ADDCOLNAM(*SQL)" &
system "CPYTOIMPF  FROMFILE(EWPFR/FLTRATOVR ) TOSTMF('$IFSPATH/FLTRATOVR.csv'  ) MBROPT(*REPLACE) STMFCCSID(*PCASCII) RCDDLM(*CRLF) DATFMT(*YYMD) TIMFMT(*JIS) ADDCOLNAM(*SQL)" &
system "CPYTOIMPF  FROMFILE(EWPFR/FLTRATOVR2) TOSTMF('$IFSPATH/FLTRATOVR2.csv' ) MBROPT(*REPLACE) STMFCCSID(*PCASCII) RCDDLM(*CRLF) DATFMT(*YYMD) TIMFMT(*JIS) ADDCOLNAM(*SQL)" &
system "CPYTOIMPF  FROMFILE(EWPFR/DSKWAITOVR) TOSTMF('$IFSPATH/DSKWAITOVR.csv' ) MBROPT(*REPLACE) STMFCCSID(*PCASCII) RCDDLM(*CRLF) DATFMT(*YYMD) TIMFMT(*JIS) ADDCOLNAM(*SQL)" &
system "CPYTOIMPF  FROMFILE(EWPFR/DSKOVR    ) TOSTMF('$IFSPATH/DSKOVR.csv'     ) MBROPT(*REPLACE) STMFCCSID(*PCASCII) RCDDLM(*CRLF) DATFMT(*YYMD) TIMFMT(*JIS) ADDCOLNAM(*SQL)" &
system "CPYTOIMPF  FROMFILE(EWPFR/LCKWAITOVR) TOSTMF('$IFSPATH/LCKWAITOVR.csv' ) MBROPT(*REPLACE) STMFCCSID(*PCASCII) RCDDLM(*CRLF) DATFMT(*YYMD) TIMFMT(*JIS) ADDCOLNAM(*SQL)" &
wait

echo 'End of Process'

