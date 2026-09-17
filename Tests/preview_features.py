"""Catalogue-driven crop composition. Approximate native geometry, not a WoW screenshot."""
import argparse
from pathlib import Path
from PIL import Image, ImageDraw
from lupa.lua51 import LuaRuntime

ROOT = Path(__file__).resolve().parents[1]

def render(art_root, output):
    lua=LuaRuntime(unpack_returned_tuples=True); cf=lua.table()
    lua.eval("function(code,cf) assert(loadstring(code))('ClassicForeverUI',cf) end")(
        (ROOT/'Data/AssetCatalogue.lua').read_text(),cf)
    canvas=Image.new('RGBA',(1080,640),(32,31,28,255)); d=ImageDraw.Draw(canvas)
    def paste(key,box):
        a=cf.AssetCatalogue[key]
        src=Image.open(art_root/Path(a.path.removeprefix('Interface\\').replace('\\','/')+'.blp')).convert('RGBA')
        coords=list(a.coords.values()) if a.coords else [0,1,0,1]
        src=src.crop((round(coords[0]*src.width),round(coords[2]*src.height),round(coords[1]*src.width),round(coords[3]*src.height)))
        canvas.alpha_composite(src.resize((box[2],box[3])),box[:2])
    d.text((24,18),'0.10 original artwork crops / enlarged for inspection',fill='white')
    for row,kind in enumerate(['QUEST','TALENTS']):
        y=70+row*140
        for col,state in enumerate(['Up','Down','Disabled']):
            x=28+col*160
            d.text((x,y),kind+' '+state,fill='white')
            paste('CLASSIC_MICRO_'+kind+'_'+state,(x,y+22,64,84))
    d.text((550,70),'Native small cast border retained inside surround',fill='white')
    paste('CLASSIC_CAST_SMALL',(550,110,320,44))
    d.rectangle((560,122,860,142),fill=(109,89,39),outline=(95,95,95))
    d.text((570,164),'Placeholder native fill / no cast indicators simulated',fill=(180,180,180))
    d.text((550,210),'Tracking ring',fill='white')
    paste('CLASSIC_TRACKING_RING',(550,239,84,84))
    d.text((700,210),'Slot trim / native icon placeholder',fill='white')
    paste('CLASSIC_SLOT_TRIM',(700,239,84,84)); d.rectangle((710,249,774,313),fill=(54,62,73))
    d.text((24,385),'Header and clock: dark character crop and exterior metal strips',fill='white')
    paste('CLASSIC_CHARACTER_BACKGROUND',(24,420,350,32))
    paste('CLASSIC_MAXLEVEL',(24,416,350,4)); paste('CLASSIC_MAXLEVEL',(24,452,350,4))
    d.text((37,430),'Native zone text',fill=(224,192,101)); d.text((290,430),'19:42',fill='white')
    d.text((550,385),'Chat: native input retained; optional exterior trim',fill='white')
    d.rectangle((550,420,1000,458),fill=(25,25,25),outline=(90,90,90))
    paste('CLASSIC_MAXLEVEL',(550,416,450,4)); paste('CLASSIC_MAXLEVEL',(550,459,450,4))
    d.text((563,432),'Native input placeholder',fill='white')
    d.text((24,553),'Only original Blizzard texture crops are shown. No generated or redistributed artwork.',fill='white')
    d.text((24,580),'This is an offline composition, not an in-game screenshot. Layers, scale and state changes need client checks.',fill=(180,180,180))
    output.parent.mkdir(parents=True,exist_ok=True); canvas.convert('RGB').save(output); print(output)

if __name__=='__main__':
    p=argparse.ArgumentParser(description=__doc__)
    p.add_argument('--art-root',type=Path,required=True); p.add_argument('--output',type=Path,required=True)
    a=p.parse_args(); render(a.art_root,a.output)
