/***
	- Created@20211124: Bobby
	- Host: Run on DB052 - new One
	- Task: Do sp_changedbowner with sa
***/

use Affiliate_12BET;
go
EXEC dbo.sp_changedbowner @loginame = N'sa';
go
use Affiliate_Aoncash;
go
EXEC dbo.sp_changedbowner @loginame = N'sa';
go
use Affiliate_Athena000;
go
EXEC dbo.sp_changedbowner @loginame = N'sa';
go
use Affiliate_itcbet;
go
EXEC dbo.sp_changedbowner @loginame = N'sa';
go
use Affiliate_MacauBet;
go
EXEC dbo.sp_changedbowner @loginame = N'sa';
go
use Affiliate_N88;
go
EXEC dbo.sp_changedbowner @loginame = N'sa';
go
use Affiliate_N8B;
go
EXEC dbo.sp_changedbowner @loginame = N'sa';
go
use Affiliate_N8G;
go
EXEC dbo.sp_changedbowner @loginame = N'sa';
go
use Affiliate_Spondemo;
go
EXEC dbo.sp_changedbowner @loginame = N'sa';
go
use AUTOINDEXRECS;
go
EXEC dbo.sp_changedbowner @loginame = N'sa';
go
use bk;
go
EXEC dbo.sp_changedbowner @loginame = N'sa';
go
use bodb_3rdProduct;
go
EXEC dbo.sp_changedbowner @loginame = N'sa';
go
use bodb_AGE;
go
EXEC dbo.sp_changedbowner @loginame = N'sa';
go
use bodb_CRM;
go
EXEC dbo.sp_changedbowner @loginame = N'sa';
go
use bodb_Licensee;
go
EXEC dbo.sp_changedbowner @loginame = N'sa';
go
use bodb_LicenseeReportArchive;
go
EXEC dbo.sp_changedbowner @loginame = N'sa';
go
use bodb_Maintenance;
go
EXEC dbo.sp_changedbowner @loginame = N'sa';
go
use bodb_MMS;
go
EXEC dbo.sp_changedbowner @loginame = N'sa';
go
use bodb_N88;
go
EXEC dbo.sp_changedbowner @loginame = N'sa';
go
use bodb_Oddsfeed;
go
EXEC dbo.sp_changedbowner @loginame = N'sa';
go
use bodb_OIC;
go
EXEC dbo.sp_changedbowner @loginame = N'sa';
go
use bodb_PlaytechCS;
go
EXEC dbo.sp_changedbowner @loginame = N'sa';
go
use bodb_RMS;
go
EXEC dbo.sp_changedbowner @loginame = N'sa';
go
use bodb_Summary;
go
EXEC dbo.sp_changedbowner @loginame = N'sa';
go
use bodb02;
go
EXEC dbo.sp_changedbowner @loginame = N'sa';
go
use Las_LogDB;
go
EXEC dbo.sp_changedbowner @loginame = N'sa';
go
use LASDB;
go
EXEC dbo.sp_changedbowner @loginame = N'sa';
go
use MonDB;
go
EXEC dbo.sp_changedbowner @loginame = N'sa';
go
use SummaryLasDB;
go
EXEC dbo.sp_changedbowner @loginame = N'sa';
go
use bodb_LicenseeReport;
go
EXEC dbo.sp_changedbowner @loginame = N'sa';
go