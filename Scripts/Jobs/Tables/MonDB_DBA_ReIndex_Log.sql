USE [MonDB]
GO

/****** Object:  Table [dbo].[userlog_T1]    Script Date: 7/16/2021 3:36:03 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[DBA_ReIndex_Log](
	[logid] [bigint] IDENTITY(1,1) NOT NULL,
	[time_trace] [datetime] NULL,
	[record_rn] [int] NULL,
	[run_counter] [int] NULL,
	[doing] [varchar](1000) NULL,
	[logdate] [datetime] NULL,
 CONSTRAINT [PK_DBA_ReIndex_Log] PRIMARY KEY CLUSTERED 
(
	[logid] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [DBA_ReIndex]
) ON [DBA_ReIndex]
GO

ALTER TABLE [dbo].[DBA_ReIndex_Log] ADD  CONSTRAINT [DF_DBA_ReIndex_Log_logdate]  DEFAULT (getdate()) FOR [logdate]
GO


