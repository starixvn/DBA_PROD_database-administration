#declare variables and set the filename
$db1_ipv6 = "DB1-IPV6-COUNTRY.CSV.ZIP"
$db3 = "DB3-IP-COUNTRY-REGION-CITY.CSV.ZIP"
$db3_ipv6 = "DB3-IPV6-COUNTRY-REGION-CITY.CSV.ZIP"

#token and file path
$token = "CPVWqMJcBsNLnoUJkqtw5rChZhEEBgfTGY6ldRP5zUUXCwOuuaHP833q23sf5lQ0"
$local_download_path = "D:\_000_Nexcel\IPDB_Monthly\_ip2loc_download"

#extract path
$local_extract_path = "D:\_000_Nexcel\IPDB_Monthly\_ip2loc_extract_files"

#ip2location db code
$code_db1_ipv6 = "DB1IPV6"
$code_db3 = "DB3"
$code_db3_ipv6 = "DB3IPV6"

#url
$url_db1_ipv6 = "https://www.ip2location.com/download?token=$token&file=$code_db1_ipv6"
$url_db3 = "https://www.ip2location.com/download?token=$token&file=$code_db3"
$url_db3_ipv6 = "https://www.ip2location.com/download?token=$token&file=$code_db3_ipv6"


#auto download and extract file when done
if (-not(Test-Path -Path "$local_download_path\$db1_ipv6" -PathType Leaf)) 
{
    Invoke-WebRequest -Uri "$url_db1_ipv6" -OutFile "$local_download_path\$db1_ipv6"
    Invoke-WebRequest -Uri "$url_db3" -OutFile "$local_download_path\$db3"
    Invoke-WebRequest -Uri "$url_db3_ipv6" -OutFile "$local_download_path\$db3_ipv6"
}

#extract files
if (-not(Test-Path -Path "$local_extract_path\$db1_ipv6" -PathType Leaf)) 
{
Expand-Archive -Force -LiteralPath "$local_download_path\$db1_ipv6" -DestinationPath "$local_extract_path\$db1_ipv6" 
Expand-Archive -Force -LiteralPath "$local_download_path\$db3" -DestinationPath "$local_extract_path\$db3"
Expand-Archive -Force -LiteralPath "$local_download_path\$db3_ipv6" -DestinationPath "$local_extract_path\$db3_ipv6"
}