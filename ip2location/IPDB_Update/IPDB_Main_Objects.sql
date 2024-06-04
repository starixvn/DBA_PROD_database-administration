

drop table country


USE [IPDB]
GO

/****** Object:  Table [dbo].[Country]    Script Date: 1/3/2024 11:02:51 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[Country](
	[CountryCode] [varchar](2) NOT NULL,
	[CountryName] [nvarchar](100) NOT NULL,
 CONSTRAINT [PK_Country] PRIMARY KEY CLUSTERED 
(
	[CountryCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO




USE [IPDB]
--GO


/****** Object:  UserDefinedFunction [dbo].[IP_DivideBy65536]    Script Date: 1/3/2024 1:47:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[IP_DivideBy65536]
(
	@input varchar(50)
)
RETURNS varchar(50)
BEGIN
	Declare @maxLen int
	Declare @ipos int
	Declare @result varchar(50)
	Declare @CurrentValue int
	SET @maxLen = LEN(@input)
	SET @ipos   = 1
	SET @result = ''
	SET @CurrentValue = CONVERT(int, LEFT(@input,1))

	WHILE @ipos <= @maxLen
	BEGIN
		If @CurrentValue >= 65536
			SELECT @result = @result + CONVERT(char(1), @CurrentValue/65536 ) -- divide result
				 , @CurrentValue = @CurrentValue % 65536 -- left over
		Else 
		BEGIN
			SET @ipos = @ipos + 1

			IF @ipos > @maxLen -- finished compute, convert leftover to HEX and append to result
				SET @result = @result + CONVERT(char(4),CONVERT(binary(2), CONVERT(int,@CurrentValue)),2)
			Else
			BEGIN -- get next value, add for next round calculation
				SET @CurrentValue = (@CurrentValue * 10) + CONVERT(tinyint, SUBSTRING(@input, @ipos, 1))
				IF @CurrentValue < 65536 AND @result <> '' SET @result = @result + '0'
			END
		END
	END

	RETURN @result
END
GO
/****** Object:  UserDefinedFunction [dbo].[IP_StringNumberToDoubleByte]    Script Date: 1/3/2024 1:47:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE FUNCTION [dbo].[IP_StringNumberToDoubleByte]
(
	@input varchar(50)
)
RETURNS varchar(50)
BEGIN
	Declare @result varchar(50)
	Declare @HexResult varchar(50)
	SET @HexResult = ''

	WHILE @input <> '0' AND @input <> ''
	BEGIN
		SET @result = dbo.IP_DivideBy65536(@input)
		SELECT @HexResult = RIGHT(@result, 4) + @HexResult
			 , @input = LEFT(@result, LEN(@result) - 4)
	END

	RETURN @HexResult
END
GO
/****** Object:  UserDefinedFunction [dbo].[ipconvert]    Script Date: 1/3/2024 1:47:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [dbo].[ipconvert] (@string nvarchar(20))
	RETURNS bigint
AS
BEGIN
	Declare @ip bigint
	Declare @start int, @word bigint, @charindex int, @i int

	SET @string = @string+'.'
	SET @i=1
	SET @start=1
	SET @charindex=charindex( '.', @string, @start)

	while (@charindex <> 0)
	begin
		set @word= substring( @string, @start, @charindex - @start)
		set @start= @charindex +1
		set @charindex= charindex( '.', @string, @start)
		-- insert into @res  values ( @start, @i, @word)
		set @ip = case
			when (@i=1) then 16777216 * @word
			when (@i=2) then 65536 * @word + @ip
			when (@i=3) then 256 * @word + @ip
			when (@i=4) then @word + @ip
			end 
		set @i=@i+1
	end

	return @ip 
END



GO
/****** Object:  UserDefinedFunction [dbo].[IPv6_StringToHex]    Script Date: 1/3/2024 1:47:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE FUNCTION [dbo].[IPv6_StringToHex]
(
	@input varchar(50)
	--,@method tinyint
)
RETURNS binary(16)
AS
BEGIN
	DECLARE @result varchar(128)
	SET @input = LTRIM(RTRIM(@input))

-- 20201130 : test & create code to get data by doing base 2 and base 16
-- 20240102 : test & modify code to divide by 256, to get one byte data directly
-- 20240102 : test & modify code to divide by 65536, to get two bytes data directly
/*
	IF @method = 1
	BEGIN
		SET @result = dbo.IP_StringNumberToBase2(@input)
		SET @result = REPLACE(SPACE(128-LEN(@result)),' ','0') + @result

		SET @result = 
			dbo.IP_BitToHex(SUBSTRING(@result,  1,4)) +
			dbo.IP_BitToHex(SUBSTRING(@result,  5,4)) +
			dbo.IP_BitToHex(SUBSTRING(@result,  9,4)) +
			dbo.IP_BitToHex(SUBSTRING(@result, 13,4)) +
			dbo.IP_BitToHex(SUBSTRING(@result, 17,4)) +
			dbo.IP_BitToHex(SUBSTRING(@result, 21,4)) +
			dbo.IP_BitToHex(SUBSTRING(@result, 25,4)) +
			dbo.IP_BitToHex(SUBSTRING(@result, 29,4)) +
			dbo.IP_BitToHex(SUBSTRING(@result, 33,4)) +
			dbo.IP_BitToHex(SUBSTRING(@result, 37,4)) +
			dbo.IP_BitToHex(SUBSTRING(@result, 41,4)) +
			dbo.IP_BitToHex(SUBSTRING(@result, 45,4)) +
			dbo.IP_BitToHex(SUBSTRING(@result, 49,4)) +
			dbo.IP_BitToHex(SUBSTRING(@result, 53,4)) +
			dbo.IP_BitToHex(SUBSTRING(@result, 57,4)) +
			dbo.IP_BitToHex(SUBSTRING(@result, 61,4)) +
			dbo.IP_BitToHex(SUBSTRING(@result, 65,4)) +
			dbo.IP_BitToHex(SUBSTRING(@result, 69,4)) +
			dbo.IP_BitToHex(SUBSTRING(@result, 73,4)) +
			dbo.IP_BitToHex(SUBSTRING(@result, 77,4)) +
			dbo.IP_BitToHex(SUBSTRING(@result, 81,4)) +
			dbo.IP_BitToHex(SUBSTRING(@result, 85,4)) +
			dbo.IP_BitToHex(SUBSTRING(@result, 89,4)) +
			dbo.IP_BitToHex(SUBSTRING(@result, 93,4)) +
			dbo.IP_BitToHex(SUBSTRING(@result, 97,4)) +
			dbo.IP_BitToHex(SUBSTRING(@result,101,4)) +
			dbo.IP_BitToHex(SUBSTRING(@result,105,4)) +
			dbo.IP_BitToHex(SUBSTRING(@result,109,4)) +
			dbo.IP_BitToHex(SUBSTRING(@result,113,4)) +
			dbo.IP_BitToHex(SUBSTRING(@result,117,4)) +
			dbo.IP_BitToHex(SUBSTRING(@result,121,4)) +
			dbo.IP_BitToHex(SUBSTRING(@result,125,4))

	END

	IF @method = 2
	BEGIN
		SET @result = dbo.IP_StringNumberToBase16(@input)
		SET @result = REPLACE(SPACE(32-LEN(@result)),' ','0') + @result
	END

	IF @method = 3
	BEGIN
		SET @result = dbo.IP_StringNumberToByte(@input)
		SET @result = REPLACE(SPACE(32-LEN(@result)),' ','0') + @result
	END

	IF @method = 4
*/
	BEGIN
		SET @result = dbo.IP_StringNumberToDoubleByte(@input)
		SET @result = REPLACE(SPACE(32-LEN(@result)),' ','0') + @result
	END

	RETURN CONVERT(binary(16), @result, 2)
END
GO













--################################################################################################
--################################################################################################
--################################################################################################


/****** Object:  Table [dbo].[Country]    Script Date: 1/3/2024 1:47:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Country](
	[countryLONG] [varchar](64) NULL,
	[countryCode] [varchar](2) NOT NULL,
	[countrySHORT3] [varchar](3) NULL,
	[countryCode3] [varchar](3) NULL,
PRIMARY KEY CLUSTERED 
(
	[countryCode] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[IPTable]    Script Date: 1/3/2024 1:47:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[IPTable](
	[ipKeyFROM] [tinyint] NOT NULL,
	[ipKeyTO] [tinyint] NOT NULL,
	[ipFROM] [bigint] NOT NULL,
	[ipTO] [bigint] NOT NULL,
	[countrySHORT] [varchar](2) NOT NULL,
	[countryLONG] [varchar](64) NULL,
	[ipREGION] [varchar](128) NULL,
	[ipCITY] [varchar](128) NULL,
	[IsModified] [bit] NOT NULL,
	[IsException] [bit] NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Index [CIX_ipKey]    Script Date: 1/3/2024 1:47:18 PM ******/
CREATE CLUSTERED INDEX [CIX_ipKey] ON [dbo].[IPTable]
(
	[ipKeyFROM] ASC,
	[ipKeyTO] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[IPTable_Denied]    Script Date: 1/3/2024 1:47:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[IPTable_Denied](
	[ipKeyFROM] [tinyint] NOT NULL,
	[ipKeyTO] [tinyint] NOT NULL,
	[ipFROM] [bigint] NOT NULL,
	[ipTO] [bigint] NOT NULL,
	[countrySHORT] [varchar](2) NOT NULL,
	[countryLONG] [varchar](64) NULL,
	[ipREGION] [varchar](128) NULL,
	[ipCITY] [varchar](128) NULL,
	[IsModified] [bit] NOT NULL,
	[IsException] [bit] NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Index [IX_IPTable_20071101]    Script Date: 1/3/2024 1:47:18 PM ******/
CREATE CLUSTERED INDEX [IX_IPTable_20071101] ON [dbo].[IPTable_Denied]
(
	[ipKeyFROM] ASC,
	[ipKeyTO] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[ipTable_mini]    Script Date: 1/3/2024 1:47:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[ipTable_mini](
	[ipKey] [tinyint] NOT NULL,
	[ipFrom] [bigint] NOT NULL,
	[ipTo] [bigint] NOT NULL,
	[countrySHORT] [varchar](2) NOT NULL,
	[countryLONG] [varchar](64) NOT NULL
) ON [PRIMARY]
GO
/****** Object:  Index [IX_ipTable_mini]    Script Date: 1/3/2024 1:47:18 PM ******/
CREATE CLUSTERED INDEX [IX_ipTable_mini] ON [dbo].[ipTable_mini]
(
	[ipKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Staging_IPv6_DB1]    Script Date: 1/3/2024 1:47:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Staging_IPv6_DB1](
	[ip_from] [char](39) NOT NULL,
	[ip_to] [char](39) NOT NULL,
	[country_code] [nvarchar](2) NOT NULL,
	[country_name] [nvarchar](64) NOT NULL,
 CONSTRAINT [ip_from_v6db1] UNIQUE CLUSTERED 
(
	[ip_from] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Staging_IPv6_DB3]    Script Date: 1/3/2024 1:47:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Staging_IPv6_DB3](
	[ip_from] [char](39) NOT NULL,
	[ip_to] [char](39) NOT NULL,
	[country_code] [nvarchar](2) NOT NULL,
	[country_name] [nvarchar](64) NOT NULL,
	[region_name] [nvarchar](128) NOT NULL,
	[city_name] [nvarchar](128) NOT NULL,
 CONSTRAINT [ip_from_v6db3] UNIQUE CLUSTERED 
(
	[ip_from] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[TEMP_IPv6_DB1]    Script Date: 1/3/2024 1:47:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TEMP_IPv6_DB1](
	[ipKey] [binary](2) NOT NULL,
	[ipFROM] [binary](16) NOT NULL,
	[ipTO] [binary](16) NOT NULL,
	[country_code] [varchar](2) NOT NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [CIX_ipKey]    Script Date: 1/3/2024 1:47:18 PM ******/
CREATE CLUSTERED INDEX [CIX_ipKey] ON [dbo].[TEMP_IPv6_DB1]
(
	[ipKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[TEMP_IPv6_DB3]    Script Date: 1/3/2024 1:47:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TEMP_IPv6_DB3](
	[ipKey] [binary](2) NOT NULL,
	[ipFROM] [binary](16) NOT NULL,
	[ipTO] [binary](16) NOT NULL,
	[country_code] [varchar](2) NOT NULL,
	[region_name] [varchar](128) NOT NULL,
	[city_name] [varchar](128) NOT NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [CIX_ipKey]    Script Date: 1/3/2024 1:47:18 PM ******/
CREATE CLUSTERED INDEX [CIX_ipKey] ON [dbo].[TEMP_IPv6_DB3]
(
	[ipKey] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[TEMP_KeyMap_IPv6_DB1]    Script Date: 1/3/2024 1:47:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TEMP_KeyMap_IPv6_DB1](
	[KeyValue] [binary](2) NOT NULL,
	[ipKey] [binary](2) NOT NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [CIX_aux]    Script Date: 1/3/2024 1:47:18 PM ******/
CREATE CLUSTERED INDEX [CIX_aux] ON [dbo].[TEMP_KeyMap_IPv6_DB1]
(
	[KeyValue] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[TEMP_KeyMap_IPv6_DB3]    Script Date: 1/3/2024 1:47:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[TEMP_KeyMap_IPv6_DB3](
	[KeyValue] [binary](2) NOT NULL,
	[ipKey] [binary](2) NOT NULL
) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [CIX_aux]    Script Date: 1/3/2024 1:47:18 PM ******/
CREATE CLUSTERED INDEX [CIX_aux] ON [dbo].[TEMP_KeyMap_IPv6_DB3]
(
	[KeyValue] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_CountrySHORT]    Script Date: 1/3/2024 1:47:18 PM ******/
CREATE NONCLUSTERED INDEX [IX_CountrySHORT] ON [dbo].[IPTable]
(
	[countrySHORT] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
/****** Object:  Index [IX_ipFROM_ipTO]    Script Date: 1/3/2024 1:47:18 PM ******/
CREATE NONCLUSTERED INDEX [IX_ipFROM_ipTO] ON [dbo].[IPTable]
(
	[ipFROM] ASC,
	[ipTO] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [IX_CountrySHORT]    Script Date: 1/3/2024 1:47:18 PM ******/
CREATE NONCLUSTERED INDEX [IX_CountrySHORT] ON [dbo].[ipTable_mini]
(
	[countrySHORT] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
SET ANSI_PADDING ON
GO
/****** Object:  Index [ix_country_code]    Script Date: 1/3/2024 1:47:18 PM ******/
CREATE NONCLUSTERED INDEX [ix_country_code] ON [dbo].[Staging_IPv6_DB3]
(
	[country_code] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
GO
ALTER TABLE [dbo].[IPTable] ADD  CONSTRAINT [DF_IP_20071101_ipKeyFROM]  DEFAULT ((0)) FOR [ipKeyFROM]
GO
ALTER TABLE [dbo].[IPTable] ADD  CONSTRAINT [DF_IP_20071101_ipKeyTO]  DEFAULT ((0)) FOR [ipKeyTO]
GO
ALTER TABLE [dbo].[IPTable] ADD  CONSTRAINT [DF_IP_20071101_Modified]  DEFAULT ((0)) FOR [IsModified]
GO
ALTER TABLE [dbo].[IPTable] ADD  CONSTRAINT [DF_IP_20071101_IsException]  DEFAULT ((0)) FOR [IsException]
GO
/****** Object:  StoredProcedure [dbo].[Prepare_KeyMap]    Script Date: 1/3/2024 1:52:57 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO























--###################################################################################################
--###################################################################################################
--###################################################################################################


CREATE PROCEDURE [dbo].[Prepare_KeyMap]
AS

CREATE TABLE #Number (number int PRIMARY KEY)
/*
-- IPv4
INSERT INTO #Number VALUES (0)
INSERT INTO #Number
SELECT TOP (255) n = CONVERT(tinyint, ROW_NUMBER() OVER (ORDER BY s1.[object_id]))
FROM sys.all_objects AS s1 CROSS JOIN sys.all_objects AS s2
OPTION (MAXDOP 1);

DELETE FROM TEMP_KeyMap_IPv4_DB3
;WITH CTE AS (
select 
	DISTINCT
	ipKeyFROM ipF,
	ipKeyTO   ipT
from IPTable
)
INSERT INTO TEMP_KeyMap_IPv4_DB3
SELECT DISTINCT N.Number KeyValue, A.ipF AS ipKey
FROM CTE AS A --(SELECT ROW_NUMBER() OVER (ORDER BY ipF, ipT) rowno, * FROM CTE) A 
INNER JOIN #number N ON N.number BETWEEN A.ipF AND A.ipT
ORDER BY 1,2

-- clean up
DELETE FROM #Number
*/
-- IPv6
INSERT INTO #Number VALUES (0)
INSERT INTO #Number
SELECT TOP (65535) n = CONVERT(INT, ROW_NUMBER() OVER (ORDER BY s1.[object_id]))
FROM sys.all_objects AS s1 CROSS JOIN sys.all_objects AS s2
OPTION (MAXDOP 1);

DELETE FROM TEMP_KeyMap_IPv6_DB1
;WITH CTE AS (
select 
	DISTINCT
	CONVERT(int, CONVERT(binary(4),'0000' + LEFT(CONVERT(varchar(32), ipFROM, 2), 4),2)) ipF,
	CONVERT(int, CONVERT(binary(4),'0000' + LEFT(CONVERT(varchar(32), ipTO  , 2), 4),2)) ipT
from TEMP_ipv6_db1
)
INSERT INTO TEMP_KeyMap_IPv6_DB1
SELECT DISTINCT CONVERT(binary(2), N.Number) KeyValue, CONVERT(binary(2), A.ipF) AS ipKey
FROM CTE AS A --(SELECT ROW_NUMBER() OVER (ORDER BY ipF, ipT) rowno, * FROM CTE) A 
INNER JOIN #number N ON N.number BETWEEN A.ipF AND A.ipT
ORDER BY 1,2

DELETE FROM TEMP_KeyMap_IPv6_DB3
;WITH CTE AS (
select 
	DISTINCT
	CONVERT(int, CONVERT(binary(4),'0000' + LEFT(CONVERT(varchar(32), ipFROM, 2), 4),2)) ipF,
	CONVERT(int, CONVERT(binary(4),'0000' + LEFT(CONVERT(varchar(32), ipTO  , 2), 4),2)) ipT
from TEMP_ipv6_db3
)
INSERT INTO TEMP_KeyMap_IPv6_DB3
SELECT DISTINCT CONVERT(binary(2), N.Number) KeyValue, CONVERT(binary(2), A.ipF) AS ipKey
FROM CTE AS A --(SELECT ROW_NUMBER() OVER (ORDER BY ipF, ipT) rowno, * FROM CTE) A 
INNER JOIN #number N ON N.number BETWEEN A.ipF AND A.ipT
ORDER BY 1,2

/*
select * from 
ipv6_aux_db1_xtest d1
full outer join ipv6_aux_db3_xtest d2 on
d1.keyvalue = d2.keyvalue and d1.ipkey = d2.ipkey
*/
GO
/****** Object:  StoredProcedure [dbo].[MergeIP]    Script Date: 1/3/2024 1:47:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE [dbo].[MergeIP]
AS

SET NOCOUNT ON
DELETE FROM dbo.ipTable_mini

--SELECT SYSDATETIME()
Declare @pipKeyFrom tinyint, @pipKeyTo tinyint, @pipFrom bigint, @pipTo bigint, @pcountrySHORT varchar(2), @pcountryLONG varchar(64)
Declare @ipKeyFrom tinyint, @ipKeyTo tinyint, @ipFrom bigint, @ipTo bigint, @countrySHORT varchar(2), @countryLONG varchar(64)
Declare @ipKey int, @RangeLow bigint, @RangeHigh bigint, @insertLow bigint, @insertHigh bigint

-- MERGE #1
Declare ipCURSOR CURSOR LOCAL FAST_FORWARD
FOR SELECT ipKeyFrom, ipKeyTO, ipFROM, ipTO, countrySHORT, countryLONG
FROM dbo.ipTable with (nolock)
--WHERE ipKeyFrom <> ipKeyTo
ORDER BY ipFROM

OPEN ipCURSOR
FETCH NEXT FROM ipCURSOR INTO @pipKeyFrom, @pipKeyTo, @pipFrom, @pipTo, @pcountrySHORT, @pcountryLONG

FETCH NEXT FROM ipCURSOR INTO @ipKeyFrom, @ipKeyTo, @ipFrom, @ipTo, @countrySHORT, @countryLONG
WHILE @@FETCH_STATUS = 0
BEGIN
	IF (@pcountrySHORT = @countrySHORT) AND (@pipKeyTo = @ipKeyTo)
	BEGIN
		SET @pipTo = @ipTo
	END
	ELSE
	BEGIN
		IF @pipKeyFrom = @pipKeyTo
			INSERT INTO dbo.ipTable_mini VALUES (@pipKeyFrom, @pipFrom, @pipTo, @pcountrySHORT, @pcountryLONG)
		ELSE
		BEGIN
			SET @ipKey = @pipKeyFrom
			
			WHILE @ipKey <= @pipKeyTo
			BEGIN
				SET @RangeLow  = @ipKey * CAST(POWER(2, 24) as bigint)
				SET @RangeHigh = @RangeLow + CAST(16777215 as bigint) -- (@ipKey + 1) * POWER(2, 24) - 1
				SET @insertLow  = CASE WHEN @pipFrom < @RangeLow  THEN @RangeLow  ELSE @pipFrom END
				SET @insertHigh = CASE WHEN @pipTo   > @RangeHigh THEN @RangeHigh ELSE @pipTo   END
				
				IF (0=1)
				BEGIN
					PRINT 'ipKey : ' + CAST(@pipKeyFrom as nvarchar(20)) + ' - ' + CAST(@pipKeyTo as nvarchar(20)) + ' : ' + CAST(@ipKey as nvarchar(20))
					PRINT '    IP: ' + CAST(@pipFrom as nvarchar(20))  + ' - ' + CAST(@pipTo as nvarchar(20))
					PRINT ' Range: ' + CAST(@RangeLow as nvarchar(20)) + ' - ' + CAST(@RangeHigh as nvarchar(20)) 
					PRINT 'INSERT: ' + CAST(@insertLow as nvarchar(20)) + ' - ' + CAST(@insertHigh as nvarchar(20))
					PRINT ' '
				END
				
				INSERT INTO dbo.ipTable_mini VALUES (@ipKey, @insertLow, @insertHigh, @pcountrySHORT, @pcountryLONG)
				SET @ipKey = @ipKey + 1
			END
		END
		
		SELECT @pipKeyFrom = @ipKeyFrom,
			@pipKeyTo = @ipKeyTo,
			@pipFrom = @ipFrom,
			@pipTo = @ipTo,
			@pcountrySHORT = @countrySHORT,
			@pcountryLONG = @countryLONG
	END

	FETCH NEXT FROM ipCURSOR INTO @ipKeyFrom, @ipKeyTo, @ipFrom, @ipTo, @countrySHORT, @countryLONG
END

PRINT ' ***** LAST RECORD ***** '
--PROCESS LAST RECORD
		IF @pipKeyFrom = @pipKeyTo
			INSERT INTO dbo.ipTable_mini VALUES (@pipKeyFrom, @pipFrom, @pipTo, @pcountrySHORT, @pcountryLONG)
		ELSE
		BEGIN
			SET @ipKey = @pipKeyFrom
			
			WHILE @ipKey <= @pipKeyTo
			BEGIN
				SET @RangeLow  = @ipKey * CAST(POWER(2, 24) as bigint)
				SET @RangeHigh = @RangeLow + CAST(16777215 as bigint) -- (@ipKey + 1) * POWER(2, 24) - 1
				SET @insertLow  = CASE WHEN @pipFrom < @RangeLow  THEN @RangeLow  ELSE @pipFrom END
				SET @insertHigh = CASE WHEN @pipTo   > @RangeHigh THEN @RangeHigh ELSE @pipTo   END
				
				IF (0=1)
				BEGIN
					PRINT 'ipKey : ' + CAST(@pipKeyFrom as nvarchar(20)) + ' - ' + CAST(@pipKeyTo as nvarchar(20)) + ' : ' + CAST(@ipKey as nvarchar(20))
					PRINT '    IP: ' + CAST(@pipFrom as nvarchar(20))  + ' - ' + CAST(@pipTo as nvarchar(20))
					PRINT ' Range: ' + CAST(@RangeLow as nvarchar(20)) + ' - ' + CAST(@RangeHigh as nvarchar(20)) 
					PRINT 'INSERT: ' + CAST(@insertLow as nvarchar(20)) + ' - ' + CAST(@insertHigh as nvarchar(20))
					PRINT ' '
				END

				INSERT INTO dbo.ipTable_mini VALUES (@ipKey, @insertLow, @insertHigh, @pcountrySHORT, @pcountryLONG)
				SET @ipKey = @ipKey + 1
			END
		END
--END:PROCESS

CLOSE ipCURSOR
DEALLOCATE ipCURSOR

--SELECT SYSDATETIME()

--CREATE TABLE test (ipKeyFrom tinyint, ipKeyTo tinyint, ipFrom bigint, ipTo bigint, countrySHORT varchar(2))
--CREATE TABLE test2 (ipKeyFrom tinyint, ipKeyTo tinyint, ipFrom bigint, ipTo bigint, countrySHORT varchar(2))

--truncate table test2



GO
/****** Object:  StoredProcedure [dbo].[Prepare_IPDB]    Script Date: 1/3/2024 1:47:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[Prepare_IPDB]
AS
SELECT 1
/*
-- [ 0 ] get current data count for comparison
PRINT '=== Get RowCount ==='
CREATE TABLE #RowCount (TableName varchar(50), RowCnt int)
INSERT INTO #RowCount SELECT 'IPTable'     , COUNT(*) FROM dbo.IPTable with (NOLOCK)
INSERT INTO #RowCount SELECT 'IPTable_Mini', COUNT(*) FROM dbo.IPTable_Mini WITH (NOLOCK)
INSERT INTO #RowCount SELECT 'IPv6_DB1'    , COUNT(*) FROM dbo.TEMP_IPv6_DB1 WITH (NOLOCK)
INSERT INTO #RowCount SELECT 'IPv6_DB3'    , COUNT(*) FROM dbo.TEMP_IPv6_DB3 WITH (NOLOCK)

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
PRINT '=== perform BULK INSERT ==='

BULK INSERT [dbo].[IPTable]
    FROM 'D:\IPDB\IP-COUNTRY-REGION-CITY.CSV'
    WITH
    ( FORMATFILE = 'D:\IPDB\IPv4-DB3.FMT' , BATCHSIZE = 100000 )

GO
BULK INSERT [dbo].[Staging_IPv6_DB1]
    FROM                'D:\IPDB\IPV6-COUNTRY.CSV'
    WITH ( FORMATFILE = 'D:\IPDB\IPv6-DB1.FMT'    , BATCHSIZE = 100000)
GO
BULK INSERT [dbo].[Staging_IPv6_DB3]
    FROM                'D:\IPDB\IPV6-COUNTRY-REGION-CITY.CSV'
    WITH ( FORMATFILE = 'D:\IPDB\IPv6-DB3.FMT'    , BATCHSIZE = 100000 )
GO

-- [ 3 ] Prepare IPKey for IPv4   , current code assume data having 12m row max
PRINT '=== update ipKey value for IPv4 ==='
UPDATE TOP (1000000) IPTABLE 
SET ipkeyfrom = CAST((ipfrom/16777216) as tinyint), ipkeyto = CAST((ipto/16777216) as tinyint)
WHERE ipKeyFrom = 0 AND ipKeyTO = 0
GO 12


-- [ 4 ] Modify Data which been special mark/request as specific Country
PRINT '=== manual Country Modify ==='

-- 20131225@Vivi: need manual update [61.14.176.18] this ip is JP ip 
--SELECT dbo.ipconvert('61.14.176.18') 
UPDATE iptable set countrySHORT='JP',countryLong='JAPAN', IsModified=1 WHERE ipKeyFrom=61 and ipKeyTO=61 and ipFrom=1024372736 and ipTo=1024372879
--SELECT * FROM IPTable WITH (nolock) WHERE 1024372754 between ipFrom and ipTo

-- 20180419 : for KH customer, Master claim they really login from KH.
--SELECT dbo.ipconvert('111.90.190.50') 
UPDATE iptable set countrySHORT='KH',countryLong='Cambodia', IsModified=1 WHERE ipKeyFrom=111 and ipKeyTO=111 and ipFrom=1868217856 and ipTo=1868218111
--SELECT * FROM IPTable WITH (nolock) WHERE 1868217906 between ipFrom and ipTo

-- 20210503 : for ID customer, IP2Location return not matched with ipinfo.io --> 64.64.121.0/24
--SELECT dbo.ipconvert('64.64.121.0'), dbo.ipconvert('64.64.121.255')
UPDATE IPTable SET countrySHORT='ID', countryLONG='Indonesia', IsModified=1  WHERE ipFrom >= 1077967104 and ipTo <= 1077967359
--SELECT * FROM IPTable WITH (nolock)                                          WHERE ipFrom >= 1077967104 and ipTo <= 1077967359

-- 2022 : KH at this range had return as US, so got request to manual override.
UPDATE iptable set countrySHORT='KH',countryLong='Cambodia', IsModified=1 WHERE ipKeyFrom=103 and ipFrom=1736952832 and ipTo=1736953343
UPDATE iptable set countrySHORT='KH',countryLong='Cambodia', IsModified=1 WHERE ipKeyFrom=103 and ipFrom=1736953600 and ipTo=1736953855
GO

-- [ 5 ] for row which ipKeyFrom not equal to ipKeyTo, break it. so, we don't required BETWEEN to check for ipKey, just compare with ipKeyFrom
PRINT '=== eliminate range for ipKey ==='

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

UPDATE IPTable SET countryLONG = 'Taiwan' WHERE countrySHORT = 'TW'
--UPDATE IPTable_Mini SET countryLONG = 'Taiwan' WHERE countrySHORT = 'TW'
--UPDATE Country SET CountryName = 'TAIWAN' WHERE CountryCode = 'TW'
--UPDATE IPTable_Denied SET countryLONG = 'Taiwan' WHERE countrySHORT = 'TW'

GO

-- [ 7 ] MergeIP : create IPTable_Mini data from IPTable, rebuild Index prior to process for speed up

ALTER INDEX [CIX_ipKey]       ON [dbo].[IPTable] REBUILD PARTITION = ALL WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = ON, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
ALTER INDEX [IX_CountrySHORT] ON [dbo].[IPTable] REBUILD PARTITION = ALL WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = ON, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
ALTER INDEX [IX_ipFROM_ipTO]  ON [dbo].[IPTable] REBUILD PARTITION = ALL WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = ON, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
GO
PRINT '=== generate IPTable_Mini ==='
EXEC dbo.MergeIP
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


-- [ 9 ] process IPv6 data, using Trigger in each Staging table, assume 1.2m from DB1, and 12m from DB3
PRINT '=== IPv6 transform ==='
DELETE TOP ( 100000)  FROM Staging_IPv6_DB1
GO 12
DELETE TOP (1000000) FROM Staging_IPv6_DB3
GO 8
DELETE TOP ( 200000)  FROM Staging_IPv6_DB3
GO 20

-- [ 10 ] get ipKey for IPv6
EXEC dbo.Prepare_KeyMap
GO

-- [ 11 ] rebuild all
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
      SELECT 'IPTable' TableName, COUNT(*) RowCnt FROM dbo.IPTable with (NOLOCK)
UNION SELECT 'IPTable_Mini'     , COUNT(*) FROM dbo.IPTable_Mini WITH (NOLOCK)
UNION SELECT 'IPv6_DB1'         , COUNT(*) FROM dbo.TEMP_IPv6_DB1 WITH (NOLOCK)
UNION SELECT 'IPv6_DB3'         , COUNT(*) FROM dbo.TEMP_IPv6_DB3 WITH (NOLOCK)
)
SELECT rc.TableName, rc.RowCnt as CountBefore, NewCount.RowCnt as CountAfter
FROM #RowCount rc INNER JOIN NewCount ON rc.TableName = NewCount.TableName

DROP TABLE #RowCount
*/
GO
/****** Object:  Trigger [dbo].[DB1_Convert]    Script Date: 1/3/2024 1:47:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE TRIGGER [dbo].[DB1_Convert]
   ON  [dbo].[Staging_IPv6_DB1]
   AFTER DELETE
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	;WITH CTE AS (
	SELECT 
		dbo.IPv6_StringToHex(ip_from) ipFROM,
		dbo.IPv6_StringToHex(ip_to  ) ipTO,
		country_code
	FROM deleted
	WHERE LEN(ip_from) > 15 -- 1st layer : (try) removed IPv4,  as when lookup, will using IPv4 Table instead (IPTable/IPTable_Mini)
	)
	
	INSERT INTO dbo.TEMP_IPv6_DB1 (ipFROM, ipTO, country_code, ipKey)
	SELECT ipFROM, ipTO, country_code, CONVERT(binary(2),LEFT(CONVERT(char(32), ipFROM, 2), 4),2)
	FROM CTE
	WHERE 
		ipFROM > 0x00000000000000000000FFFFFFFFFFFF -- 2nd layer : removed IPv4,  as when lookup, will using IPv4 Table instead (IPTable/IPTable_Mini)
	
    -- Insert statements for trigger here

END
GO
ALTER TABLE [dbo].[Staging_IPv6_DB1] ENABLE TRIGGER [DB1_Convert]
GO
/****** Object:  Trigger [dbo].[DB3_Convert]    Script Date: 1/3/2024 1:47:18 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE TRIGGER [dbo].[DB3_Convert]
   ON  [dbo].[Staging_IPv6_DB3]
   AFTER DELETE
AS 
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	;WITH CTE AS (
	SELECT
		dbo.IPv6_StringToHex(ip_from) ipFROM,
		dbo.IPv6_StringToHex(ip_to  ) ipTO, 
		country_code, region_name, city_name
		FROM deleted
		WHERE LEN(ip_from) > 15 -- 1st layer : (try) removed IPv4,  as when lookup, will using IPv4 Table instead (IPTable/IPTable_Mini)
	)
	INSERT INTO dbo.TEMP_IPv6_DB3 (ipFROM, ipTO, country_code, region_name, city_name, ipKey)
	SELECT
		ipFROM, ipTO, country_code, region_name, city_name,
		CONVERT(binary(2),LEFT(CONVERT(char(32), ipFROM, 2), 4),2)
	FROM CTE
	WHERE 
		ipFROM > 0x00000000000000000000FFFFFFFFFFFF  -- 2nd layer : removed IPv4,  as when lookup, will using IPv4 Table instead (IPTable/IPTable_Mini)
      
    -- Insert statements for trigger here
END
GO
ALTER TABLE [dbo].[Staging_IPv6_DB3] ENABLE TRIGGER [DB3_Convert]
GO


USE [IPDB]
GO

/****** Object:  UserDefinedFunction [dbo].[IntegerToIPAddress]    Script Date: 1/7/2024 11:16:45 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


CREATE FUNCTION [dbo].[IntegerToIPAddress] (@IP AS bigint)

RETURNS varchar(15)

AS

BEGIN

DECLARE @Octet1 bigint
DECLARE @Octet2 bigint
DECLARE @Octet3 bigint
DECLARE @Octet4 bigint
DECLARE @RestOfIP bigint

SET @Octet1 = @IP / 16777216
SET @RestOfIP = @IP - (@Octet1 * 16777216)
SET @Octet2 = @RestOfIP / 65536
SET @RestOfIP = @RestOfIP - (@Octet2 * 65536)
SET @Octet3 = @RestOfIP / 256
SET @Octet4 = @RestOfIP - (@Octet3 * 256)
RETURN(CONVERT(varchar, @Octet1) + '.' +
	CONVERT(varchar, @Octet2) + '.' +
	CONVERT(varchar, @Octet3) + '.' +
	CONVERT(varchar, @Octet4))

END
GO


/****** Object:  UserDefinedFunction [dbo].[IP_DivideBy7Bytes]    Script Date: 1/4/2024 7:12:07 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

alter FUNCTION [dbo].[IP_DivideBy7Bytes]
(
	@input varchar(50)
)
RETURNS varchar(50)
BEGIN
	Declare @maxLen int         = LEN(@input)
	Declare @result varchar(50) = ''
	Declare @ipos int
	Declare @CurrentValue BIGINT

	SELECT @ipos = CASE WHEN @maxLen >= 17 THEN 17 ELSE @maxLen END
		 , @CurrentValue = CONVERT(BIGINT, LEFT(@input, @ipos))

	WHILE @ipos <= @maxLen
	BEGIN
		If @CurrentValue >= 72057594037927936
			SELECT @result = @result + LEFT( @CurrentValue/72057594037927936 , 1 ) -- divide result
				 , @CurrentValue = @CurrentValue % 72057594037927936 -- left over
		Else 
		BEGIN
			SET @ipos = @ipos + 1

			IF @ipos > @maxLen -- finished compute, convert leftover to HEX and append to result
				SET @result = @result + CONVERT(char(14),CONVERT(binary(7), CONVERT(BIGINT,@CurrentValue)),2)
			Else
			BEGIN -- get next value, add for next round calculation
				SET @CurrentValue = (@CurrentValue * 10) + CONVERT(tinyint, SUBSTRING(@input, @ipos, 1))
				IF @CurrentValue < 72057594037927936 AND @result <> '' SET @result = @result + '0'
			END
		END
	END

	RETURN @result
END
GO

/****** Object:  UserDefinedFunction [dbo].[IPv6_StringToHex]    Script Date: 1/4/2024 7:12:24 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


alter FUNCTION [dbo].[IPv6_StringToHex]
(
	@input varchar(50)
	--,@method tinyint
)
RETURNS binary(16)
AS
BEGIN
	DECLARE @result varchar(128)
	SET @input = LTRIM(RTRIM(@input))

-- 20201130 : test & create code to get data by doing base 2 and base 16
-- 20240102 : test & modify code to divide by 256, to get one byte data directly
-- 20240102 : test & modify code to divide by 65536, to get two bytes data directly
/*
	IF @method = 1
	BEGIN
		SET @result = dbo.IP_StringNumberToBase2(@input)
		SET @result = REPLACE(SPACE(128-LEN(@result)),' ','0') + @result

		SET @result = 
			dbo.IP_BitToHex(SUBSTRING(@result,  1,4)) +
			dbo.IP_BitToHex(SUBSTRING(@result,  5,4)) +
			dbo.IP_BitToHex(SUBSTRING(@result,  9,4)) +
			dbo.IP_BitToHex(SUBSTRING(@result, 13,4)) +
			dbo.IP_BitToHex(SUBSTRING(@result, 17,4)) +
			dbo.IP_BitToHex(SUBSTRING(@result, 21,4)) +
			dbo.IP_BitToHex(SUBSTRING(@result, 25,4)) +
			dbo.IP_BitToHex(SUBSTRING(@result, 29,4)) +
			dbo.IP_BitToHex(SUBSTRING(@result, 33,4)) +
			dbo.IP_BitToHex(SUBSTRING(@result, 37,4)) +
			dbo.IP_BitToHex(SUBSTRING(@result, 41,4)) +
			dbo.IP_BitToHex(SUBSTRING(@result, 45,4)) +
			dbo.IP_BitToHex(SUBSTRING(@result, 49,4)) +
			dbo.IP_BitToHex(SUBSTRING(@result, 53,4)) +
			dbo.IP_BitToHex(SUBSTRING(@result, 57,4)) +
			dbo.IP_BitToHex(SUBSTRING(@result, 61,4)) +
			dbo.IP_BitToHex(SUBSTRING(@result, 65,4)) +
			dbo.IP_BitToHex(SUBSTRING(@result, 69,4)) +
			dbo.IP_BitToHex(SUBSTRING(@result, 73,4)) +
			dbo.IP_BitToHex(SUBSTRING(@result, 77,4)) +
			dbo.IP_BitToHex(SUBSTRING(@result, 81,4)) +
			dbo.IP_BitToHex(SUBSTRING(@result, 85,4)) +
			dbo.IP_BitToHex(SUBSTRING(@result, 89,4)) +
			dbo.IP_BitToHex(SUBSTRING(@result, 93,4)) +
			dbo.IP_BitToHex(SUBSTRING(@result, 97,4)) +
			dbo.IP_BitToHex(SUBSTRING(@result,101,4)) +
			dbo.IP_BitToHex(SUBSTRING(@result,105,4)) +
			dbo.IP_BitToHex(SUBSTRING(@result,109,4)) +
			dbo.IP_BitToHex(SUBSTRING(@result,113,4)) +
			dbo.IP_BitToHex(SUBSTRING(@result,117,4)) +
			dbo.IP_BitToHex(SUBSTRING(@result,121,4)) +
			dbo.IP_BitToHex(SUBSTRING(@result,125,4))

	END

	IF @method = 2
	BEGIN
		SET @result = dbo.IP_StringNumberToBase16(@input)
		SET @result = REPLACE(SPACE(32-LEN(@result)),' ','0') + @result
	END

	IF @method = 3
	BEGIN
		SET @result = dbo.IP_StringNumberToByte(@input)
		SET @result = REPLACE(SPACE(32-LEN(@result)),' ','0') + @result
	END

	IF @method = 4
	BEGIN
		Declare @HexResult varchar(50)
		SET @HexResult = ''

		WHILE @input <> '0' AND @input <> ''
		BEGIN
			SELECT @result = dbo.IP_DivideBy65536(@input)
				 , @HexResult = RIGHT(@result, 4) + @HexResult
				 , @input = LEFT(@result, LEN(@result) - 4)
		END

		--SET @result = dbo.IP_StringNumberToDoubleByte(@input)
		SET @result = REPLACE(SPACE(32-LEN(@HexResult)),' ','0') + @HexResult
	END

	IF @method = 5
	BEGIN
		Declare @HexResult varchar(50)
		SET @HexResult = ''

		WHILE @input <> '0' AND @input <> ''
		BEGIN
			SELECT @result = dbo.IP_DivideBy4Bytes(@input)
				 , @HexResult = RIGHT(@result, 8) + @HexResult
				 , @input = LEFT(@result, LEN(@result) - 8)
		END

		--SET @result = dbo.IP_StringNumberToDoubleByte(@input)
		SET @result = REPLACE(SPACE(32-LEN(@HexResult)),' ','0') + @HexResult
	END

	IF @method = 6
*/
	BEGIN
		Declare @HexResult varchar(50)
		SET @HexResult = ''

		WHILE @input <> '0' AND @input <> ''
		BEGIN
			SELECT @result = dbo.IP_DivideBy7Bytes(@input)
				 , @HexResult = RIGHT(@result, 14) + @HexResult
				 , @input = LEFT(@result, LEN(@result) - 14)
		END

		--SET @result = dbo.IP_StringNumberToDoubleByte(@input)
		-- when run 3 pass, result length will be 7x3 = 21 bytes (42 char), useful data is only 16 bytes (32 char)
		SELECT @HexResult = CASE WHEN LEN(@HexResult) > 32 THEN RIGHT(@HexResult, 32) ELSE @HexResult END
		     , @result    = REPLACE(SPACE(32-LEN(@HexResult)),' ','0') + @HexResult
	END

	RETURN CONVERT(binary(16), @result, 2)
END
GO