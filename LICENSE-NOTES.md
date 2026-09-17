# License and artwork notes

Project-authored code is MIT licensed; see LICENSE. Blizzard UI artwork remains Blizzard property. Our MIT license does not cover Blizzard textures, even when an addon can reference them in the installed client.

This release includes **no extracted Blizzard textures**. It renders original artwork through client paths. Local read-only extraction was used to inspect the user's installed Classic artwork; those files remain outside the repository and package.

There is no blanket claim here that exact Blizzard artwork cannot be used. There is also no claim that Blizzard has granted blanket redistribution permission. If a future release needs a bundled image, record its specific source/build, hash, modifications and applicable rights separately. Review that file's distribution basis before publication.

Blizzard UI source mirrors are references, not a grant to relicense Blizzard source. Our layout and lifecycle implementation was independently authored. No third-party addon code or packaged textures were copied.

ClassicUI is GPLv3; Classic Frames is All Rights Reserved; KeyUI and DragonflightUI declare MIT code licenses. These code licenses do not independently license underlying Blizzard artwork. See Research/ThirdPartyAddons.md and Research/OriginalArtworkFeasibility.md.

CascLib (MIT), Pillow and lupa were local research/test tools. They and their dependencies are not shipped in the addon.
