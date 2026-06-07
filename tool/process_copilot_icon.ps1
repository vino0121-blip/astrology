Add-Type -AssemblyName System.Drawing

$ErrorActionPreference = 'Stop'

$root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$src = 'C:\Users\administrator\Desktop\app\opt\Copilot_20260604_144035.png'
$outDir = Join-Path $root 'assets\app_icon\candidates'
New-Item -ItemType Directory -Force -Path $outDir | Out-Null

$blackOut = Join-Path $outDir 'copilot-neon-black-bg.png'
$transparentOut = Join-Path $outDir 'copilot-neon-transparent.png'

function Clamp([double]$value, [double]$min, [double]$max) {
    if ($value -lt $min) { return $min }
    if ($value -gt $max) { return $max }
    return $value
}

$img = [System.Drawing.Bitmap]::FromFile($src)
try {
    $black = New-Object System.Drawing.Bitmap $img.Width, $img.Height, ([System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
    $alpha = New-Object System.Drawing.Bitmap $img.Width, $img.Height, ([System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
    try {
        for ($y = 0; $y -lt $img.Height; $y++) {
            for ($x = 0; $x -lt $img.Width; $x++) {
                $p = $img.GetPixel($x, $y)
                $r = [double]$p.R
                $g = [double]$p.G
                $b = [double]$p.B
                $luma = 0.2126 * $r + 0.7152 * $g + 0.0722 * $b
                $greenBias = $g - [Math]::Max($r, $b)

                $greenAlpha = Clamp ((($g - 18.0) / 88.0) * 255.0) 0 255
                $whiteAlpha = Clamp ((($luma - 42.0) / 150.0) * 255.0) 0 255
                $biasAlpha = Clamp ((($greenBias - 4.0) / 36.0) * 255.0) 0 255
                $a = [int](Clamp ([Math]::Max($biasAlpha, [Math]::Max($greenAlpha, $whiteAlpha))) 0 255)

                if ($a -lt 10) {
                    $black.SetPixel($x, $y, [System.Drawing.Color]::FromArgb(255, 0, 0, 0))
                    $alpha.SetPixel($x, $y, [System.Drawing.Color]::FromArgb(0, 0, 0, 0))
                } else {
                    $black.SetPixel($x, $y, [System.Drawing.Color]::FromArgb(255, $p.R, $p.G, $p.B))
                    $alpha.SetPixel($x, $y, [System.Drawing.Color]::FromArgb($a, $p.R, $p.G, $p.B))
                }
            }
        }

        $black.Save($blackOut, [System.Drawing.Imaging.ImageFormat]::Png)
        $alpha.Save($transparentOut, [System.Drawing.Imaging.ImageFormat]::Png)
    } finally {
        $black.Dispose()
        $alpha.Dispose()
    }
} finally {
    $img.Dispose()
}

Write-Output $blackOut
Write-Output $transparentOut
