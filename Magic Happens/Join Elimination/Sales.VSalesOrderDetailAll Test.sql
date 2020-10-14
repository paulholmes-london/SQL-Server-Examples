SET STATISTICS IO ON;
SET STATISTICS TIME ON;


-----------------------------------------------
-- Compile & Execution For Minimal Use
-----------------------------------------------

/* -- Normal Joins
Incomplete Elimination, e.g. joins to SalesTerritory, ShipMethod, Address etc not required
Compile Time: 105
Compile Memory: 17128
Reason For Early Termination: Good Enough Plan Found.
Logical Reads: 1,121
*/

SELECT  sod.SalesOrderID,
        sod.SalesOrderDetailID
FROM Sales.vSalesOrderDetailAllV1 AS sod
OPTION (RECOMPILE);


/* -- All Outer Joins
Comprehensive Elimination
Compile Time: 106
Compile Memory: 16576
Logical Reads: 420
*/
SELECT  sod.SalesOrderID,
        sod.SalesOrderDetailID
FROM Sales.vSalesOrderDetailAllV2 AS sod
OPTION (RECOMPILE);




-----------------------------------------------
-- Compile & Execution For One Column needing joins.
-----------------------------------------------

-- Test query, get the last name of the sales person for each order detail line.
-- Elimination Tests


/* -- Normal Joins
Incomplete Elimination, e.g. joins to SalesTerritory, ShipMethod, Address etc not required
Compile Time: 123
Compile Memory: 17128
Reason For Early Termination: Time Out
Logical Reads: 1,121
*/
SELECT sod.OrderSalesPersonEmployeePersonLastName
FROM Sales.vSalesOrderDetailAllV1 AS sod
OPTION (RECOMPILE);


/* -- All Outer Joins
Comprehensive Elimination
Compile Time: 108
Compile Memory: 16576
Logical Reads: 420
*/
SELECT sod.OrderSalesPersonEmployeePersonLastName
FROM Sales.vSalesOrderDetailAllV2 AS sod
OPTION (RECOMPILE);



---------------------------------------
-- Compile & Execution When Joining All
---------------------------------------


/* -- Normal Joins
Compile Time: 2822
Compile Memory: 107128
Reason For Early Termination: Time Out
Execution Elapsed Time: 42308 ms.
Logical Reads: 4,944,623
*/
SELECT sod.*
FROM Sales.vSalesOrderDetailAllV1 AS sod
OPTION (RECOMPILE);


/* -- All Outer Joins
Compile Time: 18495
Compile Memory: 329368
Reason For Early Termination: Time Out
Execution Elapsed Time: 48672 ms.
Logical Reads: 4,945,008
*/
SELECT sod.*
FROM Sales.vSalesOrderDetailAllV2 AS sod
OPTION (RECOMPILE);

