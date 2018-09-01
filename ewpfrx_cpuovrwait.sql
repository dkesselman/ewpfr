/* CPU & WAIT OVERVIEW */
insert into EWPFR.CPUWAITOVR ( 
SELECT
    QSY.INTNUM as "Interval Number",
    timestamp('20' || substring(QSY.CSDTETIM,2,2) ||'-'|| substring(QSY.CSDTETIM,4,2) ||'-'||substring(QSY.CSDTETIM,6,2) ||' '|| substring(QSY.CSDTETIM,8,2) ||':'||substring(QSY.CSDTETIM,10,2) ||':'||substring(QSY.CSDTETIM,12,2)) AS "Date-Time",
    MAX(PCTSYSCPU) AS "Partition CPU Utilization",
    Round(SUM(TIME01) * .000001,2) AS "Dispatched CPU Time (Seconds)",
    Round(SUM(TIME02) * .000001,2) AS "CPU Queueing Time (Seconds)",
    Round(SUM(TIME05 + TIME06 + TIME07 + TIME08 + TIME09 + TIME10) * .000001,2) AS "Disk Time (Seconds)",
    Round(SUM(TIME11) * .000001,2) AS "Journaling Time (Seconds)",
    Round(SUM(TIME14 + TIME15 + TIME19 + TIME32) * .000001,2) AS "Operating System Contention Time (Seconds)",
    Round(SUM(TIME16 + TIME17) * .000001,2) AS "Lock Contention Time (Seconds)",
    Round(SUM(TIME18) * .000001,2) AS "Inelegible Waits Contention Time (Seconds)"
FROM
    (
        SELECT
            DTECEN || DTETIM AS CSDTETIM,
            DOUBLE(JWTM01) AS TIME01,
            DOUBLE(JWTM02) AS TIME02,
            DOUBLE(JWTM05) AS TIME05,
            DOUBLE(JWTM06) AS TIME06,
            DOUBLE(JWTM07) AS TIME07,
            DOUBLE(JWTM08) AS TIME08,
            DOUBLE(JWTM09) AS TIME09,
            DOUBLE(JWTM10) AS TIME10,
            DOUBLE(JWTM11) AS TIME11,
            DOUBLE(JWTM14) AS TIME14,
            DOUBLE(JWTM15) AS TIME15,
            DOUBLE(JWTM16) AS TIME16,
            DOUBLE(JWTM17) AS TIME17,
            DOUBLE(JWTM18) AS TIME18,
            DOUBLE(JWTM19) AS TIME19,
            DOUBLE(JWTM32) AS TIME32
        FROM
            EWPFR.QAPMISUMX
    ) WAITS
INNER JOIN
    (
        SELECT
            INTNUM,
            DTECEN || DTETIM AS CSDTETIM,
            INTSEC,
            DEC(SYSPTU/DOUBLE(SYSCTA) * 100, 28, 2) AS PCTSYSCPU,
            DTETIM AS DTETIM,
            DTECEN AS DTECEN
        FROM
            EWPFR.QAPMSYSTEMX QSY
    ) QSY
ON
    QSY.CSDTETIM   = WAITS.CSDTETIM
GROUP BY
    QSY.INTNUM,
    QSY.CSDTETIM
ORDER BY
    "Date-Time" ) ;
