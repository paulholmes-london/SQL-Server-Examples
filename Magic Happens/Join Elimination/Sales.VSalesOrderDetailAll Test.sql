-- Test query, get the last name of the sales person for each order detail line.


-- Incomplete Elimination, e.g. joins to SalesTerritory, ShipMethod, Address etc not required
-- Compile Time: 123
-- Compile Memory: 17128
-- Reason For Early Termination: Time Out
SELECT sod.OrderSalesPersonEmployeePersonLastName
FROM Sales.vSalesOrderDetailAllV1 AS sod
OPTION (RECOMPILE)

-- Comprehensive Elimination
-- Compile Time: 108
-- Compile Memory: 16576
SELECT sod.OrderSalesPersonEmployeePersonLastName
FROM Sales.vSalesOrderDetailAllV2 AS sod
OPTION (RECOMPILE)



-- Compile when joining all.

SET STATISTICS IO ON
SET STATISTICS TIME ON

SELECT sod.*
FROM Sales.vSalesOrderDetailAllV1 AS sod
OPTION (RECOMPILE)

SELECT sod.*
FROM Sales.vSalesOrderDetailAllV2 AS sod
OPTION (RECOMPILE)

