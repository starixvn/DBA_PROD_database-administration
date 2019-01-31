/*
	Task: Create views with same name of tables in bodb_Licensee & get data from db053 (HA DB052 down)
	Run on DB054
*/

--====== CREATE VIEW Aff_FunctionInfo ======
CREATE VIEW dbo.Aff_FunctionInfo
AS
SELECT * FROM DB053.bodb_Licensee.dbo.Aff_FunctionInfo WITH (NOLOCK)
GO
--====== END CREATE VIEW Aff_FunctionInfo ======

--====== CREATE VIEW Aff_GroupInfo ======
CREATE VIEW dbo.Aff_GroupInfo
AS
SELECT * FROM DB053.bodb_Licensee.dbo.Aff_GroupInfo WITH (NOLOCK)
GO
--====== END CREATE VIEW Aff_GroupInfo ======

--====== CREATE VIEW Aff_GroupPolicy ======
CREATE VIEW dbo.Aff_GroupPolicy
AS
SELECT * FROM DB053.bodb_Licensee.dbo.Aff_GroupPolicy WITH (NOLOCK)
GO
--====== END CREATE VIEW Aff_GroupPolicy ======

--====== CREATE VIEW Aff_LicenseeFunction ======
CREATE VIEW dbo.Aff_LicenseeFunction
AS
SELECT * FROM DB053.bodb_Licensee.dbo.Aff_LicenseeFunction WITH (NOLOCK)
GO
--====== END CREATE VIEW Aff_LicenseeFunction ======

--====== CREATE VIEW Aff_LicenseeInfo ======
CREATE VIEW dbo.Aff_LicenseeInfo
AS
SELECT * FROM DB053.bodb_Licensee.dbo.Aff_LicenseeInfo WITH (NOLOCK)
GO
--====== END CREATE VIEW Aff_LicenseeInfo ======

--====== CREATE VIEW Aff_LicenseeUser ======
CREATE VIEW dbo.Aff_LicenseeUser
AS
SELECT * FROM DB053.bodb_Licensee.dbo.Aff_LicenseeUser WITH (NOLOCK)
GO
--====== END CREATE VIEW Aff_LicenseeUser ======

--====== CREATE VIEW Aff_On_User ======
CREATE VIEW dbo.Aff_On_User
AS
SELECT * FROM DB053.bodb_Licensee.dbo.Aff_On_User WITH (NOLOCK)
GO
--====== END CREATE VIEW Aff_On_User ======

--====== CREATE VIEW Aff_User_CreatorTransfer ======
CREATE VIEW dbo.Aff_User_CreatorTransfer
AS
SELECT * FROM DB053.bodb_Licensee.dbo.Aff_User_CreatorTransfer WITH (NOLOCK)
GO
--====== END CREATE VIEW Aff_User_CreatorTransfer ======

--====== CREATE VIEW Aff_UserPolicy ======
CREATE VIEW dbo.Aff_UserPolicy
AS
SELECT * FROM DB053.bodb_Licensee.dbo.Aff_UserPolicy WITH (NOLOCK)
GO
--====== END CREATE VIEW Aff_UserPolicy ======

--====== CREATE VIEW Country ======
CREATE VIEW dbo.Country
AS
SELECT * FROM DB053.bodb_Licensee.dbo.Country WITH (NOLOCK)
GO
--====== END CREATE VIEW Country ======

--====== CREATE VIEW CurrencyUser ======
CREATE VIEW dbo.CurrencyUser
AS
SELECT * FROM DB053.bodb_Licensee.dbo.CurrencyUser WITH (NOLOCK)
GO
--====== END CREATE VIEW CurrencyUser ======

--====== CREATE VIEW Functions ======
CREATE VIEW dbo.Functions
AS
SELECT * FROM DB053.bodb_Licensee.dbo.Functions WITH (NOLOCK)
GO
--====== END CREATE VIEW Functions ======

--====== CREATE VIEW LA_AnalysisFile ======
CREATE VIEW dbo.LA_AnalysisFile
AS
SELECT * FROM DB053.bodb_Licensee.dbo.LA_AnalysisFile WITH (NOLOCK)
GO
--====== END CREATE VIEW LA_AnalysisFile ======

--====== CREATE VIEW LA_BankInfo ======
CREATE VIEW dbo.LA_BankInfo
AS
SELECT * FROM DB053.bodb_Licensee.dbo.LA_BankInfo WITH (NOLOCK)
GO
--====== END CREATE VIEW LA_BankInfo ======

--====== CREATE VIEW LA_BillerInfo ======
CREATE VIEW dbo.LA_BillerInfo
AS
SELECT * FROM DB053.bodb_Licensee.dbo.LA_BillerInfo WITH (NOLOCK)
GO
--====== END CREATE VIEW LA_BillerInfo ======

--====== CREATE VIEW LA_ChargeInfo_MinFee ======
CREATE VIEW dbo.LA_ChargeInfo_MinFee
AS
SELECT * FROM DB053.bodb_Licensee.dbo.LA_ChargeInfo_MinFee WITH (NOLOCK)
GO
--====== END CREATE VIEW LA_ChargeInfo_MinFee ======

--====== CREATE VIEW LA_ChargeInfo_SystemMapping ======
CREATE VIEW dbo.LA_ChargeInfo_SystemMapping
AS
SELECT * FROM DB053.bodb_Licensee.dbo.LA_ChargeInfo_SystemMapping WITH (NOLOCK)
GO
--====== END CREATE VIEW LA_ChargeInfo_SystemMapping ======

--====== CREATE VIEW LA_DiscountGroupAssignment ======
CREATE VIEW dbo.LA_DiscountGroupAssignment
AS
SELECT * FROM DB053.bodb_Licensee.dbo.LA_DiscountGroupAssignment WITH (NOLOCK)
GO
--====== END CREATE VIEW LA_DiscountGroupAssignment ======

--====== CREATE VIEW LA_DiscountGroupCurrency ======
CREATE VIEW dbo.LA_DiscountGroupCurrency
AS
SELECT * FROM DB053.bodb_Licensee.dbo.LA_DiscountGroupCurrency WITH (NOLOCK)
GO
--====== END CREATE VIEW LA_DiscountGroupCurrency ======

--====== CREATE VIEW LA_DiscountGroupDetail ======
CREATE VIEW dbo.LA_DiscountGroupDetail
AS
SELECT * FROM DB053.bodb_Licensee.dbo.LA_DiscountGroupDetail WITH (NOLOCK)
GO
--====== END CREATE VIEW LA_DiscountGroupDetail ======

--====== CREATE VIEW LA_DiscountGroupHeader ======
CREATE VIEW dbo.LA_DiscountGroupHeader
AS
SELECT * FROM DB053.bodb_Licensee.dbo.LA_DiscountGroupHeader WITH (NOLOCK)
GO
--====== END CREATE VIEW LA_DiscountGroupHeader ======

--====== CREATE VIEW LA_DiscountGroupProduct ======
CREATE VIEW dbo.LA_DiscountGroupProduct
AS
SELECT * FROM DB053.bodb_Licensee.dbo.LA_DiscountGroupProduct WITH (NOLOCK)
GO
--====== END CREATE VIEW LA_DiscountGroupProduct ======

--====== CREATE VIEW LA_Function ======
CREATE VIEW dbo.LA_Function
AS
SELECT * FROM DB053.bodb_Licensee.dbo.LA_Function WITH (NOLOCK)
GO
--====== END CREATE VIEW LA_Function ======

--====== CREATE VIEW LA_FunctionParty ======
CREATE VIEW dbo.LA_FunctionParty
AS
SELECT * FROM DB053.bodb_Licensee.dbo.LA_FunctionParty WITH (NOLOCK)
GO
--====== END CREATE VIEW LA_FunctionParty ======

--====== CREATE VIEW LA_Group ======
CREATE VIEW dbo.LA_Group
AS
SELECT * FROM DB053.bodb_Licensee.dbo.LA_Group WITH (NOLOCK)
GO
--====== END CREATE VIEW LA_Group ======

--====== CREATE VIEW LA_GroupFunction ======
CREATE VIEW dbo.LA_GroupFunction
AS
SELECT * FROM DB053.bodb_Licensee.dbo.LA_GroupFunction WITH (NOLOCK)
GO
--====== END CREATE VIEW LA_GroupFunction ======

--====== CREATE VIEW LA_HostingFees ======
CREATE VIEW dbo.LA_HostingFees
AS
SELECT * FROM DB053.bodb_Licensee.dbo.LA_HostingFees WITH (NOLOCK)
GO
--====== END CREATE VIEW LA_HostingFees ======

--====== CREATE VIEW LA_HostingFeesDetail ======
CREATE VIEW dbo.LA_HostingFeesDetail
AS
SELECT * FROM DB053.bodb_Licensee.dbo.LA_HostingFeesDetail WITH (NOLOCK)
GO
--====== END CREATE VIEW LA_HostingFeesDetail ======

--====== CREATE VIEW LA_HostingFeesSetting ======
CREATE VIEW dbo.LA_HostingFeesSetting
AS
SELECT * FROM DB053.bodb_Licensee.dbo.LA_HostingFeesSetting WITH (NOLOCK)
GO
--====== END CREATE VIEW LA_HostingFeesSetting ======

--====== CREATE VIEW LA_HostingFeesTypes ======
CREATE VIEW dbo.LA_HostingFeesTypes
AS
SELECT * FROM DB053.bodb_Licensee.dbo.LA_HostingFeesTypes WITH (NOLOCK)
GO
--====== END CREATE VIEW LA_HostingFeesTypes ======

--====== CREATE VIEW LA_InvoiceDetail ======
CREATE VIEW dbo.LA_InvoiceDetail
AS
SELECT * FROM DB053.bodb_Licensee.dbo.LA_InvoiceDetail WITH (NOLOCK)
GO
--====== END CREATE VIEW LA_InvoiceDetail ======

--====== CREATE VIEW LA_InvoiceHeader ======
CREATE VIEW dbo.LA_InvoiceHeader
AS
SELECT * FROM DB053.bodb_Licensee.dbo.LA_InvoiceHeader WITH (NOLOCK)
GO
--====== END CREATE VIEW LA_InvoiceHeader ======

--====== CREATE VIEW LA_InvoiceItemType ======
CREATE VIEW dbo.LA_InvoiceItemType
AS
SELECT * FROM DB053.bodb_Licensee.dbo.LA_InvoiceItemType WITH (NOLOCK)
GO
--====== END CREATE VIEW LA_InvoiceItemType ======

--====== CREATE VIEW LA_InvoiceSetting ======
CREATE VIEW dbo.LA_InvoiceSetting
AS
SELECT * FROM DB053.bodb_Licensee.dbo.LA_InvoiceSetting WITH (NOLOCK)
GO
--====== END CREATE VIEW LA_InvoiceSetting ======

--====== CREATE VIEW LA_InvoiceStatement ======
CREATE VIEW dbo.LA_InvoiceStatement
AS
SELECT * FROM DB053.bodb_Licensee.dbo.LA_InvoiceStatement WITH (NOLOCK)
GO
--====== END CREATE VIEW LA_InvoiceStatement ======

--====== CREATE VIEW LA_InvoiceTemplate ======
CREATE VIEW dbo.LA_InvoiceTemplate
AS
SELECT * FROM DB053.bodb_Licensee.dbo.LA_InvoiceTemplate WITH (NOLOCK)
GO
--====== END CREATE VIEW LA_InvoiceTemplate ======

--====== CREATE VIEW LA_InvoiceType ======
CREATE VIEW dbo.LA_InvoiceType
AS
SELECT * FROM DB053.bodb_Licensee.dbo.LA_InvoiceType WITH (NOLOCK)
GO
--====== END CREATE VIEW LA_InvoiceType ======

--====== CREATE VIEW LA_InvoiceTypeMapping ======
CREATE VIEW dbo.LA_InvoiceTypeMapping
AS
SELECT * FROM DB053.bodb_Licensee.dbo.LA_InvoiceTypeMapping WITH (NOLOCK)
GO
--====== END CREATE VIEW LA_InvoiceTypeMapping ======

--====== CREATE VIEW LA_LicenseeRebate ======
CREATE VIEW dbo.LA_LicenseeRebate
AS
SELECT * FROM DB053.bodb_Licensee.dbo.LA_LicenseeRebate WITH (NOLOCK)
GO
--====== END CREATE VIEW LA_LicenseeRebate ======

--====== CREATE VIEW LA_MinFee ======
CREATE VIEW dbo.LA_MinFee
AS
SELECT * FROM DB053.bodb_Licensee.dbo.LA_MinFee WITH (NOLOCK)
GO
--====== END CREATE VIEW LA_MinFee ======

--====== CREATE VIEW LA_OnUser ======
CREATE VIEW dbo.LA_OnUser
AS
SELECT * FROM DB053.bodb_Licensee.dbo.LA_OnUser WITH (NOLOCK)
GO
--====== END CREATE VIEW LA_OnUser ======

--====== CREATE VIEW LA_PartyGroup ======
CREATE VIEW dbo.LA_PartyGroup
AS
SELECT * FROM DB053.bodb_Licensee.dbo.LA_PartyGroup WITH (NOLOCK)
GO
--====== END CREATE VIEW LA_PartyGroup ======

--====== CREATE VIEW LA_PartyGroupAssignment ======
CREATE VIEW dbo.LA_PartyGroupAssignment
AS
SELECT * FROM DB053.bodb_Licensee.dbo.LA_PartyGroupAssignment WITH (NOLOCK)
GO
--====== END CREATE VIEW LA_PartyGroupAssignment ======

--====== CREATE VIEW LA_Product3rdSub ======
CREATE VIEW dbo.LA_Product3rdSub
AS
SELECT * FROM DB053.bodb_Licensee.dbo.LA_Product3rdSub WITH (NOLOCK)
GO
--====== END CREATE VIEW LA_Product3rdSub ======

--====== CREATE VIEW LA_SettingGroupAssignment ======
CREATE VIEW dbo.LA_SettingGroupAssignment
AS
SELECT * FROM DB053.bodb_Licensee.dbo.LA_SettingGroupAssignment WITH (NOLOCK)
GO
--====== END CREATE VIEW LA_SettingGroupAssignment ======

--====== CREATE VIEW LA_SettingGroupDetail ======
CREATE VIEW dbo.LA_SettingGroupDetail
AS
SELECT * FROM DB053.bodb_Licensee.dbo.LA_SettingGroupDetail WITH (NOLOCK)
GO
--====== END CREATE VIEW LA_SettingGroupDetail ======

--====== CREATE VIEW LA_SettingGroupHeader ======
CREATE VIEW dbo.LA_SettingGroupHeader
AS
SELECT * FROM DB053.bodb_Licensee.dbo.LA_SettingGroupHeader WITH (NOLOCK)
GO
--====== END CREATE VIEW LA_SettingGroupHeader ======

--====== CREATE VIEW LA_SystemSettings ======
CREATE VIEW dbo.LA_SystemSettings
AS
SELECT * FROM DB053.bodb_Licensee.dbo.LA_SystemSettings WITH (NOLOCK)
GO
--====== END CREATE VIEW LA_SystemSettings ======

--====== CREATE VIEW LA_User ======
CREATE VIEW dbo.LA_User
AS
SELECT * FROM DB053.bodb_Licensee.dbo.LA_User WITH (NOLOCK)
GO
--====== END CREATE VIEW LA_User ======

--====== CREATE VIEW LA_UserFunction ======
CREATE VIEW dbo.LA_UserFunction
AS
SELECT * FROM DB053.bodb_Licensee.dbo.LA_UserFunction WITH (NOLOCK)
GO
--====== END CREATE VIEW LA_UserFunction ======

--====== CREATE VIEW LA_UserParty ======
CREATE VIEW dbo.LA_UserParty
AS
SELECT * FROM DB053.bodb_Licensee.dbo.LA_UserParty WITH (NOLOCK)
GO
--====== END CREATE VIEW LA_UserParty ======

--====== CREATE VIEW Labels ======
CREATE VIEW dbo.Labels
AS
SELECT * FROM DB053.bodb_Licensee.dbo.Labels WITH (NOLOCK)
GO
--====== END CREATE VIEW Labels ======

--====== CREATE VIEW LicenseeBAConfig ======
CREATE VIEW dbo.LicenseeBAConfig
AS
SELECT * FROM DB053.bodb_Licensee.dbo.LicenseeBAConfig WITH (NOLOCK)
GO
--====== END CREATE VIEW LicenseeBAConfig ======

--====== CREATE VIEW LicenseeBAHistory ======
CREATE VIEW dbo.LicenseeBAHistory
AS
SELECT * FROM DB053.bodb_Licensee.dbo.LicenseeBAHistory WITH (NOLOCK)
GO
--====== END CREATE VIEW LicenseeBAHistory ======

--====== CREATE VIEW LicenseeBATransaction ======
CREATE VIEW dbo.LicenseeBATransaction
AS
SELECT * FROM DB053.bodb_Licensee.dbo.LicenseeBATransaction WITH (NOLOCK)
GO
--====== END CREATE VIEW LicenseeBATransaction ======

--====== CREATE VIEW LicenseeBATransaction_active ======
CREATE VIEW dbo.LicenseeBATransaction_active
AS
SELECT * FROM DB053.bodb_Licensee.dbo.LicenseeBATransaction_active WITH (NOLOCK)
GO
--====== END CREATE VIEW LicenseeBATransaction_active ======

--====== CREATE VIEW LicenseeBATransaction_bk ======
CREATE VIEW dbo.LicenseeBATransaction_bk
AS
SELECT * FROM DB053.bodb_Licensee.dbo.LicenseeBATransaction_bk WITH (NOLOCK)
GO
--====== END CREATE VIEW LicenseeBATransaction_bk ======

--====== CREATE VIEW LicenseeCurrencyBAGroup ======
CREATE VIEW dbo.LicenseeCurrencyBAGroup
AS
SELECT * FROM DB053.bodb_Licensee.dbo.LicenseeCurrencyBAGroup WITH (NOLOCK)
GO
--====== END CREATE VIEW LicenseeCurrencyBAGroup ======

--====== CREATE VIEW LicenseeCust ======
CREATE VIEW dbo.LicenseeCust
AS
SELECT * FROM DB053.bodb_Licensee.dbo.LicenseeCust WITH (NOLOCK)
GO
--====== END CREATE VIEW LicenseeCust ======

--====== CREATE VIEW LicenseeCustComm ======
CREATE VIEW dbo.LicenseeCustComm
AS
SELECT * FROM DB053.bodb_Licensee.dbo.LicenseeCustComm WITH (NOLOCK)
GO
--====== END CREATE VIEW LicenseeCustComm ======

--====== CREATE VIEW LicenseeEventLog ======
CREATE VIEW dbo.LicenseeEventLog
AS
SELECT * FROM DB053.bodb_Licensee.dbo.LicenseeEventLog WITH (NOLOCK)
GO
--====== END CREATE VIEW LicenseeEventLog ======

--====== CREATE VIEW LicenseeFunctions ======
CREATE VIEW dbo.LicenseeFunctions
AS
SELECT * FROM DB053.bodb_Licensee.dbo.LicenseeFunctions WITH (NOLOCK)
GO
--====== END CREATE VIEW LicenseeFunctions ======

--====== CREATE VIEW LicenseeGroupComm ======
CREATE VIEW dbo.LicenseeGroupComm
AS
SELECT * FROM DB053.bodb_Licensee.dbo.LicenseeGroupComm WITH (NOLOCK)
GO
--====== END CREATE VIEW LicenseeGroupComm ======

--====== CREATE VIEW LicenseeMultiCurrencyConfig ======
CREATE VIEW dbo.LicenseeMultiCurrencyConfig
AS
SELECT * FROM DB053.bodb_Licensee.dbo.LicenseeMultiCurrencyConfig WITH (NOLOCK)
GO
--====== END CREATE VIEW LicenseeMultiCurrencyConfig ======

--====== CREATE VIEW LicenseeProduct3rd ======
CREATE VIEW dbo.LicenseeProduct3rd
AS
SELECT * FROM DB053.bodb_Licensee.dbo.LicenseeProduct3rd WITH (NOLOCK)
GO
--====== END CREATE VIEW LicenseeProduct3rd ======

--====== CREATE VIEW LicenseeReseller ======
CREATE VIEW dbo.LicenseeReseller
AS
SELECT * FROM DB053.bodb_Licensee.dbo.LicenseeReseller WITH (NOLOCK)
GO
--====== END CREATE VIEW LicenseeReseller ======

--====== CREATE VIEW Licensees ======
CREATE VIEW dbo.Licensees
AS
SELECT * FROM DB053.bodb_Licensee.dbo.Licensees WITH (NOLOCK)
GO
--====== END CREATE VIEW Licensees ======

--====== CREATE VIEW LicenseeSourcedSetting ======
CREATE VIEW dbo.LicenseeSourcedSetting
AS
SELECT * FROM DB053.bodb_Licensee.dbo.LicenseeSourcedSetting WITH (NOLOCK)
GO
--====== END CREATE VIEW LicenseeSourcedSetting ======

--====== CREATE VIEW LicenseeSourcedSetting_DanielBK_AddPK ======
CREATE VIEW dbo.LicenseeSourcedSetting_DanielBK_AddPK
AS
SELECT * FROM DB053.bodb_Licensee.dbo.LicenseeSourcedSetting_DanielBK_AddPK WITH (NOLOCK)
GO
--====== END CREATE VIEW LicenseeSourcedSetting_DanielBK_AddPK ======

--====== CREATE VIEW LicenseeSpecialCust ======
CREATE VIEW dbo.LicenseeSpecialCust
AS
SELECT * FROM DB053.bodb_Licensee.dbo.LicenseeSpecialCust WITH (NOLOCK)
GO
--====== END CREATE VIEW LicenseeSpecialCust ======

--====== CREATE VIEW LicenseeUser ======
CREATE VIEW dbo.LicenseeUser
AS
SELECT * FROM DB053.bodb_Licensee.dbo.LicenseeUser WITH (NOLOCK)
GO
--====== END CREATE VIEW LicenseeUser ======

--====== CREATE VIEW LicenseeUserFunctions ======
CREATE VIEW dbo.LicenseeUserFunctions
AS
SELECT * FROM DB053.bodb_Licensee.dbo.LicenseeUserFunctions WITH (NOLOCK)
GO
--====== END CREATE VIEW LicenseeUserFunctions ======

--====== CREATE VIEW LICSettings ======
CREATE VIEW dbo.LICSettings
AS
SELECT * FROM DB053.bodb_Licensee.dbo.LICSettings WITH (NOLOCK)
GO
--====== END CREATE VIEW LICSettings ======

--====== CREATE VIEW LrfDomain ======
CREATE VIEW dbo.LrfDomain
AS
SELECT * FROM DB053.bodb_Licensee.dbo.LrfDomain WITH (NOLOCK)
GO
--====== END CREATE VIEW LrfDomain ======

--====== CREATE VIEW MSreplication_objects ======
CREATE VIEW dbo.MSreplication_objects
AS
SELECT * FROM DB053.bodb_Licensee.dbo.MSreplication_objects WITH (NOLOCK)
GO
--====== END CREATE VIEW MSreplication_objects ======

--====== CREATE VIEW MSreplication_subscriptions ======
CREATE VIEW dbo.MSreplication_subscriptions
AS
SELECT * FROM DB053.bodb_Licensee.dbo.MSreplication_subscriptions WITH (NOLOCK)
GO
--====== END CREATE VIEW MSreplication_subscriptions ======

--====== CREATE VIEW MSsubscription_agents ======
CREATE VIEW dbo.MSsubscription_agents
AS
SELECT * FROM DB053.bodb_Licensee.dbo.MSsubscription_agents WITH (NOLOCK)
GO
--====== END CREATE VIEW MSsubscription_agents ======

--====== CREATE VIEW OA_FunctionLicensees ======
CREATE VIEW dbo.OA_FunctionLicensees
AS
SELECT * FROM DB053.bodb_Licensee.dbo.OA_FunctionLicensees WITH (NOLOCK)
GO
--====== END CREATE VIEW OA_FunctionLicensees ======

--====== CREATE VIEW OA_FunctionResellers ======
CREATE VIEW dbo.OA_FunctionResellers
AS
SELECT * FROM DB053.bodb_Licensee.dbo.OA_FunctionResellers WITH (NOLOCK)
GO
--====== END CREATE VIEW OA_FunctionResellers ======

--====== CREATE VIEW OA_Functions ======
CREATE VIEW dbo.OA_Functions
AS
SELECT * FROM DB053.bodb_Licensee.dbo.OA_Functions WITH (NOLOCK)
GO
--====== END CREATE VIEW OA_Functions ======

--====== CREATE VIEW OA_GroupFunctions ======
CREATE VIEW dbo.OA_GroupFunctions
AS
SELECT * FROM DB053.bodb_Licensee.dbo.OA_GroupFunctions WITH (NOLOCK)
GO
--====== END CREATE VIEW OA_GroupFunctions ======

--====== CREATE VIEW OA_GroupLicensees ======
CREATE VIEW dbo.OA_GroupLicensees
AS
SELECT * FROM DB053.bodb_Licensee.dbo.OA_GroupLicensees WITH (NOLOCK)
GO
--====== END CREATE VIEW OA_GroupLicensees ======

--====== CREATE VIEW OA_GroupResellers ======
CREATE VIEW dbo.OA_GroupResellers
AS
SELECT * FROM DB053.bodb_Licensee.dbo.OA_GroupResellers WITH (NOLOCK)
GO
--====== END CREATE VIEW OA_GroupResellers ======

--====== CREATE VIEW OA_Groups ======
CREATE VIEW dbo.OA_Groups
AS
SELECT * FROM DB053.bodb_Licensee.dbo.OA_Groups WITH (NOLOCK)
GO
--====== END CREATE VIEW OA_Groups ======

--====== CREATE VIEW OA_LogAction ======
CREATE VIEW dbo.OA_LogAction
AS
SELECT * FROM DB053.bodb_Licensee.dbo.OA_LogAction WITH (NOLOCK)
GO
--====== END CREATE VIEW OA_LogAction ======

--====== CREATE VIEW OA_LogActionType ======
CREATE VIEW dbo.OA_LogActionType
AS
SELECT * FROM DB053.bodb_Licensee.dbo.OA_LogActionType WITH (NOLOCK)
GO
--====== END CREATE VIEW OA_LogActionType ======

--====== CREATE VIEW OA_Menus ======
CREATE VIEW dbo.OA_Menus
AS
SELECT * FROM DB053.bodb_Licensee.dbo.OA_Menus WITH (NOLOCK)
GO
--====== END CREATE VIEW OA_Menus ======

--====== CREATE VIEW OA_OnUser ======
CREATE VIEW dbo.OA_OnUser
AS
SELECT * FROM DB053.bodb_Licensee.dbo.OA_OnUser WITH (NOLOCK)
GO
--====== END CREATE VIEW OA_OnUser ======

--====== CREATE VIEW OA_UserFunctions ======
CREATE VIEW dbo.OA_UserFunctions
AS
SELECT * FROM DB053.bodb_Licensee.dbo.OA_UserFunctions WITH (NOLOCK)
GO
--====== END CREATE VIEW OA_UserFunctions ======

--====== CREATE VIEW OA_UserLicensees ======
CREATE VIEW dbo.OA_UserLicensees
AS
SELECT * FROM DB053.bodb_Licensee.dbo.OA_UserLicensees WITH (NOLOCK)
GO
--====== END CREATE VIEW OA_UserLicensees ======

--====== CREATE VIEW OA_UserLog_Login ======
CREATE VIEW dbo.OA_UserLog_Login
AS
SELECT * FROM DB053.bodb_Licensee.dbo.OA_UserLog_Login WITH (NOLOCK)
GO
--====== END CREATE VIEW OA_UserLog_Login ======

--====== CREATE VIEW OA_UserLog_RunSP ======
CREATE VIEW dbo.OA_UserLog_RunSP
AS
SELECT * FROM DB053.bodb_Licensee.dbo.OA_UserLog_RunSP WITH (NOLOCK)
GO
--====== END CREATE VIEW OA_UserLog_RunSP ======

--====== CREATE VIEW OA_UserResellers ======
CREATE VIEW dbo.OA_UserResellers
AS
SELECT * FROM DB053.bodb_Licensee.dbo.OA_UserResellers WITH (NOLOCK)
GO
--====== END CREATE VIEW OA_UserResellers ======

--====== CREATE VIEW OA_Users ======
CREATE VIEW dbo.OA_Users
AS
SELECT * FROM DB053.bodb_Licensee.dbo.OA_Users WITH (NOLOCK)
GO
--====== END CREATE VIEW OA_Users ======

--====== CREATE VIEW OAS_ChargeInfo ======
CREATE VIEW dbo.OAS_ChargeInfo
AS
SELECT * FROM DB053.bodb_Licensee.dbo.OAS_ChargeInfo WITH (NOLOCK)
GO
--====== END CREATE VIEW OAS_ChargeInfo ======

--====== CREATE VIEW OAS_ChargeInfoSub ======
CREATE VIEW dbo.OAS_ChargeInfoSub
AS
SELECT * FROM DB053.bodb_Licensee.dbo.OAS_ChargeInfoSub WITH (NOLOCK)
GO
--====== END CREATE VIEW OAS_ChargeInfoSub ======

--====== CREATE VIEW OAS_LogAction ======
CREATE VIEW dbo.OAS_LogAction
AS
SELECT * FROM DB053.bodb_Licensee.dbo.OAS_LogAction WITH (NOLOCK)
GO
--====== END CREATE VIEW OAS_LogAction ======

--====== CREATE VIEW OAS_LogActionType ======
CREATE VIEW dbo.OAS_LogActionType
AS
SELECT * FROM DB053.bodb_Licensee.dbo.OAS_LogActionType WITH (NOLOCK)
GO
--====== END CREATE VIEW OAS_LogActionType ======

--====== CREATE VIEW OAS_OnUser ======
CREATE VIEW dbo.OAS_OnUser
AS
SELECT * FROM DB053.bodb_Licensee.dbo.OAS_OnUser WITH (NOLOCK)
GO
--====== END CREATE VIEW OAS_OnUser ======

--====== CREATE VIEW OAS_Party ======
CREATE VIEW dbo.OAS_Party
AS
SELECT * FROM DB053.bodb_Licensee.dbo.OAS_Party WITH (NOLOCK)
GO
--====== END CREATE VIEW OAS_Party ======

--====== CREATE VIEW OAS_PartyDetail ======
CREATE VIEW dbo.OAS_PartyDetail
AS
SELECT * FROM DB053.bodb_Licensee.dbo.OAS_PartyDetail WITH (NOLOCK)
GO
--====== END CREATE VIEW OAS_PartyDetail ======

--====== CREATE VIEW OAS_UserLog_Login ======
CREATE VIEW dbo.OAS_UserLog_Login
AS
SELECT * FROM DB053.bodb_Licensee.dbo.OAS_UserLog_Login WITH (NOLOCK)
GO
--====== END CREATE VIEW OAS_UserLog_Login ======

--====== CREATE VIEW OAS_UserLog_RunSP ======
CREATE VIEW dbo.OAS_UserLog_RunSP
AS
SELECT * FROM DB053.bodb_Licensee.dbo.OAS_UserLog_RunSP WITH (NOLOCK)
GO
--====== END CREATE VIEW OAS_UserLog_RunSP ======

--====== CREATE VIEW OAS_Users ======
CREATE VIEW dbo.OAS_Users
AS
SELECT * FROM DB053.bodb_Licensee.dbo.OAS_Users WITH (NOLOCK)
GO
--====== END CREATE VIEW OAS_Users ======

--====== CREATE VIEW On_User ======
CREATE VIEW dbo.On_User
AS
SELECT * FROM DB053.bodb_Licensee.dbo.On_User WITH (NOLOCK)
GO
--====== END CREATE VIEW On_User ======

--====== CREATE VIEW Party ======
CREATE VIEW dbo.Party
AS
SELECT * FROM DB053.bodb_Licensee.dbo.Party WITH (NOLOCK)
GO
--====== END CREATE VIEW Party ======

--====== CREATE VIEW Product3rd ======
CREATE VIEW dbo.Product3rd
AS
SELECT * FROM DB053.bodb_Licensee.dbo.Product3rd WITH (NOLOCK)
GO
--====== END CREATE VIEW Product3rd ======

--====== CREATE VIEW ResellerProductCharge ======
CREATE VIEW dbo.ResellerProductCharge
AS
SELECT * FROM DB053.bodb_Licensee.dbo.ResellerProductCharge WITH (NOLOCK)
GO
--====== END CREATE VIEW ResellerProductCharge ======

--====== CREATE VIEW ResellerProductChargeByDateRange ======
CREATE VIEW dbo.ResellerProductChargeByDateRange
AS
SELECT * FROM DB053.bodb_Licensee.dbo.ResellerProductChargeByDateRange WITH (NOLOCK)
GO
--====== END CREATE VIEW ResellerProductChargeByDateRange ======

--====== CREATE VIEW Resellers ======
CREATE VIEW dbo.Resellers
AS
SELECT * FROM DB053.bodb_Licensee.dbo.Resellers WITH (NOLOCK)
GO
--====== END CREATE VIEW Resellers ======

--====== CREATE VIEW ResellerTransactionRate ======
CREATE VIEW dbo.ResellerTransactionRate
AS
SELECT * FROM DB053.bodb_Licensee.dbo.ResellerTransactionRate WITH (NOLOCK)
GO
--====== END CREATE VIEW ResellerTransactionRate ======

--====== CREATE VIEW Sport_Bettype_Reference ======
CREATE VIEW dbo.Sport_Bettype_Reference
AS
SELECT * FROM DB053.bodb_Licensee.dbo.Sport_Bettype_Reference WITH (NOLOCK)
GO
--====== END CREATE VIEW Sport_Bettype_Reference ======

--====== CREATE VIEW SystemLicensee ======
CREATE VIEW dbo.SystemLicensee
AS
SELECT * FROM DB053.bodb_Licensee.dbo.SystemLicensee WITH (NOLOCK)
GO
--====== END CREATE VIEW SystemLicensee ======

--====== CREATE VIEW Systems ======
CREATE VIEW dbo.Systems
AS
SELECT * FROM DB053.bodb_Licensee.dbo.Systems WITH (NOLOCK)
GO
--====== END CREATE VIEW Systems ======

--====== CREATE VIEW Users ======
CREATE VIEW dbo.Users
AS
SELECT * FROM DB053.bodb_Licensee.dbo.Users WITH (NOLOCK)
GO
--====== END CREATE VIEW Users ======

