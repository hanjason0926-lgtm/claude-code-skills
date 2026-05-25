# Claude Code Skills

Claude Code 自訂技能（Skills）集合，用於強化 AI 輔助程式開發的行為準則。

## 什麼是 Skill？

Skill 是可在 Claude Code 中使用 `/skill-name` 呼叫的自訂指令。每個 Skill 以 `SKILL.md` 定義，包含行為準則或操作流程，讓 Claude 在特定情境下依照預設規範運作。

## 技能列表

| 目錄 | Skill 名稱 | 語言 | 說明 |
|------|-----------|------|------|
| `andrej-karpathy-skills/` | `karpathy-guidelines` | English | Behavioral guidelines to reduce common LLM coding mistakes |
| `andrej-karpathy-skills-zh/` | `karpathy-guidelines-zh` | 繁體中文 | 減少 LLM 常見程式錯誤的行為準則（中文版） |
| — | [`skill-creator`](https://github.com/anthropics/skills/tree/main/skills/skill-creator) | English | Anthropic 官方 skill 製作工具，用於建立新的 Claude Code skill |

## 參考資源

- [anthropics/skills](https://github.com/anthropics/skills) — Anthropic 官方 skill 範本、工具與規格文件
- [multica-ai/andrej-karpathy-skills](https://github.com/multica-ai/andrej-karpathy-skills) — karpathy-guidelines skill 原始來源
