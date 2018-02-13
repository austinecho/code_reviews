

SET STATISTICS IO ON; 

--DROP TABLE #LoadCarrier
--DROP TABLE #LoadBoard

DECLARE @LoadGUID UNIQUEIDENTIFIER;

--SET @LoadGUID = '55015E82-324E-4EEE-8C92-A341E68C22DC';
SET @LoadGUID = NULL; 
IF @LoadGUID IS NOT NULL
    BEGIN 

		;
        WITH    CTE_Loads ( LoadGuid )
                  AS ( SELECT   LoadGuId
                       FROM     dbo.tblLoads
                       WHERE    LoadGuId = @LoadGUID
                                AND Status NOT IN ( 'ORDERED', 'DELIVERED',
                                                    'CANCELLED' )
                     ),
                CTE_Carrier ( CarrierGuid, CarrierName, LoadGuid )
                  AS ( SELECT   C.CarrierGuid ,
                                C.CarrierName ,
                                L.LoadGuid
                       FROM     dbo.tblCarrier AS C
                                INNER JOIN dbo.tblCarrierLoads AS CL ON C.CarrierGuid = CL.CarrierGuId
                                INNER JOIN CTE_Loads AS L ON CL.LoadGuId = L.LoadGuid
                     )
            SELECT  L.LoadGuid
            FROM    CTE_Loads AS L
                    INNER JOIN CTE_Carrier AS C ON L.LoadGuid = C.LoadGuid;

    END;

ELSE
    BEGIN

        WITH    CTE_NullLoads ( LoadGuid )
                  AS ( SELECT   LoadGuId
                       FROM     dbo.tblLoads
                       WHERE    Status NOT IN ( 'ORDERED', 'DELIVERED',
                                                'CANCELLED' )
                     ),
                CTE_Carrier ( CarrierGuid, CarrierName, LoadGuid )
                  AS ( SELECT   C.CarrierGuid ,
                                C.CarrierName ,
                                L.LoadGuid
                       FROM     dbo.tblCarrier AS C
                                INNER JOIN dbo.tblCarrierLoads AS CL ON C.CarrierGuid = CL.CarrierGuId
                                INNER JOIN CTE_NullLoads AS L ON CL.LoadGuId = L.LoadGuid
                     )
            SELECT  L.LoadGuid
            FROM    CTE_NullLoads AS L
                    INNER JOIN CTE_Carrier AS C ON L.LoadGuid = C.LoadGuid;

    END;
        

		
			--SELECT L.LoadGuId, C.CarrierGuid, C.CarrierName
			--INTO #LoadCarrier
			--FROM dbo.tblLoads AS L
			--INNER JOIN dbo.tblCarrierLoads AS CL
			--ON L.LoadGuId = CL.LoadGuId
			--INNER JOIN dbo.tblCarrier AS C
			--ON CL.CarrierGuId = C.CarrierGuid
			--WHERE --L.LoadGuId = '55015E82-324E-4EEE-8C92-A341E68C22DC' AND 
			--L.Status NOT IN
			--			(
			--			'ORDERED',
			--			'DELIVERED',
			--			'CANCELLED'
			--			)
			--AND C.TrackingTypeID IN (4,5,6,7)

			--SELECT *
			--FROM #LoadCarrier

			--SELECT LB.DestinationName
			--,LB.OriginName
			--,LB.DeliveryFrom
			--,LB.DeliveryTo	
			--,LB.DropAddress1	AS DeliveryLine1
			--,LB.DropAddress2	AS DeliveryLine2
			--,LB.DropCity		AS DeliveryCity
			--,LB.DropState		AS DeliveryState
			--,LB.DestinationZip	AS DeliveryZip
			--,LB.PickupFrom
			--,LB.PickupTo
			--,LB.PickAddress1	AS PickupLine1
			--,LB.PickAddress2	AS PickupLine2
			--,LB.PickCity		AS PickupCity
			--,LB.PickState		AS PickupState
			--,LB.OriginZip		AS PickupZip
			--INTO #LoadBoard
			--FROM ODSQuery.tblLoadBoard AS lb 
			--INNER JOIN #LoadCarrier AS LC
			--ON LB.LoadGuId = LC.LoadGuId

			--SELECT MP.MSISDN
			--FROM dbo.LoadCarrierDriver AS LCD
			--INNER JOIN dbo.CarrierDriver AS CD
			--ON LCD.CarrierDriverId = CD.CarrierDriverId
			--INNER JOIN dbo.Driver AS D
			--ON CD.DriverId = D.DriverId
			--LEFT OUTER JOIN dbo.MobilePhone AS MP
			--ON D.MobilePhoneId = MP.MobilePhoneId
			--INNER JOIN #LoadCarrier AS LC
			--ON LCD.LoadGuid = LC.LoadGuId