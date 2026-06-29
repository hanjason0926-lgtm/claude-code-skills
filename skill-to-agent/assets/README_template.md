# @@NAME@@-agent

由 `skill-to-agent` 產生的獨立 agent。**只透過 `@@NAME@@` 這個 skill 工作**,並用五道關卡擋掉系統/設定/實作問題與 skill 邊界以外的請求。

## 安裝

```powershell
py -m venv .venv
.venv\Scripts\Activate.ps1
pip install -r requirements.txt
```
(或直接用你既有、已裝好 claude-agent-sdk 的 venv 來跑 `run.py`。)

## 使用

```powershell
.venv\Scripts\python.exe run.py "你的任務"          # 唯讀(安全)
.venv\Scripts\python.exe run.py --write "你的任務"  # 開放改檔/執行(多數 skill 需要)
.venv\Scripts\python.exe run.py                     # 互動模式
```

⚠️ **多數 skill 要跑外部工具(Bash 等),唯讀模式叫不動,要實際執行請加 `--write`。**

## 設定(產生時已填入)

- skill:`@@NAME@@`
- 工具白名單:`@@ALLOWED_TOOLS@@`
- Claude 設定目錄(帳號):`@@CONFIG_DIR@@`

## 五道關卡

1. 輸入預先過濾:系統/設定/注入/越界問句,不呼叫模型直接拒絕。
2. system prompt 硬邊界:只准透過該 skill 做事。
3. `skills=["@@NAME@@"]`:只暴露這一個 skill。
4. `can_use_tool` 執行期白名單:白名單以外工具一律拒絕,Skill 限定本 skill。
5. 訂閱計費防護:啟動即擋 API 金鑰/雲端計費變數。

## 前提

需先用 `claude` 登入訂閱帳號;這個 agent 只走 Claude Code 訂閱用量,不走 API 計費。
