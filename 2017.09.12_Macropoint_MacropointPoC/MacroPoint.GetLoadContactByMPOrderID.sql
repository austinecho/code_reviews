SET STATISTICS IO ON;


EXECUTE [Macropoint].[GetLoadContactByMPOrderId] @MacroPointOrderId = 'K0RDNZ9HO7GLFTWJMA3YUQC46EBIP15V';


DECLARE @MacroPointOrderId VARCHAR(32) = 'K0RDNZ9HO7GLFTWJMA3YUQC46EBIP15V';
WITH    CTE_Load
          AS ( SELECT   o.LoadGuId ,
                        L.LoadId
               FROM     Macropoint.[Order] o
                        INNER JOIN dbo.tblLoads AS L ON o.LoadGuId = L.LoadGuId
               WHERE    o.MacroPointOrderId = @MacroPointOrderId
             )
    SELECT  l.LoadId ,
            u.EmailId
    FROM    Macropoint.[Order] o
            INNER JOIN CTE_Load AS CLG ON o.LoadGuId = CLG.LoadGuId
            INNER JOIN dbo.tblLoads l ON CLG.LoadId = l.LoadId
            INNER JOIN dbo.tblUsers u ON l.OrderBy = u.UserGuid

