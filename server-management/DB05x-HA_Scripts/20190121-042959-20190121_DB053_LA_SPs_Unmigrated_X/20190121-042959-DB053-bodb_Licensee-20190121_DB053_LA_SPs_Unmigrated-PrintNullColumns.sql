
SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

/****** Object:  Stored Procedure dbo.PrintNullColumns    Script Date: 1/21/2019 4:30:10 AM ******/
CREATE PROC dbo.PrintNullColumns(@tablename sysname)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @query nvarchar(max);
    DECLARE @column sysname;
    DECLARE columns_cursor CURSOR FOR
        SELECT c.name
        FROM sys.tables t JOIN sys.columns c ON t.object_id = c.object_id
        WHERE t.name = @tablename AND c.is_nullable = 1;
    OPEN columns_cursor;
    FETCH NEXT FROM columns_cursor INTO @column;
    WHILE (@@FETCH_STATUS = 0)
    BEGIN
        SET @query = N'
        DECLARE @c int
        SELECT @c = COUNT(*) FROM ' + @tablename + ' WHERE ' + @column + N' IS NULL
        IF (@c > 0)
            PRINT (''' + @tablename + ' - '+@column + N''');'
        EXEC (@query);

        FETCH NEXT FROM columns_cursor INTO @column;
    END
    CLOSE columns_cursor;
    DEALLOCATE columns_cursor;
    SET NOCOUNT OFF;
    RETURN;
END;
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO


GO 
