# 生成 1200x630 的社交分享封面：assets/og-cover.jpg
$ErrorActionPreference = "Stop"
Add-Type -AssemblyName System.Drawing

$root = Split-Path -Parent $PSScriptRoot
$source = Join-Path $root "assets\img\pei-1.jpg"
$target = Join-Path $root "assets\og-cover.jpg"

$W = 1200
$H = 630

$src = [System.Drawing.Image]::FromFile($source)
$bmp = New-Object System.Drawing.Bitmap -ArgumentList $W, $H
$g = [System.Drawing.Graphics]::FromImage($bmp)
$g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
$g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$g.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAliasGridFit

# 背景：按比例裁切填满
$scale = [Math]::Max($W / $src.Width, $H / $src.Height)
$dw = [int]($src.Width * $scale)
$dh = [int]($src.Height * $scale)
$dx = [int](($W - $dw) / 2)
$dy = [int](($H - $dh) / 2)
$g.DrawImage($src, $dx, $dy, $dw, $dh)
$src.Dispose()

# 左侧压暗，保证文字可读
$rect = New-Object System.Drawing.Rectangle -ArgumentList 0, 0, $W, $H
$grad = New-Object System.Drawing.Drawing2D.LinearGradientBrush(
    $rect,
    [System.Drawing.Color]::FromArgb(235, 9, 11, 14),
    [System.Drawing.Color]::FromArgb(20, 9, 11, 14),
    [System.Drawing.Drawing2D.LinearGradientMode]::Horizontal)
$g.FillRectangle($grad, $rect)
$grad.Dispose()

$accent = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(196, 68, 42))
$g.FillRectangle($accent, 84, 84, 9, 46)

$brandFont = New-Object System.Drawing.Font -ArgumentList @("Microsoft YaHei", [single]20, [System.Drawing.FontStyle]::Bold)
$brandBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(235, 255, 255, 255))
$g.DrawString("现代建筑人物志", $brandFont, $brandBrush, 110, 88)

$titleFont = New-Object System.Drawing.Font -ArgumentList @("Microsoft YaHei", [single]46, [System.Drawing.FontStyle]::Bold)
$titleBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::White)
$g.DrawString("近代以来的建筑师", $titleFont, $titleBrush, 80, 250)
$g.DrawString("与他们的建筑", $titleFont, $titleBrush, 80, 322)

$subFont = New-Object System.Drawing.Font -ArgumentList @("Microsoft YaHei", [single]21, [System.Drawing.FontStyle]::Regular)
$subBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(225, 255, 255, 255))
$g.DrawString("17 位建筑师 · 17 座代表作 · 1850 — 今天", $subFont, $subBrush, 84, 420)

$noteFont = New-Object System.Drawing.Font -ArgumentList @("Microsoft YaHei", [single]16, [System.Drawing.FontStyle]::Regular)
$noteBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(205, 255, 255, 255))
$g.DrawString("从流水别墅到 CCTV 总部，可按地区、时期与关键词检索", $noteFont, $noteBrush, 84, 480)

$g.Dispose()

$codec = [System.Drawing.Imaging.ImageCodecInfo]::GetImageEncoders() | Where-Object { $_.MimeType -eq "image/jpeg" }
$params = New-Object System.Drawing.Imaging.EncoderParameters(1)
$params.Param[0] = New-Object System.Drawing.Imaging.EncoderParameter(
    [System.Drawing.Imaging.Encoder]::Quality, 88L)
$bmp.Save($target, $codec, $params)
$bmp.Dispose()
$params.Dispose()

Write-Output ("written: {0} ({1:N0} bytes)" -f $target, (Get-Item $target).Length)
