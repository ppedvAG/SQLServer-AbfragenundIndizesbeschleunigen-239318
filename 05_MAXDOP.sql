--MAXDOP
--Maximum Degree of Parallelism
--Steuern, wieviele CPU-Kerne pro Abfrage verwendet werden dürfen

--Kann auf 3 verschiedenenen Ebenen gesetzt werden
--Query > DB > Server

--Wichtige Felder:
--Cost Threshold for Parallelism
	--Mindeste Kosten einer Abfrage, damit diese parallelisiert werden kann
	--Maximum Degree of Parallelism

SET STATISTICS time, io ON

SELECT * FROM KundenUmsatz k
WHERE Salary > (SELECT TOP(10) AVG(Salary) FROM KundenUmsatz)

--Auf Query selbst
SELECT * FROM KundenUmsatz k
WHERE Salary > (SELECT TOP(10) AVG(Salary) FROM KundenUmsatz)
OPTION(MAXDOP 8)

--MAXDOP 8
--CPU-Zeit = 5811 ms, verstrichene Zeit = 13035 ms

--MAXDOP 4
--CPU-Zeit = 6140 ms, verstrichene Zeit = 12537 ms

--MAXDOP 1
--CPU-Zeit = 4594 ms, verstrichene Zeit = 13168 ms