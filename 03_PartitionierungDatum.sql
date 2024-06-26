--Prozedur erstellen
	--PFunktion erweitern
	--PSchema erweitern
		--Neue Dateigruppe + Datei erstellen
	--Bestehende Daten bewegen

CREATE TABLE M003_Umsatz(Datum date, Umsatz float);

BEGIN TRANSACTION
DECLARE @i int = 0;
WHILE @i < 1000000
BEGIN
	INSERT INTO M003_Umsatz VALUES
	(DATEADD(DAY, FLOOR(RAND()*1096), '20200101'), RAND() * 1000);
	SET @i += 1;
END
COMMIT;

CREATE PARTITION FUNCTION pfDatum(DATE)
AS
RANGE LEFT FOR VALUES('2019-12-31', '2020-12-31', '2021-12-31', '2022-12-31')

ALTER DATABASE [Demo] ADD FILEGROUP [M003_D1]
ALTER DATABASE [Demo] ADD FILEGROUP [M003_D2]
ALTER DATABASE [Demo] ADD FILEGROUP [M003_D3]
ALTER DATABASE [Demo] ADD FILEGROUP [M003_D4]
ALTER DATABASE [Demo] ADD FILEGROUP [M003_D5]

ALTER DATABASE [Demo]
ADD FILE
(
	NAME = N'M003_DF1',
	FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\DATA\Demo\DF1.ndf',
	SIZE = 8192KB,
	FILEGROWTH = 65536KB
)
TO FILEGROUP [M003_D1]

ALTER DATABASE [Demo]
ADD FILE
(
	NAME = N'M003_DF2',
	FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\DATA\Demo\DF2.ndf',
	SIZE = 8192KB,
	FILEGROWTH = 65536KB
)
TO FILEGROUP [M003_D2]

ALTER DATABASE [Demo]
ADD FILE
(
	NAME = N'M003_DF3',
	FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\DATA\Demo\DF3.ndf',
	SIZE = 8192KB,
	FILEGROWTH = 65536KB
)
TO FILEGROUP [M003_D3]

ALTER DATABASE [Demo]
ADD FILE
(
	NAME = N'M003_DF4',
	FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\DATA\Demo\DF4.ndf',
	SIZE = 8192KB,
	FILEGROWTH = 65536KB
)
TO FILEGROUP [M003_D4]

ALTER DATABASE [Demo]
ADD FILE
(
	NAME = N'M003_DF5',
	FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\DATA\Demo\DF5.ndf',
	SIZE = 8192KB,
	FILEGROWTH = 65536KB
)
TO FILEGROUP [M003_D5]

CREATE PARTITION SCHEME schDatum
AS
PARTITION pfDatum TO(M003_D1, M003_D2, M003_D3, M003_D4, M003_D5)

--Tabelle auf Schema legen
CREATE TABLE M003_Umsatz2(Datum date, Umsatz float)
ON schDatum(Datum);

INSERT INTO M003_Umsatz2
SELECT * FROM M003_Umsatz

--DROP TABLE M003_Umsatz

SET STATISTICS time, io ON

SELECT * FROM M003_Umsatz2
WHERE Datum BETWEEN '2020-01-01' AND '2020-12-31'

SELECT OBJECT_NAME(object_id), * FROM sys.dm_db_index_physical_stats(DB_ID(), 0, -1, 0, 'DETAILED')

SELECT RIGHT(YEAR(GETDATE()), 2);

GO
--Prozedur
DROP PROC neuesJahr;

CREATE PROCEDURE neuesJahr AS
DECLARE @jahr char(2) = RIGHT(YEAR(GETDATE()), 2);
	
DECLARE @nameDG char(7) = CONCAT('M003_', @jahr);
DECLARE @nameFile char(8) = CONCAT('M003_F', @jahr);

DECLARE @neueDG varchar(500) = 'ALTER DATABASE [Demo] ADD FILEGROUP [' + @nameDG + ']';
EXEC @neueDG;

DECLARE @addFile varchar(1024) = 'ALTER DATABASE [Demo] ADD FILE (NAME = ' + @nameFile + ', FILENAME = C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\DATA\Demo\' + @nameFile + '.ndf), SIZE = 8192KB, FILEGROWTH = 65536KB) TO FILEGROUP [' + @nameDG + ']';
EXEC @addFile;

ALTER PARTITION FUNCTION pfDatum()
SPLIT RANGE (CONCAT(YEAR(GETDATE())-1, '-12-31'));

DECLARE @alterScheme VARCHAR(256) = 'ALTER PARTITION SCHEME schDatum NEXT USED' + @nameDG;
EXEC @alterScheme;



EXEC neuesJahr;

INSERT INTO M003_Umsatz2 VALUES ('2024-02-02', 333)
SELECT *, $partition.pfDatum(Datum) FROM M003_Umsatz2;