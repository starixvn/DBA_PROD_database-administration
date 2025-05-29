truncate table TEMP_IPTable_Denied

IF @@SERVERNAME <> 'DBCUST'
BEGIN
	truncate table TEMP_IPTable_Mini
END

GO
