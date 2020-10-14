--------------------------------------
-- **** www.paulholmes.net ***
-- Step by step guide to logical trees
--------------------------------------

-- The following are repros demonstrating the observations made in
-- Logical Trees Part 3
-- http://www.paulholmes.net/2020/08/logical-trees-part-2-overview-of-trees.html


-- Examples should work in all version of AdventureWorks from 2008R2 onwards.
USE AdventureWorks2008R2;





-- Select a column

SELECT ProductID
FROM Production.Product
OPTION (RECOMPILE, QUERYTRACEON 8605, QUERYTRACEON 8606, QUERYTRACEON 8607, QUERYTRACEON 3604);

/* *** Converted Tree: ***

LogOp_Project QCOL: [AdventureWorks2017].[Production].[Product].ProductID
    LogOp_Get TBL: Production.Product Production.Product TableID=482100758 TableReferenceID=0 IsRow: COL: IsBaseRow1000 
    AncOp_PrjList 		

LogOp_Get specifies the table given in the query.
The second reference is to the base table - in this case the same.
TableId is the object Id.
TableReferenceID may be used to differentiate otherwise ambiguous table references; See later example.

LogOp_Project {column specifiers} has two children:
- The LogOp_Get describing the table read.
- AncOp_PrjList; which can have it's own children producing derived columns.
*/



-- Select a column with table alias

SELECT p.ProductID
FROM Production.Product AS p
OPTION (RECOMPILE, QUERYTRACEON 8605, QUERYTRACEON 8606, QUERYTRACEON 8607, QUERYTRACEON 3604);

/* *** Converted Tree: ***

LogOp_Project QCOL: [p].ProductID
    LogOp_Get TBL: Production.Product(alias TBL: p) Production.Product TableID=482100758 TableReferenceID=0 IsRow: COL: IsBaseRow1000
    AncOp_PrjList

Project uses the table alias in the column specifier
Get associates the table with an alias.
*/



-- Select multiple columns

SELECT p.ProductID,
       p.Name
FROM Production.Product AS p
OPTION (RECOMPILE, QUERYTRACEON 8605, QUERYTRACEON 8606, QUERYTRACEON 8607, QUERYTRACEON 3604);

/*  *** Converted Tree: ***

LogOp_Project QCOL: [p].ProductID QCOL: [p].Name
    LogOp_Get TBL: Production.Product(alias TBL: p) Production.Product TableID=482100758 TableReferenceID=0 IsRow: COL: IsBaseRow1000
    AncOp_PrjList

Project specifies more than one QCOL columns
*/



-- Select from a table synonym

CREATE SYNONYM Production.ProductSynonym
FOR Production.Product;

SELECT ps.ProductID
FROM Production.ProductSynonym AS ps
OPTION (RECOMPILE, QUERYTRACEON 8605, QUERYTRACEON 8606, QUERYTRACEON 8607, QUERYTRACEON 3604);

DROP SYNONYM Production.ProductSynonym;

/* *** Converted Tree: ***

LogOp_Project QCOL: [ps].ProductID
    LogOp_Get TBL: Production.ProductSynonym(alias TBL: ps) Production.Product TableID=482100758 TableReferenceID=0 IsRow: COL: IsBaseRow1000
    AncOp_PrjList 

LogOp_Get specifies the synonym, and then specifies the base table.
*/



-- Optimization: Index Matching

SELECT p.Name
FROM Production.Product AS p
OPTION (RECOMPILE, QUERYTRACEON 8605, QUERYTRACEON 8606, QUERYTRACEON 8607, QUERYTRACEON 3604);

/* *** Output Tree: (trivial plan) ***

PhyOp_NOP
    PhyOp_Range TBL: Production.Product(alias TBL: p)(3) ASC  Bmk ( QCOL: [p].ProductID) IsRow: COL: IsBaseRow1000 

Index matching looks for the narrowest index that will satisfy the query fastest.
In this case the only column needed is Name.
Index Id 3 - AK_Product_Name - is chosen. It is the narrowest of the indexes that contain the Name column
*/




-- Finding Index Ids

SELECT [Schema] = OBJECT_SCHEMA_NAME(i.object_id),
       [Table] = OBJECT_NAME(i.object_id),
       i.index_id,
       IndexName = i.name
FROM sys.indexes AS i
ORDER BY [Schema],
         [Table],
         i.index_id,
         IndexName;