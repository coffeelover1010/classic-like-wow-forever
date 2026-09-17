"""Offline art crop composition. Approximate native geometry; not a game screenshot."""
import argparse
from pathlib import Path
from PIL import Image, ImageDraw
from lupa.lua51 import LuaRuntime

ROOT = Path(__file__).resolve().parents[1]

def render(art_root, output):
    lua = LuaRuntime(unpack_returned_tuples=True)
    cf = lua.table()
    lua.eval("function(code,cf) assert(loadstring(code))('ClassicForeverUI',cf) end")(
        (ROOT / 'Data/AssetCatalogue.lua').read_text(), cf)
    canvas = Image.new('RGBA', (750, 560), (28, 27, 24, 255))
    draw = ImageDraw.Draw(canvas)
    def paste(key, box):
        a = cf.AssetCatalogue['CLASSIC_QUEST_' + key]
        source = Image.open(art_root / Path(a.path.removeprefix('Interface\\').replace('\\', '/') + '.blp')).convert('RGBA')
        c = list(a.coords.values())
        crop = source.crop((round(c[0]*source.width), round(c[2]*source.height),
                            round(c[1]*source.width), round(c[3]*source.height)))
        canvas.alpha_composite(crop.resize((box[2], box[3])), (box[0], box[1]))
    for x,title in [(25,'Quest windows'),(395,'NPC dialogue')]:
        draw.text((x,15),title,fill='white')
        paste('PAPER',(x+8,60,304,388))
        paste('TL',(x,52,16,16)); paste('TR',(x+304,52,16,16))
        paste('BL',(x,440,16,16)); paste('BR',(x+304,440,16,16))
        paste('TOP',(x+16,52,288,8)); paste('BOTTOM',(x+16,448,288,8))
        paste('LEFT',(x,68,8,372)); paste('RIGHT',(x+312,68,8,372))
        draw.text((x+26,90),'Native text and controls remain.',fill=(35,23,12))
    draw.text((25,490),'Offline crop composition / approximate native inset geometry',fill='white')
    draw.text((25,510),'Not a game screenshot. Outer frame and buttons omitted.',fill='white')
    output.parent.mkdir(parents=True,exist_ok=True)
    canvas.convert('RGB').save(output)
    print(output)

if __name__ == '__main__':
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('--art-root',type=Path,required=True)
    p.add_argument('--output',type=Path,required=True)
    a=p.parse_args(); render(a.art_root,a.output)
