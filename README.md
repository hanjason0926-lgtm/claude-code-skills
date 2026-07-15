# Claude Code Skills

Claude Code 自訂技能（Skills）集合，用於強化 AI 輔助程式開發的行為準則。

## 什麼是 Skill？

Skill 是可在 Claude Code 中使用 `/skill-name` 呼叫的自訂指令。每個 Skill 以 `SKILL.md` 定義，包含行為準則或操作流程，讓 Claude 在特定情境下依照預設規範運作。

## 技能列表

| 目錄 | Skill 名稱 | 語言 | 說明 |
|------|-----------|------|------|
| `andrej-karpathy-skills/` | `karpathy-guidelines` | English | Behavioral guidelines to reduce common LLM coding mistakes |
| `andrej-karpathy-skills-zh/` | `karpathy-guidelines-zh` | 繁體中文 | 減少 LLM 常見程式錯誤的行為準則（中文版） |
| `text-to-motion/` | `text-to-motion` | 繁體中文 | 把文字敘述製作成動態簡報影片（MP4）／動圖（GIF）的完整流程：HyperFrames HTML 動畫 + ffmpeg，可控尺寸／fps／分段／檔案大小上限等 |
| `skill-to-agent/` | `skill-to-agent` | 繁體中文 | 把單一既有 skill 打包成獨立可執行的 claude-agent-sdk agent，並用五道關卡鎖定只能用該 skill、拒絕系統／設定／越界問題 |
| `skill-bakeoff/` | `skill-bakeoff` | English | 讓多個 skill 對同一份任務各做一版並排比較：支援指定 skill 清單或只給主題（自動上網搜尋、安全審查候選 skill），每個 skill 在獨立子代理平行執行，最後產出比較用 hub 頁面 |
| `project-spec-doc/` | `project-spec-doc` | 繁體中文 | 把 HTML 原型整理成正式的企劃／功能規格文件，同時產出 Word（.docx）簽核版與單檔 HTML 客戶對焦版；內含 EventFlow 範例文件 |
| — | [`skill-creator`](https://github.com/anthropics/skills/tree/main/skills/skill-creator) | English | Anthropic 官方 skill 製作工具，用於建立新的 Claude Code skill |
| — | [`hyperframes`](https://github.com/heygen-com/hyperframes) | CLI | 將 HTML + GSAP 動畫在無頭瀏覽器中逐格擷取、render 成 MP4 影片的工具 |
| — | [`superpowers`](https://github.com/obra/superpowers) | English | obra 的 agentic skills 框架／開發方法論：自動串接 brainstorm → TDD → 計劃 → 程式審查 → 系統化除錯等流程，以 plugin 方式安裝 |

## 參考資源

- [anthropics/skills](https://github.com/anthropics/skills) — Anthropic 官方 skill 範本、工具與規格文件
- [multica-ai/andrej-karpathy-skills](https://github.com/multica-ai/andrej-karpathy-skills) — karpathy-guidelines skill 原始來源
- [obra/superpowers](https://github.com/obra/superpowers) — agentic skills 框架與軟體開發方法論（brainstorm／TDD／計劃／審查／除錯），可作為 plugin 安裝
