SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO
CREATE PROCEDURE	dbo.GetAllIPv62Location
AS
/*
	Creator:	20190705@Billy
	Task:		Get all IPv6 - [Redmine: #116251]
	Database:	FPSADMIN.IPDB

	Revisions:
		- 20190705@Billy:	Initial - [Redmine: #116251]

	Developer's Notes:
		- @Example:			NULL		- Explaination [DEFAULT]

*/
BEGIN;
	SET NOCOUNT ON;

	SELECT	[FromIP]		= ipv6.ip_from
		,	[ToIP]			= ipv6.ip_to
		,	[CountryCode]	= ipv6.country_code
		,	[CountryName]	= ipv6.country_name
		,	[Region]		= ipv6.region
		,	[City]			= ipv6.city
		,	[ISPName]		= ipv6.isp_name
	FROM	dbo.IPv62Location AS ipv6 WITH (NOLOCK);
END;
GO
/*<info serverAlias="FPSADMIN-IPDB" executers="fpsWebService" viewers="" isFunction="0" isNested="0"></info>*/