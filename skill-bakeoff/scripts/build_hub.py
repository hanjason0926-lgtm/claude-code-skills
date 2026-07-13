#!/usr/bin/env python3
"""Build a comparison hub index.html for a skill bake-off from a manifest JSON.

The manifest holds one entry per competing skill (name, source, one-line approach,
and one or more result links). This script renders a clean, theme-aware hub page so
the hub never has to be hand-written.

Usage:
    python build_hub.py --manifest <manifest.json> --out <index.html>

Manifest schema:
    {
      "title": "optional page title",
      "subtitle": "optional one-line description",
      "note": "optional footer note (e.g. CDN dependency caveat)",
      "entries": [
        {
          "skill": "skill-name",                 # required
          "source": "owner/repo",                # optional
          "approach": "one sentence summary",     # optional but recommended
          "links": [                              # required, >=1
            {"label": "Landing", "href": "skill-name/index.html"}
          ]
        }
      ]
    }
"""
import argparse
import html
import json
import sys
from pathlib import Path

PAGE = """<!DOCTYPE html>
<html lang="zh-Hant">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>{title}</title>
<style>
  :root {{ color-scheme: light dark; }}
  * {{ margin: 0; padding: 0; box-sizing: border-box; }}
  body {{
    font-family: 'PingFang TC', 'Microsoft JhengHei', system-ui, sans-serif;
    background: #FAFAF8; color: #1c1c1a; line-height: 1.65; padding: 56px 24px;
  }}
  @media (prefers-color-scheme: dark) {{
    body {{ background: #151412; color: #ECEAE4; }}
    .card {{ background: #1E1C19; border-color: #33302B; }}
    .meta, .src {{ color: #98938A; }}
    .links a {{ background: #2A2723; border-color: #3A362F; color: #ECEAE4; }}
  }}
  .wrap {{ max-width: 880px; margin: 0 auto; }}
  h1 {{ font-size: 30px; letter-spacing: -0.01em; margin-bottom: 8px; }}
  .sub {{ color: #767065; margin-bottom: 40px; }}
  .grid {{ display: grid; gap: 14px; }}
  .card {{
    background: #FFFFFF; border: 1px solid #E7E5DF; border-radius: 10px;
    padding: 22px 26px; display: flex; align-items: center;
    justify-content: space-between; gap: 20px; flex-wrap: wrap;
  }}
  .card h2 {{ font-size: 17px; margin-bottom: 4px; font-family: ui-monospace, monospace; }}
  .meta {{ font-size: 13px; color: #767065; }}
  .src {{ font-size: 12px; color: #9A948A; margin-top: 4px; }}
  .links {{ display: flex; gap: 8px; flex-shrink: 0; flex-wrap: wrap; }}
  .links a {{
    display: inline-block; text-decoration: none; color: #1c1c1a; font-size: 13px;
    padding: 8px 16px; background: #F4F3EF; border: 1px solid #E7E5DF;
    border-radius: 6px; transition: border-color .15s;
  }}
  .links a:hover {{ border-color: #B9B4A8; }}
  .note {{ margin-top: 44px; font-size: 13.5px; color: #767065; }}
</style>
</head>
<body>
<div class="wrap">
  <h1>{title}</h1>
  <p class="sub">{subtitle}</p>
  <div class="grid">
{cards}
  </div>
{note}
</div>
</body>
</html>
"""

CARD = """    <div class="card">
      <div>
        <h2>{skill}</h2>
        {approach}
        {source}
      </div>
      <div class="links">{links}</div>
    </div>"""


def esc(s):
    return html.escape(str(s), quote=True)


def render_card(entry):
    skill = esc(entry.get("skill", "(unnamed)"))
    approach = entry.get("approach")
    source = entry.get("source")
    approach_html = f'<p class="meta">{esc(approach)}</p>' if approach else ""
    source_html = f'<p class="src">來源:{esc(source)}</p>' if source else ""
    links = entry.get("links") or []
    if not links:
        links_html = '<span class="src">(無連結)</span>'
    else:
        links_html = "".join(
            f'<a href="{esc(l["href"])}">{esc(l.get("label", "開啟"))}</a>' for l in links
        )
    return CARD.format(skill=skill, approach=approach_html, source=source_html, links=links_html)


def main():
    ap = argparse.ArgumentParser(description="Build a bake-off comparison hub from a manifest JSON.")
    ap.add_argument("--manifest", required=True, help="Path to manifest.json")
    ap.add_argument("--out", required=True, help="Output index.html path")
    args = ap.parse_args()

    manifest_path = Path(args.manifest)
    try:
        data = json.loads(manifest_path.read_text(encoding="utf-8"))
    except FileNotFoundError:
        sys.exit(f"error: manifest not found: {manifest_path}")
    except json.JSONDecodeError as e:
        sys.exit(f"error: manifest is not valid JSON: {e}")

    entries = data.get("entries")
    if not entries:
        sys.exit("error: manifest has no 'entries'")

    title = esc(data.get("title", "Skill 對照測試"))
    subtitle = esc(data.get("subtitle", "同一份任務,多個 skill 各自產出,比較風格與品質。"))
    note_text = data.get("note")
    note_html = f'<p class="note">{esc(note_text)}</p>' if note_text else ""

    cards = "\n".join(render_card(e) for e in entries)
    page = PAGE.format(title=title, subtitle=subtitle, cards=cards, note=note_html)

    out_path = Path(args.out)
    out_path.parent.mkdir(parents=True, exist_ok=True)
    out_path.write_text(page, encoding="utf-8")
    print(f"wrote {out_path}  ({len(entries)} entries, {out_path.stat().st_size} bytes)")


if __name__ == "__main__":
    main()
