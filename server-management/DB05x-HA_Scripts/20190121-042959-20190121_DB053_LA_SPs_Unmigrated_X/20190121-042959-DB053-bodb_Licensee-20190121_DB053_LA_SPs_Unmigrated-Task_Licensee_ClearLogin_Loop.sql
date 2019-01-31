
SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

/****** Object:  Stored Procedure dbo.Task_Licensee_ClearLogin_Loop    Script Date: 1/21/2019 4:30:11 AM ******/
CREATE PROCEDURE [dbo].[Task_Licensee_ClearLogin_Loop]  
AS  
/*
	Created:  20101209@Henry
	Task: Clear Login
	DB: DB052.bodb_Licensee
	Original SP:
	
	Revisions:
		
*/
 Declare @start datetime  
 SELECT @start = CURRENT_TIMESTAMP  
  
 WHILE (1=1) AND (DATEDIFF(minute,@start, CURRENT_TIMESTAMP) < 20)  
 BEGIN  
  EXEC Task_Licensee_ClearLogin  
  WAITFOR DELAY '00:00:30'  
 END  
 

GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO


GO 
