exec [dbo].[DBA_CloneTableStructure]
		@SourceSchema = 'dbo',
		@SourceTable = 'bettransm',
		@DestinationSchema = 'dbo',
		@DestinationTable = 'bettransm_bk_v2',
		@RecreateIfExists = 1,
		@FileGroup = '[ps_bettransm_monthly]([winlostdate])'


go

alter table bettransm switch partition 1 to bettransm_bk_v2 partition 1
alter table bettransm switch partition 2 to bettransm_bk_v2 partition 2
alter table bettransm switch partition 3 to bettransm_bk_v2 partition 3
alter table bettransm switch partition 4 to bettransm_bk_v2 partition 4
alter table bettransm switch partition 5 to bettransm_bk_v2 partition 5
alter table bettransm switch partition 6 to bettransm_bk_v2 partition 6
alter table bettransm switch partition 7 to bettransm_bk_v2 partition 7
alter table bettransm switch partition 8 to bettransm_bk_v2 partition 8
alter table bettransm switch partition 9 to bettransm_bk_v2 partition 9
alter table bettransm switch partition 10 to bettransm_bk_v2 partition 10
alter table bettransm switch partition 11 to bettransm_bk_v2 partition 11
alter table bettransm switch partition 12 to bettransm_bk_v2 partition 12


go
drop table bettransm_bk_v2


go

alter partition function pf_bettransm_monthly() merge range (N'2019-01-31 23:59:00.000')
alter partition function pf_bettransm_monthly() merge range (N'2019-02-28 23:59:00.000')
alter partition function pf_bettransm_monthly() merge range (N'2019-03-31 23:59:00.000')
alter partition function pf_bettransm_monthly() merge range (N'2019-04-30 23:59:00.000')
alter partition function pf_bettransm_monthly() merge range (N'2019-05-31 23:59:00.000')
alter partition function pf_bettransm_monthly() merge range (N'2019-06-30 23:59:00.000')
alter partition function pf_bettransm_monthly() merge range (N'2019-07-31 23:59:00.000')
alter partition function pf_bettransm_monthly() merge range (N'2019-08-31 23:59:00.000')
alter partition function pf_bettransm_monthly() merge range (N'2019-09-30 23:59:00.000')
alter partition function pf_bettransm_monthly() merge range (N'2019-10-31 23:59:00.000')
alter partition function pf_bettransm_monthly() merge range (N'2019-11-30 23:59:00.000')
alter partition function pf_bettransm_monthly() merge range (N'2019-12-31 23:59:00.000')


go

alter database [bodb_archive] remove file [Bettransm_1901]
alter database [bodb_archive] remove file [Bettransm_1902]
alter database [bodb_archive] remove file [Bettransm_1903]
alter database [bodb_archive] remove file [Bettransm_1904]
alter database [bodb_archive] remove file [Bettransm_1905]
alter database [bodb_archive] remove file [Bettransm_1906]
alter database [bodb_archive] remove file [Bettransm_1907]
alter database [bodb_archive] remove file [Bettransm_1908]
alter database [bodb_archive] remove file [Bettransm_1909]
alter database [bodb_archive] remove file [Bettransm_1910]
alter database [bodb_archive] remove file [Bettransm_1911]
alter database [bodb_archive] remove file [Bettransm_1912]


go

alter database [bodb_archive] remove filegroup [Bettransm_1901]
alter database [bodb_archive] remove filegroup [Bettransm_1902]
alter database [bodb_archive] remove filegroup [Bettransm_1903]
alter database [bodb_archive] remove filegroup [Bettransm_1904]
alter database [bodb_archive] remove filegroup [Bettransm_1905]
alter database [bodb_archive] remove filegroup [Bettransm_1906]
alter database [bodb_archive] remove filegroup [Bettransm_1907]
alter database [bodb_archive] remove filegroup [Bettransm_1908]
alter database [bodb_archive] remove filegroup [Bettransm_1909]
alter database [bodb_archive] remove filegroup [Bettransm_1910]
alter database [bodb_archive] remove filegroup [Bettransm_1911]
alter database [bodb_archive] remove filegroup [Bettransm_1912]
