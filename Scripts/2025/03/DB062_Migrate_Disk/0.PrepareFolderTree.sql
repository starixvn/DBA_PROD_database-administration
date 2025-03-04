/*
	Task: COpy folder tree from old drives to new drives
		
	Created on 20250304 by Daniel
	Run on DB062 command windows
*/



--Copy folder tree USER_DB F: FAS2720 -> L: FAS2820
robocopy f:\user_db l:\user_db\ /E /XF *

--Copy folder tree USER_DB J: A300 -> K: A250
robocopy j:\user_db k:\user_db\ /E /XF *

--Copy folder tree USER_DB\bodb_archive F: FAS2720 -> K: A250
robocopy f:\user_db\bodb_archive k:\user_db\bodb_Archive /E /XF *

--Copy folder tree USER_DB\bodb_Report F: FAS2720 -> K: A250
robocopy f:\user_db\bodb_Report k:\user_db\bodb_Report /E /XF *
