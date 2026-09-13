Set shell = CreateObject("WScript.Shell")
scriptDir = CreateObject("Scripting.FileSystemObject").GetParentFolderName(WScript.ScriptFullName)

shell.Run "powershell.exe -NoProfile -ExecutionPolicy Bypass -File """ & scriptDir & "\app_engine.ps1""", 0, False