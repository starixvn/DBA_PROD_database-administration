
#declare variables and set the filename
$desPath = "D:\_000_Nexcel\IPDB_Monthly\_ip2loc_final_data"


bcp IPTable               out $desPath\bcp_IPTable.csv        -S localhost\sql2019 -T -d IPDB -c -tv!x
bcp IPTable_Mini          out $desPath\bcp_IPTable_Mini.csv   -S localhost\sql2019 -T -d IPDB -c -tv!x
bcp IPTable_Denied        out $desPath\bcp_IPTable_Denied.csv -S localhost\sql2019 -T -d IPDB -c -tv!x

bcp TEMP_IPv6_DB1         out $desPath\bcp_IPv6_DB1.csv       -S localhost\sql2019 -T -d IPDB -c -tv!x
bcp TEMP_IPv6_DB3         out $desPath\bcp_IPv6_DB3.csv       -S localhost\sql2019 -T -d IPDB -c -tv!x
bcp TEMP_KeyMap_IPv6_DB1  out $desPath\bcp_IPv6_Key1.csv      -S localhost\sql2019 -T -d IPDB -c -tv!x
bcp TEMP_KeyMap_IPv6_DB3  out $desPath\bcp_IPv6_Key3.csv      -S localhost\sql2019 -T -d IPDB -c -tv!x

$7zipPath = "$env:ProgramFiles\7-Zip\7z.exe"

if (-not (Test-Path -Path $7zipPath -PathType Leaf)) {
    throw "7 zip file '$7zipPath' not found"
}

Set-Alias 7zip $7zipPath

$Source = "$desPath\bcp_IPTable*.csv"
$Target = "$desPath\bcp_IPDB.exe"

7zip a -sfx -mmt=6 -bsp2 $Target $Source

$Source = "$desPath\bcp_IPv6*.csv"
$Target = "$desPath\bcp_IPv6.exe"

7zip a -sfx -mmt=6 -bsp2 $Target $Source