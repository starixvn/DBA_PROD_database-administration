
SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

/****** Object:  Stored Procedure dbo.LRF_CheckDataReady_KPIs    Script Date: 1/21/2019 4:30:08 AM ******/
/****** Object:  Stored Procedure dbo.LRF_CheckDataReady_KPIs    Script Date: 10/31/2016 11:03:01 PM ******/
/****** Object:  Stored Procedure dbo.LRF_CheckDataReady_KPIs    Script Date: 10/31/2016 11:02:54 ******/
CREATE PROCEDURE [dbo].[LRF_CheckDataReady_KPIs]
    @ReportDate datetime = NULL
AS
/*
    Created: 20111012@Don
    Task: Check if data ready for main KPI report
    DB: DB052.bodb_Licensee

    Revisions:
        -20121026@Jim: add more NumberGame data
        -20160726@Francis: Move SP to bodb_LicenseeReport - [Redmine: #60449]
    Param's Explanation:

*/
SET NOCOUNT ON

declare @Date datetime
declare @Flag bit
select @Flag = convert(bit,1)
  
if (@ReportDate IS NULL)
    select @Date = convert(varchar(10), dateadd(dd, -1, current_timestamp), 120)
else
    select @Date = convert(varchar(10), @ReportDate, 120)

-- rptKPI_Transfer    
if (@Flag = convert(bit,1))
    if (not exists(select * from bodb_LicenseeReport.dbo.rptKPI_MTD_Cross (nolock) where rptDate = @Date and StatID in (1,2,3,4)))
        select @Flag = convert(bit,0)

-- rpt_Betting
if (@Flag = convert(bit,1))
    if (not exists(select * from bodb_LicenseeReport.dbo.rptKPI_MTD_Cross (nolock) where rptDate = @Date and StatID between 7 and 23))
        select @Flag = convert(bit,0)
----20121026@Jim added 
if (@Flag = convert(bit,1))
    if (not exists(select * from bodb_LicenseeReport.dbo.rptKPI_MTD_3rdProducts (nolock) where rptDate = @Date ))
        select @Flag = convert(bit,0)

		
-- rptKPI_Account
if (@Flag = convert(bit,1))
    if (not exists(select * from bodb_LicenseeReport.dbo.rptKPI_MTD_Cross (nolock) where rptDate = @Date and StatID in (5,6)))
        select @Flag = convert(bit,0)

--SET @Flag=convert(BIT,1)--- for create data test on local

select @Flag DataAvailable

SET NOCOUNT OFF
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO


GO 
 GRANT EXECUTE ON [dbo].[LRF_CheckDataReady_KPIs] TO [bodbAdminNet]
GO 
 GRANT VIEW DEFINITION ON [dbo].[LRF_CheckDataReady_KPIs] TO [vnteam]
GO 
 GRANT EXECUTE ON [dbo].[LRF_CheckDataReady_KPIs] TO [bodbLicenseeNet]
GO 
