use adventureworks;

-- 1)Crear un procedimiento que recibe como parámetro una fecha y muestre la cantidad de órdenes ingresadas en esa fecha.
DROP PROCEDURE cantOrdenes;

DELIMITER $$

CREATE PROCEDURE cantOrdenes (IN fecha DATE)
BEGIN
	SELECT COUNT(*)
	FROM salesorderheader
    WHERE DATE(OrderDate) = fecha;
END $$

DELIMITER ;

CALL cantOrdenes('2003-09-22');

-- -------------------------------------------------------------------------------

-- 2)Crear una función que calcule el valor nominal de un margen 
-- bruto determinado por el usuario a partir del precio de lista de los productos.
SET GLOBAL log_bin_trust_function_creators = 1; -- variable global q permite crear funciones
DROP FUNCTION valor_nominal;
DELIMITER $$
CREATE FUNCTION valor_nominal(precio_lista DECIMAL(10,2), margen_b DECIMAL (10,2)) RETURNS DECIMAL (10,2)
BEGIN
	DECLARE margenBruto DECIMAL (15,3);
    SET margenBruto = precio_lista * margen_b;
    RETURN margenBruto;
END$$
DELIMITER ;

Select valor_nominal(100.50, 1.2);

--------------------------------------------------------------------------------------------------------------

-- 3)Obtner un listado de productos en orden alfabético que muestre cuál debería ser el valor de precio de lista, 
-- si se quiere aplicar un margen bruto del 20%, utilizando la función creada en el punto 2, sobre el campo
-- StandardCost. Mostrando tambien el campo ListPrice y la diferencia con el nuevo campo creado.
SELECT 	ProductID,
		Name,
        ProductNumber,
        ListPrice,
        valor_nominal(StandardCost, 1.2) as Precio_con_margen, StandardCost, ListPrice,
        round(ListPrice - valor_nominal(StandardCost, 1.2),2) as Diferencia
FROM product
ORDER BY Name;

-- ------------------------------------------------------------------------------------------------------------

-- 4)Crear un procedimiento que reciba como parámetro una fecha desde y una hasta, y muestre un listado con los Id 
-- de los diez Clientes que más costo de transporte tienen entre esas fechas (campo Freight).
DROP PROCEDURE MAS_COSTO_TRANSP;

DELIMITER $$

CREATE PROCEDURE MAS_COSTO_TRANSP (IN fecha_desde DATE, IN fecha_hasta DATE)
BEGIN
	SELECT CustomerID, SUM(Freight) AS Total_Costo_Transp
	FROM salesorderheader
    WHERE OrderDate BETWEEN fecha_desde AND fecha_hasta
    GROUP BY CustomerID
    ORDER BY Total_Costo_Transp DESC
    LIMIT 10;
END $$

DELIMITER ;

CALL MAS_COSTO_TRANSP('2002-01-01','2002-01-31');

-- --------------------------------------------------------------------------------------------------

-- 5)Crear un procedimiento que permita realizar la insercción de datos en la tabla shipmethod.

DROP PROCEDURE cargar_Shipmethod;

DELIMITER $$
CREATE PROCEDURE cargar_Shipmethod(IN nombre VARCHAR(50), IN ship_base DOUBLE, IN ship_rate DOUBLE)
BEGIN
    INSERT INTO shipmethod (Name, ShipBase, ShipRate, ModifiedDate)
	VALUES (nombre,ship_base,ship_rate,NOW());
END $$
DELIMITER ;

CALL cargar_Shipmethod('Prueba', 1.5, 3.5);

SELECT * FROM shipmethod;
