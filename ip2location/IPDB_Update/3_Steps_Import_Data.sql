USE IPDB;

go

--truncate table #RowCount

--truncate table IPTable_Mini

--/*
-- [ 0 ] get current data count for comparison
PRINT '=== Get RowCount ==='
CREATE TABLE #RowCount (TableName varchar(50), RowCnt int)
INSERT INTO #RowCount SELECT 'IPTable'			, COUNT(*) FROM dbo.IPTable with (NOLOCK)
INSERT INTO #RowCount SELECT 'IPTable_Mini'		, COUNT(*) FROM dbo.IPTable_Mini WITH (NOLOCK)
INSERT INTO #RowCount SELECT 'IPTable_Denied'	, COUNT(*) FROM dbo.IPTable_Denied WITH (NOLOCK)
INSERT INTO #RowCount SELECT 'IPv6_DB1'			, COUNT(*) FROM dbo.TEMP_IPv6_DB1 WITH (NOLOCK)
INSERT INTO #RowCount SELECT 'IPv6_DB3'			, COUNT(*) FROM dbo.TEMP_IPv6_DB3 WITH (NOLOCK)
INSERT INTO #RowCount SELECT 'KeyMap_IPv6_DB1'  , COUNT(*) FROM dbo.TEMP_KeyMap_IPv6_DB1 WITH (NOLOCK)
INSERT INTO #RowCount SELECT 'KeyMap_IPv6_DB3'  , COUNT(*) FROM dbo.TEMP_KeyMap_IPv6_DB3 WITH (NOLOCK)


select * from #RowCount 


-- [ 1 ] Prepare Table which is part of data processing

TRUNCATE TABLE [dbo].[IPTable]
ALTER INDEX [IX_CountrySHORT] ON [dbo].[IPTable] DISABLE
ALTER INDEX [IX_ipFROM_ipTO]  ON [dbo].[IPTable] DISABLE
GO
TRUNCATE TABLE [dbo].[Staging_IPv6_DB1]
TRUNCATE TABLE [dbo].[Staging_IPv6_DB3]

TRUNCATE TABLE [dbo].[TEMP_IPv6_DB1]
TRUNCATE TABLE [dbo].[TEMP_IPv6_DB3]
TRUNCATE TABLE [dbo].[TEMP_KeyMap_IPv6_DB1]
TRUNCATE TABLE [dbo].[TEMP_KeyMap_IPv6_DB3]
GO

-- [ 2 ] Import data which download from IPDB

PRINT '=== Prepare Country table for the first time if need ==='

truncate table Country

BULK INSERT [dbo].Country
    FROM 'D:\_000_Nexcel\IPDB_Monthly\_ip2loc_extract_files\DB3-IP-COUNTRY-REGION-CITY.CSV.ZIP\IP2LOCATION-COUNTRY.CSV'
    WITH
    ( FIRSTROW = 2,
		--FIELDTERMINATOR='","',
      --ROWTERMINATOR = '\n',
	FORMATFILE = 'D:\_000_Nexcel\IPDB_Monthly\_bcp_format_files\ipdb_country.FMT' , BATCHSIZE = 100000 
	)
	
--update to remove china in tw name
select * from Country where CountryCode = 'TW'
UPDATE Country SET CountryName = 'Taiwan' WHERE CountryCode = 'TW'


select * 
from Country

GO


select count(1) 
from IPTable i with(nolock)


PRINT '=== perform BULK INSERT ===' --40s local

BULK INSERT [dbo].[IPTable]
    FROM 'D:\_000_Nexcel\IPDB_Monthly\_ip2loc_extract_files\DB3-IP-COUNTRY-REGION-CITY.CSV.ZIP\IP-COUNTRY-REGION-CITY.CSV'
    WITH
    ( FORMATFILE = 'D:\_000_Nexcel\IPDB_Monthly\_bcp_format_files\IPv4-DB3.FMT' , BATCHSIZE = 100000 )

GO


select top 10 * 
from IPTable i with(nolock)

go


select count(1) from Staging_IPv6_DB1 s with(nolock)

--> local 3s
BULK INSERT [dbo].[Staging_IPv6_DB1]
    FROM                'D:\_000_Nexcel\IPDB_Monthly\_ip2loc_extract_files\DB1-IPV6-COUNTRY.CSV.ZIP\IPV6-COUNTRY.CSV'
    WITH ( FORMATFILE = 'D:\_000_Nexcel\IPDB_Monthly\_bcp_format_files\IPv6-DB1.FMT'    , BATCHSIZE = 100000)
GO


select top 10 * from Staging_IPv6_DB1 s with(nolock)

go


select count(1) from [Staging_IPv6_DB3] s with(nolock)
-->local 1min 44s

BULK INSERT [dbo].[Staging_IPv6_DB3]
    FROM                'D:\_000_Nexcel\IPDB_Monthly\_ip2loc_extract_files\DB3-IPV6-COUNTRY-REGION-CITY.CSV.ZIP\IPV6-COUNTRY-REGION-CITY.CSV'
    WITH ( FORMATFILE = 'D:\_000_Nexcel\IPDB_Monthly\_bcp_format_files\IPv6-DB3.FMT'    , BATCHSIZE = 100000 )
GO


select top 10 * from [Staging_IPv6_DB3] s with(nolock)

go


-- [ 3 ] Prepare IPKey for IPv4   , current code assume data having 12m row max

select top 10 * 
from IPTable i with(nolock)

select  count(1)
from IPTable i with(nolock)

PRINT '=== update ipKey value for IPv4 ==='
--> local 1min 39s
UPDATE TOP (1000000) IPTABLE 
SET ipkeyfrom = CAST((ipfrom/16777216) as tinyint), ipkeyto = CAST((ipto/16777216) as tinyint)
WHERE ipKeyFrom = 0 AND ipKeyTO = 0
GO 12


-- [ 4 ] Modify Data which been special mark/request as specific Country
PRINT '=== manual Country Modify ==='

-- 20131225@Vivi: need manual update [61.14.176.18] this ip is JP ip 
--SELECT dbo.ipconvert('61.14.176.18') 
--select dbo.[IntegerToIPAddress](1024372754)

UPDATE iptable set countrySHORT='JP',countryLong='JAPAN', IsModified=1 WHERE ipKeyFrom=61 and ipKeyTO=61 and ipFrom=1024372736 and ipTo=1024372879
--SELECT * FROM IPTable WITH (nolock) WHERE 1024372754 between ipFrom and ipTo

-- 20180419 : for KH customer, Master claim they really login from KH. 
---> updated 20240108, data is correct, no need to update
--SELECT dbo.ipconvert('111.90.190.50') 
UPDATE iptable set countrySHORT='KH',countryLong='Cambodia', IsModified=1 WHERE ipKeyFrom=111 and ipKeyTO=111 and ipFrom=1868217856 and ipTo=1868218111
--SELECT * FROM IPTable WITH (nolock) WHERE 1868217906 between ipFrom and ipTo
--SELECT * FROM IPTable WITH (nolock) WHERE ipKeyFrom=111 and ipKeyTO=111 and ipFrom=1868217856 and ipTo=1868218111

-- 20210503 : for ID customer, IP2Location return not matched with ipinfo.io --> 64.64.121.0/24 
---> updated 20240108, data is correct, no need to update
--SELECT dbo.ipconvert('64.64.121.0'), dbo.ipconvert('64.64.121.255')
UPDATE IPTable SET countrySHORT='ID', countryLONG='Indonesia', IsModified=1  WHERE ipFrom >= 1077967104 and ipTo <= 1077967359
--SELECT * FROM IPTable WITH (nolock)                                          WHERE ipFrom >= 1077967104 and ipTo <= 1077967359

-- 2022 : KH at this range had return as US, so got request to manual override.
--SELECT * FROM IPTable WITH (nolock) WHERE ipKeyFrom=103 and ipFrom=1736952832 and ipTo=1736953343
--SELECT * FROM IPTable WITH (nolock) WHERE ipKeyFrom=103 and ipFrom=1736953600 and ipTo=1736953855
---> updated 20240108, no data , no need to update
UPDATE iptable set countrySHORT='KH',countryLong='Cambodia', IsModified=1 WHERE ipKeyFrom=103 and ipFrom=1736952832 and ipTo=1736953343
UPDATE iptable set countrySHORT='KH',countryLong='Cambodia', IsModified=1 WHERE ipKeyFrom=103 and ipFrom=1736953600 and ipTo=1736953855
GO

-- [ 5 ] for row which ipKeyFrom not equal to ipKeyTo, break it. so, we don't required BETWEEN to check for ipKey, just compare with ipKeyFrom
PRINT '=== eliminate range for ipKey ==='


---------================
-- 20240618: manual update those ips range to VN: 103.199.41.182, 103.199.41.97 , 103.199.41.251, 103.199.41.159
-- SELECT dbo.ipconvert('103.199.41.182') 
-- select * from IPTable i with(nolock) WHERE ipFrom = 1741105408 AND ipTo = 1741105663
UPDATE IPTable SET countrySHORT='VN', countryLong='Viet Nam', IsModified=1, ipREGION = 'Ho Chi Minh', ipCITY = 'Ho Chi Minh City' 
WHERE ipKeyFrom = 103 AND ipKeyTO = 103 AND ipFrom = 1741105408 AND ipTo = 1741105663



-- make a unique ipKeyFROM value
CREATE TABLE #Number (number int PRIMARY KEY)
INSERT INTO #Number VALUES (0)

INSERT INTO #Number
SELECT TOP (255) n = CONVERT(INT, ROW_NUMBER() OVER (ORDER BY s1.[object_id]))
FROM sys.all_objects AS s1 CROSS JOIN sys.all_objects AS s2
OPTION (MAXDOP 1);

SELECT * INTO #temp FROM IPTable WITH (NOLOCK) 
WHERE ipkeyfrom <> ipkeyto

DELETE FROM IPTable 
WHERE ipkeyfrom <> ipkeyto

INSERT INTO IPTable (ipKeyFROM, ipKeyTO, ipFROM, ipTO, countrySHORT, countryLONG, ipREGION, ipCITY, IsModified, IsException)
SELECT 
	number as ipKeyFrom, number as ipKeyTo,
	CASE WHEN number = ipKeyFrom THEN ipFROM ELSE CONVERT(bigint, CONVERT(binary(4), CONVERT(varchar(2), CONVERT(binary(1), number), 2) + '000000',2)) END as ipFROM,
	CASE WHEN number = ipKeyTO   THEN ipTO   ELSE CONVERT(bigint, CONVERT(binary(4), CONVERT(varchar(2), CONVERT(binary(1), number), 2) + 'FFFFFF',2)) END as ipTO,
	countrySHORT, countryLONG, ipREGION, ipCITY,
	IsModified, IsException
FROM #Number n 
	INNER JOIN #temp AS i ON n.number BETWEEN i.ipKeyFROM AND i.ipKeyTO

DROP TABLE #Number
DROP TABLE #temp
GO

-- [ 6 ] 2023 : remove word which refer to China from TW
PRINT '=== set Taiwan as just ''Taiwan'' ==='

select top 10 * from  IPTable where countrySHORT = 'TW'
select top 10 * from  IPTable_Mini where countrySHORT = 'TW'
select top 10 * from  Country where CountryCode = 'TW'
select top 10 * from  IPTable_Denied where countrySHORT = 'TW'

UPDATE IPTable SET countryLONG = 'Taiwan' WHERE countrySHORT = 'TW'
--UPDATE IPTable_Mini SET countryLONG = 'Taiwan' WHERE countrySHORT = 'TW'
--UPDATE Country SET CountryName = 'TAIWAN' WHERE CountryCode = 'TW'
--UPDATE IPTable_Denied SET countryLONG = 'Taiwan' WHERE countrySHORT = 'TW'

GO

-- [ 7 ] MergeIP : create IPTable_Mini data from IPTable, rebuild Index prior to process for speed up
--> local index ->  22s
--> local mergeip -> 3min 19s

ALTER INDEX [CIX_ipKey]       ON [dbo].[IPTable] REBUILD PARTITION = ALL WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = ON, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
ALTER INDEX [IX_CountrySHORT] ON [dbo].[IPTable] REBUILD PARTITION = ALL WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = ON, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
ALTER INDEX [IX_ipFROM_ipTO]  ON [dbo].[IPTable] REBUILD PARTITION = ALL WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = ON, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO

PRINT '=== generate IPTable_Mini ==='
EXEC dbo.MergeIP
GO


select top 10 * from  IPTable_Mini where countrySHORT = 'TW'
select count(1) from  IPTable_Mini i with(nolock)

GO

-- [ 8 ] create IPTable_Denited data base on given country list.
ALTER INDEX [IX_ipTable_mini] ON [dbo].[ipTable_mini] REBUILD PARTITION = ALL WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = ON, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
ALTER INDEX [IX_CountrySHORT] ON [dbo].[ipTable_mini] REBUILD PARTITION = ALL WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = ON, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO


PRINT '=== generate IPTable_Denied ==='
DELETE FROM IPTable_Denied
INSERT INTO IPTable_Denied
SELECT ipKey ipKeyFROM, ipKey ipKeyTO, ipFROM, ipTO, countrySHORT, countryLONG, '' ipREGION, '' ipCITY, 0 IsModified, 0 IsException
FROM
	dbo.ipTable_mini i WITH (NOLOCK)
	--INNER JOIN dbo.Country c WITH (NOLOCK) ON i.countrySHORT = c.CountryCode
WHERE
	countrySHORT in ('HK','PH','TW','US','CH','VN','AU','GB','SG')
GO


select count(1) from  IPTable_Denied i with(nolock)
select top 10 * from  IPTable_Denied where countrySHORT = 'TW'

GO

select count(1) from Staging_IPv6_DB1 s1 with(nolock)
select count(1) from Staging_IPv6_DB3 s1 with(nolock)

-- [ 9 ] process IPv6 data, using Trigger in each Staging table, assume 1.2m from DB1, and 12m from DB3
--local ->  9min 06s
PRINT '=== IPv6 transform ==='
DELETE TOP ( 100000)  FROM Staging_IPv6_DB1
GO 12
DELETE TOP (1000000) FROM Staging_IPv6_DB3
GO 8
DELETE TOP ( 300000)  FROM Staging_IPv6_DB3
GO 20



-- [ 10 ] get ipKey for IPv6
EXEC dbo.Prepare_KeyMap
GO



-- [ 11 ] rebuild all
--> local 26s
Exec sp_msforeachtable 'ALTER INDEX ALL ON ? REBUILD WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = ON, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)' 
GO



-- [ 12 ] check data if everything looking good. (not have new country, not have data left in Staging table)
PRINT '=== Verify ==='

;WITH A AS (SELECT COUNT(*) cnt FROM dbo.IPTable WITH (NOLOCK)  WHERE ipKeyFrom = 0) 
, B AS (SELECT COUNT(*) cnt FROM dbo.IPTable WITH (NOLOCK)      WHERE ipKeyFrom <> ipKeyTO)
, C AS (SELECT COUNT(*) cnt FROM dbo.ipTable WITH (NOLOCK)      WHERE countrySHORT NOT IN (SELECT CountryCode FROM dbo.Country) AND countryLONG <> '-')
, D AS (SELECT COUNT(*) cnt FROM dbo.ipTable_mini WITH (NOLOCK) WHERE countrySHORT NOT IN (SELECT CountryCode FROM dbo.Country) AND countryLONG <> '-')
, E AS (SELECT COUNT(*) cnt FROM dbo.Staging_IPv6_DB1 WITH (NOLOCK))
, F AS (SELECT COUNT(*) cnt FROM dbo.Staging_IPv6_DB3 WITH (NOLOCK))
          SELECT CASE WHEN cnt = 1 THEN 'OK' ELSE 'Please check #A' END Result FROM A
UNION ALL SELECT CASE WHEN cnt = 0 THEN 'OK' ELSE 'Please check #B' END Result FROM B
UNION ALL SELECT CASE WHEN cnt = 0 THEN 'OK' ELSE 'Please check #C' END Result FROM C
UNION ALL SELECT CASE WHEN cnt = 0 THEN 'OK' ELSE 'Please check #D' END Result FROM D
UNION ALL SELECT CASE WHEN cnt = 0 THEN 'OK' ELSE 'Please check #E' END Result FROM E
UNION ALL SELECT CASE WHEN cnt = 0 THEN 'OK' ELSE 'Please check #F' END Result FROM F

-- with correct new data, RowCount is expected to change.
-- if count not change, possibly new version not release yet.
;WITH NewCount AS (
      SELECT 'IPTable' TableName , COUNT(*) RowCnt FROM dbo.IPTable with (NOLOCK)
UNION SELECT 'IPTable_Mini'      , COUNT(*) FROM dbo.IPTable_Mini WITH (NOLOCK)
UNION SELECT 'IPTable_Denied'    , COUNT(*) FROM dbo.IPTable_Denied WITH (NOLOCK)

UNION SELECT 'IPv6_DB1'          , COUNT(*) FROM dbo.TEMP_IPv6_DB1 WITH (NOLOCK)
UNION SELECT 'IPv6_DB3'          , COUNT(*) FROM dbo.TEMP_IPv6_DB3 WITH (NOLOCK)

UNION SELECT 'KeyMap_IPv6_DB1'   , COUNT(*) FROM dbo.TEMP_KeyMap_IPv6_DB1 WITH (NOLOCK)
UNION SELECT 'KeyMap_IPv6_DB3'   , COUNT(*) FROM dbo.TEMP_KeyMap_IPv6_DB3 WITH (NOLOCK)
)
SELECT rc.TableName, rc.RowCnt as CountBefore, NewCount.RowCnt as CountAfter
FROM #RowCount rc INNER JOIN NewCount ON rc.TableName = NewCount.TableName

DROP TABLE #RowCount

GO
