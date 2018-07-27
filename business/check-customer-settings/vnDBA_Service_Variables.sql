USE	CheckResultDB;
GO

CREATE TABLE	dbo.vnDBA_Service_Variables (
					VarKey		NVARCHAR(128)
				,	VarValue	SQL_VARIANT
				,	CONSTRAINT PK_Service_Variables PRIMARY KEY CLUSTERED (VarKey) ON DATA
				) ON DATA

