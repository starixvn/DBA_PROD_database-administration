USE [MonDB]
GO
/****** Object:  StoredProcedure [dbo].[vnDBA_migration_gen_attachDB]    Script Date: 11/30/2021 4:07:37 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER procedure [dbo].[vnDBA_migration_gen_attachDB]
@DBName	nvarchar(100)
as
	-- 20211129-Brice: initial

begin
	declare @val varchar(MAX)
	select @val = COALESCE(@val + '
			, (FILENAME = N''' + physical_name + ''')','(FILENAME = N''' + physical_name + ''')')
	FROM sys.master_files
	WHERE database_id = DB_ID(@DBName)

	SELECT 
	'IF NOT EXISTS (SELECT TOP 1 1 FROM sys.databases WHERE name = '''+@DBName+''')
	BEGIN
		CREATE DATABASE ['+@DBName+'] ON
		'+ @val +'
		FOR ATTACH;
	END'
end
