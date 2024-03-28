--Kompression
--Daten verkleinern
--Vorteil: Weniger Speicherverbrauch, kürzere Ladezeiten
--Nachteil: CPU-Aufwand beim Speichern/Laden der Daten

--Zwei verschiedene Arten der Kompression
--Zeilenkompression: Daten selbst komprimiert, 50%
--Seitenkompression: Zeilenkompression + Seiten dazu, 70%

--SELECT        Employees.LastName, Employees.FirstName, Employees.BirthDate, Employees.HireDate, Employees.Address, Employees.City, Employees.Region, Employees.PostalCode, Employees.Country, Employees.HomePhone, 
--                         Employees.Salary, Orders.OrderDate, Orders.RequiredDate, Orders.ShippedDate, Orders.OrderID, Employees.EmployeeID AS Expr1, Orders.Freight, Shippers.ShipperID AS Expr2, Shippers.CompanyName AS Expr3, 
--                         Shippers.Phone AS Expr4, Products.ProductID, Products.ProductName, Products.QuantityPerUnit, Products.UnitPrice, [Order Details].OrderID AS Expr5, [Order Details].ProductID AS Expr6, [Order Details].Quantity, 
--                         [Order Details].Discount, [Order Details].UnitPrice AS Expr7, Customers.CustomerID, Customers.CompanyName, Customers.ContactName, Customers.ContactTitle, Customers.Address AS Expr8, Customers.City AS Expr9, 
--                         Customers.Region AS Expr10, Customers.PostalCode AS Expr11, Customers.Country AS Expr12, Customers.Phone, Customers.Fax
--INTO KundenUmsatz FROM  Customers INNER JOIN
--                         Orders ON Customers.CustomerID = Orders.CustomerID INNER JOIN
--                         Employees ON Orders.EmployeeID = Employees.EmployeeID INNER JOIN
--                         [Order Details] ON Orders.OrderID = [Order Details].OrderID INNER JOIN
--                         Products ON [Order Details].ProductID = Products.ProductID INNER JOIN
--                         Shippers ON Orders.ShipVia = Shippers.ShipperID

SELECT TOP 0 *
INTO KundenUmsatz
FROM Northwind.dbo.KundenUmsatz;

INSERT INTO KundenUmsatz
SELECT * FROM Northwind.dbo.KundenUmsatz

------------------------------------------------------------------

SET STATISTICS time, io ON

SELECT * FROM KundenUmsatz
--Ohne Kompression
--logische Lesevorgänge: 89891
--CPU-Zeit = 4234 ms, verstrichene Zeit = 28877 ms
--95.92% Seitendichte

SELECT * FROM KundenUmsatz
--Row Compression
--logische Lesevorgänge: 50059
--CPU-Zeit = 5219 ms, verstrichene Zeit = 28929 ms
--97.76% Seitendichte

SELECT 1 - 392.133/702.281
--44.16294902% Platzersparnis

dbcc showcontig('KundenUmsatz')

SELECT 1 - 194.727/702.281
--72.27221013% Platzersparnis

SELECT * FROM KundenUmsatz
--Row Compression
--logische Lesevorgänge: 24046
--CPU-Zeit = 8734 ms, verstrichene Zeit = 33076 ms
--98.55% Seitendichte