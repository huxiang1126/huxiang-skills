// Renders every poster in build/shots.json with headless Chrome: build/posters/<id>/<k>.jpg
// Posters whose spec is unchanged since the last run are skipped.  Usage: node tools/shoot.mjs [id-prefix ...]
import puppeteer from "puppeteer-core";
import fs from "fs";
import path from "path";
import crypto from "crypto";

const ROOT = path.dirname(path.dirname(new URL(import.meta.url).pathname));
const shots = JSON.parse(fs.readFileSync(path.join(ROOT, "build/shots.json"), "utf8"));
const only = process.argv.slice(2);
const browser = await puppeteer.launch({ headless: "new", executablePath: process.env.CHROME || "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome",
  args: ["--no-sandbox", "--force-device-scale-factor=1", "--allow-file-access-from-files"] });
const page = await browser.newPage();
await page.setViewport({ width: 1080, height: 1350, deviceScaleFactor: 1 });
await page.goto("file://" + path.join(ROOT, "tools/poster.html"));
let n = 0, skipped = 0;
for (const s of shots) {
  if (only.length && !only.some(p => s.id.startsWith(p))) continue;
  const dir = path.join(ROOT, "build/posters", s.id);
  const hash = crypto.createHash("md5").update(JSON.stringify(s) + fs.statSync(path.join(ROOT, "tools/poster.html")).mtimeMs).digest("hex");
  const hf = path.join(dir, ".hash");
  if (!only.length && fs.existsSync(hf) && fs.readFileSync(hf, "utf8") === hash) { skipped++; continue; }
  fs.mkdirSync(dir, { recursive: true });
  const K = process.env.FIRST ? 1 : s.zs.length;
  for (let k = 0; k < K; k++) {
    const missing = await page.evaluate(async (spec) => await window.render(spec), { ...s.spec, z: s.zs[k] });
    if (missing.length) console.log("MISSING", s.id, missing);
    await page.screenshot({ path: path.join(dir, `${String(k).padStart(3, "0")}.jpg`), type: "jpeg", quality: 94 });
    n++;
  }
  if (!process.env.FIRST) fs.writeFileSync(hf, hash);
}
await browser.close();
console.log(`rendered ${n} frames, skipped ${skipped} posters`);
