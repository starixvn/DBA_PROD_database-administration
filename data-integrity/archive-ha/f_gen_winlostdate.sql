SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO
CREATE FUNCTION [dbo].[f_gen_winlostdate]
(	
	@dateFrom smalldatetime,
	@dateTo smalldatetime
)
RETURNS TABLE
/*
	Creator:	20201222@Patrick
	Task:		Check bodb_Archive tables' rowcount - [Redmine: #00000]
	Database:	DBARC.bodb_Archive

	Revisions:
		- 20200626@Patrick: Add TVS system to archive process [Redmine: #135963]
*/

AS
RETURN 
(
	SELECT	tally.winlostdate
	FROM	(
		SELECT	[NoDays] = DATEDIFF(DAY, @dateFrom, @dateTo) + 1
	) cnt
	CROSS APPLY	(
		SELECT	TOP(cnt.NoDays)
				[winlostdate] = DATEADD(DAY, ROW_NUMBER() OVER(ORDER BY (SELECT NULL)) - 1, @dateFrom)
		FROM		(VALUES (0), (0), (0), (0), (0), (0), (0), (0), (0), (0)) x10(n)
		CROSS APPLY	(VALUES (0), (0), (0), (0), (0), (0), (0), (0), (0), (0)) x100(n)
		CROSS APPLY	(VALUES (0), (0), (0), (0), (0), (0), (0), (0), (0), (0)) x1000(n)
	) tally
)
GO
/*<info serverAlias="DBARC-bodb_Archive" executers="" viewers="" isFunction="1" isNested="1"></info>*/