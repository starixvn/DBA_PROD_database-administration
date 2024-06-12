USE [MonDB]
GO

CREATE TABLE [dbo].[RepTokens](
	[PubId] [int] NULL,
	[PubName] [sysname] NOT NULL,
	[PubDatabase] [sysname] NOT NULL,
	[TraceTokenId] [int] NULL,
	[CreatedDate] [datetime2](7) NULL,
	[ModifiedDate] [datetime2](7) NULL,
	[Latency] [int] NULL,
	[IsDone] [bit] NULL,
	[SubName] [sysname] NULL,
	[SubDatabase] [sysname] NULL
) ON [PRIMARY]
GO

