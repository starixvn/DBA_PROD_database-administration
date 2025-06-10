truncate table TEMP_IPTable_Mini
truncate table TEMP_IP
ALTER INDEX [IX_IPTable_1] ON [dbo].[TEMP_IP] DISABLE
ALTER INDEX [IX_IPTable_2] ON [dbo].[TEMP_IP] DISABLE
GO
truncate table TEMP_KeyMap_IPv6_DB1
truncate table TEMP_KeyMap_IPv6_DB3
truncate table temp_ipv6_db1
truncate table temp_ipv6_db3
GO

IF @@SERVERNAME = 'DBCUST'
BEGIN
	truncate table TEMP_IPTable_Denied
END

GO