#!/usr/bin/env python3
"""Render an exact-typography 1080x1350 warm-moment editorial card."""

from __future__ import annotations

import argparse
import math
import os
import re
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont, ImageOps


WIDTH, HEIGHT = 1080, 1350
BG = "#FCFBF7"
INK = "#191918"
MUTED = "#696760"
RULE = "#E8E4DA"
SAGE = "#7F9278"
SAGE_LIGHT = "#DDE5DA"
TERRACOTTA = "#C87355"
TERRACOTTA_LIGHT = "#F2D3C7"


FontSpec = tuple[str, int]


def first_existing(specs: list[FontSpec]) -> FontSpec:
    for path, index in specs:
        if path and os.path.exists(path):
            return path, index
    raise FileNotFoundError("No suitable font found. Pass font paths explicitly.")


def font_specs(args: argparse.Namespace) -> tuple[FontSpec, FontSpec, FontSpec, FontSpec, FontSpec]:
    regular = (args.font, args.font_index) if args.font else first_existing([
        ("/System/Library/Fonts/STHeiti Light.ttc", 1),
        ("/System/Library/Fonts/Supplemental/Arial Unicode.ttf", 0),
        ("/usr/share/fonts/opentype/noto/NotoSansCJK-Regular.ttc", 0),
        ("/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf", 0),
    ])
    bold = (args.font_bold, args.font_bold_index) if args.font_bold else first_existing([
        ("/System/Library/Fonts/STHeiti Medium.ttc", 1),
        ("/System/Library/Fonts/Supplemental/Arial Bold.ttf", 0),
        ("/usr/share/fonts/opentype/noto/NotoSansCJK-Bold.ttc", 0),
        ("/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf", 0),
    ])
    display = (args.font_display, args.font_display_index) if args.font_display else first_existing([
        ("/System/Library/Fonts/Supplemental/Songti.ttc", 0),
        ("/usr/share/fonts/opentype/noto/NotoSerifCJK-Bold.ttc", 0),
        bold,
    ])
    quote = (args.font_quote, args.font_quote_index) if args.font_quote else first_existing([
        ("/System/Library/Fonts/Supplemental/Songti.ttc", 1),
        ("/usr/share/fonts/opentype/noto/NotoSerifCJK-Bold.ttc", 0),
        display,
    ])
    latin_italic = (args.font_latin_italic, args.font_latin_italic_index) if args.font_latin_italic else first_existing([
        ("/System/Library/Fonts/Supplemental/Baskerville.ttc", 2),
        ("/System/Library/Fonts/Supplemental/Georgia Italic.ttf", 0),
        ("/usr/share/fonts/truetype/dejavu/DejaVuSerif-Italic.ttf", 0),
        regular,
    ])
    return regular, bold, display, quote, latin_italic


def load_font(spec: FontSpec, size: int) -> ImageFont.FreeTypeFont:
    path, index = spec
    return ImageFont.truetype(path, size=size, index=index)


def has_cjk(text: str) -> bool:
    return bool(re.search(r"[\u3400-\u9fff]", text))


def quote_title(text: str) -> str:
    value = text.strip()
    paired = (("“", "”"), ("「", "」"), ('"', '"'))
    if any(value.startswith(left) and value.endswith(right) for left, right in paired):
        return value
    return f"“{value}”"


def wrap_text(draw: ImageDraw.ImageDraw, text: str, font: ImageFont.FreeTypeFont, max_width: int) -> list[str]:
    text = text.strip()
    if not text:
        return []
    lines: list[str] = []
    for paragraph in text.splitlines() or [text]:
        if not paragraph:
            lines.append("")
            continue
        tokens = list(paragraph) if has_cjk(paragraph) else re.findall(r"\S+\s*", paragraph)
        current = ""
        for token in tokens:
            trial = current + token
            if current and draw.textlength(trial, font=font) > max_width:
                lines.append(current.rstrip())
                current = token.lstrip() if not has_cjk(paragraph) else token
            else:
                current = trial
        if current:
            lines.append(current.rstrip())
    return lines


def fit_block(
    draw: ImageDraw.ImageDraw,
    text: str,
    font_spec: FontSpec,
    start_size: int,
    min_size: int,
    max_width: int,
    max_lines: int,
) -> tuple[ImageFont.FreeTypeFont, list[str]]:
    for size in range(start_size, min_size - 1, -2):
        font = load_font(font_spec, size)
        lines = wrap_text(draw, text, font, max_width)
        if len(lines) <= max_lines:
            return font, lines
    font = load_font(font_spec, min_size)
    lines = wrap_text(draw, text, font, max_width)
    if len(lines) > max_lines:
        raise ValueError(f"Text exceeds {max_lines} lines even at {min_size}px: {text}")
    return font, lines


def line_height(font: ImageFont.FreeTypeFont, spacing: int) -> int:
    box = font.getbbox("国Ag")
    return box[3] - box[1] + spacing


def draw_marker(
    draw: ImageDraw.ImageDraw,
    x1: float,
    y: float,
    x2: float,
    font: ImageFont.FreeTypeFont,
    color: str,
) -> None:
    size = getattr(font, "size", 28)
    glyph_bottom = y + font.getbbox("国Ag")[3]
    stroke_h = max(7, int(size * 0.17))
    top = glyph_bottom - stroke_h + 1
    bottom = glyph_bottom + 3
    draw.rounded_rectangle((x1 - 4, top, x2 + 5, bottom), radius=4, fill=color)
    draw.line((x1 - 1, bottom - 1, x2 + 2, bottom - 2), fill=color, width=2)


def draw_marked_lines(
    draw: ImageDraw.ImageDraw,
    xy: tuple[int, int],
    lines: list[str],
    font: ImageFont.FreeTypeFont,
    fill: str,
    spacing: int,
    mark: str = "",
    marker_color: str = SAGE_LIGHT,
    align: str = "left",
    area_width: int | None = None,
) -> int:
    x, y = xy
    lh = line_height(font, spacing)
    found = not mark
    for line in lines:
        tx = x
        if align == "center" and area_width is not None:
            tx = x + (area_width - draw.textlength(line, font=font)) / 2
        if mark and mark in line:
            idx = line.index(mark)
            before = line[:idx]
            marked = line[idx : idx + len(mark)]
            mx1 = tx + draw.textlength(before, font=font)
            mx2 = mx1 + draw.textlength(marked, font=font)
            draw_marker(draw, mx1, y, mx2, font, marker_color)
            found = True
        draw.text((tx, y), line, font=font, fill=fill)
        y += lh
    if not found:
        raise ValueError(f"Marker phrase was split or absent: {mark!r}. Choose a shorter phrase.")
    return y


def draw_emphasized_lines(
    draw: ImageDraw.ImageDraw,
    xy: tuple[int, int],
    lines: list[str],
    regular_font: ImageFont.FreeTypeFont,
    bold_font: ImageFont.FreeTypeFont,
    fill: str,
    spacing: int,
    emphasis: str = "",
) -> int:
    x, y = xy
    lh = max(line_height(regular_font, spacing), line_height(bold_font, spacing))
    found = not emphasis
    for line in lines:
        if emphasis and emphasis in line:
            idx = line.index(emphasis)
            before = line[:idx]
            after = line[idx + len(emphasis) :]
            draw.text((x, y), before, font=regular_font, fill=fill)
            cursor = x + draw.textlength(before, font=regular_font)
            draw.text((cursor, y), emphasis, font=bold_font, fill=fill)
            cursor += draw.textlength(emphasis, font=bold_font)
            draw.text((cursor, y), after, font=regular_font, fill=fill)
            found = True
        else:
            draw.text((x, y), line, font=regular_font, fill=fill)
        y += lh
    if not found:
        raise ValueError(f"Bold phrase was split or absent: {emphasis!r}. Choose a shorter phrase.")
    return y


def accent_color(name: str) -> str:
    return SAGE if name == "sage" else TERRACOTTA


def draw_doodle(draw: ImageDraw.ImageDraw, kind: str, color_name: str, y: int) -> None:
    if kind == "none":
        return
    color = accent_color(color_name)
    x = WIDTH - 132
    width = 4

    if kind == "sun":
        draw.ellipse((x + 22, y + 22, x + 50, y + 50), outline=color, width=width)
        for angle in range(0, 360, 45):
            r1, r2 = 23, 33
            cx, cy = x + 36, y + 36
            a = math.radians(angle)
            draw.line((cx + r1 * math.cos(a), cy + r1 * math.sin(a), cx + r2 * math.cos(a), cy + r2 * math.sin(a)), fill=color, width=3)
    elif kind == "cloud":
        draw.arc((x + 3, y + 28, x + 37, y + 58), 175, 355, fill=color, width=width)
        draw.arc((x + 21, y + 15, x + 57, y + 54), 190, 352, fill=color, width=width)
        draw.arc((x + 42, y + 28, x + 72, y + 58), 185, 355, fill=color, width=width)
        draw.line((x + 11, y + 55, x + 64, y + 55), fill=color, width=width)
    elif kind == "cat":
        draw.ellipse((x + 15, y + 22, x + 58, y + 62), outline=color, width=width)
        draw.line((x + 18, y + 28, x + 24, y + 10, x + 34, y + 24), fill=color, width=width, joint="curve")
        draw.line((x + 42, y + 24, x + 52, y + 10, x + 57, y + 30), fill=color, width=width, joint="curve")
        draw.ellipse((x + 29, y + 39, x + 32, y + 42), fill=color)
        draw.ellipse((x + 43, y + 39, x + 46, y + 42), fill=color)
        draw.line((x + 37, y + 45, x + 37, y + 49), fill=color, width=2)
        draw.line((x + 8, y + 46, x + 28, y + 49), fill=color, width=2)
        draw.line((x + 47, y + 49, x + 68, y + 46), fill=color, width=2)
    elif kind == "bird":
        draw.arc((x + 8, y + 24, x + 40, y + 51), 195, 345, fill=color, width=width)
        draw.arc((x + 34, y + 24, x + 66, y + 51), 195, 345, fill=color, width=width)
    elif kind == "sprout":
        draw.line((x + 37, y + 65, x + 37, y + 25), fill=color, width=width)
        draw.arc((x + 8, y + 20, x + 39, y + 49), 255, 75, fill=color, width=width)
        draw.arc((x + 36, y + 13, x + 67, y + 44), 105, 285, fill=color, width=width)


def render(args: argparse.Namespace) -> None:
    regular_spec, bold_spec, display_spec, quote_spec, latin_italic_spec = font_specs(args)
    canvas = Image.new("RGB", (WIDTH, HEIGHT), BG)
    draw = ImageDraw.Draw(canvas)

    margin = 74
    content_width = WIDTH - 2 * margin
    header_h = 174

    title = quote_title(args.title)
    title_font, title_lines = fit_block(draw, title, display_spec, 58, 40, content_width, 2)
    label_font = load_font(bold_spec, 21)
    quote_font, quote_lines = fit_block(draw, args.quote, quote_spec, 40, 30, content_width, 3)
    english_font, english_lines = fit_block(draw, args.english, latin_italic_spec, 25, 19, content_width, 3)
    credit_font, credit_lines = fit_block(draw, args.credit, regular_spec, 21, 17, content_width, 2)
    reflection_label_font = load_font(bold_spec, 23)
    reflection_width = content_width - (142 if args.doodle != "none" else 0)
    reflection_font, reflection_lines = fit_block(draw, args.reflection, regular_spec, 29, 22, reflection_width, 4)
    reflection_bold_font = load_font(bold_spec, reflection_font.size)

    top_pad = 28
    footer_pad = 96 if args.doodle != "none" else 36
    echo_label_h = line_height(label_font, 6) + 7 if args.echo_label else 0
    reflection_label_h = line_height(reflection_label_font, 6) + 5 if args.reflection_label else 0
    content_h = (
        top_pad
        + echo_label_h
        + line_height(quote_font, 9) * len(quote_lines) + 9
        + line_height(english_font, 7) * len(english_lines) + 8
        + line_height(credit_font, 5) * len(credit_lines) + 18 + 14
        + reflection_label_h
        + max(line_height(reflection_font, 9), line_height(reflection_bold_font, 9)) * len(reflection_lines)
    )
    available_below_header = HEIGHT - header_h
    photo_h = max(500, min(670, available_below_header - content_h - footer_pad))
    text_panel_h = HEIGHT - header_h - photo_h
    if content_h + footer_pad > text_panel_h:
        raise ValueError(
            f"Text needs {content_h + footer_pad}px but the maximum panel provides {text_panel_h}px. "
            "Shorten the copy."
        )
    photo_top = header_h
    text_top = photo_top + photo_h

    title_lh = line_height(title_font, 8)
    title_y = max(22, (header_h - title_lh * len(title_lines)) // 2 - 2)
    draw_marked_lines(
        draw, (margin, title_y), title_lines, title_font, INK, 8,
        mark=args.title_mark, marker_color=SAGE_LIGHT, align="center", area_width=content_width,
    )

    source = Image.open(args.image).convert("RGB")
    photo = ImageOps.fit(source, (WIDTH, photo_h), method=Image.Resampling.LANCZOS, centering=(args.focus_x, args.focus_y))
    canvas.paste(photo, (0, photo_top))
    draw.line((0, text_top, WIDTH, text_top), fill=RULE, width=1)

    y = text_top + 28
    if args.echo_label:
        draw.line((margin, y + 14, margin + 34, y + 14), fill=TERRACOTTA, width=4)
        draw.text((margin + 47, y), args.echo_label, font=label_font, fill=TERRACOTTA)
        y += line_height(label_font, 6) + 7

    y = draw_marked_lines(
        draw, (margin, y), quote_lines, quote_font, INK, 9,
        mark=args.quote_mark, marker_color=TERRACOTTA_LIGHT,
    )

    y += 9
    y = draw_marked_lines(
        draw, (margin, y), english_lines, english_font, MUTED, 7,
        mark=args.english_mark, marker_color=SAGE_LIGHT,
    )

    y += 8
    y = draw_marked_lines(draw, (margin, y), credit_lines, credit_font, MUTED, 5)

    y += 18
    draw.line((margin, y, margin + 58, y), fill=SAGE, width=4)
    y += 14

    if args.reflection_label:
        draw.text((margin, y), args.reflection_label, font=reflection_label_font, fill=INK)
        y += line_height(reflection_label_font, 6) + 5

    remaining = HEIGHT - y - footer_pad
    needed = max(line_height(reflection_font, 9), line_height(reflection_bold_font, 9)) * len(reflection_lines)
    if needed > remaining:
        raise ValueError(f"Reflection exceeds available space ({needed}px > {remaining}px). Shorten it.")
    reflection_end = draw_emphasized_lines(
        draw, (margin, y), reflection_lines, reflection_font, reflection_bold_font, INK, 9,
        emphasis=args.reflection_bold,
    )

    if args.doodle != "none":
        doodle_y = min(reflection_end + 14, HEIGHT - 94)
        draw_doodle(draw, args.doodle, args.doodle_color, doodle_y)

    output = Path(args.out).expanduser().resolve()
    output.parent.mkdir(parents=True, exist_ok=True)
    canvas.save(output, format="PNG", optimize=True)
    print(f"Rendered {output} ({WIDTH}x{HEIGHT})")


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--image", required=True, help="Text-free scene image")
    parser.add_argument("--out", required=True, help="Output PNG path")
    parser.add_argument("--title", required=True, help="Chinese title; quotation marks are added automatically")
    parser.add_argument("--quote", required=True, help="Verified Chinese quotation or self-translation")
    parser.add_argument("--english", required=True, help="English original or verified English echo")
    parser.add_argument("--credit", required=True, help="Author/work or canonical text/chapter")
    parser.add_argument("--reflection", required=True)
    parser.add_argument("--echo-label", default="", help="Optional visible relationship label")
    parser.add_argument("--reflection-label", default="", help="Optional visible note label")
    parser.add_argument("--reflection-bold", default="", help="Optional 2-8 character phrase to bold in the note")
    parser.add_argument("--title-mark", default="")
    parser.add_argument("--quote-mark", default="")
    parser.add_argument("--english-mark", default="")
    parser.add_argument("--doodle", choices=["none", "sun", "cloud", "cat", "bird", "sprout"], default="none")
    parser.add_argument("--doodle-color", choices=["sage", "terracotta"], default="sage")
    parser.add_argument("--focus-x", type=float, default=0.5, help="Horizontal crop focus, 0..1")
    parser.add_argument("--focus-y", type=float, default=0.5, help="Vertical crop focus, 0..1")
    parser.add_argument("--font", default="")
    parser.add_argument("--font-index", type=int, default=0)
    parser.add_argument("--font-bold", default="")
    parser.add_argument("--font-bold-index", type=int, default=0)
    parser.add_argument("--font-display", default="")
    parser.add_argument("--font-display-index", type=int, default=0)
    parser.add_argument("--font-quote", default="")
    parser.add_argument("--font-quote-index", type=int, default=0)
    parser.add_argument("--font-latin-italic", default="")
    parser.add_argument("--font-latin-italic-index", type=int, default=0)
    args = parser.parse_args()
    if not 0 <= args.focus_x <= 1 or not 0 <= args.focus_y <= 1:
        parser.error("--focus-x and --focus-y must be between 0 and 1")
    marks = [value for value in (args.title_mark, args.quote_mark, args.english_mark) if value]
    if not marks:
        parser.error("Pass one or two marker phrases with --title-mark/--quote-mark/--english-mark")
    if len(marks) > 2:
        parser.error("Use at most two marker phrases")
    return args


if __name__ == "__main__":
    render(parse_args())
