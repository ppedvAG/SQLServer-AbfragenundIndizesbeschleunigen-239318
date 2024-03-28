--Partitionierung
--Ermöglicht, eine logische Aufteilung einer Tabelle in mehrere Tabellen

--2 Komponente:
--Partitionierungsfunktion
--Partitionierungsschema

--PFunktion
--Nimmt einen Wert, und schaut in welche Partition dieser Wert gelegt wird

--...--------100---------200---------...
CREATE PARTITION FUNCTION pfZahl(int)
AS
RANGE LEFT FOR VALUES(100, 200) --LEFT: bis zu dem Wert
--Hier: 0: bis 100, 1: bis 200, 2: bis Ende

SELECT $partition.pfZahl(50); --1
SELECT $partition.pfZahl(150); --2
SELECT $partition.pfZahl(250); --3

--Partitionierungsschema
--Legt über Dateigruppen + Partitionierungsfunktion Partitionen an
--Tabellen werden auf das Schema gelegt

CREATE PARTITION SCHEME schZahl
AS
PARTITION pfZahl --Hier PFunktion angeben
TO (M003_1, M003_2, M003_3) --Hier Dateigruppen angeben (immer eine mehr als in der PFunktion festgelegt sind)

CREATE TABLE M003_Test(id int identity, test char(5000))
ON schZahl(id) --Hier Tabelle auf das Schema legen (mit ID)

INSERT INTO M003_Test
SELECT 'Test'
GO 20000

--F1 und F2 sind 8MB groß, F3 ist 200MB groß

SELECT OBJECT_ID('M003_Test')
SELECT * FROM sys.dm_db_index_physical_stats(DB_ID(), 0, -1, 0, 'DETAILED')
WHERE object_id = 1194799664; --Partitionierung anschauen

SELECT *, $partition.pfZahl(id)
FROM M003_Test

-------------------------------------------------------------------------

--Performance
SET STATISTICS time, io ON

SELECT * FROM M003_Test
WHERE id = 50; --100 Lesevorgänge

SELECT * FROM M003_Test
WHERE id = 150; --100 Lesevorgänge

SELECT * FROM M003_Test
WHERE id = 250; --19800 Lesevorgänge

SELECT * FROM M003_Test
WHERE id BETWEEN 50 AND 150; --200 Lesevorgänge

--Bestehende Tabellen partitionieren
--Nicht so simpel
--Prozedur erstellen
	--PFunktion erweitern
	--PSchema erweitern
		--Neue Dateigruppe + Datei erstellen
	--Bestehende Daten bewegen