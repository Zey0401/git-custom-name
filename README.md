# 现代建筑人物志

一个不需要构建、直接双击就能打开的静态网页：收录 17 位近代以来的著名建筑师与 17 座代表作，
支持按地区 / 时期筛选、关键词搜索，以及“画廊”与“年表”两种视图。

## 打开方式

用浏览器打开 `index.html` 即可（无需服务器、无需安装依赖）。

## 目录结构

| 路径 | 说明 |
| --- | --- |
| `index.html` | 页面结构 |
| `assets/styles.css` | 全部样式与响应式规则 |
| `assets/app.js` | 渲染卡片与年表、筛选搜索、详情弹窗 |
| `assets/data.js` | 建筑师资料，改内容只需要动这个文件 |
| `assets/credits.js` | 图片作者与授权信息，由脚本生成 |
| `assets/img/` | 33 张建筑照片（Wikipedia/Wikimedia Commons，长边 1600px） |
| `assets/work-img/` | 70 张建筑详情卡照片（Wikimedia Commons，长边 1400px） |
| `assets/work-drawings/` | 已确认的建筑技术图纸 |
| `assets/work-media.js` | 建筑卡照片、图纸与授权数据，由脚本生成 |
| `assets/og-cover.jpg` | 1200×630 分享封面（微信、社交平台与搜索结果的缩略图） |
| `robots.txt`、`sitemap.xml` | 给搜索引擎看的两份文件，由构建脚本生成 |
| `tools/fetch-images.ps1` | 重新下载图片并生成 `credits.js` |
| `tools/contact-sheet.ps1` | 生成缩略图拼版，用于快速核对配图 |
| `tools/fetch-work-media.ps1` | 下载建筑详情卡照片与技术图纸并生成 `work-media.js` |
| `tools/build-site.ps1` | 写入站点地址、生成 SEO 元数据、预渲染卡片、输出 robots 与 sitemap |
| `tools/make-og-cover.ps1` | 重新生成分享封面 |
| `docs/deploy.md` | 部署到公网并提交搜索引擎收录的完整步骤 |

## 修改内容

编辑 `assets/data.js`，按现有条目格式增删建筑师。每条记录包含姓名、生卒、国别、地区、
流派、时期、代表作、设计理念、简介、关键词、四到五件作品和一到两张照片。

每件作品还可以补充 `photo`、`drawing` 与 `innovation` 字段。前两者使用
`{ src, caption, author, license, filePage }` 对象，用于指定本地建筑照片和技术图纸；
`innovation` 用于说明项目在当时引入的新功能或新概念。未提供本地照片时，详情卡会在浏览器中
通过 Wikipedia / Wikimedia API 查找建筑照片和可选技术图纸，网络失败时回退到建筑师主图。

批量更新 70 张建筑卡媒体资源：

```powershell
powershell -ExecutionPolicy Bypass -File tools/fetch-work-media.ps1
```

手工指定 Commons 文件时，编辑脚本顶部的 `$photoOverrides` 和 `$drawingOverrides`，
然后加 `-Force` 重新抓取。生成后可用 `tools/contact-sheet.ps1` 检查本地图片是否匹配建筑。

新增照片时，把图片放进 `assets/img/`，在 `images[].creditKey` 写上对应的 Commons 文件名，
然后刷新授权信息：

```powershell
powershell -ExecutionPolicy Bypass -File tools/fetch-images.ps1 -SkipDownload
```

不带 `-SkipDownload` 会按 `tools/fetch-images.ps1` 中的清单重新下载全部照片。

## 发布到网上

```powershell
powershell -ExecutionPolicy Bypass -File tools/build-site.ps1 -SiteUrl https://你的域名
```

这一步会把真实网址写进 canonical / og:url / sitemap，并把 17 张卡片预渲染进 HTML
（百度这类不执行 JavaScript 的爬虫也能读到内容）。仓库里已经配好 GitHub Actions，
推到 GitHub 后会自动部署、自动使用真实地址，完整步骤见 [docs/deploy.md](docs/deploy.md)。

## 图片来源

全部照片来自 Wikimedia Commons，遵循各自原始授权协议（CC BY、CC BY-SA、CC0 或公有领域）。
每张图的作者与协议显示在详情弹窗的“图片来源”一栏，数据见 `assets/credits.js`，点击可跳转到原始文件页。
