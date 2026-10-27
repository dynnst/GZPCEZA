param(
    [Parameter(Mandatory=$true)]
    [string]$imagePath
)

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

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

    $engine = [Windows.Media.Ocr.OcrEngine]::TryCreateFromLanguage((New-Object Windows.Globalization.Language("en-US")))
    if (-not $engine) {
        $engine = [Windows.Media.Ocr.OcrEngine]::TryCreateFromUserProfileLanguages()
    }

    if (-not $engine) {
        Write-Output '{"success":false,"message":"Windows OCR motoru başlatılamadı."}'
        exit 0
    }

    function Run-OcrOnFile($filePath) {
        $fullPath = [System.IO.Path]::GetFullPath($filePath)
        $storageFile = Await-WinRT ([Windows.Storage.StorageFile]::GetFileFromPathAsync($fullPath)) ([Windows.Storage.StorageFile])
        $stream = Await-WinRT ($storageFile.OpenAsync([Windows.Storage.FileAccessMode]::Read)) ([Windows.Storage.Streams.IRandomAccessStream])
        $decoder = Await-WinRT ([Windows.Graphics.Imaging.BitmapDecoder]::CreateAsync($stream)) ([Windows.Graphics.Imaging.BitmapDecoder])
        $softwareBmp = Await-WinRT ($decoder.GetSoftwareBitmapAsync()) ([Windows.Graphics.Imaging.SoftwareBitmap])
        $ocrRes = Await-WinRT ($engine.RecognizeAsync($softwareBmp)) ([Windows.Media.Ocr.OcrResult])
        
        $lineList = @()
        foreach ($l in $ocrRes.Lines) {
            $txt = $l.Text.Trim()
            if ($txt.Length -gt 0) {
                $lineList += $txt
            }
        }
        return @{
            lines = $lineList
            textAngle = $ocrRes.TextAngle
            width = $decoder.PixelWidth
            height = $decoder.PixelHeight
        }
    }

    # 1. Full image OCR
    $fullRes = Run-OcrOnFile $imagePath

    # 2. Bottom crop for high accuracy MRZ OCR (bottom 38%)
    $cropLines = @()
    $cropFile = $null
    try {
        if ($fullRes.height -ge 200 -and $fullRes.width -ge 200) {
            $srcBmp = [System.Drawing.Bitmap]::FromFile($imagePath)
            $cropH = [int]($srcBmp.Height * 0.42)
            $cropY = $srcBmp.Height - $cropH
            $cropRect = New-Object System.Drawing.Rectangle(0, $cropY, $srcBmp.Width, $cropH)

            # 1.3x scale for clearer OCR-B characters
            $targetW = [int]($srcBmp.Width * 1.3)
            $targetH = [int]($cropH * 1.3)
            $destBmp = New-Object System.Drawing.Bitmap($targetW, $targetH)
            $g = [System.Drawing.Graphics]::FromImage($destBmp)
            $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
            $g.DrawImage($srcBmp, (New-Object System.Drawing.Rectangle(0, 0, $targetW, $targetH)), $cropRect, [System.Drawing.GraphicsUnit]::Pixel)
            $g.Dispose()
            $srcBmp.Dispose()

            $cropFile = [System.IO.Path]::Combine([System.IO.Path]::GetTempPath(), ("mrz_crop_" + [System.Guid]::NewGuid().ToString("N") + ".jpg"))
            $destBmp.Save($cropFile, [System.Drawing.Imaging.ImageFormat]::Jpeg)
            $destBmp.Dispose()

            $cropRes = Run-OcrOnFile $cropFile
            $cropLines = @($cropRes.lines)
        }
    } catch { }
    finally {
        if ($cropFile -and (Test-Path $cropFile)) {
            try { Remove-Item $cropFile -Force -ErrorAction SilentlyContinue } catch { }
        }
    }

    $allLinesText = @($fullRes.lines)
    $rawText = ($allLinesText -join "`n")

    $resultObj = [PSCustomObject]@{
        success = $true
        rawText = $rawText
        lines = $allLinesText
        cropLines = $cropLines
        textAngle = $fullRes.textAngle
        imageWidth = $fullRes.width
        imageHeight = $fullRes.height
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
