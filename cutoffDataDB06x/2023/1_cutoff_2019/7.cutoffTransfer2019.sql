exec [dbo].[DBA_CloneTableStructure]
		@SourceSchema = 'dbo',
		@SourceTable = 'transfer_bk',
		@DestinationSchema = 'dbo',
		@DestinationTable = 'transfer_bk_bk_v2',
		@RecreateIfExists = 1,
		@FileGroup = '[ps_TRANSBK_monthly]([winlostdate])'


go

alter table transfer_bk switch partition 1 to transfer_bk_bk_v2 partition 1
alter table transfer_bk switch partition 2 to transfer_bk_bk_v2 partition 2
alter table transfer_bk switch partition 3 to transfer_bk_bk_v2 partition 3
alter table transfer_bk switch partition 4 to transfer_bk_bk_v2 partition 4
alter table transfer_bk switch partition 5 to transfer_bk_bk_v2 partition 5
alter table transfer_bk switch partition 6 to transfer_bk_bk_v2 partition 6
alter table transfer_bk switch partition 7 to transfer_bk_bk_v2 partition 7
alter table transfer_bk switch partition 8 to transfer_bk_bk_v2 partition 8
alter table transfer_bk switch partition 9 to transfer_bk_bk_v2 partition 9
alter table transfer_bk switch partition 10 to transfer_bk_bk_v2 partition 10
alter table transfer_bk switch partition 11 to transfer_bk_bk_v2 partition 11
alter table transfer_bk switch partition 12 to transfer_bk_bk_v2 partition 12


go
drop table transfer_bk_bk_v2


go

alter partition function pf_TRANSBK_monthly() merge range (N'2019-01-31 23:59:00.000')
alter partition function pf_TRANSBK_monthly() merge range (N'2019-02-28 23:59:00.000')
alter partition function pf_TRANSBK_monthly() merge range (N'2019-03-31 23:59:00.000')
alter partition function pf_TRANSBK_monthly() merge range (N'2019-04-30 23:59:00.000')
alter partition function pf_TRANSBK_monthly() merge range (N'2019-05-31 23:59:00.000')
alter partition function pf_TRANSBK_monthly() merge range (N'2019-06-30 23:59:00.000')
alter partition function pf_TRANSBK_monthly() merge range (N'2019-07-31 23:59:00.000')
alter partition function pf_TRANSBK_monthly() merge range (N'2019-08-31 23:59:00.000')
alter partition function pf_TRANSBK_monthly() merge range (N'2019-09-30 23:59:00.000')
alter partition function pf_TRANSBK_monthly() merge range (N'2019-10-31 23:59:00.000')
alter partition function pf_TRANSBK_monthly() merge range (N'2019-11-30 23:59:00.000')
alter partition function pf_TRANSBK_monthly() merge range (N'2019-12-31 23:59:00.000')


go

alter database [bodb_archive] remove file [TRANSBK_19M01]
alter database [bodb_archive] remove file [TRANSBK_19M02]
alter database [bodb_archive] remove file [TRANSBK_19M03]
alter database [bodb_archive] remove file [TRANSBK_19M04]
alter database [bodb_archive] remove file [TRANSBK_19M05]
alter database [bodb_archive] remove file [TRANSBK_19M06]
alter database [bodb_archive] remove file [TRANSBK_19M07]
alter database [bodb_archive] remove file [TRANSBK_19M08]
alter database [bodb_archive] remove file [TRANSBK_19M09]
alter database [bodb_archive] remove file [TRANSBK_19M10]
alter database [bodb_archive] remove file [TRANSBK_19M11]
alter database [bodb_archive] remove file [TRANSBK_19M12]


go

alter database [bodb_archive] remove filegroup [TRANSBK_19M01]
alter database [bodb_archive] remove filegroup [TRANSBK_19M02]
alter database [bodb_archive] remove filegroup [TRANSBK_19M03]
alter database [bodb_archive] remove filegroup [TRANSBK_19M04]
alter database [bodb_archive] remove filegroup [TRANSBK_19M05]
alter database [bodb_archive] remove filegroup [TRANSBK_19M06]
alter database [bodb_archive] remove filegroup [TRANSBK_19M07]
alter database [bodb_archive] remove filegroup [TRANSBK_19M08]
alter database [bodb_archive] remove filegroup [TRANSBK_19M09]
alter database [bodb_archive] remove filegroup [TRANSBK_19M10]
alter database [bodb_archive] remove filegroup [TRANSBK_19M11]
alter database [bodb_archive] remove filegroup [TRANSBK_19M12]
