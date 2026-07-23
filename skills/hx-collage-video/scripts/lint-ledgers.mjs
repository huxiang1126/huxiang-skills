#!/usr/bin/env node
import {readFile} from "node:fs/promises";
import {dirname, isAbsolute, resolve} from "node:path";

const args = process.argv.slice(2);
const options = {};
for (let index = 0; index < args.length; index += 2) {
  const key = args[index];
  const value = args[index + 1];
  if (!key?.startsWith("--") || !value) {
    console.error("Usage: lint-ledgers.mjs --storyboard <storyboard.json> --beats <beats.json> [--claims <claims.json> --captions <caption-beats.json> --safe-zones <caption-safe-zones.json> --generation-log <generation-log.json> --audio-manifest <audio-manifest.json>]");
    process.exit(2);
  }
  const optionName = key.slice(2).replace(/-([a-z])/g, (_, letter) => letter.toUpperCase());
  options[optionName] = resolve(value);
}

if (!options.storyboard || !options.beats) {
  console.error("--storyboard and --beats are required");
  process.exit(2);
}

const errors = [];
const warnings = [];
const loadJson = async (label, path) => {
  try {
    return JSON.parse(await readFile(path, "utf8"));
  } catch (error) {
    errors.push(`${label}: cannot read valid JSON at ${path}: ${error.message}`);
    return null;
  }
};
const nonEmptyString = (value) => typeof value === "string" && value.trim().length > 0;
const finiteNumber = (value) => typeof value === "number" && Number.isFinite(value);
const uniqueIds = (items, key, label) => {
  const seen = new Set();
  for (const item of items) {
    const id = item?.[key];
    if (!nonEmptyString(id)) {
      errors.push(`${label}: missing ${key}`);
      continue;
    }
    if (seen.has(id)) errors.push(`${label}: duplicate ${key} ${id}`);
    seen.add(id);
  }
  return seen;
};

const storyboard = await loadJson("storyboard", options.storyboard);
const beatLedger = await loadJson("beats", options.beats);
const storyboardDir = dirname(options.storyboard);
const scenes = Array.isArray(storyboard) ? storyboard : storyboard?.scenes;
if (!Array.isArray(storyboard) && storyboard?.version !== "2.3.0") {
  errors.push(`storyboard: expected version 2.3.0, got ${storyboard?.version ?? "missing"}`);
}
if (!Array.isArray(scenes) || scenes.length === 0) {
  errors.push("storyboard: expected a non-empty scene array or {scenes:[...]}");
}
if (beatLedger?.version !== "2.3.0") errors.push(`beats: expected version 2.3.0, got ${beatLedger?.version ?? "missing"}`);
if (typeof beatLedger?.coverage_required !== "boolean") errors.push("beats: coverage_required must be boolean");
if (!Array.isArray(beatLedger?.beats)) errors.push("beats: beats must be an array");

const beats = Array.isArray(beatLedger?.beats) ? beatLedger.beats : [];
const beatIds = uniqueIds(beats, "beat_id", "beats");
const sceneIds = uniqueIds(Array.isArray(scenes) ? scenes : [], "scene_id", "storyboard");
const allowedStates = new Set(["planned", "asset_generated", "visible_in_scene", "visible_in_master", "intentionally_removed", "missing", "unclear"]);
const allowedRoutes = new Set(["first_last", "first_image", "timeline_collage", "hyperframes_native", "short_video_overlay"]);
const allowedMotionPhases = new Set(["enter", "settle", "hold", "action", "reaction", "exit"]);
const allowedMotionDrivers = new Set(["narration", "sfx", "bgm", "scene_event", "environment", "transition", "manual"]);
const allowedMotionFamilies = new Set(["transform", "mask", "pose_swap", "light", "texture", "deformation", "particle", "composite", "camera", "video_overlay", "simulation"]);
const allowedMotionRuntimes = new Set(["gsap", "svg", "canvas2d", "css", "lottie", "three", "video", "editor_native"]);
const allowedEndBehaviors = new Set(["exit", "hold_to_cut", "handoff"]);
const allowedEventCategories = new Set(["impact", "energy", "atmosphere", "illumination", "destruction", "weather", "music_response", "texture", "transition", "other"]);
const motionPlans = [];

for (const scene of Array.isArray(scenes) ? scenes : []) {
  if (!Array.isArray(scene.beat_ids) || scene.beat_ids.length === 0) {
    errors.push(`storyboard:${scene.scene_id}: beat_ids must be a non-empty array`);
    continue;
  }
  for (const beatId of scene.beat_ids) {
    if (!beatIds.has(beatId)) errors.push(`storyboard:${scene.scene_id}: unknown beat_id ${beatId}`);
  }
  if (scene.motion_method === "first_last" && (!nonEmptyString(scene.first_frame) || !nonEmptyString(scene.last_frame) || !nonEmptyString(scene.motion_prompt))) {
    errors.push(`storyboard:${scene.scene_id}: first_last requires first_frame, last_frame and motion_prompt`);
  }
  if (scene.motion_method === "first_image" && (!nonEmptyString(scene.first_frame) || !nonEmptyString(scene.motion_prompt))) {
    errors.push(`storyboard:${scene.scene_id}: first_image requires first_frame and motion_prompt`);
  }
  if (scene.motion_method === "timeline_collage" && !nonEmptyString(scene.asset_collage)) {
    errors.push(`storyboard:${scene.scene_id}: timeline_collage requires asset_collage`);
  }
  if (scene.motion_method === "timeline_collage" && !nonEmptyString(scene.motion_plan)) {
    errors.push(`storyboard:${scene.scene_id}: timeline_collage requires motion_plan`);
  }
  if (scene.motion_method === "timeline_collage" && nonEmptyString(scene.asset_collage)) {
    const collagePath = isAbsolute(scene.asset_collage)
      ? scene.asset_collage
      : resolve(storyboardDir, scene.asset_collage);
    const collage = await loadJson(`asset-collage:${scene.scene_id}`, collagePath);
    const prefix = `asset-collage:${scene.scene_id}`;
    if (collage?.version !== "1.1.0") errors.push(`${prefix}: expected version 1.1.0, got ${collage?.version ?? "missing"}`);
    if (collage?.scene_id !== scene.scene_id) errors.push(`${prefix}: scene_id must match storyboard scene`);
    if (!nonEmptyString(collage?.canvas)) errors.push(`${prefix}: canvas must be non-empty`);
    if (!Array.isArray(collage?.beat_ids) || collage.beat_ids.length === 0) {
      errors.push(`${prefix}: beat_ids must be non-empty`);
    }
    if (new Set(collage?.beat_ids ?? []).size !== (collage?.beat_ids ?? []).length) {
      errors.push(`${prefix}: beat_ids must be unique`);
    }
    for (const beatId of collage?.beat_ids ?? []) {
      if (!scene.beat_ids.includes(beatId)) errors.push(`${prefix}: beat_id ${beatId} is not owned by the scene`);
    }
    if (!Array.isArray(collage?.layers) || collage.layers.length === 0) {
      errors.push(`${prefix}: layers must be non-empty`);
    }
    uniqueIds(Array.isArray(collage?.layers) ? collage.layers : [], "id", prefix);
    const representedBeatIds = new Set();
    for (const layer of Array.isArray(collage?.layers) ? collage.layers : []) {
      const layerPrefix = `${prefix}:${layer.id ?? "unknown"}`;
      if (!nonEmptyString(layer.file)) errors.push(`${layerPrefix}: file must be non-empty`);
      if (!["hero", "support", "background", "decorative"].includes(layer.role)) errors.push(`${layerPrefix}: invalid role`);
      if (!Array.isArray(layer.beat_ids) || layer.beat_ids.length === 0) {
        errors.push(`${layerPrefix}: beat_ids must be non-empty`);
      }
      for (const beatId of layer.beat_ids ?? []) {
        if (!scene.beat_ids.includes(beatId)) errors.push(`${layerPrefix}: beat_id ${beatId} is not owned by the scene`);
        if (!(collage?.beat_ids ?? []).includes(beatId)) errors.push(`${layerPrefix}: beat_id ${beatId} is missing from the collage beat_ids`);
        representedBeatIds.add(beatId);
      }
      if (!finiteNumber(layer.z)) errors.push(`${layerPrefix}: z must be finite`);
      if (![layer.anchor?.x, layer.anchor?.y].every(finiteNumber)) errors.push(`${layerPrefix}: anchor requires finite x and y`);
      if (!Array.isArray(layer.keyframes) || layer.keyframes.length < 2) {
        errors.push(`${layerPrefix}: at least two keyframes are required`);
      }
      let previousAt = -Infinity;
      for (const frame of Array.isArray(layer.keyframes) ? layer.keyframes : []) {
        if (!finiteNumber(frame.at) || frame.at < 0) errors.push(`${layerPrefix}: each keyframe needs at >= 0`);
        if (finiteNumber(frame.at) && finiteNumber(scene.duration) && frame.at > scene.duration) {
          errors.push(`${layerPrefix}: keyframe at ${frame.at} exceeds scene duration ${scene.duration}`);
        }
        if (frame.at < previousAt) errors.push(`${layerPrefix}: keyframes must be ordered by at`);
        previousAt = frame.at;
        for (const field of ["x", "y", "scale", "rotation", "opacity"]) {
          if (frame[field] !== undefined && !finiteNumber(frame[field])) errors.push(`${layerPrefix}: keyframe ${field} must be finite`);
        }
        if (frame.scale !== undefined && frame.scale <= 0) errors.push(`${layerPrefix}: keyframe scale must be > 0`);
        if (frame.opacity !== undefined && (frame.opacity < 0 || frame.opacity > 1)) errors.push(`${layerPrefix}: keyframe opacity must be between 0 and 1`);
      }
    }
    for (const beatId of collage?.beat_ids ?? []) {
      if (!representedBeatIds.has(beatId)) errors.push(`${prefix}: beat_id ${beatId} is not represented by any layer`);
    }

    if (nonEmptyString(scene.motion_plan)) {
      const motionPath = isAbsolute(scene.motion_plan)
        ? scene.motion_plan
        : resolve(storyboardDir, scene.motion_plan);
      const motion = await loadJson(`motion-plan:${scene.scene_id}`, motionPath);
      const motionPrefix = `motion-plan:${scene.scene_id}`;
      motionPlans.push(motion);
      if (motion?.version !== "1.0.0") errors.push(`${motionPrefix}: expected version 1.0.0, got ${motion?.version ?? "missing"}`);
      if (motion?.scene_id !== scene.scene_id) errors.push(`${motionPrefix}: scene_id must match storyboard scene`);
      if (!finiteNumber(motion?.duration) || Math.abs(motion.duration - scene.duration) > 0.001) errors.push(`${motionPrefix}: duration must match storyboard scene`);
      if (!nonEmptyString(motion?.strategy)) errors.push(`${motionPrefix}: strategy must be non-empty`);

      const layers = Array.isArray(collage?.layers) ? collage.layers : [];
      const layerIds = new Set(layers.map((layer) => layer.id));
      const tracks = Array.isArray(motion?.tracks) ? motion.tracks : [];
      const trackIds = uniqueIds(tracks, "track_id", motionPrefix);
      const trackedLayerIds = new Set();
      const highIntensityWindows = [];
      const phaseIds = new Set();
      if (!Array.isArray(motion?.tracks) || tracks.length === 0) errors.push(`${motionPrefix}: tracks must be non-empty`);
      if (!Array.isArray(motion?.events)) errors.push(`${motionPrefix}: events must be an array`);

      for (const track of tracks) {
        const trackPrefix = `${motionPrefix}:${track.track_id ?? "unknown"}`;
        if (!layerIds.has(track.layer_id)) errors.push(`${trackPrefix}: unknown layer_id ${track.layer_id ?? "missing"}`);
        if (trackedLayerIds.has(track.layer_id)) errors.push(`${trackPrefix}: layer_id ${track.layer_id} has more than one motion track`);
        trackedLayerIds.add(track.layer_id);
        if (!["hero", "support", "background"].includes(track.importance)) errors.push(`${trackPrefix}: invalid importance`);
        if (!allowedEndBehaviors.has(track.end_behavior)) errors.push(`${trackPrefix}: invalid end_behavior`);
        const phases = Array.isArray(track.phases) ? track.phases : [];
        if (phases.length < 2) errors.push(`${trackPrefix}: at least two lifecycle phases are required`);
        let previousStart = -Infinity;
        const phaseKinds = new Set();
        for (const phase of phases) {
          const phasePrefix = `${trackPrefix}:${phase.phase_id ?? "unknown"}`;
          if (!nonEmptyString(phase.phase_id)) errors.push(`${trackPrefix}: phase_id is required`);
          else if (phaseIds.has(phase.phase_id)) errors.push(`${phasePrefix}: duplicate phase_id`);
          else phaseIds.add(phase.phase_id);
          if (!allowedMotionPhases.has(phase.phase)) errors.push(`${phasePrefix}: invalid phase`);
          phaseKinds.add(phase.phase);
          if (!finiteNumber(phase.start) || !finiteNumber(phase.end) || phase.start < 0 || phase.end <= phase.start || phase.end > scene.duration) {
            errors.push(`${phasePrefix}: invalid or out-of-range timing`);
          }
          if (finiteNumber(phase.start) && phase.start < previousStart) errors.push(`${trackPrefix}: phases must be ordered by start`);
          previousStart = phase.start;
          if (!allowedMotionDrivers.has(phase.driver)) errors.push(`${phasePrefix}: invalid driver`);
          if (!allowedMotionFamilies.has(phase.family)) errors.push(`${phasePrefix}: invalid family`);
          if (!allowedMotionRuntimes.has(phase.runtime)) errors.push(`${phasePrefix}: invalid runtime`);
          if (!nonEmptyString(phase.rule) || !nonEmptyString(phase.intention)) errors.push(`${phasePrefix}: rule and intention are required`);
          if (!Number.isInteger(phase.intensity) || phase.intensity < 1 || phase.intensity > 5) errors.push(`${phasePrefix}: intensity must be an integer from 1 to 5`);
          if (phase.finite !== true) errors.push(`${phasePrefix}: finite must be true`);
          if (phase.intensity >= 4 && finiteNumber(phase.start) && finiteNumber(phase.end)) {
            highIntensityWindows.push({start: phase.start, end: phase.end, id: phase.phase_id});
          }
        }
        if (!phaseKinds.has("enter")) errors.push(`${trackPrefix}: lifecycle requires an enter phase`);
        if (![...phaseKinds].some((phase) => ["settle", "hold", "action", "reaction"].includes(phase))) {
          errors.push(`${trackPrefix}: lifecycle requires an in-clip settle, hold, action or reaction phase`);
        }
        if (track.end_behavior === "exit" && !phaseKinds.has("exit")) errors.push(`${trackPrefix}: end_behavior exit requires an exit phase`);
      }

      for (const layer of layers) {
        if (layer.role !== "decorative" && !trackedLayerIds.has(layer.id)) {
          errors.push(`${motionPrefix}: non-decorative layer ${layer.id} has no motion track`);
        }
      }

      const dominantTrackIds = motion?.motion_budget?.dominant_track_ids;
      if (!Array.isArray(dominantTrackIds) || dominantTrackIds.length < 1 || dominantTrackIds.length > 2) {
        errors.push(`${motionPrefix}: motion_budget requires one or two dominant_track_ids`);
      }
      for (const trackId of dominantTrackIds ?? []) {
        if (!trackIds.has(trackId)) errors.push(`${motionPrefix}: dominant track ${trackId} does not exist`);
      }
      const maxHigh = motion?.motion_budget?.max_simultaneous_high_intensity;
      if (!Number.isInteger(maxHigh) || maxHigh < 1 || maxHigh > 3) {
        errors.push(`${motionPrefix}: max_simultaneous_high_intensity must be an integer from 1 to 3`);
      }

      const eventIds = new Set();
      for (const event of Array.isArray(motion?.events) ? motion.events : []) {
        const eventPrefix = `${motionPrefix}:${event.event_id ?? "unknown"}`;
        if (!nonEmptyString(event.event_id)) errors.push(`${motionPrefix}: event_id is required`);
        else if (eventIds.has(event.event_id)) errors.push(`${eventPrefix}: duplicate event_id`);
        else eventIds.add(event.event_id);
        if (!allowedEventCategories.has(event.category)) errors.push(`${eventPrefix}: invalid category`);
        if (!nonEmptyString(event.effect) || !nonEmptyString(event.cause)) errors.push(`${eventPrefix}: effect and cause are required`);
        if (!finiteNumber(event.start) || !finiteNumber(event.end) || event.start < 0 || event.end <= event.start || event.end > scene.duration) {
          errors.push(`${eventPrefix}: invalid or out-of-range timing`);
        }
        if (!Array.isArray(event.targets) || event.targets.length === 0) errors.push(`${eventPrefix}: targets must be non-empty`);
        for (const target of event.targets ?? []) {
          if (!layerIds.has(target) && !["$canvas", "$camera", "$all"].includes(target)) errors.push(`${eventPrefix}: unknown target ${target}`);
        }
        if (!allowedMotionRuntimes.has(event.runtime)) errors.push(`${eventPrefix}: invalid runtime`);
        if (!Number.isInteger(event.intensity) || event.intensity < 1 || event.intensity > 5) errors.push(`${eventPrefix}: intensity must be an integer from 1 to 5`);
        if (!["none", "narration", "sfx", "bgm"].includes(event.audio_source)) errors.push(`${eventPrefix}: invalid audio_source`);
        if (!["sfx", "music_sync", "silent_by_design"].includes(event.sound_policy)) errors.push(`${eventPrefix}: invalid sound_policy`);
        if (event.sound_policy === "sfx" && !nonEmptyString(event.sfx_cue)) errors.push(`${eventPrefix}: sound_policy sfx requires sfx_cue`);
        if (event.sound_policy === "music_sync" && event.audio_source !== "bgm") errors.push(`${eventPrefix}: music_sync requires audio_source bgm`);
        if (event.intensity >= 4 && finiteNumber(event.start) && finiteNumber(event.end)) {
          highIntensityWindows.push({start: event.start, end: event.end, id: event.event_id});
        }
      }

      const sampleTimes = [...new Set(highIntensityWindows.flatMap((window) => [window.start, window.end, (window.start + window.end) / 2]))];
      for (const time of sampleTimes) {
        const concurrent = highIntensityWindows.filter((window) => window.start <= time && time < window.end);
        if (Number.isInteger(maxHigh) && concurrent.length > maxHigh) {
          errors.push(`${motionPrefix}: ${concurrent.length} high-intensity motions overlap at ${time.toFixed(3)}s, budget is ${maxHigh}`);
          break;
        }
      }

      for (const quiet of motion?.motion_budget?.quiet_windows ?? []) {
        if (!finiteNumber(quiet.start) || !finiteNumber(quiet.end) || quiet.start < 0 || quiet.end <= quiet.start || quiet.end > scene.duration) {
          errors.push(`${motionPrefix}: invalid quiet window`);
          continue;
        }
        if (highIntensityWindows.some((window) => window.start < quiet.end && window.end > quiet.start)) {
          errors.push(`${motionPrefix}: high-intensity motion overlaps quiet window ${quiet.start}-${quiet.end}s`);
        }
      }
    }
  }
}

for (const beat of beats) {
  const prefix = `beats:${beat.beat_id ?? "unknown"}`;
  if (!sceneIds.has(beat.scene_id)) errors.push(`${prefix}: scene_id ${beat.scene_id ?? "missing"} not found in storyboard`);
  const owningScene = (Array.isArray(scenes) ? scenes : []).find((scene) => scene.scene_id === beat.scene_id);
  if (owningScene && !owningScene.beat_ids?.includes(beat.beat_id)) errors.push(`${prefix}: owning scene does not reference this beat_id`);
  if (typeof beat.required !== "boolean") errors.push(`${prefix}: required must be boolean`);
  for (const field of ["role", "action", "story_function"]) {
    if (!nonEmptyString(beat[field])) errors.push(`${prefix}: ${field} must be non-empty`);
  }
  if (!finiteNumber(beat.min_visible_seconds) || beat.min_visible_seconds <= 0) errors.push(`${prefix}: min_visible_seconds must be > 0`);
  if (!allowedStates.has(beat.state)) errors.push(`${prefix}: invalid state ${beat.state ?? "missing"}`);
  if (!allowedRoutes.has(beat.assembly_route)) errors.push(`${prefix}: invalid assembly_route ${beat.assembly_route ?? "missing"}`);
  if (beat.state === "visible_in_scene") {
    if (!finiteNumber(beat.scene_window?.start) || !finiteNumber(beat.scene_window?.end) || beat.scene_window.end <= beat.scene_window.start) {
      errors.push(`${prefix}: visible_in_scene requires a valid scene_window`);
    }
  }
  if (beat.state === "visible_in_master") {
    if (!finiteNumber(beat.master_window?.start) || !finiteNumber(beat.master_window?.end) || beat.master_window.end <= beat.master_window.start) {
      errors.push(`${prefix}: visible_in_master requires a valid master_window`);
    } else if (beat.master_window.end - beat.master_window.start + 1e-6 < beat.min_visible_seconds) {
      errors.push(`${prefix}: master_window is shorter than min_visible_seconds`);
    }
  }
  if (beat.state === "intentionally_removed" && (beat.required !== false || !nonEmptyString(beat.removal_reason))) {
    errors.push(`${prefix}: intentionally_removed requires required=false and removal_reason`);
  }
}

const requiredBeats = beats.filter((beat) => beat.required === true);
if (beatLedger?.coverage_required === true && requiredBeats.length === 0) {
  errors.push("beats: coverage_required=true requires at least one required beat");
}

let captions = null;
let claims = null;
let claimIds = null;
if (options.claims) {
  claims = await loadJson("claims", options.claims);
  if (claims?.version !== "2.3.0") errors.push(`claims: expected version 2.3.0, got ${claims?.version ?? "missing"}`);
  if (!Array.isArray(claims?.claims) || claims.claims.length === 0) errors.push("claims: claims must be non-empty");
  claimIds = uniqueIds(Array.isArray(claims?.claims) ? claims.claims : [], "claim_id", "claims");
  for (const claim of Array.isArray(claims?.claims) ? claims.claims : []) {
    const prefix = `claims:${claim.claim_id ?? "unknown"}`;
    if (!nonEmptyString(claim.claim)) errors.push(`${prefix}: claim must be non-empty`);
    if (!["verified", "contested", "inference", "omit"].includes(claim.status)) errors.push(`${prefix}: invalid status`);
    if (!Array.isArray(claim.sources) || claim.sources.length === 0) errors.push(`${prefix}: sources must be non-empty`);
    if (claim.status === "contested" && !nonEmptyString(claim.qualification)) errors.push(`${prefix}: contested claim requires qualification`);
    if (claim.status === "inference" && !nonEmptyString(claim.qualification)) errors.push(`${prefix}: inference claim requires qualification`);
  }
  for (const scene of Array.isArray(scenes) ? scenes : []) {
    for (const claimId of scene.claim_ids ?? []) {
      if (!claimIds.has(claimId)) errors.push(`storyboard:${scene.scene_id}: unknown claim_id ${claimId}`);
    }
  }
}
if (options.captions) {
  captions = await loadJson("captions", options.captions);
  if (captions?.version !== "2.3.0") errors.push(`captions: expected version 2.3.0, got ${captions?.version ?? "missing"}`);
  if (!["default", "caption_led"].includes(captions?.mode)) errors.push("captions: mode must be default or caption_led");
  if (!Array.isArray(captions?.beats) || captions.beats.length === 0) errors.push("captions: beats must be non-empty");
  const captionIds = uniqueIds(Array.isArray(captions?.beats) ? captions.beats : [], "id", "captions");
  for (const beat of Array.isArray(captions?.beats) ? captions.beats : []) {
    const prefix = `captions:${beat.id ?? "unknown"}`;
    if (!["narration", "thesis", "date_event"].includes(beat.mode)) errors.push(`${prefix}: invalid mode`);
    if (!finiteNumber(beat.start) || !finiteNumber(beat.end) || beat.end <= beat.start) errors.push(`${prefix}: invalid start/end`);
    if (!nonEmptyString(beat.zh)) errors.push(`${prefix}: zh must be non-empty`);
    if (!nonEmptyString(beat.semantic_motion)) errors.push(`${prefix}: semantic_motion must be non-empty`);
    if (!Array.isArray(beat.visual_avoid)) errors.push(`${prefix}: visual_avoid must be an array`);
    if (beat.mode === "date_event" && (!Array.isArray(beat.claim_ids) || beat.claim_ids.length === 0)) errors.push(`${prefix}: date_event requires claim_ids`);
    for (const claimId of beat.claim_ids ?? []) {
      if (claimIds && !claimIds.has(claimId)) errors.push(`${prefix}: unknown claim_id ${claimId}`);
      const claim = claims?.claims?.find((item) => item.claim_id === claimId);
      if (claim && ["contested", "inference"].includes(claim.status) && !nonEmptyString(beat.qualification)) {
        errors.push(`${prefix}: ${claim.status} claim ${claimId} requires a rendered qualification`);
      }
    }
  }
  if (captions?.mode === "caption_led" && !captions.beats?.some((beat) => beat.mode === "thesis" || beat.mode === "date_event")) {
    errors.push("captions: caption_led mode requires at least one thesis or date_event beat");
  }
  captions._ids = captionIds;
}

if (options.safeZones) {
  const safeZones = await loadJson("safe-zones", options.safeZones);
  if (!captions) errors.push("safe-zones: --captions is required when --safe-zones is used");
  if (safeZones?.version !== "2.3.0") errors.push(`safe-zones: expected version 2.3.0, got ${safeZones?.version ?? "missing"}`);
  if (!finiteNumber(safeZones?.canvas?.width) || !finiteNumber(safeZones?.canvas?.height)) errors.push("safe-zones: invalid canvas");
  if (!nonEmptyString(safeZones?.caption_selector)) errors.push("safe-zones: caption_selector must be non-empty");
  if (!finiteNumber(safeZones?.sample_interval_seconds) || safeZones.sample_interval_seconds <= 0 || safeZones.sample_interval_seconds > 0.5) {
    errors.push("safe-zones: sample_interval_seconds must be > 0 and <= 0.5");
  }
  const safeBeatIds = new Set();
  for (const beat of Array.isArray(safeZones?.beats) ? safeZones.beats : []) {
    const prefix = `safe-zones:${beat.caption_id ?? "unknown"}`;
    if (safeBeatIds.has(beat.caption_id)) errors.push(`${prefix}: duplicate caption_id`);
    safeBeatIds.add(beat.caption_id);
    if (!captions?._ids?.has(beat.caption_id)) errors.push(`${prefix}: caption_id not found in caption ledger`);
    if (!nonEmptyString(beat.selector)) errors.push(`${prefix}: selector must be non-empty`);
    if (!finiteNumber(beat.start) || !finiteNumber(beat.end) || beat.end <= beat.start) errors.push(`${prefix}: invalid start/end`);
    if (!Array.isArray(beat.regions) || beat.regions.length === 0) errors.push(`${prefix}: regions must be non-empty`);
    const regionIds = new Set();
    for (const region of Array.isArray(beat.regions) ? beat.regions : []) {
      if (!nonEmptyString(region.id)) errors.push(`${prefix}: region id missing`);
      if (regionIds.has(region.id)) errors.push(`${prefix}: duplicate region id ${region.id}`);
      regionIds.add(region.id);
      if (!Array.isArray(region.keyframes) || region.keyframes.length === 0) errors.push(`${prefix}:${region.id}: keyframes must be non-empty`);
      let previousAt = -Infinity;
      for (const frame of Array.isArray(region.keyframes) ? region.keyframes : []) {
        if (![frame.at, frame.x, frame.y, frame.width, frame.height].every(finiteNumber) || frame.width <= 0 || frame.height <= 0) {
          errors.push(`${prefix}:${region.id}: invalid keyframe geometry`);
        }
        if (frame.at < previousAt) errors.push(`${prefix}:${region.id}: keyframes must be ordered by at`);
        previousAt = frame.at;
      }
    }
    const captionBeat = captions?.beats?.find((item) => item.id === beat.caption_id);
    for (const avoidId of captionBeat?.visual_avoid ?? []) {
      if (!regionIds.has(avoidId)) errors.push(`${prefix}: visual_avoid references missing region ${avoidId}`);
    }
  }
  for (const caption of captions?.beats ?? []) {
    if ((caption.mode === "thesis" || caption.mode === "date_event") && !safeBeatIds.has(caption.id)) {
      errors.push(`safe-zones: hero caption ${caption.id} has no safe-zone beat`);
    }
  }
}

if (options.generationLog) {
  const generationLog = await loadJson("generation-log", options.generationLog);
  if (generationLog?.version !== "2.3.0") errors.push(`generation-log: expected version 2.3.0, got ${generationLog?.version ?? "missing"}`);
  uniqueIds(Array.isArray(generationLog?.items) ? generationLog.items : [], "item_id", "generation-log");
  for (const item of Array.isArray(generationLog?.items) ? generationLog.items : []) {
    for (const beatId of item.beat_ids ?? []) {
      if (!beatIds.has(beatId)) errors.push(`generation-log:${item.item_id}: unknown beat_id ${beatId}`);
    }
    if (item.status === "verified" && (!nonEmptyString(item.local_file) || !/^[a-fA-F0-9]{64}$/.test(item.sha256 ?? ""))) {
      errors.push(`generation-log:${item.item_id}: verified requires local_file and sha256`);
    }
  }
}

let audio = null;
if (options.audioManifest) {
  audio = await loadJson("audio-manifest", options.audioManifest);
  if (audio?.version !== "2.3.0") errors.push(`audio-manifest: expected version 2.3.0, got ${audio?.version ?? "missing"}`);
  if (!nonEmptyString(audio?.reference_mixes?.no_music?.path) || !/^[a-fA-F0-9]{64}$/.test(audio?.reference_mixes?.no_music?.sha256 ?? "")) {
    errors.push("audio-manifest: reference_mixes.no_music requires path and sha256");
  }
  const tracks = Array.isArray(audio?.tracks) ? audio.tracks : [];
  const trackIds = uniqueIds(tracks, "id", "audio-manifest");
  for (const track of tracks) {
    const prefix = `audio-manifest:${track.id ?? "unknown"}`;
    if (!["narration", "dialogue", "sfx", "ambience", "bgm"].includes(track.kind)) errors.push(`${prefix}: invalid kind`);
    if (!nonEmptyString(track.path) || !/^[a-fA-F0-9]{64}$/.test(track.sha256 ?? "")) errors.push(`${prefix}: path and sha256 are required`);
    if (track.kind === "narration" && (!nonEmptyString(track.provider) || !nonEmptyString(track.voice_id) || !["user_owned", "authorized_clone", "stock_voice", "local_synthetic"].includes(track.voice_authorization))) {
      errors.push(`${prefix}: narration requires provider, voice_id and a valid voice_authorization`);
    }
    if (track.kind === "bgm" && !nonEmptyString(track.license_credit)) errors.push(`${prefix}: BGM requires license_credit`);
  }
  for (const id of audio?.mixes?.no_music ?? []) {
    const track = tracks.find((item) => item.id === id);
    if (!trackIds.has(id)) errors.push(`audio-manifest:no_music: unknown track ${id}`);
    if (track?.kind === "bgm") errors.push(`audio-manifest:no_music: BGM track ${id} is forbidden`);
  }
  if (audio?.background_music_authorized === false && (tracks.some((track) => track.kind === "bgm") || audio?.mixes?.music)) {
    errors.push("audio-manifest: BGM exists while background_music_authorized=false");
  }
  if (audio?.background_music_authorized === true && !(audio?.mixes?.music ?? []).some((id) => tracks.find((track) => track.id === id)?.kind === "bgm")) {
    errors.push("audio-manifest: authorized music mix must include a BGM track");
  }
  if (audio?.background_music_authorized === true && (!nonEmptyString(audio?.reference_mixes?.music?.path) || !/^[a-fA-F0-9]{64}$/.test(audio?.reference_mixes?.music?.sha256 ?? ""))) {
    errors.push("audio-manifest: authorized music requires reference_mixes.music path and sha256");
  }
}

const bgmDrivenMotion = motionPlans.flatMap((motion) => [
  ...(motion?.tracks ?? []).flatMap((track) => (track.phases ?? []).filter((phase) => phase.driver === "bgm").map((phase) => `${motion.scene_id}:${phase.phase_id}`)),
  ...(motion?.events ?? []).filter((event) => event.audio_source === "bgm" || event.sound_policy === "music_sync").map((event) => `${motion.scene_id}:${event.event_id}`)
]);
if (bgmDrivenMotion.length > 0 && !options.audioManifest) {
  errors.push(`motion-plan: BGM-driven motion requires --audio-manifest (${bgmDrivenMotion.join(", ")})`);
} else if (bgmDrivenMotion.length > 0 && audio?.background_music_authorized !== true) {
  errors.push(`motion-plan: BGM-driven motion requires background_music_authorized=true (${bgmDrivenMotion.join(", ")})`);
}

if (errors.length === 0 && requiredBeats.some((beat) => ["missing", "unclear"].includes(beat.state))) {
  warnings.push("required beats include missing or unclear states; final coverage QA will fail");
}

const report = {
  version: "2.3.0",
  verdict: errors.length === 0 ? "PASS" : "FAIL",
  counts: {
    scenes: Array.isArray(scenes) ? scenes.length : 0,
    beats: beats.length,
    requiredBeats: requiredBeats.length,
    motionPlans: motionPlans.filter(Boolean).length,
    motionTracks: motionPlans.reduce((count, motion) => count + (motion?.tracks?.length ?? 0), 0),
    motionEvents: motionPlans.reduce((count, motion) => count + (motion?.events?.length ?? 0), 0),
    errors: errors.length,
    warnings: warnings.length
  },
  errors,
  warnings
};
console.log(JSON.stringify(report, null, 2));
process.exitCode = errors.length === 0 ? 0 : 1;
