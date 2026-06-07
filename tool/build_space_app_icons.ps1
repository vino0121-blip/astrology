Add-Type -AssemblyName System.Drawing

$ErrorActionPreference = 'Stop'

$root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$assetRoot = Join-Path $root 'assets\app_icon'

$sourceLogo = 'C:\Users\administrator\.codex\generated_images\019e9c84-6c7c-7010-81d8-4d78f73ea99c\ig_0cc3d4aa07707fea016a23ffed065c81918826b88529ef48c2.png'
$sourceSpace = Join-Path $assetRoot 'space-background-bright-stars-1024.png'

$transparentMaster = Join-Path $assetRoot 'hoshimeguri-icon-transparent-1024.png'
$spaceMaster = Join-Path $assetRoot 'hoshimeguri-icon-space-1024.png'
$iosMaster = Join-Path $assetRoot 'app-icon-ios-1024.png'
$playStore = Join-Path $assetRoot 'play-store-icon-512.png'
$adaptiveForeground = Join-Path $assetRoot 'android-adaptive-foreground-512.png'
$adaptiveBackground = Join-Path $assetRoot 'android-adaptive-background-512.png'

function New-SquareBitmap([int]$size) {
    return New-Object System.Drawing.Bitmap $size, $size, ([System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
}

function Resize-ToSquare(
    [System.Drawing.Image]$source,
    [int]$size,
    [bool]$transparent
) {
    $output = New-SquareBitmap $size
    $graphics = [System.Drawing.Graphics]::FromImage($output)
    try {
        $graphics.CompositingMode = $(if ($transparent) {
            [System.Drawing.Drawing2D.CompositingMode]::SourceCopy
        } else {
            [System.Drawing.Drawing2D.CompositingMode]::SourceOver
        })
        $graphics.CompositingQuality = [System.Drawing.Drawing2D.CompositingQuality]::HighQuality
        $graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
        $graphics.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
        $graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
        if ($transparent) {
            $graphics.Clear([System.Drawing.Color]::Transparent)
        } else {
            $graphics.Clear([System.Drawing.Color]::Black)
        }
        $graphics.DrawImage($source, 0, 0, $size, $size)
    } finally {
        $graphics.Dispose()
    }
    return $output
}

function Clamp([double]$value, [double]$min, [double]$max) {
    if ($value -lt $min) { return $min }
    if ($value -gt $max) { return $max }
    return $value
}

function Extract-Foreground([System.Drawing.Bitmap]$source) {
    $output = New-SquareBitmap $source.Width

    for ($y = 0; $y -lt $source.Height; $y++) {
        for ($x = 0; $x -lt $source.Width; $x++) {
            $pixel = $source.GetPixel($x, $y)
            $maxChannel = [Math]::Max($pixel.R, [Math]::Max($pixel.G, $pixel.B))
            $luma = 0.2126 * $pixel.R + 0.7152 * $pixel.G + 0.0722 * $pixel.B

            if ($luma -le 7) {
                $output.SetPixel($x, $y, [System.Drawing.Color]::Transparent)
                continue
            }

            $dx = ($x / [double]$source.Width) - 0.647
            $dy = ($y / [double]$source.Height) - 0.336
            $insideAccent = (($dx * $dx + $dy * $dy) -lt (0.04 * 0.04))
            $isCyan = $insideAccent -and
                ($pixel.G - $pixel.R -gt 12) -and
                ($pixel.B - $pixel.R -gt 12)

            if ($isCyan) {
                $alpha = Clamp (($maxChannel - 4.0) / (215.0 - 4.0)) 0.0 1.0
            } else {
                $alpha = Clamp (($luma - 5.0) / (238.0 - 5.0)) 0.0 1.0
            }

            if (($isCyan -and $maxChannel -ge 165) -or
                (-not $isCyan -and $luma -ge 165)) {
                $alpha = 1.0
            }

            if ($alpha -le 0.04) {
                $output.SetPixel($x, $y, [System.Drawing.Color]::Transparent)
                continue
            }

            if ($isCyan) {
                $red = [int](Clamp ($pixel.R / $alpha) 0 255)
                $green = [int](Clamp ($pixel.G / $alpha) 0 255)
                $blue = [int](Clamp ($pixel.B / $alpha) 0 255)
            } else {
                $neutral = [int](Clamp ($luma / $alpha) 0 248)
                $red = [int](Clamp ($neutral + 5) 0 255)
                $green = [int](Clamp ($neutral + 3) 0 255)
                $blue = $neutral
            }
            $alphaByte = [int](Clamp ($alpha * 255.0) 0 255)

            $output.SetPixel(
                $x,
                $y,
                [System.Drawing.Color]::FromArgb($alphaByte, $red, $green, $blue)
            )
        }
    }

    return $output
}

function Composite(
    [System.Drawing.Bitmap]$background,
    [System.Drawing.Bitmap]$foreground
) {
    $output = New-SquareBitmap $background.Width
    $graphics = [System.Drawing.Graphics]::FromImage($output)
    try {
        $graphics.CompositingMode = [System.Drawing.Drawing2D.CompositingMode]::SourceOver
        $graphics.CompositingQuality = [System.Drawing.Drawing2D.CompositingQuality]::HighQuality
        $graphics.DrawImageUnscaled($background, 0, 0)
        $graphics.DrawImageUnscaled($foreground, 0, 0)
    } finally {
        $graphics.Dispose()
    }
    return $output
}

function Save-AdaptiveForeground(
    [System.Drawing.Bitmap]$source,
    [string]$path
) {
    $size = 512
    $scale = 0.82
    $drawSize = [int]($size * $scale)
    $offset = [int](($size - $drawSize) / 2)
    $output = New-SquareBitmap $size
    $graphics = [System.Drawing.Graphics]::FromImage($output)
    try {
        $graphics.Clear([System.Drawing.Color]::Transparent)
        $graphics.CompositingMode = [System.Drawing.Drawing2D.CompositingMode]::SourceOver
        $graphics.CompositingQuality = [System.Drawing.Drawing2D.CompositingQuality]::HighQuality
        $graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
        $graphics.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
        $graphics.DrawImage($source, $offset, $offset, $drawSize, $drawSize)
        $output.Save($path, [System.Drawing.Imaging.ImageFormat]::Png)
    } finally {
        $graphics.Dispose()
        $output.Dispose()
    }
}

New-Item -ItemType Directory -Force -Path $assetRoot | Out-Null

$logoImage = [System.Drawing.Bitmap]::FromFile($sourceLogo)
$spaceImage = [System.Drawing.Bitmap]::FromFile($sourceSpace)

try {
    $logo1024 = Resize-ToSquare $logoImage 1024 $false
    $space1024 = Resize-ToSquare $spaceImage 1024 $false
    try {
        $foreground1024 = Extract-Foreground $logo1024
        try {
            $composite1024 = Composite $space1024 $foreground1024
            try {
                $foreground1024.Save($transparentMaster, [System.Drawing.Imaging.ImageFormat]::Png)
                $space1024.Save($spaceMaster, [System.Drawing.Imaging.ImageFormat]::Png)
                $composite1024.Save($iosMaster, [System.Drawing.Imaging.ImageFormat]::Png)

                $composite512 = Resize-ToSquare $composite1024 512 $false
                $space512 = Resize-ToSquare $space1024 512 $false
                try {
                    $composite512.Save($playStore, [System.Drawing.Imaging.ImageFormat]::Png)
                    $space512.Save($adaptiveBackground, [System.Drawing.Imaging.ImageFormat]::Png)
                } finally {
                    $composite512.Dispose()
                    $space512.Dispose()
                }

                Save-AdaptiveForeground $foreground1024 $adaptiveForeground
            } finally {
                $composite1024.Dispose()
            }
        } finally {
            $foreground1024.Dispose()
        }
    } finally {
        $logo1024.Dispose()
        $space1024.Dispose()
    }
} finally {
    $logoImage.Dispose()
    $spaceImage.Dispose()
}

Write-Output "Created: $iosMaster"
Write-Output "Created: $transparentMaster"
Write-Output "Created: $adaptiveForeground"
Write-Output "Created: $adaptiveBackground"
