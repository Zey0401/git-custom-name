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
| `tools/fetch-images.ps1` | 重新下载图片并生成 `credits.js` |
| `tools/contact-sheet.ps1` | 生成缩略图拼版，用于快速核对配图 |

## 修改内容

编辑 `assets/data.js`，按现有条目格式增删建筑师。每条记录包含姓名、生卒、国别、地区、
流派、时期、代表作、设计理念、简介、关键词、四到五件作品和一到两张照片。

新增照片时，把图片放进 `assets/img/`，在 `images[].creditKey` 写上对应的 Commons 文件名，
然后刷新授权信息：

```powershell
powershell -ExecutionPolicy Bypass -File tools/fetch-images.ps1 -SkipDownload
```

不带 `-SkipDownload` 会按 `tools/fetch-images.ps1` 中的清单重新下载全部照片。

## 图片来源

全部照片来自 Wikimedia Commons，遵循各自原始授权协议（CC BY、CC BY-SA、CC0 或公有领域）。
每张图的作者与协议显示在详情弹窗的“图片来源”一栏，数据见 `assets/credits.js`，点击可跳转到原始文件页。
