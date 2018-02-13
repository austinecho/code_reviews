DROP TABLE #MergedSaveAndSendTable
DROP TABLE #HoldJoin

DECLARE @customerGuid UNIQUEIDENTIFIER = 'A246B8A0-78E6-4983-9E26-A6A40315C883'
DECLARE @TT_SaveAndSendEmails TT_SaveAndSendEmail
DECLARE @emailType INT = 1
DECLARE @userGuid uniqueidentifier = 'EAEBEC6C-B31E-46BD-9FA4-91D5253B5F9F'

INSERT INTO @TT_SaveAndSendEmails(EmailAddress)
VALUES('LTLCore@echo.com'), ('aayerdi@u.northwestern.edu')

SELECT * INTO #MergedSaveAndSendTable FROM
(
	SELECT s.*, t.SaveAndSendEmailId As OriginalId FROM @TT_SaveAndSendEmails s
	FULL OUTER JOIN (SELECT SaveAndSendEmailId, EmailAddress FROM dbo.SaveAndSendEmail (NOLOCK) 
			            WHERE CustomerGuid = @customerGuid 
						AND EmailType = @emailType) AS t
	ON t.EmailAddress = s.EmailAddress
) AS MergedSaveAndSendTable
		

SELECT @customerGuid AS CustomerGuid, @emailType AS EmailType, s.*
INTO #HoldJoin
FROM @TT_SaveAndSendEmails s

SELECT * from #HoldJoin
SELECT * from #MergedSaveAndSendTable

--INSERT INTO dbo.SaveAndSendEmail(CustomerGuid, EmailType, EmailAddress, CreatedDate, CreatedBy)
SELECT @customerGuid, @emailType, EmailAddress, GETDATE(), @userGuid
FROM #MergedSaveAndSendTable
WHERE OriginalId IS NULL

SELECT * 
FROM dbo.SaveAndSendEmail email
INNER JOIN #MergedSaveAndSendTable t ON t.OriginalId = email.SaveAndSendEmailId
WHERE t.EmailAddress IS NULL


select * from dbo.SaveAndSendEmail