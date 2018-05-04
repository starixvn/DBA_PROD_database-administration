SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING OFF
GO

CREATE TABLE [dbo].[outright_bk](
	[orid] [int] NOT NULL,
	[leagueid] [int] NOT NULL,
	[teamid] [int] NOT NULL,
	[eventdate] [smalldatetime] NOT NULL,
	[kickofftime] [datetime] NOT NULL,
	[oddsstatus] [varchar](10) NULL,
	[odds] [smallmoney] NULL,
	[maxbet] [int] NULL,
	[gapodds] [smallmoney] NULL,
	[matchcode] [varchar](10) NULL,
	[groupmatch] [varchar](20) NULL,
	[status] [varchar](10) NULL,
	[creator] [int] NOT NULL,
	[bal] [money] NULL,
	[risk] [money] NULL,
	[DisplayMode] [tinyint] NULL,
	[PlaceOdds] [smallmoney] NULL,
	[Placing] [tinyint] NULL,
	[IsFavor] [bit] NULL,
	[IsSCR] [bit] NULL,
	[ProgramID] [varchar](10) NULL,
	[FOddsStatus] [varchar](10) NULL,
	[SCRTime] [datetime] NULL,
	[LeaguePatternID] [smallint] NULL,
	[TeamPatternID] [smallint] NULL,
	[ProgramDate] [smalldatetime] NULL,
	[IsDeadheat] [bit] NULL,
 CONSTRAINT [PK_outright_bk] PRIMARY KEY CLUSTERED 
(
	[orid] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [EVENT]
) ON [EVENT]

GO

SET ANSI_PADDING OFF
GO
