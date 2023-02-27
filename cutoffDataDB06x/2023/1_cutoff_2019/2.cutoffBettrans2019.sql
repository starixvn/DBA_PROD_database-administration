exec [dbo].[DBA_CloneTableStructure]
		@SourceSchema = 'dbo',
		@SourceTable = 'bettrans_bk',
		@DestinationSchema = 'dbo',
		@DestinationTable = 'bettrans_bk_v2',
		@RecreateIfExists = 1,
		@FileGroup = '[ps_bettrans_monthly]([winlostdate])'


go

alter table bettrans_bk switch partition 1 to bettrans_bk_v2 partition 1
alter table bettrans_bk switch partition 2 to bettrans_bk_v2 partition 2
alter table bettrans_bk switch partition 3 to bettrans_bk_v2 partition 3
alter table bettrans_bk switch partition 4 to bettrans_bk_v2 partition 4
alter table bettrans_bk switch partition 5 to bettrans_bk_v2 partition 5
alter table bettrans_bk switch partition 6 to bettrans_bk_v2 partition 6
alter table bettrans_bk switch partition 7 to bettrans_bk_v2 partition 7
alter table bettrans_bk switch partition 8 to bettrans_bk_v2 partition 8
alter table bettrans_bk switch partition 9 to bettrans_bk_v2 partition 9
alter table bettrans_bk switch partition 10 to bettrans_bk_v2 partition 10
alter table bettrans_bk switch partition 11 to bettrans_bk_v2 partition 11
alter table bettrans_bk switch partition 12 to bettrans_bk_v2 partition 12


go
drop table bettrans_bk_v2


go

alter partition function pf_bettrans_monthly() merge range (N'2019-01-31 23:59:00.000')
alter partition function pf_bettrans_monthly() merge range (N'2019-02-28 23:59:00.000')
alter partition function pf_bettrans_monthly() merge range (N'2019-03-31 23:59:00.000')
alter partition function pf_bettrans_monthly() merge range (N'2019-04-30 23:59:00.000')
alter partition function pf_bettrans_monthly() merge range (N'2019-05-31 23:59:00.000')
alter partition function pf_bettrans_monthly() merge range (N'2019-06-30 23:59:00.000')
alter partition function pf_bettrans_monthly() merge range (N'2019-07-31 23:59:00.000')
alter partition function pf_bettrans_monthly() merge range (N'2019-08-31 23:59:00.000')
alter partition function pf_bettrans_monthly() merge range (N'2019-09-30 23:59:00.000')
alter partition function pf_bettrans_monthly() merge range (N'2019-10-31 23:59:00.000')
alter partition function pf_bettrans_monthly() merge range (N'2019-11-30 23:59:00.000')
alter partition function pf_bettrans_monthly() merge range (N'2019-12-31 23:59:00.000')


go

alter database [bodb_archive] remove file [Bettrans_1901]
alter database [bodb_archive] remove file [Bettrans_1902]
alter database [bodb_archive] remove file [Bettrans_1903]
alter database [bodb_archive] remove file [Bettrans_1904]
alter database [bodb_archive] remove file [Bettrans_1905]
alter database [bodb_archive] remove file [Bettrans_1906]
alter database [bodb_archive] remove file [Bettrans_1907]
alter database [bodb_archive] remove file [Bettrans_1908]
alter database [bodb_archive] remove file [Bettrans_1909]
alter database [bodb_archive] remove file [Bettrans_1910]
alter database [bodb_archive] remove file [Bettrans_1911]
alter database [bodb_archive] remove file [Bettrans_1912]


go

alter database [bodb_archive] remove filegroup [Bettrans_1901]
alter database [bodb_archive] remove filegroup [Bettrans_1902]
alter database [bodb_archive] remove filegroup [Bettrans_1903]
alter database [bodb_archive] remove filegroup [Bettrans_1904]
alter database [bodb_archive] remove filegroup [Bettrans_1905]
alter database [bodb_archive] remove filegroup [Bettrans_1906]
alter database [bodb_archive] remove filegroup [Bettrans_1907]
alter database [bodb_archive] remove filegroup [Bettrans_1908]
alter database [bodb_archive] remove filegroup [Bettrans_1909]
alter database [bodb_archive] remove filegroup [Bettrans_1910]
alter database [bodb_archive] remove filegroup [Bettrans_1911]
alter database [bodb_archive] remove filegroup [Bettrans_1912]
