SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO
ALTER PROCEDURE		dbo.DBA_Task_Archive_MiddleServiceAssociation
AS
/*
	Creator:	20180927@Billy
	Task:		Delete archived associations in Middle Service - [Redmine: #101008]
	Database:	FPSDI.FPS_DeviceFingerprint
	
	Revisions:
		- 20180927@Billy:	Initial - [Redmine: #101008]
		
	Developer's Notes:
		- @Example:			NULL		- Explaination [DEFAULT]
		
*/
BEGIN;
	SET NOCOUNT ON;

	-- Declare variables --
	
	DECLARE	@Query			NVARCHAR(MAX)
		;


	-- Delete associations in middle service database --
	RAISERROR('Delete Middle Service Associations', 0, 0) WITH NOWAIT;

	SELECT	@Query = N'';
	SELECT	@Query = @Query + N'
CREATE TABLE	#Archived (
				DeviceId			INT
					PRIMARY KEY CLUSTERED
			);

INSERT INTO	#Archived (DeviceId)
SELECT	DeviceId
FROM	OPENQUERY(FPSDI, N''
SELECT	DeviceId
FROM	FPS_DeviceFingerprint.dbo.DBA_Archive_DeviceSingleAssociation WITH (NOLOCK);
'');

DELETE	tbl WITH (PAGLOCK)
FROM		dbo.Associations AS tbl
INNER JOIN	#Archived AS tmp WITH (TABLOCK)
		ON	tbl.DeviceId = tmp.DeviceId;
';

	EXECUTE	FPSADMIN.FPS_MiddleService.sys.sp_executesql @Query;
END;
GO
/*<info serverAlias="FPSDI-FPS_DeviceFingerprint" executers="" viewers="" isFunction="0" isNested="0"></info>*/
