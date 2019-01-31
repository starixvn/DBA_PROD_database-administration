
SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

/****** Object:  Stored Procedure dbo.Dot_Dep_GetBaStatus    Script Date: 1/21/2019 4:30:01 AM ******/
CREATE PROCEDURE [dbo].[Dot_Dep_GetBaStatus]
	@custId int,	
	@transTime datetime = Null
AS
--20130521@Darren(Licensee DB): get customer ba status
--20130605@Darren(Licensee DB): add datetime condition
--20140403@Darren(Licensee DB): Fix Alway return 0 issue
BEGIN
	SET NOCOUNT ON;
	declare @status BIT 
	set @status=0
	if @transTime is null
	BEGIN
		IF EXISTS(select 1 from dbo.LicenseeBAHistory with(nolock) where CustID = @custId AND status='running')
			set @status = 1
	END
	ELSE IF EXISTS(
				select 1 
				from dbo.LicenseeBAHistory with(nolock)
				where CustID = @custId 
					and ( OnDate < @transTime and (OffDate > @transTime or OffDate is null ))
			)
	BEGIN
			set @status = 1
	END
	SELECT @status as status			
END


GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO


GO 
 GRANT EXECUTE ON [dbo].[Dot_Dep_GetBaStatus] TO [Dot_Member]
GO 
