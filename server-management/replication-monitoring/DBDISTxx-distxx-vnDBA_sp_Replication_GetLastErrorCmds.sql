SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO
CREATE PROCEDURE	dbo.vnDBA_sp_Replication_GetLastErrorCmds
						@quantity		INT				= 100
AS
/*
	Creator:	20181023@Billy
	Task:		Description - [Redmine: #000000]
	Database:	DBDISTxx.distxx
	
	Revisions:
		- 20181023@Billy:	Initial - [Redmine: #000000]
		
	Developer's Notes:
		- @Example:			NULL		- Explaination [DEFAULT]
		
*/
BEGIN;
	SET NOCOUNT ON;

	DECLARE	@LastError	TABLE (
							time		DATETIME
						,	error_text	NVARCHAR(MAX)
						,	xact_seqno	VARBINARY(16)
						,	command_id	INT
						);

	INSERT INTO	@LastError (time, error_text, xact_seqno, command_id)
	SELECT	TOP(@quantity)
			time, error_text, xact_seqno, command_id
	FROM	dbo.MSrepl_errors AS err WITH (NOLOCK)
	ORDER BY time DESC;

	SELECT	[Distributor]	= @@SERVERNAME
		,	[Publisher]		= srv.name
		,	[PublisherDb]	= pdb.publisher_db
		,	[ErrorTime]		= err.time
		,	[Article]		= art.article
		,	[Command]		= CONVERT(NVARCHAR(MAX), f.command)
		,	[ErrorText]		= err.error_text
		,	[XactSeqNo]		= err.xact_seqno
		,	[CommandId]		= err.command_id
		,	[IsPartialCmd]	= cmd.partial_command
	FROM			@LastError AS err
	CROSS JOIN		dbo.MSpublisher_databases AS pdb WITH (NOLOCK)
	LEFT JOIN		sys.servers AS srv WITH (NOLOCK)
				ON	pdb.publisher_id = srv.server_id
	INNER LOOP JOIN	dbo.MSrepl_commands AS cmd WITH (NOLOCK)
				ON	cmd.xact_seqno = err.xact_seqno
				AND	cmd.command_id = err.command_id
				AND	cmd.publisher_database_id = pdb.id
	CROSS APPLY	(
		SELECT	start = CHARINDEX(0x7B00, cmd.command)
			,	finish = CHARINDEX(0x7D00, cmd.command)
			,	length = LEN(cmd.command)
	) pos
	OUTER APPLY	(
		SELECT	prefix = SUBSTRING(cmd.command, 0, pos.start)
			,	command = SUBSTRING(cmd.command, pos.start, pos.finish - pos.start + 2)
			,	postfix = SUBSTRING(cmd.command, pos.finish + 2, pos.length - pos.finish + 1)
		WHERE	pos.finish - pos.start + 2 >= 0
			AND	pos.length - pos.finish + 1 >= 0
	) f
	CROSS APPLY	(
		SELECT	params = (LEN(f.command) - LEN(REPLACE(f.command, 0x3F00, ''))) / 2
	) inf
	INNER JOIN	dbo.MSarticles AS art WITH (NOLOCK)
			ON	cmd.article_id = art.article_id
	ORDER BY err.time DESC;

END;
GO
/*<info serverAlias="DBDISTxx-distxx" executers="" viewers="" isFunction="0" isNested="0"></info>*/