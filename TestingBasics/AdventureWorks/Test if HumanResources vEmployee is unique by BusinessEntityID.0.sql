SELECT BusinessEntityID
FROM [AdventureWorks].[HumanResources].[vEmployee]
group by BusinessEntityID
having count(*) > 1
