/*
	Creator:	20170208@Billy
	Task:		Letstalk Notification - Example scripts - [Redmine: #70016]
	Server:		
*/


--	BEGIN STEP 1:
--		Insert metadata
----------------------------------------------------------------------------------------------------

-- Add new room's information --
INSERT INTO	dbo.DBA_LetstalkRooms
	(	RoomId, RoomName      , isActive)
SELECT	12345 , 'Testing Room', 1
;

-- Add new job's information --
INSERT INTO	dbo.DBA_LetstalkJobs
	(	ServerName, JobId                                 , JobName           , Level, RoomId)
SELECT	'DBTEST'  , 'EDB4758C-3551-4D61-9325-F994761C230B', 'Job test''s Name', 3    , 12345
;


--	BEGIN STEP 2:
--		Add new message examples
----------------------------------------------------------------------------------------------------

EXECUTE DBMON.MonDBDW.dbo.DBA_Letstalk_NewJobMessage @ServerName = 'DBTEST', @JobId = 'EDB4758C-3551-4D61-9325-F994761C230B', @JobName = NULL, @Message = N'testing'

EXECUTE DBMON.MonDBDW.dbo.DBA_Letstalk_NewJobMessage @ServerName = @@SERVERNAME, @JobId = 'EDB4758C-3551-4D61-9325-F994761C230B', @JobName = NULL, @Message = N'testing'

EXECUTE DBMON.MonDBDW.dbo.DBA_Letstalk_NewJobMessage @ServerName = 'DBTEST', @JobId = NULL, @JobName = 'Job test''s Name', @Message = N'testing'


--	BEGIN STEP 3:
--		Get message for notify on Letstalk - For Letstalk service's call only
----------------------------------------------------------------------------------------------------

-- Get all messages has been reported since the last 5 mimutes --
EXECUTE DBMON.MonDB.dbo.DBA_Letstalk_Notify

-- Get all messages has been reported since the last 10 minutes --
EXECUTE DBMON.MonDB.dbo.DBA_Letstalk_Notify @minute = 10

-- Get "JOB" type messages has been reported since the last 5 minutes -- 
EXECUTE DBMON.MonDB.dbo.DBA_Letstalk_Notify @type = 'JOB'

-- Get "JOB" type messages has been reported since the last 10 minutes --
EXECUTE DBMON.MonDB.dbo.DBA_Letstalk_Notify @minute = 10, @type = 'JOB'
