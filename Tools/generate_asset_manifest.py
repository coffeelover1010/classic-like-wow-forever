#!/usr/bin/env python3
"""Produce JSON, CSV, and a Lua table from texture/atlas candidates."""
import argparse, csv, json, subprocess
from pathlib import Path
def main():
 p=argparse.ArgumentParser(); p.add_argument("source", type=Path); p.add_argument("--out", type=Path, default=Path("assets")); a=p.parse_args(); a.out.mkdir(parents=True,exist_ok=True)
 scan=Path(__file__).with_name("scan_lua_api_usage.py"); raw=subprocess.check_output(["python",str(scan),str(a.source)], text=True); data=json.loads(raw)
 rows=[{"logical_name":"AUTO_TEXTURE_%03d"%i,"kind":"texture","value":v} for i,v in enumerate(data["textures"],1)] + [{"logical_name":"AUTO_ATLAS_%03d"%i,"kind":"atlas","value":v} for i,v in enumerate(data["atlases"],1)]
 with (a.out/"AssetCatalogue.csv").open("w",newline="",encoding="utf-8") as f: w=csv.DictWriter(f,fieldnames=rows[0].keys() if rows else ["logical_name","kind","value"]); w.writeheader(); w.writerows(rows)
 (a.out/"AssetCatalogue.json").write_text(json.dumps(rows,indent=2),encoding="utf-8")
 def lua_quote(value): return '"' + value.replace('\\', '\\\\').replace('"', '\\"') + '"'
 (a.out/"AssetCatalogue.lua").write_text("return {\n"+"".join("  %s = { %s = %s },\n"%(r["logical_name"],r["kind"],lua_quote(r["value"])) for r in rows)+"}\n",encoding="utf-8")
if __name__ == "__main__": main()
