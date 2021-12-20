/*
SELECT 'ALTER LOGIN ['+name+'] ENABLE;' FROM sys.sql_logins
WHERE name NOT LIKE '#%'
  AND name NOT LIKE '%\%'
  AND name NOT LIKE 'RD%'
  AND name NOT LIKE 'vn%'
  AND name NOT IN ('viet',  'thien','sa')
  AND name <> 'MonDB_User'
  AND is_disabled=0
ORDER BY 1
GO

*/
-----------------------------------------------------------------------
ALTER LOGIN [bodbAdminNet] ENABLE;
ALTER LOGIN [bodbDownlineNet] ENABLE;
ALTER LOGIN [bodbDownlineNetView] ENABLE;
ALTER LOGIN [bodbExtAccNet] ENABLE;
ALTER LOGIN [bodbLicenseeNet] ENABLE;
ALTER LOGIN [bodbOWPNet] ENABLE;
ALTER LOGIN [bodbRMSNet] ENABLE;
ALTER LOGIN [bodbSPUNet] ENABLE;
ALTER LOGIN [bodbTGRSNet] ENABLE;
ALTER LOGIN [CNS_Sales] ENABLE;
ALTER LOGIN [DataSync] ENABLE;
ALTER LOGIN [db06_sync_custinfo_usr] ENABLE;
ALTER LOGIN [Dot_3rdparty] ENABLE;
ALTER LOGIN [Dot_Admin] ENABLE;
ALTER LOGIN [Dot_Bonus] ENABLE;
ALTER LOGIN [Dot_Casino] ENABLE;
ALTER LOGIN [Dot_InfoSite] ENABLE;
ALTER LOGIN [Dot_Intg] ENABLE;
ALTER LOGIN [Dot_LicCentral] ENABLE;
ALTER LOGIN [Dot_Member] ENABLE;
ALTER LOGIN [Dot_P2P] ENABLE;
ALTER LOGIN [Dot_PandR] ENABLE;
ALTER LOGIN [Dot_RefUser] ENABLE;
ALTER LOGIN [dwrs] ENABLE;
ALTER LOGIN [dwrs2] ENABLE;
ALTER LOGIN [ibcrep] ENABLE;
ALTER LOGIN [Intg_BI] ENABLE;
ALTER LOGIN [LicBIUser] ENABLE;
ALTER LOGIN [Member2API] ENABLE;
ALTER LOGIN [Portal] ENABLE;
ALTER LOGIN [repl_ap] ENABLE;
ALTER LOGIN [RMAUser] ENABLE;
ALTER LOGIN [Save_Files] ENABLE;
ALTER LOGIN [ServerMonitor] ENABLE;
ALTER LOGIN [SqlLink] ENABLE;
