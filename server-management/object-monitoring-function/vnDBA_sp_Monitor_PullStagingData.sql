ALTER PROCEDURE	dbo.vnDBA_sp_Monitor_PullStagingData
AS
/*
	Creator:	20160803@Billy
	Task:		Objects monitoring function - Objects staging data pulling - [Redmine: #58941]
	Database:	DBTP.MonDB
	
	Revisions:
		- 20160803@Billy:	v2.01	*start tracking*
*/
BEGIN
    SET NOCOUNT ON;

	CREATE TABLE	#remotes (
						remote_name			SYSNAME
					,	is_done				BIT
					);

	CREATE TABLE	#olddata (
						info_date					DATETIME			NOT NULL
					,	server_name					SYSNAME				NOT NULL
					,	xml_data					NVARCHAR(MAX)		NULL
					);

	DECLARE	@remote_name	NVARCHAR(255)
		,	@query			NVARCHAR(MAX)
		;

	INSERT INTO	#remotes
		(	    remote_name, is_done)
	SELECT	srl.remote_name, 0
	FROM	dbo.vnDBA_Servers_RemoteList AS srl WITH (NOLOCK)
	WHERE	srl.object_monitored = 1;

	INSERT	#olddata
		(	   info_date,    server_name,    xml_data)
	SELECT	ms.info_date, ms.server_name, ms.xml_data
	FROM	dbo.vnDBA_Monitor_Staging AS ms;

	WHILE	0 = 0
	BEGIN
	    UPDATE	TOP(1) #remotes
		SET		@remote_name = remote_name
			,	is_done = 1
		WHERE	is_done = 0;

		IF	@@ROWCOUNT = 0
			BREAK;

		IF	@@SERVERNAME LIKE 'SIT%'
		BEGIN
			DELETE	ms
			FROM	dbo.vnDBA_Monitor_Staging ms
			WHERE	ms.server_name = N'SIT' + @remote_name;
		END;
		ELSE
		BEGIN
			DELETE	ms
			FROM	dbo.vnDBA_Monitor_Staging ms
			WHERE	ms.server_name = @remote_name;
		END;

		SELECT	@query = N'
					INSERT INTO	dbo.vnDBA_Monitor_Staging
						(	info_date
						,	server_name
						,	xml_data
						)
					SELECT	info_date
						,	server_name
						,	xml_data
					FROM	' + @remote_name + N'.MonDB.dbo.vnDBA_Monitor_Staging WITH (NOLOCK);
				';

		BEGIN TRY
			EXECUTE	sys.sp_executesql @stmt = @query;
		END TRY
		BEGIN CATCH
			DECLARE	@msg NVARCHAR(MAX);
			
			SELECT	@msg = ERROR_MESSAGE();
			
			RAISERROR(@msg, 0, 0) WITH NOWAIT;
		END CATCH;

	END;

	INSERT INTO	dbo.vnDBA_Monitor_Staging
		(	  info_date,   server_name,   xml_data)
	SELECT	o.info_date, o.server_name, o.xml_data
	FROM	#olddata AS o
	WHERE	o.server_name NOT IN (SELECT ms.server_name FROM dbo.vnDBA_Monitor_Staging AS ms WITH (NOLOCK));

	DROP TABLE	#remotes
			,	#olddata
			;
END;
GO