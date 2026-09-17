"""Render the actual mocked settings frame tree for offline layout review.

Requires test-only lupa and Pillow. Font metrics/check marks are approximations;
this is not a WoW screenshot and cannot verify native rendering or input.
"""
import argparse
from pathlib import Path

from lupa.lua51 import LuaRuntime
from PIL import Image, ImageDraw, ImageFont

ROOT = Path(__file__).resolve().parents[1]


def render(output, scenario):
    lua = LuaRuntime(unpack_returned_tuples=True)
    lua.execute((ROOT / "Tests/MockWoW.lua").read_text())
    if scenario == "trial":
        lua.execute("WOW_PROJECT_ID=999")
    shared = lua.table()
    loader = lua.eval("function(code,shared) assert(loadstring(code))('ClassicForeverUI',shared) end")
    for line in (ROOT / "ClassicForeverUI.toc").read_text().splitlines():
        if line.strip() and not line.startswith("#"):
            loader((ROOT / line.strip()).read_text(), shared)
    lua.execute('Mock.Event("PLAYER_LOGIN"); SlashCmdList.CLASSICFOREVERUI("")')
    if scenario == "combat":
        lua.execute('Mock.combat=true; Mock.Click(ClassicForeverUI.Options.Rows.Minimap)')
    g = lua.globals()
    root = g.ClassicForeverUI.Options.Frame
    key = lua.eval("tostring")
    rects = {key(root): (0, 0, 700, 856)}

    def fraction(point):
        return (0 if "LEFT" in point else 1 if "RIGHT" in point else .5,
                0 if "TOP" in point else 1 if "BOTTOM" in point else .5)

    def rectangle(obj):
        name = key(obj)
        if name in rects:
            return rects[name]
        if obj.allPoints is not None:
            result = rectangle(obj.allPoints)
        else:
            constraints = []
            for p in obj.points.values():
                point, relative, relpoint, dx, dy = tuple(p.values())
                rx, ry, rw, rh = rectangle(relative)
                ax, ay = fraction(relpoint)
                sx, sy = fraction(point)
                constraints.append((sx, sy, rx + rw * ax + dx, ry + rh * ay - dy))
            sx, sy, tx, ty = constraints[0]
            w, h = obj.width, obj.height
            for sx2, sy2, tx2, ty2 in constraints[1:]:
                if sx2 != sx:
                    w = (tx2 - tx) / (sx2 - sx)
                if sy2 != sy:
                    h = (ty2 - ty) / (sy2 - sy)
            result = (tx - w * sx, ty - h * sy, w, h)
        rects[name] = result
        return result

    objects = []
    for obj in g.Mock.frames.values():
        if obj.kind not in ("Texture", "FontString") or not obj.IsVisible(obj):
            continue
        parent, depth = obj.parent, 0
        while parent is not None and key(parent) != key(root):
            parent = parent.parent
            depth += 1
        if parent is not None:
            layer = {"BACKGROUND": 0, "ARTWORK": 1, "OVERLAY": 2, "HIGHLIGHT": 3}.get(obj.layer, 1)
            objects.append((depth, layer, obj.sublevel or 0, obj))
    objects.sort(key=lambda item: item[:3])
    canvas = Image.new("RGBA", (700, 856), (15, 14, 12, 255))
    font_path = Path("C:/Windows/Fonts/arial.ttf")
    if not font_path.exists():
        font_path = Path("/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf")

    def rgba(values):
        values = list(values.values())
        return tuple(round(v * 255) for v in (values + [1])[:4])

    for _, _, _, obj in objects:
        x, y, w, h = map(round, rectangle(obj))
        assert w > 0 and h > 0, (obj.text, x, y, w, h)
        layer = Image.new("RGBA", canvas.size)
        draw = ImageDraw.Draw(layer)
        if obj.kind == "FontString":
            size = 18 if obj.font == "GameFontNormalLarge" else 12 if "Small" in (obj.font or "") else 13
            font = ImageFont.truetype(str(font_path), size)
            text = obj.text or ""
            tw = draw.textlength(text, font=font)
            if tw > w:
                print(f"Review text width: {text!r}: {tw:.0f} > {w}")
            tx = x + (w - tw if obj.justify == "RIGHT" else (w - tw) / 2 if obj.justify == "CENTER" else 0)
            draw.text((tx, y + h / 2), text, font=font, anchor="lm", fill=rgba(obj.textColor))
        elif obj.color is not None:
            draw.rectangle((x, y, x + w - 1, y + h - 1), fill=rgba(obj.color))
        elif obj.texture and "UI-CheckBox-Check" in obj.texture:
            draw.line([(x+6, y+13), (x+11, y+18), (x+21, y+7)], fill=(231,197,118), width=3)
        canvas = Image.alpha_composite(canvas, layer)
    result = Image.new("RGB", (748, 934), (29, 28, 25))
    result.paste(canvas.convert("RGB"), (24, 24))
    draw = ImageDraw.Draw(result)
    draw.text((24, 902), "Offline layout preview / approximate fonts / not an in-game screenshot",
              font=ImageFont.truetype(str(font_path), 12), fill=(175,174,165))
    output.parent.mkdir(parents=True, exist_ok=True)
    result.save(output)
    print(output)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--output", type=Path, default=ROOT / "dist/settings-preview.png")
    parser.add_argument("--scenario", choices=("normal", "combat", "trial"), default="normal")
    args = parser.parse_args()
    render(args.output, args.scenario)
