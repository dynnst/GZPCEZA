param(
    [Parameter(Mandatory=$true)]
    [string]$imagePath
)

try {
    if (-not (Test-Path $imagePath)) {
        Write-Output '{"success":false,"message":"Görsel dosyası bulunamadı."}'
        exit 0
    }

    Add-Type -AssemblyName System.Drawing
    Add-Type -AssemblyName System.Runtime.WindowsRuntime

    $asTaskGeneric = [System.WindowsRuntimeSystemExtensions].GetMethods() | Where-Object { 
        $_.Name -eq 'AsTask' -and 
        $_.GetParameters().Count -eq 1 -and 
        $_.GetParameters()[0].ParameterType.Name -eq 'IAsyncOperation`1' 
    } | Select-Object -First 1

    function Await-WinRT($asyncOp, $type) {
        $method = $asTaskGeneric.MakeGenericMethod($type)
        $task = $method.Invoke($null, @($asyncOp))
        $task.Wait(-1) | Out-Null
        return $task.Result
    }

    [Windows.Media.Ocr.OcrEngine, Windows.Foundation, ContentType = WindowsRuntime] | Out-Null
    [Windows.Graphics.Imaging.BitmapDecoder, Windows.Foundation, ContentType = WindowsRuntime] | Out-Null
    [Windows.Storage.StorageFile, Windows.Foundation, ContentType = WindowsRuntime] | Out-Null
    [Windows.Globalization.Language, Windows.Foundation, ContentType = WindowsRuntime] | Out-Null

    $fullPath = [System.IO.Path]::GetFullPath($imagePath)
    $storageFile = Await-WinRT ([Windows.Storage.StorageFile]::GetFileFromPathAsync($fullPath)) ([Windows.Storage.StorageFile])
    $stream = Await-WinRT ($storageFile.OpenAsync([Windows.Storage.FileAccessMode]::Read)) ([Windows.Storage.Streams.IRandomAccessStream])
    $decoder = Await-WinRT ([Windows.Graphics.Imaging.BitmapDecoder]::CreateAsync($stream)) ([Windows.Graphics.Imaging.BitmapDecoder])
    $softwareBmp = Await-WinRT ($decoder.GetSoftwareBitmapAsync()) ([Windows.Graphics.Imaging.SoftwareBitmap])

    $engine = [Windows.Media.Ocr.OcrEngine]::TryCreateFromLanguage((New-Object Windows.Globalization.Language("en")))
    if (-not $engine) {
        $engine = [Windows.Media.Ocr.OcrEngine]::TryCreateFromUserProfileLanguages()
    }

    if (-not $engine) {
        Write-Output '{"success":false,"message":"Windows OCR motoru başlatılamadı."}'
        exit 0
    }

    $ocrResult = Await-WinRT ($engine.RecognizeAsync($softwareBmp)) ([Windows.Media.Ocr.OcrResult])

    $extractedLines = @()
    foreach ($line in $ocrResult.Lines) {
        $txt = $line.Text.Trim()
        if ($txt.Length -gt 0) {
            $extractedLines += $txt
        }
    }

    # Normalize lines to find MRZ candidates
    # In passports, MRZ is 44 chars (TD3) or 30/36 chars (TD1/TD2)
    # OCR sometimes misinterprets '<' as 'K', '(', '{', etc.
    $mrzCandidates = @()
    foreach ($line in $extractedLines) {
        $norm = $line.Replace(" ", "").ToUpper()
        if ($norm.Length -ge 24) {
            if ($norm.StartsWith("P") -or $norm.StartsWith("I") -or $norm.Contains("<") -or $norm -match "^[A-Z0-9<]{28,}$") {
                $mrzCandidates += $norm
            }
        }
    }

    # If candidates has at least 2 lines, pick the last two or longest matching
    $mrz1 = ""
    $mrz2 = ""
    if ($mrzCandidates.Count -ge 2) {
        $mrz1 = $mrzCandidates[$mrzCandidates.Count - 2]
        $mrz2 = $mrzCandidates[$mrzCandidates.Count - 1]
    } elseif ($extractedLines.Count -ge 2) {
        $mrz1 = $extractedLines[$extractedLines.Count - 2].Replace(" ", "").ToUpper()
        $mrz2 = $extractedLines[$extractedLines.Count - 1].Replace(" ", "").ToUpper()
    }

    $resultObj = [PSCustomObject]@{
        success = $true
        rawText = ($extractedLines -join "`n")
        mrz1 = $mrz1
        mrz2 = $mrz2
        mrzLines = @($mrz1, $mrz2)
    }

    $json = $resultObj | ConvertTo-Json -Compress
    Write-Output $json

} catch {
    $errObj = [PSCustomObject]@{
        success = $false
        message = $_.Exception.Message
    }
    Write-Output ($errObj | ConvertTo-Json -Compress)
}
