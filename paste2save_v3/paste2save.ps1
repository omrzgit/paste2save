<#
.SYNOPSIS
    paste2save v3.01 - Fast, native clipboard image saving for Windows 10/11.
.DESCRIPTION
    Extracts images directly from Windows clipboard and saves them without
    relying on MS Paint, SendKeys, or GUI automation.
    Includes an Auto-Save Watcher mode to automatically capture multiple images
    copied from web browsers or screenshots without intervention.
    Includes configurable settings for default action, countdown delay, and save folder.
.PARAMETER Destination
    Target directory where images will be saved. Defaults to config.json, location.txt, or .\saved_images.
.PARAMETER Naming
    Naming strategy: 'timestamp' (default), 'sequential', 'random', or 'overwrite'.
.PARAMETER Format
    Image format: 'png' (default), 'jpg', or 'bmp'.
.PARAMETER Watch
    Monitor clipboard continuously and auto-save new images as they are copied.
.PARAMETER IntervalMs
    Polling interval in milliseconds for Watch mode (default: 500).
.PARAMETER OpenFolder
    Opens the destination folder in Windows Explorer after saving.
.PARAMETER NoSound
    Mutes audible notifications.
.PARAMETER Settings
    Opens the interactive Settings menu directly.
#>

[CmdletBinding()]
param(
    [string]$Destination = "",
    [ValidateSet("timestamp", "sequential", "random", "overwrite")]
    [string]$Naming = "timestamp",
    [ValidateSet("png", "jpg", "jpeg", "bmp")]
    [string]$Format = "png",
    [switch]$Watch,
    [int]$IntervalMs = 500,
    [switch]$OpenFolder,
    [switch]$NoSound,
    [switch]$Interactive,
    [switch]$Settings
)

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
if (-not $ScriptDir) { $ScriptDir = (Get-Location).Path }
$ConfigFile = Join-Path $ScriptDir "config.json"
$LocationFile = Join-Path $ScriptDir "location.txt"

function Resolve-FullPath {
    param([string]$Path)
    if ([string]::IsNullOrWhiteSpace($Path)) { return "" }
    $cleaned = $Path.Trim().Trim('"').Trim("'")
    if ([System.IO.Path]::IsPathRooted($cleaned)) {
        return $cleaned
    }
    return [System.IO.Path]::GetFullPath((Join-Path $ScriptDir $cleaned))
}

function Get-Configuration {
    $defaultConfig = [PSCustomObject]@{
        Destination         = "saved_images"
        DefaultOption       = "1"
        DefaultDelaySeconds = 5
    }

    if (Test-Path $ConfigFile) {
        try {
            $rawJson = Get-Content $ConfigFile -Raw -Encoding UTF8 | ConvertFrom-Json
            if ($rawJson) {
                if ($rawJson.Destination) { $defaultConfig.Destination = [string]$rawJson.Destination }
                if ($rawJson.DefaultOption) { $defaultConfig.DefaultOption = [string]$rawJson.DefaultOption }
                if ($null -ne $rawJson.DefaultDelaySeconds) { $defaultConfig.DefaultDelaySeconds = [int]$rawJson.DefaultDelaySeconds }
                return $defaultConfig
            }
        } catch {
            # Fall back to defaults on parse error
        }
    }

    # Backward compatibility with location.txt
    if (Test-Path $LocationFile) {
        $legacyLoc = (Get-Content $LocationFile -Raw).Trim()
        if ($legacyLoc) {
            $defaultConfig.Destination = $legacyLoc
        }
    }

    Save-Configuration -ConfigObj $defaultConfig
    return $defaultConfig
}

function Save-Configuration {
    param([PSCustomObject]$ConfigObj)
    try {
        $json = $ConfigObj | ConvertTo-Json -Depth 3
        Set-Content -Path $ConfigFile -Value $json -Encoding UTF8 -Force
        # Keep location.txt synced for backwards compatibility
        if ($ConfigObj.Destination) {
            Set-Content -Path $LocationFile -Value $ConfigObj.Destination.Trim() -Encoding UTF8 -Force
        }
    } catch {
        Write-Warning "Could not save configuration: $_"
    }
}

function Get-DestinationPath {
    param([string]$ExplicitPath, [PSCustomObject]$CurrentConfig)
    if ($ExplicitPath -and (Test-Path -IsValid $ExplicitPath)) {
        return (Resolve-FullPath $ExplicitPath)
    }
    if ($CurrentConfig -and $CurrentConfig.Destination) {
        return (Resolve-FullPath $CurrentConfig.Destination)
    }
    return (Resolve-FullPath "saved_images")
}

function Get-OptionDescription {
    param([string]$Opt)
    switch ($Opt) {
        "1" { return "Timestamp save (paste_YYYYMMDD_HHMMSS.png)" }
        "2" { return "Sequential save (paste_0001.png)" }
        "3" { return "Random ID save (x12345.png)" }
        "4" { return "Overwrite save (x.png)" }
        "5" { return "Auto-Save Watcher" }
        default { return "Timestamp save" }
    }
}

function Generate-FileName {
    param(
        [string]$TargetDir,
        [string]$Strategy,
        [string]$Extension
    )
    $ext = $Extension.ToLower().TrimStart('.')
    switch ($Strategy.ToLower()) {
        "random" {
            $rnd = Get-Random -Minimum 1000 -Maximum 99999
            return "x${rnd}.$ext"
        }
        "overwrite" {
            return "x.$ext"
        }
        "sequential" {
            $idx = 1
            while (Test-Path (Join-Path $TargetDir ("paste_{0:D4}.$ext" -f $idx))) {
                $idx++
            }
            return "paste_{0:D4}.$ext" -f $idx
        }
        default {
            $ts = Get-Date -Format "yyyyMMdd_HHmmss"
            $fn = "paste_${ts}.$ext"
            if (Test-Path (Join-Path $TargetDir $fn)) {
                $ms = (Get-Date).Millisecond
                $fn = "paste_${ts}_${ms}.$ext"
            }
            return $fn
        }
    }
}

function Save-ClipboardImage {
    param(
        [string]$TargetDir,
        [string]$Strategy = "timestamp",
        [string]$ImgFormat = "png",
        [switch]$Quiet
    )

    if (-not [System.Windows.Forms.Clipboard]::ContainsImage()) {
        if (-not $Quiet) {
            Write-Host "[!] No image found in clipboard! Copy an image first." -ForegroundColor Yellow
        }
        return $null
    }

    $img = $null
    try {
        $img = [System.Windows.Forms.Clipboard]::GetImage()
    } catch {
        if (-not $Quiet) {
            Write-Host "[!] Failed to read image from clipboard: $_" -ForegroundColor Red
        }
        return $null
    }

    if ($null -eq $img) {
        if (-not $Quiet) {
            Write-Host "[!] Clipboard image data is empty." -ForegroundColor Yellow
        }
        return $null
    }

    if (-not (Test-Path $TargetDir)) {
        New-Item -ItemType Directory -Path $TargetDir -Force | Out-Null
    }

    $filename = Generate-FileName -TargetDir $TargetDir -Strategy $Strategy -Extension $ImgFormat
    $fullPath = Join-Path $TargetDir $filename

    $dotnetFormat = switch ($ImgFormat.ToLower().TrimStart('.')) {
        "jpg"  { [System.Drawing.Imaging.ImageFormat]::Jpeg }
        "jpeg" { [System.Drawing.Imaging.ImageFormat]::Jpeg }
        "bmp"  { [System.Drawing.Imaging.ImageFormat]::Bmp }
        default { [System.Drawing.Imaging.ImageFormat]::Png }
    }

    $width = $img.Width
    $height = $img.Height

    try {
        $img.Save($fullPath, $dotnetFormat)
    } finally {
        $img.Dispose()
    }

    $fileSize = (Get-Item $fullPath).Length
    $sizeKb = [Math]::Round($fileSize / 1KB, 2)

    if (-not $Quiet) {
        Write-Host "[+] Successfully saved:" -ForegroundColor Green
        Write-Host "    File:       $filename" -ForegroundColor Cyan
        Write-Host "    Resolution: ${width}x${height} px" -ForegroundColor Gray
        Write-Host "    Size:       ${sizeKb} KB" -ForegroundColor Gray
        Write-Host "    Path:       $fullPath" -ForegroundColor DarkGray
    }

    if (-not $NoSound) {
        try { [System.Console]::Beep(1200, 120) } catch {}
    }

    return $fullPath
}

function Get-ClipboardImageHash {
    if (-not [System.Windows.Forms.Clipboard]::ContainsImage()) { return $null }
    try {
        $img = [System.Windows.Forms.Clipboard]::GetImage()
        if ($null -eq $img) { return $null }
        $ms = New-Object System.IO.MemoryStream
        $img.Save($ms, [System.Drawing.Imaging.ImageFormat]::Png)
        $bytes = $ms.ToArray()
        $ms.Dispose()
        $img.Dispose()
        $md5 = [System.Security.Cryptography.MD5]::Create()
        $hashBytes = $md5.ComputeHash($bytes)
        $md5.Dispose()
        return [BitConverter]::ToString($hashBytes) -replace '-'
    } catch {
        return $null
    }
}

function Start-ClipboardWatcher {
    param(
        [string]$TargetDir,
        [string]$Strategy = "timestamp",
        [string]$ImgFormat = "png",
        [int]$PollMs = 500
    )

    Write-Host "`n=======================================================" -ForegroundColor Cyan
    Write-Host "       paste2save v3.01 - Auto-Save Watcher Active     " -ForegroundColor Green
    Write-Host "=======================================================" -ForegroundColor Cyan
    Write-Host "Destination: $TargetDir" -ForegroundColor Yellow
    Write-Host "Naming:      $Strategy | Format: $ImgFormat" -ForegroundColor Gray
    Write-Host "`nInstructions:" -ForegroundColor White
    Write-Host "  1. Browse any webpage (Chrome, Edge, Firefox, Brave, etc.)"
    Write-Host "  2. Right-click any image -> 'Copy Image' (or press Win+Shift+S)"
    Write-Host "  3. The image is saved automatically without intervention!"
    Write-Host "`nPress Ctrl+C at any time to exit watcher mode.`n" -ForegroundColor DarkYellow

    $lastHash = Get-ClipboardImageHash
    $count = 0

    while ($true) {
        Start-Sleep -Milliseconds $PollMs
        try {
            if ([System.Windows.Forms.Clipboard]::ContainsImage()) {
                $currentHash = Get-ClipboardImageHash
                if ($currentHash -and ($currentHash -ne $lastHash)) {
                    $lastHash = $currentHash
                    $saved = Save-ClipboardImage -TargetDir $TargetDir -Strategy $Strategy -ImgFormat $ImgFormat -Quiet
                    if ($saved) {
                        $count++
                        $ts = Get-Date -Format "HH:mm:ss"
                        $leaf = Split-Path -Leaf $saved
                        Write-Host "[$ts] [#$count] Auto-saved: $leaf -> $saved" -ForegroundColor Green
                    }
                }
            }
        } catch {
            # Ignore transient clipboard locks
        }
    }
}

function Show-SettingsMenu {
    param([PSCustomObject]$Config)

    while ($true) {
        Clear-Host
        $destResolved = Resolve-FullPath $Config.Destination
        $optDesc = Get-OptionDescription -Opt $Config.DefaultOption

        Write-Host "=======================================================" -ForegroundColor Green
        Write-Host "               paste2save v3.01 - Settings             " -ForegroundColor Cyan
        Write-Host "=======================================================" -ForegroundColor Green
        Write-Host "Current Configuration:" -ForegroundColor White
        Write-Host "  1. Default Action:    Option [$($Config.DefaultOption)] - $optDesc" -ForegroundColor Yellow
        Write-Host "  2. Timeout Delay:     $($Config.DefaultDelaySeconds) second(s)" -ForegroundColor Yellow
        Write-Host "  3. Save Destination:  $($Config.Destination) ($destResolved)" -ForegroundColor Yellow
        Write-Host ""
        Write-Host "Settings Options:" -ForegroundColor White
        Write-Host "  [1] Change Default Action Option (1 to 5)" -ForegroundColor White
        Write-Host "  [2] Change Timeout Delay (0 to 60 seconds)" -ForegroundColor White
        Write-Host "  [3] Change Destination Folder" -ForegroundColor White
        Write-Host "  [4] Reset All to Factory Defaults" -ForegroundColor White
        Write-Host "  [0] Return to Main Menu" -ForegroundColor Gray
        Write-Host ""
        $settingChoice = Read-Host "Select setting to change [0-4]"

        switch ($settingChoice.Trim()) {
            "1" {
                Write-Host "`nSelect which option should execute by default:" -ForegroundColor Cyan
                Write-Host "  [1] Timestamp save (paste_YYYYMMDD_HHMMSS.png)"
                Write-Host "  [2] Sequential save (paste_0001.png)"
                Write-Host "  [3] Random ID save  (x12345.png)"
                Write-Host "  [4] Overwrite save  (x.png)"
                Write-Host "  [5] Auto-Save Watcher (Continuous browser copy)"
                $newOpt = Read-Host "Enter default option number [1-5]"
                if ($newOpt -match '^[1-5]$') {
                    $Config.DefaultOption = $newOpt
                    Save-Configuration -ConfigObj $Config
                    Write-Host "[+] Default action set to Option [$newOpt]." -ForegroundColor Green
                } else {
                    Write-Host "[!] Invalid choice. Must be 1, 2, 3, 4, or 5." -ForegroundColor Red
                }
                Start-Sleep -Milliseconds 1200
            }
            "2" {
                Write-Host "`nSet countdown timeout delay in seconds." -ForegroundColor Cyan
                Write-Host "(0 = run default option immediately; 1-60 = countdown delay)" -ForegroundColor Gray
                $newDelay = Read-Host "Enter delay in seconds [0-60]"
                if ($newDelay -match '^\d+$' -and [int]$newDelay -ge 0 -and [int]$newDelay -le 60) {
                    $Config.DefaultDelaySeconds = [int]$newDelay
                    Save-Configuration -ConfigObj $Config
                    Write-Host "[+] Timeout delay set to $($Config.DefaultDelaySeconds) second(s)." -ForegroundColor Green
                } else {
                    Write-Host "[!] Invalid input. Must be an integer between 0 and 60." -ForegroundColor Red
                }
                Start-Sleep -Milliseconds 1200
            }
            "3" {
                Write-Host "`nCurrent destination: $($Config.Destination)" -ForegroundColor Cyan
                Write-Host "Enter new relative folder (e.g. saved_images) or absolute path (e.g. D:\Pictures):" -ForegroundColor Gray
                $newPath = Read-Host "New folder path"
                if (-not [string]::IsNullOrWhiteSpace($newPath)) {
                    $Config.Destination = $newPath.Trim()
                    Save-Configuration -ConfigObj $Config
                    Write-Host "[+] Destination folder updated to: $($Config.Destination)" -ForegroundColor Green
                } else {
                    Write-Host "[!] Path was empty. Destination unchanged." -ForegroundColor Yellow
                }
                Start-Sleep -Milliseconds 1200
            }
            "4" {
                $Config.DefaultOption = "1"
                $Config.DefaultDelaySeconds = 5
                $Config.Destination = "saved_images"
                Save-Configuration -ConfigObj $Config
                Write-Host "[+] Settings reset to defaults." -ForegroundColor Green
                Start-Sleep -Milliseconds 1200
            }
            "0" {
                return
            }
            default {
                Write-Host "[!] Invalid selection." -ForegroundColor Yellow
                Start-Sleep -Milliseconds 800
            }
        }
    }
}

function Execute-Action {
    param(
        [string]$ActionNumber,
        [string]$TargetFolder,
        [string]$Format,
        [int]$IntervalMs,
        [PSCustomObject]$Config
    )

    switch ($ActionNumber) {
        "1" {
            $res = Save-ClipboardImage -TargetDir $TargetFolder -Strategy "timestamp" -ImgFormat $Format
            if ($res -and (Test-Path $TargetFolder)) {
                Start-Sleep -Milliseconds 800
                Invoke-Item $TargetFolder
            }
        }
        "2" {
            $res = Save-ClipboardImage -TargetDir $TargetFolder -Strategy "sequential" -ImgFormat $Format
            if ($res -and (Test-Path $TargetFolder)) {
                Start-Sleep -Milliseconds 800
                Invoke-Item $TargetFolder
            }
        }
        "3" {
            $res = Save-ClipboardImage -TargetDir $TargetFolder -Strategy "random" -ImgFormat $Format
            if ($res -and (Test-Path $TargetFolder)) {
                Start-Sleep -Milliseconds 800
                Invoke-Item $TargetFolder
            }
        }
        "4" {
            $res = Save-ClipboardImage -TargetDir $TargetFolder -Strategy "overwrite" -ImgFormat $Format
            if ($res -and (Test-Path $TargetFolder)) {
                Start-Sleep -Milliseconds 800
                Invoke-Item $TargetFolder
            }
        }
        "5" {
            Start-ClipboardWatcher -TargetDir $TargetFolder -Strategy "timestamp" -ImgFormat $Format -PollMs $IntervalMs
        }
        "6" {
            if (-not (Test-Path $TargetFolder)) {
                New-Item -ItemType Directory -Path $TargetFolder -Force | Out-Null
            }
            Invoke-Item $TargetFolder
        }
        "7" {
            Show-SettingsMenu -Config $Config
            # Return special code to redisplay main menu
            return "MENU"
        }
        "0" {
            Write-Host "Goodbye!" -ForegroundColor Gray
            exit 0
        }
        default {
            $res = Save-ClipboardImage -TargetDir $TargetFolder -Strategy "timestamp" -ImgFormat $Format
        }
    }
    return "DONE"
}

# --- Execution Entrypoint ---
$AppConfig = Get-Configuration
$TargetFolder = Get-DestinationPath -ExplicitPath $Destination -CurrentConfig $AppConfig

if ($Settings) {
    Show-SettingsMenu -Config $AppConfig
    exit 0
}

if ($Watch) {
    Start-ClipboardWatcher -TargetDir $TargetFolder -Strategy $Naming -ImgFormat $Format -PollMs $IntervalMs
    exit 0
}

# CLI direct execution if parameters were supplied
$hasArgs = ($PSBoundParameters.Count -gt 0) -and (-not $Interactive)

if ($hasArgs) {
    $savedPath = Save-ClipboardImage -TargetDir $TargetFolder -Strategy $Naming -ImgFormat $Format
    if ($savedPath -and $OpenFolder) {
        Invoke-Item $TargetFolder
    }
    exit 0
}

# --- Interactive Main Menu Loop ---
while ($true) {
    $TargetFolder = Get-DestinationPath -ExplicitPath $Destination -CurrentConfig $AppConfig
    $defaultOpt = if ($AppConfig.DefaultOption) { $AppConfig.DefaultOption } else { "1" }
    $defaultDesc = Get-OptionDescription -Opt $defaultOpt
    $timeoutSeconds = [int]$AppConfig.DefaultDelaySeconds

    Clear-Host
    Write-Host "=======================================================" -ForegroundColor Green
    Write-Host "           paste2save v3.01 (Windows 10/11)            " -ForegroundColor Cyan
    Write-Host "=======================================================" -ForegroundColor Green
    Write-Host "Save folder:    $TargetFolder" -ForegroundColor Yellow
    Write-Host "Default Action: Option [$defaultOpt] - $defaultDesc" -ForegroundColor Gray
    Write-Host "Default Delay:  $timeoutSeconds second(s)" -ForegroundColor Gray
    Write-Host ""
    Write-Host "Main Menu:" -ForegroundColor White
    Write-Host "  [1] Save clipboard image (Timestamp: paste_YYYYMMDD_HHMMSS.png)" -ForegroundColor White
    Write-Host "  [2] Save clipboard image (Sequential: paste_0001.png)" -ForegroundColor White
    Write-Host "  [3] Save clipboard image (Random ID:  x12345.png)" -ForegroundColor White
    Write-Host "  [4] Save clipboard image (Overwrite:  x.png)" -ForegroundColor White
    Write-Host "  [5] Auto-Save Watcher (Copy images from browser & auto-save)" -ForegroundColor Green
    Write-Host "  [6] Open destination folder in Explorer" -ForegroundColor White
    Write-Host "  [7] Settings (Change default option, timeout delay, & folder)" -ForegroundColor Yellow
    Write-Host "  [0] Exit" -ForegroundColor Gray
    Write-Host ""

    $selection = $null

    if ($timeoutSeconds -le 0) {
        Write-Host "Timeout delay is 0s. Defaulting immediately to Option [$defaultOpt]..." -ForegroundColor DarkYellow
        Write-Host "(Press any key within 1s to cancel and open menu...)" -ForegroundColor DarkGray
        $sw = [System.Diagnostics.Stopwatch]::StartNew()
        while ($sw.Elapsed.TotalSeconds -lt 1.0) {
            if ([System.Console]::KeyAvailable) {
                $key = [System.Console]::ReadKey($true)
                $selection = $key.KeyChar.ToString()
                break
            }
            Start-Sleep -Milliseconds 50
        }
        if (-not $selection) {
            $selection = $defaultOpt
        }
    } else {
        Write-Host "Press 1-7 (0 to exit) or wait $timeoutSeconds seconds for default [$defaultOpt]..." -ForegroundColor DarkYellow
        $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
        while ($stopwatch.Elapsed.TotalSeconds -lt $timeoutSeconds) {
            if ([System.Console]::KeyAvailable) {
                $key = [System.Console]::ReadKey($true)
                $selection = $key.KeyChar.ToString()
                break
            }
            Start-Sleep -Milliseconds 100
        }
        if (-not $selection -or $selection -eq "") {
            Write-Host "`nDefaulting to Option [$defaultOpt] ($defaultDesc)..." -ForegroundColor Cyan
            $selection = $defaultOpt
        } else {
            Write-Host "`nSelected: $selection" -ForegroundColor Cyan
        }
    }

    $status = Execute-Action -ActionNumber $selection -TargetFolder $TargetFolder -Format $Format -IntervalMs $IntervalMs -Config $AppConfig
    if ($status -eq "DONE") {
        break
    }
    # If MENU was returned (from settings), loop continues and refreshes the main menu
}
