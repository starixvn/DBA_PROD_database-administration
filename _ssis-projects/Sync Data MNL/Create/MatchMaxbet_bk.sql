SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[MatchMaxbet_bk](
	[MatchId] [int] NOT NULL,
	[BetType] [int] NOT NULL,
	[Maxbet] [float] NULL,
	[OperatorId] [int] NULL,
	[Spread] [float] NULL,
 CONSTRAINT [PK_MatchMaxbet_bk] PRIMARY KEY CLUSTERED 
(
	[MatchId] ASC,
	[BetType] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON, FILLFACTOR = 100) ON [EVENT]
) ON [EVENT]

GO


