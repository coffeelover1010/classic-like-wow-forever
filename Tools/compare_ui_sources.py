#!/usr/bin/env python3
"""Compare file inventories and scanner manifests from two UI source trees."""
import argparse, json, subprocess
from pathlib import Path
def scan(root):
 tool=Path(__file__).with_name("scan_lua_api_usage.py"); return json.loads(subprocess.check_output(["python",str(tool),str(root)],text=True))
def main():
 p=argparse.ArgumentParser(); p.add_argument("left",type=Path); p.add_argument("right",type=Path); p.add_argument("--output",type=Path,default=Path("CompatibilityReport.md")); a=p.parse_args()
 lf={str(x.relative_to(a.left)) for x in a.left.rglob("*") if x.suffix.lower() in (".lua",".xml",".toc")}; rf={str(x.relative_to(a.right)) for x in a.right.rglob("*") if x.suffix.lower() in (".lua",".xml",".toc")}
 l,r=scan(a.left),scan(a.right); lines=["# UI source comparison", "", f"Left: `{a.left}`", f"Right: `{a.right}`", ""]
 for title,left,right in [("Files",lf,rf)]+[(k.replace("_"," ").title(),set(l[k]),set(r[k])) for k in l]:
  lines += [f"## {title}", "", "### Added", *[f"- `{x}`" for x in sorted(right-left)], "", "### Removed", *[f"- `{x}`" for x in sorted(left-right)], ""]
 a.output.write_text("\n".join(lines),encoding="utf-8")
if __name__ == "__main__": main()
