# Build C: Source identity and reproducibility

## Recorded build environment

- Ubuntu 22.04 ARM64 Builder VM, Python 3.10 venv, GNU Arm toolchain 10.3.1.
- PX4 source branch `release/1.17`; original Cube Orange, board ID 140.
- PX4 target `cubepilot_cubeorange_rover`.
- Branch `cubeorange-iomcu-diagnostics`.
- Committed Build C revision: `2092c87c6aed28e0c45580f0b061c2994d2923e7`.
- Earlier custom board commit: `b377a2093b`.
- Built image reported `image_size` = `1955552` bytes; linked flash region = `1966080` bytes, leaving `10528` bytes (99.46% used).

## Six paths changed in Build C commit

```text
ROMFS/px4fmu_common/init.d/rcS
boards/cubepilot/cubeorange/rover.px4board
platforms/nuttx/src/px4/stm/stm32_common/include/px4_arch/px4io_serial.h
platforms/nuttx/src/px4/stm/stm32h7/px4io_serial/px4io_serial.cpp
src/drivers/px4io/px4io.cpp
src/drivers/px4io/px4io_serial.cpp
```

Source behavior and code walkthrough: [`BUILD_C_IOMCU_DIAGNOSTICS.md`](BUILD_C_IOMCU_DIAGNOSTICS.md). Do not substitute the prose description for the source patch.

## Export authoritative patch files

From the **original local PX4 checkout** on the Builder VM:

```bash
cd ~/orange_cube_rover_firmware/px4-rover
bash /path/to/this-repository/scripts/export_build_c.sh
```

The script checks commit identity, exports the two commits to `patches/`, creates one diff, copies the built `.px4` into `firmware/` if it exists, and prints SHA-256. **Review outputs and verify the diff applies before publication.** Run it only after placing the repository on the same Ubuntu VM or adapting its destination path.

Manual alternative:

```bash
cd ~/orange_cube_rover_firmware/px4-rover
git format-patch -2 2092c87c6a -o /path/to/documentation-repo/patches
git diff b377a2093b^ 2092c87c6a > /path/to/documentation-repo/patches/build-c-complete.diff
git show --pretty='' --name-only 2092c87c6a
sha256sum build/cubepilot_cubeorange_rover/cubepilot_cubeorange_rover.px4
```

## Replay, rebuild and verification

A reproducible patch replay requires the **compatible upstream PX4 base commit** of the original two-commit series; record the result of:

```bash
cd ~/orange_cube_rover_firmware/px4-rover
git rev-parse b377a2093b^
git show --no-patch --format=fuller 2092c87c6a
git status --short
```

In a separate clean checkout at that exact base commit, first verify and then apply the numbered patch files in order using `git am` (or inspect with `git apply --check`). Do not run `git am` over a checkout with unrelated changes. The patches have **not** yet been exported or replay-tested as part of this documentation package.

Build on a supported prepared host:

```bash
make cubepilot_cubeorange_rover -j4
```

Read identity from the JSON `.px4` distribution package:

```bash
python3 - <<'PY2'
import json
from pathlib import Path
p=Path('build/cubepilot_cubeorange_rover/cubepilot_cubeorange_rover.px4')
fw=json.loads(p.read_text())
for k in ('board_id','image_size','git_hash'):
    print(k,fw.get(k))
PY2
```

**Do not rely on binary hashes across different toolchain/host versions without investigating build determinism.** Source history is authoritative; release assets should receive independently recorded SHA-256 values.

## What is not available in the initial package

- No full PX4 source checkout or modified `.cpp`/`.h` files.
- No exported Git patches until the Builder executes the script.
- No firmware binary until it is copied from the Builder.
- No electrical measurements of IOMCU power/reset/UART/heater state.
