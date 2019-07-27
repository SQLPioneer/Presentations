SELECT BusinessEntityID
FROM [AdventureWorks].[HumanResources].vEmployeeDepartment
group by BusinessEntityID
having count(*) > 1
