---
name: project-spec-doc
description: Generate a dual-format functional specification / planning document (企劃文件／功能規格文件) for a software project — a Word (.docx) sign-off version and a single-file HTML client-facing version — documenting a set of UI modules (list pages, add/edit/view forms, search, validation rules, copy behavior) captured from an HTML prototype. Use this skill whenever the user asks for a "企劃文件", "功能規格文件", "規格文件", "spec document", "PRD", or asks to turn an HTML/web prototype into a formal document for client review or sign-off — even if they don't use those exact words but describe wanting a document that pairs with a prototype for stakeholder alignment or approval. Also use when asked to update, extend, or keep in sync an existing spec document of this kind.
---

# 企劃文件產生器（Project Spec Doc Generator）

依既定架構與樣式，把一個 HTML 原型的功能規則整理成正式的規格文件，同時產出兩個版本：Word 簽核版與 HTML 客戶對焦版。這份 skill 記錄的是完整的做法，照著做即可重現一致的風格。

## 使用前必須先確認的三件事

在動手之前，先跟使用者確認（如果對話裡還沒講清楚）：

1. **最後要不要放一個「共通規則」統整章節？** 如果文件涵蓋多個高度相似的模組（都有頁籤、都有複製功能等）且使用者不介意文件多一章，就加；如果使用者明確要求「文件只談這幾個功能」，就不要加，把規則分散寫回各模組小節即可。
2. **Word 版要不要簽核頁？如果要，使用者有沒有既有的驗收單／簽核單範本圖片？** 有的話要照圖調整樣式，不要套用本文件內建的預設樣式。
3. **HTML 版要不要「Demo 連結」按鈕（點擊直接跳轉到原型對應頁面）？** 如果要，記得提醒使用者「文件與原型檔案要放在同一個資料夾」，因為靠相對路徑連結。

不確定的話，用一句話問使用者即可，不要自己假設。

---

## 一、兩個版本的分工

| 版本 | 用途 | 特有內容 |
|---|---|---|
| Word 版（.docx） | 正式交付、簽核留存、列印 | 結尾附雙方簽核頁（見「六、簽核頁」） |
| HTML 版（.html） | 與客戶線上對焦、免安裝開啟即可看 | 側欄目錄、必填/選填 chip、每章 Demo 連結按鈕 |

兩版內容必須完全同步；每次原型異動後，兩版都要一起更新，並重新擷取受影響的截圖。

---

## 二、整體章節架構樣板

```
封面（專案名稱／文件版本／撰寫日期／適用模組）
目錄（手動列點，對應各章標題）

一、文件概述
  1.1 文件目的
  1.2 適用範圍（條列各模組一句話說明）
  1.3 使用者角色

二、系統選單架構
  （選單層級表格：第一層／第二層／對應章節）

三、〈功能模組 A〉         ← 依模組類型套用下方三種樣板之一
四、〈功能模組 B〉
五、〈功能模組 C〉
...

［若第0節判斷結果為「要」，最後加一章：X、共通規則與跨模組行為］
［Word 版結尾另加簽核頁；HTML 版不加簽核頁］
```

模組順序即章節順序（三、四、五...），每個模組依它的類型套用下面三種固定樣板之一。

### 2.1「列表型」模組樣板（有列表、可新增/編輯/檢視/複製）

```
X.1 功能概述          一段話說明這個功能是做什麼、給誰用
X.2 列表頁說明
  （插入列表頁截圖）
  X.2.1 頁籤            列出頁籤名稱＋定義；不同頁籤有不同操作按鈕時要列表對照
  X.2.2 列表欄位說明     每個欄位一列：欄位名稱／說明（含顯示規則、顏色規則等）
  X.2.3 搜尋功能說明     快速搜尋／進階搜尋分開寫，進階搜尋欄位用表格列出選項
X.3 新增／編輯／檢視頁說明
  （插入新增頁截圖）
  X.3.1 頁面標題規則     觸發方式 → 頁面標題 對照表（新增/編輯/檢視/複製分別叫什麼）
  X.3.2 欄位說明         表格：欄位／型態／必填／說明規則
  X.3.3 檢視模式（唯讀）規則
  X.3.4 檢核條件         表格：檢核欄位／檢核規則／提示訊息（一項對一項，不遺漏）
X.4 複製規則           條列複製時哪些欄位會/不會帶入、儲存後行為、取消後行為
X.5 分頁說明           列表分頁顯示格式與互動
X.6 其他操作規則（視需要新增）
  凡是「不適合塞進上面任何一張表格」的規則，獨立成這一小節，條列說明。
  常見情境：檔案上傳時系統即時解析內容、查無對應資料時畫面顯示什麼提示、
  某動作發生時是否同步觸發通知（推播／簡訊／Email）等。
```

**若表單欄位需要中／英文雙語輸入**：不要把兩個語言欄位都塞進同一頁一起顯示，改為「中文／英文」頁籤切換設計——中文頁籤顯示完整欄位（含中文名稱），英文頁籤只顯示英文名稱一個欄位。兩邊都設為必填時，檢核條件小節要加一句：「若必填欄位位於未顯示之頁籤，系統會自動切換至該頁籤，方便使用者立即修正」，並在 X.3.2 開頭加一段文字說明這個頁籤切換規則。

### 2.2「純查詢型」模組樣板（只查詢，無新增/編輯/刪除）

```
X.1 功能概述
X.2 列表欄位說明（含截圖）
X.3 搜尋功能說明（一般搜尋＋進階搜尋）
X.4 分頁說明（含「查詢前」與「查詢後」兩種狀態的顯示格式對照）
```

**當某個欄位的意義依「類型」不同而不同時**（例如「交易序號」在不同行為下代表不同序號），不要只在欄位說明表格塞一句籠統敘述，拆成兩個子小節：
```
X.2.1 〈類型〉種類          列出所有「行為/類型」，以及各自的觸發來源
X.2.2 〈某欄位〉顯示規則    針對同一欄位，依上面每種類型分別說明實際顯示什麼內容
```

### 2.3「單頁設定型」模組樣板（沒有列表，只有一個設定頁）

```
X.1 功能概述
X.2 欄位說明（含截圖）
X.3 操作規則（取消／儲存的行為）
X.4 檢核條件（若欄位皆為系統固定值、無法編輯，此節改寫一句話說明「無額外必填檢核規則」，不要留空表格）
```

---

## 三、內容撰寫的硬性規則

1. **每個表格欄位都要講兩件事**：叫什麼＋規則是什麼，不是只寫欄位名稱。
2. **檢核條件表一定要三欄**：檢核欄位／檢核規則／提示訊息。有多少個必填欄位，就要有多少列，不能只挑幾個代表。
3. **複製規則要交代三件事**：哪些欄位會帶入、哪些欄位會被清空或重置、儲存/取消後各自的行為。
4. **顏色與按鈕樣式用文字描述清楚**，例如「編輯（藍色外框）、複製（灰色外框）、刪除（橘紅色）」，方便工程師和客戶都能對照畫面。
5. **每次需求異動，先改 HTML 原型，再回頭同步文件**，避免文件與畫面兜不起來；原型資料異動後（新增測試列、欄位改名等），對應截圖也要重新擷取。

---

## 四、Word 版（.docx）技術做法

用 Node.js 的 `docx` 套件寫一支產生腳本（例如 `build_doc.js`）。

**共用樣式函式**：`h1()`／`h2()`／`h3()`／`p()`／`bullet()`／`numbered()`／`makeTable()`，統一控制字體、字級、顏色，不要每段落各自設定。

**編號清單陷阱**：每一組獨立的編號清單（例如每個模組各自的「複製規則」）都要給獨立的 `numbering reference`，不然編號會一路累加到下一組、不會重新從 1 開始：

```js
// 錯誤：全部共用同一個 reference，編號會一直累加
numbered("步驟一", 0, "num-list");

// 正確：每組獨立 reference
numbered("步驟一", 0, "num-module-a-copy");
numbered("步驟一", 0, "num-module-b-copy"); // 從1開始，不受前面影響
```
記得在 `numbering.config` 陣列裡註冊每一個用到的 reference。

**表格**：表頭灰底＋粗體，儲存格可放字串或字串陣列（陣列會自動變成同一格內的條列，適合放多條規則說明）。

**截圖**：用 `ImageRun` 插入，統一縮放到版面寬度（約 600px 對應 6.25 吋），加上細框線＋置中圖說文字。

```js
function screenshot(filename, caption) {
  const buffer = fs.readFileSync(path.join(SHOT_DIR, filename));
  const dims = sizeOf(buffer); // 套件: image-size
  const maxWidthPx = 600;
  const scale = maxWidthPx / dims.width;
  return [
    new Paragraph({
      alignment: AlignmentType.CENTER,
      border: { top:{...}, bottom:{...}, left:{...}, right:{...} }, // 細框線
      children: [new ImageRun({ data: buffer, transformation: { width: dims.width*scale, height: dims.height*scale }, type: "png" })],
    }),
    new Paragraph({ alignment: AlignmentType.CENTER, children: [new TextRun({ text: caption, size: 18, color: "8C8C8C", italics: true })] }),
  ];
}
```

**字體**：中文用「微軟正黑體」，全文件統一套用（`styles.default.document.run.font`）。

**色彩**：跟著實際產品的設計 token 走（例如主色藍、危險色橘紅），不要自己亂配色，讓文件配色和畫面配色一致。

---

## 五、HTML 版（.html）技術做法

同樣寫一支 Node.js 腳本（例如 `build_html_doc.js`），輸出**單一自包含 HTML 檔**（截圖用 base64 內嵌，不外連圖檔，才能單檔分享）。

**圖片編碼注意（容易踩的坑）**：讀取截圖轉 base64 時，一定要用 binary buffer，不能用 utf8 讀取，否則圖片會整個損毀變亂碼：

```js
// 錯誤：用 utf8 讀取二進位圖片檔，會產生亂碼損毀的圖片
function img64(name) {
  return fs.readFileSync(path.join(SHOT_DIR, name), "utf8").trim();
}

// 正確：讀成 Buffer 再轉 base64
function img64(name) {
  return fs.readFileSync(path.join(SHOT_DIR, name)).toString("base64");
}
```

**版面**：左側 sticky 側欄目錄（章節編號 01～N＋標題，N依實際章節數而定），右側主內容區，滾動時自動高亮目前章節（scroll 監聽 + `offsetTop` 比對）。

**封面條**：深色漸層 header，放專案名稱／文件版本／日期／適用模組數。

**表格裡的「必填／選填」欄位**：不要放死板的「是／否」文字，改成綠色／灰色圓角小標籤（chip）：
```css
.chip-req{background:#EAFBEC;color:#15803D;border:1px solid #86EFAC;}
.chip-opt{background:#F3F4F6;color:#6B7280;border:1px solid #E5E7EB;}
```

**功能按鈕說明**：直接用跟畫面一樣顏色的小標籤（例如藍色外框＝編輯、橘紅底＝刪除），取代純文字描述。

**截圖來源**：務必用瀏覽器自動化工具（Playwright）直接對實際 HTML 原型截圖，不要手畫示意圖：
```python
page.goto(f"file://{prototype_path}")
page.click("#addBtn")          # 觸發要拍的畫面狀態
page.screenshot(path="screenshots/02_form_add.png")
```
常見截圖時機：列表頁（預設載入畫面）、新增頁（點擊「＋新增」後）、查詢類頁面（展開進階搜尋＋觸發查詢，同時呈現搜尋條件與查詢結果）。

**Demo 連結（每章一個按鈕，點了直接跳進原型對應頁面）**：
1. 原型 HTML 的 `<script>` 結尾加一段：讀取 `location.hash`（例如 `#adjustment-list-view`），比對到對應的側邊選單項目後 `.click()` 模擬點擊，直接切換到該功能畫面。
   ```js
   (function handleDeepLink(){
     const hash = window.location.hash.replace('#', '');
     if(!hash) return;
     const menuItem = document.querySelector(`.menu-item[data-target="${hash}"]`);
     if(menuItem){ menuItem.click(); }
   })();
   ```
2. 企劃文件每個章節標題右側放一個按鈕，`href` 指向 `原型檔名.html#對應的hash值`，並加 `target="_blank" rel="noopener"`。
3. 前提：兩個檔案要放在同一個資料夾（相對路徑連結）。
4. 這個按鈕在 `@media print` 裡要隱藏。

**列印樣式**：加 `@media print`，隱藏側欄與 Demo連結按鈕、每個章節強制分頁，方便客戶直接用瀏覽器「列印→另存為PDF」。

---

## 六、Word 版專屬：簽核頁

Word 簽核版在最後一章結束後（不需要另外換頁，直接接續），加一個簽核頁：

```
驗收單位簽名                    ← 粗體標題，非章節樣式（不用 h1，不加底線）

┌─────────────────────┬─────────────────────┐
│ 〈開發端公司全名〉（灰底粗體）    │ 〈客戶端公司全名〉（灰底粗體）    │
├─────────────────────┼─────────────────────┤
│                         │                         │
│      （大片留白，供蓋章／簽名）    │      （大片留白，供蓋章／簽名）    │
│                         │                         │
└─────────────────────┴─────────────────────┘

           中華民國　　　年　　　月　　　日          ← 置中，數字處留空
```

實作重點：
- 用 `Table`／`TableCell` 手刻，標題列用 `shading` 加灰底、`borders` 四邊都設實線；空白簽名格用「連續放好幾個空白 `Paragraph`」撐出高度（docx 沒有直接設定儲存格高度的簡單 API）。
- **樣式優先照客戶提供的既有範本圖片調整，不要自己套死樣式。** 曾經同一個專案內就因為客戶換了一張參考圖，從「線條式簽名欄」改成「灰底表格框線式」，兩種都要能照圖重畫。
- 兩個公司欄位務必用**完整正式的公司全名**（例如「台灣積體電路製造股份有限公司-福委會」而非「台積電」）。
- 簽核頁前面不要強制分頁，讓 Word 自然換頁即可。
- HTML 客戶對焦版不要加這個簽核頁。

---

## 七、下指令時該準備什麼（給使用者的檢查清單）

請使用者一次準備好以下資訊：

1. 專案名稱、要涵蓋的功能模組清單
2. 每個模組屬於哪一種類型（列表型／純查詢型／單頁設定型）
3. HTML 原型檔案（或至少完整截圖），讓 Claude 能實際擷取畫面放入文件
4. 本文件開頭「使用前必須先確認的三件事」的答案（共通規則章節、簽核頁樣式、Demo連結）

拿到以上資訊後，就能直接依循本 skill 產出 Word 版與 HTML 版兩份文件。
