SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING OFF
GO

CREATE TABLE [dbo].[VSOutright_bk](
	[Orid] [int] IDENTITY(1,1) NOT FOR REPLICATION NOT NULL,
	[EventID] [int] NOT NULL,
	[RacerNum] [tinyint] NULL,
	[IsFavor] [varchar](3) NULL,
	[EventDate] [smalldatetime] NOT NULL,
	[KickoffTime] [datetime] NOT NULL,
	[RacerID] [int] NULL,
	[HumanID] [int] NULL,
	[WinOdds] [smallmoney] NULL,
	[PlaceOdds] [smallmoney] NULL,
	[Lane] [tinyint] NULL,
	[MaxBet] [int] NULL,
	[DisplayMode] [tinyint] NULL,
	[Placing] [tinyint] NULL,
	[Creator] [int] NOT NULL,
	[tstamp] [timestamp] NOT NULL,
	[ChangeTime] [datetime] NULL,
	[EventStatus] [varchar](50) NULL,
 CONSTRAINT [PK_VSOutright_BK] PRIMARY KEY CLUSTERED 
(
	[Orid] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [EVENT]
) ON [EVENT]

GO

SET ANSI_PADDING OFF
GO

ALTER TABLE [dbo].[VSOutright_bk] ADD  CONSTRAINT [DF_VSOutright_BK_Placing]  DEFAULT ((0)) FOR [Placing]
GO

ALTER TABLE [dbo].[VSOutright_bk] ADD  CONSTRAINT [DF_VSOutright_BK_ChangeTime]  DEFAULT (getdate()) FOR [ChangeTime]
GO


