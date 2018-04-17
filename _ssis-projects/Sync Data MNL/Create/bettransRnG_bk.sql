SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO

CREATE TABLE [dbo].[bettransRnG_bk](
	[transid] [bigint] NOT NULL,
	[custid] [int] NOT NULL,
	[transdate] [datetime] NOT NULL,
	[odds] [smallmoney] NULL,
	[stake] [money] NOT NULL,
	[status] [varchar](10) NULL,
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
	[betfrom] [varchar](1) NULL,
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
	[productID] [smallint] NOT NULL,
	[gameID] [smallint] NOT NULL,
	[vendorID] [int] NOT NULL,
	[GameId3rd] [varchar](50) NULL,
	[TranId3rd] [varchar](64) NULL,
	[RefNo] [bigint] NULL,
	[IsSum] [bit] NULL,
	[winlost] [money] NULL,
	[awinlost] [money] NULL,
	[mwinlost] [money] NULL,
	[swinlost] [money] NULL,
	[playercomm] [money] NULL,
	[comm] [money] NULL,
	[acomm] [money] NULL,
	[scomm] [money] NULL,
	[Transdate3rd] [datetime] NULL,
	[Additional] [varchar](1000) NULL
) ON [bettransRnG_bk_table]

GO

SET ANSI_PADDING OFF
GO

CREATE CLUSTERED INDEX [CIX_winlostdate] ON [dbo].[bettransRnG_bk] 
(
	[winlostdate] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON)
GO

CREATE NONCLUSTERED INDEX [IX_custid] ON [dbo].[bettransRnG_bk] 
(
	[custid] ASC
)
INCLUDE ( [winlostdate],
[productID],
[gameID]) WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON)
GO

CREATE NONCLUSTERED INDEX [IX_RefNo] ON [dbo].[bettransRnG_bk] 
(
	[RefNo] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON)
GO
