param(
    [string]$ServerInstance = "localhost\HAVALIMANI",
    [string]$BackupPath = "C:\Program Files\Microsoft SQL Server\MSSQL13.HAVALIMANI\MSSQL\Backup\CEZA.bak",
    [string]$Database = "CEZA_MOBILE_EXPORT",
    [string]$OutputPath = "..\assets\cezam_data.json",
    [string]$SqlUser,
    [string]$SqlPassword,
    [switch]$ForceRestore
)

$ErrorActionPreference = "Stop"
Add-Type -AssemblyName System.Data

function New-ConnectionString {
    param(
        [string]$Catalog
    )

    if ($SqlUser) {
        return "Data Source=$ServerInstance;Initial Catalog=$Catalog;User ID=$SqlUser;Password=$SqlPassword;MultipleActiveResultSets=True;Connect Timeout=60;Encrypt=False;TrustServerCertificate=True"
    }

    return "Data Source=$ServerInstance;Initial Catalog=$Catalog;Integrated Security=True;MultipleActiveResultSets=True;Connect Timeout=60;Encrypt=False;TrustServerCertificate=True"
}

function Invoke-Scalar {
    param(
        [System.Data.SqlClient.SqlConnection]$Connection,
        [string]$Sql
    )

    $cmd = $Connection.CreateCommand()
    $cmd.CommandTimeout = 0
    $cmd.CommandText = $Sql
    return $cmd.ExecuteScalar()
}

function Invoke-NonQuery {
    param(
        [System.Data.SqlClient.SqlConnection]$Connection,
        [string]$Sql
    )

    $cmd = $Connection.CreateCommand()
    $cmd.CommandTimeout = 0
    $cmd.CommandText = $Sql
    [void]$cmd.ExecuteNonQuery()
}

function Read-DataTable {
    param(
        [System.Data.SqlClient.SqlConnection]$Connection,
        [string]$Sql
    )

    $cmd = $Connection.CreateCommand()
    $cmd.CommandTimeout = 0
    $cmd.CommandText = $Sql
    $adapter = [System.Data.SqlClient.SqlDataAdapter]::new($cmd)
    $table = [System.Data.DataTable]::new()
    [void]$adapter.Fill($table)
    return $table
}

function Quote-SqlString {
    param([string]$Value)
    return $Value.Replace("'", "''")
}

$master = [System.Data.SqlClient.SqlConnection]::new((New-ConnectionString "master"))
$master.Open()

$exists = [int](Invoke-Scalar $master "SELECT CASE WHEN DB_ID(N'$(Quote-SqlString $Database)') IS NULL THEN 0 ELSE 1 END")
if ($exists -eq 1 -and -not $ForceRestore) {
    Write-Output "Database $Database already exists; skipping restore. Use -ForceRestore to replace it."
}
else {
    if ($exists -eq 1) {
        Write-Output "Dropping existing database $Database..."
        Invoke-NonQuery $master "ALTER DATABASE [$Database] SET SINGLE_USER WITH ROLLBACK IMMEDIATE; DROP DATABASE [$Database];"
    }

    Write-Output "Reading backup file list..."
    $safeBackup = Quote-SqlString $BackupPath
    $fileList = Read-DataTable $master "RESTORE FILELISTONLY FROM DISK = N'$safeBackup';"
    if ($fileList.Rows.Count -lt 2) {
        throw "Backup file list is empty or incomplete: $BackupPath"
    }

    $dataLogical = ($fileList.Rows | Where-Object { $_.Type -eq "D" } | Select-Object -First 1).LogicalName
    $logLogical = ($fileList.Rows | Where-Object { $_.Type -eq "L" } | Select-Object -First 1).LogicalName
    if (-not $dataLogical -or -not $logLogical) {
        throw "Could not find data/log logical names in backup."
    }

    $dataPath = Invoke-Scalar $master "SELECT CAST(SERVERPROPERTY('InstanceDefaultDataPath') AS nvarchar(4000));"
    $logPath = Invoke-Scalar $master "SELECT CAST(SERVERPROPERTY('InstanceDefaultLogPath') AS nvarchar(4000));"
    if (-not $dataPath) { $dataPath = "C:\Program Files\Microsoft SQL Server\MSSQL13.HAVALIMANI\MSSQL\DATA\" }
    if (-not $logPath) { $logPath = $dataPath }

    $mdfPath = Join-Path $dataPath "$Database.mdf"
    $ldfPath = Join-Path $logPath "$($Database)_log.ldf"

    Write-Output "Restoring $BackupPath to $Database..."
    $restoreSql = @"
RESTORE DATABASE [$Database]
FROM DISK = N'$safeBackup'
WITH
    MOVE N'$(Quote-SqlString $dataLogical)' TO N'$(Quote-SqlString $mdfPath)',
    MOVE N'$(Quote-SqlString $logLogical)' TO N'$(Quote-SqlString $ldfPath)',
    REPLACE,
    RECOVERY,
    STATS = 10;
"@
    Invoke-NonQuery $master $restoreSql
}

$master.Close()

$exportScript = Join-Path $PSScriptRoot "export_cezam_data.ps1"
if ($SqlUser) {
    & $exportScript -ServerInstance $ServerInstance -Database $Database -SqlUser $SqlUser -SqlPassword $SqlPassword -OutputPath $OutputPath
}
else {
    & $exportScript -ServerInstance $ServerInstance -Database $Database -OutputPath $OutputPath
}
