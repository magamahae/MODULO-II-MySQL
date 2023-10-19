use adventureworks;
SELECT @@sql_mode;
SET @@sql_mode = SYS.LIST_DROP(@@sql_mode, 'ONLY_FULL_GROUP_BY');
SELECT @@sql_mode;


-- 1. Obtener un listado de cuál fue el volumen de ventas (cantidad) por año y método de envío mostrando para cada registro, qué porcentaje representa del total del año. Resolver utilizando Subconsultas y Funciones Ventana, luego comparar la diferencia en la demora de las consultas.<br> 

SELECT YEAR(h.OrderDate) as Año, e.Name as MetodoEnvio, SUM(d.OrderQty) as Cantidad,
	ROUND( SUM(d.OrderQty)/ t.cantidad_año * 100, 2) as porcentaje
FROM salesorderheader h
	JOIN salesorderdetail d ON (h.SalesOrderID = d.SalesOrderID)
    JOIN shipmethod e ON (e.ShipMethodID = h.ShipMethodID)
    JOIN (SELECT YEAR(h.OrderDate) as año,  SUM(d.OrderQty) as cantidad_año
		FROM salesorderheader h
			JOIN salesorderdetail d ON (h.SalesOrderID = d.SalesOrderID)
            GROUP BY YEAR(h.OrderDate))t
	ON (YEAR(h.OrderDate) = t.año)
GROUP BY Año, MetodoEnvio
ORDER BY Año, MetodoEnvio;
-- LIMIT 0, 2000	Error Code: 1055. Expression #1 of SELECT list is not in GROUP BY clause and contains nonaggregated column 'adventureworks.h.OrderDate' which is not functionally dependent on columns in GROUP BY clause; this is incompatible with sql_mode=only_full_group_by	0.000 sec
-- 0.656

SELECT	Año,
		MetodoEnvio,
        Cantidad,
        ROUND(Cantidad / SUM(Cantidad) OVER (PARTITION BY Año) * 100, 2) AS PorcentajeTotalAño
FROM (
	SELECT 	YEAR(h.OrderDate) as Año, 
			e.Name AS MetodoEnvio, 
			SUM(d.OrderQty) as Cantidad
	FROM salesorderheader h
		JOIN salesorderdetail d
			ON (h.SalesOrderID = d.SalesOrderID)
		JOIN shipmethod e
			ON (e.ShipMethodID = h.ShipMethodID)
	GROUP BY YEAR(h.OrderDate), e.Name
	ORDER BY YEAR(h.OrderDate), e.Name) AS v;
-- 0.219
    
-- 2. Obtener un listado por categoría de productos, con el valor total de ventas y productos vendidos, mostrando para ambos, su porcentaje respecto del total.<br>

SELECT	Categoria,
		Cantidad,
        format(Total,2, 'es_ES') AS TotalCategoria,
        ROUND(Cantidad / SUM(Cantidad) OVER () * 100, 2) AS PorcentajeCantidad,
        SUM(Cantidad) OVER() AS TotalCantidad,
        ROUND(Total / SUM(Total) OVER () * 100, 2) AS PorcentajeVenta
FROM (
	SELECT 	c.Name AS Categoria, 
			SUM(d.OrderQty) as Cantidad, 
            SUM(d.LineTotal) as Total
	FROM salesorderdetail d 
		JOIN product p ON (d.ProductID = p.ProductID)
		JOIN productsubcategory s ON (p.ProductSubcategoryID = s.ProductSubcategoryID)
		JOIN productcategory c ON (s.ProductCategoryID = c.ProductCategoryID)
	GROUP BY Categoria
	ORDER BY Categoria) v;

-- 3. Obtener un listado por país (según la dirección de envío), con el valor total de ventas y productos vendidos, mostrando para ambos, su porcentaje respecto del total.<br>
SELECT 	pais, 
		ventas, 
        ROUND(ventas / SUM(ventas) OVER () * 100, 2) as porcentaje_venta,
        prod_vendidos_cant, 
		ROUND(prod_vendidos_cant/ SUM(prod_vendidos_cant) OVER () * 100, 2) as porcentaje_prod_v_cant
		
FROM (
		SELECT c.Name as pais,
        SUM(d.OrderQty) as prod_vendidos_cant,
        SUM(d.LineTotal)as ventas
        FROM  salesorderheader h
		JOIN salesorderdetail d
		ON (h.SalesOrderID = d.SalesOrderID)
		JOIN address a 
        ON (h.ShipToAddressID = a.AddressID)
        JOIN stateprovince s
        ON(s.StateProvinceID = a.StateProvinceID)
		JOIN countryregion c    
        ON (c.CountryRegionCode= s.CountryRegionCode)
        
        GROUP BY c.Name
        ORDER BY c.Name)v;
        

-- 4. Obtener por ProductID, los valores correspondientes a la mediana de las ventas (LineTotal), sobre las ordenes realizadas. Investigar las funciones FLOOR() y CEILING().

SELECT ProductID, AVG(LineTotal) AS Mediana_Producto, Cnt
FROM (
	SELECT	d.ProductID,
			d.LineTotal, 
			COUNT(*) OVER (PARTITION BY d.ProductID) AS Cnt,
			ROW_NUMBER() OVER (PARTITION BY d.ProductID ORDER BY d.LineTotal) AS RowNum
	FROM	salesorderheader h
			JOIN salesorderdetail d 
            ON (h.SalesOrderID = d.SalesOrderID)) v
WHERE 	(FLOOR(Cnt/2) = CEILING(Cnt/2) AND (RowNum = FLOOR(Cnt/2) OR RowNum = FLOOR(Cnt/2) + 1))
OR		(FLOOR(Cnt/2) <> CEILING(Cnt/2) AND RowNum = CEILING(Cnt/2))
GROUP BY ProductID;
