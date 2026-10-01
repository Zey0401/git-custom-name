<#
  部署前运行：把站点地址写进 SEO 元数据、robots.txt、sitemap.xml，
  并把建筑师卡片预渲染进 index.html（不执行 JavaScript 的爬虫也能读到内容）。

  用法：
    powershell -ExecutionPolicy Bypass -File tools/build-site.ps1 -SiteUrl https://你的域名
    powershell -ExecutionPolicy Bypass -File tools/build-site.ps1 -SiteUrl https://用户名.github.io/仓库名/
#>
param(
    [Parameter(Mandatory = $true)][string]$SiteUrl,
    [string]$SiteName = "现代建筑人物志",
    [string]$SiteTitle = "近代以来的建筑师与他们的建筑",
    [string]$SiteDescription = "从流水别墅到 CCTV 总部：17 位近代以来著名建筑师、17 座代表作，可按地区、时期与关键词检索。"
)

$ErrorActionPreference = "Stop"
$utf8 = New-Object System.Text.UTF8Encoding($false)
$root = Split-Path -Parent $PSScriptRoot
$site = $SiteUrl.Trim()
if ($site -notmatch '^https?://') { throw "SiteUrl 需要以 http:// 或 https:// 开头" }
$site = $site.TrimEnd('/')

function Esc([string]$value) {
    if ($null -eq $value) { return "" }
    return $value.Replace("&", "&amp;").Replace("<", "&lt;").Replace(">", "&gt;").Replace('"', "&quot;")
}

function Replace-Block([string]$text, [string]$startTag, [string]$endTag, [string]$inner) {
    $i = $text.IndexOf($startTag)
    if ($i -lt 0) { throw "index.html 里找不到标记：$startTag" }
    $j = $text.IndexOf($endTag, $i)
    if ($j -lt 0) { throw "index.html 里找不到标记：$endTag" }
    $head = $text.Substring(0, $i + $startTag.Length)
    $tail = $text.Substring($j)
    return $head + "`r`n" + $inner + "`r`n" + $tail
}

# ---------- 1. 读取建筑师数据 ----------
$dataPath = Join-Path $root "assets\data.js"
$dataText = [System.IO.File]::ReadAllText($dataPath, $utf8)
$chunks = $dataText -split '(?m)^\s{2}\{\s*$' | Where-Object { $_ -match 'id:\s*"' }

$items = @()
foreach ($chunk in $chunks) {
    $sig = [regex]::Match($chunk, 'signature:\s*\{\s*title:\s*"([^"]+)",\s*en:\s*"([^"]+)",\s*year:\s*(\d+),\s*place:\s*"([^"]+)"\s*\}')
    if (-not $sig.Success) { throw "解析 signature 失败，请检查 data.js 格式" }
    $img = [regex]::Match($chunk, 'images:\s*\[\s*\{\s*src:\s*"([^"]+)"')

    $workList = @()
    foreach ($m in [regex]::Matches($chunk, '\{ name: "([^"]+)", year: (\d+), place: "([^"]+)"')) {
        $workList += ("{0}（{1}，{2}）" -f $m.Groups[1].Value, $m.Groups[2].Value, $m.Groups[3].Value)
    }

    $items += [pscustomobject]@{
        Id        = [regex]::Match($chunk, 'id:\s*"([^"]+)"').Groups[1].Value
        Name      = [regex]::Match($chunk, 'name:\s*"([^"]+)"').Groups[1].Value
        Latin     = [regex]::Match($chunk, 'latin:\s*"([^"]+)"').Groups[1].Value
        Life      = [regex]::Match($chunk, 'life:\s*"([^"]+)"').Groups[1].Value
        Country   = [regex]::Match($chunk, 'country:\s*"([^"]+)"').Groups[1].Value
        Region    = [regex]::Match($chunk, 'region:\s*"([^"]+)"').Groups[1].Value
        Movement  = [regex]::Match($chunk, 'movement:\s*"([^"]+)"').Groups[1].Value
        EraLabel  = [regex]::Match($chunk, 'eraLabel:\s*"([^"]+)"').Groups[1].Value
        Bio       = [regex]::Match($chunk, 'bio:\s*"([^"]+)"').Groups[1].Value
        SigTitle  = $sig.Groups[1].Value
        SigEn     = $sig.Groups[2].Value
        SigYear   = [int]$sig.Groups[3].Value
        SigPlace  = $sig.Groups[4].Value
        Image     = $img.Groups[1].Value
        Works     = ($workList -join "、")
    }
}
if ($items.Count -eq 0) { throw "没有解析到任何建筑师数据" }

# ---------- 2. 预渲染卡片（供爬虫与禁用 JS 的场景读取） ----------
$cardLines = @()
for ($n = 0; $n -lt $items.Count; $n++) {
    $it = $items[$n]
    $loading = if ($n -lt 6) { "" } else { ' loading="lazy"' }
    $cardLines += @"
      <article class="card" id="$($it.Id)">
        <div class="card__media">
          <img class="card__img" src="$(Esc $it.Image)" alt="$(Esc $it.Name)代表作：$(Esc $it.SigTitle)"$loading decoding="async">
          <span class="card__flag">$(Esc $it.Region)</span>
          <span class="card__year">$($it.SigYear)</span>
        </div>
        <div class="card__body">
          <h2 class="card__name">$(Esc $it.Name)</h2>
          <p class="card__latin">$(Esc $it.Latin) · $(Esc $it.Life)</p>
          <p class="card__meta"><span class="tag">$(Esc $it.Movement)</span><span>$(Esc $it.Country) · $(Esc $it.EraLabel)</span></p>
          <p class="card__desc">$(Esc $it.Bio)</p>
          <p class="card__work"><strong>$(Esc $it.SigTitle)</strong><span>$(Esc $it.SigPlace)</span></p>
          <p class="card__works">代表作：$(Esc $it.Works)</p>
        </div>
      </article>
"@
}
$cardsHtml = ($cardLines -join "`r`n")

# ---------- 3. SEO 元数据 ----------
$keywords = @("现代建筑", "建筑师", "建筑作品", "近代建筑史") + ($items | ForEach-Object { $_.Name })
$keywordsLine = ($keywords -join ",")

$listItems = @()
for ($n = 0; $n -lt $items.Count; $n++) {
    $it = $items[$n]
    $listItems += [ordered]@{
        "@type"       = "ListItem"
        "position"    = $n + 1
        "name"        = $it.Name
        "description" = "$($it.SigYear) 年代表作：$($it.SigTitle)（$($it.SigEn)），$($it.SigPlace)"
        "url"         = "$site/#$($it.Id)"
    }
}

$jsonLd = [ordered]@{
    "@context" = "https://schema.org"
    "@graph"   = @(
        [ordered]@{
            "@type"       = "WebSite"
            "@id"         = "$site/#website"
            "url"         = "$site/"
            "name"        = $SiteName
            "description" = $SiteDescription
            "inLanguage"  = "zh-CN"
        },
        [ordered]@{
            "@type"            = "CollectionPage"
            "@id"              = "$site/#webpage"
            "url"              = "$site/"
            "name"             = "$SiteName · $SiteTitle"
            "description"      = $SiteDescription
            "isPartOf"         = [ordered]@{ "@id" = "$site/#website" }
            "primaryImageOfPage" = [ordered]@{
                "@type" = "ImageObject"
                "url"   = "$site/assets/og-cover.jpg"
                "width" = 1200
                "height" = 630
            }
            "mainEntity"       = [ordered]@{ "@id" = "$site/#architect-list" }
        },
        [ordered]@{
            "@type"          = "ItemList"
            "@id"            = "$site/#architect-list"
            "name"           = "近代以来的建筑师与他们的代表作"
            "numberOfItems"  = $items.Count
            "itemListElement" = $listItems
        }
    )
}

$seoLines = @(
    '<meta name="robots" content="index,follow,max-image-preview:large">',
    ('<meta name="keywords" content="{0}">' -f (Esc $keywordsLine)),
    ('<meta name="author" content="{0}">' -f (Esc $SiteName)),
    '<meta name="theme-color" content="#16181c">',
    ('<link rel="canonical" href="{0}/">' -f $site),
    '<meta property="og:type" content="website">',
    ('<meta property="og:site_name" content="{0}">' -f (Esc $SiteName)),
    '<meta property="og:locale" content="zh_CN">',
    ('<meta property="og:title" content="{0}">' -f (Esc $SiteTitle)),
    ('<meta property="og:description" content="{0}">' -f (Esc $SiteDescription)),
    ('<meta property="og:url" content="{0}/">' -f $site),
    ('<meta property="og:image" content="{0}/assets/og-cover.jpg">' -f $site),
    '<meta property="og:image:width" content="1200">',
    '<meta property="og:image:height" content="630">',
    ('<meta property="og:image:alt" content="{0}">' -f (Esc $SiteTitle)),
    '<meta name="twitter:card" content="summary_large_image">',
    ('<meta name="twitter:title" content="{0}">' -f (Esc $SiteTitle)),
    ('<meta name="twitter:description" content="{0}">' -f (Esc $SiteDescription)),
    ('<meta name="twitter:image" content="{0}/assets/og-cover.jpg">' -f $site),
    '<script type="application/ld+json">',
    ($jsonLd | ConvertTo-Json -Depth 10),
    '</script>'
)
$seoHtml = ($seoLines -join "`r`n")

# ---------- 4. 写回 index.html ----------
$htmlPath = Join-Path $root "index.html"
$html = [System.IO.File]::ReadAllText($htmlPath, $utf8)
$html = Replace-Block $html "<!-- SEO:START -->" "<!-- SEO:END -->" $seoHtml
$html = Replace-Block $html "<!-- CARDS:START -->" "<!-- CARDS:END -->" $cardsHtml

# 防呆：标记必须是完整注释，否则生成内容会被浏览器当成注释吞掉
if ($html -match '<!--\s*(SEO|CARDS):START\s*\r?\n') {
    throw "index.html 中的 SEO:START / CARDS:START 标记缺少结尾的 -->，请写成完整注释。"
}
[System.IO.File]::WriteAllText($htmlPath, $html, $utf8)

# ---------- 5. robots.txt 与 sitemap.xml ----------
$robots = @(
    "User-agent: *",
    "Allow: /",
    "",
    "Sitemap: $site/sitemap.xml",
    ""
) -join "`n"
[System.IO.File]::WriteAllText((Join-Path $root "robots.txt"), $robots, $utf8)

$today = (Get-Date).ToString("yyyy-MM-dd")
$sitemap = @(
    '<?xml version="1.0" encoding="UTF-8"?>',
    '<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">',
    "  <url>",
    "    <loc>$site/</loc>",
    "    <lastmod>$today</lastmod>",
    "    <changefreq>monthly</changefreq>",
    "    <priority>1.0</priority>",
    "  </url>",
    "</urlset>",
    ""
) -join "`n"
[System.IO.File]::WriteAllText((Join-Path $root "sitemap.xml"), $sitemap, $utf8)

Write-Output "站点地址 : $site"
Write-Output "建筑师   : $($items.Count) 位"
Write-Output "已更新   : index.html（SEO + 预渲染卡片）、robots.txt、sitemap.xml"
if ($site -match "your-domain|example\.com") {
    Write-Output "提示     : 当前用的是示例域名，正式发布前请换成真实域名重新运行。"
}
