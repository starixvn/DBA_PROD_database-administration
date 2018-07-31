/*
	Creator:	20180625@Billy
	Task:		Failed log table for Raw Query service broker - [Redmine: #00000]
	Server:		DBSTARIX.StarixDB
*/


USE	StarixDB;
GO

IF	OBJECT_ID('dbo.vnDBA_ServiceBroker_RawQueryFailedLog') IS NOT NULL
	DROP TABLE	dbo.vnDBA_ServiceBroker_RawQueryFailedLog;

CREATE TABLE	dbo.vnDBA_ServiceBroker_RawQueryFailedLog (
					LogDate		DATETIME
				,	Msg			NVARCHAR(MAX)
				,	ErrorMsg	NVARCHAR(MAX)
				);

CREATE CLUSTERED INDEX	CIX_ServiceBroker_RawQueryFailedLog ON dbo.vnDBA_ServiceBroker_RawQueryFailedLog (
							LogDate	ASC
						) WITH (DATA_COMPRESSION = PAGE) ON DATA;