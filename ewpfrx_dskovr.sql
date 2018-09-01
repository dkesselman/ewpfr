/* Disk overview for System disk pool */
INSERT INTO EWPFR.DSKOVR (
SELECT
    INTNUM as "Intervalo",
    timestamp('20' || substring(DTETIM,1,2) ||'-'|| substring(DTETIM,3,2) ||'-'||substring(DTETIM,5,2) ||' '|| substring(DTETIM,7,2) ||':'||substring(DTETIM,9,2) ||':'||substring(DTETIM,11,2)) AS "Date-Time",
    CASE
      WHEN SUM(NUMCMDS) = 0
      THEN round(0,2)
    ELSE CASE WHEN SUM(RESPTIMENEW) <> 0 THEN round(SUM(RESPTIMENEW)/SUM(NUMCMDS),2) ELSE round(SUM(RESPTIMEOLD)/SUM(NUMCMDS),2) END END AS "Average Response time",
    Round(AVG(PCTDSKBUSY),2) AS "% Disk Busy",
    CASE
      WHEN MAX(INTSEC) = 0
      THEN 0
      ELSE round(SUM(NUMREADS)/MAX(INTSEC),2)
    END AS "Reads per second",
    CASE
      WHEN MAX(INTSEC) = 0
      THEN 0
      ELSE round(SUM(NUMWRTS)/MAX(INTSEC),2)
    END AS "Writes per second",
    CASE
      WHEN MAX(INTSEC) = 0
      THEN 0
      ELSE round(SUM(NUMCMDS)/MAX(INTSEC),2)
    END AS "Operations per second",
    CASE
      WHEN SUM(NUMREADS) = 0
      THEN 0
      ELSE round((SUM(TOTBYTESRD) / 1024) / SUM(NUMREADS),2)
    END AS "Average KB per Read",
    CASE
      WHEN SUM(NUMWRTS) = 0
      THEN 0
      ELSE round((SUM(TOTBYTESWR) / 1024) / SUM(NUMWRTS),2)
    END AS "Average KB per Write",
    CASE
      WHEN SUM(NUMCMDS) = 0
      THEN 0
    ELSE CASE WHEN SUM(SRVTIMENEW) <> 0 THEN round(SUM(SRVTIMENEW)/SUM(NUMCMDS),2) ELSE round(SUM(SRVTIMEOLD)/SUM(NUMCMDS),2) END END AS "Average Service Time",
    CASE
      WHEN SUM(NUMCMDS) = 0
      THEN 0
    ELSE CASE WHEN SUM(SRVTIMENEW) <> 0 THEN round(SUM(WTTIMENEW)/SUM(NUMCMDS),2) ELSE round((SUM(RESPTIMEOLD) - SUM(SRVTIMEOLD))/ SUM(NUMCMDS),2) END END AS "Average Wait Time",
    round(SUM(TOTBYTESRD) / 1048576,2) AS "Total Read MB",
    round(SUM(TOTBYTESWR) / 1048576,2) AS "Total Write MB",
    MAX(INTSEC) AS INTSEC,
    round(SUM(DRIVECAP)/1073741824,2) AS "Drive Capacity",
    round(AVG(PCTDSKFULL),2) AS "% Disk Full"
FROM
    (
        SELECT
            DOUBLE(MAX(DSCAP)) AS DRIVECAP,
            CASE
              WHEN DOUBLE(MAX(DSCAP)) = 0
              THEN 0
              ELSE MAX(DOUBLE(DSCAP - DSAVL)/DOUBLE(DSCAP)) * 100
            END AS PCTDSKFULL,
            BIGINT(MAX(QDS.INTSEC)) AS INTSEC,
            MIN(QSY.DTETIM) AS DTETIM,
            MIN(QSY.DTECEN) AS DTECEN,
            QSY.INTNUM AS INTNUM,
            SUM(DOUBLE(DSSRVT)) + SUM(DOUBLE(DSWT)) AS RESPTIMENEW,
            SUM(CASE
              WHEN DSSMPL <> 0
              THEN DOUBLE(DSQUEL)/DOUBLE(DSSMPL)
              ELSE 0
            END) * DOUBLE(MAX(QDS.INTSEC)) * 1000 AS RESPTIMEOLD,
            AVG(CASE
              WHEN DSSMPL <> 0
              THEN DOUBLE(DSSMPL - DSNBSY) / DOUBLE(DSSMPL) * 100
              ELSE 0
            END) AS PCTDSKBUSY,
            SUM(CASE
              WHEN DSSMPL <> 0
              THEN DOUBLE(DSQUEL)/DOUBLE(DSSMPL)
              ELSE 0
            END) AS AVGOPS,
            SUM(DOUBLE(DSRDS)) + SUM(DOUBLE(DSWRTS)) AS NUMCMDS,
            SUM(DOUBLE(DSRDS)) AS NUMREADS,
            SUM(DOUBLE(DSWRTS)) AS NUMWRTS,
            SUM(DOUBLE(DSDROP)) AS NUMDEVRDS,
            SUM(DOUBLE(DSDWOP)) AS NUMDEVWRTS,
            SUM(DOUBLE(DSDROP)) + SUM(DOUBLE(DSDWOP)) AS NUMDEVCMDS,
            SUM(DOUBLE(DSSRVT)) AS SRVTIMENEW,
            SUM(CASE
              WHEN DSSMPL <> 0
              THEN DOUBLE((DSSMPL - DSNBSY) / DSSMPL)
              ELSE 0
            END) * MAX(QDS.INTSEC) * 1000 AS SRVTIMEOLD,
            SUM(DOUBLE(DSWT)) AS WTTIMENEW,
            SUM(DOUBLE(DSBLKR)) * (CASE
              WHEN MAX(DSSECT) <> 0
              THEN DOUBLE(MAX(DSSECT))
              ELSE 520
            END) AS TOTBYTESRD,
            SUM(DOUBLE(DSBLKW)) * (CASE
              WHEN MAX(DSSECT) <> 0
              THEN DOUBLE(MAX(DSSECT))
              ELSE 520
            END) AS TOTBYTESWR	
        FROM
            EWPFR.QAPMSYSTEMX QSY LEFT
        OUTER JOIN
            EWPFR.QAPMDISKX QDS
        ON
            QSY.INTNUM = QDS.INTNUM
        WHERE
            (DSASP = '1')
        GROUP BY
            QSY.INTNUM,
            DSARM,
            DMFLAG
    ) A
GROUP BY
    INTNUM,
    DTETIM,
    DTECEN
ORDER BY
    "Date-Time");
