Add-Type -AssemblyName System.Drawing

$ErrorActionPreference = 'Stop'

$root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$outDir = Join-Path $root 'assets\app_icon\candidates'
New-Item -ItemType Directory -Force -Path $outDir | Out-Null

function Color-Hex([string]$hex) {
    $h = $hex.TrimStart('#')
    return [System.Drawing.Color]::FromArgb(
        255,
        [Convert]::ToInt32($h.Substring(0, 2), 16),
        [Convert]::ToInt32($h.Substring(2, 2), 16),
        [Convert]::ToInt32($h.Substring(4, 2), 16)
    )
}

function New-Pen([string]$hex, [float]$w) {
    $p = New-Object System.Drawing.Pen (Color-Hex $hex), $w
    $p.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
    $p.EndCap = [System.Drawing.Drawing2D.LineCap]::Round
    $p.LineJoin = [System.Drawing.Drawing2D.LineJoin]::Round
    return $p
}

function New-Canvas([string]$path) {
    $bmp = New-Object System.Drawing.Bitmap 2048, 2048, ([System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $g.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality

    $rect = New-Object System.Drawing.Rectangle 0, 0, 2048, 2048
    $bg = New-Object System.Drawing.Drawing2D.LinearGradientBrush `
        $rect, (Color-Hex '#0D1218'), (Color-Hex '#172027'), 45
    $g.FillRectangle($bg, $rect)
    $bg.Dispose()

    return @{ Bitmap = $bmp; Graphics = $g; Path = $path }
}

function Save-Canvas($canvas) {
    $out = New-Object System.Drawing.Bitmap 1024, 1024, ([System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
    $og = [System.Drawing.Graphics]::FromImage($out)
    $og.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $og.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $og.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
    $og.DrawImage($canvas.Bitmap, 0, 0, 1024, 1024)
    $out.Save($canvas.Path, [System.Drawing.Imaging.ImageFormat]::Png)
    $og.Dispose()
    $out.Dispose()
    $canvas.Graphics.Dispose()
    $canvas.Bitmap.Dispose()
}

function Draw-Star([System.Drawing.Graphics]$g, [float]$cx, [float]$cy, [float]$r, [string]$hex) {
    $brush = New-Object System.Drawing.SolidBrush (Color-Hex $hex)
    $pts = New-Object System.Drawing.PointF[] 8
    for ($i = 0; $i -lt 8; $i++) {
        $radius = $(if (($i % 2) -eq 0) { $r } else { $r * 0.28 })
        $angle = (-90 + 45 * $i) * [Math]::PI / 180
        $pts[$i] = New-Object System.Drawing.PointF `
            ([float]($cx + [Math]::Cos($angle) * $radius)), `
            ([float]($cy + [Math]::Sin($angle) * $radius))
    }
    $g.FillPolygon($brush, $pts)
    $brush.Dispose()
}

function Candidate-Eclipse {
    $c = New-Canvas (Join-Path $outDir 'geo-01-eclipse-dial.png')
    $g = $c.Graphics

    $gold = New-Object System.Drawing.SolidBrush (Color-Hex '#E2C46D')
    $ink = New-Object System.Drawing.SolidBrush (Color-Hex '#0D1218')
    $teal = New-Object System.Drawing.SolidBrush (Color-Hex '#7FBBC0')
    $line = New-Pen '#E2C46D' 18
    $subtle = New-Pen '#2D3F46' 7

    $g.DrawEllipse($subtle, 474, 402, 858, 858)
    $g.FillEllipse($gold, 556, 500, 760, 760)
    $g.FillEllipse($ink, 718, 444, 760, 760)
    $g.DrawLine($line, 521, 1343, 1434, 430)
    $g.FillEllipse($teal, 444, 1302, 56, 56)
    Draw-Star $g 1460 407 54 '#F3E2A2'

    $gold.Dispose()
    $ink.Dispose()
    $teal.Dispose()
    $line.Dispose()
    $subtle.Dispose()
    Save-Canvas $c
}

function Candidate-OrbitNeedle {
    $c = New-Canvas (Join-Path $outDir 'geo-02-orbit-needle.png')
    $g = $c.Graphics

    $goldPen = New-Pen '#E8CB77' 26
    $tealPen = New-Pen '#78B8BD' 13
    $dimPen = New-Pen '#273741' 8
    $goldBrush = New-Object System.Drawing.SolidBrush (Color-Hex '#E8CB77')
    $tealBrush = New-Object System.Drawing.SolidBrush (Color-Hex '#78B8BD')

    $g.DrawArc($dimPen, 398, 398, 1252, 1252, 198, 242)
    $g.DrawArc($tealPen, 500, 318, 1048, 1048, 214, 94)
    $g.DrawArc($goldPen, 514, 514, 1020, 1020, 24, 96)

    $needle = New-Object System.Drawing.Drawing2D.GraphicsPath
    $needle.AddPolygon(@(
        (New-Object System.Drawing.PointF 1024, 398),
        (New-Object System.Drawing.PointF 1094, 1024),
        (New-Object System.Drawing.PointF 1024, 1650),
        (New-Object System.Drawing.PointF 954, 1024)
    ))
    $g.FillPath($goldBrush, $needle)
    $needle.Dispose()

    $g.FillEllipse($tealBrush, 1388, 514, 70, 70)
    Draw-Star $g 654 1350 50 '#F3E2A2'

    $goldPen.Dispose()
    $tealPen.Dispose()
    $dimPen.Dispose()
    $goldBrush.Dispose()
    $tealBrush.Dispose()
    Save-Canvas $c
}

function Candidate-AspectGrid {
    $c = New-Canvas (Join-Path $outDir 'geo-03-aspect-grid.png')
    $g = $c.Graphics

    $tealPen = New-Pen '#79B9BE' 16
    $goldPen = New-Pen '#E4C670' 20
    $dimPen = New-Pen '#2A3941' 8
    $goldBrush = New-Object System.Drawing.SolidBrush (Color-Hex '#E4C670')
    $tealBrush = New-Object System.Drawing.SolidBrush (Color-Hex '#79B9BE')
    $inkBrush = New-Object System.Drawing.SolidBrush (Color-Hex '#111820')

    $g.DrawEllipse($dimPen, 500, 500, 1048, 1048)
    $points = @(
        @(1024, 388),
        @(1466, 1276),
        @(582, 1276)
    )
    $g.DrawLine($tealPen, $points[0][0], $points[0][1], $points[1][0], $points[1][1])
    $g.DrawLine($tealPen, $points[1][0], $points[1][1], $points[2][0], $points[2][1])
    $g.DrawLine($tealPen, $points[2][0], $points[2][1], $points[0][0], $points[0][1])
    $g.DrawLine($goldPen, 1024, 520, 1024, 1520)

    foreach ($p in $points) {
        $g.FillEllipse($goldBrush, $p[0] - 78, $p[1] - 78, 156, 156)
        $g.FillEllipse($inkBrush, $p[0] - 34, $p[1] - 34, 68, 68)
    }
    $g.FillEllipse($tealBrush, 990, 990, 68, 68)

    $tealPen.Dispose()
    $goldPen.Dispose()
    $dimPen.Dispose()
    $goldBrush.Dispose()
    $tealBrush.Dispose()
    $inkBrush.Dispose()
    Save-Canvas $c
}

Candidate-Eclipse
Candidate-OrbitNeedle
Candidate-AspectGrid

Write-Output "Generated geometric candidates in $outDir"
