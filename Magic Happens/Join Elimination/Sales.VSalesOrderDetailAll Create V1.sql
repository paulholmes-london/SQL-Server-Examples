USE [AdventureWorks2017]
GO

CREATE OR ALTER  VIEW Sales.vSalesOrderDetailAllV1

AS

-- All properties of SalesOrderDetail.
-- No elimination or duplication of SalesOrderDetail rows.

-- CTEs used to:
--   1. Allow multiple use of join construct
--   2. Nest inner joins, that can be consumed in an outer join.

WITH SalesTerritoryAll AS (
SELECT	TerritoryID					= st.TerritoryID,
		Name						= st.Name,
		CountryRegionCode			= st.CountryRegionCode,
		[Group]						= st.[Group],
		SalesYTD					= st.SalesYTD,
		SalesLastYear				= st.SalesLastYear,
		CostYTD						= st.CostYTD,
		CostLastYear				= st.CostLastYear,
		rowguid						= st.rowguid,
		ModifiedDate				= st.ModifiedDate,

		CountryRegionName			= stcr.Name,
		CountryRegionModifiedDate	= stcr.ModifiedDate

FROM Sales.SalesTerritory AS st
JOIN Person.CountryRegion AS stcr
	ON stcr.CountryRegionCode = st.CountryRegionCode
),

AddressAll AS (
SELECT	AddressId												= a.AddressId,
		AddressLine1											= a.AddressLine1,
		AddressLine2											= a.AddressLine2,
		City													= a.City,
		StateProvinceID											= a.StateProvinceID,
		PostalCode												= a.PostalCode,
		SpatialLocation											= a.SpatialLocation,
		rowguid													= a.rowguid,
		ModifiedDate											= a.ModifiedDate,
		StateProvinceStateProvinceCode							= asp.StateProvinceCode,
		StateProvinceCountryRegionCode							= asp.CountryRegionCode,
		StateProvinceIsOnlyStateProvinceFlag					= asp.IsOnlyStateProvinceFlag,
		StateProvinceName										= asp.Name,
		StateProvinceTerritoryId								= asp.TerritoryID,
		StateProvincerowguid									= asp.rowguid,
		StateProvinceModifiedDate								= asp.ModifiedDate,	
		StateProvinceCountryRegionName							= aspcr.Name,
		StateProvinceCountryRegionModifiedDate					= aspcr.ModifiedDate,
		StateProvinceSalesTerritoryName							= aspst.Name,
		StateProvinceSalesTerritoryCountryRegionCode			= aspst.CountryRegionCode,
		StateProvinceSalesTerritoryGroup						= aspst.[Group],
		StateProvinceSalesTerritorySalesYTD						= aspst.SalesYTD,
		StateProvinceSalesTerritorySalesLastYear				= aspst.SalesLastYear,
		StateProvinceSalesTerritoryCostYTD						= aspst.CostYTD,
		StateProvinceSalesTerritoryCostLastYear					= aspst.CostLastYear,
		StateProvinceSalesTerritoryrowguid						= aspst.rowguid,
		StateProvinceSalesTerritoryModifiedDate					= aspst.ModifiedDate,
		StateProvinceSalesTerritoryCountryRegionName			= aspst.CountryRegionName,
		StateProvinceSalesTerritoryCountryRegionModifiedDate	= aspst.CountryRegionModifiedDate

FROM Person.Address AS a
JOIN Person.StateProvince AS asp
	ON asp.StateProvinceID	= a.StateProvinceID
JOIN Person.CountryRegion AS aspcr
	ON aspcr.CountryRegionCode = asp.CountryRegionCode
JOIN SalesTerritoryAll AS aspst
	ON aspst.TerritoryID = asp.TerritoryID
),

PersonAll AS (
SELECT	BusinessEntityID					= p.BusinessEntityID,
		PersonType							= p.PersonType,
		NameStyle							= p.NameStyle,
		Title								= p.Title,
		FirstName							= p.FirstName,
		MiddleName							= p.MiddleName,
		LastName							= p.LastName,
		Suffix								= p.Suffix,
		EmailPromotion						= p.EmailPromotion,
		AdditionalContactInfo				= p.AdditionalContactInfo,
		Demographics						= p.Demographics,
		DemographicsTotalPurchaseYTD		= p.Demographics.value('declare default element namespace "http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/IndividualSurvey";(/IndividualSurvey/TotalPurchaseYTD)[1]', 'money'),
		DemographicsDateFirstPurchase		= CONVERT(datetime, REPLACE(p.Demographics.value('declare default element namespace "http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/IndividualSurvey";(/IndividualSurvey/DateFirstPurchase)[1]', 'nvarchar(20)'),'Z', ''), 101),
		DemographicsBirthDate				= CONVERT(datetime, REPLACE(p.Demographics.value('declare default element namespace "http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/IndividualSurvey";(/IndividualSurvey/BirthDate)[1]', 'nvarchar(20)'),'Z', ''), 101),
		DemographicsMaritalStatus			= p.Demographics.value('declare default element namespace "http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/IndividualSurvey";(/IndividualSurvey/MaritalStatus)[1]', 'nvarchar(1)'),
		DemographicsYearlyIncome			= p.Demographics.value('declare default element namespace "http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/IndividualSurvey";(/IndividualSurvey/YearlyIncome)[1]', 'nvarchar(30)'),
		DemographicsGender					= p.Demographics.value('declare default element namespace "http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/IndividualSurvey";(/IndividualSurvey/Gender)[1]', 'nvarchar(1)'),
		DemographicsTotalChildren			= p.Demographics.value('declare default element namespace "http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/IndividualSurvey";(/IndividualSurvey/TotalChildren)[1]', 'integer'),
		DemographicsNumberChildrenAtHome	= p.Demographics.value('declare default element namespace "http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/IndividualSurvey";(/IndividualSurvey/NumberChildrenAtHome)[1]', 'integer'),
		DemographicsEducation				= p.Demographics.value('declare default element namespace "http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/IndividualSurvey";(/IndividualSurvey/Education)[1]', 'nvarchar(30)'),
		DemographicsOccupation				= p.Demographics.value('declare default element namespace "http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/IndividualSurvey";(/IndividualSurvey/Occupation)[1]', 'nvarchar(30)'), -- TODO: Right Type? was 'c' in cross apply view.
		DemographicsHomeOwnerFlag			= p.Demographics.value('declare default element namespace "http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/IndividualSurvey";(/IndividualSurvey/HomeOwnerFlag)[1]', 'bit'),
		DemographicsNumberCarsOwned			= p.Demographics.value('declare default element namespace "http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/IndividualSurvey";(/IndividualSurvey/NumberCarsOwned)[1]', 'integer'),
		DemographicsHobby					= p.Demographics.value('declare default element namespace "http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/IndividualSurvey";(/IndividualSurvey/Hobby)[1]', 'nvarchar(30)'),
		DemographicsCommuteDistance			= p.Demographics.value('declare default element namespace "http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/IndividualSurvey";(/IndividualSurvey/CommuteDistance)[1]', 'nvarchar(30)'),
		DemographicsComments				= p.Demographics.value('declare default element namespace "http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/IndividualSurvey";(/IndividualSurvey/Comments)[1]', 'nvarchar(30)'),
		rowguid								= p.rowguid,
		ModifiedDate						= p.ModifiedDate,
		BusinessEntityrowguid				= pbe.rowguid,
		BusinessEntityModifiedDate			= pbe.ModifiedDate

FROM Person.Person AS p
JOIN Person.BusinessEntity AS pbe
	ON pbe.BusinessEntityID = p.BusinessEntityID
),

SalesPerson AS (
SELECT	BusinessEntityID								= sp.BusinessEntityID,
		TerritoryID										= sp.TerritoryID,
		SalesQuota										= sp.SalesQuota,
		Bonus											= sp.Bonus,
		CommissionPct									= sp.CommissionPct,
		SalesYTD										= sp.SalesYTD,
		SalesLastYear									= sp.SalesLastYear,
		rowguid											= sp.rowguid,
		ModifiedDate									= sp.ModifiedDate,

		EmployeeNationalIDNumber						= spe.NationalIDNumber,
		EmployeeLoginID									= spe.LoginID, 
		EmployeeOrganizationNode						= spe.OrganizationNode,
		EmployeeOrganizationLevel						= spe.OrganizationLevel,
		EmployeeJobTitle								= spe.JobTitle,
		EmployeeBirthDate								= spe.BirthDate,
		EmployeeMaritalStatus							= spe.MaritalStatus,
		EmployeeGender									= spe.Gender,
		EmployeeHireDate								= spe.HireDate,
		EmployeeSalariedFlag							= spe.SalariedFlag,
		EmployeeVacationHours							= spe.VacationHours,
		EmployeeSickLeaveHours							= spe.SickLeaveHours,
		EmployeeCurrentFlag								= spe.CurrentFlag, 
		Employeerowguid									= spe.rowguid, 
		EmployeeModifiedDate							= spe.ModifiedDate,

		EmployeePersonPersonType						= spep.PersonType,
		EmployeePersonNameStyle							= spep.NameStyle,
		EmployeePersonTitle								= spep.Title,
		EmployeePersonFirstName							= spep.FirstName,
		EmployeePersonMiddleName						= spep.MiddleName,
		EmployeePersonLastName							= spep.LastName,
		EmployeePersonSuffix							= spep.Suffix,
		EmployeePersonEmailPromotion					= spep.EmailPromotion,
		EmployeePersonAdditionalContactInfo				= spep.AdditionalContactInfo,
		EmployeePersonDemographics						= spep.Demographics,
		EmployeePersonDemographicsTotalPurchaseYTD		= spep.DemographicsTotalPurchaseYTD,
		EmployeePersonDemographicsDateFirstPurchase		= spep.DemographicsDateFirstPurchase,	
		EmployeePersonDemographicsBirthDate				= spep.DemographicsBirthDate,			
		EmployeePersonDemographicsMaritalStatus			= spep.DemographicsMaritalStatus,		
		EmployeePersonDemographicsYearlyIncome			= spep.DemographicsYearlyIncome,		
		EmployeePersonDemographicsGender				= spep.DemographicsGender,				
		EmployeePersonDemographicsTotalChildren			= spep.DemographicsTotalChildren,		
		EmployeePersonDemographicsNumberChildrenAtHome	= spep.DemographicsNumberChildrenAtHome,
		EmployeePersonDemographicsEducation				= spep.DemographicsEducation,			
		EmployeePersonDemographicsOccupation			= spep.DemographicsOccupation,			
		EmployeePersonDemographicsHomeOwnerFlag			= spep.DemographicsHomeOwnerFlag,		
		EmployeePersonDemographicsNumberCarsOwned		= spep.DemographicsNumberCarsOwned,		
		EmployeePersonDemographicsHobby					= spep.DemographicsHobby,				
		EmployeePersonDemographicsCommuteDistance		= spep.DemographicsCommuteDistance,		
		EmployeePersonDemographicsComments				= spep.DemographicsComments,			
		EmployeePersonrowguid							= spep.rowguid,
		EmployeePersonModifiedDate						= spep.ModifiedDate,
		EmployeePersonBusinessEntityrowguid				= spep.BusinessEntityrowguid,
		EmployeePersonBusinessEntityModifiedDate		= spep.BusinessEntityModifiedDate,

		SalesTerritoryName								= spst.Name,
		SalesTerritoryCountryCode						= spst.CountryRegionCode,
		SalesTerritoryGroup								= spst.[Group],
		SalesTerritorySalesYTD							= spst.SalesYTD,
		SalesTerritorySalesLastYear						= spst.SalesLastYear,
		SalesTerritoryCostYTD							= spst.CostYTD,
		SalesTerritoryCostLastYear						= spst.CostLastYear,
		SalesTerritoryrowguid							= spst.rowguid,
		SalesTerritoryModifiedDate						= spst.ModifiedDate,
		SalesTerritoryCountryRegionName					= spst.CountryRegionName,
		SalesTerritoryCountryRegionModifiedDate			= spst.CountryRegionModifiedDate

FROM Sales.SalesPerson AS sp
JOIN HumanResources.Employee AS spe
	ON spe.BusinessEntityID = sp.BusinessEntityID
JOIN PersonAll AS spep
	ON spep.BusinessEntityID = spe.BusinessEntityID
JOIN SalesTerritoryAll AS spst
	ON spst.TerritoryID = sp.TerritoryID
),

ProductSubcategoryAll AS
(SELECT ProductSubcategoryID						= ps.ProductSubcategoryID,
	   ProductSubCategoryName						= ps.Name,
	   ProductSubCategoryrowguid					= ps.rowguid,
	   ProductSubCategoryModifiedDate				= ps.ModifiedDate,

	   ProductCategoryID							= pc.ProductCategoryID,
	   ProductCategoryName							= pc.Name,
	   ProductCategoryrowguid						= pc.rowguid,
	   ProductCategoryModifiedDate					= pc.ModifiedDate

FROM Production.ProductSubcategory AS ps
JOIN Production.ProductCategory AS pc
	ON pc.ProductCategoryID = ps.ProductCategoryID
),

SpecialOfferProductAll AS
(SELECT	SpecialOfferID							= sop.SpecialOfferID,
		ProductID								= sop.ProductID,
		rowguid									= sop.rowguid,
		ModifiedDate							= sop.ModifiedDate,

		SpecialOfferDescription					= so.Description,	
		SpecialOfferDiscountPct					= so.DiscountPct,	
		SpecialOfferType						= so.Type,
		SpecialOfferCategory					= so.Category,
		SpecialOfferStartDate					= so.StartDate,
		SpecialOfferEndDate						= so.EndDate,	
		SpecialOfferMinQty						= so.MinQty,
		SpecialOfferMaxQty						= so.MaxQty,
		SpecialOfferrowguid						= so.rowguid,	
		SpecialOfferModifiedDate				= so.ModifiedDate,		

		ProductName								= p.Name,
		ProductProductNumber					= p.ProductNumber,
		ProductMakeFlag							= p.MakeFlag,
		ProductFinishedGoodsFlag				= p.FinishedGoodsFlag,
		ProductColor							= p.Color,
		ProductSafetyStockLevel					= p.SafetyStockLevel,
		ProductReorderPoint						= p.ReorderPoint,
		ProductStandardCost						= p.StandardCost,
		ProductListPrice						= p.ListPrice,

		ProductSize								= p.Size,
		ProductSizeUnitMeasureCode				= p.SizeUnitMeasureCode,
		ProductSizeUnitMeasureName				= umsize.Name,
		ProductSizeUnitMeasureModifiedDate		= umsize.ModifiedDate,

		ProductWeight							= p.Weight,
		ProductWeightUnitMeasureCode			= p.WeightUnitMeasureCode,
		ProductWeightUnitMeasureName			= umweight.Name,
		ProductWeightUnitMeasureModifiedDate	= umweight.ModifiedDate,

		ProductDaysToManufacture				= p.DaysToManufacture,
		ProductProductLine						= p.ProductLine,
		ProductClass							= p.Class,
		ProductStyle							= p.Style,
		ProductProductSubcategoryID				= p.ProductSubcategoryID,
		ProductProductModelID					= p.ProductModelID,
		ProductSellStartDate					= p.SellStartDate,
		ProductSellEndDate						= p.SellEndDate,
		ProductDiscontinuedDate					= p.DiscontinuedDate,
		Productrowguid							= p.rowguid,
		ProductModifiedDate						= p.ModifiedDate,

		ProductModelId							= p.ProductModelID,
		ProductModelName						= pm.Name,
		ProductModelCatalogDescription			= pm.CatalogDescription,
		ProductModelInstructions				= pm.Instructions,
		ProductModelrowguid						= pm.rowguid,	
		ProductModelModifiedDate				= pm.ModifiedDate,

		ProductSubcategoryID					= p.ProductSubcategoryID,
		ProductSubCategoryName					= ps.ProductSubCategoryName,
		ProductSubCategoryrowguid				= ps.ProductSubCategoryrowguid,
		ProductSubCategoryModifiedDate			= ps.ProductSubCategoryModifiedDate,
		ProductCategoryID						= ps.ProductCategoryID,
		ProductCategoryName						= ps.ProductCategoryName,
		ProductCategoryrowguid					= ps.ProductCategoryrowguid,
		ProductCategoryModifiedDate				= ps.ProductCategoryModifiedDate

FROM Sales.SpecialOfferProduct AS sop
JOIN Sales.SpecialOffer AS so
	ON so.SpecialOfferID = sop.SpecialOfferID
JOIN Production.Product AS p
	ON p.ProductId = sop.ProductID
	LEFT JOIN ProductSubcategoryAll AS ps
		ON ps.ProductSubcategoryID = p.ProductSubcategoryID
	LEFT JOIN Production.ProductModel AS pm
		ON pm.ProductModelID = p.ProductModelID
LEFT JOIN Production.UnitMeasure AS umsize
	ON umsize.UnitMeasureCode = p.SizeUnitMeasureCode
LEFT JOIN Production.UnitMeasure AS umweight
	ON umweight.UnitMeasureCode = p.WeightUnitMeasureCode
)

SELECT 	SalesOrderID														= sod.SalesOrderID,
		SalesOrderDetailID													= sod.SalesOrderDetailID,
		CarrierTrackingNumber												= sod.CarrierTrackingNumber,
		OrderQty															= sod.OrderQty,
		ProductID															= sod.ProductID,
		SpecialOfferID														= sod.SpecialOfferID,
		UnitPrice															= sod.UnitPrice,
		UnitPriceDiscount													= sod.UnitPriceDiscount,
		LineTotal															= sod.LineTotal,
		rowguid																= sod.rowguid,
		ModifiedDate														= sod.ModifiedDate,

		SpecialOfferProductrowguid											= sop.rowguid,						
		SpecialOfferProductModifiedDate										= sop.ModifiedDate,					
		SpecialOfferProductSpecialOfferDescription							= sop.SpecialOfferDescription,			
		SpecialOfferProductSpecialOfferDiscountPct							= sop.SpecialOfferDiscountPct,			
		SpecialOfferProductSpecialOfferType									= sop.SpecialOfferType,				
		SpecialOfferProductSpecialOfferCategory								= sop.SpecialOfferCategory,			
		SpecialOfferProductSpecialOfferStartDate							= sop.SpecialOfferStartDate,			
		SpecialOfferProductSpecialOfferEndDate								= sop.SpecialOfferEndDate,				
		SpecialOfferProductSpecialOfferMinQty								= sop.SpecialOfferMinQty,				
		SpecialOfferProductSpecialOfferMaxQty								= sop.SpecialOfferMaxQty,				
		SpecialOfferProductSpecialOfferrowguid								= sop.SpecialOfferrowguid,				
		SpecialOfferProductSpecialOfferModifiedDate							= sop.SpecialOfferModifiedDate,		

		SpecialOfferProductProductName										= sop.ProductName,					
		SpecialOfferProductProductProductNumber								= sop.ProductProductNumber,			
		SpecialOfferProductProductMakeFlag									= sop.ProductMakeFlag,					
		SpecialOfferProductProductFinishedGoodsFlag							= sop.ProductFinishedGoodsFlag,		
		SpecialOfferProductProductColor										= sop.ProductColor,					
		SpecialOfferProductProductSafetyStockLevel							= sop.ProductSafetyStockLevel,			
		SpecialOfferProductProductReorderPoint								= sop.ProductReorderPoint,				
		SpecialOfferProductProductStandardCost								= sop.ProductStandardCost,				
		SpecialOfferProductProductListPrice									= sop.ProductListPrice,				

		SpecialOfferProductProductSize										= sop.ProductSize,						
		SpecialOfferProductProductSizeUnitMeasureCode						= sop.ProductSizeUnitMeasureCode,		
		SpecialOfferProductProductSizeUnitMeasureName						= sop.ProductSizeUnitMeasureName,		
		SpecialOfferProductProductSizeUnitMeasureModifiedDate				= sop.ProductSizeUnitMeasureModifiedDate,		

		SpecialOfferProductProductWeight									= sop.ProductWeight,					
		SpecialOfferProductProductWeightUnitMeasureCode						= sop.ProductWeightUnitMeasureCode,	
		SpecialOfferProductProductWeightUnitMeasureName						= sop.ProductWeightUnitMeasureName,		
		SpecialOfferProductProductWeightUnitMeasureModifiedDate				= sop.ProductWeightUnitMeasureModifiedDate,		

		SpecialOfferProductProductDaysToManufacture							= sop.ProductDaysToManufacture,		
		SpecialOfferProductProductProductLine								= sop.ProductProductLine,				
		SpecialOfferProductProductClass										= sop.ProductClass,					
		SpecialOfferProductProductStyle										= sop.ProductStyle,					
		SpecialOfferProductProductProductModelID							= sop.ProductProductModelID,			
		SpecialOfferProductProductSellStartDate								= sop.ProductSellStartDate,			
		SpecialOfferProductProductSellEndDate								= sop.ProductSellEndDate,				
		SpecialOfferProductProductDiscontinuedDate							= sop.ProductDiscontinuedDate,			
		SpecialOfferProductProductrowguid									= sop.Productrowguid,					
		SpecialOfferProductProductModifiedDate								= sop.ProductModifiedDate,				
			
		SpecialOfferProductProductModelId									= sop.ProductModelId,
		SpecialOfferProductProductModelName									= sop.ProductModelName,				
		SpecialOfferProductProductModelCatalogDescription					= sop.ProductModelCatalogDescription,	
		SpecialOfferProductProductModelInstructions							= sop.ProductModelInstructions,		
		SpecialOfferProductProductModelrowguid								= sop.ProductModelrowguid,				
		SpecialOfferProductProductModelModifiedDate							= sop.ProductModelModifiedDate,		

		SpecialOfferProductProductSubcategoryID								= sop.ProductProductSubcategoryID,		
		SpecialOfferProductProductSubCategoryName							= sop.ProductSubCategoryName,			
		SpecialOfferProductProductSubCategoryrowguid						= sop.ProductSubCategoryrowguid,		
		SpecialOfferProductProductSubCategoryModifiedDate					= sop.ProductSubCategoryModifiedDate,	
		SpecialOfferProductProductCategoryID								= sop.ProductCategoryID,			
		SpecialOfferProductProductCategoryName								= sop.ProductCategoryName,				
		SpecialOfferProductProductCategoryrowguid							= sop.ProductCategoryrowguid,			
		SpecialOfferProductProductCategoryModifiedDate						= sop.ProductCategoryModifiedDate,		

		OrderRevisionNumber													= soh.RevisionNumber,
		OrderOrderDate														= soh.OrderDate,
		OrderDueDate														= soh.DueDate,
		OrderShipDate														= soh.ShipDate,
		OrderStatus															= soh.Status,
		OrderOnlineOrderFlag												= soh.OnlineOrderFlag,
		OrderSalesOrderNumber												= soh.SalesOrderNumber,
		OrderPurchaseOrderNumber											= soh.PurchaseOrderNumber,
		OrderAccountNumber													= soh.AccountNumber,
		OrderCustomerID														= soh.CustomerID,
		OrderSalesPersonID													= soh.SalesPersonID,
		OrderTerritoryID													= soh.TerritoryID,
		OrderBillToAddressID												= soh.BillToAddressID,
		OrderShipToAddressID												= soh.ShipToAddressID,
		OrderShipMethodID													= soh.ShipMethodID,
		OrderCreditCardID													= soh.CreditCardID,
		OrderCreditCardApprovalCode											= soh.CreditCardApprovalCode,
		OrderCurrencyRateID													= soh.CurrencyRateID,
		OrderSubTotal														= soh.SubTotal,
		OrderTaxAmt															= soh.TaxAmt,
		OrderFreight														= soh.Freight,
		OrderTotalDue														= soh.TotalDue,
		OrderComment														= soh.Comment,
		Orderrowguid														= soh.rowguid,
		OrderModifiedDate													= soh.ModifiedDate,

		CustomerPersonID													= c.PersonID,
		CustomerStoreID														= c.StoreID,
		CustomerTerritoryID													= c.TerritoryID,
		CustomerAccountNumber												= c.AccountNumber,
		Customerrowguid														= c.rowguid,
		CustomerModifiedDate												= c.ModifiedDate,

		CustomerStoreName													= cs.Name,
		CustomerStoreSalesPersonID											= cs.SalesPersonID,
		CustomerStoreDemographics											= cs.Demographics,

		-- Do own shredding; the supplied view Sales.vStoreWithDemographics does not cover all table columns and xml nodes defined in the xsd
		CustomerStoreDemographicsContactName									= cs.Demographics.value('declare default element namespace "http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/StoreSurvey";(/StoreSurvey/ContactName)[1]', 'money'),
		CustomerStoreDemographicsJobTitle										= cs.Demographics.value('declare default element namespace "http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/StoreSurvey";(/StoreSurvey/JobTitle)[1]', 'money'),
		CustomerStoreDemographicsAnnualSales									= cs.Demographics.value('declare default element namespace "http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/StoreSurvey";(/StoreSurvey/AnnualSales)[1]', 'money'),
		CustomerStoreDemographicsAnnualRevenue									= cs.Demographics.value('declare default element namespace "http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/StoreSurvey";(/StoreSurvey/AnnualRevenue)[1]', 'money'),		  
		CustomerStoreDemographicsBankName										= cs.Demographics.value('declare default element namespace "http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/StoreSurvey";(/StoreSurvey/BankName)[1]', 'nvarchar(50)'),			  
		CustomerStoreDemographicsBusinessType									= cs.Demographics.value('declare default element namespace "http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/StoreSurvey";(/StoreSurvey/BusinessType)[1]', 'nvarchar(5)'), 	  
		CustomerStoreDemographicsYearOpened										= cs.Demographics.value('declare default element namespace "http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/StoreSurvey";(/StoreSurvey/YearOpened)[1]', 'integer'),			  
		CustomerStoreDemographicsSpecialty										= cs.Demographics.value('declare default element namespace "http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/StoreSurvey";(/StoreSurvey/Specialty)[1]', 'nvarchar(50)'),	  
		CustomerStoreDemographicsSquareFeet										= cs.Demographics.value('declare default element namespace "http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/StoreSurvey";(/StoreSurvey/SquareFeet)[1]', 'integer'),			  
		CustomerStoreDemographicsBrands											= cs.Demographics.value('declare default element namespace "http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/StoreSurvey";(/StoreSurvey/Brands)[1]', 'nvarchar(30)'),		  
		CustomerStoreDemographicsInternet										= cs.Demographics.value('declare default element namespace "http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/StoreSurvey";(/StoreSurvey/Internet)[1]', 'nvarchar(30)'), 			  
		CustomerStoreDemographicsNumberEmployees								= cs.Demographics.value('declare default element namespace "http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/StoreSurvey";(/StoreSurvey/NumberEmployees)[1]', 'integer'), 
		CustomerStoreDemographicsComments										= cs.Demographics.value('declare default element namespace "http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/StoreSurvey";(/StoreSurvey/Comments)[1]', 'integer'), 

		CustomerStorerowguid													= cs.rowguid,
		CustomerStoreModifiedDate												= cs.ModifiedDate,

		CustomerStoreSalesPersonBusinessEntityID								= cssp.BusinessEntityID,						
		CustomerStoreSalesPersonTerritoryID										= cssp.TerritoryID,									
		CustomerStoreSalesPersonSalesQuota										= cssp.SalesQuota,									
		CustomerStoreSalesPersonBonus											= cssp.Bonus,										
		CustomerStoreSalesPersonCommissionPct									= cssp.CommissionPct,								
		CustomerStoreSalesPersonSalesYTD										= cssp.SalesYTD,									
		CustomerStoreSalesPersonSalesLastYear									= cssp.SalesLastYear,								
		CustomerStoreSalesPersonrowguid											= cssp.rowguid,										
		CustomerStoreSalesPersonModifiedDate									= cssp.ModifiedDate,								

		CustomerStoreSalesPersonEmployeeNationalIDNumber						= cssp.EmployeeNationalIDNumber,					
		CustomerStoreSalesPersonEmployeeLoginID									= cssp.EmployeeLoginID,								
		CustomerStoreSalesPersonEmployeeOrganizationNode						= cssp.EmployeeOrganizationNode,					
		CustomerStoreSalesPersonEmployeeOrganizationLevel						= cssp.EmployeeOrganizationLevel,					
		CustomerStoreSalesPersonEmployeeJobTitle								= cssp.EmployeeJobTitle,							
		CustomerStoreSalesPersonEmployeeBirthDate								= cssp.EmployeeBirthDate,							
		CustomerStoreSalesPersonEmployeeMaritalStatus							= cssp.EmployeeMaritalStatus,						
		CustomerStoreSalesPersonEmployeeGender									= cssp.EmployeeGender,								
		CustomerStoreSalesPersonEmployeeHireDate								= cssp.EmployeeHireDate,							
		CustomerStoreSalesPersonEmployeeSalariedFlag							= cssp.EmployeeSalariedFlag,						
		CustomerStoreSalesPersonEmployeeVacationHours							= cssp.EmployeeVacationHours,						
		CustomerStoreSalesPersonEmployeeSickLeaveHours							= cssp.EmployeeSickLeaveHours,						
		CustomerStoreSalesPersonEmployeeCurrentFlag								= cssp.EmployeeCurrentFlag,							
		CustomerStoreSalesPersonEmployeerowguid									= cssp.Employeerowguid,								
		CustomerStoreSalesPersonEmployeeModifiedDate							= cssp.EmployeeModifiedDate,						

		CustomerStoreSalesPersonEmployeePersonPersonType						= cssp.EmployeePersonPersonType,					
		CustomerStoreSalesPersonEmployeePersonNameStyle							= cssp.EmployeePersonNameStyle,						
		CustomerStoreSalesPersonEmployeePersonTitle								= cssp.EmployeePersonTitle,							
		CustomerStoreSalesPersonEmployeePersonFirstName							= cssp.EmployeePersonFirstName,						
		CustomerStoreSalesPersonEmployeePersonMiddleName						= cssp.EmployeePersonMiddleName,					
		CustomerStoreSalesPersonEmployeePersonLastName							= cssp.EmployeePersonLastName,						
		CustomerStoreSalesPersonEmployeePersonSuffix							= cssp.EmployeePersonSuffix,					
		CustomerStoreSalesPersonEmployeePersonEmailPromotion					= cssp.EmployeePersonEmailPromotion,				
		CustomerStoreSalesPersonEmployeePersonAdditionalContactInfo				= cssp.EmployeePersonAdditionalContactInfo,			

		CustomerStoreSalesPersonEmployeePersonDemographics						= cssp.EmployeePersonDemographics,
		CustomerStoreSalesPersonEmployeePersonDemographicsTotalPurchaseYTD		= cssp.EmployeePersonDemographicsTotalPurchaseYTD,
		CustomerStoreSalesPersonEmployeePersonDemographicsDateFirstPurchase		= cssp.EmployeePersonDemographicsDateFirstPurchase,	
		CustomerStoreSalesPersonEmployeePersonDemographicsBirthDate				= cssp.EmployeePersonDemographicsBirthDate,			
		CustomerStoreSalesPersonEmployeePersonDemographicsMaritalStatus			= cssp.EmployeePersonDemographicsMaritalStatus,		
		CustomerStoreSalesPersonEmployeePersonDemographicsYearlyIncome			= cssp.EmployeePersonDemographicsYearlyIncome,		
		CustomerStoreSalesPersonEmployeePersonDemographicsGender				= cssp.EmployeePersonDemographicsGender,				
		CustomerStoreSalesPersonEmployeePersonDemographicsTotalChildren			= cssp.EmployeePersonDemographicsTotalChildren,		
		CustomerStoreSalesPersonEmployeePersonDemographicsNumberChildrenAtHome	= cssp.EmployeePersonDemographicsNumberChildrenAtHome,
		CustomerStoreSalesPersonEmployeePersonDemographicsEducation				= cssp.EmployeePersonDemographicsEducation,			
		CustomerStoreSalesPersonEmployeePersonDemographicsOccupation			= cssp.EmployeePersonDemographicsOccupation,			
		CustomerStoreSalesPersonEmployeePersonDemographicsHomeOwnerFlag			= cssp.EmployeePersonDemographicsHomeOwnerFlag,		
		CustomerStoreSalesPersonEmployeePersonDemographicsNumberCarsOwned		= cssp.EmployeePersonDemographicsNumberCarsOwned,		
		CustomerStoreSalesPersonEmployeePersonDemographicsHobby					= cssp.EmployeePersonDemographicsHobby,				
		CustomerStoreSalesPersonEmployeePersonDemographicsCommuteDistance		= cssp.EmployeePersonDemographicsCommuteDistance,		
		CustomerStoreSalesPersonEmployeePersonDemographicsComments				= cssp.EmployeePersonDemographicsComments,			

		CustomerStoreSalesPersonEmployeePersonrowguid							= cssp.EmployeePersonrowguid,						
		CustomerStoreSalesPersonEmployeePersonModifiedDate						= cssp.EmployeePersonModifiedDate,					
		CustomerStoreSalesPersonEmployeePersonBusinessEntityrowguid				= cssp.EmployeePersonBusinessEntityrowguid,			
		CustomerStoreSalesPersonEmployeePersonBusinessEntityModifiedDate		= cssp.EmployeePersonBusinessEntityModifiedDate,	

		CustomerSalesTerritoryName												= cst.Name,							
		CustomerSalesTerritoryCountryRegionCode									= cst.CountryRegionCode,					
		CustomerSalesTerritoryGroup												= cst.[Group],							
		CustomerSalesTerritorySalesYTD											= cst.SalesYTD,						
		CustomerSalesTerritorySalesLastYear										= cst.SalesLastYear,					
		CustomerSalesTerritoryCostYTD											= cst.CostYTD,						
		CustomerSalesTerritoryCostLastYear										= cst.CostLastYear,					
		CustomerSalesTerritoryrowguid											= cst.rowguid,						
		CustomerSalesTerritoryModifiedDate										= cst.ModifiedDate,					
		CustomerSalesTerritoryCountryRegionName									= cst.CountryRegionName,				
		CustomerSalesTerritoryCountryRegionModifiedDate							= cst.CountryRegionModifiedDate,		

		CustomerPersonPersonType												= cp.PersonType,					
		CustomerPersonNameStyle													= cp.NameStyle,					
		CustomerPersonTitle														= cp.Title,						
		CustomerPersonFirstName													= cp.FirstName,					
		CustomerPersonMiddleName												= cp.MiddleName,					
		CustomerPersonLastName													= cp.LastName,					
		CustomerPersonSuffix													= cp.Suffix,						
		CustomerPersonEmailPromotion											= cp.EmailPromotion,				
		CustomerPersonAdditionalContactInfo										= cp.AdditionalContactInfo,		
		CustomerPersonDemographics												= cp.Demographics,				
		CustomerPersonDemographicsTotalPurchaseYTD								= cp.DemographicsTotalPurchaseYTD,
		CustomerPersonDemographicsDateFirstPurchase								= cp.DemographicsDateFirstPurchase,	
		CustomerPersonDemographicsBirthDate										= cp.DemographicsBirthDate,			
		CustomerPersonDemographicsMaritalStatus									= cp.DemographicsMaritalStatus,		
		CustomerPersonDemographicsYearlyIncome									= cp.DemographicsYearlyIncome,		
		CustomerPersonDemographicsGender										= cp.DemographicsGender,				
		CustomerPersonDemographicsTotalChildren									= cp.DemographicsTotalChildren,		
		CustomerPersonDemographicsNumberChildrenAtHome							= cp.DemographicsNumberChildrenAtHome,
		CustomerPersonDemographicsEducation										= cp.DemographicsEducation,			
		CustomerPersonDemographicsOccupation									= cp.DemographicsOccupation,			
		CustomerPersonDemographicsHomeOwnerFlag									= cp.DemographicsHomeOwnerFlag,		
		CustomerPersonDemographicsNumberCarsOwned								= cp.DemographicsNumberCarsOwned,		
		CustomerPersonDemographicsHobby											= cp.DemographicsHobby,				
		CustomerPersonDemographicsCommuteDistance								= cp.DemographicsCommuteDistance,		
		CustomerPersonDemographicsComments										= cp.DemographicsComments,			
		CustomerPersonrowguid													= cp.rowguid,						
		CustomerPersonModifiedDate												= cp.ModifiedDate,				
		CustomerPersonBusinessEntityrowguid										= cp.BusinessEntityrowguid,		
		CustomerPersonBusinessEntityModifiedDate								= cp.BusinessEntityModifiedDate,

		OrderSalesPersonTerritoryID												= sohsp.TerritoryID,								
		OrderSalesPersonSalesQuota												= sohsp.SalesQuota,								
		OrderSalesPersonBonus													= sohsp.Bonus,									
		OrderSalesPersonCommissionPct											= sohsp.CommissionPct,							
		OrderSalesPersonSalesYTD												= sohsp.SalesYTD,								
		OrderSalesPersonSalesLastYear											= sohsp.SalesLastYear,							
		OrderSalesPersonrowguid													= sohsp.rowguid,									
		OrderSalesPersonModifiedDate											= sohsp.ModifiedDate,							
		OrderSalesPersonEmployeeNationalIDNumber								= sohsp.EmployeeNationalIDNumber,				
		OrderSalesPersonEmployeeLoginID											= sohsp.EmployeeLoginID,						
		OrderSalesPersonEmployeeOrganizationNode								= sohsp.EmployeeOrganizationNode,				
		OrderSalesPersonEmployeeOrganizationLevel								= sohsp.EmployeeOrganizationLevel,				
		OrderSalesPersonEmployeeJobTitle										= sohsp.EmployeeJobTitle,						
		OrderSalesPersonEmployeeBirthDate										= sohsp.EmployeeBirthDate,						
		OrderSalesPersonEmployeeMaritalStatus									= sohsp.EmployeeMaritalStatus,					
		OrderSalesPersonEmployeeGender											= sohsp.EmployeeGender,							
		OrderSalesPersonEmployeeHireDate										= sohsp.EmployeeHireDate,						
		OrderSalesPersonEmployeeSalariedFlag									= sohsp.EmployeeSalariedFlag,					
		OrderSalesPersonEmployeeVacationHours									= sohsp.EmployeeVacationHours,					
		OrderSalesPersonEmployeeSickLeaveHours									= sohsp.EmployeeSickLeaveHours,					
		OrderSalesPersonEmployeeCurrentFlag										= sohsp.EmployeeCurrentFlag,						
		OrderSalesPersonEmployeerowguid											= sohsp.Employeerowguid,							
		OrderSalesPersonEmployeeModifiedDate									= sohsp.EmployeeModifiedDate,					
		OrderSalesPersonEmployeePersonPersonType								= sohsp.EmployeePersonPersonType,				
		OrderSalesPersonEmployeePersonNameStyle									= sohsp.EmployeePersonNameStyle,					
		OrderSalesPersonEmployeePersonTitle										= sohsp.EmployeePersonTitle,						
		OrderSalesPersonEmployeePersonFirstName									= sohsp.EmployeePersonFirstName,					
		OrderSalesPersonEmployeePersonMiddleName								= sohsp.EmployeePersonMiddleName,				
		OrderSalesPersonEmployeePersonLastName									= sohsp.EmployeePersonLastName,					
		OrderSalesPersonEmployeePersonSuffix									= sohsp.EmployeePersonSuffix,					
		OrderSalesPersonEmployeePersonEmailPromotion							= sohsp.EmployeePersonEmailPromotion,			
		OrderSalesPersonEmployeePersonAdditionalContactInfo						= sohsp.EmployeePersonAdditionalContactInfo,		

		OrderSalesPersonEmployeePersonDemographics								= sohsp.EmployeePersonDemographics,
		OrderSalesPersonEmployeePersonDemographicsTotalPurchaseYTD				= sohsp.EmployeePersonDemographicsTotalPurchaseYTD,
		OrderSalesPersonEmployeePersonDemographicsDateFirstPurchase				= sohsp.EmployeePersonDemographicsDateFirstPurchase,	
		OrderSalesPersonEmployeePersonDemographicsBirthDate						= sohsp.EmployeePersonDemographicsBirthDate,			
		OrderSalesPersonEmployeePersonDemographicsMaritalStatus					= sohsp.EmployeePersonDemographicsMaritalStatus,		
		OrderSalesPersonEmployeePersonDemographicsYearlyIncome					= sohsp.EmployeePersonDemographicsYearlyIncome,		
		OrderSalesPersonEmployeePersonDemographicsGender						= sohsp.EmployeePersonDemographicsGender,				
		OrderSalesPersonEmployeePersonDemographicsTotalChildren					= sohsp.EmployeePersonDemographicsTotalChildren,		
		OrderSalesPersonEmployeePersonDemographicsNumberChildrenAtHome			= sohsp.EmployeePersonDemographicsNumberChildrenAtHome,
		OrderSalesPersonEmployeePersonDemographicsEducation						= sohsp.EmployeePersonDemographicsEducation,			
		OrderSalesPersonEmployeePersonDemographicsOccupation					= sohsp.EmployeePersonDemographicsOccupation,			
		OrderSalesPersonEmployeePersonDemographicsHomeOwnerFlag					= sohsp.EmployeePersonDemographicsHomeOwnerFlag,		
		OrderSalesPersonEmployeePersonDemographicsNumberCarsOwned				= sohsp.EmployeePersonDemographicsNumberCarsOwned,		
		OrderSalesPersonEmployeePersonDemographicsHobby							= sohsp.EmployeePersonDemographicsHobby,				
		OrderSalesPersonEmployeePersonDemographicsCommuteDistance				= sohsp.EmployeePersonDemographicsCommuteDistance,		
		OrderSalesPersonEmployeePersonDemographicsComments						= sohsp.EmployeePersonDemographicsComments,			

		OrderSalesPersonEmployeePersonrowguid									= sohsp.EmployeePersonrowguid,					
		OrderSalesPersonEmployeePersonModifiedDate								= sohsp.EmployeePersonModifiedDate,				
		OrderSalesPersonEmployeePersonBusinessEntityrowguid						= sohsp.EmployeePersonBusinessEntityrowguid,		
		OrderSalesPersonEmployeePersonBusinessEntityModifiedDate				= sohsp.EmployeePersonBusinessEntityModifiedDate,
		OrderSalesPersonSalesTerritoryName										= sohsp.SalesTerritoryName,						
		OrderSalesPersonSalesTerritoryCountryCode								= sohsp.SalesTerritoryCountryCode,				
		OrderSalesPersonSalesTerritoryGroup										= sohsp.SalesTerritoryGroup,						
		OrderSalesPersonSalesTerritorySalesYTD									= sohsp.SalesTerritorySalesYTD,					
		OrderSalesPersonSalesTerritorySalesLastYear								= sohsp.SalesTerritorySalesLastYear,				
		OrderSalesPersonSalesTerritoryCostYTD									= sohsp.SalesTerritoryCostYTD,					
		OrderSalesPersonSalesTerritoryCostLastYear								= sohsp.SalesTerritoryCostLastYear,				
		OrderSalesPersonSalesTerritoryrowguid									= sohsp.SalesTerritoryrowguid,					
		OrderSalesPersonSalesTerritoryModifiedDate								= sohsp.SalesTerritoryModifiedDate,				
		OrderSalesPersonSalesTerritoryCountryRegionName							= sohsp.SalesTerritoryCountryRegionName,		
		OrderSalesPersonSalesTerritoryCountryRegionModifiedDate					= sohsp.SalesTerritoryCountryRegionModifiedDate,	

		OrderSalesTerritoryName													= sohst.Name,						
		OrderSalesTerritoryCountryRegionCode									= sohst.CountryRegionCode,			
		OrderSalesTerritoryGroup												= sohst.[Group],						
		OrderSalesTerritorySalesYTD												= sohst.SalesYTD,					
		OrderSalesTerritorySalesLastYear										= sohst.SalesLastYear,				
		OrderSalesTerritoryCostYTD												= sohst.CostYTD,						
		OrderSalesTerritoryCostLastYear											= sohst.CostLastYear,				
		OrderSalesTerritoryrowguid												= sohst.rowguid,						
		OrderSalesTerritoryModifiedDate											= sohst.ModifiedDate,				
		OrderSalesTerritoryCountryRegionName									= sohst.CountryRegionName,			
		OrderSalesTerritoryCountryRegionModifiedDate							= sohst.CountryRegionModifiedDate,

		BillToAddressAddressLine1												= bta.AddressLine1,											
		BillToAddressAddressLine2												= bta.AddressLine2,											
		BillToAddressCity														= bta.City,													
		BillToAddressStateProvinceID											= bta.StateProvinceID,											
		BillToAddressPostalCode													= bta.PostalCode,												
		BillToAddressSpatialLocation											= bta.SpatialLocation,											
		BillToAddressrowguid													= bta.rowguid,													
		BillToAddressModifiedDate												= bta.ModifiedDate,											
		BillToAddressStateProvinceStateProvinceCode								= bta.StateProvinceStateProvinceCode,							
		BillToAddressStateProvinceCountryRegionCode								= bta.StateProvinceCountryRegionCode,							
		BillToAddressStateProvinceIsOnlyStateProvinceFlag						= bta.StateProvinceIsOnlyStateProvinceFlag,					
		BillToAddressStateProvinceName											= bta.StateProvinceName,										
		BillToAddressStateProvinceTerritoryId									= bta.StateProvinceTerritoryId,								
		BillToAddressStateProvincerowguid										= bta.StateProvincerowguid,									
		BillToAddressStateProvinceModifiedDate									= bta.StateProvinceModifiedDate,								
		BillToAddressStateProvinceCountryRegionName								= bta.StateProvinceCountryRegionName,							
		BillToAddressStateProvinceCountryRegionModifiedDate						= bta.StateProvinceCountryRegionModifiedDate,					
		BillToAddressStateProvinceSalesTerritoryName							= bta.StateProvinceSalesTerritoryName,							
		BillToAddressStateProvinceSalesTerritoryCountryRegionCode				= bta.StateProvinceSalesTerritoryCountryRegionCode,			
		BillToAddressStateProvinceSalesTerritoryGroup							= bta.StateProvinceSalesTerritoryGroup,						
		BillToAddressStateProvinceSalesTerritorySalesYTD						= bta.StateProvinceSalesTerritorySalesYTD,						
		BillToAddressStateProvinceSalesTerritorySalesLastYear					= bta.StateProvinceSalesTerritorySalesLastYear,				
		BillToAddressStateProvinceSalesTerritoryCostYTD							= bta.StateProvinceSalesTerritoryCostYTD,						
		BillToAddressStateProvinceSalesTerritoryCostLastYear					= bta.StateProvinceSalesTerritoryCostLastYear,					
		BillToAddressStateProvinceSalesTerritoryrowguid							= bta.StateProvinceSalesTerritoryrowguid,						
		BillToAddressStateProvinceSalesTerritoryModifiedDate					= bta.StateProvinceSalesTerritoryModifiedDate,					
		BillToAddressStateProvinceSalesTerritoryCountryRegionName				= bta.StateProvinceSalesTerritoryCountryRegionName,			
		BillToAddressStateProvinceSalesTerritoryCountryRegionModifiedDate		= bta.StateProvinceSalesTerritoryCountryRegionModifiedDate,

		ShipToAddressAddressLine1												= sta.AddressLine1,											
		ShipToAddressAddressLine2												= sta.AddressLine2,											
		ShipToAddressCity														= sta.City,													
		ShipToAddressStateProvinceID											= sta.StateProvinceID,											
		ShipToAddressPostalCode													= sta.PostalCode,												
		ShipToAddressSpatialLocation											= sta.SpatialLocation,											
		ShipToAddressrowguid													= sta.rowguid,													
		ShipToAddressModifiedDate												= sta.ModifiedDate,											
		ShipToAddressStateProvinceStateProvinceCode								= sta.StateProvinceStateProvinceCode,							
		ShipToAddressStateProvinceCountryRegionCode								= sta.StateProvinceCountryRegionCode,							
		ShipToAddressStateProvinceIsOnlyStateProvinceFlag						= sta.StateProvinceIsOnlyStateProvinceFlag,					
		ShipToAddressStateProvinceName											= sta.StateProvinceName,										
		ShipToAddressStateProvinceTerritoryId									= sta.StateProvinceTerritoryId,								
		ShipToAddressStateProvincerowguid										= sta.StateProvincerowguid,									
		ShipToAddressStateProvinceModifiedDate									= sta.StateProvinceModifiedDate,								
		ShipToAddressStateProvinceCountryRegionName								= sta.StateProvinceCountryRegionName,							
		ShipToAddressStateProvinceCountryRegionModifiedDate						= sta.StateProvinceCountryRegionModifiedDate,					
		ShipToAddressStateProvinceSalesTerritoryName							= sta.StateProvinceSalesTerritoryName,							
		ShipToAddressStateProvinceSalesTerritoryCountryRegionCode				= sta.StateProvinceSalesTerritoryCountryRegionCode,			
		ShipToAddressStateProvinceSalesTerritoryGroup							= sta.StateProvinceSalesTerritoryGroup,						
		ShipToAddressStateProvinceSalesTerritorySalesYTD						= sta.StateProvinceSalesTerritorySalesYTD,						
		ShipToAddressStateProvinceSalesTerritorySalesLastYear					= sta.StateProvinceSalesTerritorySalesLastYear,				
		ShipToAddressStateProvinceSalesTerritoryCostYTD							= sta.StateProvinceSalesTerritoryCostYTD,						
		ShipToAddressStateProvinceSalesTerritoryCostLastYear					= sta.StateProvinceSalesTerritoryCostLastYear,					
		ShipToAddressStateProvinceSalesTerritoryrowguid							= sta.StateProvinceSalesTerritoryrowguid,						
		ShipToAddressStateProvinceSalesTerritoryModifiedDate					= sta.StateProvinceSalesTerritoryModifiedDate,					
		ShipToAddressStateProvinceSalesTerritoryCountryRegionName				= sta.StateProvinceSalesTerritoryCountryRegionName,			
		ShipToAddressStateProvinceSalesTerritoryCountryRegionModifiedDate		= sta.StateProvinceSalesTerritoryCountryRegionModifiedDate,

		ShipMethodName															= sohsm.Name,
		ShipMethodShipBase														= sohsm.ShipBase,
		ShipMethodShipRate														= sohsm.ShipRate,
		ShipMethodrowguid														= sohsm.rowguid,
		ShipMethodModifiedDate													= sohsm.ModifiedDate,

		CreditCardCardType														= sohsc.CardType,
		CreditCardCardNumber													= sohsc.CardNumber,
		CreditCardExpMonth														= sohsc.ExpMonth,
		CreditCardExpYear														= sohsc.ExpYear,
		CreditCardModifiedDate													= sohsc.ModifiedDate,

		CurrencyRateCurrencyRateDate											= sohcr.CurrencyRateDate,
		CurrencyRateFromCurrencyCode											= sohcr.FromCurrencyCode,
		CurrencyRateToCurrencyCode												= sohcr.ToCurrencyCode,
		CurrencyRateAverageRate													= sohcr.AverageRate,
		CurrencyRateEndOfDayRate												= sohcr.EndOfDayRate,
		CurrencyRateModifiedDate												= sohcr.ModifiedDate,

		FromCurrencyName														= sohcrcfrom.Name,
		FromCurrencyModifiedDate												= sohcrcfrom.ModifiedDate,

		ToCurrencyName															= sohcrcto.Name,
		ToCurrencyModifiedDate													= sohcrcto.ModifiedDate

FROM Sales.SalesOrderDetail AS sod
LEFT JOIN SpecialOfferProductAll AS sop -- logically an inner join should be used, but does not eliminate due to compound key
	ON  sop.SpecialOfferID = sod.SpecialOfferID AND
		sop.ProductID = sod.ProductID

JOIN Sales.SalesOrderHeader AS soh
	ON soh.SalesOrderID = sod.SalesOrderID

	JOIN Sales.Customer AS c
		ON c.CustomerID = soh.CustomerID
		LEFT JOIN Sales.Store AS cs
			ON cs.BusinessEntityID = c.StoreID
			LEFT JOIN SalesPerson AS cssp
				ON cssp.BusinessEntityID = cs.SalesPersonID
		LEFT JOIN SalesTerritoryAll AS cst
			ON cst.TerritoryID = c.TerritoryID
		LEFT JOIN PersonAll AS cp
			ON cp.BusinessEntityID = c.PersonID

	LEFT JOIN SalesPerson AS sohsp
		ON sohsp.BusinessEntityID = soh.SalesPersonID
	
	LEFT JOIN SalesTerritoryAll AS sohst
		ON sohst.TerritoryID = soh.TerritoryID

	JOIN AddressAll AS bta
		ON bta.AddressID = soh.BillToAddressID
	
	JOIN AddressAll AS sta
		ON sta.AddressID = soh.ShipToAddressID

	JOIN Purchasing.ShipMethod AS sohsm
		ON sohsm.ShipMethodId = soh.ShipMethodID

	LEFT JOIN Sales.CreditCard AS sohsc
		ON sohsc.CreditCardID = soh.CreditCardID

	LEFT JOIN Sales.CurrencyRate AS sohcr
		ON sohcr.CurrencyRateID = soh.CurrencyRateID
		LEFT JOIN Sales.Currency AS sohcrcfrom
			ON sohcrcfrom.CurrencyCode = sohcr.FromCurrencyCode
		LEFT JOIN Sales.Currency AS sohcrcto
			ON sohcrcto.CurrencyCode = sohcr.ToCurrencyCode

GO


