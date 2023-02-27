exec [dbo].[DBA_CloneTableStructure]
		@SourceSchema = 'dbo',
		@SourceTable = 'bettransRNG_bk',
		@DestinationSchema = 'dbo',
		@DestinationTable = 'bettransRNG_bk_v2',
		@RecreateIfExists = 1,
		@FileGroup = '[ps_BETRNG_monthly_new]([winlostdate])'


go

alter table bettransRNG_bk switch partition 1 to bettransRNG_bk_v2 partition 1
alter table bettransRNG_bk switch partition 2 to bettransRNG_bk_v2 partition 2
alter table bettransRNG_bk switch partition 3 to bettransRNG_bk_v2 partition 3
alter table bettransRNG_bk switch partition 4 to bettransRNG_bk_v2 partition 4
alter table bettransRNG_bk switch partition 5 to bettransRNG_bk_v2 partition 5
alter table bettransRNG_bk switch partition 6 to bettransRNG_bk_v2 partition 6
alter table bettransRNG_bk switch partition 7 to bettransRNG_bk_v2 partition 7
alter table bettransRNG_bk switch partition 8 to bettransRNG_bk_v2 partition 8
alter table bettransRNG_bk switch partition 9 to bettransRNG_bk_v2 partition 9
alter table bettransRNG_bk switch partition 10 to bettransRNG_bk_v2 partition 10
alter table bettransRNG_bk switch partition 11 to bettransRNG_bk_v2 partition 11
alter table bettransRNG_bk switch partition 12 to bettransRNG_bk_v2 partition 12


go
drop table bettransRNG_bk_v2


go

alter partition function pf_BETRNG_monthly_new() merge range (N'2019-01-31 23:59:00.000')
alter partition function pf_BETRNG_monthly_new() merge range (N'2019-02-28 23:59:00.000')
alter partition function pf_BETRNG_monthly_new() merge range (N'2019-03-31 23:59:00.000')
alter partition function pf_BETRNG_monthly_new() merge range (N'2019-04-30 23:59:00.000')
alter partition function pf_BETRNG_monthly_new() merge range (N'2019-05-31 23:59:00.000')
alter partition function pf_BETRNG_monthly_new() merge range (N'2019-06-30 23:59:00.000')
alter partition function pf_BETRNG_monthly_new() merge range (N'2019-07-31 23:59:00.000')
alter partition function pf_BETRNG_monthly_new() merge range (N'2019-08-31 23:59:00.000')
alter partition function pf_BETRNG_monthly_new() merge range (N'2019-09-30 23:59:00.000')
alter partition function pf_BETRNG_monthly_new() merge range (N'2019-10-31 23:59:00.000')
alter partition function pf_BETRNG_monthly_new() merge range (N'2019-11-30 23:59:00.000')
alter partition function pf_BETRNG_monthly_new() merge range (N'2019-12-31 23:59:00.000')


go

alter database [bodb_archive] remove file [BETRNG_19M01_new]
alter database [bodb_archive] remove file [BETRNG_19M02_new]
alter database [bodb_archive] remove file [BETRNG_19M03_new]
alter database [bodb_archive] remove file [BETRNG_19M04_new]
alter database [bodb_archive] remove file [BETRNG_19M05_new]
alter database [bodb_archive] remove file [BETRNG_19M06_new]
alter database [bodb_archive] remove file [BETRNG_19M07_new]
alter database [bodb_archive] remove file [BETRNG_19M08_new]
alter database [bodb_archive] remove file [BETRNG_19M09_new]
alter database [bodb_archive] remove file [BETRNG_19M10_new]
alter database [bodb_archive] remove file [BETRNG_19M11_new]
alter database [bodb_archive] remove file [BETRNG_19M12_new]


go

alter database [bodb_archive] remove filegroup [BETRNG_19M01_new]
alter database [bodb_archive] remove filegroup [BETRNG_19M02_new]
alter database [bodb_archive] remove filegroup [BETRNG_19M03_new]
alter database [bodb_archive] remove filegroup [BETRNG_19M04_new]
alter database [bodb_archive] remove filegroup [BETRNG_19M05_new]
alter database [bodb_archive] remove filegroup [BETRNG_19M06_new]
alter database [bodb_archive] remove filegroup [BETRNG_19M07_new]
alter database [bodb_archive] remove filegroup [BETRNG_19M08_new]
alter database [bodb_archive] remove filegroup [BETRNG_19M09_new]
alter database [bodb_archive] remove filegroup [BETRNG_19M10_new]
alter database [bodb_archive] remove filegroup [BETRNG_19M11_new]
alter database [bodb_archive] remove filegroup [BETRNG_19M12_new]
