USE [EchoOptimizer]
GO
/****** Object:  StoredProcedure [dbo].[GetLoadInfoFor204Message]    Script Date: 10/4/2017 4:44:27 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
/*=================================================

Name:			Stored Proc - GetLoadInfoFor204Message

Description:	Gets a load info by ID. 

Author:			David Hoyt          
Date:			2017/8/18


EXEC [dbo].[GetLoadInfoFor204Message]
	@LoadID  = '22229730'

=================================================*/
ALTER PROCEDURE [dbo].[DT_GetLoadInfoFor204Message]
       @LoadID AS INT
AS 

BEGIN 

SET NOCOUNT ON 
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED 

DECLARE @LoadGuid UNIQUEIDENTIFIER 
DECLARE @LoadItemID UNIQUEIDENTIFIER
DECLARE @CarrierLoadID INT 
DECLARE @LoadTenderID INT

SELECT @LoadGuid = loadguid FROM dbo.tblLoads WHERE LoadId = @LoadID
SELECT @LoadItemID = loaditemID FROM dbo.tblLoadItems WHERE LoadGuId = @LoadGuid
SELECT @CarrierLoadID = CarrierLoadID FROM dbo.tblCarrierLoads WHERE LoadGuId = @LoadGuid
SELECT @LoadTenderID = LoadTenderID FROM Tender.LoadTender WHERE LoadGuid = @LoadGuid



;WITH CTE_loadItems_WeightUnit
AS
(
SELECT WeightUnit, LoadGuId
FROM dbo.tblLoadItems
WHERE LoadItemId = @LoadItemID
),
CTE_carrierLoads_Amount
AS
(
SELECT Amount, LoadGuId
FROM dbo.tblCarrierLoads
WHERE CarrierLoadId = @CarrierLoadID
),
CTE_LoadTender
AS
(
SELECT TenderExpireTime ,
       Status ,
       RoutingGuid ,
       TenderingGuid,
	   IsDeclined,
	   LoadGuid,
	   LoadTenderId
FROM Tender.LoadTender
WHERE LoadTenderId = @LoadTenderID
AND IsTimedOut = 0
AND IsDeclined = 0
AND Status = 1
),
CTE_LoadTenderResponse
AS
(
SELECT  ReservationActionCode, Remarks1, Remarks2, StatusReasonCode, LoadTenderId
FROM Tender.LoadTenderResponse
WHERE LoadTenderId = @LoadTenderID
)


       SELECT TOP 1
               l.ActivityDate, 
			   l.DeliveryDate,
			   cust.CustomerId, 
			   ca.SCAC, 
			   l.LoadId, 
			   l.Mode, 
			   l.hazmat, 
			   l.DeliveryBydate,
			   l.PickUpByDate,
			   l.PickupReadyByDate,
			   l.CustomerDeliveryByDate, 
			   l.CustomerNotesExternal, 
			   cal.Amount, 
			   l.Distance, 
			   l.NumberOfPallets, 
			   l.PalletStackable, 
			   li.WeightUnit,
			   ee.Code as EquipmentTypeCode, 
			   EE.Length_Code as EquipmentLength, 
			   EQN.EquipmentNotes, 
			   l.Cogs, 
			   l.LoadGuId,
			   ltd.TenderExpireTime,
			   ltd.Status,
			   ltd.TenderingGuid,
			   ltd.RoutingGuid,
			   ltr.ReservationActionCode,
			   ltr.Remarks1,
			   ltr.remarks2,
			   ltr.StatusReasonCode,
			   ltd.IsDeclined
       FROM     dbo.[tblLoads] L 
	   LEFT OUTER JOIN CTE_loadItems_WeightUnit LI on LI.LoadGuId = L.LoadGuId
	   LEFT OUTER JOIN dbo.LoadSpecialService LSS on LSS.LoadGuId = L.LoadGuId
	   LEFT OUTER JOIN dbo.LoadEquipment LEQ on LEQ.LoadGuId = L.LoadGuId
	   LEFT OUTER JOIN MDS.Equipment_Equipment EE on EE.Code = LEQ.EquipmentID
       LEFT OUTER JOIN dbo.tblcarrier CA ON CA.carrierGuid = L.carrierGuid
       LEFT OUTER JOIN CTE_carrierLoads_Amount CAL ON CAL.LoadGuId = L.LoadGuid
       INNER JOIN dbo.tblCustomerLoads CL ON CL.LoadGuid = L.LoadGuid
       INNER JOIN dbo.tblCustomer cust ON cust.CustomerGuid = CL.CustomerGuiD
	   LEFT OUTER JOIN dbo.EquipmentNotes EQN on EQN.LoadGuId = l.LoadGuId
	   LEFT OUTER JOIN dbo.tblLoadsExtended le ON le.LoadID = L.LoadId
       LEFT OUTER JOIN CTE_LoadTender ltd ON L.LoadGuId = ltd.LoadGuid
       LEFT OUTER JOIN CTE_LoadTenderResponse ltr ON ltd.LoadTenderId = ltr.LoadTenderId
	   WHERE    L.LoadId = @LoadID
	

  
END
