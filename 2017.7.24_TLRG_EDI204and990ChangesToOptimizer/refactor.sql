SET STATISTICS IO ON

DECLARE @RowCount INT;
EXEC [dbo].[get204ifActive] @LoadGuid = '373B0C2F-AC13-4F07-B688-EF5D13778F7F', -- uniqueidentifier
    @RowCount = @RowCount OUTPUT -- int

GO


DECLARE @RowCount INT;
EXEC dt_test
@LoadGuid = '373B0C2F-AC13-4F07-B688-EF5D13778F7F', -- uniqueidentifier
    @RowCount = @RowCount OUTPUT -- int



ALTER PROCEDURE DT_Test
@LoadGuid uniqueidentifier,
	@RowCount as int OUTPUT
AS
BEGIN

;WITH CTE_LoadTenderID (LoadTenderID) AS 
(
SELECT LoadTenderId
FROM Tender.LoadTender
WHERE IsTimedOut = 0
AND IsDeclined = 0
 AND LoadGuid = @LoadGuid
 ),

 CTE_LoadTender (LoadTenderID, CarrierGuid, LoadGuid, CreatedDate)
 AS
 (
 SELECT LT.LoadTenderId, CarrierGuid, LoadGuid, CreatedDate
 FROM Tender.LoadTender AS LT
 INNER JOIN CTE_LoadTenderID AS LTI
 ON LT.LoadTenderId = LTI.LoadTenderID
 )

 SELECT lt.LoadTenderID
 FROM CTE_LoadTender AS lt
 LEFT OUTER JOIN Tender.LoadTenderResponse ltr ON lt.LoadTenderId = ltr.LoadTenderId
                INNER JOIN dbo.tblCarrierLoads cl ON cl.CarrierGuId = lt.CarrierGuid
                                                     AND cl.LoadGuId = lt.LoadGuid
                                                     AND cl.CreationDate < lt.CreatedDate
	WHERE ltr.LoadTenderResponseId IS NULL
	
SET @RowCount = @@ROWCOUNT

END


