SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[ResultDetail3rd_bk](
	[ResultID] [int] NOT NULL,
	[VendorID] [int] NOT NULL,
	[MatchID] [int] NOT NULL,
	[GameID] [int] NOT NULL,
	[Custom1] [nvarchar](50) NULL,
	[Custom2] [nvarchar](50) NULL,
	[Custom3] [nvarchar](50) NULL,
	[ResultStatusID] [tinyint] NULL,
	[SettlementStatusID] [tinyint] NULL,
	[GameResult] [varchar](50) NULL,
	[OtherInfo] [varchar](50) NULL,
	[CreateBy] [int] NULL,
	[CreateDate] [datetime] NULL,
	[LastModifyBy] [int] NULL,
	[LastModifyDate] [datetime] NULL,
 CONSTRAINT [PK_ResultDetail3rd_bk] PRIMARY KEY CLUSTERED 
(
	[ResultID] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [EVENT]
) ON [EVENT]

GO

SET ANSI_PADDING OFF
GO


