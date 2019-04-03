/*
	Created: 20190318@Helen
	Database: DBTXN.bodb02
	Original:  
	
	Revisions:
		- 20190318@Helen: Initialize - archive event timeout issue [Redimine:110447]
 */
-- Edit step 21, Job named "Joe : DBTRANS_bodb02 : Thursday routine"  call this SP 
EXEC Task_Archive_Event_Control
