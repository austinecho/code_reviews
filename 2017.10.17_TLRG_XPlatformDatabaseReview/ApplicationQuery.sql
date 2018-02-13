USE EchoOptimizer;

SET STATISTICS IO ON; 


SELECT  CASE WHEN tblCustomer.AccountStatus = '-- Please select --' THEN 'U'
             ELSE tblCustomer.AccountStatus
        END AS AccountStatus ,
        CASE WHEN tblCustomer.ParentAccountId != tblCustomer.CustomerGuid
             THEN tblCustomer.ParentAccountId
             ELSE CAST(CAST(0 AS BINARY) AS UNIQUEIDENTIFIER)
        END AS ParentCustomerGuid ,
        tblCustomer.CustomerGuid ,
        tblCustomer.CustomerName ,
        tblCustomer.CustomerId ,
        tblCustomer.CustId ,
        CASE WHEN tblCustomer.InActive = 0 THEN 1
             ELSE 0
        END AS IsActive ,
        tblCustomerExtended.IsTLRGEnabled
FROM    tblCustomer
        LEFT JOIN tblCustomerExtended ON tblCustomer.CustomerGuid = tblCustomerExtended.CustomerGuid
WHERE   tblCustomer.CustomerGuid = 'A296635A-D4E2-4269-8F78-0004AC1AFB60'

--============================================================
WITH CTE_TLRGEnabled
AS
(
SELECT CustomerGuid
FROM dbo.tblCustomerExtended
WHERE IsTLRGEnabled = 1
)

SELECT  CASE WHEN tblCustomer.AccountStatus = '-- Please select --' THEN 'U'
             ELSE tblCustomer.AccountStatus
        END AS AccountStatus ,
        CASE WHEN tblCustomer.ParentAccountId != tblCustomer.CustomerGuid
             THEN tblCustomer.ParentAccountId
             ELSE CAST(CAST(0 AS BINARY) AS UNIQUEIDENTIFIER)
        END AS ParentCustomerGuid ,
        tblCustomer.CustomerGuid ,
        tblCustomer.CustomerName ,
        tblCustomer.CustomerId ,
        tblCustomer.CustId ,
        CASE WHEN tblCustomer.InActive = 0 THEN 1
             ELSE 0
        END IsActive,
		1 AS isTLRGEnabled 
FROM    tblCustomer WITH (INDEX(PK_tblCustomer))
INNER JOIN CTE_TLRGEnabled AS cg
ON tblcustomer.CustomerGuid = cg.CustomerGuid 
ORDER BY [CustomerName];
--====================================================================================================================

CREATE NONCLUSTERED INDEX DT_Test ON dbo.tblCustomerExtended (IsTLRGEnabled) INCLUDE (CustomerGuid)
DROP INDEX DT_Test ON dbo.tblCustomerExtended

SELECT TOP 100
        tblCustomer.CustomerGuid ,
        tblCustomer.CustomerName ,
        tblCustomer.CustomerId ,
        tblCustomer.CustId ,
        tblCustomer.InActive
FROM    tblCustomer
WHERE   [CustomerName] != ''
ORDER BY [CustomerName];