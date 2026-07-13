# Fan-out details

## Per-skill subagent prompt template

Send this to each competing skill's subagent. Everything is identical across agents except the two
`{{...}}` skill-specific lines. Fill `{{COMMON_BRIEF}}` once and reuse it byte-for-byte.

```
任務:嚴格遵循一個 skill,完成以下任務。

步驟:
1. 完整讀取這個 skill(務必讀完,含資料夾內 references/ 等參考檔):
   {{SKILL_MD_PATH}}
2. 嚴格按照該 skill 的所有規範與流程完成任務。skill 的規範優先於你的預設習慣;
   skill 明確禁止的做法一律不要用。

任務內容(所有競賽 skill 收到的是完全相同的這份 brief):
{{COMMON_BRIEF}}

技術限制:
- {{DELIVERABLE_CONSTRAINTS，例如:單一自包含 HTML,inline CSS/JS,可用 CDN}}
- 程式碼必須完整,不可有「省略 / omitted / // TODO / ...其餘」之類的佔位。
- 輸出檔案路徑(用 Write 工具,一字不差):
  {{OUTPUT_PATH}}

完成後(若環境允許)用瀏覽器實測:console 無錯誤、正常渲染、亮暗模式如適用皆可讀,
再交付。回傳一段簡短的「繁體中文」說明:你依據 skill 選擇的方向與關鍵手法(不要貼程式碼)。
```

## Fairness checklist (before spawning)

- [ ] `{{COMMON_BRIEF}}` is identical in every agent's prompt — copy-paste, don't paraphrase per skill.
- [ ] The brief describes the *task*, not a *style*. Style is the variable each skill supplies.
- [ ] Only `{{SKILL_MD_PATH}}` and `{{OUTPUT_PATH}}` differ between agents.
- [ ] Reference files (images, data) are the same path for all agents.
- [ ] Skills that can't produce the target medium are handled explicitly (natural output or excluded with a reason) — not silently forced.
- [ ] All runs spawned in one turn for parallelism (unless resource limits force batching/series).

## Verification snippet

After the runs, confirm each output is real and complete (adapt the deliverable filename/extension):

```bash
# PowerShell
$base='<bakeoff-dir>'
foreach ($d in @('skill-a','skill-b','skill-c')) {
  $f = "$base\$d\<deliverable>"
  if (Test-Path $f) {
    $c = Get-Content $f -Raw -Encoding UTF8
    $endOk = $c.TrimEnd() -match '</html>\s*$|</script>\s*$|</body>\s*$'
    $ph = $c -match '省略|omitted|// TODO|\.\.\.rest'
    "{0}: {1} bytes, complete={2}, placeholder={3}" -f $d, (Get-Item $f).Length, $endOk, $ph
  } else { "$d: MISSING" }
}
```

Anything MISSING, `complete=False`, or `placeholder=True` → read that folder, diagnose, re-run that
one skill. Don't re-run the whole set.

## manifest.json schema (for build_hub.py)

```json
{
  "title": "UI Skill 對照測試",
  "subtitle": "同一份任務,多個設計 skill 各自產出,比較風格與品質。",
  "note": "部分版本依賴 CDN(元件庫、字體),需網路連線才完整。",
  "entries": [
    {
      "skill": "design-taste-frontend",
      "source": "Leonxlnx/taste-skill (v2)",
      "approach": "先推斷產品方向,再自訂概念與 token 系統;Linear 式乾淨 B2B。",
      "links": [
        { "label": "Landing", "href": "design-taste-frontend/index.html" },
        { "label": "履歷", "href": "design-taste-frontend/resume.html" }
      ]
    }
  ]
}
```

- `title`/`subtitle`/`note` are optional strings for the page header/footer.
- Each entry needs `skill` and at least one `links` item. `source` and `approach` are optional but make
  the hub far more useful — fill `approach` from the agent's returned report.
