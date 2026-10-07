<#
.SYNOPSIS
    paste2save v3.0 - Fast, native clipboard image saving for Windows 10/11.
.DESCRIPTION
    Extracts images directly from Windows clipboard and saves them without
    relying on MS Paint, SendKeys, or GUI automation.
    Includes an Auto-Save Watcher mode to automatically capture multiple images
    copied from web browsers or screenshots without intervention.
.PARAMETER Destination
    Target directory where images will be saved. Defaults to location.txt or .\saved_images.
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
    [switch]$Interactive
)

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
if (-not $ScriptDir) { $ScriptDir = Get-Location }
$LocationFile = Join-Path $ScriptDir "location.txt"

function Get-DestinationPath {
    param([string]$ExplicitPath)
    if ($ExplicitPath -and (Test-Path -IsValid $ExplicitPath)) {
        return (Resolve-FullPath $ExplicitPath)
    }
    if (Test-Path $LocationFile) {
        $raw = (Get-Content $LocationFile -Raw).Trim()
        if ($raw -and (Test-Path -IsValid $raw)) {
            return (Resolve-FullPath $raw)
        }
    }
    # Fallback to local saved_images directory
    $defaultDir = Join-Path $ScriptDir "saved_images"
    return $defaultDir
}

function Resolve-FullPath {
    param([string]$Path)
    if ([System.IO.Path]::IsPathRooted($Path)) {
        return $Path
    }
    return [System.IO.Path]::GetFullPath((Join-Path $ScriptDir $Path))
}

function Set-DestinationPath {
    param([string]$NewPath)
    $cleanPath = $NewPath.Trim()
    Set-Content -Path $LocationFile -Value $cleanPath -Encoding UTF8
    Write-Host "[*] Saved location updated to: $cleanPath" -ForegroundColor Green
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
        [System.Console]::Beep(1200, 120)
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
    Write-Host "       paste2save v3.0 - Auto-Save Watcher Active" -ForegroundColor Green
    Write-Host "=======================================================" -ForegroundColor Cyan
    Write-Host "Destination: $TargetDir" -ForegroundColor Yellow
    Write-Host "Naming:      $Strategy | Format: $ImgFormat" -ForegroundColor Gray
    Write-Host "`nInstructions:" -ForegroundColor White
    Write-Host "  1. Browse any webpage (Chrome, Edge, Firefox, etc.)"
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
            # Ignore transient clipboard locks from other applications
        }
    }
}

# Main Execution Flow
$TargetFolder = Get-DestinationPath -ExplicitPath $Destination

if ($Watch) {
    Start-ClipboardWatcher -TargetDir $TargetFolder -Strategy $Naming -ImgFormat $Format -PollMs $IntervalMs
    exit 0
}

# Check if arguments were supplied; if none, show interactive menu
$hasArgs = ($PSBoundParameters.Count -gt 0) -and (-not $Interactive)

if ($hasArgs) {
    $savedPath = Save-ClipboardImage -TargetDir $TargetFolder -Strategy $Naming -ImgFormat $Format
    if ($savedPath -and $OpenFolder) {
        Invoke-Item $TargetFolder
    }
    exit 0
}

# Interactive Menu Mode
Clear-Host
Write-Host "=======================================================" -ForegroundColor Green
Write-Host "            paste2save v3.0 (Windows 10/11)            " -ForegroundColor Cyan
Write-Host "=======================================================" -ForegroundColor Green
Write-Host "Save folder: $TargetFolder" -ForegroundColor Yellow
Write-Host ""
Write-Host "  [1] Save clipboard image (Timestamp: paste_YYYYMMDD_HHMMSS.png)" -ForegroundColor White
Write-Host "  [2] Save clipboard image (Sequential: paste_0001.png)" -ForegroundColor White
Write-Host "  [3] Save clipboard image (Random ID:  x12345.png)" -ForegroundColor White
Write-Host "  [4] Save clipboard image (Overwrite:  x.png)" -ForegroundColor White
Write-Host "  [5] Auto-Save Watcher (Copy images from browser & auto-save)" -ForegroundColor Green
Write-Host "  [6] Change destination folder" -ForegroundColor White
Write-Host "  [7] Open destination folder in Explorer" -ForegroundColor White
Write-Host "  [0] Exit" -ForegroundColor Gray
Write-Host ""
Write-Host "Press 1-7 or wait 5 seconds for default [1]..." -ForegroundColor DarkYellow

$selection = $null
$timeoutSeconds = 5
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
    Write-Host "`nDefaulting to option [1] (Timestamp)..." -ForegroundColor Cyan
    $selection = "1"
} else {
    Write-Host "`nSelected: $selection" -ForegroundColor Cyan
}

switch ($selection) {
    "1" {
        $res = Save-ClipboardImage -TargetDir $TargetFolder -Strategy "timestamp" -ImgFormat $Format
        if ($res -and (Test-Path $TargetFolder)) {
            Start-Sleep -Seconds 1
            Invoke-Item $TargetFolder
        }
    }
    "2" {
        $res = Save-ClipboardImage -TargetDir $TargetFolder -Strategy "sequential" -ImgFormat $Format
        if ($res -and (Test-Path $TargetFolder)) {
            Start-Sleep -Seconds 1
            Invoke-Item $TargetFolder
        }
    }
    "3" {
        $res = Save-ClipboardImage -TargetDir $TargetFolder -Strategy "random" -ImgFormat $Format
        if ($res -and (Test-Path $TargetFolder)) {
            Start-Sleep -Seconds 1
            Invoke-Item $TargetFolder
        }
    }
    "4" {
        $res = Save-ClipboardImage -TargetDir $TargetFolder -Strategy "overwrite" -ImgFormat $Format
        if ($res -and (Test-Path $TargetFolder)) {
            Start-Sleep -Seconds 1
            Invoke-Item $TargetFolder
        }
    }
    "5" {
        Start-ClipboardWatcher -TargetDir $TargetFolder -Strategy "timestamp" -ImgFormat $Format -PollMs $IntervalMs
    }
    "6" {
        $newDir = Read-Host "Enter new folder path"
        if ($newDir) {
            Set-DestinationPath -NewPath $newDir
        }
    }
    "7" {
        if (-not (Test-Path $TargetFolder)) {
            New-Item -ItemType Directory -Path $TargetFolder -Force | Out-Null
        }
        Invoke-Item $TargetFolder
    }
    "0" {
        Write-Host "Goodbye!" -ForegroundColor Gray
    }
    default {
        $res = Save-ClipboardImage -TargetDir $TargetFolder -Strategy "timestamp" -ImgFormat $Format
    }
}
