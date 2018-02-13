/*
DEAD END CODE 
DataTeam KLJ
Draft 20170207
Release One 

Test Plan
Execute dependencies (SQL)

Metrics: 
20170214 RB-20170223_DeadEndCode_R1 (Trunk only execution)
--Need to comment out rs_procOnTime to test in PROD (Pre-state)

*/


--DB01VPRD (or equivilant) 
USE [EchoOptimizer]

--IF NEEDED

	--PRE TEST CHECK (QA HELPER SCRIPT ONLY)
	--**************************************************
	--Find test data / examples

	----(Loads)
	----Ordered
	--SELECT TOP 10 LoadID, LoadGuid, CreatedDate, [Status] FROM tblLoads AS L WITH(NoLock) WHERE [Status] = 'ORDERED' ORDER BY CreatedDate DESC
	----Delivered
	--SELECT TOP 10 LoadID, LoadGuid, CreatedDate, [Status], BookedSalesPerson FROM tblLoads AS L WITH(NoLock) WHERE [Status] = 'DELIVERED' ORDER BY CreatedDate DESC

	----(Customer)
	--SELECT TOP 10 L.LoadID, L.LoadGuid, L.CreatedDate, L.[Status], C.CustomerGuid, C.CustomerId, C.CustomerName FROM tblLoads AS L WITH(NoLock) INNER JOIN tblCustomerLoads AS CL ON L.LoadGuid = CL.LoadGuid INNER JOIN tblCustomer AS C ON CL.CustomerGuiD = C.CustomerGuid ORDER BY CreatedDate DESC

	----(Carrier)
	--SELECT TOP 10 L.LoadID, L.LoadGuid, L.CreatedDate, L.[Status], CAR.CarrierGuid, CAR.CarrierId, CAR.CarrierName FROM tblLoads AS L WITH(NoLock) INNER JOIN tblCarrierLoads AS CARL ON L.LoadGuid = CARL.LoadGuid INNER JOIN tblCarrier AS CAR ON CARL.CarrierGuiD = CAR.CarrierGuid ORDER BY CreatedDate DESC

	----(StateID)
	--SELECT TOP 10 * FROM tblStates WHERE StateCode = 'IL'
	--**************************************************



	--(((((FOR QA TO USE IN TEST)))))
	--TEST Template
	--**************************************************

	--(((((TEST PLAN DETAILS - Object and required check)))))

	--SELECT 'SPName'
	--UNION
	--SELECT 'Check: Row set returned (Required)'
	--**************************************************

	----Pattern:

	--(((((TEST SCRIPT)))))

	----T=00:00s 0 row(s) --(((((DEV METRICS / HOW LONG AND HOW MANY)))))


--BEGIN

--TEST 1
--**************************************************
SELECT 'GetBOLSpecialServicesList' --Name
UNION
SELECT 'Check: Expect 1 row (Required), check [OrigSpecSvc] for value (Not required)' --Test
--**************************************************

----Pattern:
--SELECT dbo.GetBOLSpecialServicesList(2, '43683379-D578-47E2-82B9-B8BC6D18119A') as OrigSpecSvc --StopID, LoadGuid

	--Indirect usage (SP calls function) 
	EXEC [dbo].[BOL_SelectPickDropInformation] 

		@LoadID = '22229478', --Replace LoadID
		@BlindType = '3'

----T=00:00s 1 row(s)


--TEST Template
--**************************************************
SELECT 'rs_procCulliganDomesticShipmentsSummary'
UNION
SELECT 'Check: Row set returned (Required)'
--**************************************************

----Pattern:
	EXEC [dbo].[rs_procCulliganDomesticShipmentsSummary] 

	@From = '7/1/2015',
	@To = '7/1/2015',
	@DateFormatData = '',
	@DateFilter = 'PickUpByDate',
	@DateFilterType = 'custom' ,
	@DateFormat = 'year',
	@DateYear = '2015',
	@GLCode = '',
	@OriginName = '',
	@DestName = ''

----T=00:03s 171 row(s)


--TEST Template
--**************************************************
SELECT 'rs_procEmployeeCommission'
UNION
SELECT 'Check: Row set returned (Required)'
--**************************************************

----Pattern:
EXEC [dbo].[rs_procEmployeeCommission]
	@From = '7/1/2015',
	@To = '7/1/2015',
	@DateFilter = 'PrintDate',
	@DateFilterType = 'Custom',
	@SalesRep = '31354816-1FBA-42EF-9775-5BD1BC51A78A',
	@Office = ' All',
	@Customer = 'All',
	@bApply35Rule = 1


----T=00:13s 11 row(s)

--TEST Template
--**************************************************
SELECT 'rs_procTraceTraceDetailFilteredWorkloads'
UNION
SELECT 'Check: Row set returned (Required)'
--**************************************************

----Pattern:
	EXEC [dbo].[rs_procTraceTraceDetailFilteredWorkloads] 
		@From = '7/1/2015' ,
		@To = '7/1/2015',
		@DateFilter = 'DeliveryByDate',
		@DateFilterType = 'ALL',
		@Report = 'TrackNTrace',
		@Status = '',
		@customer ='A8540922-6D54-4150-8BB9-FF71F1AC87F2', --CustomerGuId
		@mode ='Expedited,Intermodal,International,LTL,TL'
----T=00:05s 421 row(s)

--TEST Template
--**************************************************
SELECT 'rs_procIncomFreightCost'
UNION
SELECT 'Check: Row set returned (Required)'
--**************************************************

----Pattern:
	EXEC [dbo].[rs_procIncomFreightCost]    
	 @From = '7/1/2015',    
	 @To = '7/1/2015',    
	 @mode = 'TL',     
	 @job_num = '',    
	 @customerguid ='10A66043-121F-417E-A452-4E9C2720C346' ,   
	 @ProcessLevel = '',
	 @CustClientName = ' All'
----T=00:02s 2 row(s)

--TEST Template
--**************************************************
SELECT 'rs_procInsideSalesTeamNewAccounts'
UNION
SELECT 'Check: No Errors (Required), 0 row count acceptable'
--**************************************************

----Pattern:
	EXEC [dbo].[rs_procInsideSalesTeamNewAccounts] 
		@From = '7/1/2015',
		@To = '7/2/2015',
		@DateFilter = 'BookedDate',		
		@DateFilterType = 'Custom',
		@Account = 'All', 
		@SalesRepStatus = 'A'
----T=00:00s 0 row(s) --Time dependency and Office constraint exist - virtually untestable without real data

--TEST Template
--**************************************************
SELECT 'rs_procInsideSalesWeeklyMetricsKeyTrends'
UNION
SELECT 'Check: No Errors (Required), 0 row count acceptable'
--**************************************************

----Pattern:
	EXEC [dbo].[rs_procInsideSalesWeeklyMetricsKeyTrends]
		@From = '7/1/2015',
		@To = '7/2/2015',
		@DateFilter = 'BookedDate',		
		@DateFilterType = 'Custom',
		@SalesRep = 'All'

----T=00:00s 0 row(s) --Time dependency and Office constraint exist - virtually untestable without real data

--TEST Template
--**************************************************
SELECT 'rs_procLoadSummary'
UNION
SELECT 'Check: Row set returned (Required)'
--**************************************************

----Pattern:
	EXEC [dbo].[rs_procLoadSummary]
		@From = '7/1/2015' ,
		@To = '7/1/2015' ,
		@DateFilter = 'BookedDate' ,
		@DateFilterType = 'Custom' ,
		@pGroupOn = 'account'
----T=00:10s 2798 row(s)

--TEST Template
--**************************************************
SELECT 'rs_procLoadSummary_Top15'
UNION
SELECT 'Check: Row set returned (Required)'
--**************************************************

----Pattern:
EXEC [dbo].[rs_procLoadSummary_Top15]
		@From = '7/1/2015' ,
		@To = '7/1/2015' ,
		@DateFilter = 'BookedDate' ,
		@DateFilterType = 'Custom' ,
		@pGroupOn = 'account'
----T=00:15s 15 row(s)

--TEST Template
--**************************************************
SELECT 'rs_procLoadSummary_Top5'
UNION
SELECT 'Check: Row set returned (Required)'
--**************************************************

----Pattern:
EXEC [dbo].[rs_procLoadSummary_Top5]
		@From = '7/1/2015' ,
		@To = '7/1/2015' ,
		@DateFilter = 'BookedDate' ,
		@DateFilterType = 'Custom' ,
		@pGroupOn = 'account'
----T=00:13s 5 row(s)

--TEST Template
--**************************************************
SELECT 'rs_procLoadTruckInOut'
UNION
SELECT 'Check: Row set returned (Required)'
--**************************************************

----Pattern:
EXEC [dbo].[rs_procLoadTruckInOut]
	@Preview = 'LoadandTruck'
----T=00:02s 103 row(s)

--TEST Template
--**************************************************
SELECT 'rs_procOnTime'
UNION
SELECT 'Check: Row set returned (Required)'
--**************************************************

----Pattern:
EXEC [dbo].[rs_procOnTime]
		@From = '7/1/2015',
		@To = '7/1/2015',
		@DateFilter = 'DeliveryByDate',
		@DateFilterType = 'Custom',
		@GrpdBy = 'Month',
		@Mode ='Expedited,Intermodal,International,LTL,Services,Small Pack,TL',
		@CustomerID ='10A66043-121F-417E-A452-4E9C2720C346', --GUID 
		@CarrierID ='All',
		@ActCarrier =' All',
		@business_unit ='All',
		@process_level ='All'
----T=00:05s 44 row(s)

--TEST Template
--**************************************************
SELECT 'rs_procPECOInvoiceDetailTotalLoad'
UNION
SELECT 'Check: No Errors (Required), 0 row count acceptable'
--**************************************************

----Pattern:
	EXEC [dbo].[rs_procPECOInvoiceDetailTotalLoad] 
	@FromDate = '7/1/2015',
	@ToDate = '7/2/2015',
	@DateFilter = 'printdate'
----T=00:00s 0 row(s) --Hard coded GUID, may not have usage CustomerGuID = '92b44be9-4e91-44ff-bcf8-e59f02cad312'

--TEST Template
--**************************************************
SELECT 'rs_procPreBilledCOGSCutOff'
UNION
SELECT 'Check: Row set returned (Required)'
--**************************************************

----Pattern:
EXEC [dbo].[rs_procPreBilledCOGSCutOff] 
	@AsOfDate = '1/2/2015'
----T=00:06s 32 row(s) --Depends on delivery_date,invoice_status,invoice_date

--TEST Template
--**************************************************
SELECT 'rs_procSalesActivity'
UNION
SELECT 'Check: Row set returned (Required)'
--**************************************************

----Pattern:
EXEC [dbo].[rs_procSalesActivity]
		@From = '7/1/2015',
		@To = '7/2/2015',
		@DateFilter = 'BookedDate',		
		@DateFilterType = 'custom',
		@DateFormat = 'month',
		@Account = 'All' ,
		@Carrier = 'All',
		@Mode = 'Expedited,Intermodal,International,International - Air,International - Ocean,LTL,Services,Small Pack,TL',
		@Salesrep = ' All',
		@BookingAgent = ' All',
		@Office = ' All',
		@Segment = 'All',
		@ParentCompany = 'All'
----T=00:08s 1 row(s)

--TEST Template
--**************************************************
SELECT 'rs_procSalesActivity_drilldown'
UNION
SELECT 'Check: No Errors (Required), 0 row count acceptable'
--**************************************************

----Pattern:
EXEC [dbo].[rs_procSalesActivity_drilldown]
		@From = '1/1/2015' ,
		@To = '7/31/2015' ,
		@DateFilter = 'CI.InvDate' ,
		@DateFilterType = 'Custom' ,
		@pGroupOn = 'account',
		@DateFormat = 'month' ,
		@DateFormatData = '4' ,
		@DateYear ='2015',
		@Mode = 'Expedited,Intermodal,International,LTL,Services,Small Pack,TL',
		@Account = 'All' ,
		@Carrier = 'All' ,
		@Salesrep = ' All',
		@Office = ' All',
		@Loads = '',
		@SelectedItem = '',
		@SelectedValue = '',
		@BookingAgent = ' All',
		@Segment = 'All',
		@ParentCompany = 'All'
----T=00:00s 0 row(s) --Can't find data in dev. Similar to SP above, but no results found.

--TEST Template
--**************************************************
SELECT 'rs_procSalesActivity_AccountingAudit'
UNION
SELECT 'Check: Row set returned (Required)'
--**************************************************

----Pattern:
EXEC [dbo].[rs_procSalesActivity_AccountingAudit]

		@From = '7/1/2015',
		@To = '7/1/2015',
		@DateFilter = 'BookedDate',		
		@DateFilterType = 'custom',
		@DateFormat = 'week',
		@Account = 'All' ,
		@Carrier = 'All',
		@Mode = 'Expedited,Intermodal,International,International - Air,International - Ocean,LTL,Services,Small Pack,TL',
		@Salesrep = ' All',
		@BookingAgent = ' All',
		@Office = ' All',
		@Segment = 'All,Transactional,Enterprise,National,BPO',
		@ParentCompany = 'All'
----T=00:09s 1 row(s)

--TEST Template
--**************************************************
SELECT 'rs_procSalesActivityBookedBy'
UNION
SELECT 'Check: Row set returned (Required)'
--**************************************************

----Pattern:
EXEC [dbo].[rs_procSalesActivityBookedBy]
		@From = '7/1/2015',
		@To = '7/1/2015',
		@DateFilter = 'BookedDate',		
		@DateFilterType = 'custom',
		@DateFormat = 'week',
		@Account = 'All' ,
		@Carrier = 'All',
		@Mode = 'Expedited,Intermodal,International,International - Air,International - Ocean,LTL,Services,Small Pack,TL',
		@Salesrep = ' All',
		@BookingAgent = ' All',
		@Office = ' All',
		@Segment = 'All,Transactional,Enterprise,National,BPO',
		@ParentCompany = 'All'
----T=00:09s 1 row(s)

--TEST Template
--**************************************************
SELECT 'rs_procSalesRepActivity'
UNION
SELECT 'Check: Row set returned (Required)'
--**************************************************

----Pattern:
EXEC [dbo].[rs_procSalesRepActivity]
	@userid = '2ae3d045-e6fe-46b4-a865-11ce2eef3876'
----T=00:01s 2 row(s)

--TEST Template
--**************************************************
SELECT 'rs_procSalesRepActivity_Monthly'
UNION
SELECT 'Check: No Errors (Required), 0 row count acceptable'
--**************************************************

----Pattern:
EXEC [dbo].[rs_procSalesRepActivity_Monthly]
	@userid = '2ae3d045-e6fe-46b4-a865-11ce2eef3876'
----T=00:00s 0 row(s) --Used GetDate() as a constraint 

--TEST Template
--**************************************************
SELECT 'rs_procSalesRepActivity_Quarterly'
UNION
SELECT 'Check: Row set returned (Required)'
--**************************************************

----Pattern:
EXEC [dbo].[rs_procSalesRepActivity_Quarterly]
	@userid = '2ae3d045-e6fe-46b4-a865-11ce2eef3876'
----T=00:00s 0 row(s)

--TEST Template
--**************************************************
SELECT 'rs_procSalesRepPipelineDetail'
UNION
SELECT 'Check: Row set returned (Required)'
--**************************************************

----Pattern:

	EXEC [dbo].[rs_procSalesRepPipelineDetail]
	@From = '7/1/2015',
	@To = '7/1/2015',
	@DateFilter = 'BookedDate',
	@DateFilterType = 'Custom',
	@SalesOffice = '0',
	@CommType = '1,2,3,4',
	@AccountOwner = 'All'

----T=00:15s 2798 row(s)

--TEST Template
--**************************************************
SELECT 'rs_procSalesRepPipelineSummary'
UNION
SELECT 'Check: Row set returned (Required)'
--**************************************************

----Pattern:
	EXEC [dbo].[rs_procSalesRepPipelineSummary]
	@From = '7/1/2015',
	@To = '7/1/2015',
	@DateFilter = 'BookedDate',
	@DateFilterType = 'Custom',
	@SalesOffice = '0',
	@CommType = '1,2,3,4'

----T=00:12s 592 row(s)

--TEST Template
--**************************************************
SELECT 'NonClaimsRatio'
UNION
SELECT 'Check: No Errors (Required), 0 row count acceptable'
--**************************************************

----Pattern:
	DECLARE @CarrierVolume Carrier.TT_LoadCount
	INSERT INTO @CarrierVolume VALUES ('6DC879E3-4648-4798-9765-B82557194A25','20','20','0') 
	--[CarrierGuid],[OriginStateID],[DestinationStateID],[TotalCount] --Data not present in test

	EXEC [Carrier].[NonClaimsRatio]
	@CarrierVolume

----T=00:00s 0 row(s)

--TEST Template
--**************************************************
SELECT 'rs_procBaseCog2'
UNION
SELECT 'Check: Row set returned (Required)'
--**************************************************

----Pattern:
-- =============================================
	EXEC [rs_procBaseCog2] 
	@AsOfDate = '7/1/2015'

----T=00:11s 1270 row(s)


--TEST Template
--**************************************************
SELECT 'rs_procBookedLoads_YTDMTD'
UNION
SELECT 'Check: No Errors (Required), 1 row with Nulls is acceptable'
--**************************************************

----Pattern:
EXEC [rs_procBookedLoads_YTDMTD]
----T=00:00s 0 row(s)


--TEST Template
--**************************************************
SELECT 'rs_procCommission'
UNION
SELECT 'Check: Row set returned (Required)'
--**************************************************

----Pattern:
EXEC [rs_procCommission]
	@From = '7/1/2015',
	@To = '7/2/2015',
	@DateFilter = 'PrintDate',
	@DateFilterType = 'Custom',
	@SalesRep = ' All',
	@Office = ' All',
	@Customer = '10A66043-121F-417E-A452-4E9C2720C346',
	@bApply35Rule = 1
----T=00:11s 26 row(s)


--TEST Template
--**************************************************
SELECT 'rs_procCSRActivity'
UNION
SELECT 'Check: Row set returned (Required)'
--**************************************************

----Pattern:
EXEC [rs_procCSRActivity]
		@From = '7/1/2015',
		@To = '7/1/2015',
		@DateFilter = 'L.BookedDate',
		@DateFilterType = 'Custom',
		@Mode = 'Expedited,Intermodal,International,LTL,Services,Small Pack,TL',
		@CSR = 'All',
		@Customer = 'All',
		@ViewByField = 'OrderBy'
----T=00:02s 1 row(s)


--TEST Template
--**************************************************
SELECT 'rs_procCulliganFreightPay'
UNION
SELECT 'Check: Row set returned (Required)'
--**************************************************

----Pattern:
	EXEC [rs_procCulliganFreightPay] 
	@FromDate = '7/1/2015',
	@ToDate = '7/1/2015',
	@DateFilter= 'PrintDate'
----T=00:00s 23 row(s)


--TEST Template
--**************************************************
SELECT 'rs_procCulliganFreightPay_TotalCharge'
UNION
SELECT 'Check: Row set returned (Required)'
--**************************************************

----Pattern:
	EXEC [rs_procCulliganFreightPay_TotalCharge] 
	@FromDate = '7/1/2015',
	@ToDate = '7/1/2015',
	@DateFilter= 'PrintDate'
----T=00:00s 11 row(s)


--TEST Template
--**************************************************
SELECT 'rs_procCulliganRebateSummary'
UNION
SELECT 'Check: Row set returned (Required)'
--**************************************************

----Pattern:
	EXEC [rs_procCulliganRebateSummary] 
	@FromDate = '7/1/2015',
	@ToDate = '7/1/2015',
	@DateFilter= 'PrintDate'
----T=00:00s 23 row(s)


--TEST Template
--**************************************************
SELECT 'rs_procCulliganRebateSummary_TotalLoad'
UNION
SELECT 'Check: Row set returned (Required)'
--**************************************************

----Pattern:
	EXEC [rs_procCulliganRebateSummary_TotalLoad] 
	@FromDate = '7/1/2015',
	@ToDate = '7/1/2015',
	@DateFilter= 'PrintDate'
----T=00:00s 11 row(s)


--TEST Template
--**************************************************
SELECT 'rs_procCustomerActivity'
UNION
SELECT 'Check: Row set returned (Required)'
--**************************************************

----Pattern:
EXEC [rs_procCustomerActivity]
		@From = '7/1/2015',
		@To = '7/1/2015',
		@CustomerID = 'All',
		@DateFilter = 'BookedDate',
		@DateFilterType = 'Custom',
		@Mode ='Expedited,Intermodal,International,LTL,Services,Small Pack,TL',
		@DateFormat = 'week',
		@ProcessLevel = ''
----T=00:05s 1 row(s)


--TEST Template
--**************************************************
SELECT 'rs_procCustomerAudit'
UNION
SELECT 'Check: Row set returned (Required)'
--**************************************************

----Pattern:
EXEC [rs_procCustomerAudit] 
		@From = '7/1/2015',
		@To = '7/1/2015',
		@DateFilter = 'L.BookedDate',
		@DateFilterType = 'Custom',
		@Mode = 'Expedited,Intermodal,International,LTL,Services,Small Pack,TL',
		@Customer = '10A66043-121F-417E-A452-4E9C2720C346',
		@grpby = 'None',
		@carrier =' All',
		@RemoveAudit = 0
----T=00:09s 128 row(s)


--TEST Template
--**************************************************
SELECT 'rs_procCustomerSaving'
UNION
SELECT 'Check: Row set returned (Required)'
--**************************************************

----Pattern:

EXEC [rs_procCustomerSaving]  
		@From = '7/1/2015',
		@To = '7/1/2015',
		@DateFilter = 'L.BookedDate',
		@DateFilterType = 'Custom',
		@Mode = 'Expedited,Intermodal,International,LTL,Services,Small Pack,TL',
		@Customer = '10A66043-121F-417E-A452-4E9C2720C346',
		@grpby = 'None',
		@carrier =' All',
		@RemoveAudit = 0

----T=00:07s 124 row(s)


--TEST Template
--**************************************************
SELECT 'rs_procCustomerServiceMetric'
UNION
SELECT 'Check: No Errors (Required), 0 row count acceptable'
--**************************************************

----Pattern:

EXEC [rs_procCustomerServiceMetric]
		@From = '7/1/2015',
		@To = '7/1/2015',
		@DateFilter = 'L.BookedDate',
		@DateFilterType = 'Custom',
		@customerid = 'All'
----T=00:00s 0 row(s) --No results found: DATEADD(d, 7 - DATEPART(dw, L.ActivityDate), L.ActivityDate))  and uses a LoadActivityLog constraint


--TEST Template
--**************************************************
SELECT 'rs_procEmployeeSalesRepPipelineDetail'
UNION
SELECT 'Check: Row set returned (Required)'
--**************************************************

----Pattern:
EXEC [rs_procEmployeeSalesRepPipelineDetail]
		@From = '7/1/2015',
		@To = '7/1/2015',
		@DateFilter = 'L.BookedDate',
		@DateFilterType = 'Custom',
		@SalesOffice = '0',
		@CommType = '1,2,3,4',
		@userid = 'All'
----T=00:18s 2798 row(s)


--TEST Template
--**************************************************
SELECT 'rs_procSalesActivity_AccountingAudit'
UNION
SELECT 'Check: Row set returned (Required)'
--**************************************************

----Pattern:
EXEC [rs_procSalesActivity_AccountingAudit]

		@From = '7/1/2015',
		@To = '7/1/2015',
		@DateFilter = 'L.BookedDate',
		@DateFilterType = 'Custom',
		@DateFormat = 'week',
		@Account = 'All' ,
		@Carrier = 'All',
		@Mode = 'Expedited,Intermodal,International,International - Air,International - Ocean,LTL,Services,Small Pack,TL',
		@Salesrep = ' All',
		@BookingAgent = ' All',
		@Office = ' All',
		@Segment = 'All,Transactional,Enterprise,National,BPO',
		@ParentCompany = 'All'
----T=00:08s 1 row(s)


--TEST Template
--**************************************************
SELECT 'rs_procSalesActivity_drilldown_BookedBy'
UNION
SELECT 'Check: No Errors (Required), 0 row count acceptable'
--**************************************************

----Pattern:
EXEC [rs_procSalesActivity_drilldown_BookedBy]

		@From = '7/1/2015',
		@To = '7/31/2015',
		@DateFilter = 'L.BookedDate',
		@DateFilterType = 'Custom',
		@pGroupOn = 'account',
		@DateFormat = 'month' ,
		@DateFormatData = '7' ,
		@DateYear ='2015',
		@Mode = 'Expedited,Intermodal,International,LTL,Services,Small Pack,TL',
		@Account = 'All' ,
		@Carrier = 'All' ,
		@Salesrep = ' All',
		@Office = ' All',
		@Loads = '',
		@SelectedItem = '',
		@SelectedValue = '',
		@BookingAgent = ' All',
		@Segment = 'All',
		@ParentCompany = 'All'
----T=00:00s 0 row(s) --Time sensitive / no data found


--TEST Template
--**************************************************
SELECT 'rs_procSalesActivity_drilldown_OwnedBy'
UNION
SELECT 'Check: Row set returned (Required)'
--**************************************************

----Pattern:
EXEC [dbo].[rs_procSalesActivity_drilldown_OwnedBy]
		@From = '7/1/2015',
		@To = '7/1/2015',
		@DateFilter = 'L.BookedDate',
		@DateFilterType = 'Custom',
		@pGroupOn = 'account',
		@DateFormat = 'month' ,
		@DateFormatData = '7' ,
		@DateYear ='2015',
		@Mode = 'Expedited,Intermodal,International,LTL,Services,Small Pack,TL',
		@Account = 'All' ,
		@Carrier = 'All' ,
		@Salesrep = ' All',
		@Office = ' All',
		@Loads = '',
		@SelectedItem = '',
		@SelectedValue = '',
		@BookingAgent = ' All',
		@Segment = 'All',
		@ParentCompany = 'All'
----T=00:23s 2591 row(s)


--TEST Template
--**************************************************
SELECT 'rs_procSalesActivityOwnedBy'
UNION
SELECT 'Check: Row set returned (Required)'
--**************************************************

----Pattern:
EXEC [rs_procSalesActivityOwnedBy]
		@From = '7/1/2015',
		@To = '7/1/2015',
		@DateFilter = 'L.BookedDate',
		@DateFilterType = 'Custom',
		@DateFormat = 'month',
		@Account = 'All' ,
		@Carrier = 'All',
		@Mode = 'Expedited,Intermodal,International,International - Air,International - Ocean,LTL,Services,Small Pack,TL',
		@Salesrep = ' All',
		@BookingAgent = ' All',
		@Office = ' All',
		@Segment = 'All,Transactional,Enterprise,National,BPO',
		@ParentCompany = 'All'
----T=00:08s 1 row(s)





----TEST Template
----**************************************************
--SELECT 'SPName'
--UNION
--SELECT 'Check: Row set returned (Required)'
----**************************************************

------Pattern:

------T=00:00s 0 row(s)


----END