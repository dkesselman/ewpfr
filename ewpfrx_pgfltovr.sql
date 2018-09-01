 /* Page faults overview */
INSERT INTO EWPFR.FLTRATOVR (
SELECT 
	INTNUM as "Interval", 
	timestamp('20' || substring(a.CSDTETIM,2,2) ||'-'|| substring(a.CSDTETIM,4,2) ||'-'||substring(a.CSDTETIM,6,2) ||' '|| substring(a.CSDTETIM,8,2) ||':'||substring(a.CSDTETIM,10,2) ||':'||substring(a.CSDTETIM,12,2)) AS "Date-Time",
	CASE 
	  WHEN INTSEC = 0 
	  THEN 0 
	  ELSE round(FLTTOTAL/INTSEC ,2)
	END AS  "Faults Per Second", 
	FLTTOTAL as "Total Page Faults", 
	CASE 
	  WHEN INTSEC = 0 
	  THEN 0 
	  ELSE round(PENDFLTTOTAL/INTSEC ,2)
	END AS  "I/O Pending Faults Per Second", 
	PENDFLTTOTAL as "I/O Total Pending Faults"
FROM 
	( 
		SELECT 
			QSY.DTETIM AS DTETIM, 
			QSY.DTECEN AS DTECEN, 
			QSY.INTNUM, 
			QSY.INTSEC, 
			QSY.DTECEN || QSY.DTETIM AS CSDTETIM, 
			SUM(DOUBLE(QMI.JBTFLT)) AS FLTTOTAL, 
			SUM(DOUBLE(QMI.JBIPF)) AS PENDFLTTOTAL 
		FROM 
			EWPFR.QAPMJOBMIX QMI 
		INNER JOIN 
			EWPFR.QAPMSYSTEMX QSY 
		ON 
			QMI.INTNUM = QSY.INTNUM 
		GROUP BY 
			QSY.INTNUM, 
			QSY.DTETIM, 
			QSY.DTECEN, 
			QSY.INTSEC 
	) A 
ORDER BY 
	"Date-Time");
