Example EchoOptimizer.dbo.CIM_GetProductLineListByCustomerGuid

How to fix key lookup


SELECT ProductLineID
 INTO #Temp
  FROM ProductLines
  WHERE 
	CustomerID='5D04784B-D5AB-458E-9140-88F30A6AA78C' --and RecStatus=0

	SELECT PL.ProductLineID ,
           PL.ProductLineName ,
           PL.ProductLineDescription ,
           PL.CustomerID ,
           PL.CreatedBy ,
           PL.CreatedDate ,
           PL.ModifiedBy ,
           PL.ModifiedDate ,
           PL.RecStatus
	FROM dbo.ProductLines AS PL
	INNER JOIN #Temp AS T1
	ON PL.ProductLineID = T1.ProductLineID