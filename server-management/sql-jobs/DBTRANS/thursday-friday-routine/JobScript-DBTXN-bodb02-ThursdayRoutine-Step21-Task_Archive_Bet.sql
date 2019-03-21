DECLARE @archiveDate TABLE (rid int PRIMARY KEY IDENTITY(1,1), winlostdate smalldatetime)

INSERT INTO @archiveDate (winlostdate)
SELECT winlostdate FROM dbo.task_archivedate
ORDER BY 1

DECLARE @wldate SMALLDATETIME

SELECT @wldate = winlostdate FROM @archiveDate WHERE rid = 1   
EXEC DBARC.bodb_archive.dbo.Task_Archive_Event @winlostdate = @wldate, @Action = 'copy'

SELECT @wldate = winlostdate FROM @archiveDate WHERE rid = 2   
EXEC DBARC.bodb_archive.dbo.Task_Archive_Event @winlostdate = @wldate, @Action = 'copy'

SELECT @wldate = winlostdate FROM @archiveDate WHERE rid = 3   
EXEC DBARC.bodb_archive.dbo.Task_Archive_Event @winlostdate = @wldate, @Action = 'copy'

SELECT @wldate = winlostdate FROM @archiveDate WHERE rid = 4   
EXEC DBARC.bodb_archive.dbo.Task_Archive_Event @winlostdate = @wldate, @Action = 'copy'

SELECT @wldate = winlostdate FROM @archiveDate WHERE rid = 5   
EXEC DBARC.bodb_archive.dbo.Task_Archive_Event @winlostdate = @wldate, @Action = 'copy'

SELECT @wldate = winlostdate FROM @archiveDate WHERE rid = 6   
EXEC DBARC.bodb_archive.dbo.Task_Archive_Event @winlostdate = @wldate, @Action = 'copy'

SELECT @wldate = winlostdate FROM @archiveDate WHERE rid = 7   
EXEC DBARC.bodb_archive.dbo.Task_Archive_Event @winlostdate = @wldate, @Action = 'copy'
