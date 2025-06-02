exec sp_rename 'IPTable_Mini','T2'
exec sp_rename 'TEMP_IPTable_Mini','IPTable_Mini'
exec sp_rename 'T2', 'TEMP_IPTable_Mini'

exec sp_rename 'IPTable_Denied','T3'
exec sp_rename 'TEMP_IPTable_Denied','IPTable_Denied'
exec sp_rename 'T3', 'TEMP_IPTable_Denied'
GO
