"""Build a texture-free install folder and ZIP from the TOC allowlist."""
import argparse
import hashlib
import re
from pathlib import Path
from zipfile import ZIP_DEFLATED, ZipFile, ZipInfo

ROOT = Path(__file__).resolve().parents[1]
ADDON = "ClassicForeverUI"
DOCS = ("README.md", "BETA-TEST.md", "LICENSE", "LICENSE-NOTES.md")


def build(output, interface=None):
    toc = ROOT / (ADDON + ".toc")
    content = toc.read_text(encoding="utf-8")
    if interface:
        if not re.fullmatch(r"\d{5,6}", interface):
            raise ValueError("Interface must be the numeric value returned by GetBuildInfo")
        content = re.sub(r"(?m)^## Interface:.*$", "## Interface: " + interface, content)
    version = re.search(r"(?m)^## Version:\s*(\S+)", content).group(1)
    payload = {toc.name: content.encode("utf-8")}
    for line in content.splitlines():
        if not line.strip() or line.startswith("#"):
            continue
        relative = Path(line.strip())
        source = (ROOT / relative).resolve()
        if not source.is_relative_to(ROOT) or source.suffix != ".lua" or relative.is_absolute():
            raise ValueError(f"Unexpected TOC entry: {line}")
        payload[relative.as_posix()] = source.read_bytes()
    for name in DOCS:
        payload[name] = (ROOT / name).read_bytes()
    output = output.resolve()
    folder = output / ADDON
    folder.mkdir(parents=True, exist_ok=True)
    existing = {p.relative_to(folder).as_posix() for p in folder.rglob("*") if p.is_file()}
    if existing - payload.keys():
        raise ValueError("Output folder contains unexpected files; choose a fresh output directory")
    for name, data in payload.items():
        destination = folder / name
        if not destination.resolve().is_relative_to(folder):
            raise ValueError("Output path escaped addon folder")
        destination.parent.mkdir(parents=True, exist_ok=True)
        destination.write_bytes(data)
    suffix = f"-interface{interface}" if interface else ""
    archive = output / f"{ADDON}-{version}{suffix}.zip"
    with ZipFile(archive, "w", ZIP_DEFLATED) as z:
        for name, data in sorted(payload.items()):
            item = ZipInfo(f"{ADDON}/{name}", (2026, 9, 17, 0, 0, 0))
            item.compress_type = ZIP_DEFLATED
            item.external_attr = 0o100644 << 16
            z.writestr(item, data)
    with ZipFile(archive) as z:
        assert z.testzip() is None
        assert len(z.namelist()) == len(payload)
        assert all(n.startswith(ADDON + "/") for n in z.namelist())
        assert not any(n.lower().endswith((".blp", ".tga", ".png", ".dll", ".exe")) for n in z.namelist())
        for name, data in payload.items():
            assert z.read(f"{ADDON}/{name}") == data
    digest = hashlib.sha256(archive.read_bytes()).hexdigest()
    archive.with_suffix(".zip.sha256").write_text(f"{digest}  {archive.name}\n", encoding="ascii")
    print(f"Verified {len(payload)} files; no bundled art or research dependencies.")
    print(f"Folder: {folder}")
    print(f"ZIP: {archive}")
    print(f"SHA256: {digest}")
    return archive


if __name__ == "__main__":
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("--output", type=Path, default=ROOT / "dist")
    p.add_argument("--interface", help="Use only the number observed on the beta client")
    args = p.parse_args()
    build(args.output, args.interface)
