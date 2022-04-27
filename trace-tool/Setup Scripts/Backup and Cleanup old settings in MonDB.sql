/*
	Task: SP Trace - Backup and Cleanup old settings in MonDB
	Created: Daniel@20220427
	IMPORTANT!! Follow step order & instruction in comment lines
*/

--1. Gen scripts to cleanup settings/ backup settings:
USE MonDB
GO
SELECT [Object Name] = object_name(cp.major_id),
	'DROP SIGNATURE FROM OBJECT::dbo.' + object_name(cp.major_id) + ' BY CERTIFICATE serverlevel_cert' [Cleanup scripts],-- CLEANUP OLD SETTINGS - Gen scripts, copy & run
	'ADD SIGNATURE TO OBJECT::dbo.' + object_name(cp.major_id) + ' BY CERTIFICATE serverlevel_cert WITH PASSWORD=''!@h19hPrIv()''' [Backup scripts],--BACKUP / DEPLOY SETTINGS - Gen scripts, save for later deploy in next step
	[Object Type] = obj.type_desc,
	[Cert/Key] = coalesce(c.name, a.name),
	cp.crypt_type_desc
FROM sys.crypt_properties cp
	INNER JOIN sys.objects obj ON obj.object_id = cp.major_id
	LEFT JOIN sys.certificates c ON c.thumbprint = cp.thumbprint
	LEFT JOIN sys.asymmetric_keys a ON a.thumbprint = cp.thumbprint
ORDER BY [Object Name] ASC


--2. IMPORTANT!! Just copy and save the backup settings for LATER deployment in next step. Do not run now:
/*
--BACKUP / DEPLOY SETTINGS (Copied from scripts generated above and run IN NEXT STEP)
USE MonDB
GO
ADD SIGNATURE TO OBJECT::dbo.vndba_Capture_DatabaseProperties BY CERTIFICATE serverlevel_cert WITH PASSWORD='!@h19hPrIv()'
ADD SIGNATURE TO OBJECT::dbo.vndba_capture_iosStats BY CERTIFICATE serverlevel_cert WITH PASSWORD='!@h19hPrIv()'
ADD SIGNATURE TO OBJECT::dbo.vndba_capture_SecPermissions BY CERTIFICATE serverlevel_cert WITH PASSWORD='!@h19hPrIv()'
ADD SIGNATURE TO OBJECT::dbo.vndba_capture_serverconfigdata BY CERTIFICATE serverlevel_cert WITH PASSWORD='!@h19hPrIv()'
ADD SIGNATURE TO OBJECT::dbo.vndba_capture_serverproperties BY CERTIFICATE serverlevel_cert WITH PASSWORD='!@h19hPrIv()'
ADD SIGNATURE TO OBJECT::dbo.vndba_capture_serverWaitInfo BY CERTIFICATE serverlevel_cert WITH PASSWORD='!@h19hPrIv()'
ADD SIGNATURE TO OBJECT::dbo.vnDBA_Monitor_HighCPUCaptureRequests BY CERTIFICATE serverlevel_cert WITH PASSWORD='!@h19hPrIv()'
ADD SIGNATURE TO OBJECT::dbo.vnDBA_Monitor_HighCPUCaptureSchedulers BY CERTIFICATE serverlevel_cert WITH PASSWORD='!@h19hPrIv()'
ADD SIGNATURE TO OBJECT::dbo.vndba_sp_capture_SQLAgentJobs BY CERTIFICATE serverlevel_cert WITH PASSWORD='!@h19hPrIv()'
ADD SIGNATURE TO OBJECT::dbo.vndba_sp_GetStatementExecPlanByHandle BY CERTIFICATE serverlevel_cert WITH PASSWORD='!@h19hPrIv()'
ADD SIGNATURE TO OBJECT::dbo.vndba_sp_GetStatisticsInfoBySP BY CERTIFICATE serverlevel_cert WITH PASSWORD='!@h19hPrIv()'
ADD SIGNATURE TO OBJECT::dbo.vndba_sp_LogGrowth BY CERTIFICATE serverlevel_cert WITH PASSWORD='!@h19hPrIv()'
ADD SIGNATURE TO OBJECT::dbo.vnDBA_sp_Monitor_LukasCapture BY CERTIFICATE serverlevel_cert WITH PASSWORD='!@h19hPrIv()'
ADD SIGNATURE TO OBJECT::dbo.vnDBA_sp_Monitor_WarningStateCapturePlans BY CERTIFICATE serverlevel_cert WITH PASSWORD='!@h19hPrIv()'
ADD SIGNATURE TO OBJECT::dbo.vnDBA_sp_Monitor_WarningStateCaptureRequestPlans BY CERTIFICATE serverlevel_cert WITH PASSWORD='!@h19hPrIv()'
ADD SIGNATURE TO OBJECT::dbo.vnDBA_sp_Monitor_WarningStateCaptureRequests BY CERTIFICATE serverlevel_cert WITH PASSWORD='!@h19hPrIv()'
ADD SIGNATURE TO OBJECT::dbo.vnDBA_sp_Monitor_WarningStateCaptureSchedulers BY CERTIFICATE serverlevel_cert WITH PASSWORD='!@h19hPrIv()'
ADD SIGNATURE TO OBJECT::dbo.vndba_sp_trace BY CERTIFICATE serverlevel_cert WITH PASSWORD='!@h19hPrIv()'
ADD SIGNATURE TO OBJECT::dbo.vndba_sp_traceread BY CERTIFICATE serverlevel_cert WITH PASSWORD='!@h19hPrIv()'
ADD SIGNATURE TO OBJECT::dbo.vnDBA_sp_Wait_CaptureInfo BY CERTIFICATE serverlevel_cert WITH PASSWORD='!@h19hPrIv()'
*/


--3. Run CLEANUP OLD SETTINGS in MonDB (Copied from scripts generated above and run @MonDB):
USE MonDB
GO
DROP SIGNATURE FROM OBJECT::dbo.vndba_Capture_DatabaseProperties BY CERTIFICATE serverlevel_cert
DROP SIGNATURE FROM OBJECT::dbo.vndba_capture_iosStats BY CERTIFICATE serverlevel_cert
DROP SIGNATURE FROM OBJECT::dbo.vndba_capture_SecPermissions BY CERTIFICATE serverlevel_cert
DROP SIGNATURE FROM OBJECT::dbo.vndba_capture_serverconfigdata BY CERTIFICATE serverlevel_cert
DROP SIGNATURE FROM OBJECT::dbo.vndba_capture_serverproperties BY CERTIFICATE serverlevel_cert
DROP SIGNATURE FROM OBJECT::dbo.vndba_capture_serverWaitInfo BY CERTIFICATE serverlevel_cert
DROP SIGNATURE FROM OBJECT::dbo.vnDBA_Monitor_HighCPUCaptureRequests BY CERTIFICATE serverlevel_cert
DROP SIGNATURE FROM OBJECT::dbo.vnDBA_Monitor_HighCPUCaptureSchedulers BY CERTIFICATE serverlevel_cert
DROP SIGNATURE FROM OBJECT::dbo.vndba_sp_capture_SQLAgentJobs BY CERTIFICATE serverlevel_cert
DROP SIGNATURE FROM OBJECT::dbo.vndba_sp_GetStatementExecPlanByHandle BY CERTIFICATE serverlevel_cert
DROP SIGNATURE FROM OBJECT::dbo.vndba_sp_GetStatisticsInfoBySP BY CERTIFICATE serverlevel_cert
DROP SIGNATURE FROM OBJECT::dbo.vndba_sp_LogGrowth BY CERTIFICATE serverlevel_cert
DROP SIGNATURE FROM OBJECT::dbo.vnDBA_sp_Monitor_LukasCapture BY CERTIFICATE serverlevel_cert
DROP SIGNATURE FROM OBJECT::dbo.vnDBA_sp_Monitor_WarningStateCapturePlans BY CERTIFICATE serverlevel_cert
DROP SIGNATURE FROM OBJECT::dbo.vnDBA_sp_Monitor_WarningStateCaptureRequestPlans BY CERTIFICATE serverlevel_cert
DROP SIGNATURE FROM OBJECT::dbo.vnDBA_sp_Monitor_WarningStateCaptureRequests BY CERTIFICATE serverlevel_cert
DROP SIGNATURE FROM OBJECT::dbo.vnDBA_sp_Monitor_WarningStateCaptureSchedulers BY CERTIFICATE serverlevel_cert
DROP SIGNATURE FROM OBJECT::dbo.vndba_sp_trace BY CERTIFICATE serverlevel_cert
DROP SIGNATURE FROM OBJECT::dbo.vndba_sp_traceread BY CERTIFICATE serverlevel_cert
DROP SIGNATURE FROM OBJECT::dbo.vnDBA_sp_Wait_CaptureInfo BY CERTIFICATE serverlevel_cert


--4. DROP orphaned CERT in MonDB (for creating new CERT in next steps):
USE MonDB
GO
DROP CERTIFICATE serverlevel_cert


