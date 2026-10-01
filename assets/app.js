(function () {
  "use strict";

  var DATA = window.ARCHITECTS || [];
  var CREDITS = window.IMAGE_CREDITS || {};
  var state = { region: "all", era: "all", query: "", view: "grid" };

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

  function modalMarkup(item) {
    var figures = item.images.map(function (image, i) {
      return '<figure class="modal__figure">' +
        imageMarkup(image, item.name + "：" + image.caption, "modal__img") +
        '<figcaption>图 ' + (i + 1) + ' · ' + esc(image.caption) + '</figcaption>' +
        '</figure>';
    }).join("");
    var galleryClass = item.images.length > 1 ? "" : " modal__gallery--single";

    var works = item.works.slice().sort(function (a, b) {
      return a.year - b.year;
    }).map(function (work) {
      return '<li><strong>' + esc(work.name) + '</strong><b>' + esc(work.year) + '</b>' +
        '<em>' + esc(work.place) + '</em></li>';
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
            '<h3>代表作</h3>' +
            '<ul class="works">' + works + '</ul>' +
          '</div>' +
        '</div>' +
        '<div class="credits"><h3>图片来源</h3><ul>' + creditMarkup(item) + '</ul></div>' +
      '</div>';
  }

  function openModal(id) {
    var item = DATA.filter(function (entry) { return entry.id === id; })[0];
    if (!item) return;
    lastFocus = document.activeElement;
    modalContent.innerHTML = modalMarkup(item);
    modal.hidden = false;
    document.body.style.overflow = "hidden";
    applyImages(modalContent);
    modal.querySelector(".modal__close").focus();
  }

  function closeModal() {
    modal.hidden = true;
    modalContent.innerHTML = "";
    document.body.style.overflow = "";
    if (lastFocus && lastFocus.focus) lastFocus.focus();
  }

  document.addEventListener("click", function (event) {
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
      closeModal();
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
