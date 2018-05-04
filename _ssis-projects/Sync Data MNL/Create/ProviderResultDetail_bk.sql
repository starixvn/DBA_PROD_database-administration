SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[ProviderResultDetail_bk](
	[MatchId] [int] NOT NULL,
	[SourceId] [tinyint] NOT NULL,
	[TypeId] [tinyint] NOT NULL,
	[HomeValue] [varchar](50) NULL,
	[AwayValue] [varchar](50) NULL,
	[CreatedDate] [datetime] NOT NULL,
 CONSTRAINT [PK_ProviderResultDetail_bk] PRIMARY KEY CLUSTERED 
(
	[MatchId] ASC,
	[SourceId] ASC,
	[TypeId] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [EVENT]
) ON [EVENT]

GO

SET ANSI_PADDING OFF
GO

ALTER TABLE [dbo].[ProviderResultDetail_bk] ADD  CONSTRAINT [DF_ProviderResultDetail_bk_CreatedDate]  DEFAULT (getdate()) FOR [CreatedDate]
GO


