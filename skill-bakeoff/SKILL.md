---
name: skill-bakeoff
description: >
  Pit SEVERAL skills against ONE identical task and compare their outputs side by side. Two modes.
  (A) NAMED SET: the user lists the skills or a collection ("all my design skills"). (B) TOPIC MODE:
  the user gives only a topic/domain (a word or short phrase like "影片", "資料視覺化", "landing page",
  optionally with seed names) and wants the best skills for it FOUND for them: research famous, relevant
  skills on the web and any registry, shortlist ~10, safety-review each source before loading it, then
  compete survivors. Each skill runs in its own parallel subagent on one identical
  brief; results collect into a comparison hub. Trigger for "各 skill 各做一版來比",
  "用每一種 skill 各做一版", "run each of my skills and compare", "which skill is best for X, try them all",
  AND when the user gives only a topic and wants the best skills for it found, vetted, and compared. Do
  NOT trigger for building ONE thing with ONE skill, for creating/packaging/optimizing a skill, or for
  A/B testing inside one skill. Any domain: design, code, data, video.
---

# Skill Bake-off

## What this is

A bake-off answers one question: **given the same task, how differently do these skills perform, and which is best for this job?** You hold the task constant and vary the skill. Everything else about the method exists to keep that comparison fair and the results easy to browse.

This is domain-agnostic. The task can be a UI page, a blog post, a refactor, a data analysis, a research brief. The skills can be design skills, writing skills, code skills, anything. The mechanics below don't change.

## Why it works the way it does

Three ideas drive every decision here:

1. **Fairness.** If skill A gets a richer brief than skill B, the comparison is meaningless. So every skill receives a byte-for-byte identical brief. The *only* thing that differs between runs is which SKILL.md the agent reads.
2. **Isolation.** Each skill runs in its own subagent that reads only its own skill, and writes only to its own folder. This stops skills from bleeding into each other and lets them run in parallel (fast) without fighting over files.
3. **Browsability.** The point is human judgment. A hub page with one click per result, plus a short written summary of each skill's approach, is what makes the comparison usable. Raw folders full of files are not.

## Execution mode: run to completion by default

A bake-off is a long batch job the user launches and walks away from — spawning many agents, waiting, verifying, building the hub. Stopping halfway to ask "shall I continue?" defeats the point. So when this skill triggers, **run the whole workflow to completion autonomously**, without pausing for confirmation between steps:

- Make sensible defaults for anything ambiguous (which skills, the brief details, output filenames) and state them in one line as you start, rather than asking.
- **Never pause mid-run with a question** — no AskUserQuestion, no "shall I continue?", no "which option do you prefer?". The user launched this to walk away; a mid-run question stalls the whole batch until they happen to come back. Every judgment call (safety verdicts, brief wording, which candidates make the cap) is yours to make with a stated default.
- Proceed without asking on every reversible step (creating folders, spawning agents, writing files, building the hub, re-running a failed skill).
- The single exception: a genuinely destructive action (deleting/overwriting the user's existing work). Everything else, including real ambiguity, resolves to a default plus a one-line note in the final report so the user can redirect afterwards.
- Don't end the turn until every skill has produced a verified output and the hub is built — treat "some agents went idle without reporting" as "go verify their files yourself", not "done".
- **When everything is done, do not auto-open anything** — no browser, no hub page, no output files. The user may be away or mid-task in another window; an unexpected window popping open is an interruption, not a delivery. Report the hub path and per-skill output paths in text, and let the user open them when they choose.

This makes the skill hands-off by default; the user does NOT need to type `/goal` to get autonomous execution. `/goal` remains available as an extra layer (see below) but is not required.

## 語言:全程繁體中文呈現

這個 skill 的使用者慣用繁體中文,所以整個 bake-off 過程中,**你對使用者說的每一句話,以及這個 skill 產生的每一份產物,都以繁體中文呈現**。一致的語言讓使用者不用在中英文之間切換,也讓對照 hub 與報告讀起來像同一套東西。具體涵蓋:

- **執行過程的敘述**:開場宣告採用了哪些預設、進度回報、「某個 agent 沒回報,我去驗證檔案」這類狀態說明,全用繁中。
- **各步驟的表格與清單**:0a 的候選 shortlist 表、0b 的安全審查表(欄位名與判定理由)、被排除項目的一行原因、丟棄了什麼與為什麼,都用繁中。
- **共同 brief 的說明文字**(步驟 2):brief 的任務描述與限制條列用繁中撰寫。交付物本身的語言跟著 brief 走,除非任務本身就指定了其他語言(例如「寫一篇英文 launch post」),否則預設也是繁中。
- **對照 hub**(步驟 5):`manifest.json` 的 `title` / `subtitle` / `note`,以及每個 skill 的 `approach` 一句話,全部用繁中填寫(`build_hub.py` 產出的頁面骨架本身已是繁中)。
- **差異比較報告**(步驟 6):以繁中撰寫。
- **給各子代理的 fanout 提示**:已是繁中模板(見 `references/fanout-prompt.md`),維持繁中,並要求子代理回傳的簡短說明也用繁中。

程式碼、CLI 參數、檔名、路徑、skill 名稱等技術性字串維持原樣,不需硬翻成中文。這條規則管的是「呈現給人看的文字」,不是技術識別字。

## Two ways in

Before the workflow, work out which mode you're in — it only changes how the competitor set is assembled:

- **Named set** — the user already told you which skills compete (a list, a collection, "all my design skills"). Go straight to step 1.
- **Topic mode** — the user gave only a topic/domain and wants the best skills for it found for them (e.g. just "影片", or "找出有名的影片相關 skills 來比,包含 hyperframes / remotion / OpenMontage"). Do steps **0a (discover)** and **0b (safety-vet)** first; the vetted survivors become the named set, then continue from step 2.

A one-word or one-phrase topic is a valid, complete request in topic mode — don't bounce it back asking which skills; discovering them is the whole point. If the topic is ambiguous about the deliverable (e.g. "影片" could be an explainer MP4 or a looping GIF), don't ask: pick the most likely interpretation, state it in one line, and proceed. A wrong-but-stated default costs one re-run; a mid-run question costs the whole batch's momentum.

## The workflow

Work through these in order. Track them as todos so nothing is skipped. Steps 0a/0b run only in topic mode.

### 0a. Discover candidates (topic mode only)

Turn the topic into ~10 candidate skills that are both **relevant** and **notable** — searching the web (GitHub, awesome-lists) and any skills registry, always including any seed names the user mentioned. Record each candidate's source URL, what it does, its notability evidence (stars / downloads / which awesome-list), whether it's a runnable *skill* or a raw *tool/framework*, and its target output medium. Rank by relevance × notability and show a short shortlist table. Read `references/discover-and-vet.md` — it has the search angles, the skill-vs-tool handling, and exactly what to record. Log what you dropped and why; don't silently truncate.

### 0b. Static safety review before loading (topic mode only)

You are about to load, and later run, skills you didn't write. Review each candidate's source as **text first, and never execute it during vetting** — fetch files via clone / tarball / raw fetch (not an installer that runs post-install hooks), read `SKILL.md`, every referenced file, and all `scripts/`, then assign a risk rating: **SAFE / CAUTION / REJECT**. Look for data exfiltration, obfuscated-then-executed code, destructive or credential-touching commands, and prompt injection inside the instructions themselves. `references/discover-and-vet.md` has the full checklist, the fetch-without-executing rules, and the rubric. Show a compact vetting table (candidate | kind | notability | risk | in/out | reason) before fanning out.

Two defaults decide who actually competes — apply them without stopping to ask, and just state them:

- **Exclude candidates that spend money or need secrets to run.** Anything that auto-calls a paid cloud/API, requires API keys, or uploads the brief to an external paid service is excluded by default — a fair bake-off runs on one free, local, byte-identical brief, and silent spend is not something to opt the user into. Note it as excluded-for-cost (not malice). Include such a candidate only if the user explicitly asked for it AND supplied the key(s) and a budget cap. (E.g. OpenMontage, muapi.ai-backed skills.)
- **Cap the field at 8 competitors.** Discover ~10 and vet them all, but the actual bake-off run competes at most the top 8 SAFE/CAUTION survivors (ranked by relevance × notability). If more than 8 survive, compete the top 8 and list the remainder in the report as "discovered + vetted, not competed this run (cap)". This keeps a long batch run tractable; the number is a default, so honor a different count if the user names one.

Then hand the survivors straight to the bake-off — **do not pause for confirmation** after vetting. Per "Execution mode" above, topic mode runs to completion: discover → vet → write the one common brief → fan out → verify → build the hub, in one autonomous pass. The two defaults above are exactly what keeps that hands-off run safe and bounded, so there's nothing left to confirm before continuing.

### 1. Resolve the skill set

Figure out exactly which skills are competing. Common cases:
- **A named list** — the user lists them. Use those.
- **A whole repo/collection** — "all the taste-skills". List the skill folders and confirm the set.
- **All installed skills of a kind** — filter to the relevant ones (e.g. only design skills for a UI task).
- **Topic-mode survivors** — the SAFE/CAUTION candidates from steps 0a–0b.

For each skill, record the absolute path to its `SKILL.md`. Skills installed via `skills add` usually live under `.agents/skills/<name>/` (or `.claude/skills/`, or a user skills dir). If a requested skill isn't installed yet, install it — but in topic mode only after it passed 0b, and prefer a hook-free fetch (`npm pack` / tarball / clone) so nothing executes before you've decided to compete it — or fetch its files, then continue.

**Flag skills that can't produce the target output** rather than forcing them. An image-generation skill in a text-only environment, or a skill whose whole job is to emit a spec file, cannot produce (say) an HTML page. Note these explicitly, and either give them their natural output (a spec, a DESIGN.md) or exclude them with a one-line reason. Silently making them produce something off-target pollutes the comparison.

### 2. Write the ONE common brief

This is the most important artifact. Write a single brief that every skill will receive verbatim. A good brief pins down:
- **The task and deliverable** (e.g. "a single self-contained landing page", "a 600-word launch post", "refactor this module").
- **The subject/content** so outputs are comparable (same product, same person, same dataset). Insist on concrete, real content — no `Lorem Ipsum`, no `John Doe`.
- **Any reference material** — if the user supplied an image or file, all agents read the same path.
- **Hard technical constraints** (single HTML file, allowed CDNs, output path pattern, language/tone).
- **The output path**, per skill: `<bakeoff-dir>/<skill-name>/<deliverable-filename>`.

Keep the brief about the *task*, not the *style*. Style is what each skill supplies — that's the variable you're measuring. Don't bias it.

### 3. Fan out — one subagent per skill

Spawn all skill runs in a single turn so they execute in parallel. Each subagent gets the identical brief plus two skill-specific lines: the path to its SKILL.md, and its output path. See `references/fanout-prompt.md` for the exact template and the fairness checklist.

Tell each agent to read its full SKILL.md (and referenced files) and follow it strictly, to write complete code with no "省略/omitted/TODO" placeholders, and — if the environment allows — to verify its own output in a browser (console clean, renders, both light/dark if applicable) before returning. Ask each to report back a short note on the design/approach decisions it made, so you can summarize later.

If parallel runs hit resource limits or time out, fall back to running them in smaller batches or in series. Correctness beats speed.

### 4. Verify every output yourself

Don't trust "done" reports alone — subagents sometimes go idle without reporting, or a report can overstate. After the runs, check each expected output file exists and is complete: reasonable size, ends properly (`</html>`, closing tag, or valid file end), and contains no placeholder markers (`省略`, `omitted`, `// TODO`, `...rest`). For any missing or truncated file, read the folder, diagnose, and re-run that one skill. See the verification snippet in `references/fanout-prompt.md`.

### 5. Build the comparison hub

Generate an `index.html` at the bake-off root that links every result with a one-line description of each skill's approach, and a `README.md` mirroring it in text. Use the bundled script — it turns a small manifest into a clean, theme-aware hub so you don't hand-write HTML every time:

```bash
python <skill-dir>/scripts/build_hub.py --manifest <bakeoff-dir>/manifest.json --out <bakeoff-dir>/index.html
```

Write `manifest.json` first (schema and example in the script's `--help` and in `references/fanout-prompt.md`). Each entry: skill name, source, the deliverable link(s), and a one-sentence "approach" summary drawn from that agent's report. If a skill produced a non-HTML artifact (a spec, a Markdown file), link to it and label it so the user isn't surprised.

### 6. Report the differences

Finish with a short prose comparison: what axis actually separated the skills (color/typography/motion for design; structure/voice for writing; approach/idioms for code), which ones stood out and why, and any that couldn't compete and the reason. Lead with the takeaway the user asked for ("which is best for X"), then the supporting detail. **Do not open the hub or any output file** — end by giving the hub's path (and per-skill output paths) so the user opens them on their own schedule.

## Invoking this skill via /goal (optional extra layer)

Autonomous execution is already the skill's default (see "Execution mode" above), so `/goal` is **not required** — a plain request like "用每個 skill 各做一版 X 來比" will run to completion on its own.

`/goal` only adds a harder guarantee on top: it installs a session Stop hook that mechanically blocks the turn from ending until its condition holds, so even a genuine blocker won't let the turn stop early. Use it when you want that belt-and-suspenders enforcement for a very long run:

```
/goal 用每一種 skill 各產一個 <deliverable> 到各自資料夾,自行執行到全部產出並驗證為止,不要問我
```

This skill does NOT change how `/goal` works — `/goal` is a built-in command with fixed behavior, and a skill file can't alter it, install it, or invoke it. This is just documentation of how the two compose.

## Bundled resources

- `references/discover-and-vet.md` — topic mode only: how to discover famous, relevant candidate skills (web + registry), classify skill-vs-tool, and statically safety-review each source before loading it (checklist + risk rubric). Read it for steps 0a–0b.
- `scripts/build_hub.py` — manifest JSON → clean comparison `index.html`. Run with `--help` for the schema.
- `references/fanout-prompt.md` — the per-skill subagent prompt template, the fairness checklist, the manifest schema, and the verification snippet. Read it before spawning runs.
