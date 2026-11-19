' EGM Optik Okuyucu Köprüsünü Ekranda Hiçbir Siyah Pencere Açmadan Arka Planda Başlatır
Set WshShell = CreateObject("WScript.Shell")
targetDir = WshShell.ExpandEnvironmentStrings("%LOCALAPPDATA%\EgmReaderBridge")
targetExe = targetDir & "\EgmReaderBridge.exe"

' Köprü dosyası hedef dizinde yoksa App_Data klasöründen kopyala
Set fso = CreateObject("Scripting.FileSystemObject")
If Not fso.FileExists(targetExe) Then
    scriptDir = fso.GetParentFolderName(WScript.ScriptFullName)
    sourceExe = scriptDir & "\EgmReaderBridge.exe"
    If fso.FileExists(sourceExe) Then
        If Not fso.FolderExists(targetDir) Then fso.CreateFolder(targetDir)
        fso.CopyFile sourceExe, targetExe, True
    End If
End If

' Pencere stili 0 = vbHide (Tamamen görünmez arka plan modu)
If fso.FileExists(targetExe) Then
    WshShell.Run Chr(34) & targetExe & Chr(34), 0, False
End If
