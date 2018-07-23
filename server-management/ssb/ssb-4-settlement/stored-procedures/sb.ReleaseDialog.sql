USE [bodb02]
GO
/****** Object:  StoredProcedure [sb].[ReleaseDialog]    Script Date: 7/22/2018 11:29:08 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [sb].[ReleaseDialog]
      @dialogHandle UNIQUEIDENTIFIER,
      @sendCount BIGINT
AS
/*  Created: Viet @ 20140210
	Task : release a dialog
	DB: bodb02 @ DB052/DB053/DB054/DB06
	Revisions:   
			
*/
BEGIN
	SET NOCOUNT ON
	DECLARE @rowcount INT, @string VARCHAR(50) 

	-- Release dialog by setting OwnerSPID to -1.
	UPDATE [sb].[DialogPool] WITH(ROWLOCK, UPDLOCK)
		SET OwnerSPID = -1, SendCount = @sendCount 
	WHERE Handle = @dialogHandle
END

