USE	CheckResultDB;
GO

IF	OBJECT_ID('dbo.vnDBA_ServiceBroker_CheckSettingFailedLog') IS NOT NULL
	DROP TABLE	dbo.vnDBA_ServiceBroker_CheckSettingFailedLog;

CREATE TABLE	dbo.vnDBA_ServiceBroker_CheckSettingFailedLog (
					LogDate		DATETIME
				,	Msg			NVARCHAR(MAX)
				,	ErrorMsg	NVARCHAR(MAX)
				);

CREATE CLUSTERED INDEX	CIX_ServiceBroker_CheckSettingFailedLog ON dbo.vnDBA_ServiceBroker_CheckSettingFailedLog (
							LogDate	ASC
						) WITH (DATA_COMPRESSION = PAGE) ON DATA;