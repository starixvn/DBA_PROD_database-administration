/*<info serverAlias="DBCUST-MonDB,DBTRANS-MonDB,DBPRO-MonDB,DBTP-MonDB" executers="" isFunction="0"></info>*/

USE [MonDB]

GO

CREATE PROCEDURE [dbo].[DBA_Monitor_Latency_Pub_ClearTokenHistory]
(
	@IsDebug BIT = 0,
	@CutoffDate DateTime
)
AS
/*  
	Created by: 20240612@Sol
	Task: replication monitor
	DB: DBTrans/DBCust/DB02/DBTP
	Revision:
		- 20240612@Sol: initial sp

*/
BEGIN
	SET NOCOUNT ON;

	--/* get publisher db and distributor db (if any)
	BEGIN
		DECLARE @PubDbs TABLE (Pub_DatabaseName SYSNAME)
		DECLARE @ReplInfo TABLE (
			Pub_DatabaseName SYSNAME,
			Pub_Id int,
			Pub_Name SYSNAME,
			TokenId INT,
			distributor_latency BIGINT,
			subscriber SYSNAME NULL,
			subscriber_db SYSNAME NULL,
			subscriber_latency BIGINT,
			overall_latency BIGINT,
			Threshold INT,
			CreatedTime DATETIME2,
			LoopTime DATETIME2,
			IsAlerted BIT
			)

		--insert data to table
		INSERT INTO @PubDbs (Pub_DatabaseName)
		SELECT d.name
		FROM sys.databases d
		WHERE is_published = 1

		IF @IsDebug = 1 
			SELECT * FROM @PubDbs
	END

	--/* get list publication based on publisher db
	BEGIN
		DECLARE @PubDatabase SYSNAME;
		DECLARE @cmd NVARCHAR(max);

		DECLARE PubDb_cursor CURSOR
		FOR
			SELECT Pub_DatabaseName
			FROM @PubDbs
			ORDER BY Pub_DatabaseName;

		OPEN PubDb_cursor

		FETCH NEXT
		FROM PubDb_cursor
		INTO @PubDatabase

		WHILE @@FETCH_STATUS = 0
		BEGIN
			--gen command
			SET @cmd = CONCAT (
					'select ''',
					@PubDatabase,
					''', name, pubid from ',
					@PubDatabase,
					'.dbo.syspublications'
					);

			INSERT INTO @ReplInfo (Pub_DatabaseName, Pub_Name, Pub_Id)
			EXEC (@cmd)

			FETCH NEXT
			FROM PubDb_cursor
			INTO @PubDatabase
		END

		CLOSE PubDb_cursor;
		DEALLOCATE PubDb_cursor;

		IF @IsDebug = 1 
			SELECT * FROM @ReplInfo
	END

	--/* clear history
	BEGIN
		DECLARE @PubName SYSNAME, @PubId INT;
		DECLARE @MessageInfo NVARCHAR(MAX) = '';
		DECLARE @ParamDefinition NVARCHAR(max) = '@dyn_cutoff_date datetime, @dyn_publication sysname';
				
		SET @CutoffDate = ISNULL(@CutoffDate, DATEADD(HOUR, -1, GETDATE()));

		DECLARE PubName_cursor CURSOR
		FOR
			SELECT Pub_DatabaseName, Pub_Name, Pub_Id
			FROM @ReplInfo
			ORDER BY Pub_DatabaseName;

		OPEN PubName_cursor

		FETCH NEXT
		FROM PubName_cursor
		INTO @PubDatabase,@PubName, @PubId

		WHILE @@FETCH_STATUS = 0
		BEGIN
			--gen command
			SET @cmd = CONCAT (
					'exec ',
					@PubDatabase,
					'.sys.sp_deletetracertokenhistory @publication = @dyn_publication, @cutoff_date = @dyn_cutoff_date'
					);

			BEGIN TRY
				EXEC sp_executesql @cmd,
					@ParamDefinition,
					@dyn_publication = @PubName,
					@dyn_cutoff_date = @CutoffDate ;

				IF @@TRANCOUNT > 0
					COMMIT TRANSACTION;

				--delete from RepTokens too
				DELETE FROM MonDB.dbo.RepTokens
				WHERE PubName = @PubName AND PubId = @PubId AND PubDatabase = @PubDatabase AND CreatedDate <= @CutoffDate

				IF @IsDebug = 1
				BEGIN
					SET @MessageInfo = CONCAT ('db | pub name | cutoff date',' --> ',@PubDatabase,' | ', @PubName,' | ',@CutoffDate);
					RAISERROR (@MessageInfo,0,1) WITH NOWAIT
				END

			END TRY
			BEGIN CATCH
				
				IF @@TRANCOUNT > 0
						ROLLBACK TRANSACTION;

				SELECT ERROR_MESSAGE();

				IF @IsDebug = 1
				BEGIN
					SET @MessageInfo = CONCAT ('db | pub name | cutoff date',' --> ',@PubDatabase,' | ',@PubName,' | ', @CutoffDate);
					RAISERROR (@MessageInfo,0,1) WITH NOWAIT
				END

			END CATCH

			FETCH NEXT FROM PubName_cursor
			INTO @PubDatabase, @PubName, @pubid
		END

		CLOSE PubName_cursor;
		DEALLOCATE PubName_cursor;
	END

END

GO

