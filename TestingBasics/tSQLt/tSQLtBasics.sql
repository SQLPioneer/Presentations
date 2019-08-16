
-- Create a test class (schema) to hold all related tests
EXEC tSQLt.NewTestClass @ClassName = 'Adams Test Class'

GO

-- Create a basic Test
CREATE OR ALTER PROCEDURE [Adams Test Class].[test basics]
as 
BEGIN
    -- Assemble 
    
    -- Act
    select 'Basic Test' column1 into #actual
    select 'Basic Test' column1 into #expected
    -- Assert
    EXEC tSQLt.assertEqualsTable '#actual', '#expected'
END
GO

-- Create a basic Test
CREATE OR ALTER PROCEDURE [Adams Test Class].[test failure]
as 
BEGIN
    -- Assemble 
    
    -- Act
    select 'Basic Test Failed' column1 into #actual
    select 'Basic Test' column1 into #expected
    -- Assert
    EXEC tSQLt.assertEqualsTable '#actual', '#expected'
END
GO

-- Run All tests in the Class
exec tSQLt.Run @TestName = 'Adams Test Class'
-- Run Only 1 test in the class if the full name is specified
exec tSQLt.Run @TestName = 'Adams Test Class.test basics'
-- Run test class specifing XML output
exec tSQLt.Run 
      @TestName = 'Adams Test Class.test basics'
    , @TestResultFormatter ='tSQLt.XmlResultFormatter'

exec tSQLt.RunAll
      @TestName = 'ufnGetAccountingEndDateTests'
    , @TestResultFormatter ='tSQLt.XmlResultFormatter'

GO




exec tsqlt.NewTestClass @ClassName ='ufnGetProductListPrice'

GO
-- Add a test for the ufnGetProductListPrice class
CREATE or ALTER  	PROCEDURE [ufnGetProductListPrice].[test function returns the correct result]
AS
BEGIN

    BEGIN TRANSACTION

    DECLARE @actual MONEY;
    
    ALTER TABLE [Production].[Product] DROP CONSTRAINT [FK_Product_ProductModel_ProductModelID]
    ALTER TABLE [Production].[Product] DROP CONSTRAINT [FK_Product_ProductSubcategory_ProductSubcategoryID]
    -- ALTER TABLE [Production].[Product] DROP CONSTRAINT [FK_Product_UnitMeasure_SizeUnitMeasureCode]
    ALTER TABLE [Production].[Product] DROP CONSTRAINT [FK_Product_UnitMeasure_WeightUnitMeasureCode]
    ALTER TABLE [Sales].[SpecialOfferProduct] DROP CONSTRAINT [FK_SpecialOfferProduct_Product_ProductID]
    ALTER TABLE [Sales].[ShoppingCartItem] DROP CONSTRAINT [FK_ShoppingCartItem_Product_ProductID]
    ALTER TABLE [Purchasing].[ProductVendor] DROP CONSTRAINT [FK_ProductVendor_Product_ProductID]
    ALTER TABLE [Production].[ProductReview] DROP CONSTRAINT [FK_ProductReview_Product_ProductID]
    ALTER TABLE [Production].[ProductProductPhoto] DROP CONSTRAINT [FK_ProductProductPhoto_Product_ProductID]

    EXEC tsqlt.FakeTable @TableName = 'Production.Product'--, @IDENTITY = 0
    -- EXEC tsqlt.FakeTable 'Production', 'ProductListPriceHistory'
    ROLLBACK TRANSACTION
    
    INSERT INTO Production.Product (ProductID) VALUES('1000')

    INSERT INTO Production.ProductListPriceHistory (ProductID, ListPrice, StartDate, EndDate) VALUES(1000, 100, 2019-08-1, 2019-09-1)

    SELECT @actual = dbo.ufnGetProductListPrice(1000, '2019-08-16');
  SELECT dbo.ufnGetProductListPrice(1000, '2019-08-16');
    DECLARE @expected MONEY;
    SET @expected = '100';
    EXEC tSQLt.AssertEquals @expected, @actual;


END;

GO
SELECT * FROM tSQLt.TestResult

