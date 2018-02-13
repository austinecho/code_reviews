
SET STATISTICS IO ON

BEGIN
  SET NOCOUNT ON;

    DECLARE @lastRan DATETIME;
    DECLARE @numChanges int;

    -- Get Last Ran date
    SELECT TOP 1 @lastRan = LastRan FROM EchoOptimizer.SearchEngine.WarehouseActivityLog ORDER BY LastRan DESC;
    SET @lastRan = '3/15/2017';

	 SELECT * into #WarehouseChanges from(
        SELECT
          cw.Id as ClientWarehouseId,
          cw.MasterWarehouseId, 
          cw.Name,
          ta.Address1,
          ta.Address2,
          ta.Address3,
          ta.City,
          ts.StateCode as State,
          ta.Zip,
          tc.CountryName as Country,
          cw.CreatedDate,
          cw.ModifiedDate,
          cw.AccountId
        FROM EchoOptimizer.Warehouse.ClientWarehouse cw  WITH (NOLOCK)
          INNER JOIN EchoOptimizer.Warehouse.MasterWarehouse mw  WITH (NOLOCK) on mw.Id = cw.MasterWarehouseId
          INNER JOIN EchoOptimizer.dbo.tblAddress ta  WITH (NOLOCK) on ta.AddressId = mw.AddressId
          INNER JOIN EchoOptimizer.dbo.tblStates ts  WITH (NOLOCK) on ts.StateId = ta.StateId
          INNER JOIN EchoOptimizer.dbo.tblCountry tc  WITH (NOLOCK) on tc.CountryId = ta.CountryId
        WHERE cw.ModifiedDate >= @lastRan
          OR mw.ModifiedDate >= @lastRan) as warehouseChanges

    SELECT @numChanges = @@ROWCOUNT;

    -- insert all unmatched records in WarehouseActivity
    INSERT INTO EchoOptimizer.SearchEngine.WarehouseActivity (
      ClientWarehouseId,
      MasterWarehouseId,
      Name,
      Address1,
      Address2,
      Address3,
      City,
      [State],
      Zip,
      Country,
      CreatedDate,
      ModifiedDate,
      AccountId)
    SELECT
      wc.ClientWarehouseId,
      wc.MasterWarehouseId, 
      wc.Name,
      wc.Address1,
      wc.Address2,
      wc.Address3,
      wc.City,
      wc.[State],
      wc.Zip,
      wc.Country,
      wc.CreatedDate,
      wc.ModifiedDate,
      wc.AccountId
    FROM #WarehouseChanges wc  WITH (NOLOCK)
      LEFT JOIN SearchEngine.WarehouseActivity wa  WITH (NOLOCK) on wc.ClientWarehouseId = wa.ClientWarehouseId
    WHERE wa.ClientWarehouseId is null;

    -- UPDATE all matched records in WarehouseActivity
    UPDATE SearchEngine.WarehouseActivity SET 
      ClientWarehouseId = wc.ClientWarehouseId,
      MasterWarehouseId = wc.MasterWarehouseId,
      Name = wc.Name,
      Address1 = wc.Address1,
      Address2 = wc.Address2,
      Address3 = wc.Address3,
      City = wc.City,
      [State] = wc.[State],
      Zip = wc.Zip,
      Country = wc.Country,
      CreatedDate = wc.CreatedDate,
      ModifiedDate = wc.ModifiedDate,
      AccountId =wc.AccountId
    FROM #WarehouseChanges wc  WITH (NOLOCK)
      INNER JOIN SearchEngine.WarehouseActivity wa  WITH (NOLOCK) on wc.ClientWarehouseId = wa.ClientWarehouseId
    WHERE BINARY_CHECKSUM(wc.Name, wc.Address1, wc.Address2, wc.Address3, wc.City, wc.[State], wc.Zip, wc.Country, wc.AccountId) 
      != BINARY_CHECKSUM(wa.Name, wa.Address1, wa.Address2, wa.Address3, wa.City, wa.[State], wa.Zip, wa.Country, wa.AccountId);

    -- Drop Temp Tables
     IF OBJECT_ID('tempdb..#WarehouseChanges') IS NOT NULL DROP TABLE #WarehouseChanges

    -- Add Details to log
    INSERT INTO EchoOptimizer.SearchEngine.WarehouseActivityLog (Count, LastRan)
    VALUES(@numChanges, GETDATE());
END

