# Public repository and release checklist

- [ ] Confirm the repository name and ownership with the maintainer.
- [ ] Choose a documentation license with the maintainer; preserve upstream PX4 notices and component licenses.
- [ ] Export the **actual two commits** from Builder, review all changed files and compare with documentation.
- [ ] Record upstream base revision (`git rev-parse b377a2093b^`), PX4 branch and submodule state.
- [ ] Replay exported patches in a clean compatible checkout and document result (not yet tested).
- [ ] Check `git status --short` and inspect untracked backups, keys, secrets and logs before publishing.
- [ ] Copy `.px4` artifact if distribution is desired, record SHA-256 and identity (`board_id`, `image_size`, `git_hash`).
- [ ] Mark all firmware artifacts **EXPERIMENTAL / DO NOT OPERATE MOTORS OR AIRCRAFT**.
- [ ] Preserve exact error logs and measurement context; do not claim the IOMCU was repaired.
- [ ] Verify that hyperlinks in legacy A/B release notes point to real assets before advertising downloads.
- [ ] Do not publish QGC screenshots showing personal account data, machine names or confidential material without review.
- [ ] Avoid implying support, certification or endorsement from PX4, CubePilot or ArduPilot.
- [ ] Include the unresolved-heater warning in each release description.

## Suggested releases

**`build-a-experimental`**: rover differential + ICM20649 disabled; original PX4IO startup retained.

**`build-b-experimental`**: same rover/IMU configuration with PX4IO disabled; IOMCU defect remains.

**`build-c-iomcu-diagnostics`**: read-only PX4IO protocol-version probe; auto PX4IO startup disabled; unsuccessful probe with recorded UART/DMA errors and heating.

Only create public release entries when actual binary assets and hashes are available and checked. These tags are proposals, **not existing releases**.
