SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING OFF
GO

CREATE TABLE [dbo].[match_bk](
	[matchid] [int] NOT NULL,
	[leagueid] [int] NOT NULL,
	[homeid] [int] NOT NULL,
	[awayid] [int] NOT NULL,
	[eventdate] [datetime] NULL,
	[eventstatus] [varchar](50) NULL,
	[betstatus] [varchar](50) NULL,
	[livehomescore] [int] NULL,
	[liveawayscore] [int] NULL,
	[finalhomescore] [int] NULL,
	[finalawayscore] [int] NULL,
	[creator] [int] NOT NULL,
	[matchcode] [varchar](50) NULL,
	[kickofftime] [datetime] NULL,
	[closedtime] [datetime] NULL,
	[showtime] [varchar](50) NULL,
	[hthomescore] [int] NULL,
	[htawayscore] [int] NULL,
	[ruben] [tinyint] NULL,
	[multiple] [tinyint] NULL,
	[yenbet] [bit] NULL,
	[exrisk] [float] NULL,
	[sporttype] [tinyint] NULL,
	[tstamp] [binary](8) NULL,
	[homeid2] [int] NULL,
	[awayid2] [int] NULL,
	[DisplayMode] [tinyint] NULL,
	[LeaguePatternID] [smallint] NULL,
	[HomeDisplayPatternID] [smallint] NULL,
	[AwayDisplayPatternID] [smallint] NULL,
	[IsNeutral] [bit] NULL,
	[GoalRecord] [varchar](50) NULL,
	[GlobalShowTime] [smalldatetime] NULL,
 CONSTRAINT [PK_match_bk] PRIMARY KEY CLUSTERED 
(
	[matchid] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [EVENT]
) ON [EVENT]

GO

SET ANSI_PADDING OFF
GO

CREATE NONCLUSTERED INDEX [IX_eventdate] ON [dbo].[match_bk] 
(
	[eventdate] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [EVENT_Index]
GO