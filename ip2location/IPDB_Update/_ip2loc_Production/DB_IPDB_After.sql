ALTER INDEX [CIX_IPTable]  ON [dbo].[TEMP_IP] REBUILD PARTITION = ALL WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = ON, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
ALTER INDEX [IX_IPTable_1] ON [dbo].[TEMP_IP] REBUILD PARTITION = ALL WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = ON, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
ALTER INDEX [IX_IPTable_2] ON [dbo].[TEMP_IP] REBUILD PARTITION = ALL WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = ON, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO

ALTER INDEX [CIX_ipTable_Mini] ON [dbo].[TEMP_IPTable_Mini] REBUILD PARTITION = ALL WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = ON, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
ALTER INDEX [IX_CountrySHORT]  ON [dbo].[TEMP_IPTable_Mini] REBUILD PARTITION = ALL WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = ON, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO

IF @@SERVERNAME = 'DBCUST'
BEGIN
	DELETE FROM IPVN            INSERT INTO IPVN                                         SELECT ipFrom, ipTO, 0            FROM TEMP_IPTable_Mini WITH (ROWLOCK) WHERE countrySHORT = 'VN'
	DELETE FROM IPv4Restriction INSERT INTO IPv4Restriction (ipFrom, ipTo, countrySHORT) SELECT ipFrom, ipTo, countrySHORT FROM TEMP_IPTable_Mini WITH (ROWLOCK) WHERE countrySHORT IN ('VN','AU','HK','PH','SG')
	DELETE FROM IPv6Restriction INSERT INTO IPv6Restriction (ipFrom, ipTo, countrySHORT) SELECT ipFrom, ipTo, country_code FROM TEMP_IPv6_DB1     WITH (ROWLOCK) WHERE country_code IN ('VN','AU','HK','PH','SG')
END
GO

IF @@SERVERNAME = 'DBCUST'
BEGIN
	exec sp_rename 'IPTable_Denied','Denied_T3'
	exec sp_rename 'TEMP_IPTable_Denied','IPTable_Denied'
	exec sp_rename 'Denied_T3', 'TEMP_IPTable_Denied'
END
GO

exec sp_rename 'IPTable','T'
exec sp_rename 'TEMP_IP','IPTable'
exec sp_rename 'T', 'TEMP_IP'

exec sp_rename 'IPTable_Mini','T2'
exec sp_rename 'TEMP_IPTable_Mini','IPTable_Mini'
exec sp_rename 'T2', 'TEMP_IPTable_Mini'
GO

exec sp_rename 'IPv6_DB1','T1'
exec sp_rename 'TEMP_IPv6_DB1','IPv6_DB1'
exec sp_rename 'T1', 'TEMP_IPv6_DB1'

exec sp_rename 'IPv6_DB3','T3'
exec sp_rename 'TEMP_IPv6_DB3','IPv6_DB3'
exec sp_rename 'T3', 'TEMP_IPv6_DB3'

exec sp_rename 'KeyMap_IPv6_DB1','TA1'
exec sp_rename 'TEMP_KeyMap_IPv6_DB1','KeyMap_IPv6_DB1'
exec sp_rename 'TA1', 'TEMP_KeyMap_IPv6_DB1'

exec sp_rename 'KeyMap_IPv6_DB3','TA3'
exec sp_rename 'TEMP_KeyMap_IPv6_DB3','KeyMap_IPv6_DB3'
exec sp_rename 'TA3', 'TEMP_KeyMap_IPv6_DB3'
GO


---insert finished date to new table IPDBHistory
IF OBJECT_ID (N'IPDBHistory', N'U') IS NOT NULL
BEGIN
	INSERT INTO IPDBHistory
	SELECT GETDATE(), 'Monthly updating finished.'
END