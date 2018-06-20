/*
	Creator:	20180209@Billy
	Task:		Table for excluding sessions info - [Redmine: #90722]
	Server:		SITDB06
*/


USE	MonDB;
GO

CREATE TABLE	dbo.vnDBA_RDP_Excluded (
					ServerName					VARCHAR(128)
				,	UserName					VARCHAR(128)
				,	ClientName					VARCHAR(128)
				,	ForcedExcluded				BIT
				);

CREATE CLUSTERED INDEX	CIX_vnDBA_RDP_Excluded ON dbo.vnDBA_RDP_Excluded (
							ServerName
						,	UserName
						,	ClientName
						);

RETURN;

DROP INDEX CIX_vnDBA_RDP_Excluded ON dbo.vnDBA_RDP_Excluded;
DROP TABLE dbo.vnDBA_RDP_Excluded;
