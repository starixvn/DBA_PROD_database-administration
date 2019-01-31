
SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

/****** Object:  Stored Procedure dbo.Lrf_CheckIn_mnl    Script Date: 1/21/2019 4:30:08 AM ******/
/****** Object:  Stored Procedure dbo.Lrf_CheckIn_mnl    Script Date: 4/3/2017 12:52:40 PM ******/

CREATE PROCEDURE dbo.Lrf_CheckIn_mnl
	@CustID int,
	@NetSessionID varchar(30),
	@ServerID int,
	@On_UserID int OUTPUT,
	@IP varchar(15) = ''
AS

/*
	Task: CheckIN
	DB: DB052.bodb_Licensee
	Original SP:LoginDownline_OnUser
	
	Revisions:
		- 20101208@Johnny

*/

--Open SubAccId if required
--if @@servername <> '5WRHH1S'--not kickout at local server for testing
	--update on_user with (ROWLOCK) set IsKickedout=1 where CustID = @CustID and ServerID = @ServerID

	
--insert into on_user
--	(custid, NetSessionID, ServerID, IsKickedout, IP)
--values
--	(@custid, @NetSessionid, @ServerID, 0, @IP)

Select @On_UserID = 0 --SCOPE_IDENTITY()
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO


GO 
 GRANT EXECUTE ON [dbo].[Lrf_CheckIn_mnl] TO [bodbAdminNet]
GO 
 GRANT EXECUTE ON [dbo].[Lrf_CheckIn_mnl] TO [bodbLicenseeNet]
GO 
