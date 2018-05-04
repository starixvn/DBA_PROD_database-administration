SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[ResultDetail_bk](
	[MatchID] [int] NOT NULL,
	[ResourceID] [varchar](20) NOT NULL,
	[HomeValue] [varchar](20) NULL,
	[AwayValue] [varchar](20) NULL,
	[ResultStatusID] [tinyint] NULL,
	[SettlementStatusID] [tinyint] NULL,
	[CreateBy] [int] NULL,
	[CreateDate] [smalldatetime] NULL,
	[LastModifyBy] [int] NULL,
	[LastModifyDate] [smalldatetime] NULL,
	[OtherInfo] [varchar](50) NULL,
 CONSTRAINT [PK_ResultDetail_bk] PRIMARY KEY CLUSTERED 
(
	[MatchID] ASC,
	[ResourceID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [EVENT]
) ON [EVENT]

GO

SET ANSI_PADDING OFF
GO


