---Project 2---

1.

SELECT     PP.ProductID
          ,PP.Name
	      ,PP.Color
	      ,PP.ListPrice
	      ,PP.Size
FROM      Production.Product  PP 
          LEFT JOIN Sales.SalesOrderDetail SOD 
		  ON PP.ProductID = SOD.ProductID
WHERE     SOD.SalesOrderDetailID IS NULL


update sales.customer set personid=customerid       where customerid <=290 
update sales.customer set personid=customerid+1700     where customerid >= 300 and customerid<=350 
update sales.customer set personid=customerid+1700     where customerid >= 352 and customerid<=701


2.
SELECT     C.CustomerID
          ,ISNULL(PP.LastName,'Unknown') AS'LastName'
		  ,ISNULL(PP.FirstName,'Unknown') AS 'FirstName'
FROM       Sales.Customer C 
           LEFT JOIN Sales.SalesOrderHeader OH
           ON C.CustomerID = OH.CustomerID
           LEFT JOIN Person.Person PP
           ON C.PersonID = PP.BusinessEntityID
WHERE      OH.SalesOrderID IS NULL
ORDER BY   C.CustomerID


3.
SELECT TOP 10  C.CustomerID
              ,P.FirstName
			  ,P.LastName 
			  ,COUNT(OH.SalesOrderID) AS 'CountOfOrders'
FROM           Sales.SalesOrderHeader OH 
               JOIN Sales.Customer C
               ON OH.CustomerID = C.CustomerID
               JOIN Person.Person P
               ON C.PersonID = P.BusinessEntityID
GROUP BY       C.CustomerID
              ,P.FirstName
			  ,P.LastName 
ORDER BY       CountOfOrders DESC


4.
SELECT      P.FirstName
           ,P.LastName
	  	   ,E.JobTitle
		   ,E.HireDate
           ,count(*)OVER(PARTITION BY E.JobTitle) as 'CountJobTitle'
FROM        HumanResources.Employee E 
            JOIN Person.Person P
            ON E.BusinessEntityID = P.BusinessEntityID


5.
WITH Tabie1
AS
(
SELECT *
FROM    (SELECT   OH.SalesOrderID
                 ,C.CustomerID
			     ,P.FirstName
			     ,P.LastName
			     ,OH.OrderDate
                 ,ROW_NUMBER()OVER(PARTITION BY C.CustomerID ORDER BY  OH.OrderDate DESC) AS 'ROW_NUMBER'
         FROM     Sales.SalesOrderHeader OH  
		          JOIN Sales.Customer C
                  ON OH.CustomerID = C.CustomerID           
                  JOIN Person.Person P
                  ON C.PersonID = P.BusinessEntityID) C
WHERE C.ROW_NUMBER=1
)
SELECT     Tabie1.SalesOrderID
          ,Tabie1.CustomerID
		  ,Tabie1.LastName
		  ,Tabie1.FirstName
          ,Tabie1.OrderDate AS 'LastOrder' ,Tabie2.OrderDate AS 'PreviousOrder'
FROM    (SELECT *
         FROM   (SELECT    OH.SalesOrderID
                          ,C.CustomerID
				          ,P.FirstName
				          ,P.LastName
				          ,OH.OrderDate 
                          ,ROW_NUMBER()OVER(PARTITION BY C.CustomerID ORDER BY  OH.OrderDate DESC) AS 'ROW_NUMBER'
                 FROM      Sales.SalesOrderHeader OH  
			               JOIN Sales.Customer C
                           ON OH.CustomerID = C.CustomerID           
                           JOIN Person.Person P
                           ON C.PersonID = P.BusinessEntityID) AS C2 
                 WHERE C2.ROW_NUMBER=2)  AS Tabie2 
                                            RIGHT JOIN Tabie1
                                            ON Tabie2.CustomerID = Tabie1.CustomerID
ORDER BY    Tabie1.LastName



6.
WITH TB1
AS
(
SELECT       YEAR(SOH.OrderDate) AS 'Year'
            ,MAX(OD.TopOr) AS 'Total'
FROM    (SELECT    O.SalesOrderID
                  ,SUM(UnitPrice*(1- UnitPriceDiscount)*OrderQty)OVER(PARTITION BY SalesOrderID) AS 'TopOr'
         FROM      Sales.SalesOrderDetail O) OD 
		                                    JOIN Sales.SalesOrderHeader SOH
                                            ON OD.SalesOrderID = SOH.SalesOrderID
GROUP BY     YEAR(SOH.OrderDate)
)
SELECT       T4.Year
            ,T4.LastName
			,T4.FirstName
			,T4.Total
FROM    (SELECT     YEAR(SOH.OrderDate) AS 'Year'
                   ,MAX(OD.SUMOrder) AS 'Total'
				   ,C.PersonID
				   ,P.FirstName
				   ,P.LastName
         FROM      (SELECT      O.SalesOrderID
                               ,SUM(UnitPrice*(1- UnitPriceDiscount)*OrderQty)OVER(PARTITION BY SalesOrderID) AS 'SUMOrder'
                    FROM        Sales.SalesOrderDetail O) AS OD 
			                                              JOIN Sales.SalesOrderHeader SOH
                                                          ON OD.SalesOrderID = SOH.SalesOrderID
                                                          JOIN Sales.Customer C
                                                          ON SOH.CustomerID = C.CustomerID
                                                          JOIN Person.Person P
                                                          ON C.PersonID = P.BusinessEntityID
GROUP BY     YEAR(SOH.OrderDate) 
            ,C.PersonID
			,P.FirstName
			,P.LastName) AS T4
                         JOIN TB1
                         ON T4.Year=TB1.Year
                         AND T4.Total=TB1.Total
ORDER BY YEAR


7.
SELECT        Month
             ,[2011]
			 ,[2012]
			 ,[2013]
			 ,[2014]
FROM         (SELECT     OH.SalesOrderID
                        ,YEAR(OH.OrderDate) 'Year' 
			            ,MONTH(OH.OrderDate) 'Month' 
              FROM       Sales.SalesOrderHeader OH ) AS SOH
PIVOT (COUNT(SOH.SalesOrderID)FOR YEAR in ([2011],[2012],[2013],[2014])) pvt
ORDER BY Month


8.
SELECT          YEAR(OH.OrderDate) AS 'Year'
               ,MONTH(OH.OrderDate) AS 'Month'
               ,SUM(UnitPrice*(1- UnitPriceDiscount)*OrderQty) AS 'TOTAL'
FROM            Sales.SalesOrderHeader OH 
                JOIN Sales.SalesOrderDetail OD
                ON OH.SalesOrderID = OD.SalesOrderID
GROUP BY ROLLUP (YEAR(OH.OrderDate),MONTH(OH.OrderDate))


9.
SELECT*
FROM
(
SELECT         D.Name
              ,E.BusinessEntityID
			  ,P.LastName+' '+P.FirstName AS'FullName'
			  ,E.HireDate
		      ,DATEDIFF(MM,E.HireDate,GETDATE()) AS 'Seniority'
FROM		   Person.Person  P
               JOIN HumanResources.Employee E
               ON P.BusinessEntityID = E.BusinessEntityID
               JOIN HumanResources.EmployeeDepartmentHistory ED
			   ON E.BusinessEntityID = ED.BusinessEntityID
			   JOIN HumanResources.Department D
			   ON ED.DepartmentID = D.DepartmentID
) O
ORDER BY O.Name,Seniority	


10. 
SELECT         ED.StartDate,D.DepartmentID 
              ,STRING_AGG(CONCAT(P.BusinessEntityID,' ',P.LastName,' ',P.FirstName),',') WITHIN GROUP (ORDER BY ED.StartDate) AS Employee_list
FROM		   Person.Person  P
               JOIN HumanResources.Employee E
               ON P.BusinessEntityID = E.BusinessEntityID
               JOIN HumanResources.EmployeeDepartmentHistory ED
			   ON E.BusinessEntityID = ED.BusinessEntityID
			   JOIN HumanResources.Department D
			   ON ED.DepartmentID = D.DepartmentID
GROUP BY       D.DepartmentID,ED.StartDate
 











