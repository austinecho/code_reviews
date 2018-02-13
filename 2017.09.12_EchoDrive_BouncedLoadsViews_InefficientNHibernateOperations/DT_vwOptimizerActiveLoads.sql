ALTER VIEW [CarrierPortal].[DT_vwOptimizerActiveLoads]
	AS 

WITH CTE_LBGuid AS
(
SELECT LoadGuId
FROM ODSQuery.tblLoadBoard
where mode='TL'
	and stops > 1
	AND Status IN ('CHECKED IN', 'LOADING', 'UNLOADING', 'PICKED UP', 'BOOKED', 'CANCELLED', 'Ordered', 'DELIVERED')
)
,
cte_activeloads(loadguid, loadid, carrierguid, status, stops, pickupopendate, pickupcldate
, deliveryopendate, deliverycldate, pronumber, invoiceamount, cogs, driver1, assigned, viewtimeout)
as
(
	select lb.loadguid, lb.loadid, lb.carrierguid, lb.status, lb.stops, lb.pickupfrom as pickupopendate, lb.pickupto as pickupcldate
	, lb.deliveryfrom as deliveryopendate, lb.deliveryto as deliverycldate, dbo.fn_ConcatReferenceNumByLoadGuid(lb.LoadGuid, 2) as ProNumber
	, cc.amount as invoiceamount, lb.cogs, lb.driver1, case when lb.carrierid is null then 0 else 1 end as assigned,
	case when lb.Status = 'BOOKED' then dateadd(hour, 30, lb.pickupfrom)
		when lb.Status = 'CANCELLED' and lb.canceldate is not null then dateadd(hour, 24, lb.canceldate)
		when lb.Status = 'Ordered' then dateadd(hour, 30, lb.pickupfrom)
		when lb.Status = 'DELIVERED' then dateadd(hour, 24, lb.DropDepartureDate)
		else null end as viewtimeout
	from CTE_LBGuid AS CTE
	INNER JOIN 	odsquery.tblloadboard as lb with (nolock)
	ON CTE.LoadGuId = lb.LoadGuId
	left join dbo.tblcarriercosts as cc with (nolock) on cc.loadguid = lb.loadguid

)
select ct.loadguid, ct.loadid, ct.carrierguid, ct.status, ct.stops, ct.pickupopendate, ct.pickupcldate
	, ct.deliveryopendate, ct.deliverycldate, ct.pronumber, ct.invoiceamount, ct.cogs, ct.driver1, ct.assigned
	from cte_activeloads ct
	where ct.carrierguid is not null
	AND (ct.cogs > 0 or ct.driver1 is not null)
	and (ct.viewtimeout is null or getdate() < ct.viewtimeout)


GO