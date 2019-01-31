
SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

/****** Object:  Stored Procedure dbo.Task_BackupFull    Script Date: 1/21/2019 4:30:10 AM ******/
CREATE PROCEDURE [dbo].[Task_BackupFull]
	@suffix varchar(20) = ''
AS

Declare @Date nvarchar(50)
Declare @Time nvarchar(50)
Set @Date = 
CAST(DATEPART(year, CURRENT_TIMESTAMP) as nvarchar) + 
CASE WHEN DATEPART(month, CURRENT_TIMESTAMP) < 10 THEN '0' + CAST(DATEPART(month, CURRENT_TIMESTAMP) as nvarchar) ELSE CAST(DATEPART(month, CURRENT_TIMESTAMP) as nvarchar) END + 
CASE WHEN DATEPART(day, CURRENT_TIMESTAMP)   < 10 THEN '0' + CAST(DATEPART(day, CURRENT_TIMESTAMP) as nvarchar)   ELSE CAST(DATEPART(day, CURRENT_TIMESTAMP) as nvarchar) END
Set @Time = 
CASE WHEN DATEPART(hour, CURRENT_TIMESTAMP)  < 10 THEN '0' + CAST(DATEPART(hour, CURRENT_TIMESTAMP) as nvarchar)  ELSE CAST(DATEPART(hour, CURRENT_TIMESTAMP) as nvarchar) END +
CASE WHEN DATEPART(minute,CURRENT_TIMESTAMP) < 10 THEN '0' + CAST(DATEPART(minute,CURRENT_TIMESTAMP) as nvarchar) ELSE CAST(DATEPART(minute,CURRENT_TIMESTAMP) as nvarchar) END

Declare @Backup_File nvarchar(200)
Set @Backup_File = '\\10.1.1.92\g$\Backup_Full\bodb_Licensee_backup_' + @Date + '_' + @Time + 
	CASE @suffix WHEN '' THEN 'DF' ELSE @suffix END + '.bak'
Declare @Desc nvarchar(255) Set @Desc = 'Full Backup for ' + @Date
Declare @Name nvarchar(128) Set @Name = @Date + ' ' + @Time + CASE @suffix WHEN '' THEN ' DIFF_BK' ELSE ' FULL_BK' END

IF @suffix = ''
	BACKUP DATABASE bodb_Licensee TO DISK = @Backup_File
	WITH DIFFERENTIAL,
	 DESCRIPTION = @Desc, NOFORMAT, NOINIT
	,NAME = @Name
	,SKIP, NOREWIND, NOUNLOAD
ELSE
	BACKUP DATABASE bodb_Licensee TO DISK = @Backup_File 
	WITH 
	 DESCRIPTION = @Desc
	,NAME = @Name










GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO


GO 
