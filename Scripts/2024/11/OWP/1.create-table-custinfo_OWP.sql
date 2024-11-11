/*
	Created by:	Evan
	Date:		20241111
	Database:	DBTP10C.bodb02
	Task: Create table custInfo_OWP, add data SystemSettings
*/

USE [bodb02]
GO
/****** Object:  Table [dbo].[custInfo_OWP] ******/
CREATE TABLE [dbo].[custInfo_OWP](
	[username] [nvarchar](50) NULL,
	[custid] [int] NOT NULL,
	[currency] [int] NULL,
	[roleid] [tinyint] NULL,
	[srecommend] [int] NULL,
	[mrecommend] [int] NULL,
	[recommend] [int] NULL,
	[dangercust] [bit] NULL,
	[autosuspend] [bit] NULL,
	[reject] [bit] NULL,
	[credit] [money] NULL,
	[closed] [bit] NULL,
	[MatchLimit] [smallmoney] NOT NULL,
	[VirtualMultiplier] [smallmoney] NOT NULL,
	[Enabled] [bit] NOT NULL,
	[danger] [tinyint] NOT NULL,
	[danger2] [tinyint] NOT NULL,
	[danger3] [tinyint] NOT NULL,
	[DisableOutright] [bit] NOT NULL,
	[Abnormal] [tinyint] NOT NULL,
	[DoubleCommLosing] [bit] NOT NULL,
	[autosuspend2] [bit] NULL,
	[DisableEsports] [bit] NULL,
	[DisableSuperLive] [bit] NULL,
	[LockUpd] [bit] NULL,
	[BonusWalletFlag] [bit] NULL,
	[CreditUpdatedDate] [smalldatetime] NULL,
	[DangerLevel] [int] NULL,
	[CustomerClass] [smallint] NULL,
	[Danger4] [tinyint] NULL,
	[Danger5] [tinyint] NULL,
	[CCSoccer] [smallint] NULL,
	[CCBasketball] [smallint] NULL,
	[CCEsports] [smallint] NULL,
	[CCOtherSports] [smallint] NULL,
	[CCNonSports] [smallint] NULL,
	[autosuspend3] [bit] NULL,
	[RepUpdateTime] [datetime2](7) NULL,
	[tstamp] [TIMESTAMP]
 CONSTRAINT [PK_custinfo_OWP] PRIMARY KEY CLUSTERED 
(
	[custid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [DATA]
) ON [DATA]
GO

ALTER TABLE [dbo].[custInfo_OWP] ADD  CONSTRAINT [DF_custInfo_OWP_RepUpdateTime]  DEFAULT (sysdatetime()) FOR [RepUpdateTime]
GO

INSERT INTO SystemSettings (VName, VValue)
VALUES ('LastCustId', 0)
INSERT INTO SystemSettings (VName, VValue)
VALUES ('LastUpdateTime', CONVERT(VARCHAR(500), GETDATE(), 121))

GO

