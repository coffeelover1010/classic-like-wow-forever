#!/usr/bin/env python3
"""Create a concise compatibility matrix from two scanner JSON manifests."""
import argparse,json
from pathlib import Path
def main():
 p=argparse.ArgumentParser(); p.add_argument("left",type=Path); p.add_argument("right",type=Path); p.add_argument("--output",type=Path,default=Path("Research/CompatibilityMatrix.md")); a=p.parse_args(); l=json.loads(a.left.read_text()); r=json.loads(a.right.read_text())
 out=["# Compatibility matrix", "", "Generated from scanner manifests; candidates require client verification.", "", "| Category | Shared | Left only | Right only |", "|---|---:|---:|---:|"]
 for k in sorted(set(l)|set(r)): out.append(f"| {k} | {len(set(l.get(k,[]))&set(r.get(k,[])))} | {len(set(l.get(k,[]))-set(r.get(k,[])))} | {len(set(r.get(k,[]))-set(l.get(k,[])))} |")
 a.output.parent.mkdir(parents=True,exist_ok=True); a.output.write_text("\n".join(out)+"\n")
if __name__ == "__main__": main()
