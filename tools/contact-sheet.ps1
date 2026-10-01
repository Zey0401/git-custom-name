param([string]$Dir = "", [string]$Prefix = "sheet")

$ErrorActionPreference = "Stop"
Add-Type -AssemblyName System.Drawing

$root = Split-Path -Parent $PSScriptRoot
$imgDir = if ($Dir) { $Dir } else { Join-Path $root "assets\img" }
$outDir = Join-Path $root "tools\preview"
New-Item -ItemType Directory -Force -Path $outDir | Out-Null

$files = Get-ChildItem -Path $imgDir -Filter *.jpg | Sort-Object Name
$cols = 4
$cellW = 360
$cellH = 260
$imgW = 344
$imgH = 214
$pad = 8
$perSheet = 12

$sheetIndex = 0
for ($start = 0; $start -lt $files.Count; $start += $perSheet) {
    $sheetIndex++
    $slice = $files[$start..([Math]::Min($start + $perSheet - 1, $files.Count - 1))]
    $rows = [int][Math]::Ceiling($slice.Count / $cols)
    $sheetW = $cols * $cellW
    $sheetH = $rows * $cellH
    $bmp = New-Object System.Drawing.Bitmap -ArgumentList $sheetW, $sheetH
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.Clear([System.Drawing.Color]::FromArgb(244, 245, 246))
    $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $font = New-Object System.Drawing.Font("Consolas", 11)
    $brush = [System.Drawing.Brushes]::Black

    for ($i = 0; $i -lt $slice.Count; $i++) {
        $col = $i % $cols
        $row = [int][Math]::Floor($i / $cols)
        $x = $col * $cellW + $pad
        $y = $row * $cellH + $pad

        $img = [System.Drawing.Image]::FromFile($slice[$i].FullName)
        $scale = [Math]::Min($imgW / $img.Width, $imgH / $img.Height)
        $w = [int]($img.Width * $scale)
        $h = [int]($img.Height * $scale)
        $g.DrawImage($img, $x, $y, $w, $h)
        $img.Dispose()

        $g.DrawString($slice[$i].BaseName, $font, $brush, $x, $y + $imgH + 4)
    }

    $g.Dispose()
    $out = Join-Path $outDir ("{0}-{1}.png" -f $Prefix, $sheetIndex)
    $bmp.Save($out, [System.Drawing.Imaging.ImageFormat]::Png)
    $bmp.Dispose()
    Write-Output $out
}
