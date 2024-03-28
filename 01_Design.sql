/*
	Normalformen zusammengefasst:
	1. Jede Zelle sollte genau einen Wert haben
		- Adresse aufteilen in einzelne Spalten
		- Sonst muss diese eine Spalte sp�ter wieder getrennt werden (Funktion -> Teuer)
	2. Jeder Datensatz sollte einen Prim�rschl�ssel haben
	3. Beziehungen sollten nur zwischen Schl�sselspalten existieren

	Redundanz verringern (Daten nicht doppelt speichern)
		- Beziehungen (Fremdschl�ssel)
		- Gro�e Tabellen in kleinere Tabellen aufteilen

	Kundentabelle (1 Mio. DS)
	Bestellungen (100 Mio. DS)
	Kunden <- Beziehung -> Bestellung
*/

--C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\DATA