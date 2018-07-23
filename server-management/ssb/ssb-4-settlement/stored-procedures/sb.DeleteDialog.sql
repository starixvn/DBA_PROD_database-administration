USE [bodb02]
GO

CREATE PROCEDURE [sb].[DeleteDialog]
	@dialogHandle UNIQUEIDENTIFIER
AS
/*  Created: Viet @ 20140210
	Task : delete a dialog
	DB: bodb02 @ DB052/DB053/DB054/DB06
	Revisions:  
			
*/
BEGIN
	SET NOCOUNT ON;
		
	DELETE [sb].[DialogPool] WHERE Handle = @dialogHandle
END


GO

GRANT VIEW DEFINITION ON [sb].[DeleteDialog] TO [vnteam] AS [dbo]
GO


