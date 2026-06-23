---
name: text-to-motion
description: 把文字敘述變成動態簡報影片(MP4)和/或動圖(GIF)的完整流程:文字 → HyperFrames HTML 動畫 → render 成 MP4 → ffmpeg 轉 GIF。支援「分段」(每個主題場景一個檔)或「整合」(單一檔案),可控參數:尺寸 px(如 440x250)、fps、比例處理(補黑邊/裁切/拉伸)、檔案大小上限(自動調參收斂)、總長/每段秒數、風格與主色、循環模式(無限/播一次)、GIF 色彩數、MP4 交付解析度。只要使用者想用文字產生影片或動圖、做動態簡報/教學/宣傳動畫、把一段說明變成 GIF、或要求把這類影片切成每個主題一個 GIF,都使用這個 skill,即使對方沒有明講輸出格式或沒提到 HyperFrames。
---

# text-to-motion:文字敘述 → 影片 / 動圖 GIF

把一段文字敘述變成有設計感的動態簡報影片,並依需求輸出 MP4、GIF、分段或整合單檔。
與使用者互動一律用繁體中文。

## 流程總覽

```
文字敘述
  → (0) 確認輸出選項        缺什麼問什麼,有預設值
  → (1) 場景規劃             拆成 N 個主題場景,先給使用者確認再動工
  → (2) 建 HyperFrames 專案  每場景一個 composition,邊寫邊記「乾淨窗口」
  → (3) check + render       過 lint 才 render,產出 30fps 1920x1080 MP4
  → (4) 輸出轉換             MP4 直接交付,GIF 用 ffmpeg palettegen 管線
  → (5) 交付 + 驗證回報      最終檔複製到交付資料夾,ffprobe + 頭尾格目視
```

render 一次要花數分鐘,所以順序是「規劃先確認、lint 過了才 render、render 一次就好」,
所有分段/格式變化都從同一支 MP4 後製出來。

## Step 0:確認輸出選項

從使用者的話裡先撈(參數常直接寫在敘述裡,如「440x250、12fps、每檔小於 1MB」),
撈不到且重要的才用 AskUserQuestion 問,其餘用預設。

所有預設值的單一來源是本 skill 的 `config/defaults.json`(影片規格、GIF 規格、場景長度
範圍、配色與字型、引擎版本)。**動工前一律先讀 `config/defaults.json` 取當下數值,不要靠記憶或
本表的舊值**;下表只說明「哪個參數去哪裡查」,凡 defaults.json 有的(尺寸、fps、色彩、比例、
循環、配色…)都以設定檔為準,本表不再重抄具體數字以免漂移。

**核心參數**(格式與分段沒講就要問,其他有預設):

| 參數 | 可能值 | 預設 |
|------|--------|------|
| 輸出格式 | MP4 / GIF / 兩者 | 問 |
| 分段方式 | 分段(每場景一檔)/ 整合(單檔) | 問 |
| GIF 尺寸 px | 寬x高 | 見 `defaults.json` → `gif.width`/`gif.height` |
| GIF fps | 30fps 原片只能取 30/15/10/6/5(等距抽格;20/25/12 會不等距導致抖動) | 見 `defaults.json` → `gif.fps` |
| 比例處理 | pad 補黑邊 / crop 裁切 / stretch 拉伸 | 見 `defaults.json` → `gif.aspect_mode`;目標比例與 16:9 差很大(如正方形、直式)時建議 crop,並在 Step 2 把構圖設計在中央安全區,裁切才不缺字 |

**進階參數**(使用者講到才生效,不主動問):

| 參數 | 說明 | 預設 |
|------|------|------|
| 檔案大小上限 | 例「每檔 <1MB」;超標時依 gif-pipeline.md 的調參階梯自動收斂,並回報用了哪幾步 | 無上限,但單檔 >8MB 要在回報中主動警示並給縮小選項 |
| 總長 / 每段秒數 | 例「總長 30 秒」「每段不超過 8 秒」 | 自動:單場景 6~15s,總長 30~120s |
| 風格 / 主色 | 深色科技(預設)/ 亮色簡約 / 暖色手作,或指定主色(如品牌色 #1a73e8) | 深色科技(紫青漸層) |
| 循環模式 | 無限循環 / 播一次 / N 次 | 見 `defaults.json` → `gif.loop`(0=無限) |
| GIF 色彩數 | 2~256;256→128 常省約三成大小且畫質損失小 | 見 `defaults.json` → `gif.colors` |
| MP4 交付解析度 | 例「720p 就好」;母片固定 1080p render,交付時縮 | 1080p 原檔 |
| 交付資料夾 | 最終檔放哪 | 工作目錄下 `gif_out\` 或 `output\` |

## Step 1:場景規劃

把文字敘述拆成 4~8 個主題場景。每個場景給:

- `id`:英文 slug(intro、problem、outro...),會成為檔名與 composition id
- 標題與內容要點(一兩句)
- 秒數:單場景 6~15 秒,總長控制在 30~120 秒

用表格把場景規劃呈現給使用者確認後才開始寫程式,因為 render 很貴,規劃改起來便宜。

## Step 2:建 HyperFrames 專案

**先讀 `references/hyperframes-composition.md`** 再動手,裡面有 master 與場景的完整骨架、
框架規則(class="clip"、window.__timelines、確定性邏輯等)。跳過它寫出來的 composition 會壞。

在工作目錄下建 `<topic-slug>/` 專案。字型(中文 Noto Sans TC + 等寬 JetBrains Mono):

1. 直接複製本 skill 內建的字型包:`<skill 根目錄>/assets/fonts/` → 專案 `assets/fonts/`
   (含 fonts.css 與全部 woff2,離線可用)
2. 字型包缺失時,跑本 skill 的 `scripts/fetch-fonts.mjs`(複製到專案 `scripts/` 後
   `node scripts/fetch-fonts.mjs`,需網路,會重建 assets/fonts/)
3. 再不行就用系統字型 `"Microsoft JhengHei", sans-serif`,並避免依賴特定字重的版面

**邊寫邊記乾淨窗口**:每寫完一個場景的 GSAP timeline,把兩個時間記進專案根目錄的 `scenes.json`:

- `stable_in`:進場動畫全部結束的時間(相對場景起點,= 最晚進場 tween 的 position + duration)
- `exit_start`:退場 tween 開始的時間(相對場景起點)

```json
{
  "fps_source": 30,
  "scenes": [
    { "id": "intro", "title": "標題", "start": 0, "duration": 8, "stable_in": 2.3, "exit_start": 7.15 }
  ]
}
```

這是分段切檔的依據:授權時自己記下來,之後就完全不必做場景偵測。

## Step 3:check + render

```bash
npm run check    # lint + validate + inspect,全部錯誤修完才往下
npm run render   # 數分鐘
```

render 的執行方式很重要:**任務沒交付前不要結束回覆**。render 跑數分鐘,優先用前景執行
搭配長 timeout(600000ms);若預估會超過,改背景執行後「自己輪詢等到結束」
(確認 `renders/` 出現 mp4 且檔案大小停止成長)再往下走。把 render 丟到背景就先回報
「等完成後再繼續」,對無人值守執行等於任務做一半棄單。

render 輸出在專案的 `renders/<專案名>_<時間戳>.mp4`。有些版本會留 `work-*` 暫存資料夾
(capture worker 逐格截圖,可當驗證底片),有的話交付前刪掉,沒有就算了。

## Step 4:輸出轉換

細節與原理在 `references/gif-pipeline.md`(要調參數或出問題時讀它)。標準路徑:

1. 由 `scenes.json` 算出切點,寫 `cuts.txt`,每行 `名稱|起點秒|長度秒`:
   - 第一段:從 `start`(0)開始,保留標題打入動畫(這是內容,不是殘影)
   - 其他段:`start + stable_in` 開始
   - 每段結束:`start + exit_start`(避開自己的退場淡出)
   - 整合單檔:一行,`0` 到最後一場景的 `start + exit_start`(去掉結尾淡黑,循環才不閃黑)
2. 跑 skill 附的腳本(Git Bash):
   ```bash
   bash <skill-path>/scripts/make_gifs.sh 影片.mp4 cuts.txt gif_out 440x250 15 pad [色彩數] [loop]
   ```
   (色彩數預設 256;loop 預設 0=無限循環,-1=播一次,N=再播 N 次)
   腳本會輸出 GIF、ffprobe 驗尺寸,並把每檔第一格/最後一格抽到 `gif_out/_verify/`。
3. 檢查每檔大小:有使用者上限就依 gif-pipeline.md 的「大小調參階梯」收斂到達標;
   沒上限但單檔 >8MB(常見於 >20 秒的整合 GIF)也要在回報主動警示,給降 fps/減色/分段的選項。
4. MP4 分段交付或縮解析度交付,用 gif-pipeline.md 的對應指令。

## Step 5:交付 + 驗證回報

1. Read `gif_out/_verify/` 裡每檔的 first/last PNG:第一格必須是完整不透明的畫面(第一段的
   打入動畫初始狀態除外),最後一格不能已開始淡出。發現殘影就微調該段切點重產該檔。
2. **把最終交付檔複製到顯眼的交付位置**:使用者指定的資料夾,沒指定就在工作目錄根層開一個
   (例如 `gif_out\` 或 `output\`)。專案資料夾(compositions、renders、node_modules)是中間產物,
   交付檔絕不能只留在專案樹深處讓使用者自己挖。
3. 確認後刪掉 `_verify/`(與 `work-*`,若存在)。
4. 回報表格:檔名、主題、起點、長度、尺寸、檔案大小;每檔給**絕對路徑**;說明用的參數。

## 已知陷阱

- **不要用 `npx`,一律用 `npm exec --yes -- hyperframes@<版本> <子命令>`**。兩者等效、版本鎖定相同,
  但部分 Windows 環境的 npx 是壞的(`npx-cli.js` 缺檔),npm exec 到處都能跑。
  reference 裡的 package.json 範本已是這個寫法,照抄即可;版本號以 `config/defaults.json` 的
  `engine.hyperframes_version` 為準。
- `npm run dev` 是長駐 preview server,只能 `run_in_background` 跑,前景會 timeout 弄死它。
  (這是唯一適合背景執行的指令;render 不是,見 Step 3。)
- Windows 上 ffmpeg 的 `drawtext` 常因 Fontconfig 缺設定而失敗,不要用它在畫面上印字;
  要在畫面放文字就放進 composition 的 HTML 裡。
- composition 裡禁止 `Date.now()`、`Math.random()`、網路 fetch:render 是確定性逐格擷取,非確定性邏輯會讓每次 render 不一樣。
- `npm run check` 最常見的錯誤是文字溢出/遮罩裁切(標題 line-height 太緊、遮罩容器太矮):
  行容器加上下 padding 再用負 margin 補償即可,細節見 hyperframes-composition.md。
- GIF 檔案大小主要由 fps 與秒數決定;簡報式動畫格間差異小,15fps 通常只比 12fps 大不到 5%。
