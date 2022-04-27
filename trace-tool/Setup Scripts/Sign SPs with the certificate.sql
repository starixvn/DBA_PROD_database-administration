/*
	Task: SP Trace - Sign SPs with the certificate
	Created: Daniel@20220427
	IMPORTANT!! Follow step order & instruction in comment lines
*/

--Use the saved backup scripts step 1 <Backup and Cleanup old settings in MonDB>, can use the script below but it might be out-dated:
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
