param(
    [switch]$Force,
    [string]$Only = "",
    [switch]$SkipDrawings,
    [switch]$DrawingsOnly
)

$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"
Add-Type -AssemblyName System.Drawing

$root = Split-Path -Parent $PSScriptRoot
$imageDir = Join-Path $root "assets\work-img"
$drawingDir = Join-Path $root "assets\work-drawings"
$mediaJs = Join-Path $root "assets\work-media.js"
$mediaJson = Join-Path $root "tools\preview\work-media.json"
$utf8 = New-Object System.Text.UTF8Encoding($false)
$userAgent = "dafaf-architect-gallery/1.0 (static educational demo)"

New-Item -ItemType Directory -Force -Path $imageDir | Out-Null
New-Item -ItemType Directory -Force -Path $drawingDir | Out-Null
New-Item -ItemType Directory -Force -Path (Split-Path -Parent $mediaJson) | Out-Null

# Commons 的中文文件名元数据覆盖并不稳定，因此优先以准确的英文建筑名搜索。
$queries = @{
    "wright|罗比住宅"                         = "Robie House Frank Lloyd Wright"
    "wright|约翰逊制蜡公司总部"               = "Johnson Wax Headquarters Frank Lloyd Wright"
    "wright|西塔里埃森"                       = "Taliesin West Frank Lloyd Wright"
    "wright|古根海姆美术馆"                   = "Solomon R. Guggenheim Museum Frank Lloyd Wright"
    "corbusier|萨伏伊别墅"                    = "Villa Savoye Le Corbusier"
    "corbusier|马赛公寓"                      = "Unite d habitation Marseille Le Corbusier"
    "corbusier|昌迪加尔行政中心"              = "Chandigarh Capitol Complex Le Corbusier"
    "corbusier|朗香教堂"                      = "Notre Dame du Haut Ronchamp Le Corbusier"
    "corbusier|柏林联合住宅"                  = "Corbusierhaus Berlin Le Corbusier"
    "mies|巴塞罗那馆"                         = "Barcelona Pavilion Mies van der Rohe"
    "mies|图根哈特住宅"                       = "Villa Tugendhat Mies van der Rohe"
    "mies|范斯沃斯住宅"                       = "Farnsworth House Mies van der Rohe"
    "mies|西格拉姆大厦"                       = "Seagram Building Mies van der Rohe"
    "aalto|帕伊米奥疗养院"                    = "Paimio Sanatorium Alvar Aalto"
    "aalto|维普里图书馆"                      = "Viipuri Library Alvar Aalto"
    "aalto|塞于奈察洛市政厅"                  = "Saynatsalo Town Hall Alvar Aalto"
    "aalto|芬兰地亚大厦"                      = "Finlandia Hall Alvar Aalto"
    "kahn|耶鲁大学美术馆"                     = "Yale University Art Gallery Louis Kahn"
    "kahn|索尔克研究所"                       = "Salk Institute Louis Kahn"
    "kahn|金贝尔美术馆"                       = "Kimbell Art Museum Louis Kahn"
    "kahn|孟加拉国国民议会大厦"               = "Jatiya Sangsad Bhaban Louis Kahn"
    "niemeyer|潘普利亚圣方济各教堂"           = "Church of Saint Francis of Assisi Pampulha Oscar Niemeyer"
    "niemeyer|巴西利亚三权广场"               = "Praca dos Tres Poderes Oscar Niemeyer"
    "niemeyer|巴西利亚大教堂"                 = "Cathedral of Brasilia Oscar Niemeyer"
    "niemeyer|尼泰罗伊当代艺术博物馆"         = "Niteroi Contemporary Art Museum Oscar Niemeyer"
    "tange|广岛和平纪念资料馆"                = "Hiroshima Peace Memorial Museum Kenzo Tange"
    "tange|香川县厅舍"                        = "Kagawa Prefectural Government Hall Kenzo Tange"
    "tange|代代木国立综合体育馆"              = "Yoyogi National Gymnasium Kenzo Tange"
    "tange|东京都厅舍"                        = "Tokyo Metropolitan Government Building Kenzo Tange"
    "pei|美国国家美术馆东馆"                  = "National Gallery of Art East Building I M Pei"
    "pei|卢浮宫金字塔"                        = "Louvre Pyramid I M Pei"
    "pei|香港中银大厦"                        = "Bank of China Tower Hong Kong I M Pei"
    "pei|苏州博物馆"                          = "Suzhou Museum I M Pei"
    "pei|伊斯兰艺术博物馆"                    = "Museum of Islamic Art Doha I M Pei"
    "ando|住吉的长屋"                         = "Row House in Sumiyoshi Tadao Ando"
    "ando|水之教堂"                           = "Church on the Water Tadao Ando"
    "ando|光之教堂"                           = "Church of the Light Tadao Ando"
    "ando|地中美术馆"                         = "Chichu Art Museum Tadao Ando"
    "piano|蓬皮杜中心"                        = "Centre Pompidou Renzo Piano"
    "piano|关西国际机场航站楼"                = "Kansai International Airport Terminal Renzo Piano"
    "piano|贝耶勒基金会美术馆"                = "Fondation Beyeler Renzo Piano"
    "piano|纽约时报大厦"                      = "New York Times Building Renzo Piano"
    "foster|香港汇丰银行总部"                 = "HSBC Building Hong Kong Norman Foster"
    "foster|柏林国会大厦改建"                 = "Reichstag dome Norman Foster"
    "foster|圣玛丽斧街 30 号"                 = "30 St Mary Axe Norman Foster"
    "foster|北京首都国际机场 T3 航站楼"       = "Beijing Capital International Airport Terminal 3 Norman Foster"
    "gehry|盖里自宅"                          = "Gehry Residence Frank Gehry"
    "gehry|维特拉设计博物馆"                  = "Vitra Design Museum Frank Gehry"
    "gehry|毕尔巴鄂古根海姆美术馆"            = "Guggenheim Museum Bilbao Frank Gehry"
    "gehry|华特·迪士尼音乐厅"                 = "Walt Disney Concert Hall Frank Gehry"
    "hadid|维特拉消防站"                      = "Vitra Fire Station Zaha Hadid"
    "hadid|广州大剧院"                        = "Guangzhou Opera House Zaha Hadid"
    "hadid|阿利耶夫文化中心"                  = "Heydar Aliyev Center Zaha Hadid"
    "hadid|东大门设计广场"                    = "Dongdaemun Design Plaza Zaha Hadid"
    "koolhaas|康索现代艺术中心"               = "Kunsthal Rotterdam Rem Koolhaas"
    "koolhaas|西雅图中央图书馆"               = "Seattle Central Library Rem Koolhaas"
    "koolhaas|央视总部大楼"                   = "CCTV Headquarters Rem Koolhaas"
    "koolhaas|台北表演艺术中心"               = "Taipei Performing Arts Center Rem Koolhaas"
    "wangshu|苏州大学文正学院图书馆"          = "Wenzheng College Library Wang Shu"
    "wangshu|宁波美术馆"                      = "Ningbo Art Museum Wang Shu"
    "wangshu|宁波博物馆"                      = "Ningbo Museum Wang Shu"
    "wangshu|中国美术学院象山校区"            = "China Academy of Art Xiangshan Campus Wang Shu"
    "sanaa|金泽 21 世纪美术馆"                = "21st Century Museum of Contemporary Art Kanazawa SANAA"
    "sanaa|纽约新当代艺术博物馆"              = "New Museum New York SANAA"
    "sanaa|劳力士学习中心"                    = "Rolex Learning Center SANAA"
    "sanaa|卢浮宫朗斯分馆"                    = "Louvre Lens SANAA"
    "zumthor|圣本笃教堂"                      = "Saint Benedict Chapel Sumvitg Peter Zumthor"
    "zumthor|瓦尔斯温泉浴场"                  = "Therme Vals Peter Zumthor"
    "zumthor|科隆巴美术馆"                    = "Kolumba Museum Peter Zumthor"
    "zumthor|布鲁德·克劳斯田野教堂"           = "Bruder Klaus Field Chapel Peter Zumthor"
}

# 自动搜索不稳定或选错文件时，在这里填写准确的 Commons 文件标题。
$photoOverrides = @{
    "corbusier|马赛公寓"                  = "File:Le Corbusier, La Cité Radieuse, Marseille.jpg"
    "corbusier|朗香教堂"                  = "File:Notre-Dame du Haut (86743448).jpg"
    "mies|图根哈特住宅"                   = "File:Villa Tugendhat, Brno.jpg"
    "kahn|金贝尔美术馆"                   = "File:Kimbell Art Museum Highsmith.jpg"
    "niemeyer|巴西利亚三权广场"           = "File:Praça dos Três Poderes, vista parcial.jpg"
    "tange|香川县厅舍"                    = "File:Kagawa Prefectural Office Main Building.JPG"
    "tange|东京都厅舍"                    = "File:Tokyo Metropolitan Government Building No.1 - Shinjuku, Tokyo - DSC05442.jpg"
    "pei|苏州博物馆"                      = "File:Suzhou Museum - new buildings.jpg"
    "pei|伊斯兰艺术博物馆"                = "File:Museum of Islamic Art in Doha (3820043632).jpg"
    "ando|住吉的长屋"                     = "File:Azuma house.JPG"
    "ando|地中美术馆"                     = "File:150505 Chichu Art Museum Naoshima Island Kagawa pref Japan01s3.jpg"
    "piano|关西国际机场航站楼"            = "File:関空第1ターミナル全景 - panoramio.jpg"
    "piano|纽约时报大厦"                  = "File:The New York Times Building at sunset, 2021-09-30.jpg"
    "foster|北京首都国际机场 T3 航站楼"    = "File:Beijing capital airport 6.jpg"
    "gehry|盖里自宅"                      = "File:Gehry House - Image01.jpg"
    "hadid|维特拉消防站"                  = "File:Vitra Campus - Hadid Fire Station - full view, blue sky.jpg"
    "hadid|东大门设计广场"                = "File:Dongdaemun Design Plaza at night, Seoul, Korea.jpg"
    "koolhaas|台北表演艺术中心"           = "File:Taipei Performing Arts Center 2023.jpg"
    "wangshu|苏州大学文正学院图书馆"      = "File:Soochow University Library.JPG"
    "wangshu|宁波美术馆"                  = "File:Ningbo Museum of Art, 2014-01 01.JPG"
    "wangshu|中国美术学院象山校区"        = "File:20250722 Zhongguo Guoji Sheji Bowuguan.jpg"
    "sanaa|纽约新当代艺术博物馆"          = "File:New Museum, New York.jpg"
    "sanaa|劳力士学习中心"                = "File:Rolex Learning center.jpg"
    "sanaa|卢浮宫朗斯分馆"                = "File:Louvre-Lens.jpg"
    "zumthor|圣本笃教堂"                  = "File:Sogn Benedetg1.jpg"
    "zumthor|布鲁德·克劳斯田野教堂"       = "File:2017-08-20-mechernich-bruder-klaus-kapelle-07.jpg"
}
$drawingOverrides = @{
    "corbusier|朗香教堂" = "File:Plan chapelle Notre-Dame-du-Haut.svg"
}
$captionOverrides = @{
    "wangshu|苏州大学文正学院图书馆" = "苏州大学文正学院图书馆（苏州大学图书馆参考图）"
}

function Invoke-CurlText([string]$url) {
    $output = & curl.exe --ssl-no-revoke -sS --retry 2 --retry-all-errors --retry-delay 1 `
        --connect-timeout 6 --max-time 20 -A $userAgent $url 2>$null
    if ($LASTEXITCODE -ne 0 -or -not $output) {
        throw "curl failed: $url"
    }
    $text = $output -join "`n"
    if ($text -notmatch '^\s*[\[{]') {
        throw "non-JSON response from Commons"
    }
    return $text
}

function Get-CommonsResponse([string]$query) {
    $encoded = [uri]::EscapeDataString($query)
    $url = "https://commons.wikimedia.org/w/api.php?action=query&format=json" +
        "&generator=search&gsrsearch=$encoded&gsrnamespace=6&gsrlimit=20" +
        "&prop=imageinfo&iiprop=url%7Cextmetadata&iiurlwidth=1400"
    return ((Invoke-CurlText $url) | ConvertFrom-Json)
}

function Get-Pages($response) {
    if (-not $response -or -not $response.query -or -not $response.query.pages) {
        return @()
    }
    return @($response.query.pages.PSObject.Properties.Value | Sort-Object { [int]$_.index })
}

function Get-MetadataValue($metadata, [string]$name) {
    if (-not $metadata -or -not $metadata.$name) { return "" }
    return ([string]$metadata.$name.value -replace "<[^>]+>", " ") -replace "\s+", " "
}

function Test-DrawingTitle([string]$title) {
    return $title -match "(?i)(plan|drawing|section|elevation|diagram|axonometric|blueprint|floor|grundriss|schnitt|ansicht|平面|剖面|立面|图纸|布置图)" -and
        $title -notmatch "(?i)(logo|icon|locator|location map|flag|commons)"
}

function Select-PhotoPage($pages, [string]$query) {
    $candidates = @()
    foreach ($page in $pages) {
        if (-not $page.imageinfo -or -not $page.imageinfo[0].thumburl) { continue }
        if ($page.title -match "(?i)\.(pdf|djvu|svg|webm|ogv|ogg|mp4|tif|tiff)$" -or (Test-DrawingTitle $page.title)) { continue }
        if ($page.title -match "(?i)(portrait|logo|map|flag|poster|design model|architecture model|model of|lamp|video)") { continue }
        $info = $page.imageinfo[0]
        $name = ($page.title -replace "^File:", "")
        $tokens = @(($query -split "\s+") | Where-Object { $_.Length -ge 4 })
        $matches = @($tokens | Where-Object { $name -match [regex]::Escape($_) }).Count
        $index = [int]$page.index
        $score = 120 - ($index * 6) + ($matches * 8)
        if ($info.thumbwidth -and $info.thumbheight) {
            $ratio = [double]$info.thumbwidth / [double]$info.thumbheight
            if ($ratio -ge 0.8 -and $ratio -le 2.4) { $score += 12 }
        }
        if ($name -match "(?i)exterior") { $score += 28 }
        if ($name -match "(?i)(interior|panorama|detail)") { $score -= 24 }
        $candidates += [pscustomobject]@{
            Page  = $page
            Info  = $info
            Score = $score
            Title = $page.title
        }
    }
    return ($candidates | Sort-Object Score -Descending | Select-Object -First 1)
}

function Select-DrawingPage($pages) {
    foreach ($page in $pages) {
        if (-not $page.imageinfo -or -not $page.imageinfo[0].thumburl) { continue }
        if ($page.title -notmatch "(?i)\.(svg|png|jpe?g|webp)$") { continue }
        if (Test-DrawingTitle $page.title) {
            return [pscustomobject]@{ Page = $page; Info = $page.imageinfo[0]; Title = $page.title }
        }
    }
    return $null
}

function Convert-ToJpeg([string]$source, [string]$target) {
    $image = [System.Drawing.Image]::FromFile($source)
    try {
        $maxSide = 1400
        $scale = [Math]::Min(1.0, $maxSide / [Math]::Max($image.Width, $image.Height))
        $width = [Math]::Max(1, [int][Math]::Round($image.Width * $scale))
        $height = [Math]::Max(1, [int][Math]::Round($image.Height * $scale))
        $bitmap = New-Object System.Drawing.Bitmap -ArgumentList $width, $height
        $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
        try {
            $graphics.Clear([System.Drawing.Color]::White)
            $graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
            $graphics.DrawImage($image, 0, 0, $width, $height)
            $codec = [System.Drawing.Imaging.ImageCodecInfo]::GetImageEncoders() |
                Where-Object { $_.MimeType -eq "image/jpeg" } | Select-Object -First 1
            $parameters = New-Object System.Drawing.Imaging.EncoderParameters -ArgumentList 1
            $parameters.Param[0] = New-Object System.Drawing.Imaging.EncoderParameter(
                [System.Drawing.Imaging.Encoder]::Quality, [long]84)
            $bitmap.Save($target, $codec, $parameters)
        }
        finally {
            $graphics.Dispose()
            $bitmap.Dispose()
        }
    }
    finally {
        $image.Dispose()
    }
}

function Download-CommonsImage($candidate, [string]$target, [string]$extension) {
    $temporary = "$target.download"
    if (Test-Path -LiteralPath $temporary) { Remove-Item -LiteralPath $temporary -Force }
    try {
        $urls = @($candidate.Info.thumburl, $candidate.Info.url) | Where-Object { $_ } | Select-Object -Unique
        $downloaded = $false
        foreach ($url in $urls) {
            if (Test-Path -LiteralPath $temporary) { Remove-Item -LiteralPath $temporary -Force }
            & curl.exe --ssl-no-revoke -L -sS --retry 0 `
                --connect-timeout 6 --max-time 25 -A $userAgent -o $temporary $url 2>$null
            if ($LASTEXITCODE -eq 0 -and (Test-Path -LiteralPath $temporary) -and
                (Get-Item -LiteralPath $temporary).Length -gt 5000) {
                $downloaded = $true
                break
            }
        }
        if (-not $downloaded) {
            throw "image download failed: $($candidate.Title)"
        }
        $size = (Get-Item -LiteralPath $temporary).Length
        if ($size -lt 5000) { throw "image too small: $size bytes" }
        if ($extension -eq ".jpg") {
            Convert-ToJpeg $temporary $target
        }
        else {
            Move-Item -LiteralPath $temporary -Destination $target -Force
        }
    }
    finally {
        if (Test-Path -LiteralPath $temporary) {
            Remove-Item -LiteralPath $temporary -Force
        }
    }
}

function Get-Slug([string]$value) {
    $slug = $value.ToLowerInvariant() -replace "[^a-z0-9]+", "-"
    return $slug.Trim("-")
}

function Get-Credit([string]$creditKey) {
    if (-not $creditKey -or -not (Test-Path -LiteralPath (Join-Path $root "assets\credits.js"))) {
        return $null
    }
    $creditsText = [System.IO.File]::ReadAllText((Join-Path $root "assets\credits.js"), $utf8)
    $pattern = '(?m)^\s*' + [regex]::Escape((ConvertTo-Json $creditKey -Compress)) +
        ':\s*\{ author: (.*?), license: (.*?), licenseUrl: (.*?), filePage: (.*?) \},'
    $match = [regex]::Match($creditsText, $pattern)
    if (-not $match.Success) { return $null }
    return [pscustomobject]@{
        Author    = ($match.Groups[1].Value | ConvertFrom-Json)
        License   = ($match.Groups[2].Value | ConvertFrom-Json)
        LicenseUrl = ($match.Groups[3].Value | ConvertFrom-Json)
        FilePage  = ($match.Groups[4].Value | ConvertFrom-Json)
    }
}

$existing = @{}
if (Test-Path -LiteralPath $mediaJson) {
    $jsonText = [System.IO.File]::ReadAllText($mediaJson, $utf8)
    $parsed = $jsonText | ConvertFrom-Json
    foreach ($property in $parsed.PSObject.Properties) {
        $existing[$property.Name] = $property.Value
    }
}
$manifest = @{}
foreach ($key in $existing.Keys) {
    $manifest[$key] = $existing[$key]
}

function Save-Manifest {
    $sorted = [ordered]@{}
    foreach ($key in ($manifest.Keys | Sort-Object)) {
        $sorted[$key] = $manifest[$key]
    }
    $json = $sorted | ConvertTo-Json -Depth 10
    [System.IO.File]::WriteAllText($mediaJson, $json, $utf8)
    [System.IO.File]::WriteAllText($mediaJs, "window.WORK_MEDIA = $json;`r`n", $utf8)
}

$dataText = [System.IO.File]::ReadAllText((Join-Path $root "assets\data.js"), $utf8)
$chunks = $dataText -split '(?m)^\s{2}\{\s*$' | Where-Object { $_ -match 'id:\s*"' }
$failures = @()
$downloaded = 0
$reused = 0
$drawingCount = 0

foreach ($chunk in $chunks) {
    $id = [regex]::Match($chunk, 'id:\s*"([^"]+)"').Groups[1].Value
    $architect = [regex]::Match($chunk, 'name:\s*"([^"]+)"').Groups[1].Value
    $firstImage = [regex]::Match($chunk, 'images:\s*\[\s*\{\s*src:\s*"([^"]+)"[^}]*creditKey:\s*"([^"]+)"').Groups
    $signature = [regex]::Match($chunk, 'signature:\s*\{\s*title:\s*"([^"]+)",\s*en:\s*"([^"]+)",\s*year:\s*(\d+),\s*place:\s*"([^"]+)"\s*\}')
    $works = [regex]::Matches($chunk, '\{ name: "([^"]+)", year: (\d+), place: "([^"]+)"')
    for ($index = 0; $index -lt $works.Count; $index++) {
        $workName = $works[$index].Groups[1].Value
        $key = "$id|$workName"
        if ($Only -and $key -ne $Only) { continue }

        $entry = $existing[$key]
        $isSignature = $workName -eq $signature.Groups[1].Value
        if ($DrawingsOnly) {
            if (-not $entry -or -not $entry.photo -or -not $entry.photo.src) { continue }
            if ($entry.drawingsChecked) {
                $manifest[$key] = $entry
                $reused++
                continue
            }
            try {
                $query = $queries[$key]
                if (-not $query) { throw "missing search query" }
                $drawingQuery = if ($drawingOverrides.ContainsKey($key)) {
                    $drawingOverrides[$key]
                } else {
                    "$query architectural drawing plan section elevation"
                }
                Write-Output ("DRAWING QUERY {0}" -f $key)
                $drawingResponse = Get-CommonsResponse $drawingQuery
                $drawing = Select-DrawingPage (Get-Pages $drawingResponse)
                if ($drawing) {
                    $fileStem = [System.IO.Path]::GetFileNameWithoutExtension($entry.photo.src)
                    $sourceExtension = [System.IO.Path]::GetExtension($drawing.Title).ToLowerInvariant()
                    $targetExtension = if ($sourceExtension -in @(".jpg", ".jpeg")) { ".jpg" } else { ".png" }
                    $drawingTarget = Join-Path $drawingDir ($fileStem + $targetExtension)
                    Download-CommonsImage $drawing $drawingTarget $targetExtension
                    $drawingMeta = $drawing.Info.extmetadata
                    $entry.drawing = [ordered]@{
                        src       = "assets/work-drawings/" + [System.IO.Path]::GetFileName($drawingTarget)
                        caption   = $workName + " 技术图纸"
                        author    = Get-MetadataValue $drawingMeta "Artist"
                        license   = Get-MetadataValue $drawingMeta "LicenseShortName"
                        licenseUrl = Get-MetadataValue $drawingMeta "LicenseUrl"
                        filePage  = $drawing.Info.descriptionurl
                    }
                    if (-not $entry.drawing.author) { $entry.drawing.author = "Wikimedia Commons 贡献者" }
                    if (-not $entry.drawing.license) { $entry.drawing.license = "见原始文件页" }
                    $drawingCount++
                    Write-Output ("DRAWING OK {0} <- {1}" -f $key, $drawing.Title)
                }
                $entry | Add-Member -NotePropertyName drawingsChecked -NotePropertyValue $true -Force
                $manifest[$key] = $entry
                Save-Manifest
            }
            catch {
                $failures += $key
                Write-Output ("DRAWING FAIL {0}: {1}" -f $key, $_.Exception.Message)
            }
            continue
        }
        if ($isSignature -and $firstImage[1].Success) {
            $credit = Get-Credit $firstImage[2].Value
            $manifest[$key] = [ordered]@{
                photo = [ordered]@{
                    src       = $firstImage[1].Value
                    caption   = $workName
                    author    = if ($credit) { $credit.Author } else { "Wikimedia Commons 贡献者" }
                    license   = if ($credit) { $credit.License } else { "见原始文件页" }
                    licenseUrl = if ($credit) { $credit.LicenseUrl } else { "" }
                    filePage  = if ($credit) { $credit.FilePage } else { "" }
                }
                drawing = $null
                drawingsChecked = $false
            }
            $reused++
            Save-Manifest
            continue
        }

        $photoPath = if ($entry -and $entry.photo -and $entry.photo.src) {
            Join-Path $root ($entry.photo.src -replace "/", "\")
        } else { "" }
        if (-not $Force -and $photoPath -and (Test-Path -LiteralPath $photoPath) -and (Get-Item -LiteralPath $photoPath).Length -gt 5000) {
            $manifest[$key] = $entry
            $reused++
            if ($entry.drawing -and $entry.drawing.src) { $drawingCount++ }
            Save-Manifest
            continue
        }

        try {
            $query = $queries[$key]
            if (-not $query) { throw "missing search query" }
            Write-Output ("QUERY {0}" -f $key)
            $response = Get-CommonsResponse ("$query exterior building")
            $pages = Get-Pages $response
            if ($photoOverrides.ContainsKey($key)) {
                $overrideTitle = $photoOverrides[$key]
                $escaped = [uri]::EscapeDataString($overrideTitle)
                $overrideResponse = Invoke-CurlText ("https://commons.wikimedia.org/w/api.php?action=query&format=json" +
                    "&prop=imageinfo&iiprop=url%7Cextmetadata&iiurlwidth=1400&titles=$escaped") | ConvertFrom-Json
                $pages = @(Get-Pages $overrideResponse)
            }
            $photo = Select-PhotoPage $pages $query
            if (-not $photo) {
                $response = Get-CommonsResponse $query
                $pages = Get-Pages $response
                $photo = Select-PhotoPage $pages $query
            }
            if (-not $photo) { throw "no suitable photo result" }

            $slug = Get-Slug $query
            if ($slug.Length -gt 56) { $slug = $slug.Substring(0, 56).Trim("-") }
            $fileStem = "{0}-{1:d2}-{2}" -f $id, ($index + 1), $slug
            $target = Join-Path $imageDir ($fileStem + ".jpg")
            Write-Output ("DOWNLOAD {0} <- {1}" -f $key, $photo.Title)
            Download-CommonsImage $photo $target ".jpg"
            $metadata = $photo.Info.extmetadata
            $photoEntry = [ordered]@{
                src       = "assets/work-img/" + [System.IO.Path]::GetFileName($target)
                caption   = if ($captionOverrides.ContainsKey($key)) { $captionOverrides[$key] } else { $workName }
                author    = Get-MetadataValue $metadata "Artist"
                license   = Get-MetadataValue $metadata "LicenseShortName"
                licenseUrl = Get-MetadataValue $metadata "LicenseUrl"
                filePage  = $photo.Info.descriptionurl
            }
            if (-not $photoEntry.author) { $photoEntry.author = "Wikimedia Commons 贡献者" }
            if (-not $photoEntry.license) { $photoEntry.license = "见原始文件页" }

            $drawingEntry = $null
            if (-not $SkipDrawings) {
                try {
                    $drawingQuery = "$query architectural drawing plan section elevation"
                    if ($drawingOverrides.ContainsKey($key)) {
                        $drawingQuery = $drawingOverrides[$key]
                    }
                    $drawingResponse = Get-CommonsResponse $drawingQuery
                    $drawing = Select-DrawingPage (Get-Pages $drawingResponse)
                    if ($drawing) {
                        $sourceExtension = [System.IO.Path]::GetExtension($drawing.Title).ToLowerInvariant()
                        $targetExtension = if ($sourceExtension -in @(".jpg", ".jpeg")) { ".jpg" } else { ".png" }
                        $drawingTarget = Join-Path $drawingDir ($fileStem + $targetExtension)
                        Download-CommonsImage $drawing $drawingTarget $targetExtension
                        $drawingMeta = $drawing.Info.extmetadata
                        $drawingEntry = [ordered]@{
                            src       = "assets/work-drawings/" + [System.IO.Path]::GetFileName($drawingTarget)
                            caption   = $workName + " 技术图纸"
                            author    = Get-MetadataValue $drawingMeta "Artist"
                            license   = Get-MetadataValue $drawingMeta "LicenseShortName"
                            licenseUrl = Get-MetadataValue $drawingMeta "LicenseUrl"
                            filePage  = $drawing.Info.descriptionurl
                        }
                        if (-not $drawingEntry.author) { $drawingEntry.author = "Wikimedia Commons 贡献者" }
                        if (-not $drawingEntry.license) { $drawingEntry.license = "见原始文件页" }
                        $drawingCount++
                    }
                }
                catch {
                    Write-Output ("DRAWING MISS {0}: {1}" -f $key, $_.Exception.Message)
                }
            }

            $manifest[$key] = [ordered]@{
                photo = $photoEntry
                drawing = $drawingEntry
                drawingsChecked = (-not $SkipDrawings)
            }
            Save-Manifest
            $downloaded++
            Write-Output ("OK {0} <- {1}" -f $key, $photo.Title)
        }
        catch {
            $failures += $key
            Write-Output ("FAIL {0}: {1}" -f $key, $_.Exception.Message)
            if ($entry) { $manifest[$key] = $entry }
            Save-Manifest
        }
    }
}

Save-Manifest

Write-Output ("Media entries: {0}; downloaded: {1}; reused: {2}; drawings: {3}" -f $manifest.Count, $downloaded, $reused, $drawingCount)
if ($failures.Count) {
    Write-Output ("Failures: " + ($failures -join ", "))
    exit 2
}
