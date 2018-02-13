USE CarrierCommission

DECLARE @OldCount BIGINT
SET @OldCount = (SELECT COUNT(1) FROM History.FileImport WHERE DATEDIFF(DAY, [ImportDate], GETDATE()) > 60)

BEGIN TRAN 
WHILE @OldCount > 0
BEGIN
DELETE TOP (100)
FROM History.FileImport
WHERE DATEDIFF(DAY, [ImportDate], GETDATE()) > 60

SET @OldCount = (SELECT COUNT(1) FROM History.FileImport WHERE DATEDIFF(DAY, [ImportDate], GETDATE()) > 60)
END

--ROLLBACK