# HyperFrames composition 寫法(text-to-motion 用)

HyperFrames(HeyGen)把 HTML+GSAP 動畫逐格擷取成影片。CLI 以 `npx --yes hyperframes@0.6.88` 執行。
官方文件:`npx hyperframes docs <topic>`(topics: data-attributes, gsap, compositions, rendering, examples, troubleshooting),完整索引 https://hyperframes.heygen.com/llms.txt。

## 框架鐵則(違反就 render 壞掉)

1. 每個有時間軸的元素都要 `data-start`、`data-duration`、`data-track-index`,且**必須**有 `class="clip"`(框架靠它控制可見性)。
2. GSAP timeline 一律 `paused: true`,並註冊到 `window.__timelines["<composition-id>"]`。
3. 只能確定性邏輯:禁 `Date.now()`、`Math.random()`、網路 fetch。render 是逐格 seek,非確定性會讓畫面每次不同。
4. 子 composition 用 `data-composition-src="compositions/檔名.html"` 引用,檔案內容包在 `<template id="<id>-template">` 裡。
5. 影片元素要 `muted`,音軌另用 `<audio>`。
6. 改完任何 composition 都要 `npm run check`,錯誤清零才算完成。

## 專案檔案

```
<topic-slug>/
├── package.json        # scripts: dev/check/render/publish(見下)
├── meta.json           # {"id":"<slug>","name":"<slug>","createdAt":"<ISO>"}
├── hyperframes.json    # registry 設定(照抄下方)
├── index.html          # master timeline
├── compositions/       # 每場景一個 html
├── assets/fonts/       # fonts.css + woff2(本地化字型)
└── scenes.json         # 自己記的乾淨窗口(本 skill 的切檔依據)
```

package.json:

```json
{
  "name": "<topic-slug>",
  "private": true,
  "type": "module",
  "scripts": {
    "dev": "npm exec --yes -- hyperframes@0.6.88 preview",
    "check": "npm exec --yes -- hyperframes@0.6.88 lint && npm exec --yes -- hyperframes@0.6.88 validate && npm exec --yes -- hyperframes@0.6.88 inspect",
    "render": "npm exec --yes -- hyperframes@0.6.88 render",
    "publish": "npm exec --yes -- hyperframes@0.6.88 publish"
  }
}
```

(用 `npm exec` 而非 `npx`:兩者等效且版本鎖定相同,但部分 Windows 環境的 npx 損壞,
npm exec 可移植性更好。版本號以 skill 的 `config/defaults.json` 為準。)

hyperframes.json:

```json
{
  "$schema": "https://hyperframes.heygen.com/schema/hyperframes.json",
  "registry": "https://raw.githubusercontent.com/heygen-com/hyperframes/main/registry",
  "paths": { "blocks": "compositions", "components": "compositions/components", "assets": "assets" }
}
```

## master(index.html)骨架

重點:body 固定 1920x1080;場景層彼此**不重疊**(start 首尾相接),交叉淡化是每個場景自己的進退場動畫,這讓分段切檔時鄰段互不污染。可加跨全片的背景層(光暈、噪點)讓場景間有連續感。

**不要加底部進度條**(畫面底部一條跟著時間填滿的橫條):整支影片分段切成多個 GIF 後,
每段底部都會掛著一截長度不一的進度條,既無意義又干擾畫面,所以本 skill 一律不放。

```html
<!doctype html>
<html lang="zh-Hant" data-resolution="landscape">
  <head>
    <meta charset="UTF-8" />
    <title>影片標題</title>
    <link rel="stylesheet" href="assets/fonts/fonts.css" />
    <script src="https://cdn.jsdelivr.net/npm/gsap@3.14.2/dist/gsap.min.js"></script>
    <style>
      body, html { margin: 0; width: 1920px; height: 1080px; background: #07090f; overflow: hidden;
        font-family: "Noto Sans TC", "Microsoft JhengHei", sans-serif; }
      #master-root { width: 1920px; height: 1080px; position: relative; }
      .scene-layer { position: absolute; inset: 0; pointer-events: none; z-index: 10; }
    </style>
  </head>
  <body>
    <div id="master-root" data-composition-id="master" data-width="1920" data-height="1080"
         data-start="0" data-duration="<總秒數>">

      <!-- 跨全片背景層(可選):漸層 vignette、點陣、glow、grain。不要放底部進度條 -->

      <div id="scene-intro" class="scene-layer clip"
           data-composition-id="intro" data-composition-src="compositions/intro.html"
           data-start="0" data-duration="8" data-track-index="1"></div>
      <!-- 其餘場景同形,data-start 接續、track-index 遞增 -->

      <script>
        window.__timelines = window.__timelines || {};
        const masterTL = gsap.timeline({ paused: true });
        // 跨全片的緩慢環境動態放這裡(例:glow 漂移 x/y, duration=總秒數, ease:"none")。不要做進度條
        window.__timelines["master"] = masterTL;
      </script>
    </div>
  </body>
</html>
```

## 場景 composition 骨架(compositions/<id>.html)

```html
<template id="<id>-template">
  <div id="<id>" data-composition-id="<id>" data-width="1920" data-height="1080" data-duration="<秒數>">
    <div class="sc-stage">
      <!-- 場景內容:標題、列表、卡片、演示元件... -->
    </div>

    <style>
      #<id> { width: 1920px; height: 1080px; position: relative; overflow: hidden; }
      /* 所有 selector 都用 #<id> 前綴,避免跨場景污染 */
      /* 要進場的元素初始態寫在 CSS(opacity:0 / transform),由 timeline 揭示 */
    </style>

    <script src="https://cdn.jsdelivr.net/npm/gsap@3.14.2/dist/gsap.min.js"></script>
    <script>
      (function () {
        const tl = gsap.timeline({ paused: true });
        const root = "#<id>";

        // 進場:0 ~ 約 1.5s,錯落淡入/位移/遮罩揭示
        // tl.fromTo(root+" .title", {opacity:0,y:40}, {opacity:1,y:0,duration:.8,ease:"power3.out"}, .2)

        // 中段:內容逐項出現 + 緩慢環境漂移(避免長停格像當機)
        // tl.to(root+" .stage", { y:-12, duration:4, ease:"none" }, 2)

        // 退場:結束前 0.7~0.9s 開始,整體淡出/上移
        // tl.to(root+" .sc-stage", {opacity:0, y:-50, duration:.75, ease:"power2.in"}, <exit_start>)

        window.__timelines["<id>"] = tl;   // window.__timelines 由 master 先建好也行,保險起見自己 || 初始化
      })();
    </script>
  </div>
</template>
```

## 乾淨窗口(寫 timeline 時順手記)

每個場景記兩個相對時間進 `scenes.json`:

- `stable_in` = 最晚一個進場 tween 的 position + duration(例:position 1.45 + duration 0.85 → 2.3)。
  注意是「版面基底定下來」的時間;之後逐項出現的內容(表格列、卡片)不算進場,GIF 留著它們反而精彩。
  若中段有環境漂移(緩慢 y 位移),不影響 stable_in 判定,漂移是刻意的。
- `exit_start` = 退場 tween 的 position。

切檔規則(SKILL.md Step 4 用):分段 GIF 取 `[start + stable_in, start + exit_start]`,
第一段例外從 `start` 開始保留打入動畫。這樣每段頭尾都是完整畫面,循環播放不閃。

## 常見 `npm run check` 錯誤與修法

- **文字溢出/被裁切(text overflow)**:最常見。原因多是大標題 line-height 太緊,或遮罩揭示用的
  `overflow:hidden` 容器太矮裁到字的上下緣。修法:行容器加上下 padding(約 0.08~0.12em)
  並用等量負 margin 補償視覺位置,例:`padding-bottom:0.08em`。
- **跨元素 tween 重疊 warning**:lint 對「同一 timeline 操作多個元素」的靜態誤報,目視 preview
  或抽格確認沒問題即可忽略,不必為了消 warning 改寫動畫。
- **單一 composition 檔 lint 報「字型未定義」**:字型實際由 master 的 fonts.css 注入,
  單檔靜態分析看不到,屬誤報。
- 原則:**error 必須清零,warning 要逐條判斷是誤報還是真問題**,誤報在回報中說明即可。

## 設計建議(讓產出不像簡報罐頭)

- 深色底 + 1~2 個強調色漸層(預設配色與字型的完整定義在 skill 的 `config/defaults.json`,
  範例用 #7c6cff 紫 → #2dd4ff 青),標題大膽(120~160px 粗體)。使用者指定主色時替換 accent 色即可。
- 進場用 power3/power4.out,退場 power2.in;遮罩揭示(overflow:hidden + translateY)比單純 fade 高級。
- 長停格一定加緩慢漂移或微動畫,否則 GIF 循環時像靜止圖。
- 中英混排:中文 Noto Sans TC,代碼/參數用 JetBrains Mono。
- 每場景一個重點,文字能少就少;觀眾是用看的不是用讀的。
