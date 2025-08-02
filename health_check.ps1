<#
.SYNOPSIS
  Full system health check for Windows 10/11 with collapsible HTML sections and a terminal progress bar.

.DESCRIPTION
  Gathers:
    • System info (OS version, uptime)
    • Windows Update history & installed hotfixes
    • Volume & disk space
    • Services status
    • Installed applications (x86 & x64)
    • Recent Event Log errors/warnings
    • CPU & memory usage
    • Network adapters & IPs
    • Windows Defender status
    • Pending reboot flag
    • Physical disks (SMART/health)
    • BitLocker volume status
    • Firewall profiles
    • Scheduled tasks
    • BIOS/firmware info
    • Windows activation status
    • Time-sync state
    • Top 5 CPU & memory processes
    • TPM status
  Outputs both JSON and an HTML report with collapsible sections.

.NOTES
  - Run as Administrator.
  - Requires PSWindowsUpdate; installs it if missing.
  - Saves reports in the script directory.
#>

#region — Helper Functions

function Test-Administrator {
    $isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()
               ).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    if (-not $isAdmin) {
        Write-Error "This script must be run as Administrator."
        exit 1
    }
}

function Get-PendingReboot {
    $paths = @(
        'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\RebootPending',
        'HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\PendingFileRenameOperations',
        'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired'
    )
    foreach ($p in $paths) {
        if (Test-Path $p) { return $true }
    }
    return $false
}

function Ensure-Module {
    param($Name)
    if (-not (Get-Module -ListAvailable -Name $Name)) {
        Write-Host "Installing module $Name..."
        Install-Module -Name $Name -Force -Scope CurrentUser -AllowClobber
    }
}

#endregion

#— Check for elevation
Test-Administrator

#— Progress Bar Setup
$totalSteps = 23
$currentStep = 0
function Update-Progress {
    param([string]$Message)
    $script:currentStep++
    # Calculate raw percentage
    $rawPercent = ($script:currentStep / $script:totalSteps) * 100
    # Clamp to max 100 - Clamping because updating total steps can be... cumbersome over time.
    $percent = if ($rawPercent -gt 100) { 100 } else { [int]$rawPercent }
    Write-Progress `
      -Activity "System Health Check" `
      -Status $Message `
      -PercentComplete $percent
}


#— Ensure Windows Update module
Update-Progress "Checking for PSWindowsUpdate module"
Ensure-Module PSWindowsUpdate

#— Prepare output paths
Update-Progress "Preparing output file paths"
$stamp   = (Get-Date).ToString('yyyyMMdd_HHmmss')
$base    = Join-Path $PSScriptRoot "HealthCheck_${env:COMPUTERNAME}_$stamp"
$jsonOut = "${base}.json"
$htmlOut = "${base}.html"

#— 1. System Info
Update-Progress "Gathering system info"
$os     = Get-CimInstance Win32_OperatingSystem |
          Select-Object Caption, Version, @{n='LastBoot'; e={$_.LastBootUpTime}}
$uptime = (Get-Date) - $os.LastBoot

#— 2. Windows Updates
Update-Progress "Gathering Windows Update history"
$wuHist = Get-WUHistory | Select-Object Date, Title, Result
Update-Progress "Gathering installed hotfixes"
$hotfix = Get-HotFix      | Select-Object HotFixID, InstalledOn

#— 3. Volumes & Disks
Update-Progress "Gathering volume & disk information"
$volumes = Get-Volume |
           Select-Object DriveLetter, FileSystem,
             @{n='FreeGB';  e={[math]::Round($_.SizeRemaining/1GB,2)}},
             @{n='TotalGB'; e={[math]::Round($_.Size/1GB,2)}}

#— 4. Services
Update-Progress "Gathering service status"
$services = Get-Service |
            Select-Object Name, DisplayName, Status, StartType

#— 5. Installed Applications
Update-Progress "Gathering installed applications"
$uninstallKeys = @(
    'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*',
    'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*'
)
$apps = foreach ($k in $uninstallKeys) {
    Get-ItemProperty $k -ErrorAction SilentlyContinue |
      Where-Object { $_.DisplayName } |
      Select-Object DisplayName, DisplayVersion, Publisher, InstallDate
}

#— 6. Recent Event Log Errors & Warnings (24h)
Update-Progress "Gathering recent event log errors/warnings"
$events = Get-WinEvent -FilterHashtable @{
    LogName   = 'System','Application'
    Level     = 1,2
    StartTime = (Get-Date).AddDays(-1)
} | Select-Object TimeCreated, ProviderName, Id, LevelDisplayName, Message

#— 7. CPU & Memory
Update-Progress "Gathering CPU & memory stats"
$cpu = Get-CimInstance Win32_Processor |
       Select-Object Name, NumberOfCores, NumberOfLogicalProcessors, MaxClockSpeed
$mem = Get-CimInstance Win32_OperatingSystem |
       Select-Object @{n='TotalMB'; e={[math]::Round($_.TotalVisibleMemorySize/1KB,2)}},
                     @{n='FreeMB';  e={[math]::Round($_.FreePhysicalMemory/1KB,2)}}

#— 8. Network Adapters & IP
Update-Progress "Gathering network adapter info"
$net = Get-NetAdapter | Where-Object Status -eq 'Up' |
       Select-Object Name, LinkSpeed, MACAddress,
         @{n='IPv4'; e={(Get-NetIPAddress -InterfaceIndex $_.ifIndex -AddressFamily IPv4).IPAddress -join ','}}

#— 9. Defender Status
Update-Progress "Gathering Windows Defender status"
$def = Get-MpComputerStatus |
       Select-Object AMProductVersion, AMServiceEnabled, RealTimeProtectionEnabled,
                     NISEnabled, QuickScanTime, FullScanTime

#— 10. Pending Reboot
Update-Progress "Checking pending reboot flag"
$pendingReboot = Get-PendingReboot

#— 11–19. Additional Checks
Update-Progress "Gathering SMART/physical disk health"
$physicalDisks = Get-PhysicalDisk |
  Select-Object FriendlyName, MediaType, OperationalStatus, HealthStatus,
                @{n='SizeGB'; e={[math]::Round($_.Size/1GB,2)}}

Update-Progress "Gathering BitLocker status"
$bitlocker = Get-BitLockerVolume |
  Select-Object MountPoint, VolumeStatus, ProtectionStatus,
                @{n='PercentEncrypted';e={$_.EncryptionPercentage}}

Update-Progress "Gathering firewall profiles"
$firewall = Get-NetFirewallProfile |
  Select-Object Name, Enabled, DefaultInboundAction, DefaultOutboundAction

Update-Progress "Gathering scheduled tasks"
$scheduledTasks = Get-ScheduledTask |
  Select-Object TaskName, State, LastRunTime, NextRunTime

Update-Progress "Gathering BIOS/firmware info"
$bios = Get-CimInstance Win32_BIOS |
  Select-Object Manufacturer, SMBIOSBIOSVersion,
                @{n='ReleaseDate';e={[Management.ManagementDateTimeConverter]::ToDateTime($_.ReleaseDate)}}

Update-Progress "Gathering Windows activation status"
$activation = Get-CimInstance SoftwareLicensingProduct `
  -Filter "Name LIKE 'Windows%' and PartialProductKey<>null" |
  Select-Object Name, LicenseStatus

Update-Progress "Gathering time sync status"
$timeSyncRaw = (w32tm /query /status) 2>&1
$timeSync = [PSCustomObject]@{
  Source       = ($timeSyncRaw | Select-String 'Source:'        | % { $_.Line.Split(':',2)[1].Trim() })
  Stratum      = ($timeSyncRaw | Select-String 'Stratum:'       | % { $_.Line.Split(':',2)[1].Trim() })
  PollInterval = ($timeSyncRaw | Select-String 'Poll Interval:' | % { $_.Line.Split(':',2)[1].Trim() })
  LastSync     = ($timeSyncRaw | Select-String 'Last successful sync time:' |
                    % { $_.Line.Split(':',2)[1].Trim() })
}

Update-Progress "Gathering top CPU processes"
$topCPU    = Get-Process | Sort-Object CPU -Descending | Select-Object -First 5 Name, @{n='CPU(s)';e={[math]::Round($_.CPU,2)}}, Id
Update-Progress "Gathering top memory processes"
$topMemory = Get-Process | Sort-Object WorkingSet -Descending | Select-Object -First 5 Name, @{n='MemMB';e={[math]::Round($_.WorkingSet/1MB,2)}}, Id

Update-Progress "Gathering TPM status"
$tpm = Get-Tpm | Select-Object TpmPresent, TpmReady, ManufacturerManufacturerId, ManufacturerVersion

#— 20. Assemble report object
Update-Progress "Assembling report object"
$report = [PSCustomObject]@{
    GeneratedOn      = Get-Date
    Machine          = $env:COMPUTERNAME
    OperatingSystem  = $os
    Uptime           = [string]$uptime
    WindowsUpdates   = @{ History = $wuHist; HotFixes = $hotfix }
    Volumes          = $volumes
    Services         = $services
    InstalledApps    = $apps
    RecentEvents     = $events
    CPU              = $cpu
    Memory           = $mem
    Network          = $net
    Defender         = $def
    PendingReboot    = $pendingReboot
    PhysicalDisks    = $physicalDisks
    BitLocker        = $bitlocker
    FirewallProfiles = $firewall
    ScheduledTasks   = $scheduledTasks
    BIOS             = $bios
    Activation       = $activation
    TimeSync         = $timeSync
    TopCPUProcesses  = $topCPU
    TopMemProcesses  = $topMemory
    TPM              = $tpm
}

#— 21. Export JSON
Update-Progress "Exporting JSON report"
$report | ConvertTo-Json -Depth 6 | Out-File -FilePath $jsonOut -Encoding UTF8

#— 22–23. Build & write HTML
Update-Progress "Building HTML report"
$css = @"
<style>
  body { font-family: Arial, sans-serif; margin: 20px; }
  details { margin-top: 20px; }
  summary { font-size: 1.2em; font-weight: bold; cursor: pointer; outline: none; }
  table { width: 100%; border-collapse: collapse; margin-top: 10px; }
  th, td { border: 1px solid #CCC; padding: 8px; text-align: left; }
  th { background-color: #F0F4F8; }
  tr:nth-child(even) { background-color: #FBFCFD; }
  .flag { font-weight: bold; color: #C00; }
</style>
"@

$html = @"
<html>
<head>
  <meta charset='UTF-8'>
  <title>System Health Check - $env:COMPUTERNAME</title>
  $css
</head>
<body>
  <h1>System Health Check for <em>$env:COMPUTERNAME</em></h1>
  <p>Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')</p>
"@

function Add-Section {
    param($Title, $Data)
    if ($null -eq $Data -or (@($Data).Count -eq 0)) {
        $content = "<p><em>No data returned.</em></p>"
    } else {
        $content = $Data | ConvertTo-HTML -Fragment -As Table
    }
    return @"
<details open>
  <summary>$Title</summary>
  $content
</details>
"@
}

$html += Add-Section "Operating System & Uptime" ([PSCustomObject]@{
    Caption   = $os.Caption
    Version   = $os.Version
    LastBoot  = $os.LastBoot
    Uptime    = $uptime
})
$html += Add-Section "Windows Update History (Last 50)"  ($wuHist | Select-Object -First 50)
$html += Add-Section "Installed Hotfixes"               $hotfix
$html += Add-Section "Volumes & Free Space (GB)"        $volumes
$html += Add-Section "Services Status"                  $services
$html += Add-Section "Installed Applications"           $apps
$html += Add-Section "Recent Event Log Errors/Warnings" $events
$html += Add-Section "CPU"                              $cpu
$html += Add-Section "Memory (MB)"                      $mem
$html += Add-Section "Network Adapters & IPv4"          $net
$html += Add-Section "Windows Defender Status"          $def
$html += Add-Section "Physical Disk Health (SMART)"     $physicalDisks
$html += Add-Section "BitLocker Volume Status"          $bitlocker
$html += Add-Section "Firewall Profiles"                $firewall
$html += Add-Section "Scheduled Tasks"                  $scheduledTasks
$html += Add-Section "BIOS / Firmware Info"             $bios
$html += Add-Section "Windows Activation Status"        $activation
$html += Add-Section "Time Sync Status"                 $timeSync
$html += Add-Section "Top 5 CPU Processes"              $topCPU
$html += Add-Section "Top 5 Memory Processes"           $topMemory
$html += Add-Section "TPM Status"                       $tpm

# Pending reboot
$html += @"
<details open>
  <summary>Pending Reboot?</summary>
  <p class='flag'>$(if ($pendingReboot) { 'YES' } else { 'No' })</p>
</details>
"@

$html += "</body></html>"

Update-Progress "Writing HTML report to disk"
$html | Out-File -FilePath $htmlOut -Encoding UTF8

#— Complete progress bar
Write-Progress -Activity "System Health Check" -Completed

Write-Host "`n✅ Reports generated:`n  JSON: $jsonOut`n  HTML: $htmlOut"
