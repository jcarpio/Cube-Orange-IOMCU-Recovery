# PX4 source patches — pending export

**No patch files are included in this initial package.** The modified C/C++ source currently resides on the operator's Builder Ubuntu VM. Run `scripts/export_build_c.sh` there to produce the actual two-commit patch series and cumulative diff. Do not construct patches from the prose report.

Expected commits:

1. `b377a2093b` — custom Rover target configuration.
2. `2092c87c6a` — IOMCU diagnostic probe and startup/transport changes.

Verify the patch files with `git show`, then replay and compile in a fresh compatible PX4 checkout before publishing as reproducible source artifacts.
