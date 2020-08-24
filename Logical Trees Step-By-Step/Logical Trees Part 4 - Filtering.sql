--------------------------------------
-- **** www.paulholmes.net ***
-- Step by step guide to logical trees
--------------------------------------

-- The following are repros demonstrating the observations made in
-- Logical Trees Part 4
-- http://www.paulholmes.net/2020/08/logical-trees-part-4-filtering-with.html

-- Examples should work in all version of AdventureWorks from 2008R2 onwards.
USE AdventureWorks2019;





-- Simple equality comparison, comparing a column with a constant
SELECT p.Name
FROM Production.Product AS p
WHERE p.ProductID = 500
OPTION (RECOMPILE, QUERYTRACEON 8605, QUERYTRACEON 8606, QUERYTRACEON 8607, QUERYTRACEON 3604);
/* *** Converted Tree: ***
LogOp_Project QCOL: [p].Name
    LogOp_Select
        LogOp_Get TBL: Production.Product(alias TBL: p) Production.Product TableID=482100758 TableReferenceID=0 IsRow: COL: IsBaseRow1000 
        ScaOp_Comp x_cmpEq
            ScaOp_Identifier QCOL: [p].ProductID
            ScaOp_Const TI(int,ML=4) XVAR(int,Not Owned,Value=500)
    AncOp_PrjList

LogOp_Select has two childen:
A logical operator describing the input data
A scalar comparison operator (ScaOp_Comp), specifying an equality comparison (x_cmpEq)

ScaOp_Comp has two children, describing the two values to be compared
ScaOp_Identifier specifies a column, using the alias declared in the LogOp_Get
ScaOp_Const specifies a constant, with a data type and value.
*/




-- Simple comparison with boolean expression
SELECT p.Name
FROM Production.Product AS p
WHERE p.Color = 'Silver'
      AND p.ProductLine = 'M'
OPTION (RECOMPILE, QUERYTRACEON 8605, QUERYTRACEON 8606, QUERYTRACEON 8607, QUERYTRACEON 3604);
/* *** Converted Tree: ***
LogOp_Project QCOL: [p].Name
	LogOp_Select
        LogOp_Get TBL: Production.Product(alias TBL: p) Production.Product TableID=482100758 TableReferenceID=0 IsRow: COL: IsBaseRow1000 
        ScaOp_Logical x_lopAnd
            ScaOp_Comp x_cmpEq
                ScaOp_Identifier QCOL: [p].Color
                ScaOp_Const TI(nvarchar collate 872468488,Var,Trim,ML=12) XVAR(nvarchar,Owned,Value=Len,Data = (12,83105108118101114))
            ScaOp_Comp x_cmpEq
                ScaOp_Identifier QCOL: [p].ProductLine
                ScaOp_Const TI(nvarchar collate 872468488,Var,Trim,ML=2) XVAR(nvarchar,Owned,Value=Len,Data = (2,77))

    AncOp_PrjList 
LogOp_Select has two childen:
A logical operator describing the input data
A logical comparison operator (ScaOp_Logical), specifying an AND comparison (x_lopAnd)

ScaOp_Logical has two children, specifying the two comparisons eacg returning a boolean result, as input to the AND expression.
*/




-- Simple comparison with 3 part boolean expression
SELECT p.Name
FROM Production.Product AS p
WHERE p.Color = 'Silver'
      AND p.ProductLine = 'M'
	  AND p.FinishedGoodsFlag = 1
OPTION (RECOMPILE, QUERYTRACEON 8605, QUERYTRACEON 8606, QUERYTRACEON 8607, QUERYTRACEON 3604);
/* *** Converted Tree: *** (partial. operators omitted for clarity, indicated by :)
		:
		ScaOp_Logical x_lopAnd
			ScaOp_Comp x_cmpEq
			:
			ScaOp_Comp x_cmpEq
			:
			ScaOp_Comp x_cmpEq
		:
Note that unlike SQL syntaxt, the logical operator can take more than 2 inputs. 
*/




-- NOT expression rewritten using De Morgan's laws.
SELECT p.ProductID
FROM Production.Product AS p
WHERE NOT (
              p.Color = 'Silver'
              AND p.ProductLine = 'M'
          )
OPTION (RECOMPILE, QUERYTRACEON 8605, QUERYTRACEON 8606, QUERYTRACEON 8607, QUERYTRACEON 3604);
/* *** Converted Tree: *** (partial. operators omitted for clarity, indicated by :)
	:
	ScaOp_Logical x_lopOr
	    ScaOp_Comp x_cmpNe
	        ScaOp_Identifier QCOL: [p].Color
	        ScaOp_Const TI(nvarchar collate 872468488,Var,Trim,ML=12) XVAR(nvarchar,Owned,Value=Len,Data = (12,83105108118101114))
	    ScaOp_Comp x_cmpNe
	        ScaOp_Identifier QCOL: [p].ProductLine
	        ScaOp_Const TI(nvarchar collate 872468488,Var,Trim,ML=2) XVAR(nvarchar,Owned,Value=Len,Data = (2,77))
	:

Tree shows the expression with NOT eliminated, and the AND converted to OR
*/



-- *** IN Test against constants
SELECT p.Name
FROM Production.Product AS p
WHERE p.ProductID IN ( 500, 501 )
OPTION (RECOMPILE, QUERYTRACEON 8605, QUERYTRACEON 8606, QUERYTRACEON 8607, QUERYTRACEON 3604);

/* *** Converted Tree: ***
	:
	ScaOp_Logical x_lopOr
	    ScaOp_Comp x_cmpEq
	        ScaOp_Identifier QCOL: [p].ProductID
	        ScaOp_Const TI(int,ML=4) XVAR(int,Not Owned,Value=501)
	    ScaOp_Comp x_cmpEq
	        ScaOp_Identifier QCOL: [p].ProductID
	        ScaOp_Const TI(int,ML=4) XVAR(int,Not Owned,Value=500)w
	:

Described using OR and multiple equality comparisons
*/





-- Optimization: Contradiction (Explicit)
SELECT p.Name
FROM Production.Product AS p
WHERE 1=0
OPTION (RECOMPILE, QUERYTRACEON 8605, QUERYTRACEON 8606, QUERYTRACEON 8607, QUERYTRACEON 3604);

/* *** Converted Tree: ***
LogOp_Project QCOL: [p].Name
    LogOp_Select
        LogOp_Get TBL: Production.Product(alias TBL: p) Production.Product TableID=482100758 TableReferenceID=0 IsRow: COL: IsBaseRow1000 
        ScaOp_Const TI(bit,ML=1) XVAR(bit,Not Owned,Value=0)
    AncOp_PrjList 

Initially, a select operator has a filter defined with a zero constant, i.e. always false


*** Simplified Tree: ***

LogOp_ConstTableGet (0) COL: IsBaseRow1000  QCOL: [p].ProductID QCOL: [p].Name COL: ProductNumber  COL: rowguid 

In this tree, the 'always false' select has been replaced by LogOp_ConstTableGet.
This includes a rowcount (0), indicating no rows will be returned.
Instead it gives an indication that some table metadata will be needed  (e.g. column names, data types).
*/



-- Optimization: Contradiction (Check Constraint)
SELECT p.Name
FROM Production.Product AS p
WHERE p.ListPrice < 0
OPTION (RECOMPILE, QUERYTRACEON 8605, QUERYTRACEON 8606, QUERYTRACEON 8607, QUERYTRACEON 3604);

/* *** Converted Tree: ***
	:
	LogOp_Select
	    LogOp_Get TBL: Production.Product(alias TBL: p) Production.Product TableID=482100758 TableReferenceID=0 IsRow: COL: IsBaseRow1000 
	    ScaOp_Comp x_cmpLt
	        ScaOp_Identifier QCOL: [p].ListPrice
	        ScaOp_Const TI(money,ML=8) XVAR(money,Not Owned,Value=(10000units)=(0))
	:

The specified comparison is in the converted tree.


*** Simplified Tree: ***

LogOp_ConstTableGet (0) COL: IsBaseRow1000  QCOL: [p].ProductID QCOL: [p].Name COL: ProductNumber  COL: rowguid 

In this tree, the comparison that can never return true due to the check constraint, is replaced with LogOp_ConstTableGet (0)
*/



-- Optimization: Domain Simplification - Apparent Rule: SelPredNorm
SELECT p.ProductID
FROM Production.Product AS p
WHERE p.ProductID
      BETWEEN 1 AND 5
      AND p.ProductID
      BETWEEN 5 AND 10
OPTION (RECOMPILE, QUERYTRACEON 8605, QUERYTRACEON 8606, QUERYTRACEON 8607, QUERYTRACEON 3604);

/* *** Converted Tree: ***
	:
	ScaOp_Logical x_lopAnd
	    ScaOp_Comp x_cmpGe
	        ScaOp_Identifier QCOL: [p].ProductID
	        ScaOp_Const TI(int,ML=4) XVAR(int,Not Owned,Value=1)
	    ScaOp_Comp x_cmpLe
	        ScaOp_Identifier QCOL: [p].ProductID
	        ScaOp_Const TI(int,ML=4) XVAR(int,Not Owned,Value=5)
	    ScaOp_Comp x_cmpGe
	        ScaOp_Identifier QCOL: [p].ProductID
	        ScaOp_Const TI(int,ML=4) XVAR(int,Not Owned,Value=5)
	    ScaOp_Comp x_cmpLe
	        ScaOp_Identifier QCOL: [p].ProductID
	        ScaOp_Const TI(int,ML=4) XVAR(int,Not Owned,Value=10)
	:

Initialy the comparison is expressed in full.


*** Simplified Tree: ***
	:
	ScaOp_Comp x_cmpEq
	    ScaOp_Identifier QCOL: [p].ProductID
	    ScaOp_Const TI(int,ML=4) XVAR(int,Not Owned,Value=5)
	:

In the simplified tree, it is rationalised to ProductId = 5
*/


