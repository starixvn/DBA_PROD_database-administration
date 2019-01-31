
SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

/****** Object:  Stored Procedure dbo.GEN_MemberBetting    Script Date: 1/21/2019 4:30:01 AM ******/
CREATE PROCEDURE [dbo].[GEN_MemberBetting]
AS
/*
    Created: 20111026@Don
    Task: 
    DB: DB052.bodb_Licensee

    Revisions:

*/ 

    declare 
        @rptDateStart datetime,
        @strDateStart varchar(10),
        @rptDateEnd datetime,
        @strDateEnd varchar(10)
    
    
    -- ****** Licensee Member Betting ******
    select 
        @rptDateStart = MIN(b.winlostdate), 
        @strDateStart = CONVERT(varchar(10),@rptDateStart,120),
        --@rptDateEnd = DATEADD(day,-1,CURRENT_TIMESTAMP),
        @rptDateEnd = MAX(b.winlostdate), 
        @strDateEnd = CONVERT(varchar(10),@rptDateEnd,120)
    from dbo.bettrans b with(nolock)

    print 'GEN_rptLicMemberBetting ' + cast(@strDateStart as varchar) + ', ' + cast(@strDateEnd as varchar)
    EXECUTE dbo.GEN_rptLicMemberBetting @strDateStart, @strDateEnd
    
    print 'GEN_rptLicMemberBetting_BA ' + cast(@strDateStart as varchar) + ', ' + cast(@strDateEnd as varchar)
    EXECUTE dbo.GEN_rptLicMemberBetting_BA @strDateStart, @strDateEnd
    


GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO


GO 
