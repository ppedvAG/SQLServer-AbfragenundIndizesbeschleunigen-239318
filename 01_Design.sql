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

--C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\DATA