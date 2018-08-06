SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[translog_BK](
	[translogid] [bigint] NOT NULL,
	[custid] [int] NOT NULL,
	[transdate] [datetime] NOT NULL,
	[odds] [smallmoney] NULL,
	[stake] [money] NOT NULL,
	[status] [nvarchar](10) NULL,
	[apositiontaking] [smallmoney] NULL,
	[mpositiontaking] [smallmoney] NULL,
	[tpositiontaking] [smallmoney] NULL,
	[spositiontaking] [smallmoney] NULL,
	[playerdiscount] [decimal](9, 8) NULL,
	[discount] [decimal](9, 8) NULL,
	[adiscount] [decimal](9, 8) NULL,
	[sdiscount] [decimal](9, 8) NULL,
	[creator] [int] NOT NULL,
	[winlostdate] [smalldatetime] NOT NULL,
	[betfrom] [nvarchar](1) NULL,
	[virtualrate] [float] NOT NULL,
	[actualrate] [float] NULL,
	[actual_stake] [money] NULL,
	[currency] [tinyint] NULL,
	[CurrencyName] [nvarchar](50) NULL,
	[recommend] [int] NOT NULL,
	[mrecommend] [int] NOT NULL,
	[srecommend] [int] NOT NULL,
	[ip] [nvarchar](15) NULL,
	[statusID] [tinyint] NULL,
	[balance] [money] NULL,
	[Username] [nvarchar](50) NULL,
	[transdesc] [nvarchar](1000) NULL,
	[productID] [int] NOT NULL,
	[gameID] [int] NOT NULL,
	[eventID] [int] NOT NULL,
	[vendorID] [int] NOT NULL,
	[GameId3rd] [nvarchar](50) NULL,
	[TranId3rd] [nvarchar](64) NULL,
	[custom1] [varchar](50) NULL,
	[custom2] [varchar](50) NULL,
	[custom3] [varchar](50) NULL,
	[LiveIndicator] [bit] NULL,
 CONSTRAINT [PK_translog_BK] PRIMARY KEY CLUSTERED 
(
	[translogid] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [TRANSLOG_BK_TABLE]
) ON [TRANSLOG_BK_TABLE]

GO

SET ANSI_PADDING OFF
GO

CREATE NONCLUSTERED INDEX [IX_winlostdate] ON [dbo].[translog_BK] 
(
	[winlostdate] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON)
GO


