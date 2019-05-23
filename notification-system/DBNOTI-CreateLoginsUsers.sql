/*
	Creator:	20190523@Billy
	Task:		Create logins and users for Letstalk and Skype services - [Redmine: #113125]
	Server:		DBNOTI
*/

USE	master;
GO

CREATE LOGIN DBA_Letstalk
WITH	PASSWORD			= N'***********************'
	,	DEFAULT_DATABASE	= [master]
	,	CHECK_EXPIRATION	= OFF
	,	CHECK_POLICY		= OFF
	;

CREATE LOGIN DBA_Skype
WITH	PASSWORD			= N'***********************'
	,	DEFAULT_DATABASE	= [master]
	,	CHECK_EXPIRATION	= OFF
	,	CHECK_POLICY		= OFF
	;

USE	NotificationDB;
GO

CREATE USER DBA_Letstalk FOR LOGIN DBA_Letstalk;

CREATE USER DBA_Skype FOR LOGIN DBA_Skype;
