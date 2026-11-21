# =========================================================================================
# Script: run_14_migration.ps1
# Açıklama: 14_CREATE_CEZA_PARAMETRE_VE_GENELGE_SINIFLANDIRMA.sql dosyasını hedef veritabanına uygular.
# =========================================================================================

param(
    [string]$Server = "(localdb)\MSSQLLocalDB",
    [string]$Database = "CEZA"
)

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$sqlFile = Join-Path $scriptDir "14_CREATE_CEZA_PARAMETRE_VE_GENELGE_SINIFLANDIRMA.sql"

if (!(Test-Path $sqlFile)) {
    Write-Error "SQL dosyası bulunamadı: $sqlFile"
    exit 1
}

$connStr = "Server=$Server;Database=$Database;Integrated Security=True;"
Write-Host "Veritabanına bağlanılıyor: $Server / $Database..." -ForegroundColor Cyan

try {
    $conn = New-Object System.Data.SqlClient.SqlConnection($connStr)
    $conn.Open()
    
    $rawSql = Get-Content $sqlFile -Raw -Encoding UTF8
    
    # Split by GO batches
    $batches = [System.Text.RegularExpressions.Regex]::Split($rawSql, "^\s*GO\s*$", [System.Text.RegularExpressions.RegexOptions]::Multiline -bor [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)
    
    foreach ($batch in $batches) {
        $clean = $batch.Trim()
        if (![string]::IsNullOrWhiteSpace($clean)) {
            $cmd = $conn.CreateCommand()
            $cmd.CommandText = $clean
            $cmd.ExecuteNonQuery() | Out-Null
        }
    }
    
    $conn.Close()
    Write-Host "[BASARILI] CezaParametre tablosu ve varsayılan parametreler başarıyla uygulandı!" -ForegroundColor Green
}
catch {
    Write-Error "Hata: $($_.Exception.Message)"
    exit 1
}
