# MP4 → GIF 管線(text-to-motion 用)

## 標準指令(scripts/make_gifs.sh 內建的就是這套)

```bash
ffmpeg -y -ss <起點秒> -t <長度秒> -i 影片.mp4 \
  -vf "fps=15,scale=440:250:force_original_aspect_ratio=decrease,pad=440:250:(ow-iw)/2:(oh-ih)/2,split[s0][s1];[s0]palettegen=stats_mode=diff[p];[s1][p]paletteuse=dither=bayer:bayer_scale=3" \
  -loop 0 輸出.gif
```

各環節的理由:

- **palettegen/paletteuse**:GIF 只有 256 色,不做兩段式調色盤會有明顯色塊。`stats_mode=diff` 把調色盤預算花在會動的區域,適合背景固定的簡報動畫。`dither=bayer:bayer_scale=3` 在漸層底色上比預設 floyd_steinberg 雜訊低、檔案小。
- **`-ss` 放在 `-i` 前**:現代 ffmpeg 會先 keyframe seek 再精確解碼到目標時間,快且準。
- **`-loop 0`**:無限循環。

## fps 取樣等距規則

GIF fps 必須整除來源 fps,否則抽格不等距、平滑移動會抖:

| 來源 30fps 可取 | 30 / 15 / 10 / 6 / 5 |
|---|---|
| 不要取 | 20、25、12.5(不等距);12 勉強可但 15 更順且簡報動畫下檔案幾乎一樣大 |

預設 15。使用者嫌卡就上 30(檔案約 2.5 倍),嫌大就降 10。

## 循環模式(-loop)

| 值 | 行為 |
|---|---|
| `-loop 0` | 無限循環(預設) |
| `-loop -1` | 播一次停在最後一格 |
| `-loop N` | 播完再重播 N 次(共 N+1 次) |

## 色彩數(palettegen max_colors)

`palettegen=stats_mode=diff:max_colors=N`,N 預設 256。降到 128 通常省約三成大小、
漸層底色略增條紋感;96 以下開始明顯。搭配 `dither=bayer:bayer_scale=4~5` 可再壓噪省一點。

## 大小調參階梯(有檔案上限或單檔 >8MB 時)

依序嘗試,每步重測大小,達標就停,回報時說明用了哪幾步:

1. fps 降一檔:15 → 10 → 6
2. 色彩數:256 → 128 → 96
3. 尺寸等比例縮:例 440x250 → 360x205(跟使用者確認過才動,尺寸通常是硬需求)
4. 縮短秒數或改分段:整合 GIF >20 秒本來就容易破 10MB,分段常是更好的答案

尺寸是使用者指定的就不要動第 3 步,直接跳第 4 步並回報權衡。

## MP4 交付解析度縮放

母片固定 1080p render(品質與後續重切的彈性),使用者要小檔交付時再縮:

```bash
ffmpeg -y -i 母片.mp4 -vf "scale=1280:720:flags=lanczos" -c:v libx264 -crf 18 -preset slow -pix_fmt yuv420p -movflags +faststart 交付_720p.mp4
```

## 比例處理三模式

| 模式 | filter 片段 | 效果 |
|------|------------|------|
| pad(預設) | `scale=W:H:force_original_aspect_ratio=decrease,pad=W:H:(ow-iw)/2:(oh-ih)/2` | 保比例裝進去,補黑邊 |
| crop | `scale=W:H:force_original_aspect_ratio=increase,crop=W:H` | 保比例填滿,裁掉超出 |
| stretch | `scale=W:H` | 直接拉伸,可能變形 |

1920x1080 → 440x250 的比例差很小(1.778 vs 1.76),pad 模式黑邊只有上下各約 1px。

## cuts.txt 格式

```
# 名稱|起點秒|長度秒
01_標題|0|7.2667
02_痛點|9.2667|7.0333
```

切點來源優先序:

1. **scenes.json 乾淨窗口**(本 skill 產的影片都有):分段 = `[start+stable_in, start+exit_start]`,第一段從 `start` 開始。
2. **外來影片沒有 scenes.json**:用逐格亮度找轉場。把影片 dump 成逐格 jpg 或直接對 mp4 跑:
   ```bash
   ffmpeg -i in.mp4 -vf "signalstats,metadata=print:key=lavfi.signalstats.YAVG" -f null - 2>&1 | grep -E 'pts_time|YAVG'
   ```
   亮度平台 = 畫面穩定,單調下降/上升 = 淡出/淡入。轉場叢集也可用 `scdet` 粗定位再用 YAVG 收斂。
   肉眼看起來乾淨的格,像素統計可能已經開始變了,以量測為準、保守取點。

## 驗證

make_gifs.sh 會自動抽每檔第一格與最後一格到 `<outdir>/_verify/`。逐張 Read 檢查:

- 第一格:完整不透明畫面,無前段殘影(第一段的打入動畫初始狀態除外)
- 最後一格:未開始淡出、變暗

有問題就調該段切點(殘影:起點 +0.07 起跳;淡出:長度 -0.07 起跳)重產單檔。確認後刪 `_verify/`。

## MP4 分段(使用者要分段影片而非 GIF 時)

同一份 cuts.txt,逐行:

```bash
ffmpeg -y -ss <起點> -t <長度> -i 影片.mp4 -c:v libx264 -crf 18 -preset slow -pix_fmt yuv420p -movflags +faststart 輸出段.mp4
```

任意時間點切必須重編碼(stream copy 只能切在 keyframe),crf 18 視覺無損。

## 整合單檔的循環考量

單檔 GIF 結尾若是淡黑,循環回第一格會閃一下。把終點設在最後一個場景的 `start + exit_start`,
不要包含全片結尾淡出。MP4 整合檔則保留完整結尾。
