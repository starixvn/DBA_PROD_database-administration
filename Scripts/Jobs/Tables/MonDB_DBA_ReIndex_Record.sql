USE [MonDB]
GO

/****** Object:  Table [dbo].[tmp_Task_ReIndex]    Script Date: 7/16/2021 3:32:09 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[DBA_ReIndex_Record](
	[rn] [int] IDENTITY(1,1) NOT NULL,
	[time_trace] [datetime] NOT NULL,
	[id_db] [bigint] NULL,
	[id_table] [bigint] NULL,
	[id_index] [bigint] NULL,
	[name_table] [varchar](500) NULL,
	[name_index] [varchar](500) NULL,
	[index_type] [char](1) NULL,
	[RunCounter] [int] NULL,
	[TimeStart] [datetime2](6) NULL,
	[command] [nvarchar](1000) NULL,
	[FragmentTarget] [smallmoney] NULL,
	[page_count] [bigint] NULL,
	[Fragment] [smallmoney] NULL,
	[Debug] [bit] NULL,
 CONSTRAINT [PK_DBA_ReIndex_Record] PRIMARY KEY CLUSTERED 
(
	[rn] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [DBA_ReIndex]
) ON [DBA_ReIndex]
GO

ALTER TABLE [dbo].[DBA_ReIndex_Record] ADD  CONSTRAINT [DF_DBA_ReIndex_Record_IndexType]  DEFAULT ('') FOR [index_type]
GO

ALTER TABLE [dbo].[DBA_ReIndex_Record] ADD  CONSTRAINT [DF_DBA_ReIndex_Record_RunCounter]  DEFAULT ((0)) FOR [RunCounter]
GO