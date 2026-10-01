(function () {
  "use strict";

  var DATA = window.ARCHITECTS || [];
  var CREDITS = window.IMAGE_CREDITS || {};
  var WORK_MEDIA = window.WORK_MEDIA || {};
  var state = { region: "all", era: "all", query: "", view: "grid" };
  var mediaCache = {};
  var mediaRequestToken = 0;

  var WORK_INNOVATIONS = {
    "罗比住宅": "连续窗带、悬挑屋面和围绕壁炉组织的自由平面，把草原住宅推向成熟。",
    "约翰逊制蜡公司总部": "树状混凝土柱与柱顶光缝，把结构本身变成采光装置。",
    "西塔里埃森": "用本地石块与帆布篷架连接建筑和沙漠环境，并形成学徒制建筑学校的原型。",
    "古根海姆美术馆": "螺旋坡道把观展流线变成连续空间，改变美术馆从楼层到路径的组织方式。",
    "萨伏伊别墅": "底层架空、自由平面、横向长窗、自由立面和屋顶花园五要素同时实现。",
    "马赛公寓": "垂直花园城市概念，把住宅、商业、教育和屋顶公共活动叠入单体。",
    "昌迪加尔行政中心": "用遮阳格栅、巨型混凝土构架和气候适应性布局重塑热带行政建筑。",
    "朗香教堂": "塑性曲面屋盖、非矩形平面与彩窗光效，转向更具雕塑感的宗教空间。",
    "柏林联合住宅": "借助预制混凝土网格与模度体系，把联合住宅原型进行工业化和标准化。",
    "巴塞罗那馆": "自由平面、独立墙体和连续材料表面，把室内外空间组织为流动序列。",
    "图根哈特住宅": "钢框架与大面积玻璃带来无柱起居层，住宅顺应坡地景观展开。",
    "范斯沃斯住宅": "钢框架、玻璃幕墙与浮动平台把最小住宅推到原型化程度。",
    "西格拉姆大厦": "塔楼后退形成公共广场，并用青铜幕墙统一结构与立面。",
    "帕伊米奥疗养院": "按病人姿势设计天花、洗手盆与房间朝向，把人体尺度系统化。",
    "维普里图书馆": "波浪形木天花同时解决声学与采光，形成地域化现代主义语言。",
    "塞于奈察洛市政厅": "下沉庭院与木构议会厅，把纪念性公共建筑转译到芬兰木材与砖传统。",
    "芬兰地亚大厦": "沿湖展开的变形体量协调音乐、会议与公共流线。",
    "耶鲁大学美术馆": "四面体混凝土楼板与圆柱形楼梯暴露结构，把服务核心变成空间主题。",
    "索尔克研究所": "对称实验室庭园与中央水渠把科研空间组织成仪式性轴线。",
    "金贝尔美术馆": "摆线拱顶与铝制反射板提供可控天光，建立美术馆照明的系统模型。",
    "孟加拉国国民议会大厦": "议会厅、清真寺、办公与水池组合成纪念性几何群，回应孟加拉气候与文化。",
    "潘普利亚圣方济各教堂": "自由曲线混凝土壳体与独立钟塔把现代主义变成地方性雕塑。",
    "巴西利亚三权广场": "用对称广场和对比形体组织国家权力象征，形成现代首都轴线。",
    "巴西利亚大教堂": "十六瓣抛物线结构把屋顶与采光玻璃系统一体化。",
    "尼泰罗伊当代艺术博物馆": "悬崖上的碗形几何与环形坡道，让建筑成为景观路径。",
    "广岛和平纪念资料馆": "架空柱廊与水平体量把纪念物、城市轴线和公共空间连成整体。",
    "香川县厅舍": "清水混凝土与木构表达结合，发展日本公共建筑的现代本土语汇。",
    "代代木国立综合体育馆": "悬索屋盖与两根巨柱形成动态结构，开创大跨度体育建筑形态。",
    "东京都厅舍": "双塔与广场构成后现代纪念性，重新诠释城市行政中心。",
    "美国国家美术馆东馆": "三角与菱形几何解决梯形基地，并建立新旧馆轴线联系。",
    "卢浮宫金字塔": "玻璃金字塔作为地下入口枢纽，把历史庭院转为现代交通核心。",
    "香港中银大厦": "三角柱分叉结构随高度收束，兼顾结构效率与地标轮廓。",
    "苏州博物馆": "用白墙灰边、几何屋顶与庭院重构江南园林空间。",
    "伊斯兰艺术博物馆": "立方体旋转堆叠与穹顶光斑，将伊斯兰几何转译为现代空间。",
    "住吉的长屋": "中庭切进窄长住宅，把自然与气候重新引入城市生活。",
    "水之教堂": "十字水池、滑动玻璃和湖畔景观组成动态仪式空间。",
    "光之教堂": "混凝土墙上十字形光缝把结构、照明和宗教符号合一。",
    "地中美术馆": "建筑埋入地下，以几何开口引入随时间变化的天光。",
    "蓬皮杜中心": "结构、交通和设备外置，室内获得无柱灵活空间。",
    "关西国际机场航站楼": "超长曲面屋顶与空气流动系统结合，适应大型机场运营。",
    "贝耶勒基金会美术馆": "出挑屋面控制天光，展厅可向花园开启。",
    "纽约时报大厦": "陶瓷遮阳棒幕墙调节采光与能耗，回应城市街道尺度。",
    "香港汇丰银行总部": "悬挂结构和模块化构件允许楼层更替，首层释放公共空间。",
    "柏林国会大厦改建": "玻璃穹顶、自然采光和热回收系统把历史建筑改造成低碳议会。",
    "圣玛丽斧街 30 号": "螺旋通风井与三角幕墙减少能耗，形成自然通风高层模型。",
    "北京首都国际机场 T3 航站楼": "连续曲面屋顶和大型屋面采光系统整合超大规模航站楼流线。",
    "盖里自宅": "以工业材料和未完工姿态打破郊区住宅，成为解构主义起点。",
    "维特拉设计博物馆": "白色雕塑体块与交错天光构成博物馆展示路径。",
    "毕尔巴鄂古根海姆美术馆": "钛板曲面和数字建模推动复杂几何进入实际建造。",
    "华特·迪士尼音乐厅": "不锈钢曲面与葡萄园式音乐厅结合，形成城市雕塑与声学空间。",
    "维特拉消防站": "倾斜墙体与锐角开口把建筑变成动态路径。",
    "广州大剧院": "多个曲面体量包裹剧场空间，创造地景化公共建筑。",
    "阿利耶夫文化中心": "屋面和广场连续曲面取消体量边界，建立无障碍公共地景。",
    "东大门设计广场": "无明确正背的曲面外壳连接历史城门与城市广场。",
    "康索现代艺术中心": "坡道串联不同标高展厅，形成可漫游的剖面与流线。",
    "西雅图中央图书馆": "将藏书、会议与观景分层堆叠，公共大厅形成连续起伏空间。",
    "央视总部大楼": "双塔顶部折转相连，形成循环体量，挑战高层建筑类型。",
    "台北表演艺术中心": "三个剧场从球体穿出并共享后台，使舞台空间可组合。",
    "苏州大学文正学院图书馆": "坡地平台和瓦片材料把校园建筑嵌入湖岸地形。",
    "宁波美术馆": "老码头仓库改造与回收砖瓦，延续城市工业记忆。",
    "宁波博物馆": "瓦爿墙和斜切体量将旧城材料与博物馆叙事结合。",
    "中国美术学院象山校区": "校园以院落、廊道和坡屋顶组织，把建造工艺引入教学。",
    "金泽 21 世纪美术馆": "圆形无正面平面与玻璃边界，使建筑成为公园的一部分。",
    "纽约新当代艺术博物馆": "错位堆叠的白色盒体与铝网表皮打破传统塔楼形象。",
    "劳力士学习中心": "起伏连续楼板与玻璃围合创造地形化学习景观。",
    "卢浮宫朗斯分馆": "极简长向体量与时间轴线展览结合，回应矿场遗迹。",
    "圣本笃教堂": "木瓦椭圆体量以单一空间收束乡村礼拜仪式。",
    "瓦尔斯温泉浴场": "片麻岩、天光、水声和温度共同组成材料体验。",
    "科隆巴美术馆": "在废墟与旧教堂之上用砖墙孔隙引入天光。",
    "布鲁德·克劳斯田野教堂": "树枝模板烧制后形成炭化墙体和窄天窗。"
  };

  var grid = document.getElementById("grid");
  var timelineList = document.getElementById("timeline-list");
  var gallery = document.getElementById("gallery");
  var timeline = document.getElementById("timeline");
  var result = document.getElementById("result");
  var resetBtn = document.getElementById("reset");
  var searchInput = document.getElementById("search");
  var modal = document.getElementById("modal");
  var modalContent = document.getElementById("modal-content");
  var lastFocus = null;
  var currentItem = null;
  var currentWorkIndex = -1;

  function esc(value) {
    return String(value == null ? "" : value)
      .replace(/&/g, "&amp;")
      .replace(/</g, "&lt;")
      .replace(/>/g, "&gt;")
      .replace(/"/g, "&quot;");
  }

  function norm(value) {
    return String(value == null ? "" : value).toLowerCase().replace(/\s+/g, "");
  }

  function searchText(item) {
    var parts = [item.name, item.latin, item.country, item.region, item.movement,
      item.signature.title, item.signature.en, item.signature.place,
      item.signature.year, item.keywords.join("")];
    item.works.forEach(function (w) {
      parts.push(w.name, w.place, w.year);
    });
    return norm(parts.join("|"));
  }

  function matches(item) {
    if (state.region !== "all" && item.region !== state.region) return false;
    if (state.era !== "all" && item.era !== state.era) return false;
    if (state.query && searchText(item).indexOf(norm(state.query)) === -1) return false;
    return true;
  }

  function imageMarkup(image, alt, className, eager) {
    return '<img class="' + className + '" src="' + esc(image.src) + '" alt="' + esc(alt) + '"' +
      (eager ? "" : ' loading="lazy"') + ' decoding="async">';
  }

  function cardMarkup(item, index) {
    var hero = item.images[0];
    return '' +
      '<button class="card" type="button" data-id="' + esc(item.id) + '" aria-label="查看 ' + esc(item.name) + ' 详情">' +
        '<span class="card__media">' +
          imageMarkup(hero, item.name + "代表作：" + item.signature.title, "card__img", index < 6) +
          '<span class="card__flag">' + esc(item.region) + '</span>' +
          '<span class="card__year">' + esc(item.signature.year) + '</span>' +
        '</span>' +
        '<span class="card__body">' +
          '<span class="card__name">' + esc(item.name) + '</span>' +
          '<span class="card__latin">' + esc(item.latin) + '</span>' +
          '<span class="card__meta"><span class="tag">' + esc(item.movement) + '</span>' +
            '<span>' + esc(item.country) + ' · ' + esc(item.life) + '</span></span>' +
          '<span class="card__desc">' + esc(item.bio) + '</span>' +
          '<span class="card__work"><strong>' + esc(item.signature.title) + '</strong>' +
            '<span>' + esc(item.signature.place) + '</span></span>' +
        '</span>' +
      '</button>';
  }

  function timelineMarkup(items) {
    var groups = [];
    var index = {};
    items.slice().sort(function (a, b) {
      return a.signature.year - b.signature.year;
    }).forEach(function (item) {
      var decade = Math.floor(item.signature.year / 10) * 10;
      if (!index[decade]) {
        index[decade] = { decade: decade, items: [] };
        groups.push(index[decade]);
      }
      index[decade].items.push(item);
    });

    return groups.map(function (group) {
      var rows = group.items.map(function (item) {
        return '' +
          '<button class="tl-item" type="button" data-id="' + esc(item.id) + '">' +
            '<span class="tl-item__media">' +
              imageMarkup(item.images[0], item.signature.title, "tl-img") +
            '</span>' +
            '<span class="tl-item__title"><strong>' + esc(item.name) + '</strong>' +
              '<span>' + esc(item.country) + ' · ' + esc(item.movement) + '</span></span>' +
            '<span class="tl-item__work"><strong>' + esc(item.signature.title) + '</strong>' +
              esc(item.signature.year) + ' · ' + esc(item.signature.place) + '</span>' +
          '</button>';
      }).join("");
      return '<div class="tl-decade">' +
        '<div class="tl-decade__label">' + group.decade + ' 年代</div>' +
        '<div class="tl-decade__items">' + rows + '</div>' +
        '</div>';
    }).join("");
  }

  function applyImages(root) {
    root.querySelectorAll("img").forEach(function (img) {
      img.addEventListener("error", function () {
        var holder = img.parentNode;
        if (!holder || holder.querySelector(".image-fallback")) return;
        img.remove();
        var box = document.createElement("div");
        box.className = "image-fallback";
        box.textContent = "图片缺失";
        holder.appendChild(box);
      });
    });
  }

  // 筛选条：内容超出宽度时标记为可滑动，并给出边缘渐隐提示
  function updateScrollHints() {
    document.querySelectorAll(".chips").forEach(function (strip) {
      var maxScroll = Math.max(0, strip.scrollWidth - strip.clientWidth);
      var scrollable = maxScroll > 4;
      var progress = maxScroll ? strip.scrollLeft / maxScroll : 0;
      strip.classList.toggle("is-scrollable", scrollable);
      strip.classList.toggle("at-start", strip.scrollLeft <= 4);
      strip.classList.toggle("at-end", strip.scrollLeft >= maxScroll - 4);
      var rail = strip.nextElementSibling;
      if (rail && rail.classList.contains("chips__rail")) {
        rail.style.setProperty("--scroll-progress", Math.max(0, Math.min(1, progress)));
      }
    });
  }

  function ensureScrollRail(strip) {
    var rail = strip.nextElementSibling;
    if (rail && rail.classList.contains("chips__rail")) return rail;
    rail = document.createElement("div");
    rail.className = "chips__rail";
    rail.setAttribute("aria-hidden", "true");
    rail.innerHTML = '<span class="chips__dot"></span>';
    strip.parentNode.insertBefore(rail, strip.nextSibling);
    return rail;
  }

  // 鼠标用户也可以拖动筛选条；触屏继续使用浏览器原生惯性滚动
  function enableDragScroll(strip) {
    if (!window.PointerEvent) return;
    var rail = ensureScrollRail(strip);
    var active = false;
    var moved = false;
    var suppressClick = false;
    var startX = 0;
    var startLeft = 0;
    var pointerId = -1;

    strip.addEventListener("pointerdown", function (event) {
      if (event.pointerType !== "mouse" || event.button !== 0) return;
      if (strip.scrollWidth - strip.clientWidth <= 4) return;
      active = true;
      moved = false;
      pointerId = event.pointerId;
      startX = event.clientX;
      startLeft = strip.scrollLeft;
    });

    strip.addEventListener("pointermove", function (event) {
      if (!active || event.pointerId !== pointerId) return;
      var distance = event.clientX - startX;
      if (Math.abs(distance) > 4 && !moved) {
        moved = true;
        strip.classList.add("is-dragging");
        if (strip.setPointerCapture) strip.setPointerCapture(pointerId);
      }
      if (!moved) return;
      event.preventDefault();
      strip.scrollLeft = startLeft - distance;
      updateScrollHints();
    });

    function endDrag(event) {
      if (!active || event.pointerId !== pointerId) return;
      active = false;
      strip.classList.remove("is-dragging");
      if (moved && strip.releasePointerCapture) {
        try { strip.releasePointerCapture(pointerId); } catch (error) {}
      }
      suppressClick = moved;
      window.setTimeout(function () { suppressClick = false; }, 0);
      updateScrollHints();
    }

    strip.addEventListener("pointerup", endDrag);
    strip.addEventListener("pointercancel", endDrag);
    strip.addEventListener("click", function (event) {
      if (!suppressClick) return;
      event.preventDefault();
      event.stopPropagation();
    }, true);

    var railActive = false;
    var railPointerId = -1;

    function setRailPosition(event) {
      var maxScroll = Math.max(0, strip.scrollWidth - strip.clientWidth);
      if (!maxScroll) return;
      var rect = rail.getBoundingClientRect();
      var radius = 7;
      var usableWidth = Math.max(1, rect.width - radius * 2);
      var ratio = (event.clientX - rect.left - radius) / usableWidth;
      strip.scrollLeft = Math.max(0, Math.min(1, ratio)) * maxScroll;
      updateScrollHints();
    }

    rail.addEventListener("pointerdown", function (event) {
      if (strip.scrollWidth - strip.clientWidth <= 4) return;
      event.preventDefault();
      railActive = true;
      railPointerId = event.pointerId;
      strip.classList.add("is-dragging");
      if (rail.setPointerCapture) rail.setPointerCapture(railPointerId);
      setRailPosition(event);
    });

    rail.addEventListener("pointermove", function (event) {
      if (!railActive || event.pointerId !== railPointerId) return;
      event.preventDefault();
      setRailPosition(event);
    });

    function endRailDrag(event) {
      if (!railActive || event.pointerId !== railPointerId) return;
      railActive = false;
      strip.classList.remove("is-dragging");
      if (rail.releasePointerCapture) {
        try { rail.releasePointerCapture(railPointerId); } catch (error) {}
      }
      updateScrollHints();
    }

    rail.addEventListener("pointerup", endRailDrag);
    rail.addEventListener("pointercancel", endRailDrag);
  }

  function render() {
    var items = DATA.filter(matches);
    grid.innerHTML = items.map(cardMarkup).join("");
    timelineList.innerHTML = items.length
      ? timelineMarkup(items)
      : "";

    if (!items.length) {
      grid.innerHTML = '<div class="empty"><strong>没有匹配的建筑师</strong>' +
        '试着换一个关键词，或清除地区与时期筛选。</div>';
    }

    var hasFilter = state.region !== "all" || state.era !== "all" || state.query;
    resetBtn.hidden = !hasFilter;
    result.textContent = hasFilter
      ? "显示 " + items.length + " / " + DATA.length + " 位建筑师"
      : "共 " + DATA.length + " 位建筑师 · " + DATA.length + " 座代表作 · 按代表作落成年份编排";

    document.getElementById("stat-architects").textContent = DATA.length;
    document.getElementById("stat-works").textContent = DATA.length;
    applyImages(grid);
    applyImages(timelineList);
    updateScrollHints();
  }

  function creditMarkup(item) {
    return item.images.map(function (image, i) {
      var info = CREDITS[image.creditKey] || {};
      var author = info.author ? esc(info.author) : "Wikimedia Commons 贡献者";
      var license = info.license ? esc(info.license) : "见原始文件页";
      var page = info.filePage || ("https://commons.wikimedia.org/wiki/" + encodeURIComponent(image.creditKey || ""));
      return '<li>图 ' + (i + 1) + '：' + esc(image.caption) + ' — ' +
        author + '，<a href="' + esc(page) + '" target="_blank" rel="noopener">' + license + '</a></li>';
    }).join("");
  }

  function sortedWorks(item) {
    return item.works.slice().sort(function (a, b) {
      return a.year - b.year;
    });
  }

  function workCardMarkup(item, work, index) {
    var isSignature = work.name === item.signature.title;
    var number = (index + 1 < 10 ? "0" : "") + (index + 1);
    return '<li class="work-card' + (isSignature ? " is-signature" : "") + '">' +
      '<button class="work-card__button" type="button" data-work-index="' + index + '" aria-label="查看建筑：' + esc(work.name) + '">' +
        '<span class="work-card__top">' +
          '<span class="work-card__number">' + number + '</span>' +
          (isSignature ? '<span class="work-card__badge">本页主图</span>' : '') +
          '<span class="work-card__year">' + esc(work.year) + '</span>' +
        '</span>' +
        '<strong class="work-card__name">' + esc(work.name) + '</strong>' +
        '<span class="work-card__place">' + esc(work.place) + '</span>' +
        '<span class="work-card__desc">' + esc(work.desc || "") + '</span>' +
        '<span class="work-card__cta">查看建筑细节 ' +
          '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true">' +
            '<path d="M5 12h14"></path><path d="m13 6 6 6-6 6"></path>' +
          '</svg>' +
        '</span>' +
      '</button>' +
    '</li>';
  }

  function workMiniMarkup(work, index, activeIndex) {
    return '<button class="work-mini' + (index === activeIndex ? " is-active" : "") + '" type="button" data-work-index="' + index + '"' +
      (index === activeIndex ? ' aria-current="true"' : '') + '>' +
      '<span>' + esc(work.year) + '</span>' +
      '<strong>' + esc(work.name) + '</strong>' +
    '</button>';
  }

  function workKey(item, work) {
    return item.id + "|" + work.name;
  }

  function apiUrl(host, params) {
    return "https://" + host + "/w/api.php?" + new URLSearchParams(params).toString();
  }

  function fetchJson(url, signal) {
    return fetch(url, { signal: signal, credentials: "omit" }).then(function (response) {
      if (!response.ok) throw new Error("HTTP " + response.status);
      return response.json();
    });
  }

  function responsePages(response) {
    if (!response || !response.query || !response.query.pages) return [];
    return Object.keys(response.query.pages).map(function (id) {
      return response.query.pages[id];
    });
  }

  function bestWikiPage(response, work) {
    var pages = responsePages(response).filter(function (page) {
      return !page.missing;
    });
    pages.sort(function (a, b) {
      var aExact = a.title === work.name ? 2 : (a.title.indexOf(work.name) > -1 ? 1 : 0);
      var bExact = b.title === work.name ? 2 : (b.title.indexOf(work.name) > -1 ? 1 : 0);
      var aMedia = a.thumbnail || a.pageimage ? 1 : 0;
      var bMedia = b.thumbnail || b.pageimage ? 1 : 0;
      return (bExact - aExact) || (bMedia - aMedia);
    });
    return pages[0] || null;
  }

  function cleanMetadata(value) {
    if (!value) return "";
    return String(value).replace(/<[^>]+>/g, " ").replace(/\s+/g, " ").trim();
  }

  function fileTitle(name) {
    if (!name) return "";
    return /^File:/i.test(name) ? name : "File:" + name;
  }

  function imageInfoMap(response) {
    var result = {};
    responsePages(response).forEach(function (page) {
      if (!page.imageinfo || !page.imageinfo[0]) return;
      var info = page.imageinfo[0];
      var meta = info.extmetadata || {};
      result[page.title] = {
        src: info.thumburl || info.url || "",
        author: cleanMetadata(meta.Artist && meta.Artist.value),
        license: cleanMetadata(meta.LicenseShortName && meta.LicenseShortName.value),
        licenseUrl: cleanMetadata(meta.LicenseUrl && meta.LicenseUrl.value),
        filePage: info.descriptionurl || ("https://commons.wikimedia.org/wiki/" + encodeURIComponent(page.title))
      };
    });
    return result;
  }

  function isDrawingTitle(title) {
    var pattern = /(plan|drawing|section|elevation|diagram|axonometric|blueprint|floor|grundriss|schnitt|ansicht|平面|剖面|立面|图纸|布置图)/i;
    var blocked = /(logo|icon|locator|map|flag|commons)/i;
    return /\.(svg|png|jpe?g|webp)$/i.test(title) && pattern.test(title) && !blocked.test(title);
  }

  function drawingTitle(page) {
    var images = page && page.images ? page.images : [];
    for (var i = 0; i < images.length; i++) {
      var title = images[i].title || "";
      if (isDrawingTitle(title)) return title;
    }
    return "";
  }

  function mediaFromImageInfo(page) {
    if (!page || !page.imageinfo || !page.imageinfo[0]) return null;
    var info = page.imageinfo[0];
    var meta = info.extmetadata || {};
    return {
      src: info.thumburl || info.url || "",
      caption: page.title.replace(/^File:/i, ""),
      author: cleanMetadata(meta.Artist && meta.Artist.value) || "Wikimedia Commons 贡献者",
      license: cleanMetadata(meta.LicenseShortName && meta.LicenseShortName.value) || "见原始文件页",
      licenseUrl: cleanMetadata(meta.LicenseUrl && meta.LicenseUrl.value),
      filePage: info.descriptionurl || ("https://commons.wikimedia.org/wiki/" + encodeURIComponent(page.title))
    };
  }

  function resolveCommonsMedia(item, work, signal) {
    var searchUrl = apiUrl("commons.wikimedia.org", {
      action: "query",
      format: "json",
      origin: "*",
      generator: "search",
      gsrsearch: work.name + " " + item.name + " " + work.place,
      gsrnamespace: "6",
      gsrlimit: "30",
      prop: "imageinfo",
      iiprop: "url|extmetadata",
      iiurlwidth: "1400"
    });
    return fetchJson(searchUrl, signal).then(function (response) {
      var pages = responsePages(response).filter(function (page) {
        return page.imageinfo && page.imageinfo[0] && !/\.pdf$/i.test(page.title);
      });
      var drawingPage = pages.filter(function (page) { return isDrawingTitle(page.title); })[0];
      var photoPage = pages.filter(function (page) {
        return !isDrawingTitle(page.title) && !/(portrait|architect|logo|locator|map|flag)/i.test(page.title);
      })[0];
      if (!photoPage && drawingPage) photoPage = drawingPage;
      if (!photoPage) throw new Error("未找到建筑照片");
      var drawing = drawingPage && drawingPage !== photoPage ? mediaFromImageInfo(drawingPage) : null;
      return {
        photo: mediaFromImageInfo(photoPage),
        drawing: drawing
      };
    });
  }

  function localPhoto(item, work) {
    var image = item.images[0];
    var credit = CREDITS[image.creditKey] || {};
    return {
      src: image.src,
      caption: work.name === item.signature.title ? "本页主图" : "建筑师主图 · 建筑照片暂未加载",
      author: credit.author || "Wikimedia Commons 贡献者",
      license: credit.license || "见原始文件页",
      filePage: credit.filePage || ("https://commons.wikimedia.org/wiki/" + encodeURIComponent(image.creditKey || "")),
      fallback: work.name !== item.signature.title
    };
  }

  function resolveWorkMedia(item, work, signal) {
    if (WORK_MEDIA[workKey(item, work)]) {
      return Promise.resolve(WORK_MEDIA[workKey(item, work)]);
    }
    if (work.photo) {
      return Promise.resolve({ photo: work.photo, drawing: work.drawing || null });
    }
    if (work.name === item.signature.title) {
      return Promise.resolve({ photo: localPhoto(item, work) });
    }

    var exactUrl = apiUrl("zh.wikipedia.org", {
      action: "query",
      format: "json",
      origin: "*",
      redirects: "1",
      titles: work.name,
      prop: "pageimages|images",
      piprop: "thumbnail|name",
      pithumbsize: "1400",
      imlimit: "100"
    });

    return fetchJson(exactUrl, signal).then(function (exactResponse) {
      var page = bestWikiPage(exactResponse, work);
      if (page && (page.thumbnail || page.pageimage)) return page;
      var searchUrl = apiUrl("zh.wikipedia.org", {
        action: "query",
        format: "json",
        origin: "*",
        generator: "search",
        gsrsearch: work.name + " " + item.name,
        gsrnamespace: "0",
        gsrlimit: "5",
        prop: "pageimages|images",
        piprop: "thumbnail|name",
        pithumbsize: "1400",
        imlimit: "100"
      });
      return fetchJson(searchUrl, signal).then(function (searchResponse) {
        return bestWikiPage(searchResponse, work);
      });
    }).then(function (page) {
      if (!page || !page.thumbnail) throw new Error("未找到建筑照片");
      var photoFile = fileTitle(page.pageimage);
      var drawingFile = drawingTitle(page);
      var fileTitles = [photoFile, drawingFile].filter(Boolean);
      if (!fileTitles.length) {
        return {
          photo: {
            src: page.thumbnail.source,
            caption: page.title,
            author: "Wikimedia Commons 贡献者",
            license: "见原始文件页",
            filePage: "https://zh.wikipedia.org/wiki/" + encodeURIComponent(page.title)
          }
        };
      }
      var infoUrl = apiUrl("commons.wikimedia.org", {
        action: "query",
        format: "json",
        origin: "*",
        prop: "imageinfo",
        iiprop: "url|extmetadata",
        iiurlwidth: "1400",
        titles: fileTitles.join("|")
      });
      return fetchJson(infoUrl, signal).then(function (infoResponse) {
        var infoMap = imageInfoMap(infoResponse);
        var photoInfo = infoMap[photoFile] || {};
        var drawingInfo = drawingFile ? (infoMap[drawingFile] || {}) : null;
        return {
          photo: {
            src: photoInfo.src || page.thumbnail.source,
            caption: work.name,
            author: photoInfo.author || "Wikimedia Commons 贡献者",
            license: photoInfo.license || "见原始文件页",
            filePage: photoInfo.filePage || ("https://zh.wikipedia.org/wiki/" + encodeURIComponent(page.title))
          },
          drawing: drawingInfo && drawingInfo.src ? {
            src: drawingInfo.src,
            caption: work.name + " 技术图纸",
            author: drawingInfo.author || "Wikimedia Commons 贡献者",
            license: drawingInfo.license || "见原始文件页",
            filePage: drawingInfo.filePage
          } : null
        };
      });
    }).catch(function (error) {
      if (signal && signal.aborted) throw error;
      return resolveCommonsMedia(item, work, signal);
    });
  }

  function mediaFigureMarkup(media, className, alt, fallbackText) {
    if (!media || !media.src) {
      return '<div class="work-view__media-empty">' + esc(fallbackText) + '</div>';
    }
    var credit = [media.author, media.license].filter(Boolean).join("，") || "Wikimedia Commons";
    return '<figure class="' + className + '">' +
      '<a href="' + esc(media.filePage || "#") + '" target="_blank" rel="noopener">' +
        imageMarkup(media, alt, className + "-img", true) +
      '</a>' +
      '<figcaption><strong>' + esc(media.caption || alt) + '</strong>' +
        '<a href="' + esc(media.filePage || "#") + '" target="_blank" rel="noopener">' + esc(credit) + '</a>' +
      '</figcaption>' +
    '</figure>';
  }

  function renderWorkMedia(item, work, media) {
    var holder = modal.querySelector("[data-work-media]");
    if (!holder) return;
    holder.classList.remove("is-loading");
    holder.innerHTML =
      mediaFigureMarkup(media.photo, "work-view__photo", work.name + " 建筑照片", "建筑照片暂不可用") +
      (media.drawing ? mediaFigureMarkup(media.drawing, "work-view__drawing", work.name + " 技术图纸", "技术图纸暂不可用") : "");
    applyImages(holder);
  }

  function loadWorkMedia(item, work) {
    var holder = modal.querySelector("[data-work-media]");
    if (!holder) return;
    var key = workKey(item, work);
    if (WORK_MEDIA[key]) {
      mediaCache[key] = WORK_MEDIA[key];
      renderWorkMedia(item, work, mediaCache[key]);
      return;
    }
    if (mediaCache[key]) {
      renderWorkMedia(item, work, mediaCache[key]);
      return;
    }

    var token = ++mediaRequestToken;
    holder.classList.add("is-loading");
    holder.innerHTML =
      mediaFigureMarkup(localPhoto(item, work), "work-view__photo", work.name + " 建筑照片", "建筑照片暂不可用") +
      '<div class="work-view__media-status">正在查找该建筑的照片与技术图纸…</div>';
    var controller = window.AbortController ? new AbortController() : null;
    var timeout = window.setTimeout(function () {
      if (controller) controller.abort();
    }, 6000);

    resolveWorkMedia(item, work, controller ? controller.signal : undefined).then(function (media) {
      window.clearTimeout(timeout);
      mediaCache[key] = media;
      if (token === mediaRequestToken) renderWorkMedia(item, work, media);
    }).catch(function () {
      window.clearTimeout(timeout);
      if (token !== mediaRequestToken) return;
      var fallback = { photo: localPhoto(item, work) };
      mediaCache[key] = fallback;
      renderWorkMedia(item, work, fallback);
    });
  }

  function workDetailMarkup(item, activeIndex) {
    var works = sortedWorks(item);
    var work = works[activeIndex];
    if (!work) return "";

    var isSignature = work.name === item.signature.title;
    var search = "https://zh.wikipedia.org/wiki/Special:Search?search=" + encodeURIComponent(work.name);
    var related = works.map(function (entry, index) {
      return workMiniMarkup(entry, index, activeIndex);
    }).join("");
    var keywords = item.keywords.map(function (word) {
      return '<span>' + esc(word) + '</span>';
    }).join("");
    var innovation = WORK_INNOVATIONS[work.name] || work.innovation || "该项目延续了建筑师对空间、材料与结构的持续实验。";
    var initialPhoto = mediaFigureMarkup(localPhoto(item, work), "work-view__photo", work.name + " 建筑照片", "建筑照片暂不可用");

    return '' +
      '<article class="work-view">' +
        '<div class="work-view__topbar">' +
          '<button class="work-view__back" type="button" data-work-back>' +
            '<svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true">' +
              '<path d="m15 18-6-6 6-6"></path>' +
            '</svg>' +
            '返回 ' + esc(item.name) +
          '</button>' +
          '<span class="work-view__counter">作品 ' + (activeIndex + 1) + ' / ' + works.length + '</span>' +
        '</div>' +
        '<header class="work-view__hero">' +
          '<div class="work-view__year">' + esc(work.year) + '</div>' +
          '<div class="work-view__heading">' +
            '<span class="work-view__eyebrow">' + (isSignature ? "代表作" : "其他建筑") + ' · ' + esc(item.movement) + '</span>' +
            '<h2 id="modal-title">' + esc(work.name) + '</h2>' +
            '<p>' + esc(work.place) + '</p>' +
          '</div>' +
        '</header>' +
        '<section class="work-view__media is-loading" data-work-media>' +
          initialPhoto +
          '<div class="work-view__media-status">正在查找该建筑的照片与技术图纸…</div>' +
        '</section>' +
        '<div class="work-view__body">' +
          '<div class="work-view__main">' +
            '<h3>建筑说明</h3>' +
            '<p class="work-view__lead">' + esc(work.desc || "") + '</p>' +
            '<div class="work-view__innovation">' +
              '<span>当时的新功能与新概念</span>' +
              '<p>' + esc(innovation) + '</p>' +
            '</div>' +
            '<dl class="work-view__facts">' +
              '<div><dt>建成时间</dt><dd>' + esc(work.year) + ' 年</dd></div>' +
              '<div><dt>所在地</dt><dd>' + esc(work.place) + '</dd></div>' +
              '<div><dt>建筑师</dt><dd>' + esc(item.name) + '</dd></div>' +
              '<div><dt>设计时期</dt><dd>' + esc(item.eraLabel) + '</dd></div>' +
            '</dl>' +
          '</div>' +
          '<aside class="work-view__aside">' +
            '<h3>设计脉络</h3>' +
            '<p>' + esc(item.headline) + '</p>' +
            '<div class="keywords">' + keywords + '</div>' +
          '</aside>' +
        '</div>' +
        '<div class="work-view__related">' +
          '<h3>继续浏览</h3>' +
          '<div class="work-view__related-strip">' + related + '</div>' +
        '</div>' +
        '<div class="work-view__actions">' +
          '<a class="work-view__wiki" href="' + esc(search) + '" target="_blank" rel="noopener">在维基百科查看 ↗</a>' +
        '</div>' +
      '</article>';
  }

  function modalMarkup(item) {
    var figures = item.images.map(function (image, i) {
      return '<figure class="modal__figure">' +
        imageMarkup(image, item.name + "：" + image.caption, "modal__img") +
        '<figcaption>图 ' + (i + 1) + ' · ' + esc(image.caption) + '</figcaption>' +
        '</figure>';
    }).join("");
    var galleryClass = item.images.length > 1 ? "" : " modal__gallery--single";

    var works = sortedWorks(item).map(function (work, i) {
      return workCardMarkup(item, work, i);
    }).join("");

    var keywords = item.keywords.map(function (word) {
      return '<span>' + esc(word) + '</span>';
    }).join("");

    return '' +
      '<div class="modal__gallery' + galleryClass + '">' + figures + '</div>' +
      '<div class="modal__body">' +
        '<div class="modal__head">' +
          '<div class="modal__eyebrow">' +
            '<span class="tag">' + esc(item.region) + '</span>' +
            '<span class="tag tag--teal">' + esc(item.eraLabel) + '</span>' +
            '<span>' + esc(item.country) + ' · ' + esc(item.life) + '</span>' +
          '</div>' +
          '<h2 id="modal-title">' + esc(item.name) + '</h2>' +
          '<p class="modal__latin">' + esc(item.latin) + ' · ' + esc(item.movement) + '</p>' +
        '</div>' +
        '<p class="modal__headline">' + esc(item.headline) + '</p>' +
        '<div class="modal__columns">' +
          '<div>' +
            '<h3>建筑师</h3>' +
            '<p class="modal__bio">' + esc(item.bio) + '</p>' +
            '<div class="keywords">' + keywords + '</div>' +
          '</div>' +
          '<div>' +
            '<h3>建筑作品</h3>' +
            '<ul class="works">' + works + '</ul>' +
          '</div>' +
        '</div>' +
        '<div class="credits"><h3>图片来源</h3><ul>' + creditMarkup(item) + '</ul></div>' +
      '</div>';
  }

  function openModal(id) {
    var item = DATA.filter(function (entry) { return entry.id === id; })[0];
    if (!item) return;
    mediaRequestToken += 1;
    lastFocus = document.activeElement;
    currentItem = item;
    currentWorkIndex = -1;
    modalContent.innerHTML = modalMarkup(item);
    modal.hidden = false;
    document.body.style.overflow = "hidden";
    applyImages(modalContent);
    modal.querySelector(".modal__close").focus();
  }

  function showWork(index) {
    if (!currentItem || index < 0 || index >= currentItem.works.length) return;
    var work = sortedWorks(currentItem)[index];
    currentWorkIndex = index;
    modalContent.innerHTML = workDetailMarkup(currentItem, index);
    var panel = modal.querySelector(".modal__panel");
    if (panel) panel.scrollTop = 0;
    var back = modal.querySelector(".work-view__back");
    if (back) back.focus();
    loadWorkMedia(currentItem, work);
  }

  function showArchitect() {
    if (!currentItem) return;
    mediaRequestToken += 1;
    var returnIndex = currentWorkIndex;
    currentWorkIndex = -1;
    modalContent.innerHTML = modalMarkup(currentItem);
    var panel = modal.querySelector(".modal__panel");
    if (panel) panel.scrollTop = 0;
    applyImages(modalContent);
    var returnCard = returnIndex > -1 && modal.querySelector('[data-work-index="' + returnIndex + '"]');
    if (returnCard) returnCard.focus();
  }

  function closeModal() {
    mediaRequestToken += 1;
    modal.hidden = true;
    modalContent.innerHTML = "";
    document.body.style.overflow = "";
    currentItem = null;
    currentWorkIndex = -1;
    if (lastFocus && lastFocus.focus) lastFocus.focus();
  }

  document.addEventListener("click", function (event) {
    if (event.target.closest("[data-work-back]")) {
      showArchitect();
      return;
    }
    var workCard = event.target.closest("[data-work-index]");
    if (workCard && !modal.hidden) {
      showWork(Number(workCard.getAttribute("data-work-index")));
      return;
    }
    var card = event.target.closest("[data-id]");
    if (card) {
      openModal(card.getAttribute("data-id"));
      return;
    }
    if (event.target.closest("[data-close]")) closeModal();
  });

  document.addEventListener("keydown", function (event) {
    if (modal.hidden) return;
    if (event.key === "Escape") {
      if (currentWorkIndex > -1) showArchitect();
      else closeModal();
      return;
    }
    if (event.key === "Tab") {
      var focusable = modal.querySelectorAll("button, a[href], input, [tabindex]:not([tabindex='-1'])");
      if (!focusable.length) return;
      var first = focusable[0];
      var last = focusable[focusable.length - 1];
      if (event.shiftKey && document.activeElement === first) {
        event.preventDefault();
        last.focus();
      } else if (!event.shiftKey && document.activeElement === last) {
        event.preventDefault();
        first.focus();
      }
    }
  });

  document.querySelectorAll("[data-filter]").forEach(function (group) {
    group.addEventListener("click", function (event) {
      var chip = event.target.closest(".chip");
      if (!chip) return;
      var key = group.getAttribute("data-filter");
      state[key] = chip.getAttribute("data-value");
      group.querySelectorAll(".chip").forEach(function (btn) {
        btn.classList.toggle("is-active", btn === chip);
      });
      render();
    });
  });

  document.querySelectorAll(".chips").forEach(function (strip) {
    strip.addEventListener("scroll", updateScrollHints, { passive: true });
    enableDragScroll(strip);
  });

  var resizeTimer = null;
  window.addEventListener("resize", function () {
    window.clearTimeout(resizeTimer);
    resizeTimer = window.setTimeout(updateScrollHints, 120);
  });

  document.querySelectorAll("[data-view]").forEach(function (button) {
    button.addEventListener("click", function () {
      state.view = button.getAttribute("data-view");
      document.querySelectorAll("[data-view]").forEach(function (btn) {
        var active = btn === button;
        btn.classList.toggle("is-active", active);
        btn.setAttribute("aria-pressed", active ? "true" : "false");
      });
      gallery.hidden = state.view !== "grid";
      timeline.hidden = state.view !== "timeline";
    });
  });

  var searchTimer = null;
  searchInput.addEventListener("input", function () {
    window.clearTimeout(searchTimer);
    searchTimer = window.setTimeout(function () {
      state.query = searchInput.value.trim();
      render();
    }, 120);
  });

  resetBtn.addEventListener("click", function () {
    state.region = "all";
    state.era = "all";
    state.query = "";
    searchInput.value = "";
    document.querySelectorAll("[data-filter]").forEach(function (group) {
      group.querySelectorAll(".chip").forEach(function (btn, i) {
        btn.classList.toggle("is-active", i === 0);
      });
    });
    render();
  });

  render();
})();
