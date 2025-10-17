/*<info serverAlias="DBTXN-MonDB,DBCUST-MonDB,DBPRO-MonDB,DBACC-MonDB,DBAGE-MonDB,DBONUSER-MonDB,DBWH-MonDB,DBBOF-MonDB,DBAFF-MonDB,DBTP-MonDB,DBSABAPLAY" executers="wsv_nap,vnteam" selecters="" viewers="" isFunction="0" isNested="0"></info>*/
ALTER PROCEDURE [dbo].[vndba_sp_trace_WebApp]
	@Site VARCHAR(20),
	@TraceTimer INT = 30,
	@TextDataLike NVARCHAR(256),
	@TextDataLike2 NVARCHAR(256) = '',
	@TextDataLike3 NVARCHAR(256) = '',
	@TextDataLike4 NVARCHAR(256) = '',
	@TextDataLike5 NVARCHAR(256) = '',
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
			20191211@Daniel: on_user DB: Support DB05BK1 & Remove DBTP
			20201118@Daniel: Update info/code support latest server HA structure
			20230619@Daniel: Fix app name filter
			20240309@Daniel: Change web login, support NAP policy, saparate account for AFF site
			20240916@Daniel: support login asv_cust (API create cust), DBCUST.GlobCustDB (scale-out)
			20240916@Daniel: support login DBsabaplay server/login sabaplay_spbu, Dot_Intg and site Sabaplay
		
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

	IF (ISNULL(@Site, '') NOT IN ('NAP','EX-NAP','DW','PRMS','LC','ALPHA','LICENSEE', 'AFF', 'MEMBER', 'FPS', 'FD', 'OWP','Ploutos','SABAPLAY'))
	BEGIN
		SET @ErrorMsg = '@Site input error! Please set one site to filter (NAP/EX-NAP/DW/PRMS/LC/ALPHA/LICENSEE/AFF/MEMBER/FPS/FD/OWP/Ploutos/SABAPLAY). Ex: @Site = ''NAP'''
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

	DECLARE @LoginNameLike NVARCHAR(30),
		@LoginNameLike2 NVARCHAR(30) = '',
		@LoginNameLike3 NVARCHAR(30) = '',
		@LoginNameLike4 NVARCHAR(30) = '',
		@LoginNameLike5 NVARCHAR(30) = '',
		@DatabaseNameLike NVARCHAR(30), 
		@DatabaseNameLike2 NVARCHAR(30) = '',
		@DatabaseNameLike3 NVARCHAR(30) = '',
		@DatabaseNameLike4 NVARCHAR(30) = '',
		@DatabaseNameLike5 NVARCHAR(30) = ''

	SELECT 
		@LoginNameLike = 
			CASE WHEN @Site = 'NAP' THEN 'wsv_nap%'
			WHEN @Site = 'EX-NAP' THEN 'wsv_xnap'
			WHEN @Site = 'AFF' THEN 'wsv_aff'
			WHEN @Site = 'DW' THEN 'dwrs'
			WHEN @Site = 'PRMS' THEN 'wsv_rms'
			WHEN @Site = 'LC' THEN 'bodbChartNet'					
			WHEN @Site = 'ALPHA' THEN 'wsv_alp%'
			WHEN @Site = 'LICENSEE' THEN 'wsv_lap'
			WHEN @Site = 'MEMBER' THEN 'svc_tig'
			WHEN @Site = 'FPS' THEN 'fps%'
			WHEN @Site = 'FD' THEN 'wsv_wasa'
			WHEN @Site = 'OWP' THEN 'wsv_owp'
			WHEN @Site = 'Ploutos' THEN 'wsv_pts'
			WHEN @Site = 'SABAPLAY' THEN 'sabaplay_spbu'
		END
		
	SELECT @LoginNameLike2 = CASE WHEN @Site IN ('NAP') THEN 'wsv_pol' WHEN  @Site = 'SABAPLAY' THEN 'Dot_Intg' END
	SELECT @LoginNameLike3 = CASE WHEN @Site IN ('NAP','EX-NAP','ALPHA','MEMBER') THEN 'asv_cust'  WHEN  @Site = 'SABAPLAY' THEN 'oneseal_integration' END --support acc called from API on some sites
	SELECT @LoginNameLike4 = CASE WHEN @Site IN ('NAP') THEN 'oneseal_integration' end
		
	IF @@SERVERNAME IN('DBCUST', 'DB233', 'DB230\SQLSERVER2008R2', 'SITDBCUST')
		SELECT @DatabaseNameLike = '%custDB', @DatabaseNameLike2 = 'NAP_UserControl', @DatabaseNameLike3 = 'N88_UserControl',
			@DatabaseNameLike4 = 'SiteConfig', @DatabaseNameLike5 = 'IPDB'
	ELSE IF @Site = 'AFF'
		SET @DatabaseNameLike = 'Affiliate_%'
	ELSE IF @Site = 'FPS'
		SET @DatabaseNameLike = 'FPS_%'
	ELSE IF @Site = 'FD'
		SELECT @DatabaseNameLike = 'SPU_FraudDetection', @DatabaseNameLike2 = 'bodb%'
	ELSE IF @Site = 'SABAPLAY'
		SELECT @DatabaseNameLike = 'Saba%'
	ELSE
		SET @DatabaseNameLike = 'bodb%'
	
	IF (@@SERVERNAME IN('DB05', 'DB03', 'DB05BK1', 'SITDB05', 'SITDB03', 'SITDB05BK1') AND @Site IN('NAP', 'EXT-NAP', 'ALPHA', 'MEMBER'))
		SELECT @DatabaseNameLike2 = 'ON_USER', @DatabaseNameLike3 = 'IPDB'

	IF (@@SERVERNAME IN('DB052', 'DB053', 'SITDB052', 'SITDB053') AND @Site = 'NAP')
		SET @DatabaseNameLike2 = 'bk'

	IF (@@SERVERNAME IN('DBTRANS', 'DB06', 'DB061','SITDBTRANS', 'SITDB06', 'SITDB061') AND @Site IN('NAP', 'EXT-NAP', 'ALPHA', 'MEMBER'))
		SET @DatabaseNameLike2 = 'IPDB'

	IF (@@SERVERNAME LIKE '%dbsabaplay%')
		SELECT @DatabaseNameLike2 = 'WalletBridge%'

	EXEC vndba_sp_Trace
		@TraceTimer = @TraceTimer,
		@AppNameLike = '%SqlClient Data Provider',
		@LoginNameLike = @LoginNameLike,
		@LoginNameLike2 = @LoginNameLike2,
		@LoginNameLike3 = @LoginNameLike3,
		@LoginNameLike4 = @LoginNameLike4,
		@LoginNameLike5 = @LoginNameLike5,
		@DatabaseNameLike = @DatabaseNameLike,
		@DatabaseNameLike2 = @DatabaseNameLike2,
		@DatabaseNameLike3 = @DatabaseNameLike3,
		@DatabaseNameLike4 = @DatabaseNameLike4,
		@DatabaseNameLike5 = @DatabaseNameLike5,
		@MinCPU = 0,
		@TextDataLike = @TextDataLike,
		@TextDataLike2 = @TextDataLike2,
		@TextDataLike3 = @TextDataLike3,	
		@TextDataLike4 = @TextDataLike4,
		@TextDataLike5 = @TextDataLike5,
		@TraceStartEvents = @TraceStartEvents,
		@mode = @mode,
		@HasError = @HasError output,
		@ErrorMsg = @ErrorMsg output
END


