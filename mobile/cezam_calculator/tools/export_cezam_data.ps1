param(
    [string]$ConnectionString = "Data Source=(localdb)\MSSQLLocalDB;Initial Catalog=CEZA;Integrated Security=True;MultipleActiveResultSets=True;Connect Timeout=60",
    [string]$OutputPath = "..\assets\cezam_data.json",
    [string]$ServerInstance,
    [string]$Database = "CEZA",
    [string]$SqlUser,
    [string]$SqlPassword
)

$ErrorActionPreference = "Stop"
Add-Type -AssemblyName System.Data

if ($ServerInstance) {
    if ($SqlUser) {
        $ConnectionString = "Data Source=$ServerInstance;Initial Catalog=$Database;User ID=$SqlUser;Password=$SqlPassword;MultipleActiveResultSets=True;Connect Timeout=60;Encrypt=False;TrustServerCertificate=True"
    }
    else {
        $ConnectionString = "Data Source=$ServerInstance;Initial Catalog=$Database;Integrated Security=True;MultipleActiveResultSets=True;Connect Timeout=60;Encrypt=False;TrustServerCertificate=True"
    }
}

function Read-Table {
    param(
        [System.Data.SqlClient.SqlConnection]$Connection,
        [string]$Sql
    )

    $cmd = $Connection.CreateCommand()
    $cmd.CommandTimeout = 120
    $cmd.CommandText = $Sql
    $reader = $cmd.ExecuteReader()
    $rows = @()

    while ($reader.Read()) {
        $row = [ordered]@{}
        for ($i = 0; $i -lt $reader.FieldCount; $i++) {
            $value = $reader.GetValue($i)
            if ($value -is [DBNull]) { $value = $null }
            $row[$reader.GetName($i)] = $value
        }
        $rows += [pscustomobject]$row
    }

    $reader.Close()
    return $rows
}

$connection = [System.Data.SqlClient.SqlConnection]::new($ConnectionString)
$connection.Open()

$exchangeRows = Read-Table $connection "SELECT TOP 1 fldEuro AS EUR, fldDollar AS USD, fldPaund AS GBP FROM E_Exchange WHERE fldId = 1"
$defterRows = Read-Table $connection "SELECT TOP 1 fldPrice AS price, fldTypeofMoney AS currency FROM E_Defter WHERE fldId = 1"
$tgvhRows = Read-Table $connection "SELECT fldYear AS [year], fldPrice AS price, fldTypeofMoney AS currency FROM E_TGVH ORDER BY fldYear"
$uvrRows = Read-Table $connection "SELECT fldCountry AS country, fldCalculateType AS calculateType, fldPassportType AS passportType, fldVisaStatus AS visaStatus, fldDay AS [day], fldLong AS longStay, fldOneTime AS oneTime, fldHB AS visaFeeEnabled FROM E_UVR ORDER BY fldCountry"
$auhRows = Read-Table $connection "SELECT fldCountry AS country, fldFirstMounth AS firstMonth, fldKat AS monthStep, fldDayStart AS dayStart, fldDayKat AS dayStep, fldToM AS currency FROM E_AUH ORDER BY fldCountry"
$tkodRows = Read-Table $connection "SELECT fldCode AS code, fldPTime AS penaltyTime, fldStart AS [start], fldFinish AS finish, fldIdariCode AS idariCode, fldPaid AS paidType FROM E_TKOD ORDER BY fldPaid, fldStart, fldFinish, fldCode"

$connection.Close()

$resolvedOutput = Join-Path $PSScriptRoot $OutputPath
$existingCountries = @()
if (Test-Path -LiteralPath $resolvedOutput) {
    try {
        $existing = Get-Content -LiteralPath $resolvedOutput -Raw | ConvertFrom-Json
        if ($existing.countries) {
            $existingCountries = @($existing.countries | ForEach-Object { "$_".Trim() } | Where-Object { $_ })
        }
    }
    catch {
        $existingCountries = @()
    }
}

$databaseCountries = @(
    $uvrRows | ForEach-Object { "$($_.country)".Trim() } | Where-Object { $_ }
    $auhRows | ForEach-Object { "$($_.country)".Trim() } | Where-Object { $_ }
)
$countries = @($existingCountries + $databaseCountries | Sort-Object -Unique)

$data = [ordered]@{
    version = 1
    generatedAt = (Get-Date).ToString("s")
    countries = $countries
    exchange = if ($exchangeRows.Count -gt 0) { $exchangeRows[0] } else { [ordered]@{ EUR = 1; USD = 1; GBP = 1 } }
    defter = if ($defterRows.Count -gt 0) { $defterRows[0] } else { [ordered]@{ price = 0; currency = "TRY" } }
    tgvh = $tgvhRows
    uvr = $uvrRows
    auh = $auhRows
    tkod = $tkodRows
}

$json = $data | ConvertTo-Json -Depth 8
Set-Content -LiteralPath $resolvedOutput -Value $json -Encoding UTF8
Write-Output "Exported CEZAM data to $resolvedOutput"
Write-Output "Countries=$($countries.Count) UVR=$($uvrRows.Count) AUH=$($auhRows.Count) TGVH=$($tgvhRows.Count) TKOD=$($tkodRows.Count)"
