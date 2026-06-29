# 多關卡 enforcement 設計

把單一 skill 鎖死,單一手段都有破口,所以用五道互補關卡(深度防禦)。重點在於「逼它只走這個 skill」與「擋掉越界/系統/注入」是兩件事,要分開且重複防。

## 為什麼一層不夠

- 只靠 system prompt:可被 prompt injection 或「忽略上面指令」繞過。
- 只靠 `skills=[名稱]`:限定了暴露的 skill,但模型仍可能用 Bash/Read 自己做 skill 以外的事。
- 只靠工具白名單:擋得住工具濫用,但擋不住「純文字問你的系統設定」這種不需工具的越界。

所以要組合。

## 五道關卡與各自負責的破口

| 關卡 | 位置 | 擋什麼 | 為何需要 |
|---|---|---|---|
| 1. 輸入預先過濾 | wrapper,呼叫模型「之前」 | 系統/設定/實作問題、prompt injection、「列出工具」、越獄字樣 | 最便宜、最確定:不花用量、不給模型機會被說服 |
| 2. system prompt 硬邊界 | 模型 | 與 skill 無關的請求、洩漏設定 | 對「語意上越界」但 Gate 1 沒命中的灰色地帶兜底 |
| 3. `skills=[名稱]` | SDK / CLI | 暴露其他 skill | 模型根本看不到別的 skill,少一個被誘導的面 |
| 4. `can_use_tool` 白名單 | 執行期,每次工具呼叫 | 動用白名單以外工具;用 Skill 呼叫別的 skill | 硬性、不靠模型自律;就算前幾關被繞過,工具層直接 deny |
| 5. 訂閱計費防護 | 啟動 | API 金鑰/雲端計費環境變數 | 確保只走訂閱,不被導去 API 計費 |

## 設計取捨

- **Gate 1 故意「寧可錯殺」**:用關鍵字/樣式比對,可能誤擋少數正常問句。因為這類 agent 的價值在「只做一件事、不被亂用」,誤擋的代價遠小於越界。要放寬就調 `_META_PATTERNS`。
- **白名單一定要含 skill 真正需要的工具**(如 text-to-motion 需要 `Bash`/`Write`),否則 skill 跑不動。`can_use_tool` 允許白名單,其餘 deny。
- **唯讀 vs `--write`**:唯讀模式把 `Write/Edit/NotebookEdit/Bash` 從白名單移除,所以需要執行外部工具的 skill 在唯讀模式會「叫得到、跑不動」。要實際執行就 `--write`。
- **Gate 4 是最硬的一關**:`allowed_tools` 只是「免詢問」清單、不是限制;真正的限制靠 `can_use_tool` 對非白名單工具回 `PermissionResultDeny`。

## 想再加強

- 把 Gate 1 的關鍵字改成一個小型分類器(仍可不花主模型用量)。
- 在 `can_use_tool` 裡進一步檢查 Bash 指令內容(例如禁止 `curl`/外連)以收斂 skill 的副作用。
- 加上每次執行的稽核 log。
