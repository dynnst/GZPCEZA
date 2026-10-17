[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$SqlServer,

    [string]$Database = 'CEZA',

    [ValidateSet('Windows', 'Sql')]
    [string]$Authentication = 'Windows',

    [string]$SqlUser,

    [SecureString]$SqlPassword,

    [string]$OutputDirectory = (Join-Path $PSScriptRoot 'exports'),

    [datetime]$FromDate,

    [datetime]$ToDate
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function New-CezaConnectionString {
    if ($Authentication -eq 'Windows') {
        return "Data Source=$SqlServer;Initial Catalog=$Database;Integrated Security=True;Encrypt=True;TrustServerCertificate=True;Connect Timeout=30"
    }

    if ([string]::IsNullOrWhiteSpace($SqlUser) -or $null -eq $SqlPassword) {
        throw 'SQL kimlik doğrulaması için -SqlUser ve -SqlPassword gereklidir.'
    }

    $passwordPointer = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($SqlPassword)
    try {
        $plainPassword = [Runtime.InteropServices.Marshal]::PtrToStringBSTR($passwordPointer)
        return "Data Source=$SqlServer;Initial Catalog=$Database;User ID=$SqlUser;Password=$plainPassword;Encrypt=True;TrustServerCertificate=True;Connect Timeout=30"
    }
    finally {
        [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($passwordPointer)
    }
}

function Export-CezaTable {
    param(
        [System.Data.SqlClient.SqlConnection]$Connection,
        [string]$TableName,
        [string]$DateColumn,
        [string]$Path
    )

    $command = $Connection.CreateCommand()
    $command.CommandText = @"
SELECT *
FROM dbo.[$TableName]
WHERE (@FromDate IS NULL OR [$DateColumn] >= @FromDate)
  AND (@ToDate IS NULL OR [$DateColumn] < DATEADD(day, 1, @ToDate))
ORDER BY [$DateColumn] DESC, fldId DESC;
"@
    $command.Parameters.Add('@FromDate', [System.Data.SqlDbType]::DateTime).Value = if ($PSBoundParameters.ContainsKey('FromDate')) { $FromDate } else { [DBNull]::Value }
    $command.Parameters.Add('@ToDate', [System.Data.SqlDbType]::DateTime).Value = if ($PSBoundParameters.ContainsKey('ToDate')) { $ToDate.Date } else { [DBNull]::Value }

    $adapter = [System.Data.SqlClient.SqlDataAdapter]::new($command)
    $dataTable = [System.Data.DataTable]::new()
    [void]$adapter.Fill($dataTable)

    $dataTable | Export-Csv -LiteralPath $Path -NoTypeInformation -Encoding UTF8
    return $dataTable.Rows.Count
}

New-Item -ItemType Directory -Force -Path $OutputDirectory | Out-Null
$timestamp = Get-Date -Format 'yyyyMMdd_HHmmss'
$connection = [System.Data.SqlClient.SqlConnection]::new((New-CezaConnectionString))

try {
    $connection.Open()
    $historyFile = Join-Path $OutputDirectory "E_History_$timestamp.csv"
    $iskFile = Join-Path $OutputDirectory "E_IsK_$timestamp.csv"

    $historyCount = Export-CezaTable -Connection $connection -TableName 'E_History' -DateColumn 'fldDatetime' -Path $historyFile
    $iskCount = Export-CezaTable -Connection $connection -TableName 'E_IsK' -DateColumn 'fldDatetime' -Path $iskFile

    Write-Host "E_History: $historyCount kayıt -> $historyFile"
    Write-Host "E_IsK: $iskCount kayıt -> $iskFile"
}
finally {
    $connection.Dispose()
}
