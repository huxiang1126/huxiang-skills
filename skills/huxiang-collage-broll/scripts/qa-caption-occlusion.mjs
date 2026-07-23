#!/usr/bin/env node
import {createServer} from "node:http";
import {readFile, writeFile, access, mkdtemp, rm} from "node:fs/promises";
import {createReadStream} from "node:fs";
import {extname, join, normalize, relative, resolve} from "node:path";
import {tmpdir} from "node:os";
import {spawn} from "node:child_process";

if (process.argv.length !== 5) {
  console.error("Usage: qa-caption-occlusion.mjs <hyperframes-project-dir> <caption-safe-zones.json> <report.json>");
  process.exit(2);
}

const projectDir = resolve(process.argv[2]);
const configPath = resolve(process.argv[3]);
const reportPath = resolve(process.argv[4]);
let reportExists = true;
try {
  await access(reportPath);
} catch (error) {
  if (error.code === "ENOENT") reportExists = false;
  else throw error;
}
if (reportExists) throw new Error(`Refusing to overwrite existing report; choose a new versioned path: ${reportPath}`);
const config = JSON.parse(await readFile(configPath, "utf8"));
if (config.version !== "2.3.0") throw new Error(`Expected caption-safe-zones version 2.3.0, got ${config.version ?? "missing"}`);

const mime = {
  ".html": "text/html; charset=utf-8",
  ".js": "text/javascript; charset=utf-8",
  ".json": "application/json; charset=utf-8",
  ".css": "text/css; charset=utf-8",
  ".mp4": "video/mp4",
  ".wav": "audio/wav",
  ".ttf": "font/ttf",
  ".ttc": "font/collection",
  ".png": "image/png",
  ".jpg": "image/jpeg",
  ".jpeg": "image/jpeg",
  ".webp": "image/webp"
};

const server = createServer(async (request, response) => {
  const requestPath = decodeURIComponent((request.url || "/").split("?")[0]);
  const requestedRelative = requestPath === "/" ? "index.html" : requestPath.replace(/^\/+/, "");
  const filePath = normalize(join(projectDir, requestedRelative));
  const escaped = relative(projectDir, filePath).startsWith("..");
  if (escaped) {
    response.writeHead(403).end("Forbidden");
    return;
  }
  try {
    await access(filePath);
    response.writeHead(200, {"content-type": mime[extname(filePath)] || "application/octet-stream"});
    createReadStream(filePath).pipe(response);
  } catch {
    response.writeHead(404).end("Not found");
  }
});

const wait = (milliseconds) => new Promise((resolveWait) => setTimeout(resolveWait, milliseconds));
const interpolateRegion = (region, time) => {
  const frames = [...region.keyframes].sort((left, right) => left.at - right.at);
  if (frames.length === 1 || time <= frames[0].at) return {...frames[0]};
  if (time >= frames.at(-1).at) return {...frames.at(-1)};
  const rightIndex = frames.findIndex((frame) => frame.at >= time);
  const left = frames[rightIndex - 1];
  const right = frames[rightIndex];
  const progress = (time - left.at) / (right.at - left.at);
  const value = (field) => left[field] + (right[field] - left[field]) * progress;
  return {at: time, x: value("x"), y: value("y"), width: value("width"), height: value("height")};
};
const sampleTimes = (beat) => {
  if (Array.isArray(beat.samples) && beat.samples.length >= 3) return [...new Set(beat.samples)].sort((a, b) => a - b);
  const duration = beat.end - beat.start;
  const interval = config.sample_interval_seconds;
  const times = [beat.start + Math.min(0.04, duration * 0.02)];
  for (let time = beat.start + interval; time < beat.end; time += interval) times.push(time);
  times.push(beat.start + duration * 0.5, beat.end - Math.min(0.04, duration * 0.02));
  return [...new Set(times.map((time) => Number(time.toFixed(4))))].sort((a, b) => a - b);
};

let chrome;
let socket;
let profileDir;
let servePort;
try {
  await new Promise((resolveListen) => server.listen(0, "127.0.0.1", resolveListen));
  servePort = server.address().port;

  const chromeCandidates = [
    process.env.CHROME_PATH,
    "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome",
    "/Applications/Google Chrome Canary.app/Contents/MacOS/Google Chrome Canary",
    "/Applications/Chromium.app/Contents/MacOS/Chromium"
  ].filter(Boolean);
  let chromePath = "";
  for (const candidate of chromeCandidates) {
    try {
      await access(candidate);
      chromePath = candidate;
      break;
    } catch {}
  }
  if (!chromePath) throw new Error("Chrome not found. Set CHROME_PATH and rerun.");

  const portProbe = createServer();
  await new Promise((resolveListen) => portProbe.listen(0, "127.0.0.1", resolveListen));
  const debugPort = portProbe.address().port;
  await new Promise((resolveClose) => portProbe.close(resolveClose));

  profileDir = await mkdtemp(join(tmpdir(), "collage-caption-qa-"));
  chrome = spawn(chromePath, [
    "--headless=new",
    "--disable-gpu",
    "--no-first-run",
    "--no-default-browser-check",
    `--remote-debugging-port=${debugPort}`,
    `--user-data-dir=${profileDir}`,
    "about:blank"
  ], {stdio: "ignore"});

  let target;
  for (let attempt = 0; attempt < 120; attempt += 1) {
    try {
      const targets = await (await fetch(`http://127.0.0.1:${debugPort}/json`)).json();
      target = targets.find((item) => item.type === "page");
      if (target?.webSocketDebuggerUrl) break;
    } catch {}
    await wait(100);
  }
  if (!target?.webSocketDebuggerUrl) throw new Error("Chrome DevTools endpoint did not start.");

  socket = new WebSocket(target.webSocketDebuggerUrl);
  await new Promise((resolveOpen, rejectOpen) => {
    socket.addEventListener("open", resolveOpen, {once: true});
    socket.addEventListener("error", rejectOpen, {once: true});
  });

  let commandId = 0;
  const pending = new Map();
  socket.addEventListener("message", (event) => {
    const message = JSON.parse(event.data);
    if (!message.id) return;
    const request = pending.get(message.id);
    if (!request) return;
    pending.delete(message.id);
    if (message.error) request.reject(new Error(message.error.message));
    else request.resolve(message.result);
  });
  const cdp = (method, params = {}) => new Promise((resolveCommand, rejectCommand) => {
    const id = ++commandId;
    pending.set(id, {resolve: resolveCommand, reject: rejectCommand});
    socket.send(JSON.stringify({id, method, params}));
  });

  await cdp("Page.enable");
  await cdp("Runtime.enable");
  await cdp("Emulation.setDeviceMetricsOverride", {
    width: config.canvas.width,
    height: config.canvas.height,
    deviceScaleFactor: 1,
    mobile: false
  });
  await cdp("Page.navigate", {url: `http://127.0.0.1:${servePort}/index.html`});

  for (let attempt = 0; attempt < 200; attempt += 1) {
    const ready = await cdp("Runtime.evaluate", {
      expression: "Boolean(window.__timelines && Object.keys(window.__timelines).length > 0 && document.fonts.status === 'loaded' && document.querySelector('[data-composition-id]'))",
      returnByValue: true
    });
    if (ready.result.value) break;
    if (attempt === 199) throw new Error("Composition timeline, root, or fonts did not initialize.");
    await wait(100);
  }

  const findings = [];
  let samplesChecked = 0;
  let maxObservedIntersectionAreaPx2 = 0;
  for (const beat of config.beats) {
    for (const time of sampleTimes(beat)) {
      const expression = `(() => {
        const time = ${JSON.stringify(time)};
        document.querySelectorAll('.clip').forEach((clip) => {
          const start = Number(clip.dataset.start || 0);
          const end = start + Number(clip.dataset.duration || 0);
          clip.style.visibility = time >= start && time < end ? 'visible' : 'hidden';
        });
        const timelines = Object.values(window.__timelines || {});
        const timeline = window.__timelines.main || timelines[0];
        timeline.time(time, false);
        const rootElement = document.querySelector('[data-composition-id]');
        const root = rootElement.getBoundingClientRect();
        const scope = document.querySelector(${JSON.stringify(beat.selector)});
        if (!scope) return {missingScope: true, captions: []};
        const captions = Array.from(scope.querySelectorAll(${JSON.stringify(config.caption_selector)}))
          .map((element) => {
            const style = getComputedStyle(element);
            const rect = element.getBoundingClientRect();
            return {
              selector: element.id ? '#' + element.id : element.className.toString().split(/\\s+/).filter(Boolean).map((name) => '.' + name).join(''),
              text: (element.textContent || '').trim(),
              visible: style.visibility !== 'hidden' && style.display !== 'none' && Number(style.opacity) > 0.05 && rect.width > 1 && rect.height > 1,
              rect: {x: rect.left - root.left, y: rect.top - root.top, width: rect.width, height: rect.height}
            };
          })
          .filter((item) => item.visible);
        return {missingScope: false, captions};
      })()`;
      const result = await cdp("Runtime.evaluate", {expression, returnByValue: true});
      const payload = result.result.value || {captions: []};
      if (payload.missingScope) throw new Error(`Caption scope not found: ${beat.selector}`);
      samplesChecked += 1;

      for (const caption of payload.captions) {
        for (const regionDefinition of beat.regions) {
          const region = interpolateRegion(regionDefinition, time);
          const left = Math.max(caption.rect.x, region.x);
          const top = Math.max(caption.rect.y, region.y);
          const right = Math.min(caption.rect.x + caption.rect.width, region.x + region.width);
          const bottom = Math.min(caption.rect.y + caption.rect.height, region.y + region.height);
          const intersectionArea = Math.max(0, right - left) * Math.max(0, bottom - top);
          maxObservedIntersectionAreaPx2 = Math.max(maxObservedIntersectionAreaPx2, intersectionArea);
          if (intersectionArea > config.intersection_threshold_px2) {
            findings.push({
              captionId: beat.caption_id,
              time: Number(time.toFixed(3)),
              caption: caption.text,
              captionSelector: caption.selector,
              captionRect: caption.rect,
              protectedRegion: {
                id: regionDefinition.id,
                kind: regionDefinition.kind,
                x: region.x,
                y: region.y,
                width: region.width,
                height: region.height
              },
              intersectionAreaPx2: Math.round(intersectionArea)
            });
          }
        }
      }
    }
  }

  const report = {
    version: "2.3.0",
    verdict: findings.length === 0 ? "PASS" : "FAIL",
    checkedAt: new Date().toISOString(),
    beatsChecked: config.beats.length,
    samplesChecked,
    protectedRegions: config.beats.reduce((sum, beat) => sum + beat.regions.length, 0),
    intersectionAreaThresholdPx2: config.intersection_threshold_px2,
    maxObservedIntersectionAreaPx2: Math.round(maxObservedIntersectionAreaPx2),
    measurementSurface: "HyperFrames DOM geometry before render; final-master entry/mid/exit frames still require human review",
    findings
  };
  await writeFile(reportPath, `${JSON.stringify(report, null, 2)}\n`, "utf8");
  console.log(JSON.stringify(report, null, 2));
  process.exitCode = findings.length === 0 ? 0 : 1;
} finally {
  if (socket?.readyState === WebSocket.OPEN) socket.close();
  if (chrome && !chrome.killed) chrome.kill("SIGTERM");
  if (server.listening) await new Promise((resolveClose) => server.close(resolveClose));
  if (profileDir) await rm(profileDir, {recursive: true, force: true});
}
