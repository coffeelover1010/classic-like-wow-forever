"""Window trim catalogue crop composition; approximate geometry, not a game screenshot."""
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
    canvas = Image.new('RGBA', (940, 440), (30, 29, 26, 255))
    draw = ImageDraw.Draw(canvas)
    def paste(key, box):
        a = cf.AssetCatalogue['CLASSIC_CHARACTER_' + key]
        source = Image.open(art_root / Path(a.path.removeprefix('Interface\\').replace('\\', '/') + '.blp')).convert('RGBA')
        c = list(a.coords.values())
        crop = source.crop((round(c[0]*source.width), round(c[2]*source.height),
                            round(c[1]*source.width), round(c[3]*source.height)))
        canvas.alpha_composite(crop.resize((box[2], box[3])), (box[0], box[1]))
    draw.text((25,16),'0.9 window trim / existing Classic character-sheet crops',fill='white')
    for x,title,thin in [(25,'Bags: side and bottom strips',True),(335,'Bank: shared panel inset',False),(645,'Merchant: main inset',False)]:
        draw.text((x,48),title,fill='white')
        draw.rectangle((x,80,x+268,350),fill=(20,20,20),outline=(80,80,80))
        if thin:
            pieces=[('LEFT',(x,95,4,240)),('RIGHT',(x+264,95,4,240)),('BOTTOM',(x+4,346,260,4))]
        else:
            pieces=[('TL',(x,80,8,8)),('TR',(x+260,80,8,8)),('BL',(x,342,8,8)),('BR',(x+260,342,8,8)),
                ('TOP',(x+8,80,252,8)),('BOTTOM',(x+8,342,252,8)),('LEFT',(x,88,8,254)),('RIGHT',(x+260,88,8,254))]
        for key,box in pieces: paste(key,box)
        draw.text((x+35,195),'Native content omitted',fill=(170,170,170))
    draw.text((25,385),'Offline crop composition; approximate geometry. Dark placeholders are not addon backgrounds.',fill='white')
    draw.text((25,409),'Not a game screenshot. Portrait corners, item overlays and controls require client checks.',fill='white')
    output.parent.mkdir(parents=True,exist_ok=True)
    canvas.convert('RGB').save(output)
    print(output)

if __name__ == '__main__':
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('--art-root',type=Path,required=True)
    p.add_argument('--output',type=Path,required=True)
    a=p.parse_args(); render(a.art_root,a.output)
