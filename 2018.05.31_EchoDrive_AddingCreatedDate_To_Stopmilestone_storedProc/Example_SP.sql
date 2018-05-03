CREATE PROCEDURE [CarrierPortal].[DTTemp_GetLoadStopsActivityLogMilestonesByLoadGuid]
(
	@LoadGuid UNIQUEIDENTIFIER
)
AS
/*
=================================================
Name: [CarrierPortal].[GetLoadStopsActivityLogMilestonesByLoadGuid]
Description: Geat load milestones from activity logs.
Author: Landon Kerwin
Date: 03/14/2018
=================================================
Changeset
Date			Person                  Reason
--------------------------------------------------------------------------
03/14/2018		Landon Kerwin			Created
03/26/2018		Landon Kerwin			Added WarehouseId and TimeZone to query.
04/03/2018		Landon Kerwin			Modified to determine milestone date instead of using create date.
=================================================

--exec [CarrierPortal].GetLoadStopsActivityLogMilestonesByLoadGuid '3641EEAD-F7A9-4E42-A6E4-0A5DA9359E43'
--exec [CarrierPortal].GetLoadStopsActivityLogMilestonesByLoadGuid '7974EE95-A1BD-4D61-B61C-5D179A09CA0D'
--exec [CarrierPortal].GetLoadStopsActivityLogMilestonesByLoadGuid 'afba12e4-0d6b-4f61-bea3-47d131c1d0c6'
--exec [CarrierPortal].GetLoadStopsActivityLogMilestonesByLoadGuid '52899FB0-F120-43B5-832C-1E4A1667202E'
*/

BEGIN

--DECLARE @LoadGuid UNIQUEIDENTIFIER = '52899FB0-F120-43B5-832C-1E4A1667202E'

DECLARE @ThisLoad TABLE
(
	LoadGuid UNIQUEIDENTIFIER,
	LoadId INT,
	BookedDate DATETIME,
	DriverEmptyDate DATETIME
);

SET NOCOUNT ON
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

DECLARE @LoadId INT,
        @CentralTime NVARCHAR(4) = 'CT'

SELECT @LoadId = LoadId
FROM dbo.tblLoads WITH (NOLOCK)
WHERE LoadGuid = @LoadGuid

/* GET JUST ONE LOAD FROM tblLoads */
INSERT INTO @ThisLoad(LoadGuid, LoadId, BookedDate, DriverEmptyDate)
SELECT LoadGuId, LoadId, BookedDate, DriverEmptyDate
FROM dbo.tblLoads WITH (NOLOCK)
WHERE LoadId = @LoadId;		/* LoadId is the preferred index */

/* A. Get the load stops ids based on the Load Guids */

	SELECT ls.LoadStopId
	INTO #load_stop_ids
	FROM dbo.tblLoadStops AS ls WITH (NOLOCK)
	WHERE ls.LoadGuid = @LoadGuid

/* B. Get the load data utilizing the load stop ids */

	SELECT ls.LoadStopId,
		   ls.[Type] as StopType,
		   ls.StopNo,
		   ls.OrderNumber as StopOrderNumber,
		   mw.GNumber as StopWarehouseNumber,
		   tz.ShortCode as StopTimeZone
	INTO #load_stop_data
	FROM #load_stop_ids lsi
	INNER JOIN dbo.tblLoadStops AS ls WITH (NOLOCK)
	  ON lsi.LoadStopID = ls.LoadStopID
	INNER JOIN Warehouse.ClientWarehouse AS cw WITH (NOLOCK)
	  ON ls.WhGuId = cw.Id
	INNER JOIN Warehouse.MasterWarehouse AS mw WITH (NOLOCK)
	  ON cw.MasterWarehouseId = mw.Id
	INNER JOIN dbo.tblAddress AS a WITH (NOLOCK)
	  ON mw.AddressId = a.AddressId
	INNER JOIN dbo.tblCity AS c WITH (NOLOCK)
	  ON a.CityId = c.CityId
	INNER JOIN dbo.tblStates AS s WITH (NOLOCK)
	  ON c.StateId = s.StateID
	INNER JOIN dbo.tblCountry AS co WITH (NOLOCK)
	  ON s.CountryId = co.CountryId
	LEFT OUTER JOIN MDS.Geo_PostalTimeZone AS ptz WITH (NOLOCK)
	  ON CONVERT(NVARCHAR(100),a.Zip) = ptz.Postal
	     AND co.CountryCD = ptz.Country_Code
	LEFT OUTER JOIN MDS.Geo_TimeZone AS tz WITH (NOLOCK)
	  ON ptz.TimeZone_Code = tz.Code

/* C. Get the load activity ids based on the Load Guids */
	SELECT lal.ActivityLogId,
	       lal.TypeId,
		   lal.SubTypeId,
		   lal.CreatedDate
	INTO #load_activity_log_ids
	FROM dbo.tblLoadActivityLog AS lal WITH (NOLOCK)
	WHERE lal.LoadGuid = @LoadGuid
	AND (lal.TypeId in (1, --Optimizer Booked (no location)
                         20, --Optimizer Checked In
				         35, --Optimizer Delivered
				         36, --Optimizer Detention
				         46, --Optimizer Loading
				         51, --Optimizer Ordered (no location)
				         53, --Optimizer Picked Up
				         77, --Optimizer Unloading
				         1103, --Loading
				         1104, --Picked Up
				         1105, --Unloading
				         1106, --Delivered
				         1200, --Driver Assigned
				         1202, --Trailer Dropped
				         1203) --Trailer Picked Up
       OR (lal.TypeId = 63 --TrackNTrace
	       AND lal.SubTypeId in (24, --Shipment Enroute
                                 70))) --Mobile Tracking

/* D. Get the load activity data */

	SELECT lal.LoadGuid,
	       lal.ActivityLogId,
	       lal.TypeId as LoadActivityTypeId,
		   t.LoadActivityTypeName,
           lal.SubTypeId as LoadActivitySubTypeId,
		   lal.CreatedDate,
		   u.FirstName as CreatedByFirstName,
		   u.LastName as CreatedByLastName
	INTO #load_activity_log_data
	FROM #load_activity_log_ids AS lali
	INNER JOIN dbo.tblLoadActivityLog AS lal WITH (NOLOCK)
	  ON lali.CreatedDate = lal.CreatedDate AND lali.ActivityLogId = lal.ActivityLogId 
	INNER JOIN dbo.tblLoadActivityType AS t WITH (NOLOCK)
	  ON lal.TypeId = t.LoadActivityTypeId
	INNER JOIN dbo.tblUsers AS u WITH (NOLOCK)
	  ON lal.CreatedBy = u.UserGuid


/* E. Get the load activity stop data */
	SELECT lal.ActivityLogId,
	       lal.LoadActivityTypeId,
		   lal.LoadActivitySubTypeId,
		   lal.LoadActivityTypeName,
		   ls.StopType,
		   isnull(ls.StopNo, 0) as StopNo,
		   isnull(ls.StopOrderNumber, 0) as StopOrderNumber,
		   ls.StopWarehouseNumber,
		   coalesce(case when lal.LoadActivityTypeId = 20 then ls2.StopTimeZone
		                                                  else ls.StopTimeZone end,
                    @CentralTime) as StopTimeZone,
           lal.CreatedDate,
		   lal.CreatedByFirstName,
		   lal.CreatedByLastName,
		   CASE WHEN lal.LoadActivityTypeId = 1 --Optimizer Booked (no location)
		            THEN l.BookedDate
				WHEN lal.LoadActivityTypeId = 20 --Optimizer Checked In/Reported Empty
					THEN l.DriverEmptyDate
		        WHEN lal.LoadActivityTypeId in (51, --Optimizer Ordered (no location)
												1200) --Driver Assigned
					THEN lal.CreatedDate
				WHEN lal.LoadActivityTypeId in (46, --Optimizer Loading
												77, --Optimizer Unloading
												1103, --Loading
												1105) --Unloading
					THEN d.ArrivalDate
				WHEN lal.LoadActivityTypeId in (35, --Optimizer Delivered
												53, --Optimizer Picked Up
												1104, --Picked Up
												1106) --Delivered
					THEN d.DepartDate
				ELSE lal.CreatedDate END as MilestoneDate
	INTO #load_activity_stop_data
	FROM @ThisLoad l
	INNER JOIN #load_activity_log_data lal
	  ON l.LoadGuid = lal.LoadGuid
	LEFT OUTER JOIN dbo.tblLoadActivityData AS d WITH(NOLOCK)
	  ON lal.ActivityLogId = d.ActivityLogId
	LEFT OUTER JOIN #load_stop_data ls
	  ON d.LoadStopId = ls.LoadStopId
	LEFT OUTER JOIN #load_stop_data ls2
	  ON ls2.StopOrderNumber = 1

/* F. Final select */
SELECT lasd1.LoadActivityTypeId,
       lasd1.LoadActivitySubTypeId,
	   lasd1.LoadActivityTypeName,
	   lasd1.StopType,
	   lasd1.StopNo,
	   lasd1.StopOrderNumber,
	   lasd1.StopWarehouseNumber,
	   lasd1.StopTimeZone,
	   lasd1.CreatedByFirstName,
	   lasd1.CreatedByLastName,
	   lasd1.CreatedDate,
	   lasd1.MilestoneDate
FROM #load_activity_stop_data lasd1
INNER JOIN (SELECT MAX(ActivityLogId) as ActivityLogId
            FROM #load_activity_stop_data
			GROUP BY StopOrderNumber,
			         CASE WHEN LoadActivityTypeId IN (46, 1103) THEN 46 --Optimizer Loading, Loading
					      WHEN LoadActivityTypeId IN (53, 1104) THEN 53 --Optimizer Picked Up, Picked Up
					      WHEN LoadActivityTypeId IN (77, 1105) THEN 77 --Optimizer Unloading, Unloading
					      WHEN LoadActivityTypeId IN (35, 1106) THEN 35 --Optimizer Delivered, Delivered
						  ELSE LoadActivityTypeId END,
					 LoadActivitySubTypeId) lasd2
  ON lasd1.ActivityLogId = lasd2.ActivityLogId
ORDER BY lasd1.StopOrderNumber,
         lasd1.MilestoneDate
		 
END

GO