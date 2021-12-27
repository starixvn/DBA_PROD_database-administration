/***
	- Created@20211229: Bobby
	- Host: Run on DB052N2
***/

USE master;
GO
-- move files
ALTER DATABASE tempdb
MODIFY FILE (NAME = tempdev, FILENAME = 'H:\sys_db\tempdb\tempdb.mdf');
GO
ALTER DATABASE tempdb
MODIFY FILE (NAME = templog, FILENAME = 'H:\sys_db\tempdb\templog.ldf');
GO
ALTER DATABASE tempdb
MODIFY FILE (NAME = tempdev01, FILENAME = 'H:\sys_db\tempdb\tempdev01.ndf');
GO
ALTER DATABASE tempdb
MODIFY FILE (NAME = tempdev02, FILENAME = 'H:\sys_db\tempdb\tempdev02.ndf');
GO
ALTER DATABASE tempdb
MODIFY FILE (NAME = tempdev03, FILENAME = 'H:\sys_db\tempdb\tempdev03.ndf');
GO
ALTER DATABASE tempdb
MODIFY FILE (NAME = tempdev04, FILENAME = 'H:\sys_db\tempdb\tempdev04.ndf');
GO
ALTER DATABASE tempdb
MODIFY FILE (NAME = tempdev05, FILENAME = 'H:\sys_db\tempdb\tempdev05.ndf');
GO
ALTER DATABASE tempdb
MODIFY FILE (NAME = tempdev06, FILENAME = 'H:\sys_db\tempdb\tempdev06.ndf');
GO
ALTER DATABASE tempdb
MODIFY FILE (NAME = tempdev07, FILENAME = 'H:\sys_db\tempdb\tempdev07.ndf');
GO
--- add more files 
ALTER DATABASE tempdb
ADD FILE
(
    NAME = tempdev08,
    FILENAME = 'H:\sys_db\tempdb\tempdev08.ndf',
    SIZE = 256MB,
    MAXSIZE = UNLIMITED,
    FILEGROWTH = 16MB
),  
(  
    NAME = tempdev09,
    FILENAME = 'H:\sys_db\tempdb\tempdev09.ndf',
    SIZE = 256MB,
    MAXSIZE = UNLIMITED,
    FILEGROWTH = 16MB
),  
(  
    NAME = tempdev10,
    FILENAME = 'H:\sys_db\tempdb\tempdev10.ndf',
    SIZE = 256MB,
    MAXSIZE = UNLIMITED,
    FILEGROWTH = 16MB
),  
(  
    NAME = tempdev11,
    FILENAME = 'H:\sys_db\tempdb\tempdev11.ndf',
    SIZE = 256MB,
    MAXSIZE = UNLIMITED,
    FILEGROWTH = 16MB
),  
(  
    NAME = tempdev12,
    FILENAME = 'H:\sys_db\tempdb\tempdev12.ndf',
    SIZE = 256MB,
    MAXSIZE = UNLIMITED,
    FILEGROWTH = 16MB
),  
(  
    NAME = tempdev13,
    FILENAME = 'H:\sys_db\tempdb\tempdev13.ndf',
    SIZE = 256MB,
    MAXSIZE = UNLIMITED,
    FILEGROWTH = 16MB
),  
(  
    NAME = tempdev14,
    FILENAME = 'H:\sys_db\tempdb\tempdev14.ndf',
    SIZE = 256MB,
    MAXSIZE = UNLIMITED,
    FILEGROWTH = 16MB
),  
(  
    NAME = tempdev15,
    FILENAME = 'H:\sys_db\tempdb\tempdev15.ndf',
    SIZE = 256MB,
    MAXSIZE = UNLIMITED,
    FILEGROWTH = 16MB
),  
(  
    NAME = tempdev16,
    FILENAME = 'H:\sys_db\tempdb\tempdev16.ndf',
    SIZE = 256MB,
    MAXSIZE = UNLIMITED,
    FILEGROWTH = 16MB
),  
(  
    NAME = tempdev17,
    FILENAME = 'H:\sys_db\tempdb\tempdev17.ndf',
    SIZE = 256MB,
    MAXSIZE = UNLIMITED,
    FILEGROWTH = 16MB
),  
(  
    NAME = tempdev18,
    FILENAME = 'H:\sys_db\tempdb\tempdev18.ndf',
    SIZE = 256MB,
    MAXSIZE = UNLIMITED,
    FILEGROWTH = 16MB
),  
(  
    NAME = tempdev19,
    FILENAME = 'H:\sys_db\tempdb\tempdev19.ndf',
    SIZE = 256MB,
    MAXSIZE = UNLIMITED,
    FILEGROWTH = 16MB
),  
(  
    NAME = tempdev20,
    FILENAME = 'H:\sys_db\tempdb\tempdev20.ndf',
    SIZE = 256MB,
    MAXSIZE = UNLIMITED,
    FILEGROWTH = 16MB
),  
(  
    NAME = tempdev21,
    FILENAME = 'H:\sys_db\tempdb\tempdev21.ndf',
    SIZE = 256MB,
    MAXSIZE = UNLIMITED,
    FILEGROWTH = 16MB
),  
(  
    NAME = tempdev22,
    FILENAME = 'H:\sys_db\tempdb\tempdev22.ndf',
    SIZE = 256MB,
    MAXSIZE = UNLIMITED,
    FILEGROWTH = 16MB
),  
(  
    NAME = tempdev23,
    FILENAME = 'H:\sys_db\tempdb\tempdev23.ndf',
    SIZE = 256MB,
    MAXSIZE = UNLIMITED,
    FILEGROWTH = 16MB
),  
(  
    NAME = tempdev24,
    FILENAME = 'H:\sys_db\tempdb\tempdev24.ndf',
    SIZE = 256MB,
    MAXSIZE = UNLIMITED,
    FILEGROWTH = 16MB
),  
(  
    NAME = tempdev25,
    FILENAME = 'H:\sys_db\tempdb\tempdev25.ndf',
    SIZE = 256MB,
    MAXSIZE = UNLIMITED,
    FILEGROWTH = 16MB
),  
(  
    NAME = tempdev26,
    FILENAME = 'H:\sys_db\tempdb\tempdev26.ndf',
    SIZE = 256MB,
    MAXSIZE = UNLIMITED,
    FILEGROWTH = 16MB
),  
(  
    NAME = tempdev27,
    FILENAME = 'H:\sys_db\tempdb\tempdev27.ndf',
    SIZE = 256MB,
    MAXSIZE = UNLIMITED,
    FILEGROWTH = 16MB
),  
(  
    NAME = tempdev28,
    FILENAME = 'H:\sys_db\tempdb\tempdev28.ndf',
    SIZE = 256MB,
    MAXSIZE = UNLIMITED,
    FILEGROWTH = 16MB
),  
(  
    NAME = tempdev29,
    FILENAME = 'H:\sys_db\tempdb\tempdev29.ndf',
    SIZE = 256MB,
    MAXSIZE = UNLIMITED,
    FILEGROWTH = 16MB
),  
(  
    NAME = tempdev30,
    FILENAME = 'H:\sys_db\tempdb\tempdev30.ndf',
    SIZE = 256MB,
    MAXSIZE = UNLIMITED,
    FILEGROWTH = 16MB
),  
(  
    NAME = tempdev31,
    FILENAME = 'H:\sys_db\tempdb\tempdev31.ndf',
    SIZE = 256MB,
    MAXSIZE = UNLIMITED,
    FILEGROWTH = 16MB
)
TO FILEGROUP [PRIMARY];
GO