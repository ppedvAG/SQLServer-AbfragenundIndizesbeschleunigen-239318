/*
	Dateigruppen:
	Ermöglichen, das Aufteilen der Datenbank auf mehrere Dateien, auf mehrere Datenträger
	z.B.: Archivdaten auf HDD, aktuelle Daten auf SSD

	[PRIMARY]: Hauptgruppe, existiert standardmäßig und enthält alle Files

	Files:
	Tatsächliche Dateien
	C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\DATA

	Das Hauptfile hat die Endung .mdf, weitere Files haben die Endung .ndf
	Logfiles haben die Endung .ldf

	Dateigruppen können auch selbst erstellt werden, und dazugehörige Files ebenso
	Werden verwendet für die Partitionierung
*/

--Rechtsklick auf die Datenbank -> Properties -> Filegroups
--Add Filegroup
--Files -> Add File

USE Demo;

CREATE TABLE M002_T1 (id int identity, test char(5000))
ON [Aktiv];

INSERT INTO M002_T1
SELECT 'Test'
GO 20000 --32MB -> 163MB

--Wie bewege ich eine Tabelle auf eine andere Dateigruppe?

--Keine integrierte Möglichkeit -> neu Erstellen und Daten bewegen

CREATE TABLE M002_T2 (id int identity, test char(5000))
ON [Aktiv2];

SET IDENTITY_INSERT M002_T2 ON

INSERT INTO M002_T2(id, test)
SELECT id, test FROM M002_T1

TRUNCATE TABLE M002_T1


--Salamitaktik
--Große Tabellen in kleinere Tabellen aufteilen

--2 Möglichkeiten: Spaltenweise, Zeilenweise
--Spaltenweise: Fremdschlüssel
--Zeilenweise: Anhand einer Spalte auf mehrere Teile aufteilen

CREATE TABLE M002_Umsatz(Datum date, Umsatz float);

DECLARE @i int = 0;
WHILE @i < 100000
BEGIN
	INSERT INTO M002_Umsatz VALUES
	(DATEADD(DAY, FLOOR(RAND()*1096), '20200101'), RAND() * 1000);
	SET @i += 1;
END

SET STATISTICS time, io ON

dbcc showcontig('Umsatz')

SELECT * FROM M002_Umsatz
WHERE YEAR(Datum) = 2022; --Jede Seite musste durchsucht werden

CREATE TABLE M002_Umsatz2020(Datum date, Umsatz float);
CREATE TABLE M002_Umsatz2021(Datum date, Umsatz float);
CREATE TABLE M002_Umsatz2022(Datum date, Umsatz float);

INSERT INTO M002_Umsatz2020
SELECT * FROM M002_Umsatz
WHERE YEAR(Datum) = 2020

INSERT INTO M002_Umsatz2021
SELECT * FROM M002_Umsatz
WHERE YEAR(Datum) = 2021

INSERT INTO M002_Umsatz2022
SELECT * FROM M002_Umsatz
WHERE YEAR(Datum) = 2022

DROP TABLE M002_Umsatz;

SELECT * FROM M002_Umsatz2020; --83 LV

--Problem: Datensätze sind jetzt separat
--Finde alle Umsätze > 750

--Lösung: View, die alle Tabellen kombiniert

CREATE VIEW M002_UmsatzGesamt AS
SELECT * FROM M002_Umsatz2020
UNION ALL
SELECT * FROM M002_Umsatz2021
UNION ALL --UNION ALL: Filtert keine Duplikate, kostet wesentlich weniger Performance
SELECT * FROM M002_Umsatz2022

SELECT * FROM M002_UmsatzGesamt
WHERE Umsatz > 750 --Alle drei Tabellen werden hier angegriffen

SELECT * FROM M002_UmsatzGesamt
WHERE YEAR(Datum) = 2021 OR YEAR(Datum) = 2022 --Alle drei Tabellen werden hier angegriffen
--Problem: Hier wird auch die 2020 Tabelle
--Lösung: Partitionierte View

/*
	Pläne:
	Zeigt den genauen Ablauf einer Abfrage an
	Aktivieren mit Include Actual Execution Plan (Strg + M)

	Wichtige Metriken:
		Kosten: Bezeichnet, den Aufwand im Kontext der gesamten Abfrage
		Number of Rows Read: Anzahl gelesene Datensätze
*/

SELECT * FROM M002_UmsatzGesamt
WHERE Umsatz > 750

--CHECK Constraint
--Prüft Datensätze bei Insert/Update, ob die Bedingung innerhalb des Constraints gegeben ist

--Bei den Umsatztabellen wäre ein Jahresconstraint sinnvoll
DROP TABLE M002_Umsatz2020;
DROP TABLE M002_Umsatz2021;
DROP TABLE M002_Umsatz2022;

CREATE TABLE M002_Umsatz2020
(
	Datum date,
	Umsatz float,

	--CONSTRAINT pk PRIMARY KEY(Datum),
	--CONSTRAINT fk_test FOREIGN KEY Datum REFERENCES M002_Umsatz2021(Datum)
	CONSTRAINT datum2020 CHECK (YEAR(Datum) = 2020)
);

INSERT INTO M002_Umsatz2020 VALUES ('2021-01-01', 222) --Konflikt

CREATE TABLE M002_Umsatz2021(Datum date, Umsatz float, CONSTRAINT datum2021 CHECK (YEAR(Datum) = 2021));
CREATE TABLE M002_Umsatz2022(Datum date, Umsatz float, CONSTRAINT datum2022 CHECK (YEAR(Datum) = 2022));