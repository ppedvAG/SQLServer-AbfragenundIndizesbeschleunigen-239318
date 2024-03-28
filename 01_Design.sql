/*
	Normalformen zusammengefasst:
	1. Jede Zelle sollte genau einen Wert haben
		- Adresse aufteilen in einzelne Spalten
		- Sonst muss diese eine Spalte später wieder getrennt werden (Funktion -> Teuer)
	2. Jeder Datensatz sollte einen Primärschlüssel haben
	3. Beziehungen sollten nur zwischen Schlüsselspalten existieren

	Redundanz verringern (Daten nicht doppelt speichern)
		- Beziehungen (Fremdschlüssel)
		- Große Tabellen in kleinere Tabellen aufteilen

	Kundentabelle (1 Mio. DS)
	Bestellungen (100 Mio. DS)
	Kunden <- Beziehung -> Bestellung
*/

/*
	Seiten:
	8192B (8KB)
	132B für Management Daten
	8060B für tatsächliche Daten

	Seiten werden immer 1:1 geladen (keine halben Seiten)
		-> Seiten sollten reduziert werden

	Max. 700DS pro Seite
	DS können keine Seiten überschreiten (Datensätze können nicht auf zwei Seiten sein)
	Leerer Raum kann existieren
*/

CREATE DATABASE Demo;
USE Demo;

CREATE TABLE M001_T1(id int identity, test char(5000));

INSERT INTO M001_T1
SELECT 'Test'
GO 20000 --GO <X>: Führt einen Befehl X mal aus

SELECT * FROM M001_T1; --Nichts dramatisches

--dbcc: Database Console Commands
--showcontig: Zeigt Seiteninformationen über eine Tabelle an
dbcc showcontig('M001_T1')

--20000 Seiten obwohl nur 4 Byte für id und 4 Byte für test = 8 Byte pro Datensatz
CREATE TABLE M001_T2(id int identity, test varchar(5000));

INSERT INTO M001_T2
SELECT 'Test'
GO 20000

dbcc showcontig('M001_T2')
--Hier nur 55 Seiten
--Freier Platz, weil das 700DS Limit getroffen wurde

--varchar vs. nvarchar
--varchar ASCII: 1B pro Wert
--nvarchar Unicode: 2B pro Wert
CREATE TABLE M001_T3(id int identity, test varchar(MAX));

INSERT INTO M001_T3
SELECT 'Test'
GO 20000

CREATE TABLE M001_T4(id int identity, test nvarchar(MAX));

INSERT INTO M001_T4
SELECT 'Test'
GO 20000

dbcc showcontig('M001_T3') --55 Seiten
dbcc showcontig('M001_T4') --65 Seiten

--------------------------------------------------------------------------------

--Statistiken
SET STATISTICS time, io ON

SELECT * FROM M001_T1; --20000 Lesevorgänge, CPU-Zeit 110ms, Gesamtzeit 817ms
SELECT * FROM M001_T2; --55 Lesevorgänge, CPU-Zeit 16ms, Gesamtzeit 114ms

SELECT * FROM sys.dm_db_index_physical_stats(DB_ID(), 0, -1, 0, 'DETAILED')

SELECT OBJECT_NAME(581577110);
SELECT OBJECT_ID('M001_T1');

SELECT OBJECT_NAME(object_id), * FROM sys.dm_db_index_physical_stats(DB_ID(), 0, -1, 0, 'DETAILED')

--Die Northwind Datenbank
USE Northwind;
SELECT OBJECT_NAME(object_id), * FROM sys.dm_db_index_physical_stats(DB_ID(), 0, -1, 0, 'DETAILED')

--(Potenzielle) Probleme
--Überall nvarchar statt varchar
--Überall DateTime statt Date/Time
--Money statt Smallmoney
--Int statt Smallint/TinyInt
--Lieferadresse in Orders könnte gleich Kundenadresse sein -> Eigene Tabelle

--------------------------------------------------------------------------------

--INFORMATION_SCHEMA: Enthält Informationen über die gesamte Datenbank
SELECT * FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_TYPE = 'BASE TABLE'
ORDER BY TABLE_NAME

USE Demo;
SELECT * FROM INFORMATION_SCHEMA.COLUMNS;

--Abfragen optimieren
SELECT * FROM M001_T1 WHERE id < 100; --20000 Lesevorgänge

CREATE TABLE M001_T5(id int identity primary key unique, test char(5000));

INSERT INTO M001_T5
SELECT 'Test'
GO 20000

SELECT * FROM M001_T5 WHERE id < 100; --103 Lesevorgänge weil PK

SELECT TOP 100 * FROM M001_T5; --Auch mit TOP kann die Anzahl der Seiten reduziert werden

--Datentypen
--char: fixe Länge
--varchar: variable Länge, nur so viel wie tatsächlich verwendet wird
--n Prefix: Doppelte Länge weil Unicode
--text: Nicht verwenden, stattdessen VARCHAR(MAX)

--Numerische Datentypen
--int: 4B
--tinyint: 1B, smallint: 2B, bigint: 8B

--money: 8B, smallmoney: 4B

--float: 4B, 8B bei großen Zahlen
--decimal(X, Y): je weniger Platz, desto weniger Speicherverbrauch

--Datumswerte
--Datetime: 8B
--Date: 3B
--Time: 3B-5B (Zeitzonen)

--Files hinter der Datenbank
--C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\DATA

CREATE TABLE M001_T6(id int identity, test varchar(MAX));

INSERT INTO M001_T6
SELECT 'Test'
GO 200000 --2:30

--Transactions
--Gruppiert beliebig viele Statements zusammen
--2 Vorteile
	--Wenn ein Statement aufgrund eines Fehlers abbricht, werden alle Statements abgebrochen und zurückgesetzt
	--Alle Statements werden "vorüberprüft" -> Geschwindigkeit kann stark erhöht werden

BEGIN TRANSACTION

INSERT INTO M001_T6
SELECT 'Test'
GO 200000 --2:30

ROLLBACK;

COMMIT;