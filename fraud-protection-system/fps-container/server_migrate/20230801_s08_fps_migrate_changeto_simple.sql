/*
	Created: 20230801@Sol
	Task: change to simple mode if need
	DB: FPS_DB02\FPS_01-master
*/

USE [master]

GO

ALTER DATABASE FPS_LOG SET RECOVERY SIMPLE WITH NO_WAIT

GO
