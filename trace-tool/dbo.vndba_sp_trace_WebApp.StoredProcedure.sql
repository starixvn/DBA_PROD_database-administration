/*<info serverAlias="DBTXN-MonDB,DBCUST-MonDB,DBPRO-MonDB,DBACC-MonDB,DBAGE-MonDB,DBONUSER-MonDB,DBWH-MonDB,DB042-MonDB,DBAFF-MonDB,FPSDEV-PerfMonDB,FPSDI-PerfMonDB,FPSLICALL-PerfMonDB" executers="bodbAdminNet,vnteam" selecters="" viewers="" isFunction="0" isNested="0"></info>*/
ALTER PROCEDURE [vndba_sp_trace_WebApp]
	@Site VARCHAR(20),
	@TraceTimer INT = 30,
	@TextDataLike NVARCHAR(256),
	@TextDataLike2 NVARCHAR(256) = '',
	@TextDataLike3 NVARCHAR(256) = '',
	@TextDataLike4 NVARCHAR(256) = '',	
	@TraceStartEvents BIT = 0,
	@Mode TINYINT = 0,
	@HasError BIT = 0 OUTPUT,
	@ErrorMsg VARCHAR(200) = '' OUTPUT	
AS
/*
		Created: Daniel
		Date: 20160831
		Task: Trace SP/sql statements that issued from web apps
		DB: All servers - db master
		
		Revisions:
			20161202@Daniel: Support more site
			20180912@Daniel: Support DBCUST.NAP_UserControl
			20180917@Daniel: Support Core .NET service app
			20191125@Daniel: Support site 'Ploutos'
		
		Parameter's Explanation:
		  . Site: Input a site name to filter, choose one of the following:
		    + Alpha
		    + NAP
		    + Licensee
		    + Member
		    Ex: @Site = 'NAP'
		    
		  . @TraceTimer: Set trace duration string in seconds, not allow set more than 30min/1800s
		  . @TraceStartEvents: Include trace starting events, in case commands started but cannot complete due to problem or long run time-out queries
		  . @Mode: run mode
		    + 0: User need to wait for trace done then get the result
		    + 1: Expert mode, just start trace and return trace info  for user to check later
		  
	  Test:
	  EXEC MonDB.dbo.vndba_sp_trace_WebApp
  	@Site = 'FD',
	@TraceTimer = 10,
  	@TextDataLike = '%DataCapture%',
  	@mode = 0

*/
BEGIN

	SET NOCOUNT ON

	IF (ISNULL(@Site, '') NOT IN ('NAP','EX-NAP','DW','PRMS','LC','ALPHA','LICENSEE', 'AFF', 'MEMBER', 'FPS', 'FD', 'OWP','Ploutos'))
	BEGIN
		SET @ErrorMsg = '@Site input error! Please set one site to filter (NAP/EX-NAP/DW/PRMS/LC/ALPHA/LICENSEE/AFF/MEMBER/FPS/FD/OWP/Ploutos). Ex: @Site = ''NAP'''
		SET @HasError = 1
		PRINT @ErrorMsg
		RETURN
	END

	IF (ISNULL(@TraceTimer,0) > 180)
	BEGIN
		SET @ErrorMsg = 'Error: Not allow long-running trace more than 3 minutes'
		SET @HasError = 1
		PRINT @ErrorMsg
		RETURN
	END

	DECLARE @LoginNameLike NVARCHAR(30), @DatabaseNameLike NVARCHAR(30), @DatabaseNameLike2 NVARCHAR(30) = ''

	SELECT 
		@LoginNameLike = 
			CASE WHEN @Site IN ('NAP', 'AFF') THEN 'bodbAdminNet%'
			WHEN @Site = 'EX-NAP' THEN 'bodbExtAccNet'
			WHEN @Site = 'DW' THEN 'dwrs'
			WHEN @Site = 'PRMS' THEN 'bodbRMSNet'
			WHEN @Site = 'LC' THEN 'bodbChartNet'					
			WHEN @Site = 'ALPHA' THEN 'bodbDownlineNet%'
			WHEN @Site = 'LICENSEE' THEN 'bodbLicenseeNet'
			WHEN @Site = 'MEMBER' THEN 'Dot_Member'
			WHEN @Site = 'FPS' THEN 'fps%'
			WHEN @Site = 'FD' THEN 'bodbSPUNet'
			WHEN @Site = 'OWP' THEN 'bodbOWPNet'
			WHEN @Site = 'Ploutos' THEN 'bodbPloutosNet'
		END
		
	IF @@SERVERNAME IN('DBCUST', 'DB233', 'DB230\SQLSERVER2008R2')
		SELECT @DatabaseNameLike = 'custDB', @DatabaseNameLike2 = 'NAP_UserControl'
	ELSE IF @Site = 'AFF'
		SET @DatabaseNameLike = 'Affiliate_%'
	ELSE IF @Site = 'FPS'
		SET @DatabaseNameLike = 'FPS_%'
	ELSE IF @Site = 'FD'
		SELECT @DatabaseNameLike = 'SPU_FraudDetection', @DatabaseNameLike2 = 'bodb%'
	ELSE 
		SET @DatabaseNameLike = 'bodb%'
	
	IF (@@SERVERNAME IN('DB05', 'DB03', 'DBTP') AND @Site IN('NAP', 'EXT-NAP', 'ALPHA', 'MEMBER'))
		SET @DatabaseNameLike2 = 'ON_USER'

	IF (@@SERVERNAME IN('DB052', 'DB054') AND @Site = 'NAP')
		SET @DatabaseNameLike2 = 'bk'

	EXEC vndba_sp_Trace
		@TraceTimer = @TraceTimer,
		@AppNameLike = '%.Net SqlClient Data Provider',
		@LoginNameLike = @LoginNameLike,
		@DatabaseNameLike = @DatabaseNameLike,
		@DatabaseNameLike2 = @DatabaseNameLike2,
		@MinCPU = 0,
		@TextDataLike = @TextDataLike,
		@TextDataLike2 = @TextDataLike2,
		@TextDataLike3 = @TextDataLike3,	
		@TextDataLike4 = @TextDataLike4,
		@TraceStartEvents = @TraceStartEvents,
		@mode = @mode,
		@HasError = @HasError output,
		@ErrorMsg = @ErrorMsg output
END


