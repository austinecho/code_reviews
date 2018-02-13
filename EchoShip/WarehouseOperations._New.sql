
--===================================================================================================
-- Created by:
-- Created date:
-- Purpose:
--===================================================================================================

CREATE PROCEDURE [SearchEngine].[WarehouseOperations] AS

BEGIN
SET XACT_ABORT ON; 
SET NOCOUNT ON;

BEGIN TRY 
BEGIN TRANSACTION 

--BEGIN


DECLARE @lastRan DATETIME;
DECLARE @numChanges INT;

    -- Get Last Ran date
SELECT TOP 1
        @lastRan = LastRan
FROM    EchoOptimizer.SearchEngine.WarehouseActivityLog WITH(NOLOCK)
ORDER BY LastRan DESC;
    SET @lastRan = COALESCE(@lastRan, '1/1/1753');


    -- Add needed warehouses into #Warehouse
SELECT  CW.Id ,
        CW.MasterWarehouseId
INTO    #Warehouse
FROM    Warehouse.ClientWarehouse AS CW WITH(NOLOCK)
WHERE   CW.ModifiedDate >= @lastRan;
     
	 -- Copy warehouse activity into #WarehouseChanges
SELECT  cw.Id AS ClientWarehouseId ,
        cw.MasterWarehouseId ,
        cw.Name ,
        ta.Address1 ,
        ta.Address2 ,
        ta.Address3 ,
        ta.City ,
        ts.StateCode AS State ,
        ta.Zip ,
        tc.CountryName AS Country ,
        cw.CreatedDate ,
        cw.ModifiedDate ,
        cw.AccountId
INTO    #WarehouseChanges
FROM    #Warehouse AS w
        INNER JOIN EchoOptimizer.Warehouse.ClientWarehouse cw WITH ( NOLOCK ) 
		ON w.Id = cw.Id
        INNER JOIN EchoOptimizer.Warehouse.MasterWarehouse mw WITH ( NOLOCK ) 
		ON w.MasterWarehouseId = mw.Id
        INNER JOIN EchoOptimizer.dbo.tblAddress ta WITH ( NOLOCK ) 
		ON ta.AddressId = mw.AddressId
        INNER JOIN EchoOptimizer.dbo.tblStates ts WITH ( NOLOCK ) 
		ON ts.StateID = ta.StateId
        INNER JOIN EchoOptimizer.dbo.tblCountry tc WITH ( NOLOCK ) 
		ON tc.CountryId = ta.CountryId;

SELECT  @numChanges = @@ROWCOUNT;


    -- insert all unmatched records in WarehouseActivity
INSERT  INTO EchoOptimizer.SearchEngine.WarehouseActivity
        ( ClientWarehouseId ,
          MasterWarehouseId ,
          Name ,
          Address1 ,
          Address2 ,
          Address3 ,
          City ,
          [State] ,
          Zip ,
          Country ,
          CreatedDate ,
          ModifiedDate ,
          AccountId
        )
        SELECT  wc.ClientWarehouseId ,
                wc.MasterWarehouseId ,
                wc.Name ,
                wc.Address1 ,
                wc.Address2 ,
                wc.Address3 ,
                wc.City ,
                wc.[State] ,
                wc.Zip ,
                wc.Country ,
                wc.CreatedDate ,
                wc.ModifiedDate ,
                wc.AccountId
        FROM    #WarehouseChanges wc WITH ( NOLOCK )
                LEFT JOIN SearchEngine.WarehouseActivity wa WITH ( NOLOCK ) 
				ON wc.ClientWarehouseId = wa.ClientWarehouseId
        WHERE   wa.ClientWarehouseId IS NULL;


   			-- Gets checksum of existing warehouse in SearchEngine.WarehouseActivity
			
WITH    CTE_ChecksumWarehouse
          AS ( SELECT   W.Id ,
                        BINARY_CHECKSUM(WA.Name, WA.Address1, WA.Address2,
                                        WA.Address3, WA.City, WA.[State],
                                        WA.Zip, WA.Country, WA.AccountId) AS wChecksum
               FROM     #Warehouse AS W
                        INNER JOIN SearchEngine.WarehouseActivity AS WA WITH(NOLOCK) 
						ON W.Id = WA.ClientWarehouseId
             )
			 
			 -- Gets checksum of Warehouses that changed
		          ,
        CTE_ChecksumTempWarehouse
          AS ( SELECT   WC.ClientWarehouseId ,
                        BINARY_CHECKSUM(WC.Name, WC.Address1, WC.Address2,
                                        WC.Address3, WC.City, WC.[State],
                                        WC.Zip, WC.Country, WC.AccountId) AS tChecksum
               FROM     #WarehouseChanges AS WC
             )
			 
			 -- Compare checksums
		    ,
        CTE_ChangedWarehouse
          AS ( SELECT   a.ClientWarehouseId
               FROM     CTE_ChecksumTempWarehouse AS a
                        INNER JOIN CTE_ChecksumWarehouse AS b 
						ON a.ClientWarehouseId = b.Id
               WHERE    a.tChecksum <> b.wChecksum
             )
    -- UPDATE all matched records in WarehouseActivity

		   UPDATE   SearchEngine.WarehouseActivity
           SET      -- ClientWarehouseId = wc.ClientWarehouseId,
                    MasterWarehouseId = wc.MasterWarehouseId ,
                    Name = wc.Name ,
                    Address1 = wc.Address1 ,
                    Address2 = wc.Address2 ,
                    Address3 = wc.Address3 ,
                    City = wc.City ,
                    [State] = wc.[State] ,
                    Zip = wc.Zip ,
                    Country = wc.Country ,
    --  CreatedDate = wc.CreatedDate,
                    ModifiedDate = wc.ModifiedDate
    --  AccountId =wc.AccountId
           FROM     CTE_ChangedWarehouse a
                    INNER JOIN #WarehouseChanges AS wc 
					ON a.ClientWarehouseId = wc.ClientWarehouseId
                    INNER JOIN SearchEngine.WarehouseActivity AS WA 
					ON wc.ClientWarehouseId = WA.ClientWarehouseId;



    -- Drop Temp Tables
IF OBJECT_ID('tempdb..#WarehouseChanges') IS NOT NULL
    DROP TABLE #WarehouseChanges;
IF OBJECT_ID('tempdb..#Warehouse') IS NOT NULL
    DROP TABLE #Warehouse;
  --   Add Details to log
INSERT  INTO EchoOptimizer.SearchEngine.WarehouseActivityLog
        ( Count ,
          LastRan ,
          IsPickedByWindowsService
        ) -- isPickedByWindowsService was missing
VALUES  ( @numChanges ,
          GETDATE() ,
          0 -- 0 or 1 I don't know what goes here
	    );

COMMIT TRANSACTION
END TRY
		
BEGIN CATCH
    SELECT  ERROR_NUMBER() AS ErrorNumber ,
            ERROR_SEVERITY() AS ErrorSeverity ,
            ERROR_STATE() AS ErrorState ,
            ERROR_PROCEDURE() AS ErrorProcedure ,
            ERROR_LINE() AS ErrorLine ,
            ERROR_MESSAGE() AS ErrorMessage;

    ROLLBACK TRANSACTION;
END CATCH;
END
