
SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

/****** Object:  Stored Procedure dbo.OAS_Users_CheckIn    Script Date: 1/21/2019 4:30:10 AM ******/
/****** Object:  Stored Procedure dbo.OAS_Users_CheckIn    Script Date: 3/13/2012 4:06:03 PM ******/
   
  
CREATE PROCEDURE [dbo].[OAS_Users_CheckIn]  
 @CustID   INT,  
 @NetSessionID VARCHAR(30),  
 @On_UserID  INT      OUTPUT,  
 @IP    VARCHAR(15)  = ''  
AS  
  
/*  
 * Created by : [20111512@Kos]  
 * Task  : check in user  
 * DB   : DB052.bodb_Licensee  
 * Revisions :  
 *  
 * Param's Explanation:    
 *  - @CustID  : Customer ID  
 *  - @NetSessionID : Net session ID  
 *  - @On_UserID : User ID  
 *  - @IP   : IP address  
 */  
  
SET NOCOUNT ON   
  
UPDATE OAS_OnUser WITH (ROWLOCK, UPDLOCK)   
SET IsKickedout = 1   
WHERE CustID = @CustID  
   
INSERT INTO OAS_OnUser  
 (custid, NetSessionID, IsKickedout, IP)  
VALUES  
 (@custid, @NetSessionid, 0, @IP)  
  
SELECT @On_UserID = SCOPE_IDENTITY()
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO


GO 
 GRANT EXECUTE ON [dbo].[OAS_Users_CheckIn] TO [bodbAdminNet]
GO 
