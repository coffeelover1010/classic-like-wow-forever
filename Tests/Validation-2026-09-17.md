# Local validation: 17 September 2026

Result: **44 behavioral scenarios passed**, plus Lua 5.1 compilation/execution of all **30 TOC files**, and an inventory check covering every configured artwork path.

The runner exercised login, module isolation, partial rollback, combat deferral, Edit Mode restoration, nil project constants, unknown-client opt-in, missing unit APIs, missing artwork, uncertain texture returns, opaque secret values, update failure recovery, rejected events, late-loaded frames, report/gallery construction, per-module disable, and native vehicle-token display.

Additional checks:

- Python compileall passed for Tools and Tests.
- The package builder validated **35 allowlisted files**, ZIP CRCs and byte-for-byte payload equality.
- Package root is ClassicForeverUI; ClassicForeverUI.toc is directly inside it.
- No BLP, TGA, PNG, DLL, EXE, third-party research checkout or test dependency is in the package.
- Original local BLP files were decoded with Pillow and visually inspected. An offline composition checked the original bar crops, gryphon mirroring and unit-bar placement.
- Git diff whitespace check passed.

Reproduction on the inspected Windows host, from the repository:

```powershell
$py = 'C:\Users\Z68\.cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe'
$env:PYTHONPATH = 'C:\dev\addons playground\cf-ui-research\python-tools'
& $py Tests/run_tests.py
& $py -m compileall -q Tools Tests
& $py Tools/package_addon.py
```

The test dependency is lupa 2.8, using its lua51 runtime. The installed addon has no Python, lupa, Pillow or CascLib dependency.

**Not tested:** execution in a real Retail, Classic or Forever client; actual pixels in that client; engine taint; protected combat interactions; native vehicle/override transitions; real secret-value restrictions; Edit Mode persistence; SavedVariables persistence. These require BETA-TEST.md. Mock passes must not be reported as client compatibility.

0.5 adds twelve scenarios in ui_pass_tests.py for health ownership, aura/tooltip/tracker behavior and their settings. The expanded settings window was rendered with preview_options.py and reviewed offline. Original tooltip sheets were freshly extracted from Era and decoded outside the repository.
