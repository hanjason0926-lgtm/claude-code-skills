---
name: skill-to-agent
description: 把「某一個既有 skill」打包成一個獨立、可直接執行的 claude-agent-sdk Python 專案(一個 agent),並用多關卡強制這個 agent 只能使用那一個 skill、拒絕系統/設定/實作問題與該 skill 邊界以外的任何請求。只要使用者說「把某個 skill 包成 agent / sdk」「做一個只會用 XX skill 的工具」「鎖定單一 skill 的 agent」「skill 打包」「限定只跑某 skill」,就使用這個 skill,即使他沒說出 claude-agent-sdk 這個詞。產出一律建新資料夾,絕不修改來源 skill 或其他既有專案。
---

# skill-to-agent

把單一 skill 打包成「只會做那件事」的獨立 agent(claude-agent-sdk Python 專案)。產出的 agent 用五道關卡確保它只透過指定 skill 工作,並擋掉越界/系統/設定問題。

## 何時用

使用者想要一個「專用工具」: 只負責某個 skill 的功能(例如只會把文字變 GIF 的 `text-to-motion` agent),不希望它被拿來問東問西、或做 skill 範圍以外的事。

## 鐵則(務必遵守)

- **產出一律建新資料夾**。預設在「使用者目前工作目錄」下建 `<skill>-agent/`。
- **絕不修改來源 skill 的檔案,也不修改任何既有專案**。特別是 `D:\jason_han\Desktop\捷徑\00_測試\AgentSDK` 這類既有資料夾,只能讀不能寫。若預定輸出路徑落在某個既有專案資料夾「之內」,停止並改用它的同層(sibling)新資料夾。
- 只「複製範本 + 填空 + 寫新檔」,不要自由發揮改寫 enforcement 邏輯(那是這個 skill 的核心價值)。

## 輸入

1. **目標 skill 名稱**(必填,例如 `text-to-motion`)。沒給就問。
2. **輸出資料夾**(選填)。沒給就用 `<目前工作目錄>/<skill>-agent`。先確認此路徑不在任何既有專案之內(見鐵則)。

## 步驟

### 1. 定位目標 skill,讀出兩個關鍵資訊
找出該 skill 的 `SKILL.md`,依序在這些位置找(取第一個命中):
- `<cwd>/.claude/skills/<name>/SKILL.md`(專案層)
- `$CLAUDE_CONFIG_DIR/skills/<name>/SKILL.md`(若有設)
- `~/.claude-second/skills/<name>/SKILL.md`
- `~/.claude/skills/<name>/SKILL.md`

從中取得:
- **description**:該 skill frontmatter 的 description(原文即可,會放進產出 agent 的 system prompt 當邊界說明)。
- **它落在哪個設定根目錄**:例如命中 `~/.claude-second/skills/...`,則設定根目錄 = `C:\Users\<user>\.claude-second`。這個值會填進範本的 `CLAUDE_CONFIG_DIR`,讓產出的 agent 一定載得到這個 skill(專案層命中則填 `None`)。
- **需要哪些工具**:若該 skill 的 frontmatter 有 `allowed-tools`,採用它;否則用預設可寫集合 `["Skill","Read","Glob","Grep","Write","Edit","Bash"]`(多數 skill 會跑外部工具,需要 Bash/Write)。一定要含 `Skill`。

找不到該 skill 就停止並回報:可能名稱錯、或該 skill 不在上述目錄。

### 2. 決定並建立輸出資料夾
- 預設 `<cwd>/<skill>-agent`。確認不在既有專案之內(尤其 AgentSDK)。
- 建立資料夾。

### 3. 產生檔案(複製範本 + 填空)
把 `assets/agent_template.py` 複製成 `<out>/run.py`,並把這些佔位字串替換掉:
- `@@NAME@@` → 目標 skill 名稱
- `@@DESCRIPTION@@` → 該 skill 的 description(去掉會破壞三引號字串的 `"""`)
- `@@ALLOWED_TOOLS@@` → Python list 字面值,如 `["Skill", "Read", "Glob", "Grep", "Write", "Edit", "Bash"]`
- `@@CONFIG_DIR@@` → `None` 或 Python 字串字面值如 `r"C:\Users\jason_han\.claude-second"`

再把 `assets/README_template.md` 複製成 `<out>/README.md` 並替換 `@@NAME@@`、`@@ALLOWED_TOOLS@@`、`@@CONFIG_DIR@@`。
寫一個 `<out>/requirements.txt`,內容一行:`claude-agent-sdk>=0.2.102`。

### 4. 回報
告訴使用者:
- 產出位置、檔案清單。
- 怎麼跑(見下),並提醒「多數 skill 需 `--write` 才跑得動;唯讀模式叫不動」。
- 五道關卡各擋什麼(可引用 `references/enforcement.md`)。

## 產出 agent 怎麼跑

```
# 在產出資料夾,先確保已 pip install -r requirements.txt(或用既有 venv 的 python)
python run.py "你的任務"           # 唯讀(安全)
python run.py --write "你的任務"   # 開放改檔/執行(多數 skill 需要)
python run.py                      # 互動模式
```

## 五道關卡(enforcement 摘要)

產出的 agent 同時用五道關卡把它鎖在單一 skill 上,細節見 `references/enforcement.md`:
1. **輸入預先過濾**(不呼叫模型):系統/設定/注入/「列出工具」等越界問句,直接回固定拒絕語。
2. **system prompt 硬邊界**:只准透過該 skill 做事,越界只回固定拒絕語。
3. **skills 鎖定**:`skills=[名稱]`,只暴露這一個 skill。
4. **執行期工具白名單**:`can_use_tool` 把 Skill 限定到該 skill,白名單以外的工具一律拒絕。
5. **訂閱計費防護**:啟動即擋 API 金鑰/雲端計費變數,確保走訂閱。

詳細設計與「為什麼要多層」見 `references/enforcement.md`(需要時再讀)。
