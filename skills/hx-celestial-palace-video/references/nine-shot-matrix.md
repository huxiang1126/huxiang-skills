# Nine-shot Design Matrix

Create the matrix before generating. The table below is a strong default, not a fixed picture order. Reorder for rhythm, but maintain the distribution and at least four changed axes between adjacent shots.

| ID | Main giant structure | Figure | View / position | Distant anchor | Primary motion | Ground / foreground | Moon | Veo motion | Start duration |
|---|---|---|---|---|---|---|---|---|---|
| S01 | Off-frame white-jade gate and endless columns | 2%, lone pale-blue back | low camera, lower-right | gate-lit palace silhouettes | thin cloud flow below platform | dry jade plane / cropped gate pier | no | slow track right; figure walks forward | 6s |
| S02 | Eave crossing entire sky above a suspended terrace | 3%, soft-vermilion rear | high camera, left third | layered halls along cloud edge | one distant transparent waterfall | shallow mirror film / eave shadow | yes, cropped side | slow track left; ripple and garment lag | 6s |
| S03 | Curved corridor with repeated moon openings | 6%, moon-white rear-side | eye level, right third | heavenly river through openings | translucent hanging veils | calm curved water channel | no | almost static right drift; slow walk | 6s |
| S04 | Monumental stone screen and stair spanning cloud levels | 1%, pale-indigo climber | very low, near center | suspended platforms above | several narrow vertical falls | carved stair / cropped column base | yes, behind screen edge | gentle push plus slight left track | 8s |
| S05 | Giant welcoming pine framing a distant palace | 4%, pale-green watcher | rear, lower-left | immense bridge beyond branches | pine needles and one crane | stone cliff platform / trunk off-frame | no | slow track right; crane crosses once | 6s |
| S06 | Broad cinnabar-timber hall on pearl stone base | 2%, pale-apricot walker | elevated oblique view | backlit giant gate | wide banner in one breeze | matte pearl-gray terrace / giant banner edge | no | slow track left; steady walking | 6s |
| S07 | Open portal revealing multi-level palace void | 7%, champagne back | eye-level center-left | distant roofs and cloudfall | thick cloudfall over far edge | edge-less reflecting platform / portal jamb | yes, low and partial | static-to-right drift; hair and hem | 6s |
| S08 | Sky bridge crossing between two off-frame palace bodies | 3%, frost-gray figure | high rear, center | far curved wall and roofs | heavenly river under bridge | clean bridge without railing / huge eave corner | no | slow lateral left; measured steps | 6s |
| S09 | Over-shoulder beside a colossal column and screen | 16%, pale-lotus garment | 45° rear shoulder, lower-right | palace beyond giant opening | one long veil and distant waterfall | shallow water mirror / column beyond frame | yes, enormous arc | patient track right; no face turn | 8s |

## Image prompt construction

Use this sequence for each separate image call:

1. **Output contract:** “One standalone 9:16 vertical image, not a grid, not a contact sheet, no text.”
2. **World invariant:** summarize scale, five depth layers, low cloud sea, timeless Chinese celestial architecture, no railings, soft high-altitude light, and physical realism from `world-bible.md`.
3. **Scene relationship:** state the unique row in concrete spatial terms.
4. **Scale evidence:** name four specific cues visible in this composition.
5. **Figure:** rear angle, exact approximate frame percentage, clothing color/layers, action, and wind direction.
6. **Distance and motion:** one far anchor plus one primary dynamic phenomenon.
7. **Negative controls:** no text/logo/watermark, no blank band, no dense city, no railings, no warped figure or architecture.

### Example scene prompt skeleton

```text
Create one standalone 9:16 vertical cinematic image, not a grid or contact sheet.

WORLD: An immense timeless Chinese celestial palace above a low cloud sea, physically realistic live-action large-format architectural photography, quiet restrained Eastern aesthetics, bright transparent diffuse sky light. Five depth layers are clearly readable. No railing anywhere.

SCENE S04: [insert the row's explicit structure, figure, view, distant anchor, ground, moon, and one dynamic phenomenon]. Show four scale proofs: [list four concrete cues]. The cloud top remains below the platform and the person's feet.

FIGURE: [rear angle, percentage, costume layers/color, action]. Body stable; hair and fabric share one gentle wind direction.

No text, caption, logo, watermark, frame, grid, blank white strip, game art, modern object, identifiable dynasty, dense city, deformed person, extra limb, fused fabric, warped architecture, flat moon, or excessive gold.
```

## Diversity gate

Before generating each next scene, compare it with the previous accepted image. Change at least four axes. Color changes alone do not count as meaningful diversity. If the silhouette, architectural direction, and figure placement still read as the same composition, redesign the relation before calling imagegen.

## File plan

```text
stills/
  clean/S01_clean.png ... S09_clean.png
  watermarked/S01.png ... S09.png
prompts/
  S01_image.txt ... S09_image.txt
clips/
  raw/S01_attempt01.mp4 ...
  accepted/S01_veo.mp4 ... S09_veo.mp4
```
