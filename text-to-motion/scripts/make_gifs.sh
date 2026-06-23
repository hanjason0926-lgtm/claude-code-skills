#!/usr/bin/env bash
# make_gifs.sh — 依 cuts.txt 把 MP4 切成多個高品質 GIF,並抽頭尾格供驗證
# 用法: bash make_gifs.sh VIDEO CUTS_FILE OUTDIR [WxH] [FPS] [pad|crop|stretch] [COLORS] [LOOP]
#   COLORS: palettegen 色彩數 2~256
#   LOOP:   0=無限循環, -1=播一次, N=再重播 N 次
# cuts.txt 每行: 名稱|起點秒|長度秒   (# 開頭為註解)
#
# ⚠ 預設值的單一來源是 config/defaults.json(gif.width/height/fps/aspect_mode/colors/loop)。
#   正式產出時,呼叫端(SKILL.md Step 4)必須先讀 defaults.json 並把對應數值「明確帶進參數」。
#   下方 ${4:-...} 等 fallback 僅為「沒帶參數時的保底」,不是權威預設,請勿當成預設值的依據,
#   也不要靠它與 defaults.json「保持同步」——同步的責任在呼叫端傳參,不在這裡。
set -euo pipefail

VIDEO="$1"; CUTS="$2"; OUTDIR="$3"
# 以下 fallback 僅保底用;正式呼叫一律由 SKILL.md 流程依 defaults.json 傳入
SIZE="${4:-960x540}"; FPS="${5:-15}"; MODE="${6:-pad}"
COLORS="${7:-256}"; LOOP="${8:-0}"
W="${SIZE%x*}"; H="${SIZE#*x}"

case "$MODE" in
  pad)     SCALE="scale=${W}:${H}:force_original_aspect_ratio=decrease,pad=${W}:${H}:(ow-iw)/2:(oh-ih)/2" ;;
  crop)    SCALE="scale=${W}:${H}:force_original_aspect_ratio=increase,crop=${W}:${H}" ;;
  stretch) SCALE="scale=${W}:${H}" ;;
  *) echo "未知比例模式: $MODE (用 pad/crop/stretch)" >&2; exit 1 ;;
esac

VF="fps=${FPS},${SCALE},split[s0][s1];[s0]palettegen=stats_mode=diff:max_colors=${COLORS}[p];[s1][p]paletteuse=dither=bayer:bayer_scale=3"
VDIR="$OUTDIR/_verify"
mkdir -p "$OUTDIR" "$VDIR"

while IFS='|' read -r name ss t; do
  name="$(echo "$name" | xargs)"
  [[ -z "$name" || "$name" == \#* ]] && continue
  out="$OUTDIR/${name}.gif"
  ffmpeg -y -v error -ss "$ss" -t "$t" -i "$VIDEO" -vf "$VF" -loop "$LOOP" "$out"

  dims=$(ffprobe -v error -select_streams v:0 -show_entries stream=width,height -of csv=p=0 "$out")
  n=$(ffprobe -v error -select_streams v:0 -count_frames -show_entries stream=nb_read_frames -of csv=p=0 "$out")
  kb=$(du -k "$out" | cut -f1)

  ffmpeg -y -v error -i "$out" -frames:v 1 "$VDIR/${name}_first.png"
  ffmpeg -y -v error -i "$out" -vf "select=eq(n\,$((n-1)))" -frames:v 1 "$VDIR/${name}_last.png"

  status="OK"
  [[ "$dims" != "${W},${H}" ]] && status="尺寸異常!"
  warn=""
  [[ "$kb" -gt 8192 ]] && warn="  [>8MB 警示:考慮降 fps/減色/分段]"
  echo "${status} ${name}.gif ${dims} frames=${n} ${kb}KB ss=${ss} t=${t}${warn}"
done < "$CUTS"

echo "驗證用頭尾格在: $VDIR (逐張檢查後請刪除)"
