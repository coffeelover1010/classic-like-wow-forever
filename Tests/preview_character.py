"""Character catalogue crop composition; approximate geometry, not a game screenshot."""
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
    canvas = Image.new('RGBA', (650, 540), (30, 29, 26, 255))
    draw = ImageDraw.Draw(canvas)
    def paste(key, box):
        a = cf.AssetCatalogue['CLASSIC_CHARACTER_' + key]
        source = Image.open(art_root / Path(a.path.removeprefix('Interface\\').replace('\\', '/') + '.blp')).convert('RGBA')
        c = list(a.coords.values())
        crop = source.crop((round(c[0]*source.width), round(c[2]*source.height),
                            round(c[1]*source.width), round(c[3]*source.height)))
        canvas.alpha_composite(crop.resize((box[2], box[3])), (box[0], box[1]))
    draw.text((25,16),'Character paper-doll: original background and passive trim',fill='white')
    paste('BACKGROUND',(25,52,320,400))
    for key, box in [('TL',(25,52,8,8)),('TR',(337,52,8,8)),('BL',(25,444,8,8)),
                     ('BR',(337,444,8,8)),('TOP',(33,52,304,8)),('BOTTOM',(33,444,304,8)),
                     ('LEFT',(25,60,8,384)),('RIGHT',(337,60,8,384))]:
        paste(key,box)
    for x in [40,290]:
        for y in range(70,414,43):
            draw.rectangle((x,y,x+32,y+32),fill=(45,43,39),outline=(90,85,70))
            for key,box in [('TOP',(x-4,y-4,40,4)),('BOTTOM',(x-4,y+32,40,4)),
                            ('LEFT',(x-4,y,4,32)),('RIGHT',(x+32,y,4,32))]: paste(key,box)
    draw.text((111,224),'Native model area',fill=(190,187,176))
    draw.text((370,95),'Native content remains:',fill='white')
    for i,text in enumerate(['Stats and class background','Titles and equipment sets','Item quality and cooldowns','Flyouts and sockets','Original buttons and tabs']):
        draw.text((370,125+i*30),text,fill=(185,180,167))
    draw.text((25,481),'Offline crop composition / approximate inset and slot geometry',fill='white')
    draw.text((25,503),'Model, outer frame and native controls omitted. Not a game screenshot.',fill='white')
    output.parent.mkdir(parents=True,exist_ok=True)
    canvas.convert('RGB').save(output)
    print(output)

if __name__ == '__main__':
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('--art-root',type=Path,required=True)
    p.add_argument('--output',type=Path,required=True)
    a=p.parse_args(); render(a.art_root,a.output)
