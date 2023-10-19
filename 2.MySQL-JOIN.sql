use adventureworks;
-- 1. Obtener un listado contactos que hayan ordenado productos de la subcategoría "Mountain Bikes", 
-- entre los años 2000 y 2003, cuyo método de envío sea "CARGO TRANSPORT 5".<br>
SELECT DISTINCT c.LastName, c.FirstName 
FROM salesorderheader h
	JOIN contact c
		ON (h.ContactID = c.ContactID)
	JOIN salesorderdetail d
		ON (h.SalesOrderID = d.SalesOrderID)
	JOIN product p
		ON (d.ProductID = p.ProductID)
	JOIN productsubcategory s
		ON (p.ProductSubcategoryID = s.ProductCategoryID)
	JOIN shipmethod e
		ON (e.ShipMethodID = h.ShipMethodID)
WHERE YEAR(h.OrderDate) BETWEEN 2000 AND 2003
AND s.Name = 'Mountain Bikes'
AND e.Name = 'CARGO TRANSPORT 5';


-- 2. Obtener un listado contactos que hayan ordenado productos de la subcategoría "Mountain Bikes", 
-- entre los años 2000 y 2003 con la cantidad de productos adquiridos y ordenado por este valor, 
-- de forma descendente.<br>
SELECT DISTINCT c.LastName, c.FirstName, SUM(d.OrderQty) as Cant_p
FROM salesorderheader h
	JOIN contact c
		ON (h.ContactID = c.ContactID)
	JOIN salesorderdetail d
		ON (h.SalesOrderID = d.SalesOrderID)
	JOIN product p
		ON (d.ProductID = p.ProductID)
	JOIN productsubcategory s
		ON (p.ProductSubcategoryID = s.ProductCategoryID)
WHERE YEAR(h.OrderDate) BETWEEN 2000 AND 2003
AND s.Name = 'Mountain Bikes'
GROUP by c.LastName, c.FirstName
ORDER BY cant_p;

-- 3. Obtener un listado de cual fue el volumen de compra (cantidad) por año y método de envío.<br> 
SELECT YEAR(h.OrderDate) as año, s.Name as metodo, SUM(d.OrderQty) as cantidad
FROM salesorderheader h 
	JOIN shipmethod s
    ON (s.ShipMethodID = h.ShipMethodID)
	JOIN salesorderdetail d
    ON (h.SalesOrderID = d.SalesOrderID)
GROUP BY año, metodo
ORDER BY año, metodo;

-- 4. Obtener un listado por categoría de productos, con el valor total de ventas y productos vendidos.<br>
SELECT c.Name AS categoria, SUM(d.OrderQty) AS total_ventas, SUM(d.LineTotal) as prod_vendidos
FROM  salesorderheader h
	JOIN salesorderdetail d
    ON (h.SalesOrderID = d.SalesOrderID)
    JOIN product p
		ON (d.ProductID = p.ProductID)
	JOIN productsubcategory s
		ON (p.ProductSubcategoryID = s.ProductCategoryID)
	JOIN productcategory c
		ON (s.ProductCategoryID = c.ProductCategoryID)
GROUP BY categoria
ORDER BY categoria;

-- 5. Obtener un listado por país (según la dirección de envío), con el valor total de ventas y productos vendidos, 
-- sólo para aquellos países donde se enviaron más de 15 mil productos.<br>

SELECT cr.Name AS pais, SUM(d.OrderQty) AS total_ventas, SUM(d.LineTotal) as prod_vendidos
FROM  salesorderheader h
	JOIN salesorderdetail d
		ON (h.SalesOrderID = d.SalesOrderID)
	JOIN address a
		ON (h.ShipToAddressID = a.AddressID)
	JOIN stateprovince sp
		ON (a.StateProvinceID = sp.StateProvinceID)
	JOIN countryregion cr
		ON (sp.CountryRegionCode = cr.CountryRegionCode)
GROUP BY pais
HAVING total_ventas > 15000
ORDER BY pais;

-- 6. Obtener un listado de las cohortes que no tienen alumnos asignados, utilizando la base de datos henry, 
-- desarrollada en el módulo anterior.
use henry;

SELECT c.codigo as Cohorte
FROM cohorte c 
	LEFT JOIN alumno a
    ON (a.idCohorte = c.idCohorte)
WHERE a.idCohorte is NULL;