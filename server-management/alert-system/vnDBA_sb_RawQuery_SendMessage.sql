/*<info serverAlias="DBSTARIX-StarixDB" executers="" viewers="" isFunction="0"></info>*/
ALTER PROCEDURE [dbo].[vnDBA_sb_RawQuery_SendMessage]
(
	@messageBody NVARCHAR(MAX),
	@fromService SYSNAME ,   
	@toService SYSNAME,
	@onContract SYSNAME  
)
AS
/*
	Created: 20190219@Helen
	Task : Send message via service broker
	DB: DBDWCSS/StarixDB

	Revisions:
		- 20190219@Helen:  Initialize

	Param's Explanation:

*/
BEGIN
	DECLARE	@dialog				UNIQUEIDENTIFIER
	
	BEGIN DIALOG CONVERSATION	@dialog
	FROM SERVICE	@fromService
	TO SERVICE		@toService
	ON CONTRACT		@onContract
	WITH	ENCRYPTION	= OFF
		,	LIFETIME	= 172800
		;
	SEND ON CONVERSATION @dialog MESSAGE TYPE RawQueryMessage (@messageBody);
	
	END CONVERSATION @dialog;
	
END
GO	