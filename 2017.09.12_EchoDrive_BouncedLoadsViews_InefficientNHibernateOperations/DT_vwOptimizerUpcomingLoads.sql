USE [EchoOptimizer]
GO

/****** Object:  View [CarrierPortal].[vwOptimizerUpcomingLoads]    Script Date: 8/24/2017 2:18:59 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW [CarrierPortal].[DT_vwOptimizerUpcomingLoads]
	AS 
WITH CTE_ODSLoadGuid AS (
select lb.LoadGuId
	from odsquery.tblloadboard as lb with (nolock)
	where lb.mode='TL'
	and lb.stops > 1
	AND lb.Status IN ('BOOKED', 'CANCELLED', 'Ordered')
	),
cte_activeloads(loadguid, loadid, carrierguid, status, stops, pickupopendate, pickupcldate
, deliveryopendate, deliverycldate, pronumber, invoiceamount, cogs, driver1, assigned, viewtimeout)
as
(
	select lb.loadguid, lb.loadid, lb.carrierguid, lb.status, lb.stops, lb.pickupfrom as pickupopendate, lb.pickupto as pickupcldate
	, lb.deliveryfrom as deliveryopendate, lb.deliveryto as deliverycldate, dbo.fn_ConcatReferenceNumByLoadGuid(lb.LoadGuid, 2) as ProNumber
	, cc.amount as invoiceamount, lb.cogs, lb.driver1, case lb.carrierid when null then 0 else 1 end as assigned,
	case when lb.Status = 'BOOKED' then dateadd(hour, -30, lb.pickupfrom)
		when lb.Status = 'Ordered' then dateadd(hour, -30, lb.pickupfrom)
		when lb.Status = 'CANCELLED' and lb.canceldate is not null then dateadd(hour, 24, lb.canceldate)
		else null end as viewtimeout
	from CTE_ODSLoadGuid AS CTE
	INNER JOIN odsquery.tblloadboard as lb with (nolock)
	ON CTE.LoadGuId = lb.LoadGuId
	left join dbo.tblcarriercosts as cc with (nolock) on cc.loadguid = lb.loadguid
	where lb.mode='TL'
	and lb.stops > 1
	AND lb.Status IN ('BOOKED', 'CANCELLED', 'Ordered')
)
--non-bounced-loads
select ct.loadguid, ct.loadid, ct.carrierguid, ct.status, ct.stops, ct.pickupopendate, ct.pickupcldate
	, ct.deliveryopendate, ct.deliverycldate, ct.pronumber, ct.invoiceamount, ct.cogs, ct.driver1, ct.assigned
	from cte_activeloads ct
	where ct.carrierguid is not null
	and (ct.viewtimeout is not null and getdate() < ct.viewtimeout)


