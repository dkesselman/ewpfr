 /* Disk Waits Overview */
INSERT INTO EWPFR.DSKWAITOVR (
SELECT 
	QSY.INTNUM as "Intervalo", 
	timestamp('20' || substring(qsy.CSDTETIM,2,2) ||'-'|| substring(qsy.CSDTETIM,4,2) ||'-'||substring(qsy.CSDTETIM,6,2) ||' '|| substring(qsy.CSDTETIM,8,2) ||':'||substring(qsy.CSDTETIM,10,2) ||':'||substring(qsy.CSDTETIM,12,2)) AS "Date-Time",
    round(MAX(PCTSYSCPU),2) AS "Partition CPU Utilization",
	round(SUM(TIME05) * .000001,2) AS "Disk Page Faults Time (Seconds)", 
	round(SUM(TIME06) * .000001,2) AS "Disk Non-fault Reads Time (Seconds)", 
	round(SUM(TIME07) * .000001,2) AS "Disk Space Usage Contention Time (Seconds)", 
	round(SUM(TIME08) * .000001,2) AS "Disk Op-Start Contention Time (Seconds)", 
	round(SUM(TIME09) * .000001,2) AS "Disk Writes Time (Seconds)", 
	round(SUM(TIME10) * .000001,2) AS "Disk Other Time (Seconds)", 
	round(SUM(COUNT05),2) AS "Disk Page Faults Counts", 
	round(SUM(COUNT06),2) AS "Disk Non-fault Reads Counts", 
	round(SUM(COUNT07),2) AS "Disk Space Usage Contention Counts", 
	round(SUM(COUNT08),2) AS "Disk Op-Start Contention Counts", 
	round(SUM(COUNT09),2) AS "Disk Writes Counts", 
	round(SUM(COUNT10),2) AS "Disk Other Counts", 
	round(SUM(WBCJ05),2) AS "Disk Page Faults Contributing Jobs", 
	round(SUM(WBCJ06),2) AS "Disk Non-fault Reads Contributing Jobs", 
	round(SUM(WBCJ07),2) AS "Disk Space Usage Contention Contributing Jobs", 
	round(SUM(WBCJ08),2) AS "Disk Op-Start Contention Contributing Jobs", 
	round(SUM(WBCJ09),2) AS "Disk Writes Contributing Jobs", 
	round(SUM(WBCJ10),2) AS "Disk Other Contributing Jobs", 
	round((SUM(TIME05) * .000001)/MAX(INTSEC),2) AS "Disk Page Faults Normalized Time (Seconds)", 
	round((SUM(TIME06) * .000001)/MAX(INTSEC),2) AS "Disk Non-fault Reads Normalized Time (Seconds)", 
	round((SUM(TIME07) * .000001)/MAX(INTSEC),2) AS "Disk Space Usage Contention Normalized Time (Seconds)", 
	round((SUM(TIME08) * .000001)/MAX(INTSEC),2) AS "Disk Op-Start Contention Normalized Time (Seconds)", 
	round((SUM(TIME09) * .000001)/MAX(INTSEC),2) AS "Disk Writes Normalized Time (Seconds)", 
	round((SUM(TIME10) * .000001)/MAX(INTSEC),2) AS "Disk Other Normalized Time (Seconds)"
FROM 
	( 
		SELECT 
			DTECEN || DTETIM AS CSDTETIM, 
			DOUBLE(JWTM05) AS TIME05, 
			DOUBLE(JWTM06) AS TIME06, 
			DOUBLE(JWTM07) AS TIME07, 
			DOUBLE(JWTM08) AS TIME08, 
			DOUBLE(JWTM09) AS TIME09, 
			DOUBLE(JWTM10) AS TIME10, 
			JWCT05 AS COUNT05, 
			JWCT06 AS COUNT06, 
			JWCT07 AS COUNT07, 
			JWCT08 AS COUNT08, 
			JWCT09 AS COUNT09, 
			JWCT10 AS COUNT10, 
			JWJC05 AS WBCJ05, 
			JWJC06 AS WBCJ06, 
			JWJC07 AS WBCJ07, 
			JWJC08 AS WBCJ08, 
			JWJC09 AS WBCJ09, 
			JWJC10 AS WBCJ10
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
	DTETIM, 
	DTECEN, 
	QSY.CSDTETIM 
ORDER BY 
	"Date-Time");
