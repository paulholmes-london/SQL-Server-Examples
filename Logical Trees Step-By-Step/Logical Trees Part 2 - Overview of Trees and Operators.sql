--------------------------------------
-- **** www.paulholmes.net ***
-- Step by step guide to logical trees
--------------------------------------

-- The following are repros demonstrating the observations made in
-- Logical Trees Part 2
-- http://www.paulholmes.net/2020/08/logical-trees-part-2-overview-of-trees.html


-- Examples should work in all version of AdventureWorks from 2008R2 onwards.
USE AdventureWorks2019;





--------------------
-- 1: CONVERTED
--------------------



-- Converted Tree: Constant Folding
SELECT p.ProductID
FROM Production.Product AS p
WHERE p.ProductID = 10 + 2
OPTION (RECOMPILE, QUERYTRACEON 8605, QUERYTRACEON 8606, QUERYTRACEON 8607, QUERYTRACEON 3604);



-- Simplified Tree: Constant Folding (Comparison)
SELECT p.ProductID
FROM Production.Product AS p
WHERE 1 = 0
OPTION (RECOMPILE, QUERYTRACEON 8605, QUERYTRACEON 8606, QUERYTRACEON 8607, QUERYTRACEON 3604);



-- Converted Tree: View expanded, encapsulated in LogOp_ViewAnchor
SELECT spcr.*
FROM Person.vStateProvinceCountryRegion AS spcr
OPTION (RECOMPILE, QUERYTRACEON 8605, QUERYTRACEON 8606, QUERYTRACEON 8607, QUERYTRACEON 3604);



-- Converted Tree: CTE expanded, encapsulated in LogOp_ViewAnchor
WITH StateProvinceCountryRegion
AS (SELECT sp.[StateProvinceID],
           cr.[CountryRegionCode]
    FROM [Person].[StateProvince] sp
        INNER JOIN [Person].[CountryRegion] cr
            ON sp.[CountryRegionCode] = cr.[CountryRegionCode])
SELECT spcr.*
FROM StateProvinceCountryRegion AS spcr
OPTION (RECOMPILE, QUERYTRACEON 8605, QUERYTRACEON 8606, QUERYTRACEON 8607, QUERYTRACEON 3604);
GO



-- Inline Table Valued Function (TVF)
CREATE OR ALTER FUNCTION Production.vProductListPriceLessThan
(
    @ListPrice MONEY
)
RETURNS TABLE
AS
RETURN SELECT p.ProductID
       FROM Production.Product AS p
       WHERE p.ListPrice < @ListPrice;
GO

-- Converted Tree: Inline TVF expanded, encapsulated in LogOp_ViewAnchor
SELECT plt.ProductID
FROM Production.vProductListPriceLessThan(100) AS plt
OPTION (RECOMPILE, QUERYTRACEON 8605, QUERYTRACEON 8606, QUERYTRACEON 8607, QUERYTRACEON 3604);

-- Cleanup
DROP FUNCTION IF EXISTS Production.vProductListPriceLessThan;



-- Converted Tree: Negation Normal Form (NNF). 
-- NNF Explainer: Rules via Morgan's laws
-- https://en.wikipedia.org/wiki/De_Morgan%27s_laws
-- Debugger observation: Not implemented in the CNormalizeExpr::NNFConvert function.
SELECT p.ProductID
FROM Production.Product AS p
WHERE NOT (
              p.ProductID = 10
              OR p.ProductID = 20
          ) -- << Normalized as NNF: NOT p.ProductID = 10 AND NOT p.ProductID = 20
OPTION (RECOMPILE, QUERYTRACEON 8605, QUERYTRACEON 8606, QUERYTRACEON 8607, QUERYTRACEON 3604);



-- Converted Tree: Double Negative Eliminated.
SELECT p.ProductID
FROM Production.Product AS p
WHERE NOT (NOT (p.ProductID = 10))
OPTION (RECOMPILE, QUERYTRACEON 8605, QUERYTRACEON 8606, QUERYTRACEON 8607, QUERYTRACEON 3604);



-- Converted Tree: Calculated Column sod.LineTotal Expanded (happens regardless of whether col is selected)
SELECT sod.SalesOrderID
FROM Sales.SalesOrderDetail AS sod
OPTION (RECOMPILE, QUERYTRACEON 8605, QUERYTRACEON 8606, QUERYTRACEON 8607, QUERYTRACEON 3604);





----------------
-- 2: INPUT
----------------



-- Input Tree: Regular Join converted to Cartesian + Filter
SELECT p.ProductID
FROM Production.Product AS p
    JOIN Production.ProductSubcategory AS psc
        ON psc.ProductSubcategoryID = p.ProductSubcategoryID
           AND psc.Name = p.Name
OPTION (RECOMPILE, QUERYTRACEON 8605, QUERYTRACEON 8606, QUERYTRACEON 8607, QUERYTRACEON 3604);



-- Input Tree: LogOp_UnionAll of two independent LogOpConstTableGet, folded into single LogOpConstTableGet
SELECT *
FROM
(
    VALUES
        (55, 'Foo'),
        (99, 'Bar')
) AS Test (Id, Name);



-- Input Tree: Passive LogOpProject for each table eliminated
SELECT p.ProductID
FROM Production.Product AS p
UNION ALL
SELECT th.ProductID
FROM Production.TransactionHistory AS th
UNION ALL
SELECT pr.ProductID
FROM Production.ProductReview AS pr
OPTION (RECOMPILE, QUERYTRACEON 8605, QUERYTRACEON 8606, QUERYTRACEON 8607, QUERYTRACEON 3604);



-- Input Tree: View Anchor replaced by passive projection
SELECT spcr.StateProvinceID
FROM Person.vStateProvinceCountryRegion AS spcr
OPTION (RECOMPILE, QUERYTRACEON 8605, QUERYTRACEON 8606, QUERYTRACEON 8607, QUERYTRACEON 3604);



-- Input Tree: View Anchor for CTE replaced by passive projection
WITH StateProvinceCountryRegion
AS (SELECT sp.[StateProvinceID],
           cr.[CountryRegionCode]
    FROM [Person].[StateProvince] sp
        INNER JOIN [Person].[CountryRegion] cr
            ON sp.[CountryRegionCode] = cr.[CountryRegionCode])
SELECT spcr.*
FROM StateProvinceCountryRegion AS spcr
OPTION (RECOMPILE, QUERYTRACEON 8605, QUERYTRACEON 8606, QUERYTRACEON 8607, QUERYTRACEON 3604);





---------------------
-- 3: SIMPLIFIED
---------------------



-- Simplified Tree: Left Join Elimination - Rule: RedundantLOJN
SELECT p.ProductID
FROM Production.Product AS p
    LEFT JOIN Production.ProductSubcategory AS psc
        ON psc.ProductSubcategoryID = p.ProductSubcategoryID
OPTION (RECOMPILE, QUERYTRACEON 8605, QUERYTRACEON 8606, QUERYTRACEON 8607, QUERYTRACEON 3604);



-- Simplified tree: Outer Join Converted to Inner
SELECT p.ProductID
FROM Production.Product AS p
    LEFT JOIN Production.ProductSubcategory AS psc
        ON psc.ProductSubcategoryID = p.ProductSubcategoryID
WHERE psc.Name = 'a'
OPTION (RECOMPILE, QUERYTRACEON 8605, QUERYTRACEON 8606, QUERYTRACEON 8607, QUERYTRACEON 3604);



-- Simplified Tree: Eliminate empty select, resulting from contradiction - Rule: SelectOnEmpty
SELECT p.ProductID
FROM Production.Product AS p
WHERE 1 = 0
OPTION (RECOMPILE, QUERYTRACEON 8605, QUERYTRACEON 8606, QUERYTRACEON 8607, QUERYTRACEON 3604);



-- Simplified Tree: Contradiction
SELECT p.Name
FROM Production.Product AS p
WHERE p.ListPrice < 10 AND
	p.ListPrice > 10
OPTION (RECOMPILE, QUERYTRACEON 8605, QUERYTRACEON 8606, QUERYTRACEON 8607, QUERYTRACEON 3604);



-- Simplified Tree: Contradiction (Check Constraint)
SELECT p.Name
FROM Production.Product AS p
WHERE p.ListPrice < 0
OPTION (RECOMPILE, QUERYTRACEON 8605, QUERYTRACEON 8606, QUERYTRACEON 8607, QUERYTRACEON 3604);





-- Simplified Tree: Domain Simplification - Apparent Rule: SelPredNorm
SELECT p.ProductID
FROM Production.Product AS p
WHERE p.ProductID
      BETWEEN 1 AND 5
      AND p.ProductID
      BETWEEN 5 AND 10
OPTION (RECOMPILE, QUERYTRACEON 8605, QUERYTRACEON 8606, QUERYTRACEON 8607, QUERYTRACEON 3604);



-- Simplified Tree: Eliminate Unecessary Group By - GbAggToPrj
SELECT p.ProductID,
       SUM(1)
FROM Production.Product AS p
GROUP BY p.ProductID
OPTION (RECOMPILE, QUERYTRACEON 8605, QUERYTRACEON 8606, QUERYTRACEON 8607, QUERYTRACEON 3604);



-- Simplified Tree: Eliminate Unused Calculation  (resulted from calc col in table).
SELECT sod.SalesOrderID
FROM Sales.SalesOrderDetail AS sod
OPTION (RECOMPILE, QUERYTRACEON 8605, QUERYTRACEON 8606, QUERYTRACEON 8607, QUERYTRACEON 3604);



-- Simplified Tree: Predicate Pushdown; Select + Cartesian Join Converted To Regular Join (SEL JN -> JN)
SELECT p.ProductID
FROM Production.Product AS p
    JOIN Production.ProductSubcategory AS ps
        ON ps.ProductSubcategoryID = p.ProductSubcategoryID
WHERE p.ProductID = 10
OPTION (RECOMPILE, QUERYTRACEON 8605, QUERYTRACEON 8606, QUERYTRACEON 8607, QUERYTRACEON 3604);



-- Simplified Tree: Predicate Commute: Index seex on equivelent of predicate specified
SELECT c.CustomerID
FROM Sales.Customer AS c
    JOIN Sales.Store AS s
        ON s.BusinessEntityID = c.StoreID
WHERE c.StoreID < 10
OPTION (RECOMPILE, QUERYTRACEON 8605, QUERYTRACEON 8606, QUERYTRACEON 8607, QUERYTRACEON 3604);





--------------------------------------------------------------------
-- 4: JOIN-COLLAPSED
-- aka: after Heuristic Join Reordering
-- Shown as Fix initial join order in Conor Cunningham Presentation.
--------------------------------------------------------------------



-- Join Collapsed Tree: Redundant col from TVC eliminated
SELECT p.ProductID,
       Test.Id
FROM Production.Product AS p
    CROSS JOIN
    (
        VALUES
            (55, 'Foo'),
            (99, 'Bar')
    ) AS Test (Id, Name)
OPTION (RECOMPILE, QUERYTRACEON 8605, QUERYTRACEON 8606, QUERYTRACEON 8607, QUERYTRACEON 3604);



-- Join Collapsed Tree: Redundant join eliminated.
SELECT psc.Name
FROM Production.ProductSubcategory AS psc
    JOIN Production.ProductCategory AS pc
        ON pc.ProductCategoryID = psc.ProductCategoryID
OPTION (RECOMPILE, QUERYTRACEON 8605, QUERYTRACEON 8606, QUERYTRACEON 8607, QUERYTRACEON 3604);



-- Join Collapsed Tree: Conventional multi table join transformed to LogOp_NAryJoin
SELECT p.Name,
       pc.Name
FROM Production.Product AS p
    JOIN Production.ProductSubcategory AS psc
        ON psc.ProductSubcategoryID = p.ProductSubcategoryID
    JOIN Production.ProductCategory AS pc
        ON pc.ProductCategoryID = psc.ProductCategoryID
OPTION (RECOMPILE, QUERYTRACEON 8605, QUERYTRACEON 8606, QUERYTRACEON 8607, QUERYTRACEON 3604);





----------------------------------
-- 5: BEFORE PROJECT NORMALIZATION - No changes
----------------------------------

--- See: https://dba.stackexchange.com/questions/273342/logical-trees-difference-between-before-project-normalization-and-join-collapse




---------------------------------
-- 6: AFTER PROJECT NORMALIZATION
---------------------------------



-- Expression matched to a calculated col, folded back to that.
SELECT ISNULL(([UnitPrice] * ((1.0) - [UnitPriceDiscount])) * [OrderQty], (0.0)) / 100
FROM Sales.SalesOrderDetail AS sod
OPTION (RECOMPILE, QUERYTRACEON 8605, QUERYTRACEON 8606, QUERYTRACEON 8607, QUERYTRACEON 3604);



-- Common expression LEFT(p.Name, 2) rewritten into single evaluation (Expr1001)
SELECT p.ProductID
FROM Production.Product AS p
WHERE LEFT(p.Name, 2) >= 'FR'
      AND LEFT(p.Name, 2) < 'FS'
OPTION (RECOMPILE, QUERYTRACEON 8605, QUERYTRACEON 8606, QUERYTRACEON 8607, QUERYTRACEON 3604);



-- Derived Column [Name] expression pushed down, from above to below join
SELECT p.FirstName + ' ' + p.LastName AS [Name]
FROM Person.Person AS p
    INNER JOIN HumanResources.Employee e
        ON p.BusinessEntityID = e.BusinessEntityID
OPTION (RECOMPILE, QUERYTRACEON 8605, QUERYTRACEON 8606, QUERYTRACEON 8607, QUERYTRACEON 3604);

