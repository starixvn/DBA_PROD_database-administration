
SET QUOTED_IDENTIFIER ON 
GO
SET ANSI_NULLS ON 
GO

/****** Object:  Stored Procedure dbo.LA_CumulativeRebateGroupInfoSel    Script Date: 1/21/2019 4:30:02 AM ******/
/****** Object:  Stored Procedure dbo.LA_CumulativeRebateGroupInfoSel    Script Date: 11/27/2017 3:40:43 AM ******/
CREATE PROCEDURE [dbo].[LA_CumulativeRebateGroupInfoSel]
AS  
/*
	Created: 2017.11.02 - Bruce.bui
	Task : Select rebate group info
	DB: DB052.bodb_Licensee  

Revisions:
	- 20171102@Bruce: Create New SP [RedmineID: #84163]
	
Example:
	USE bodb_licensee
		EXEC [LA_CumulativeRebateGroupInfoSel]
*/
BEGIN
	SET NOCOUNT ON

	DECLARE @RebateGroup TABLE(Id INT, [Name] NVARCHAR(200))
	INSERT INTO @RebateGroup(Id, [Name])
	(
		SELECT DISTINCT h.SettingGroupHeaderId, h.GroupName
		FROM dbo.LA_SettingGroupHeader h WITH(NOLOCK)
		INNER JOIN dbo.LA_SettingGroupAssignment a WITH(NOLOCK) ON a.SettingGroupHeaderId=h.SettingGroupHeaderId
		INNER JOIN dbo.OAS_Party p WITH(NOLOCK) ON a.PartyId=p.PartyID -- remove empty group
		WHERE h.SettingGroupHeaderId IN (
			SELECT DISTINCT SettingGroupHeaderId
			FROM dbo.LA_SettingGroupDetail d WITH(NOLOCK)
			WHERE d.[Status] = 'Active'
		)
	)

	SELECT * FROM @RebateGroup WHERE Id > 0

END
GO

SET QUOTED_IDENTIFIER OFF 
GO
SET ANSI_NULLS ON 
GO


GO 
 GRANT EXECUTE ON [dbo].[LA_CumulativeRebateGroupInfoSel] TO [bodbAdminNet]
GO 
 GRANT VIEW DEFINITION ON [dbo].[LA_CumulativeRebateGroupInfoSel] TO [vnteam]
GO 
