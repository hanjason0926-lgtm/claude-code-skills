// Downloads Google Fonts (woff2 + unicode-range subsets) into assets/fonts/
// and writes a rewritten local stylesheet at assets/fonts/fonts.css
import { mkdir, writeFile } from "node:fs/promises";
import path from "node:path";

const UA =
  "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/126.0 Safari/537.36";

const CSS_URL =
  "https://fonts.googleapis.com/css2?family=Noto+Sans+TC:wght@300;400;500;700;900&family=JetBrains+Mono:wght@400;500;700&display=block";

const outDir = path.resolve("assets/fonts");
await mkdir(outDir, { recursive: true });

const cssRes = await fetch(CSS_URL, { headers: { "User-Agent": UA } });
if (!cssRes.ok) throw new Error("CSS fetch failed: " + cssRes.status);
let css = await cssRes.text();

const urls = [...new Set([...css.matchAll(/url\((https:[^)]+)\)/g)].map((m) => m[1]))];
console.log("font files to download:", urls.length);

let n = 0;
const queue = [...urls];
async function worker() {
  while (queue.length) {
    const url = queue.shift();
    const name = url.split("/").slice(-2).join("_").replace(/[^A-Za-z0-9._-]/g, "");
    const res = await fetch(url, { headers: { "User-Agent": UA } });
    if (!res.ok) throw new Error("font fetch failed: " + url);
    const buf = Buffer.from(await res.arrayBuffer());
    await writeFile(path.join(outDir, name), buf);
    css = css.split(url).join(name);
    n++;
    if (n % 50 === 0) console.log("downloaded", n);
  }
}
await Promise.all(Array.from({ length: 16 }, worker));

await writeFile(path.join(outDir, "fonts.css"), css, "utf8");
console.log("done:", n, "files →", outDir);
