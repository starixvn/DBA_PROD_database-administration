/*<info serverAlias="DBCUST-MonDB,DBTRANS-MonDB,DBPRO-MonDB,DBTP-MonDB" executers="" isFunction="0"></info>*/

USE [MonDB]

GO

CREATE PROCEDURE [dbo].[DBA_Monitor_Latency_Pub_InsertToken]
(
	@IsDebug BIT = 0
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
					'select distinct ''',
					@PubDatabase,
					''', p.name, p.pubid, s.srvname as subname, s.dest_db as subdatabase from ',
					@PubDatabase,
					'.dbo.syspublications p inner join ',
					@PubDatabase,
					'.dbo.sysarticles a on p.pubid = a.pubid inner join ',
					@PubDatabase,
					'.dbo.syssubscriptions s on a.artid = s.artid ',
					'where s.srvid <> -1'
					);

			INSERT INTO @ReplInfo (Pub_DatabaseName, Pub_Name, Pub_Id, subscriber, subscriber_db)
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

	--/* insert trace token to publisher db
	BEGIN
		DECLARE @tokenID AS BIGINT;
		DECLARE @PubName SYSNAME, @PubId INT;
		DECLARE @MessageInfo NVARCHAR(MAX) = '';
		DECLARE @ParamDefinition NVARCHAR(max) = '@dyn_tracer_token_id int output, @dyn_publication sysname';

		--remove pubid that still pending
		DELETE r
		FROM @ReplInfo r
		INNER JOIN MonDB.dbo.RepTokens rt with(nolock)
			ON r.Pub_Name = rt.PubName AND r.Pub_DatabaseName = rt.PubDatabase AND r.subscriber = rt.SubName AND r.subscriber_db = rt.SubDatabase 
		WHERE rt.IsDone = 0
		
		DECLARE PubName_cursor CURSOR
		FOR
			SELECT distinct Pub_DatabaseName, Pub_Name, Pub_Id
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
					'.sys.sp_posttracertoken @publication = @dyn_publication, @tracer_token_id= @dyn_tracer_token_id OUTPUT'
					);

			BEGIN TRY
				EXEC sp_executesql @cmd,
					@ParamDefinition,
					@dyn_publication = @PubName,
					@dyn_tracer_token_id = @tokenID OUTPUT;

				IF @@TRANCOUNT > 0
					COMMIT TRANSACTION;

				--update tokenid to use later
				INSERT INTO MonDB.dbo.RepTokens (PubId,PubName, PubDatabase, TraceTokenId,CreatedDate,ModifiedDate,IsDone, SubName, SubDatabase	)
				--SELECT @PubId, @PubName, @PubDatabase, @tokenID, SYSDATETIME(), NULL, 0
				SELECT @PubId, @PubName, @PubDatabase, @tokenID, SYSDATETIME(), NULL, 0, r.subscriber, r.subscriber_db
				FROM @ReplInfo r
				WHERE r.Pub_Id = @PubId AND r.Pub_DatabaseName = @PubDatabase AND r.Pub_Name = @PubName

				IF @IsDebug = 1
				BEGIN
					SET @MessageInfo = CONCAT ('db | pub name | token id',' --> ',@PubDatabase,' | ', @PubName,' | ',@tokenID);
					RAISERROR (@MessageInfo,0,1) WITH NOWAIT
				END

			END TRY
			BEGIN CATCH
				
				IF @@TRANCOUNT > 0
						ROLLBACK TRANSACTION;

				SELECT ERROR_MESSAGE();

				IF @IsDebug = 1
				BEGIN
					SET @MessageInfo = CONCAT ('db | pub name | token id',' --> ',@PubDatabase,' | ',@PubName,' | ','NULL');
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

