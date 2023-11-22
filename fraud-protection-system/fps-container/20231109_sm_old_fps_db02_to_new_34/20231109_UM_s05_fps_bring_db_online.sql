/*
	Created: 20231026@Sol
	Task: bring db online
	DB: 10.40.40.34,16402-master
*/

USE master;

GO 

RESTORE DATABASE FPS_DeviceFingerprint WITH RECOVERY;

GO