SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO
CREATE PROCEDURE	dbo.vnDBA_sp_Repl_GetLastestErrCmds
						@quantity		INT				= 100
AS
/*
	Creator:	20181023@Billy
	Task:		Get distributor lastest error commands - [Redmine: #103639]
	Database:	DBSTARIX.StarixDB
	
	Revisions:
		- 20181023@Billy:	Initial - [Redmine: #103639]
		
	Developer's Notes:
		- @Example:			NULL		- Explaination [DEFAULT]
		
*/
BEGIN;
	SET NOCOUNT ON;

	DECLARE	@Result	AS TABLE (
						Distributor		NVARCHAR(128)
					,	Publisher		NVARCHAR(128)
					,	PublisherDb		NVARCHAR(128)
					,	ErrorTime		DATETIME
					,	Article			NVARCHAR(128)
					,	Command			NVARCHAR(MAX)
					,	ErrorText		NVARCHAR(MAX)
					,	XactSeqNo		VARBINARY(16)
					,	CommandId		INT
					,	IsPartialCmd	BIT
					);

	INSERT INTO	@Result (Distributor, Publisher, PublisherDb, ErrorTime, Article, Command, ErrorText, XactSeqNo, CommandId, IsPartialCmd)
	EXECUTE	DBDISTRMKBT.dist_dbdistrm.dbo.vnDBA_sp_Replication_GetLastErrorCmds @quantity = @quantity;

	SELECT	[Dist]		= Distributor
		,	[Pub]		= Publisher
		,	[PubDb]		= PublisherDb
		,	[Time]		= DATEADD(HOUR, +4, ErrorTime) -- Convert to GMT+0
		,	[Obj]		= Article
		,	[Cmd]		= SUBSTRING(Command, CHARINDEX(N'CALL', Command), CHARINDEX(N']', Command) - CHARINDEX(N'CALL', Command) + 1)
		,	[Error]		= ErrorText
		,	[SeqNo]		= CONVERT(NVARCHAR(50), XactSeqNo, 1)
		,	[CmdId]		= CommandId
		,	[Partial]	= IsPartialCmd
	FROM	@Result
	ORDER BY Distributor ASC, ErrorTime DESC;
END;
GO
GRANT EXECUTE ON dbo.vnDBA_sp_Repl_GetLastestErrCmds TO vnGrafana AS dbo;
GO
/*<info serverAlias="DBSTARIX-StarixDB" executers="vnGrafana" viewers="" isFunction="0" isNested="0"></info>*/