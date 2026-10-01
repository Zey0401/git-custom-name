# 把页面发布到网上并被搜到

要让别人「联网搜到」这个页面，需要两件事，缺一不可：

1. **放到公网**：把文件托管到一个所有人都能访问的地址（部署 / 托管）。
2. **让搜索引擎收录**：把地址提交给 Google、Bing、百度等，等它们抓取并建立索引。

只做第 1 步，别人拿到链接能打开，但搜不到；只做第 2 步没有意义，因为没有可抓取的地址。

---

## 一、发布（选一个即可）

### 方案 A：GitHub Pages（推荐，免费，最省事）

仓库里已经放好了 [.github/workflows/deploy-pages.yml](../.github/workflows/deploy-pages.yml)，
推上去就会自动部署，并且**自动把真实网址写进 SEO 文件**。

1. 在 https://github.com 注册账号，新建一个 **Public** 仓库（例如 `modern-architects`）。
2. 在项目目录里执行（把地址换成你自己的仓库）：

   ```powershell
   cd "D:\Users\泽\Desktop\dafaf"
   git remote add origin https://github.com/你的用户名/modern-architects.git
   git branch -M main
   git push -u origin main
   ```

3. 打开仓库页面 → **Settings → Pages** → Build and deployment → Source 选 **GitHub Actions**。
4. 等 1–2 分钟，仓库 **Actions** 标签页会出现一次成功的运行。
   站点地址形如：`https://你的用户名.github.io/modern-architects/`
5. 之后每次 `git push`，都会自动重新生成 SEO 文件并发布。

> 说明：`actions/configure-pages` 会把当前 Pages 地址传给 `tools/build-site.ps1`，
> 所以 canonical、og:url、sitemap 里的域名永远是对的，不需要手动改。

### 方案 B：Cloudflare Pages（方便绑自己的域名）

1. 在 Cloudflare Pages 里选择「连接到 Git」并选中同一个仓库，
   构建命令留空，输出目录填 `/`。
2. 如果不用 Git 连接，也可以手动上传：**上传前先在本地跑一次**

   ```powershell
   powershell -ExecutionPolicy Bypass -File tools/build-site.ps1 -SiteUrl https://你的域名
   ```

   然后只上传这些内容：`index.html`、`assets/`、`robots.txt`、`sitemap.xml`
   （`tools/`、`docs/`、`.github/`、`README.md` 不需要上传）。

### 方案 C：国内云主机 / 对象存储（阿里云 OSS、腾讯云 COS、EdgeOne Pages 等）

访问速度最好，但要注意：

- 使用**中国大陆节点 + 自己的域名**，域名必须完成 **ICP 备案**，否则会被阻断。
- 备案需要国内主体（个人身份证也可以），通常 1–20 个工作日。
- 备案完成后同样要跑一次 `tools/build-site.ps1 -SiteUrl https://你的域名`，否则 canonical 和 sitemap 还是旧的。

---

## 二、让搜索引擎收录

部署完成后，拿到网址（例如 `https://用户名.github.io/modern-architects/`），然后：

### 1. 先自检

- 浏览器直接打开网址，图片、筛选、弹窗都正常。
- `网址/robots.txt` 能打开，里面有 `Sitemap: ...`。
- `网址/sitemap.xml` 能打开，`<loc>` 是真实网址。
- 查看网页源代码（Ctrl+U），搜索 `og:image` 和 `application/ld+json`，确认存在且域名正确。

### 2. 提交站点地图

| 平台 | 地址 | 要做的操作 |
| --- | --- | --- |
| Google Search Console | search.google.com/search-console | 添加资源 → 验证 → 站点地图 → 提交 `sitemap.xml` |
| Bing Webmaster Tools | bing.com/webmasters | 添加站点 → 导入/验证 → 提交站点地图 |
| 百度搜索资源平台 | ziyuan.baidu.com | 添加站点 → 验证 → 普通收录 → sitemap 提交（也可手动提交单个链接） |
| 360 / 搜狗 | 各自的站长平台 | 同上 |

验证方式选「HTML 标签」时，会给你一段代码，把 `index.html` 顶部预留的三行注释去掉并替换内容即可：

```html
<!-- <meta name="google-site-verification" content="REPLACE_WITH_GOOGLE_CODE"> -->
<!-- <meta name="msvalidate.01" content="REPLACE_WITH_BING_CODE"> -->
<!-- <meta name="baidu-site-verification" content="REPLACE_WITH_BAIDU_CODE"> -->
```

这段在 `<!-- SEO:START -->` 区块之外，重新运行构建脚本也不会被覆盖。

### 3. 加速收录的现实做法

- 新站点通常 **几天到几周** 才会被收录，Google 较快，百度较慢，属正常现象。
- 把链接分享到知乎、豆瓣、小红书、微博、V2EX 等地方，**外部链接**是搜索引擎判断站点价值的重要信号。
- 在百度站长平台用「抓取诊断」手动触发抓取，能看到是否成功。
- 内容更新后，在平台里重新提交一次 sitemap。

---

## 三、换域名 / 换地址之后

每次站点地址变化（自定义域名、改仓库名）都要重新生成一次：

```powershell
powershell -ExecutionPolicy Bypass -File tools/build-site.ps1 -SiteUrl https://新域名
git add -A
git commit -m "update site url"
git push
```

用 GitHub Actions 部署时，这一步是自动完成的。

---

## 四、常见问题

**别人能搜到「现代建筑师」这样的词吗？**
新站点短期内很难排到热门词首页。更现实的是长尾词，例如「流水别墅 建筑师」「光之教堂 设计者」
「王澍 宁波博物馆」。页面里这些名称都已经出现在正文、标题和结构化数据里。

**为什么百度收录比 Google 慢？**
百度对新域名更保守，且对 JavaScript 渲染支持较弱。本项目的卡片内容是**预渲染**进 HTML 的
（`tools/build-site.ps1` 生成），爬虫不执行 JS 也能读到 17 位建筑师和代表作的文字。

**图片版权有问题吗？**
照片全部来自 Wikimedia Commons，页面详情弹窗里标注了作者与授权协议。
若要把这个页面用于商业用途，请逐个核对每个文件的许可条款（尤其是 CC BY-SA 的署名与相同方式共享要求）。

**需要备案吗？**
服务器在中国大陆才需要。GitHub Pages、Cloudflare Pages 在境外，不需要备案，但国内访问速度可能不稳定。

**能用自己的域名吗？**
可以。在托管平台绑定域名后，记得重跑一次 `tools/build-site.ps1 -SiteUrl https://你的域名`。
