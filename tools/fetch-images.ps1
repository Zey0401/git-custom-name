param([switch]$SkipDownload)

$ErrorActionPreference = "Stop"
$ProgressPreference = "SilentlyContinue"

$root = Split-Path -Parent $PSScriptRoot
$imgDir = Join-Path $root "assets\img"
New-Item -ItemType Directory -Force -Path $imgDir | Out-Null

$headers = @{
    "User-Agent" = "dafaf-architect-gallery/1.0 (static educational demo)"
}

# 每个建筑对应的 Commons 原始文件；slot 即 assets/img 中的文件名
$plan = @(
    @{ slot = "wright-1";    files = @("File:Fallingwater front.jpg") },
    @{ slot = "wright-2";    files = @("File:Fallingwater with Trees.jpg") },
    @{ slot = "corbusier-1"; files = @("File:Corbusierhaus in Berlin (Unsplash).jpg") },
    @{ slot = "corbusier-2"; files = @("File:Corbusierhaus, Berlin-msu-2021-2366-.jpg") },
    @{ slot = "mies-1";      files = @("File:Barcelona mies v d rohe pavillon weltausstellung1999 03.jpg") },
    @{ slot = "mies-2";      files = @("File:Barcelona Pavilion pool.JPG") },
    @{ slot = "aalto-1";     files = @("File:SaynatsaloTownHall4.jpg") },
    @{ slot = "aalto-2";     files = @("File:Säynätsalo Town Hall council chamber towards back.jpg") },
    @{ slot = "kahn-1";      files = @("File:Salk Institute Highsmith.jpg") },
    @{ slot = "kahn-2";      files = @("File:Salk Institute, La Jolla, San Diego, CA, USA - panoramio (22).jpg") },
    @{ slot = "niemeyer-1";  files = @("File:Cathedral of Brasília exterior 2007.jpg") },
    @{ slot = "niemeyer-2";  files = @("File:Brasilia, Cathedral of Brasilia (15309099334).jpg") },
    @{ slot = "tange-1";     files = @("File:Kokuritsu Yoyogi Kyōgijō 1.jpg") },
    @{ slot = "tange-2";     files = @("File:Yoyogi-National-First-Gymnasium-01.jpg") },
    @{ slot = "pei-1";       files = @("File:Louvre Courtyard, Looking West.jpg") },
    @{ slot = "pei-2";       files = @("File:Cour Napoléon at night - Louvre.jpg") },
    @{ slot = "ando-1";      files = @("File:Church of Light.JPG") },
    @{ slot = "ando-2";      files = @("File:Ibaraki Kasugaoka Church Outside.JPG") },
    @{ slot = "piano-1";     files = @("File:Pompidou Center Paris.jpg") },
    @{ slot = "piano-2";     files = @("File:Pompidou-centre-interior.jpg") },
    @{ slot = "foster-1";    files = @("File:30 St Mary Axe - The Gherkin from Leadenhall St - Nov 2006.jpg") },
    @{ slot = "foster-2";    files = @("File:30 St Mary Axe, 'Gherkin'.JPG") },
    @{ slot = "gehry-1";     files = @("File:Museo Guggenheim -- 2021 -- Bilbao, Euskadi, España.jpg") },
    @{ slot = "gehry-2";     files = @("File:Bilbao - Museo Guggenheim 01.jpg") },
    @{ slot = "hadid-1";     files = @("File:Heydar Aliyev Center, Baku - HyderAliyevCenter8319.jpg") },
    @{ slot = "koolhaas-1";  files = @("File:Beijing CCTV building.jpg") },
    @{ slot = "koolhaas-2";  files = @("File:BeijingCBD CCTV CWT3.jpg") },
    @{ slot = "wangshu-1";   files = @("File:Ningbo Museum.jpg") },
    @{ slot = "wangshu-2";   files = @("File:Ningbo Museum 1.jpg") },
    @{ slot = "sanaa-1";     files = @("File:21st Century Museum of Contemporary Art, Kanazawa011.jpg") },
    @{ slot = "sanaa-2";     files = @("File:21st Century Museum Of Contemporary Art Kanazawa (118930731).jpeg") },
    @{ slot = "zumthor-1";   files = @("File:Therme Vals 2.jpg") },
    @{ slot = "zumthor-2";   files = @("File:2005-08-06-Therme-Vals-Peter-Zumthor 08.jpg") }
)

$used = @{}

if ($SkipDownload) {
    foreach ($entry in $plan) {
        $used[$entry.files[0]] = $entry.slot
    }
    Write-Output "Skipping downloads; only refreshing credits."
}
else {
    foreach ($entry in $plan) {
        $target = Join-Path $imgDir ($entry.slot + ".jpg")
        $done = $false
        foreach ($file in $entry.files) {
            $url = "https://commons.wikimedia.org/wiki/Special:FilePath/" +
                [uri]::EscapeDataString($file) + "?width=1600"
            try {
                Invoke-WebRequest -Uri $url -Headers $headers -OutFile $target -TimeoutSec 90
                $size = (Get-Item $target).Length
                if ($size -lt 5000) { throw "file too small ($size bytes)" }
                Write-Output ("OK   {0,-14} {1,9:N0} bytes  <- {2}" -f $entry.slot, $size, $file)
                $used[$file] = $entry.slot
                $done = $true
                break
            }
            catch {
                Write-Output ("MISS {0,-14} {1}" -f $entry.slot, $file)
            }
        }
        if (-not $done) {
            Write-Output ("FAIL {0,-14} no candidate worked" -f $entry.slot)
        }
    }
}

# 一次性批量取回作者与授权信息
$titles = @($used.Keys)
$credits = @{}

if ($titles.Count -gt 0) {
    $chunks = @()
    for ($i = 0; $i -lt $titles.Count; $i += 40) {
        $end = [Math]::Min($i + 39, $titles.Count - 1)
        $chunks += , ($titles[$i..$end])
    }

    foreach ($chunk in $chunks) {
        $query = ($chunk | ForEach-Object { [uri]::EscapeDataString($_) }) -join "%7C"
        $api = "https://commons.wikimedia.org/w/api.php?action=query&format=json&prop=imageinfo" +
            "&iiprop=extmetadata%7Curl&titles=" + $query

        $resp = $null
        for ($attempt = 1; $attempt -le 3 -and -not $resp; $attempt++) {
            try {
                $resp = Invoke-RestMethod -Uri $api -Headers $headers -TimeoutSec 60
            }
            catch {
                Write-Output ("API retry {0}/3 after rate limit..." -f $attempt)
                Start-Sleep -Seconds 45
            }
        }

        if (-not $resp) {
            Write-Output "API unavailable; credits will fall back to file pages."
            continue
        }

        foreach ($page in $resp.query.pages.PSObject.Properties.Value) {
            if ($page.missing -ne $null -or -not $page.imageinfo) { continue }
            $meta = $page.imageinfo[0].extmetadata
            $artist = ""
            if ($meta.Artist -and $meta.Artist.value) {
                $artist = [System.Net.WebUtility]::HtmlDecode(($meta.Artist.value -replace "<[^>]+>", " ")) -replace "\s+", " "
                $artist = $artist.Trim()
            }
            $license = ""
            $licenseUrl = ""
            if ($meta.LicenseShortName) { $license = [string]$meta.LicenseShortName.value }
            if ($meta.LicenseUrl) { $licenseUrl = [string]$meta.LicenseUrl.value }

            $credits[$page.title] = @{
                author     = $artist
                license    = $license
                licenseUrl = $licenseUrl
                filePage   = "https://commons.wikimedia.org/wiki/" + [uri]::EscapeDataString($page.title)
            }
        }
    }
}

$lines = @("/* 由 tools/fetch-images.ps1 生成：图片作者与授权信息 */", "window.IMAGE_CREDITS = {")
foreach ($title in ($credits.Keys | Sort-Object)) {
    $c = $credits[$title]
    $entry = "  {0}: {{ author: {1}, license: {2}, licenseUrl: {3}, filePage: {4} }}," -f
        (ConvertTo-Json $title -Compress),
        (ConvertTo-Json $c.author -Compress),
        (ConvertTo-Json $c.license -Compress),
        (ConvertTo-Json $c.licenseUrl -Compress),
        (ConvertTo-Json $c.filePage -Compress)
    $lines += $entry
}
$lines += "};"

Set-Content -Path (Join-Path $root "assets\credits.js") -Value $lines -Encoding UTF8
Write-Output ("Credits written for {0} files." -f $credits.Count)
