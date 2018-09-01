/* Lock and Seize Waits */
insert into EWPFR.LCKWAITOVR
(SELECT
    QSY.INTNUM AS "Interval Number",
    timestamp('20' || substring(QSY.CSDTETIM,2,2) ||'-'|| substring(QSY.CSDTETIM,4,2) ||'-'||substring(QSY.CSDTETIM,6,2) ||' '|| substring(QSY.CSDTETIM,8,2) ||':'||substring(QSY.CSDTETIM,10,2) ||':'||substring(QSY.CSDTETIM,12,2)) AS "Date-Time",
    MAX(PCTSYSCPU) AS "Partition CPU Utilization",
    round(SUM(TIME15) * .000001,2) AS "Seize Contention Time (Seconds) ",
    round(SUM(TIME16) * .000001,2) AS "Database Record Lock Contention Time (Seconds)",
    round(SUM(TIME17) * .000001,2) AS "Object Lock Contention Time (Seconds)",
    round(SUM(COUNT15),2) AS "Seize Contention Counts",
    round(SUM(COUNT16),2) AS "Database Record Lock Contention Counts",
    round(SUM(COUNT17),2) AS "Object Lock Contention Counts",
    round(SUM(WBCJ15),2) AS "Seize Contention Contributing Jobs",
    round(SUM(WBCJ16),2) AS "Database Record Lock Contention Contributing Jobs",
    round(SUM(WBCJ17),2) AS "Object Lock Contention Contributing Jobs",
    round((SUM(TIME15) * .000001)/MAX(INTSEC),2) AS "Seize Contention Normalized Time (Seconds)",
    round((SUM(TIME16) * .000001)/MAX(INTSEC),2) AS "Database Record Lock Contention Normalized Time (Seconds)",
    round((SUM(TIME17) * .000001)/MAX(INTSEC),2) AS "Object Lock Contention Normalized Time (Seconds)"
FROM
    (
        SELECT
            DTECEN || DTETIM AS CSDTETIM,
            DOUBLE(JWTM15) AS TIME15,
            DOUBLE(JWTM16) AS TIME16,
            DOUBLE(JWTM17) AS TIME17,
            JWCT15 AS COUNT15,
            JWCT16 AS COUNT16,
            JWCT17 AS COUNT17,
            JWJC15 AS WBCJ15,
            JWJC16 AS WBCJ16,
            JWJC17 AS WBCJ17
        FROM
            EWPFR.QAPMISUMX
    ) WAITS
JOIN
    (
        SELECT
            INTNUM,
            DTETIM AS DTETIM,
            DTECEN AS DTECEN,
            INTSEC,
            DTECEN || DTETIM AS CSDTETIM,
            DEC(SYSPTU/DOUBLE(SYSCTA) * 100, 28, 2) AS PCTSYSCPU
        FROM
            EWPFR.QAPMSYSTEMX QSY
    ) QSY
ON
    QSY.CSDTETIM = WAITS.CSDTETIM
GROUP BY
    INTNUM,
    QSY.CSDTETIM
ORDER BY
    "Date-Time") ;
