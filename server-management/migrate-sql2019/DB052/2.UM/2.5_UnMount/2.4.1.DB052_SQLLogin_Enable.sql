/***
	- Created@20211124: Bobby
	- Host: Run on DB052 - new One
	- Task: SQLLogin - Enable
***/
USE master;
GO
ALTER LOGIN [bodbAdminNet] ENABLE;
ALTER LOGIN [bodbChartNet] ENABLE;
ALTER LOGIN [bodbDownlineNet] ENABLE;
ALTER LOGIN [bodbDownlineNetView] ENABLE;
ALTER LOGIN [bodbExtAccNet] ENABLE;
ALTER LOGIN [bodbinternalNet] ENABLE;
ALTER LOGIN [bodbLicenseeNet] ENABLE;
ALTER LOGIN [bodbPloutosNet] ENABLE;
ALTER LOGIN [bodbRMSNet] ENABLE;
ALTER LOGIN [bodbSPUNet] ENABLE;
ALTER LOGIN [DataSync] ENABLE;
ALTER LOGIN [dba_Cert_User] ENABLE;
ALTER LOGIN [Dot_3rdparty] ENABLE;
ALTER LOGIN [Dot_Admin] ENABLE;
ALTER LOGIN [Dot_Casino] ENABLE;
ALTER LOGIN [Dot_Member] ENABLE;
ALTER LOGIN [dwrs2] ENABLE;
ALTER LOGIN [portal] ENABLE;
ALTER LOGIN [ServerMonitor] ENABLE;
ALTER LOGIN [SqlLink] ENABLE;
GO