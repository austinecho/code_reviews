DECLARE @DaysToDelete INT,
@DeleteSize INT 
SET @DaysToDelete = 30
SET @DeleteSize = 50000


DECLARE @RowCount INT; 
SET @RowCount = 1;

WHILE @RowCount > 0
    BEGIN
        BEGIN TRY 
            BEGIN TRAN; 
            DELETE TOP ( @DeleteSize )
            FROM    History.FileImport
            WHERE   DATEDIFF(DAY, ImportDate, GETDATE()) > @DaysToDelete;

SET @RowCount =  @@ROWCOUNT

            COMMIT;
        END TRY

        BEGIN CATCH
            SELECT  ERROR_NUMBER() AS ErrorNumber ,
                    ERROR_SEVERITY() AS ErrorSeverity ,
                    ERROR_STATE() AS ErrorState ,
                    ERROR_PROCEDURE() AS ErrorProcedure ,
                    ERROR_LINE() AS ErrorLine ,
                    ERROR_MESSAGE() AS ErrorMessage;

            SET @RowCount = 0;

            ROLLBACK TRANSACTION;
        END CATCH; 
    END;