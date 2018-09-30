SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO
ALTER PROCEDURE		dbo.DBA_Task_Archive_ArchiveEvidenceSub
AS
/*
	Creator:	20180928@Billy
	Task:		Archive unused evidence sub - [Redmine: #101008]
	Database:	FPSDI.FPS_DeviceFingerprint
	
	Revisions:
		- 20180928@Billy:	Initial - [Redmine: #101008]
		
	Developer's Notes:
		- @Example:			NULL		- Explaination [DEFAULT]
		
*/
BEGIN;
	SET NOCOUNT ON;

	-- Declare variables --
	
	DECLARE	@Query			NVARCHAR(MAX)
		;


	-- Copy archive evidences to archive database --
	RAISERROR('Archive Evidences', 0, 0) WITH NOWAIT;

	SELECT	@Query = N'';
	SELECT	@Query = @Query + N'
INSERT INTO	evidence.EvidenceSub (EviSubID, EviID, ItemID, ItemType, ItemValue, SubscriberID, LevelID, AffectedDate, EviSource)
SELECT	EviSubID, EviID, ItemID, ItemType, ItemValue, SubscriberID, LevelID, AffectedDate, EviSource
FROM		OPENQUERY(FPSADMIN, N''
	SELECT	es.EviSubID, es.EviID, es.ItemID, es.ItemType, es.ItemValue, es.SubscriberID, es.LevelID, es.AffectedDate, es.EviSource
	FROM		FPS_EVI.dbo.EvidenceSub AS es WITH (NOLOCK)
	INNER JOIN	FPSDI.FPS_DeviceFingerprint.dbo.DBA_Archive_DeviceSingleAssociation AS arc
			ON	es.ItemID = arc.DeviceID
			AND	es.SubscriberID = arc.SubscriberID
	WHERE	es.EviSubID > 0
		AND	es.ItemType = 1
		AND	es.LevelID > 0;
'');

RAISERROR(''	Inserted %d row(s)'', 0, 0, @@ROWCOUNT) WITH NOWAIT;
';

	EXECUTE	FPSARCHIVE.FPS_SUB_ARCHIVE_STAGING.sys.sp_executesql @Query;

	-- Copy invalid evidences to archive database --
	RAISERROR('Invalid Evidences', 0, 0) WITH NOWAIT;

	SELECT	@Query = N'';
	SELECT	@Query = @Query + N'
INSERT INTO	evidence.EvidenceSub (EviSubID, EviID, ItemID, ItemType, ItemValue, SubscriberID, LevelID, AffectedDate, EviSource)
SELECT	EviSubID, EviID, ItemID, ItemType, ItemValue, SubscriberID, LevelID, AffectedDate, EviSource
FROM		OPENQUERY(FPSADMIN, N''
	SELECT	es.EviSubID, es.EviID, es.ItemID, es.ItemType, es.ItemValue, es.SubscriberID, es.LevelID, es.AffectedDate, es.EviSource
	FROM		FPS_EVI.dbo.EvidenceSub AS es WITH (NOLOCK)
	LEFT JOIN	FPS_DEV.dbo.DevMaster AS dev WITH (NOLOCK)
			ON	es.ItemID = dev.DeviceID
	WHERE	es.EviSubID > 0
		AND	dev.DeviceID IS NULL;
'');

RAISERROR(''	Inserted %d row(s)'', 0, 0, @@ROWCOUNT) WITH NOWAIT;
';

	EXECUTE	FPSARCHIVE.FPS_SUB_ARCHIVE_STAGING.sys.sp_executesql @Query;

	-- Delete archived evidences --
	RAISERROR('Delete Evidences', 0, 0) WITH NOWAIT;
	
	SELECT	@Query = N'';
	SELECT	@Query = @Query + N'
CREATE TABLE	#Archived (
				EviSubID			INT
					PRIMARY KEY CLUSTERED
			);

INSERT INTO	#Archived (EviSubID)
SELECT	EviSubID
FROM	OPENQUERY(FPSARCHIVE, N''
SELECT	EviSubID
FROM	FPS_SUB_ARCHIVE_STAGING.evidence.EvidenceSub WITH (NOLOCK);
'');

DELETE	tbl WITH (PAGLOCK)
FROM		dbo.EvidenceSub AS tbl
INNER JOIN	#Archived AS tmp WITH (TABLOCK)
		ON	tbl.EviSubID = tmp.EviSubID;

RAISERROR(''	Deleted %d row(s)'', 0, 0, @@ROWCOUNT) WITH NOWAIT;
';

	EXECUTE	FPSADMIN.FPS_EVI.sys.sp_executesql @Query;
END;
GO
/*<info serverAlias="FPSDI-FPS_DeviceFingerprint" executers="" viewers="" isFunction="0" isNested="0"></info>*/
