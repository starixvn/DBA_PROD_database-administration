/*
	Creator:	20180702@Billy
	Task:		Table for ticket latency monitoring - [Redmine: #00000]
	Server:		DBSTARIX.StarixDB
*/


CREATE TABLE	dbo.vnDBA_Monitor_TicketLatency (
					ServerName			NVARCHAR(128)
				,	CaptureTime			DATETIME
				,	LastTicketId		BIGINT
				,	LastTransdate		DATETIME
				);

CREATE CLUSTERED INDEX	CIX_Monitor_TicketLatency ON dbo.vnDBA_Monitor_TicketLatency (
							CaptureTime		ASC
						,	ServerName		ASC
						) WITH (DATA_COMPRESSION = PAGE) ON PerfMon;