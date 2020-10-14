USE AdventureWorks2008R2
GO

IF OBJECT_ID('Sales.vSalesOrderDetailAllV2','V') IS NOT NULL
    DROP VIEW Sales.vSalesOrderDetailAllV2
GO

CREATE VIEW Sales.vSalesOrderDetailAllV2

AS

-- All properties of SalesOrderDetail.
-- No elimination or duplication of SalesOrderDetail rows.

-- CTEs used to allow multiple use of join construct

-- Comprehensive join elimination facilitated by using outer joins, where normally inner would be used (Non null referrer, FK enforced)

-- NOTE:
-- This may come at a compilation cost, for more comprehensive consumption.
-- i.e	A select * from this view will use more CPU and memory to compile,
--      vs. the equivelent view with 'normal' inner joins

WITH SalesTerritoryAll AS (
SELECT  TerritoryID                 = st.TerritoryID,
        Name                        = st.Name,
        CountryRegionCode           = st.CountryRegionCode,
        [Group]                     = st.[Group],
        SalesYTD                    = st.SalesYTD,
        SalesLastYear               = st.SalesLastYear,
        CostYTD                     = st.CostYTD,
        CostLastYear                = st.CostLastYear,
        rowguid                     = st.rowguid,
        ModifiedDate                = st.ModifiedDate,

        CountryRegionName           = stcr.Name,
        CountryRegionModifiedDate   = stcr.ModifiedDate

FROM Sales.SalesTerritory AS st
    LEFT JOIN Person.CountryRegion AS stcr
        ON stcr.CountryRegionCode = st.CountryRegionCode
),

AddressAll AS (
SELECT  AddressId                                               = a.AddressID,
        AddressLine1                                            = a.AddressLine1,
        AddressLine2                                            = a.AddressLine2,
        City                                                    = a.City,
        StateProvinceID                                         = a.StateProvinceID,
        PostalCode                                              = a.PostalCode,
        SpatialLocation                                         = a.SpatialLocation,
        rowguid                                                 = a.rowguid,
        ModifiedDate                                            = a.ModifiedDate,

        StateProvinceStateProvinceCode                          = asp.StateProvinceCode,
        StateProvinceCountryRegionCode                          = asp.CountryRegionCode,
        StateProvinceIsOnlyStateProvinceFlag                    = asp.IsOnlyStateProvinceFlag,
        StateProvinceName                                       = asp.Name,
        StateProvinceTerritoryId                                = asp.TerritoryID,
        StateProvincerowguid                                    = asp.rowguid,
        StateProvinceModifiedDate                               = asp.ModifiedDate,    

        StateProvinceCountryRegionName                          = aspcr.Name,
        StateProvinceCountryRegionModifiedDate                  = aspcr.ModifiedDate,
        StateProvinceSalesTerritoryName                         = aspst.Name,
        StateProvinceSalesTerritoryCountryRegionCode            = aspst.CountryRegionCode,
        StateProvinceSalesTerritoryGroup                        = aspst.[Group],
        StateProvinceSalesTerritorySalesYTD                     = aspst.SalesYTD,
        StateProvinceSalesTerritorySalesLastYear                = aspst.SalesLastYear,
        StateProvinceSalesTerritoryCostYTD                      = aspst.CostYTD,
        StateProvinceSalesTerritoryCostLastYear                 = aspst.CostLastYear,
        StateProvinceSalesTerritoryrowguid                      = aspst.rowguid,
        StateProvinceSalesTerritoryModifiedDate                 = aspst.ModifiedDate,
        StateProvinceSalesTerritoryCountryRegionName            = aspst.CountryRegionName,
        StateProvinceSalesTerritoryCountryRegionModifiedDate    = aspst.CountryRegionModifiedDate

FROM Person.Address AS a
    LEFT JOIN Person.StateProvince AS asp
        ON asp.StateProvinceID    = a.StateProvinceID
        LEFT JOIN Person.CountryRegion AS aspcr
            ON aspcr.CountryRegionCode = asp.CountryRegionCode
        LEFT JOIN SalesTerritoryAll AS aspst
            ON aspst.TerritoryID = asp.TerritoryID
),

PersonAll AS (
SELECT  BusinessEntityID                    = p.BusinessEntityID,
        BusinessEntityrowguid               = pbe.rowguid,
        BusinessEntityModifiedDate          = pbe.ModifiedDate,

        PersonType                          = p.PersonType,
        NameStyle                           = p.NameStyle,
        Title                               = p.Title,
        FirstName                           = p.FirstName,
        MiddleName                          = p.MiddleName,
        LastName                            = p.LastName,
        Suffix                              = p.Suffix,
        EmailPromotion                      = p.EmailPromotion,
        AdditionalContactInfo               = p.AdditionalContactInfo,
        Demographics                        = p.Demographics,
        DemographicsTotalPurchaseYTD        = p.Demographics.value('declare default element namespace "http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/IndividualSurvey";(/IndividualSurvey/TotalPurchaseYTD)[1]', 'money'),
        DemographicsDateFirstPurchase       = CONVERT(DATETIME, REPLACE(p.Demographics.value('declare default element namespace "http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/IndividualSurvey";(/IndividualSurvey/DateFirstPurchase)[1]', 'nvarchar(20)'),'Z', ''), 101),
        DemographicsBirthDate               = CONVERT(DATETIME, REPLACE(p.Demographics.value('declare default element namespace "http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/IndividualSurvey";(/IndividualSurvey/BirthDate)[1]', 'nvarchar(20)'),'Z', ''), 101),
        DemographicsMaritalStatus           = p.Demographics.value('declare default element namespace "http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/IndividualSurvey";(/IndividualSurvey/MaritalStatus)[1]', 'nvarchar(1)'),
        DemographicsYearlyIncome            = p.Demographics.value('declare default element namespace "http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/IndividualSurvey";(/IndividualSurvey/YearlyIncome)[1]', 'nvarchar(30)'),
        DemographicsGender                  = p.Demographics.value('declare default element namespace "http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/IndividualSurvey";(/IndividualSurvey/Gender)[1]', 'nvarchar(1)'),
        DemographicsTotalChildren           = p.Demographics.value('declare default element namespace "http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/IndividualSurvey";(/IndividualSurvey/TotalChildren)[1]', 'integer'),
        DemographicsNumberChildrenAtHome    = p.Demographics.value('declare default element namespace "http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/IndividualSurvey";(/IndividualSurvey/NumberChildrenAtHome)[1]', 'integer'),
        DemographicsEducation               = p.Demographics.value('declare default element namespace "http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/IndividualSurvey";(/IndividualSurvey/Education)[1]', 'nvarchar(30)'),
        DemographicsOccupation              = p.Demographics.value('declare default element namespace "http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/IndividualSurvey";(/IndividualSurvey/Occupation)[1]', 'nvarchar(30)'), -- TODO: Right Type? was 'c' in cross apply view.
        DemographicsHomeOwnerFlag           = p.Demographics.value('declare default element namespace "http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/IndividualSurvey";(/IndividualSurvey/HomeOwnerFlag)[1]', 'bit'),
        DemographicsNumberCarsOwned         = p.Demographics.value('declare default element namespace "http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/IndividualSurvey";(/IndividualSurvey/NumberCarsOwned)[1]', 'integer'),
        DemographicsHobby                   = p.Demographics.value('declare default element namespace "http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/IndividualSurvey";(/IndividualSurvey/Hobby)[1]', 'nvarchar(30)'),
        DemographicsCommuteDistance         = p.Demographics.value('declare default element namespace "http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/IndividualSurvey";(/IndividualSurvey/CommuteDistance)[1]', 'nvarchar(30)'),
        DemographicsComments                = p.Demographics.value('declare default element namespace "http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/IndividualSurvey";(/IndividualSurvey/Comments)[1]', 'nvarchar(30)'),
        rowguid                             = p.rowguid,
        ModifiedDate                        = p.ModifiedDate
        
FROM Person.Person AS p
    LEFT JOIN Person.BusinessEntity AS pbe
        ON pbe.BusinessEntityID = p.BusinessEntityID
),

SalesPersonAll AS (
SELECT  BusinessEntityID                                = sp.BusinessEntityID,
        TerritoryID                                     = sp.TerritoryID,
        SalesQuota                                      = sp.SalesQuota,
        Bonus                                           = sp.Bonus,
        CommissionPct                                   = sp.CommissionPct,
        SalesYTD                                        = sp.SalesYTD,
        SalesLastYear                                   = sp.SalesLastYear,
        rowguid                                         = sp.rowguid,
        ModifiedDate                                    = sp.ModifiedDate,

        EmployeeNationalIDNumber                        = spe.NationalIDNumber,
        EmployeeLoginID                                 = spe.LoginID, 
        EmployeeOrganizationNode                        = spe.OrganizationNode,
        EmployeeOrganizationLevel                       = spe.OrganizationLevel,
        EmployeeJobTitle                                = spe.JobTitle,
        EmployeeBirthDate                               = spe.BirthDate,
        EmployeeMaritalStatus                           = spe.MaritalStatus,
        EmployeeGender                                  = spe.Gender,
        EmployeeHireDate                                = spe.HireDate,
        EmployeeSalariedFlag                            = spe.SalariedFlag,
        EmployeeVacationHours                           = spe.VacationHours,
        EmployeeSickLeaveHours                          = spe.SickLeaveHours,
        EmployeeCurrentFlag                             = spe.CurrentFlag, 
        Employeerowguid                                 = spe.rowguid, 
        EmployeeModifiedDate                            = spe.ModifiedDate,

        EmployeePersonPersonType                        = spep.PersonType,
        EmployeePersonNameStyle                         = spep.NameStyle,
        EmployeePersonTitle                             = spep.Title,
        EmployeePersonFirstName                         = spep.FirstName,
        EmployeePersonMiddleName                        = spep.MiddleName,
        EmployeePersonLastName                          = spep.LastName,
        EmployeePersonSuffix                            = spep.Suffix,
        EmployeePersonEmailPromotion                    = spep.EmailPromotion,
        EmployeePersonAdditionalContactInfo             = spep.AdditionalContactInfo,
        EmployeePersonDemographics                      = spep.Demographics,
        EmployeePersonDemographicsTotalPurchaseYTD      = spep.DemographicsTotalPurchaseYTD,
        EmployeePersonDemographicsDateFirstPurchase     = spep.DemographicsDateFirstPurchase,    
        EmployeePersonDemographicsBirthDate             = spep.DemographicsBirthDate,            
        EmployeePersonDemographicsMaritalStatus         = spep.DemographicsMaritalStatus,        
        EmployeePersonDemographicsYearlyIncome          = spep.DemographicsYearlyIncome,        
        EmployeePersonDemographicsGender                = spep.DemographicsGender,                
        EmployeePersonDemographicsTotalChildren         = spep.DemographicsTotalChildren,        
        EmployeePersonDemographicsNumberChildrenAtHome  = spep.DemographicsNumberChildrenAtHome,
        EmployeePersonDemographicsEducation             = spep.DemographicsEducation,            
        EmployeePersonDemographicsOccupation            = spep.DemographicsOccupation,            
        EmployeePersonDemographicsHomeOwnerFlag         = spep.DemographicsHomeOwnerFlag,        
        EmployeePersonDemographicsNumberCarsOwned       = spep.DemographicsNumberCarsOwned,        
        EmployeePersonDemographicsHobby                 = spep.DemographicsHobby,                
        EmployeePersonDemographicsCommuteDistance       = spep.DemographicsCommuteDistance,        
        EmployeePersonDemographicsComments              = spep.DemographicsComments,            
        EmployeePersonrowguid                           = spep.rowguid,
        EmployeePersonModifiedDate                      = spep.ModifiedDate,

        EmployeePersonBusinessEntityrowguid             = spep.BusinessEntityrowguid,
        EmployeePersonBusinessEntityModifiedDate        = spep.BusinessEntityModifiedDate,

        SalesTerritoryName                              = spst.Name,
        SalesTerritoryCountryCode                       = spst.CountryRegionCode,
        SalesTerritoryGroup                             = spst.[Group],
        SalesTerritorySalesYTD                          = spst.SalesYTD,
        SalesTerritorySalesLastYear                     = spst.SalesLastYear,
        SalesTerritoryCostYTD                           = spst.CostYTD,
        SalesTerritoryCostLastYear                      = spst.CostLastYear,
        SalesTerritoryrowguid                           = spst.rowguid,
        SalesTerritoryModifiedDate                      = spst.ModifiedDate,
        SalesTerritoryCountryRegionName                 = spst.CountryRegionName,
        SalesTerritoryCountryRegionModifiedDate         = spst.CountryRegionModifiedDate

FROM Sales.SalesPerson AS sp
    LEFT JOIN HumanResources.Employee AS spe
        ON spe.BusinessEntityID = sp.BusinessEntityID
        LEFT JOIN PersonAll AS spep
            ON spep.BusinessEntityID = spe.BusinessEntityID
    LEFT JOIN SalesTerritoryAll AS spst
        ON spst.TerritoryID = sp.TerritoryID
),

ProductSubcategoryAll AS
(SELECT ProductSubcategoryID            = ps.ProductSubcategoryID,
       ProductSubCategoryName           = ps.Name,
       ProductSubCategoryrowguid        = ps.rowguid,
       ProductSubCategoryModifiedDate   = ps.ModifiedDate,

       ProductCategoryID                = pc.ProductCategoryID,
       ProductCategoryName              = pc.Name,
       ProductCategoryrowguid           = pc.rowguid,
       ProductCategoryModifiedDate      = pc.ModifiedDate

FROM Production.ProductSubcategory AS ps
    LEFT JOIN Production.ProductCategory AS pc
        ON pc.ProductCategoryID = ps.ProductCategoryID
),

SpecialOfferProductAll AS
(SELECT SpecialOfferID                          = sop.SpecialOfferID,
        SpecialOfferDescription                 = so.Description,    
        SpecialOfferDiscountPct                 = so.DiscountPct,    
        SpecialOfferType                        = so.Type,
        SpecialOfferCategory                    = so.Category,
        SpecialOfferStartDate                   = so.StartDate,
        SpecialOfferEndDate                     = so.EndDate,    
        SpecialOfferMinQty                      = so.MinQty,
        SpecialOfferMaxQty                      = so.MaxQty,
        SpecialOfferrowguid                     = so.rowguid,    
        SpecialOfferModifiedDate                = so.ModifiedDate,        

        ProductID                               = sop.ProductID,
        ProductName                             = p.Name,
        ProductProductNumber                    = p.ProductNumber,
        ProductMakeFlag                         = p.MakeFlag,
        ProductFinishedGoodsFlag                = p.FinishedGoodsFlag,
        ProductColor                            = p.Color,
        ProductSafetyStockLevel                 = p.SafetyStockLevel,
        ProductReorderPoint                     = p.ReorderPoint,
        ProductStandardCost                     = p.StandardCost,
        ProductListPrice                        = p.ListPrice,

        ProductSize                             = p.Size,
        ProductSizeUnitMeasureCode              = p.SizeUnitMeasureCode,
        ProductSizeUnitMeasureName              = umsize.Name,
        ProductSizeUnitMeasureModifiedDate      = umsize.ModifiedDate,
        
        ProductWeight                           = p.Weight,
        ProductWeightUnitMeasureCode            = p.WeightUnitMeasureCode,
        ProductWeightUnitMeasureName            = umweight.Name,
        ProductWeightUnitMeasureModifiedDate    = umweight.ModifiedDate,
        
        ProductDaysToManufacture                = p.DaysToManufacture,
        ProductProductLine                      = p.ProductLine,
        ProductClass                            = p.Class,
        ProductStyle                            = p.Style,
        ProductProductSubcategoryID             = p.ProductSubcategoryID,
        ProductProductModelID                   = p.ProductModelID,
        ProductSellStartDate                    = p.SellStartDate,
        ProductSellEndDate                      = p.SellEndDate,
        ProductDiscontinuedDate                 = p.DiscontinuedDate,
        Productrowguid                          = p.rowguid,
        ProductModifiedDate                     = p.ModifiedDate,

        ProductModelId                          = p.ProductModelID,
        ProductModelName                        = pm.Name,
        ProductModelInstructions                = pm.Instructions,
        ProductModelrowguid                     = pm.rowguid,    
        ProductModelModifiedDate                = pm.ModifiedDate,

        ProductModelCatalogDescription                          = pm.CatalogDescription,
        ProductModelCatalogDescriptionSummary                   = vpmcd.Summary,
        ProductModelCatalogDescriptionManufacturer              = vpmcd.Manufacturer,
        ProductModelCatalogDescriptionCopyright                 = vpmcd.Copyright,
        ProductModelCatalogDescriptionProductURL                = vpmcd.ProductURL,
        ProductModelCatalogDescriptionWarrantyPeriod            = vpmcd.WarrantyPeriod,
        ProductModelCatalogDescriptionWarrantyDescription       = vpmcd.WarrantyDescription,
        ProductModelCatalogDescriptionNoOfYears                 = vpmcd.NoOfYears,
        ProductModelCatalogDescriptionMaintenanceDescription    = vpmcd.MaintenanceDescription,
        ProductModelCatalogDescriptionWheel                     = vpmcd.Wheel,
        ProductModelCatalogDescriptionSaddle                    = vpmcd.Saddle,
        ProductModelCatalogDescriptionPedal                     = vpmcd.Pedal,
        ProductModelCatalogDescriptionBikeFrame                 = vpmcd.BikeFrame,
        ProductModelCatalogDescriptionCrankset                  = vpmcd.Crankset,
        ProductModelCatalogDescriptionPictureAngle              = vpmcd.PictureAngle,
        ProductModelCatalogDescriptionPictureSize               = vpmcd.PictureSize,
        ProductModelCatalogDescriptionProductPhotoID            = vpmcd.ProductPhotoID,
        ProductModelCatalogDescriptionMaterial                  = vpmcd.Material,
        ProductModelCatalogDescriptionColor                     = vpmcd.Color,
        ProductModelCatalogDescriptionProductLine               = vpmcd.ProductLine,
        ProductModelCatalogDescriptionStyle                     = vpmcd.Style,
        ProductModelCatalogDescriptionRiderExperience           = vpmcd.RiderExperience,

        ProductSubcategoryID                    = p.ProductSubcategoryID,
        ProductSubCategoryName                  = ps.ProductSubCategoryName,
        ProductSubCategoryrowguid               = ps.ProductSubCategoryrowguid,
        ProductSubCategoryModifiedDate          = ps.ProductSubCategoryModifiedDate,

        ProductCategoryID                       = ps.ProductCategoryID,
        ProductCategoryName                     = ps.ProductCategoryName,
        ProductCategoryrowguid                  = ps.ProductCategoryrowguid,
        ProductCategoryModifiedDate             = ps.ProductCategoryModifiedDate,

        rowguid                                 = sop.rowguid,
        ModifiedDate                            = sop.ModifiedDate

FROM Sales.SpecialOfferProduct AS sop
    LEFT JOIN Sales.SpecialOffer AS so
        ON so.SpecialOfferID = sop.SpecialOfferID
        LEFT JOIN Production.Product AS p
            ON p.ProductID = sop.ProductID
            LEFT JOIN ProductSubcategoryAll AS ps
                ON ps.ProductSubcategoryID = p.ProductSubcategoryID
                LEFT JOIN Production.ProductModel AS pm
                    ON pm.ProductModelID = p.ProductModelID
                    LEFT JOIN Production.vProductModelCatalogDescription AS vpmcd
                        ON vpmcd.ProductModelID = pm.ProductModelID
            LEFT JOIN Production.UnitMeasure AS umsize
                ON umsize.UnitMeasureCode = p.SizeUnitMeasureCode
            LEFT JOIN Production.UnitMeasure AS umweight
                ON umweight.UnitMeasureCode = p.WeightUnitMeasureCode
)

SELECT  SalesOrderID                    = sod.SalesOrderID,
        SalesOrderDetailID              = sod.SalesOrderDetailID,
        CarrierTrackingNumber           = sod.CarrierTrackingNumber,
        OrderQty                        = sod.OrderQty,
        UnitPrice                       = sod.UnitPrice,
        UnitPriceDiscount               = sod.UnitPriceDiscount,
        LineTotal                       = sod.LineTotal,
        rowguid                         = sod.rowguid,
        ModifiedDate                    = sod.ModifiedDate,

        SpecialOfferProductrowguid      = sop.rowguid,                        
        SpecialOfferProductModifiedDate = sop.ModifiedDate,
        
        SpecialOfferId                  = sod.SpecialOfferId,
        SpecialOfferDescription         = sop.SpecialOfferDescription,            
        SpecialOfferDiscountPct         = sop.SpecialOfferDiscountPct,            
        SpecialOfferType                = sop.SpecialOfferType,                
        SpecialOfferCategory            = sop.SpecialOfferCategory,            
        SpecialOfferStartDate           = sop.SpecialOfferStartDate,            
        SpecialOfferEndDate             = sop.SpecialOfferEndDate,                
        SpecialOfferMinQty              = sop.SpecialOfferMinQty,                
        SpecialOfferMaxQty              = sop.SpecialOfferMaxQty,                
        SpecialOfferrowguid             = sop.SpecialOfferrowguid,                
        SpecialOfferModifiedDate        = sop.SpecialOfferModifiedDate,        

        ProductId                       = sod.ProductId,
        ProductName                     = sop.ProductName,                    
        ProductProductNumber            = sop.ProductProductNumber,            
        ProductMakeFlag                 = sop.ProductMakeFlag,                    
        ProductFinishedGoodsFlag        = sop.ProductFinishedGoodsFlag,        
        ProductColor                    = sop.ProductColor,                    
        ProductSafetyStockLevel         = sop.ProductSafetyStockLevel,            
        ProductReorderPoint             = sop.ProductReorderPoint,                
        ProductStandardCost             = sop.ProductStandardCost,                
        ProductListPrice                = sop.ProductListPrice,                

        ProductSize                             = sop.ProductSize,                        
        ProductSizeUnitMeasureCode              = sop.ProductSizeUnitMeasureCode,        
        ProductSizeUnitMeasureName              = sop.ProductSizeUnitMeasureName,        
        ProductSizeUnitMeasureModifiedDate      = sop.ProductSizeUnitMeasureModifiedDate,        

        ProductWeight                           = sop.ProductWeight,                    
        ProductWeightUnitMeasureCode            = sop.ProductWeightUnitMeasureCode,    
        ProductWeightUnitMeasureName            = sop.ProductWeightUnitMeasureName,        
        ProductWeightUnitMeasureModifiedDate    = sop.ProductWeightUnitMeasureModifiedDate,        

        ProductDaysToManufacture        = sop.ProductDaysToManufacture,        
        ProductProductLine              = sop.ProductProductLine,                
        ProductClass                    = sop.ProductClass,                    
        ProductStyle                    = sop.ProductStyle,                    
        ProductProductModelID           = sop.ProductProductModelID,            
        ProductSellStartDate            = sop.ProductSellStartDate,            
        ProductSellEndDate              = sop.ProductSellEndDate,                
        ProductDiscontinuedDate         = sop.ProductDiscontinuedDate,            
        Productrowguid                  = sop.Productrowguid,                    
        ProductModifiedDate             = sop.ProductModifiedDate,                
        
        ProductModelId                  = sop.ProductModelId,
        ProductModelName                = sop.ProductModelName,                
        ProductModelInstructions        = sop.ProductModelInstructions,        
        ProductModelrowguid             = sop.ProductModelrowguid,                
        ProductModelModifiedDate        = sop.ProductModelModifiedDate,        

        ProductModelCatalogDescription                          = sop.ProductModelCatalogDescription,
        ProductModelCatalogDescriptionSummary                   = sop.ProductModelCatalogDescriptionSummary,
        ProductModelCatalogDescriptionManufacturer              = sop.ProductModelCatalogDescriptionManufacturer,
        ProductModelCatalogDescriptionCopyright                 = sop.ProductModelCatalogDescriptionCopyright,
        ProductModelCatalogDescriptionProductURL                = sop.ProductModelCatalogDescriptionProductURL,
        ProductModelCatalogDescriptionWarrantyPeriod            = sop.ProductModelCatalogDescriptionWarrantyPeriod,
        ProductModelCatalogDescriptionWarrantyDescription       = sop.ProductModelCatalogDescriptionWarrantyDescription,
        ProductModelCatalogDescriptionNoOfYears                 = sop.ProductModelCatalogDescriptionNoOfYears,
        ProductModelCatalogDescriptionMaintenanceDescription    = sop.ProductModelCatalogDescriptionMaintenanceDescription, 
        ProductModelCatalogDescriptionWheel                     = sop.ProductModelCatalogDescriptionWheel,
        ProductModelCatalogDescriptionSaddle                    = sop.ProductModelCatalogDescriptionSaddle,
        ProductModelCatalogDescriptionPedal                     = sop.ProductModelCatalogDescriptionPedal,
        ProductModelCatalogDescriptionBikeFrame                 = sop.ProductModelCatalogDescriptionBikeFrame,
        ProductModelCatalogDescriptionCrankset                  = sop.ProductModelCatalogDescriptionCrankset,
        ProductModelCatalogDescriptionPictureAngle              = sop.ProductModelCatalogDescriptionPictureAngle,
        ProductModelCatalogDescriptionPictureSize               = sop.ProductModelCatalogDescriptionPictureSize,
        ProductModelCatalogDescriptionProductPhotoID            = sop.ProductModelCatalogDescriptionProductPhotoID,
        ProductModelCatalogDescriptionMaterial                  = sop.ProductModelCatalogDescriptionMaterial, 
        ProductModelCatalogDescriptionColor                     = sop.ProductModelCatalogDescriptionColor,
        ProductModelCatalogDescriptionProductLine               = sop.ProductModelCatalogDescriptionProductLine,
        ProductModelCatalogDescriptionStyle                     = sop.ProductModelCatalogDescriptionStyle,
        ProductModelCatalogDescriptionRiderExperience           = sop.ProductModelCatalogDescriptionRiderExperience,

        ProductSubcategoryID            = sop.ProductProductSubcategoryID,        
        ProductSubCategoryName          = sop.ProductSubCategoryName,            
        ProductSubCategoryrowguid       = sop.ProductSubCategoryrowguid,        
        ProductSubCategoryModifiedDate  = sop.ProductSubCategoryModifiedDate,

        ProductCategoryID               = sop.ProductCategoryID,            
        ProductCategoryName             = sop.ProductCategoryName,                
        ProductCategoryrowguid          = sop.ProductCategoryrowguid,            
        ProductCategoryModifiedDate     = sop.ProductCategoryModifiedDate,        

        OrderRevisionNumber             = soh.RevisionNumber,
        OrderOrderDate                  = soh.OrderDate,
        OrderDueDate                    = soh.DueDate,
        OrderShipDate                   = soh.ShipDate,
        OrderStatus                     = soh.Status,
        OrderOnlineOrderFlag            = soh.OnlineOrderFlag,
        OrderSalesOrderNumber           = soh.SalesOrderNumber,
        OrderPurchaseOrderNumber        = soh.PurchaseOrderNumber,
        OrderAccountNumber              = soh.AccountNumber,
        OrderCreditCardApprovalCode     = soh.CreditCardApprovalCode,
        OrderSubTotal                   = soh.SubTotal,
        OrderTaxAmt                     = soh.TaxAmt,
        OrderFreight                    = soh.Freight,
        OrderTotalDue                   = soh.TotalDue,
        OrderComment                    = soh.Comment,
        Orderrowguid                    = soh.rowguid,
        OrderModifiedDate               = soh.ModifiedDate,

        OrderCustomerID                 = soh.CustomerID,
        OrderCustomerAccountNumber      = c.AccountNumber,
        OrderCustomerrowguid            = c.rowguid,
        OrderCustomerModifiedDate       = c.ModifiedDate,

        OrderCustomerStoreID                             = c.StoreID,
        OrderCustomerStoreName                           = cs.Name,
        OrderCustomerStoreSalesPersonID                  = cs.SalesPersonID,
        OrderCustomerStoreDemographics                   = cs.Demographics,
        OrderCustomerStoreDemographicsContactName        = cs.Demographics.value('declare default element namespace "http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/StoreSurvey";(/StoreSurvey/ContactName)[1]', 'money'),
        OrderCustomerStoreDemographicsJobTitle           = cs.Demographics.value('declare default element namespace "http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/StoreSurvey";(/StoreSurvey/JobTitle)[1]', 'money'),
        OrderCustomerStoreDemographicsAnnualSales        = cs.Demographics.value('declare default element namespace "http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/StoreSurvey";(/StoreSurvey/AnnualSales)[1]', 'money'),
        OrderCustomerStoreDemographicsAnnualRevenue      = cs.Demographics.value('declare default element namespace "http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/StoreSurvey";(/StoreSurvey/AnnualRevenue)[1]', 'money'),          
        OrderCustomerStoreDemographicsBankName           = cs.Demographics.value('declare default element namespace "http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/StoreSurvey";(/StoreSurvey/BankName)[1]', 'nvarchar(50)'),              
        OrderCustomerStoreDemographicsBusinessType       = cs.Demographics.value('declare default element namespace "http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/StoreSurvey";(/StoreSurvey/BusinessType)[1]', 'nvarchar(5)'),       
        OrderCustomerStoreDemographicsYearOpened         = cs.Demographics.value('declare default element namespace "http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/StoreSurvey";(/StoreSurvey/YearOpened)[1]', 'integer'),              
        OrderCustomerStoreDemographicsSpecialty          = cs.Demographics.value('declare default element namespace "http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/StoreSurvey";(/StoreSurvey/Specialty)[1]', 'nvarchar(50)'),      
        OrderCustomerStoreDemographicsSquareFeet         = cs.Demographics.value('declare default element namespace "http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/StoreSurvey";(/StoreSurvey/SquareFeet)[1]', 'integer'),              
        OrderCustomerStoreDemographicsBrands             = cs.Demographics.value('declare default element namespace "http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/StoreSurvey";(/StoreSurvey/Brands)[1]', 'nvarchar(30)'),          
        OrderCustomerStoreDemographicsInternet           = cs.Demographics.value('declare default element namespace "http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/StoreSurvey";(/StoreSurvey/Internet)[1]', 'nvarchar(30)'),               
        OrderCustomerStoreDemographicsNumberEmployees    = cs.Demographics.value('declare default element namespace "http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/StoreSurvey";(/StoreSurvey/NumberEmployees)[1]', 'integer'), 
        OrderCustomerStoreDemographicsComments           = cs.Demographics.value('declare default element namespace "http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/StoreSurvey";(/StoreSurvey/Comments)[1]', 'integer'), 
        OrderCustomerStorerowguid                        = cs.rowguid,
        OrderCustomerStoreModifiedDate                   = cs.ModifiedDate,

        OrderCustomerStoreSalesPersonBusinessEntityID    = cssp.BusinessEntityID,                        
        OrderCustomerStoreSalesPersonSalesQuota          = cssp.SalesQuota,                                    
        OrderCustomerStoreSalesPersonBonus               = cssp.Bonus,                                        
        OrderCustomerStoreSalesPersonCommissionPct       = cssp.CommissionPct,                                
        OrderCustomerStoreSalesPersonSalesYTD            = cssp.SalesYTD,                                    
        OrderCustomerStoreSalesPersonSalesLastYear       = cssp.SalesLastYear,                                
        OrderCustomerStoreSalesPersonrowguid             = cssp.rowguid,                                        
        OrderCustomerStoreSalesPersonModifiedDate        = cssp.ModifiedDate,                                

        OrderCustomerStoreSalesPersonEmployeeNationalIDNumber    = cssp.EmployeeNationalIDNumber,                    
        OrderCustomerStoreSalesPersonEmployeeLoginID             = cssp.EmployeeLoginID,                                
        OrderCustomerStoreSalesPersonEmployeeOrganizationNode    = cssp.EmployeeOrganizationNode,                    
        OrderCustomerStoreSalesPersonEmployeeOrganizationLevel   = cssp.EmployeeOrganizationLevel,                    
        OrderCustomerStoreSalesPersonEmployeeJobTitle            = cssp.EmployeeJobTitle,                            
        OrderCustomerStoreSalesPersonEmployeeBirthDate           = cssp.EmployeeBirthDate,                            
        OrderCustomerStoreSalesPersonEmployeeMaritalStatus       = cssp.EmployeeMaritalStatus,                        
        OrderCustomerStoreSalesPersonEmployeeGender              = cssp.EmployeeGender,                                
        OrderCustomerStoreSalesPersonEmployeeHireDate            = cssp.EmployeeHireDate,                            
        OrderCustomerStoreSalesPersonEmployeeSalariedFlag        = cssp.EmployeeSalariedFlag,                        
        OrderCustomerStoreSalesPersonEmployeeVacationHours       = cssp.EmployeeVacationHours,                        
        OrderCustomerStoreSalesPersonEmployeeSickLeaveHours      = cssp.EmployeeSickLeaveHours,                        
        OrderCustomerStoreSalesPersonEmployeeCurrentFlag         = cssp.EmployeeCurrentFlag,                            
        OrderCustomerStoreSalesPersonEmployeerowguid             = cssp.Employeerowguid,                                
        OrderCustomerStoreSalesPersonEmployeeModifiedDate        = cssp.EmployeeModifiedDate,                        

        OrderCustomerStoreSalesPersonEmployeePersonPersonType                       = cssp.EmployeePersonPersonType,                    
        OrderCustomerStoreSalesPersonEmployeePersonNameStyle                        = cssp.EmployeePersonNameStyle,                        
        OrderCustomerStoreSalesPersonEmployeePersonTitle                            = cssp.EmployeePersonTitle,                            
        OrderCustomerStoreSalesPersonEmployeePersonFirstName                        = cssp.EmployeePersonFirstName,                        
        OrderCustomerStoreSalesPersonEmployeePersonMiddleName                       = cssp.EmployeePersonMiddleName,                    
        OrderCustomerStoreSalesPersonEmployeePersonLastName                         = cssp.EmployeePersonLastName,                        
        OrderCustomerStoreSalesPersonEmployeePersonSuffix                           = cssp.EmployeePersonSuffix,                    
        OrderCustomerStoreSalesPersonEmployeePersonEmailPromotion                   = cssp.EmployeePersonEmailPromotion,                
        OrderCustomerStoreSalesPersonEmployeePersonAdditionalContactInfo            = cssp.EmployeePersonAdditionalContactInfo,            
        OrderCustomerStoreSalesPersonEmployeePersonDemographics                      = cssp.EmployeePersonDemographics,
        OrderCustomerStoreSalesPersonEmployeePersonDemographicsTotalPurchaseYTD      = cssp.EmployeePersonDemographicsTotalPurchaseYTD,
        OrderCustomerStoreSalesPersonEmployeePersonDemographicsDateFirstPurchase     = cssp.EmployeePersonDemographicsDateFirstPurchase,    
        OrderCustomerStoreSalesPersonEmployeePersonDemographicsBirthDate             = cssp.EmployeePersonDemographicsBirthDate,            
        OrderCustomerStoreSalesPersonEmployeePersonDemographicsMaritalStatus         = cssp.EmployeePersonDemographicsMaritalStatus,        
        OrderCustomerStoreSalesPersonEmployeePersonDemographicsYearlyIncome          = cssp.EmployeePersonDemographicsYearlyIncome,        
        OrderCustomerStoreSalesPersonEmployeePersonDemographicsGender                = cssp.EmployeePersonDemographicsGender,                
        OrderCustomerStoreSalesPersonEmployeePersonDemographicsTotalChildren         = cssp.EmployeePersonDemographicsTotalChildren,        
        OrderCustomerStoreSalesPersonEmployeePersonDemographicsNumberChildrenAtHome  = cssp.EmployeePersonDemographicsNumberChildrenAtHome,
        OrderCustomerStoreSalesPersonEmployeePersonDemographicsEducation             = cssp.EmployeePersonDemographicsEducation,            
        OrderCustomerStoreSalesPersonEmployeePersonDemographicsOccupation            = cssp.EmployeePersonDemographicsOccupation,            
        OrderCustomerStoreSalesPersonEmployeePersonDemographicsHomeOwnerFlag         = cssp.EmployeePersonDemographicsHomeOwnerFlag,        
        OrderCustomerStoreSalesPersonEmployeePersonDemographicsNumberCarsOwned       = cssp.EmployeePersonDemographicsNumberCarsOwned,        
        OrderCustomerStoreSalesPersonEmployeePersonDemographicsHobby                 = cssp.EmployeePersonDemographicsHobby,                
        OrderCustomerStoreSalesPersonEmployeePersonDemographicsCommuteDistance       = cssp.EmployeePersonDemographicsCommuteDistance,        
        OrderCustomerStoreSalesPersonEmployeePersonDemographicsComments              = cssp.EmployeePersonDemographicsComments,            
        OrderCustomerStoreSalesPersonEmployeePersonrowguid                       = cssp.EmployeePersonrowguid,                        
        OrderCustomerStoreSalesPersonEmployeePersonModifiedDate                  = cssp.EmployeePersonModifiedDate,                    

        OrderCustomerStoreSalesPersonTerritoryID                                 = cssp.TerritoryID,                                    
        OrderCustomerStoreSalesPersonSalesTerritoryName                          = cssp.SalesTerritoryName,                            
        OrderCustomerStoreSalesPersonSalesTerritoryCountryCode                   = cssp.SalesTerritoryCountryCode,                     
        OrderCustomerStoreSalesPersonSalesTerritoryGroup                         = cssp.SalesTerritoryGroup,                           
        OrderCustomerStoreSalesPersonSalesTerritorySalesYTD                      = cssp.SalesTerritorySalesYTD,                        
        OrderCustomerStoreSalesPersonSalesTerritorySalesLastYear                 = cssp.SalesTerritorySalesLastYear,                   
        OrderCustomerStoreSalesPersonSalesTerritoryCostYTD                       = cssp.SalesTerritoryCostYTD,                         
        OrderCustomerStoreSalesPersonSalesTerritoryCostLastYear                  = cssp.SalesTerritoryCostLastYear,                    
        OrderCustomerStoreSalesPersonSalesTerritoryrowguid                       = cssp.SalesTerritoryrowguid,                         
        OrderCustomerStoreSalesPersonSalesTerritoryModifiedDate                  = cssp.SalesTerritoryModifiedDate,                    
        OrderCustomerStoreSalesPersonSalesTerritoryCountryRegionName             = cssp.SalesTerritoryCountryRegionName,               
        OrderCustomerStoreSalesPersonSalesTerritoryCountryRegionModifiedDate     = cssp.SalesTerritoryCountryRegionModifiedDate,       

        OrderCustomerStoreSalesPersonEmployeePersonBusinessEntityrowguid         = cssp.EmployeePersonBusinessEntityrowguid,            
        OrderCustomerStoreSalesPersonEmployeePersonBusinessEntityModifiedDate    = cssp.EmployeePersonBusinessEntityModifiedDate,    

        OrderCustomerTerritoryID                             = c.TerritoryID,
        OrderCustomerSalesTerritoryName                      = cst.Name,                            
        OrderCustomerSalesTerritoryCountryRegionCode         = cst.CountryRegionCode,                    
        OrderCustomerSalesTerritoryGroup                     = cst.[Group],                            
        OrderCustomerSalesTerritorySalesYTD                  = cst.SalesYTD,                        
        OrderCustomerSalesTerritorySalesLastYear             = cst.SalesLastYear,                    
        OrderCustomerSalesTerritoryCostYTD                   = cst.CostYTD,                        
        OrderCustomerSalesTerritoryCostLastYear              = cst.CostLastYear,                    
        OrderCustomerSalesTerritoryrowguid                   = cst.rowguid,                        
        OrderCustomerSalesTerritoryModifiedDate              = cst.ModifiedDate,                    
        OrderCustomerSalesTerritoryCountryRegionName         = cst.CountryRegionName,                
        OrderCustomerSalesTerritoryCountryRegionModifiedDate = cst.CountryRegionModifiedDate,        

        OrderCustomerPersonID                                = c.PersonID,
        OrderCustomerPersonPersonType                        = cp.PersonType,                    
        OrderCustomerPersonNameStyle                         = cp.NameStyle,                    
        OrderCustomerPersonTitle                             = cp.Title,                        
        OrderCustomerPersonFirstName                         = cp.FirstName,                    
        OrderCustomerPersonMiddleName                        = cp.MiddleName,                    
        OrderCustomerPersonLastName                          = cp.LastName,                    
        OrderCustomerPersonSuffix                            = cp.Suffix,                        
        OrderCustomerPersonEmailPromotion                    = cp.EmailPromotion,                
        OrderCustomerPersonAdditionalContactInfo             = cp.AdditionalContactInfo,        
        OrderCustomerPersonDemographics                      = cp.Demographics,                
        OrderCustomerPersonDemographicsTotalPurchaseYTD      = cp.DemographicsTotalPurchaseYTD,
        OrderCustomerPersonDemographicsDateFirstPurchase     = cp.DemographicsDateFirstPurchase,    
        OrderCustomerPersonDemographicsBirthDate             = cp.DemographicsBirthDate,            
        OrderCustomerPersonDemographicsMaritalStatus         = cp.DemographicsMaritalStatus,        
        OrderCustomerPersonDemographicsYearlyIncome          = cp.DemographicsYearlyIncome,        
        OrderCustomerPersonDemographicsGender                = cp.DemographicsGender,                
        OrderCustomerPersonDemographicsTotalChildren         = cp.DemographicsTotalChildren,        
        OrderCustomerPersonDemographicsNumberChildrenAtHome  = cp.DemographicsNumberChildrenAtHome,
        OrderCustomerPersonDemographicsEducation             = cp.DemographicsEducation,            
        OrderCustomerPersonDemographicsOccupation            = cp.DemographicsOccupation,            
        OrderCustomerPersonDemographicsHomeOwnerFlag         = cp.DemographicsHomeOwnerFlag,        
        OrderCustomerPersonDemographicsNumberCarsOwned       = cp.DemographicsNumberCarsOwned,        
        OrderCustomerPersonDemographicsHobby                 = cp.DemographicsHobby,                
        OrderCustomerPersonDemographicsCommuteDistance       = cp.DemographicsCommuteDistance,        
        OrderCustomerPersonDemographicsComments              = cp.DemographicsComments,            
        OrderCustomerPersonrowguid                           = cp.rowguid,                        
        OrderCustomerPersonModifiedDate                      = cp.ModifiedDate,                
        
        OrderCustomerPersonBusinessEntityrowguid             = cp.BusinessEntityrowguid,        
        OrderCustomerPersonBusinessEntityModifiedDate        = cp.BusinessEntityModifiedDate,

        OrderSalesPersonID                                  = soh.SalesPersonID,
        OrderSalesPersonSalesQuota                          = sohsp.SalesQuota,                                
        OrderSalesPersonBonus                               = sohsp.Bonus,                                    
        OrderSalesPersonCommissionPct                       = sohsp.CommissionPct,                            
        OrderSalesPersonSalesYTD                            = sohsp.SalesYTD,                                
        OrderSalesPersonSalesLastYear                       = sohsp.SalesLastYear,                            
        OrderSalesPersonrowguid                             = sohsp.rowguid,                                    
        OrderSalesPersonModifiedDate                        = sohsp.ModifiedDate,                            
        
        OrderSalesPersonEmployeeNationalIDNumber            = sohsp.EmployeeNationalIDNumber,                
        OrderSalesPersonEmployeeLoginID                     = sohsp.EmployeeLoginID,                        
        OrderSalesPersonEmployeeOrganizationNode            = sohsp.EmployeeOrganizationNode,                
        OrderSalesPersonEmployeeOrganizationLevel           = sohsp.EmployeeOrganizationLevel,                
        OrderSalesPersonEmployeeJobTitle                    = sohsp.EmployeeJobTitle,                        
        OrderSalesPersonEmployeeBirthDate                   = sohsp.EmployeeBirthDate,                        
        OrderSalesPersonEmployeeMaritalStatus               = sohsp.EmployeeMaritalStatus,                    
        OrderSalesPersonEmployeeGender                      = sohsp.EmployeeGender,                            
        OrderSalesPersonEmployeeHireDate                    = sohsp.EmployeeHireDate,                        
        OrderSalesPersonEmployeeSalariedFlag                = sohsp.EmployeeSalariedFlag,                    
        OrderSalesPersonEmployeeVacationHours               = sohsp.EmployeeVacationHours,                    
        OrderSalesPersonEmployeeSickLeaveHours              = sohsp.EmployeeSickLeaveHours,                    
        OrderSalesPersonEmployeeCurrentFlag                 = sohsp.EmployeeCurrentFlag,                        
        OrderSalesPersonEmployeerowguid                     = sohsp.Employeerowguid,                            
        OrderSalesPersonEmployeeModifiedDate                = sohsp.EmployeeModifiedDate,                    
        
        OrderSalesPersonEmployeePersonPersonType                        = sohsp.EmployeePersonPersonType,                
        OrderSalesPersonEmployeePersonNameStyle                         = sohsp.EmployeePersonNameStyle,                    
        OrderSalesPersonEmployeePersonTitle                             = sohsp.EmployeePersonTitle,                        
        OrderSalesPersonEmployeePersonFirstName                         = sohsp.EmployeePersonFirstName,                    
        OrderSalesPersonEmployeePersonMiddleName                        = sohsp.EmployeePersonMiddleName,                
        OrderSalesPersonEmployeePersonLastName                          = sohsp.EmployeePersonLastName,                    
        OrderSalesPersonEmployeePersonSuffix                            = sohsp.EmployeePersonSuffix,                    
        OrderSalesPersonEmployeePersonEmailPromotion                    = sohsp.EmployeePersonEmailPromotion,            
        OrderSalesPersonEmployeePersonAdditionalContactInfo             = sohsp.EmployeePersonAdditionalContactInfo,        
        OrderSalesPersonEmployeePersonDemographics                      = sohsp.EmployeePersonDemographics,
        OrderSalesPersonEmployeePersonDemographicsTotalPurchaseYTD      = sohsp.EmployeePersonDemographicsTotalPurchaseYTD,
        OrderSalesPersonEmployeePersonDemographicsDateFirstPurchase     = sohsp.EmployeePersonDemographicsDateFirstPurchase,    
        OrderSalesPersonEmployeePersonDemographicsBirthDate             = sohsp.EmployeePersonDemographicsBirthDate,            
        OrderSalesPersonEmployeePersonDemographicsMaritalStatus         = sohsp.EmployeePersonDemographicsMaritalStatus,        
        OrderSalesPersonEmployeePersonDemographicsYearlyIncome          = sohsp.EmployeePersonDemographicsYearlyIncome,        
        OrderSalesPersonEmployeePersonDemographicsGender                = sohsp.EmployeePersonDemographicsGender,                
        OrderSalesPersonEmployeePersonDemographicsTotalChildren         = sohsp.EmployeePersonDemographicsTotalChildren,        
        OrderSalesPersonEmployeePersonDemographicsNumberChildrenAtHome  = sohsp.EmployeePersonDemographicsNumberChildrenAtHome,
        OrderSalesPersonEmployeePersonDemographicsEducation             = sohsp.EmployeePersonDemographicsEducation,            
        OrderSalesPersonEmployeePersonDemographicsOccupation            = sohsp.EmployeePersonDemographicsOccupation,            
        OrderSalesPersonEmployeePersonDemographicsHomeOwnerFlag         = sohsp.EmployeePersonDemographicsHomeOwnerFlag,        
        OrderSalesPersonEmployeePersonDemographicsNumberCarsOwned       = sohsp.EmployeePersonDemographicsNumberCarsOwned,        
        OrderSalesPersonEmployeePersonDemographicsHobby                 = sohsp.EmployeePersonDemographicsHobby,                
        OrderSalesPersonEmployeePersonDemographicsCommuteDistance       = sohsp.EmployeePersonDemographicsCommuteDistance,        
        OrderSalesPersonEmployeePersonDemographicsComments              = sohsp.EmployeePersonDemographicsComments,            

        OrderSalesPersonEmployeePersonrowguid                       = sohsp.EmployeePersonrowguid,                    
        OrderSalesPersonEmployeePersonModifiedDate                  = sohsp.EmployeePersonModifiedDate,                
        OrderSalesPersonEmployeePersonBusinessEntityrowguid         = sohsp.EmployeePersonBusinessEntityrowguid,        
        OrderSalesPersonEmployeePersonBusinessEntityModifiedDate    = sohsp.EmployeePersonBusinessEntityModifiedDate,
        
        OrderSalesPersonTerritoryID                                 = sohsp.TerritoryID,                                
        OrderSalesPersonSalesTerritoryName                          = sohsp.SalesTerritoryName,                        
        OrderSalesPersonSalesTerritoryCountryCode                   = sohsp.SalesTerritoryCountryCode,                
        OrderSalesPersonSalesTerritoryGroup                         = sohsp.SalesTerritoryGroup,                        
        OrderSalesPersonSalesTerritorySalesYTD                      = sohsp.SalesTerritorySalesYTD,                    
        OrderSalesPersonSalesTerritorySalesLastYear                 = sohsp.SalesTerritorySalesLastYear,                
        OrderSalesPersonSalesTerritoryCostYTD                       = sohsp.SalesTerritoryCostYTD,                    
        OrderSalesPersonSalesTerritoryCostLastYear                  = sohsp.SalesTerritoryCostLastYear,                
        OrderSalesPersonSalesTerritoryrowguid                       = sohsp.SalesTerritoryrowguid,                    
        OrderSalesPersonSalesTerritoryModifiedDate                  = sohsp.SalesTerritoryModifiedDate,                
        OrderSalesPersonSalesTerritoryCountryRegionName             = sohsp.SalesTerritoryCountryRegionName,        
        OrderSalesPersonSalesTerritoryCountryRegionModifiedDate     = sohsp.SalesTerritoryCountryRegionModifiedDate,    

        OrderTerritoryid                                            = soh.TerritoryID,
        OrderSalesTerritoryName                                     = sohst.Name,                        
        OrderSalesTerritoryCountryRegionCode                        = sohst.CountryRegionCode,            
        OrderSalesTerritoryGroup                                    = sohst.[Group],                        
        OrderSalesTerritorySalesYTD                                 = sohst.SalesYTD,                    
        OrderSalesTerritorySalesLastYear                            = sohst.SalesLastYear,                
        OrderSalesTerritoryCostYTD                                  = sohst.CostYTD,                        
        OrderSalesTerritoryCostLastYear                             = sohst.CostLastYear,                
        OrderSalesTerritoryrowguid                                  = sohst.rowguid,                        
        OrderSalesTerritoryModifiedDate                             = sohst.ModifiedDate,                
        OrderSalesTerritoryCountryRegionName                        = sohst.CountryRegionName,            
        OrderSalesTerritoryCountryRegionModifiedDate                = sohst.CountryRegionModifiedDate,

        OrderBillToAddressID                                                     = soh.BillToAddressID,
        OrderBillToAddressAddressLine1                                           = bta.AddressLine1,                                            
        OrderBillToAddressAddressLine2                                           = bta.AddressLine2,                                            
        OrderBillToAddressCity                                                   = bta.City,                                                    
        OrderBillToAddressStateProvinceID                                        = bta.StateProvinceID,                                            
        OrderBillToAddressPostalCode                                             = bta.PostalCode,                                                
        OrderBillToAddressSpatialLocation                                        = bta.SpatialLocation,                                            
        OrderBillToAddressrowguid                                                = bta.rowguid,                                                    
        OrderBillToAddressModifiedDate                                           = bta.ModifiedDate,                                            
        OrderBillToAddressStateProvinceStateProvinceCode                         = bta.StateProvinceStateProvinceCode,                            
        OrderBillToAddressStateProvinceCountryRegionCode                         = bta.StateProvinceCountryRegionCode,                            
        OrderBillToAddressStateProvinceIsOnlyStateProvinceFlag                   = bta.StateProvinceIsOnlyStateProvinceFlag,                    
        OrderBillToAddressStateProvinceName                                      = bta.StateProvinceName,                                        
        OrderBillToAddressStateProvinceTerritoryId                               = bta.StateProvinceTerritoryId,                                
        OrderBillToAddressStateProvincerowguid                                   = bta.StateProvincerowguid,                                    
        OrderBillToAddressStateProvinceModifiedDate                              = bta.StateProvinceModifiedDate,                                
        OrderBillToAddressStateProvinceCountryRegionName                         = bta.StateProvinceCountryRegionName,                            
        OrderBillToAddressStateProvinceCountryRegionModifiedDate                 = bta.StateProvinceCountryRegionModifiedDate,                    
        OrderBillToAddressStateProvinceSalesTerritoryName                        = bta.StateProvinceSalesTerritoryName,                            
        OrderBillToAddressStateProvinceSalesTerritoryCountryRegionCode           = bta.StateProvinceSalesTerritoryCountryRegionCode,            
        OrderBillToAddressStateProvinceSalesTerritoryGroup                       = bta.StateProvinceSalesTerritoryGroup,                        
        OrderBillToAddressStateProvinceSalesTerritorySalesYTD                    = bta.StateProvinceSalesTerritorySalesYTD,                        
        OrderBillToAddressStateProvinceSalesTerritorySalesLastYear               = bta.StateProvinceSalesTerritorySalesLastYear,                
        OrderBillToAddressStateProvinceSalesTerritoryCostYTD                     = bta.StateProvinceSalesTerritoryCostYTD,                        
        OrderBillToAddressStateProvinceSalesTerritoryCostLastYear                = bta.StateProvinceSalesTerritoryCostLastYear,                    
        OrderBillToAddressStateProvinceSalesTerritoryrowguid                     = bta.StateProvinceSalesTerritoryrowguid,                        
        OrderBillToAddressStateProvinceSalesTerritoryModifiedDate                = bta.StateProvinceSalesTerritoryModifiedDate,                    
        OrderBillToAddressStateProvinceSalesTerritoryCountryRegionName           = bta.StateProvinceSalesTerritoryCountryRegionName,            
        OrderBillToAddressStateProvinceSalesTerritoryCountryRegionModifiedDate   = bta.StateProvinceSalesTerritoryCountryRegionModifiedDate,

        OrderShipToAddressID                                                     = soh.ShipToAddressID,
        OrderShipToAddressAddressLine1                                           = sta.AddressLine1,                                            
        OrderShipToAddressAddressLine2                                           = sta.AddressLine2,                                            
        OrderShipToAddressCity                                                   = sta.City,                                                    
        OrderShipToAddressStateProvinceID                                        = sta.StateProvinceID,                                            
        OrderShipToAddressPostalCode                                             = sta.PostalCode,                                                
        OrderShipToAddressSpatialLocation                                        = sta.SpatialLocation,                                            
        OrderShipToAddressrowguid                                                = sta.rowguid,                                                    
        OrderShipToAddressModifiedDate                                           = sta.ModifiedDate,                                            
        OrderShipToAddressStateProvinceStateProvinceCode                         = sta.StateProvinceStateProvinceCode,                            
        OrderShipToAddressStateProvinceCountryRegionCode                         = sta.StateProvinceCountryRegionCode,                            
        OrderShipToAddressStateProvinceIsOnlyStateProvinceFlag                   = sta.StateProvinceIsOnlyStateProvinceFlag,                    
        OrderShipToAddressStateProvinceName                                      = sta.StateProvinceName,                                        
        OrderShipToAddressStateProvinceTerritoryId                               = sta.StateProvinceTerritoryId,                                
        OrderShipToAddressStateProvincerowguid                                   = sta.StateProvincerowguid,                                    
        OrderShipToAddressStateProvinceModifiedDate                              = sta.StateProvinceModifiedDate,                                
        OrderShipToAddressStateProvinceCountryRegionName                         = sta.StateProvinceCountryRegionName,                            
        OrderShipToAddressStateProvinceCountryRegionModifiedDate                 = sta.StateProvinceCountryRegionModifiedDate,                    
        OrderShipToAddressStateProvinceSalesTerritoryName                        = sta.StateProvinceSalesTerritoryName,                            
        OrderShipToAddressStateProvinceSalesTerritoryCountryRegionCode           = sta.StateProvinceSalesTerritoryCountryRegionCode,            
        OrderShipToAddressStateProvinceSalesTerritoryGroup                       = sta.StateProvinceSalesTerritoryGroup,                        
        OrderShipToAddressStateProvinceSalesTerritorySalesYTD                    = sta.StateProvinceSalesTerritorySalesYTD,                        
        OrderShipToAddressStateProvinceSalesTerritorySalesLastYear               = sta.StateProvinceSalesTerritorySalesLastYear,                
        OrderShipToAddressStateProvinceSalesTerritoryCostYTD                     = sta.StateProvinceSalesTerritoryCostYTD,                        
        OrderShipToAddressStateProvinceSalesTerritoryCostLastYear                = sta.StateProvinceSalesTerritoryCostLastYear,                    
        OrderShipToAddressStateProvinceSalesTerritoryrowguid                     = sta.StateProvinceSalesTerritoryrowguid,                        
        OrderShipToAddressStateProvinceSalesTerritoryModifiedDate                = sta.StateProvinceSalesTerritoryModifiedDate,                    
        OrderShipToAddressStateProvinceSalesTerritoryCountryRegionName           = sta.StateProvinceSalesTerritoryCountryRegionName,            
        OrderShipToAddressStateProvinceSalesTerritoryCountryRegionModifiedDate   = sta.StateProvinceSalesTerritoryCountryRegionModifiedDate,

        OrderShipMethodID                    = soh.ShipMethodID,
        OrderShipMethodName                  = sohsm.Name,
        OrderShipMethodShipBase              = sohsm.ShipBase,
        OrderShipMethodShipRate              = sohsm.ShipRate,
        OrderShipMethodrowguid               = sohsm.rowguid,
        OrderShipMethodModifiedDate          = sohsm.ModifiedDate,

        OrderCreditCardID                    = soh.CreditCardID,
        OrderCreditCardCardType              = sohsc.CardType,
        OrderCreditCardCardNumber            = sohsc.CardNumber,
        OrderCreditCardExpMonth              = sohsc.ExpMonth,
        OrderCreditCardExpYear               = sohsc.ExpYear,
        OrderCreditCardModifiedDate          = sohsc.ModifiedDate,

        OrderCurrencyRateID                  = soh.CurrencyRateID,
        OrderCurrencyRateCurrencyRateDate    = sohcr.CurrencyRateDate,
        OrderCurrencyRateFromCurrencyCode    = sohcr.FromCurrencyCode,
        OrderCurrencyRateToCurrencyCode      = sohcr.ToCurrencyCode,
        OrderCurrencyRateAverageRate         = sohcr.AverageRate,
        OrderCurrencyRateEndOfDayRate        = sohcr.EndOfDayRate,
        OrderCurrencyRateModifiedDate        = sohcr.ModifiedDate,

        OrderFromCurrencyName                = sohcrcfrom.Name,
        OrderFromCurrencyModifiedDate        = sohcrcfrom.ModifiedDate,

        OrderToCurrencyName                  = sohcrcto.Name,
        OrderToCurrencyModifiedDate          = sohcrcto.ModifiedDate

FROM Sales.SalesOrderDetail AS sod
LEFT JOIN SpecialOfferProductAll AS sop -- logically an inner join should be used, but does not eliminate due to compound key
    ON  sop.SpecialOfferID = sod.SpecialOfferID AND
        sop.ProductID = sod.ProductID

LEFT JOIN Sales.SalesOrderHeader AS soh
    ON soh.SalesOrderID = sod.SalesOrderID

    LEFT JOIN Sales.Customer AS c
        ON c.CustomerID = soh.CustomerID
        LEFT JOIN Sales.Store AS cs
            ON cs.BusinessEntityID = c.StoreID
            LEFT JOIN SalesPersonAll AS cssp
                ON cssp.BusinessEntityID = cs.SalesPersonID
        LEFT JOIN SalesTerritoryAll AS cst
            ON cst.TerritoryID = c.TerritoryID
        LEFT JOIN PersonAll AS cp
            ON cp.BusinessEntityID = c.PersonID

    LEFT JOIN SalesPersonAll AS sohsp
        ON sohsp.BusinessEntityID = soh.SalesPersonID
    
    LEFT JOIN SalesTerritoryAll AS sohst
        ON sohst.TerritoryID = soh.TerritoryID

    LEFT JOIN AddressAll AS bta
        ON bta.AddressId = soh.BillToAddressID
    
    LEFT JOIN AddressAll AS sta
        ON sta.AddressId = soh.ShipToAddressID

    LEFT JOIN Purchasing.ShipMethod AS sohsm
        ON sohsm.ShipMethodID = soh.ShipMethodID

    LEFT JOIN Sales.CreditCard AS sohsc
        ON sohsc.CreditCardID = soh.CreditCardID

    LEFT JOIN Sales.CurrencyRate AS sohcr
        ON sohcr.CurrencyRateID = soh.CurrencyRateID
        LEFT JOIN Sales.Currency AS sohcrcfrom
            ON sohcrcfrom.CurrencyCode = sohcr.FromCurrencyCode
        LEFT JOIN Sales.Currency AS sohcrcto
            ON sohcrcto.CurrencyCode = sohcr.ToCurrencyCode

GO


