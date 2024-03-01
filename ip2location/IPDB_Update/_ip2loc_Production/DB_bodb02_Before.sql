truncate table TEMP_IP
ALTER INDEX [IX_IPTable_1] ON [dbo].[TEMP_IP] DISABLE
ALTER INDEX [IX_IPTable_2] ON [dbo].[TEMP_IP] DISABLE
GO
IF @@SERVERNAME = 'DBTP10C'
BEGIN
truncate table temp_ipv6_db3
END
GO
