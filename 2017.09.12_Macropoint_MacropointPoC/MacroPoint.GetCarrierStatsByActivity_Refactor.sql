USE EchoOptimizer

SET STATISTICS IO ON

EXEC [Macropoint].[GetCarrierStatsByActivity] 


DECLARE @TypeId INT = 1300, 
 @SubTypeIDS NVARCHAR(2000) ='28,34', 
 @FromDate DATE ='2017/01/01'


	SELECT 
		COUNT(1) Instances,
		(select l.loadactivitytypename FROM dbo.tblLoadActivityType l WHERE l.LoadActivityTypeId =  a.typeid) ActivityName, 
		(SELECT s.subtypename FROM dbo.tblLoadActivitySubType s WHERE  s.LoadActivitySubTypeId = a.subtypeid ) SubTypeName
	FROM dbo.tblLoadActivityLog a 
	INNER JOIN dbo.fn_SplitStrings(@SubTypeIDS,',') AS SubTypes ON a.SubTypeId = CAST(SubTypes.Item AS INT)
             AND a.CreatedDate > ISNULL(@FromDate,GETDATE() -30)
             AND a.TypeId = @TypeID
GROUP BY 
       a.typeid,
       a.subtypeid


--======================================
-- Rework
--======================================
GO

DECLARE @SubTypeIDS NVARCHAR(2000) ='28,34',@FromDate DATE ='2017/01/01', @TypeId INT = 1300


SELECT COUNT(1) AS Instances, AT.LoadActivityTypeName, ST.SubTypeName
FROM dbo.tblLoadActivityLog AS A
INNER JOIN dbo.fn_SplitStrings(@SubTypeIDS,',') AS SubTypes 
ON a.SubTypeId = CAST(SubTypes.Item AS INT)
LEFT JOIN dbo.tblLoadActivitySubType AS ST
ON A.SubTypeId = ST.LoadActivitySubTypeId
LEFT JOIN dbo.tblLoadActivityType AS AT
ON A.TypeId = AT.LoadActivityTypeId
WHERE a.CreatedDate > ISNULL(@FromDate,GETDATE() -30)
AND a.TypeId = @TypeID
GROUP BY AT.LoadActivityTypeName, ST.SubTypeName




SELECT DISTINCT TOP 10 a.SubTypeId--COUNT(1) AS Instances, AT.LoadActivityTypeName, ST.SubTypeName
FROM dbo.tblLoadActivityLog AS a
LEFT JOIN dbo.tblLoadActivitySubType AS ST
ON a.SubTypeId = ST.LoadActivitySubTypeId
LEFT JOIN dbo.tblLoadActivityType AS AT
ON A.TypeId = AT.LoadActivityTypeId
WHERE a.SubTypeId IS NOT NULL 
GROUP BY a.TypeId, a.SubTypeId, AT.LoadActivityTypeName, ST.SubTypeName


DECLARE @Mode VARCHAR(255) = '1200,2000', 
	@Delimiter CHAR(1) = ',' ;
 SELECT [Item]
 FROM dbo.fn_SplitStrings (@Mode, @Delimiter) ;