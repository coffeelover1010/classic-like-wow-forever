#!/usr/bin/env python3
"""Extract conservative UI references from Lua/XML source trees."""
import argparse, json, re
from pathlib import Path

PATTERNS = {
    "apis": r"(?<![.:\w])(C_[A-Za-z0-9_]+(?:\.[A-Za-z0-9_]+)+|[A-Z][A-Za-z0-9_]+)\s*\(",
    "events": r"RegisterEvent\s*\(\s*[\"']([A-Z][A-Z0-9_]+)[\"']",
    "frames": r"CreateFrame\s*\([^,]+,\s*[\"']([A-Za-z][A-Za-z0-9_]*)|name\s*=\s*[\"']([A-Za-z][A-Za-z0-9_]*)",
    "textures": r"(?:SetTexture|file)\s*[=(]\s*[\"']([^\"']+)[\"']",
    "atlases": r"(?:SetAtlas|atlas)\s*[=(]\s*[\"']([^\"']+)[\"']",
}
def main():
  p=argparse.ArgumentParser(); p.add_argument("source", type=Path); p.add_argument("--output", type=Path); a=p.parse_args()
  result={k: set() for k in PATTERNS}
  for f in a.source.rglob("*"):
    if f.suffix.lower() not in (".lua", ".xml", ".toc"): continue
    try: text=f.read_text(encoding="utf-8", errors="ignore")
    except OSError: continue
    for key, pattern in PATTERNS.items():
      for hit in re.findall(pattern, text): result[key].add(next((x for x in hit if x), "") if isinstance(hit, tuple) else hit)
  data={k: sorted(v) for k,v in result.items()}
  rendered=json.dumps(data, indent=2)
  if a.output: a.output.write_text(rendered, encoding="utf-8")
  else: print(rendered)
if __name__ == "__main__": main()
