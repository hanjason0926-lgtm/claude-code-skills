# Claude Code Skills & Plugins

Claude Code 的自訂技能（Skills）與外掛（Plugins）整理集合，用於強化 AI 輔助程式開發的流程與行為準則。

## 什麼是 Skill？

Skill 是可在 Claude Code 中使用 `/skill-name` 呼叫的自訂指令。每個 Skill 以 `SKILL.md` 定義，包含行為準則或操作流程，讓 Claude 在特定情境下依照預設規範運作。

## 什麼是 Plugin？

Plugin 是可透過 `/plugin marketplace add` 加入來源、再用 `/plugin install` 安裝的擴充套件。一個 Plugin 可同時打包多個 skill、slash 指令、subagent 與 hook，用來擴充 Claude Code 的開發流程與協作模式。

## Skills

| 目錄 | Skill 名稱 | 語言 | 說明 |
|------|-----------|------|------|
| — | [`karpathy-guidelines`](https://github.com/multica-ai/andrej-karpathy-skills) | English | Behavioral guidelines to reduce common LLM coding mistakes |
| `andrej-karpathy-skills-zh/` | `karpathy-guidelines-zh` | 繁體中文 | 減少 LLM 常見程式錯誤的行為準則（中文版） |
| `text-to-motion/` | `text-to-motion` | 繁體中文 | 把文字敘述製作成動態簡報影片（MP4）／動圖（GIF）的完整流程：HyperFrames HTML 動畫 + ffmpeg，可控尺寸／fps／分段／檔案大小上限等 |
| `skill-to-agent/` | `skill-to-agent` | 繁體中文 | 把單一既有 skill 打包成獨立可執行的 claude-agent-sdk agent，並用五道關卡鎖定只能用該 skill、拒絕系統／設定／越界問題 |
| `skill-bakeoff/` | `skill-bakeoff` | English | 讓多個 skill 對同一份任務各做一版並排比較：支援指定 skill 清單或只給主題（自動上網搜尋、安全審查候選 skill），每個 skill 在獨立子代理平行執行，最後產出比較用 hub 頁面 |
| `project-spec-doc/` | `project-spec-doc` | 繁體中文 | 把 HTML 原型整理成正式的企劃／功能規格文件，同時產出 Word（.docx）簽核版與單檔 HTML 客戶對焦版；內含 EventFlow 範例文件 |
| `dashboard-requirement-review/` | `dashboard-requirement-review` | 繁體中文 | 儀表板／報表／BI 需求的風險盤點：找出「做不出來」「會算錯但不報錯」「現在不問就永遠補不回來」的項目，產出可直接對焦的問題清單 |
| — | [`skill-creator`](https://github.com/anthropics/skills/tree/main/skills/skill-creator) | English | Anthropic 官方 skill 製作工具，用於建立新的 Claude Code skill |
| — | [`hyperframes`](https://github.com/heygen-com/hyperframes) | English | 把 HTML + CSS + 動畫（GSAP／Lottie／Three.js）在無頭瀏覽器中逐格擷取、render 成 MP4 影片的框架,內含 20 個影片工作流 skill 與 CLI |
| — | [`OpenMontage`](https://github.com/calesthio/OpenMontage) | English | 開源的 agentic 影片製作系統，內含 12 條 pipeline、52 種工具與 500+ agent skills，讓 AI 編程助理化身完整的影片製作工作室 |

## Plugins

| 名稱 | 說明 |
|------|------|
| [`superpowers`](https://github.com/obra/superpowers) | obra 的 agentic skills 框架／開發方法論：自動串接 brainstorm → TDD → 計劃 → 程式審查 → 系統化除錯等流程，以 plugin 方式安裝 |
| [`oh-my-claudecode`](https://github.com/Yeachan-Heo/oh-my-claudecode) | Teams-first 多代理協作框架，以 `/plugin` 安裝,內含多個專用 agent 與 Team／Autopilot／Ultrawork 等模式 |

## 參考資源

- [anthropics/skills](https://github.com/anthropics/skills) — Anthropic 官方 skill 範本、工具與規格文件
