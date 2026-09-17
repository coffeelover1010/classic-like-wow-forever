"""Read a small UI asset allowlist from a local client with a caller-supplied CascLib.

No archive writes, CDN downloads, account access, or packaged-art output. Keep the
output outside the addon repository. CascLib is a separate MIT research dependency.
"""
import argparse
import ctypes as c
import hashlib
import json
from pathlib import Path

ASSETS = {
    "PaperDollInfoFrame": ["UI-Character-CharacterTab-L1", "UI-Character-CharacterTab-R1",
                           "UI-Character-CharacterTab-BottomLeft", "UI-Character-CharacterTab-BottomRight"],
    "QuestFrame": ["UI-QuestGreeting-TopLeft", "UI-QuestGreeting-TopRight",
                   "UI-QuestGreeting-BotLeft", "UI-QuestGreeting-BotRight"],
    "Tooltips": ["UI-Tooltip-Background", "UI-Tooltip-Border"],
    "SpellBook": ["UI-SpellbookPanel-TopLeft", "UI-SpellbookPanel-TopRight",
                  "UI-SpellbookPanel-BotLeft", "UI-SpellbookPanel-BotRight",
                  "Spellbook-Icon", "UI-Spellbook-SpellBackground", "SpellBook-SkillLineTab"],
    "MainMenuBar": ["UI-MainMenuBar-Dwarf", "UI-MainMenuBar-KeyRing",
                    "UI-MainMenuBar-MaxLevel", "UI-MainMenuBar-EndCap-Human", "UI-MainMenuBar-EndCap-Dwarf",
                    "UI-MainMenuBar", "UI-MainMenuBar-Experience"],
    "TargetingFrame": ["UI-TargetingFrame", "UI-TargetingFrame-Elite",
                       "UI-TargetingFrame-Rare", "UI-TargetingFrame-Rare-Elite", "UI-StatusBar"],
    "Minimap": ["UI-Minimap-Border", "MiniMap-TrackingBorder"],
    "CastingBar": ["UI-CastingBar-Border-Small", "UI-CastingBar-Border"],
    "Buttons": ["UI-Quickslot2", "UI-Quickslot", "UI-MicroButton-Character-Up",
                "UI-MicroButton-Spellbook-Up", "UI-MicroButton-Talents-Up",
                "UI-MicroButton-Quest-Up", "UI-MicroButton-Socials-Up",
                "UI-MicroButton-MainMenu-Up"],
}


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("--dll", type=Path, required=True)
    p.add_argument("--storage", type=Path, required=True)
    p.add_argument("--product", required=True)
    p.add_argument("--output", type=Path, required=True)
    args = p.parse_args()
    repo = Path(__file__).resolve().parents[1]
    if args.output.resolve().is_relative_to(repo):
        p.error("Research extraction must be outside the addon repository")
    lib = c.WinDLL(str(args.dll.resolve()), use_last_error=True)
    handle, dword = c.c_void_p, c.c_uint32
    signatures = {
        "CascOpenStorage": ([c.c_char_p, dword, c.POINTER(handle)], c.c_bool),
        "CascOpenFile": ([handle, c.c_char_p, dword, dword, c.POINTER(handle)], c.c_bool),
        "CascGetFileSize": ([handle, c.POINTER(dword)], dword),
        "CascReadFile": ([handle, c.c_void_p, dword, c.POINTER(dword)], c.c_bool),
        "CascCloseFile": ([handle], c.c_bool),
        "CascCloseStorage": ([handle], c.c_bool),
    }
    for name, (params, result) in signatures.items():
        func = getattr(lib, name)
        func.argtypes, func.restype = params, result
    storage = handle()
    params = f"{args.storage.resolve()}*{args.product}".encode("mbcs")
    if not lib.CascOpenStorage(params, 2, c.byref(storage)):
        raise OSError(c.get_last_error(), "CascOpenStorage failed")
    args.output.mkdir(parents=True, exist_ok=True)
    report = {"product": args.product, "storage": str(args.storage), "assets": []}
    try:
        for folder, names in ASSETS.items():
            for name in names:
                path = f"Interface\\{folder}\\{name}.blp"
                item = {"path": path}
                file = handle()
                if not lib.CascOpenFile(storage, path.encode(), 2, 0x10, c.byref(file)):
                    item.update(status="not_extracted", error=c.get_last_error())
                else:
                    try:
                        size = lib.CascGetFileSize(file, None)
                        if size == 0xFFFFFFFF or size > 16 * 1024 * 1024:
                            raise ValueError("Unexpected UI texture size")
                        buffer = c.create_string_buffer(size)
                        read = dword()
                        if not lib.CascReadFile(file, buffer, size, c.byref(read)) or read.value != size:
                            item.update(status="read_failed", error=c.get_last_error())
                        else:
                            data = buffer.raw
                            destination = args.output / folder / (name + ".blp")
                            destination.parent.mkdir(parents=True, exist_ok=True)
                            destination.write_bytes(data)
                            item.update(status="extracted", bytes=size, sha256=hashlib.sha256(data).hexdigest())
                    finally:
                        lib.CascCloseFile(file)
                report["assets"].append(item)
                print(f"{item['status']}: {path}", flush=True)
    finally:
        lib.CascCloseStorage(storage)
    (args.output / "extraction.json").write_text(json.dumps(report, indent=2), encoding="utf-8")


if __name__ == "__main__":
    main()
