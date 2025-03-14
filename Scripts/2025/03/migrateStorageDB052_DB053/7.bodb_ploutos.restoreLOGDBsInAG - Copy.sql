-- DB052
use master
go
RESTORE LOG   bodb_Ploutos FROM DISK = '' WITH NORECOVERY;
go