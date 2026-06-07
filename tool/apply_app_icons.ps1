Add-Type -AssemblyName System.Drawing

$ErrorActionPreference = 'Stop'

$root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$assetRoot = Join-Path $root 'assets\app_icon'
$iosSrc = Join-Path $assetRoot 'app-icon-ios-1024.png'
$androidSrc = Join-Path $assetRoot 'play-store-icon-512.png'
$adaptiveForegroundSrc = Join-Path $assetRoot 'android-adaptive-foreground-512.png'
$adaptiveBackgroundSrc = Join-Path $assetRoot 'android-adaptive-background-512.png'

$iosDir = Join-Path $root 'ios\Runner\Assets.xcassets\AppIcon.appiconset'
$androidRes = Join-Path $root 'android\app\src\main\res'

function Save-ResizedPng([string]$src, [string]$dest, [int]$size, [bool]$transparent) {
    $dir = Split-Path -Parent $dest
    New-Item -ItemType Directory -Force -Path $dir | Out-Null

    $img = [System.Drawing.Bitmap]::FromFile($src)
    try {
        $out = New-Object System.Drawing.Bitmap $size, $size, ([System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
        $g = [System.Drawing.Graphics]::FromImage($out)
        try {
            $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
            $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
            $g.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
            if ($transparent) {
                $g.Clear([System.Drawing.Color]::Transparent)
            } else {
                $g.Clear([System.Drawing.Color]::Black)
            }
            $g.DrawImage($img, 0, 0, $size, $size)
            $out.Save($dest, [System.Drawing.Imaging.ImageFormat]::Png)
        } finally {
            $g.Dispose()
            $out.Dispose()
        }
    } finally {
        $img.Dispose()
    }
}

$iosIcons = @{
    'Icon-App-20x20@1x.png' = 20
    'Icon-App-20x20@2x.png' = 40
    'Icon-App-20x20@3x.png' = 60
    'Icon-App-29x29@1x.png' = 29
    'Icon-App-29x29@2x.png' = 58
    'Icon-App-29x29@3x.png' = 87
    'Icon-App-40x40@1x.png' = 40
    'Icon-App-40x40@2x.png' = 80
    'Icon-App-40x40@3x.png' = 120
    'Icon-App-60x60@2x.png' = 120
    'Icon-App-60x60@3x.png' = 180
    'Icon-App-76x76@1x.png' = 76
    'Icon-App-76x76@2x.png' = 152
    'Icon-App-83.5x83.5@2x.png' = 167
    'Icon-App-1024x1024@1x.png' = 1024
}

foreach ($entry in $iosIcons.GetEnumerator()) {
    Save-ResizedPng $iosSrc (Join-Path $iosDir $entry.Key) $entry.Value $false
}

$androidIcons = @{
    'mipmap-mdpi\ic_launcher.png' = 48
    'mipmap-mdpi\ic_launcher_round.png' = 48
    'mipmap-hdpi\ic_launcher.png' = 72
    'mipmap-hdpi\ic_launcher_round.png' = 72
    'mipmap-xhdpi\ic_launcher.png' = 96
    'mipmap-xhdpi\ic_launcher_round.png' = 96
    'mipmap-xxhdpi\ic_launcher.png' = 144
    'mipmap-xxhdpi\ic_launcher_round.png' = 144
    'mipmap-xxxhdpi\ic_launcher.png' = 192
    'mipmap-xxxhdpi\ic_launcher_round.png' = 192
}

foreach ($entry in $androidIcons.GetEnumerator()) {
    Save-ResizedPng $androidSrc (Join-Path $androidRes $entry.Key) $entry.Value $false
}

Save-ResizedPng $adaptiveForegroundSrc (Join-Path $androidRes 'drawable-nodpi\ic_launcher_foreground.png') 512 $true
Save-ResizedPng $adaptiveBackgroundSrc (Join-Path $androidRes 'drawable-nodpi\ic_launcher_background.png') 512 $false

Write-Output 'Applied iOS and Android launcher icons.'
