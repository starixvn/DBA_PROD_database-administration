[CmdletBinding()]
param()

Write-Verbose -Message "Start moving packages to DBSPARE"

	Copy-Item -Path "\\10.40.40.132\Delivery\*" -Destination "G:\MNL_SIT_Package" -Recurse -Force
	Write-Verbose -Message "- Done copy packages to DBSPARE"
	Get-ChildItem -Path "\\10.40.40.132\Delivery" | Remove-Item -Recurse -Force
	Write-Verbose -Message "- Done remove packages on source"

Write-Output "Done move packages to DBSPARE"

Write-Verbose -Message "Start moving packages to SIT and MNL"

	Copy-Item -Path "G:\MNL_SIT_Package\*" -Destination "\\172.16.1.6\Script" -Recurse -Force
	Write-Verbose -Message "- Done copy packages to SIT"
	Copy-Item -Path "G:\MNL_SIT_Package\*" -Destination "\\10.11.108.244\Script" -Recurse -Force
	Write-Verbose -Message "- Done copy packages to MNL"
	Get-ChildItem -Path "G:\MNL_SIT_Package" | Remove-Item -Recurse -Force
	Write-Verbose -Message "- Done remove packages on DBSPARE"

Write-Output "Done copy packages to SIT and MNL"
