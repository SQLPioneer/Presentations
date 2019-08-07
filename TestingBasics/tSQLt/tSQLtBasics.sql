
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

-- Add a failing test to the ufnGetAccountingEndDateTests class
CREATE or ALTER  	PROCEDURE [ufnGetAccountingEndDateTests].[test Show a failing test]
AS
BEGIN
    DECLARE @actual DATETIME;
    SELECT @actual = [dbo].ufnGetAccountingEndDate();
 
    DECLARE @expected DATETIME;
    SET @expected = '2004-06-30 23:59:59:99';
    EXEC tSQLt.AssertEquals @expected, @actual;
END;

GO
SELECT * FROM tSQLt.TestResult

