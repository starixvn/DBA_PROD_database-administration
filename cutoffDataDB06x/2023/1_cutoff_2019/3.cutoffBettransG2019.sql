exec [dbo].[DBA_CloneTableStructure]
		@SourceSchema = 'dbo',
		@SourceTable = 'bettransG',
		@DestinationSchema = 'dbo',
		@DestinationTable = 'bettransG_bk_v2',
		@RecreateIfExists = 1,
		@FileGroup = '[ps_BETG_monthly]([winlostdate])'


go

alter table bettransG switch partition 1 to bettransG_bk_v2 partition 1
alter table bettransG switch partition 2 to bettransG_bk_v2 partition 2
alter table bettransG switch partition 3 to bettransG_bk_v2 partition 3
alter table bettransG switch partition 4 to bettransG_bk_v2 partition 4
alter table bettransG switch partition 5 to bettransG_bk_v2 partition 5
alter table bettransG switch partition 6 to bettransG_bk_v2 partition 6
alter table bettransG switch partition 7 to bettransG_bk_v2 partition 7
alter table bettransG switch partition 8 to bettransG_bk_v2 partition 8
alter table bettransG switch partition 9 to bettransG_bk_v2 partition 9
alter table bettransG switch partition 10 to bettransG_bk_v2 partition 10
alter table bettransG switch partition 11 to bettransG_bk_v2 partition 11
alter table bettransG switch partition 12 to bettransG_bk_v2 partition 12


go
drop table bettransG_bk_v2


go

alter partition function pf_BETG_monthly() merge range (N'2019-01-31 23:59:00.000')
alter partition function pf_BETG_monthly() merge range (N'2019-02-28 23:59:00.000')
alter partition function pf_BETG_monthly() merge range (N'2019-03-31 23:59:00.000')
alter partition function pf_BETG_monthly() merge range (N'2019-04-30 23:59:00.000')
alter partition function pf_BETG_monthly() merge range (N'2019-05-31 23:59:00.000')
alter partition function pf_BETG_monthly() merge range (N'2019-06-30 23:59:00.000')
alter partition function pf_BETG_monthly() merge range (N'2019-07-31 23:59:00.000')
alter partition function pf_BETG_monthly() merge range (N'2019-08-31 23:59:00.000')
alter partition function pf_BETG_monthly() merge range (N'2019-09-30 23:59:00.000')
alter partition function pf_BETG_monthly() merge range (N'2019-10-31 23:59:00.000')
alter partition function pf_BETG_monthly() merge range (N'2019-11-30 23:59:00.000')
alter partition function pf_BETG_monthly() merge range (N'2019-12-31 23:59:00.000')


go

alter database [bodb_archive] remove file [BETG_19M01]
alter database [bodb_archive] remove file [BETG_19M02]
alter database [bodb_archive] remove file [BETG_19M03]
alter database [bodb_archive] remove file [BETG_19M04]
alter database [bodb_archive] remove file [BETG_19M05]
alter database [bodb_archive] remove file [BETG_19M06]
alter database [bodb_archive] remove file [BETG_19M07]
alter database [bodb_archive] remove file [BETG_19M08]
alter database [bodb_archive] remove file [BETG_19M09]
alter database [bodb_archive] remove file [BETG_19M10]
alter database [bodb_archive] remove file [BETG_19M11]
alter database [bodb_archive] remove file [BETG_19M12]


go

alter database [bodb_archive] remove filegroup [BETG_19M01]
alter database [bodb_archive] remove filegroup [BETG_19M02]
alter database [bodb_archive] remove filegroup [BETG_19M03]
alter database [bodb_archive] remove filegroup [BETG_19M04]
alter database [bodb_archive] remove filegroup [BETG_19M05]
alter database [bodb_archive] remove filegroup [BETG_19M06]
alter database [bodb_archive] remove filegroup [BETG_19M07]
alter database [bodb_archive] remove filegroup [BETG_19M08]
alter database [bodb_archive] remove filegroup [BETG_19M09]
alter database [bodb_archive] remove filegroup [BETG_19M10]
alter database [bodb_archive] remove filegroup [BETG_19M11]
alter database [bodb_archive] remove filegroup [BETG_19M12]
