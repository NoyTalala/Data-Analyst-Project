# Data-Analyst-Project
## By noy

  ## Examples for messages:
         A query showing the purchase amount in the most expensive order each year and to which customers these orders belong
   ## Example of message sending ack answer:

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


 ##picture

<img width="796" alt="צילום מסך 2022-10-22 224616" src="https://user-images.githubusercontent.com/111419453/197361046-45ee85b6-f1e3-4a3a-ae87-74b1f6209660.png">

