exec [dbo].[DBA_CloneTableStructure]
		@SourceSchema = 'dbo',
		@SourceTable = 'Dot_Admin_LiveLog',
		@DestinationSchema = 'dbo',
		@DestinationTable = 'Dot_Admin_LiveLog_bk_v2',
		@RecreateIfExists = 1,
		@FileGroup = '[ps_LiveLog_quarterly]([transtime])'


go

alter table Dot_Admin_LiveLog switch partition 1 to Dot_Admin_LiveLog_bk_v2 partition 1
alter table Dot_Admin_LiveLog switch partition 2 to Dot_Admin_LiveLog_bk_v2 partition 2
alter table Dot_Admin_LiveLog switch partition 3 to Dot_Admin_LiveLog_bk_v2 partition 3
alter table Dot_Admin_LiveLog switch partition 4 to Dot_Admin_LiveLog_bk_v2 partition 4


go
drop table Dot_Admin_LiveLog_bk_v2


go

alter partition function pf_LiveLog_quarterly() merge range (N'2019-03-31 23:59:59.997')
alter partition function pf_LiveLog_quarterly() merge range (N'2019-06-30 23:59:59.997')
alter partition function pf_LiveLog_quarterly() merge range (N'2019-09-30 23:59:59.997')
alter partition function pf_LiveLog_quarterly() merge range (N'2019-12-31 23:59:59.997')


go

alter database [bodb_archive] remove file [LiveLog_19Q1]
alter database [bodb_archive] remove file [LiveLog_19Q2]
alter database [bodb_archive] remove file [LiveLog_19Q3]
alter database [bodb_archive] remove file [LiveLog_19Q4]


go

alter database [bodb_archive] remove filegroup [LiveLog_19Q1]
alter database [bodb_archive] remove filegroup [LiveLog_19Q2]
alter database [bodb_archive] remove filegroup [LiveLog_19Q3]
alter database [bodb_archive] remove filegroup [LiveLog_19Q4]
