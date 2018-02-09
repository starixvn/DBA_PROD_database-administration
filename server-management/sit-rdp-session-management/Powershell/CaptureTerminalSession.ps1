[CmdletBinding()]
param()

##
#	Creator:	20180207@Billy
#	Task:		SIT RDP Management - Remote session control - [Redmine: #90722]
#	Server:		SIT-RDP2
##

# Open SQL Connection
$DBServer 	= "SITDB06"
$DBName		= "MonDB"
$DBLogin	= "vnTask"
$Testing	= "#vnT@sk@S1T#"

Write-Verbose "Create Connection to SQL Server"

$SQLConnection = New-Object System.Data.SqlClient.SqlConnection
$SQLConnection.ConnectionString	= "Server=$DBServer;Database=$DBName;User ID=$DBLogin;Password=$Testing;"
$SQLConnection.Open()

if ($SqlConnection.State -ne [Data.ConnectionState]::Open) {
	Write-Error "Connection to DB Server is not opened."
	Exit
}

Write-Verbose "Create Command to SQL Server"

$SQLCommand = New-Object System.Data.SqlClient.SqlCommand
$SQLCommand.Connection = $SQLConnection
$SQLCommand.CommandText = "EXECUTE	MonDB.dbo.vnDBA_sp_RDP_CollectSessionInfo @InputTable, 10;"
$SQLCommand.Parameters.Add((New-Object Data.SqlClient.SqlParameter("@InputTable",[Data.SqlDBType]::Structured))) | Out-Null

Write-Verbose "Define parameters"

$InputTable = New-Object Data.DataTable
$InputTable.Columns.Add((New-Object Data.DataColumn("ServerName",[Type]::GetType("System.String"))))
$InputTable.Columns.Add((New-Object Data.DataColumn("SessionId",[Type]::GetType("System.Int32"))))
$InputTable.Columns.Add((New-Object Data.DataColumn("SessionState",[Type]::GetType("System.String"))))
$InputTable.Columns.Add((New-Object Data.DataColumn("IPAddress",[Type]::GetType("System.String"))))
$InputTable.Columns.Add((New-Object Data.DataColumn("ClientName",[Type]::GetType("System.String"))))
$InputTable.Columns.Add((New-Object Data.DataColumn("WindowStationName",[Type]::GetType("System.String"))))
$InputTable.Columns.Add((New-Object Data.DataColumn("UserName",[Type]::GetType("System.String"))))
$InputTable.Columns.Add((New-Object Data.DataColumn("ConnectTime",[Type]::GetType("System.DateTime"))))
$InputTable.Columns.Add((New-Object Data.DataColumn("DisconnectTime",[Type]::GetType("System.DateTime"))))
$InputTable.Columns.Add((New-Object Data.DataColumn("LastInputTime",[Type]::GetType("System.DateTime"))))
$InputTable.Columns.Add((New-Object Data.DataColumn("CurrentTime",[Type]::GetType("System.DateTime"))))

Write-Verbose "Get data"

$ServerName = $env:COMPUTERNAME

$Sessions = Get-TSSession -ComputerName .

ForEach ($Session in $Sessions) {
	Write-Verbose "    $($Session.SessionId)  $($Session.ConnectionState)  $($Session.UserName)  $($Session.ClientName) $($Session.ClientIPAddress) $($Session.WindowStationName) -"

	$Row = $InputTable.NewRow()
	$Row["ServerName"]			= $ServerName
	$Row["SessionId"]			= $Session.SessionId
	$Row["SessionState"]		= $Session.ConnectionState
	if ($Session.ClientIPAddress -ne $null) {
		$Row["IPAddress"]			= $Session.ClientIPAddress.IPAddressToString
	}
	$Row["ClientName"]			= $Session.ClientName
	$Row["WindowStationName"]	= $Session.WindowStationName
	$Row["UserName"]			= $Session.UserName
	if ($Session.ConnectTime -ne $null) {
		$Row["ConnectTime"]			= $Session.ConnectTime
	}
	if ($Session.DisconnectTime -ne $null) {
		$Row["DisconnectTime"]		= $Session.DisconnectTime
	}
	if ($Session.LastInputTime -ne $null) {
		$Row["LastInputTime"]		= $Session.LastInputTime
	}
	$Row["CurrentTime"]			= $Session.CurrentTime
	
	$InputTable.Rows.Add($Row)
}
	
Write-Verbose "Assign parameters"
	
$SQLCommand.Parameters[0].Value = $InputTable
$SQLCommand.Parameters[0].TypeName = "dbo.TSSession"

Write-Verbose "Execute query"

$RowCount = $SQLCommand.ExecuteNonQuery()

Write-Verbose "Close connection to SQL Server"

if ($SQLConnection.State -eq [Data.ConnectionState]::Open) {
	$SQLConnection.Close()
}

Write-Verbose "Done."