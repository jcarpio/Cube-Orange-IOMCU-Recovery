# Cube Orange IOMCU Recovery — PX4 Differential Rover Research

**An independently documented, experimental investigation of a faulty original CubePilot Cube Orange using PX4 1.17.**

> [!CAUTION]
> **NOT OPERATIONAL FIRMWARE.** The tested controller has unresolved IOMCU communication failure and unexplained heating. This repository documents diagnostic research, not a repair. Do not connect motors, ESCs, batteries, autonomous vehicles, aircraft, or cutting machinery to the affected hardware for testing. The physical heater has **not** been proven to be off. Stop powering the board if abnormal heating occurs.

## Overview

A second-hand **original CubePilot Cube Orange** (PX4 board ID **140**, **not Cube Orange+**) would not communicate reliably with its I/O microcontroller under ArduPilot. PX4 1.17 could boot, and a custom build enabled the PX4 `rover_differential` module for a planned research rover. Three staged builds isolated the software path while preserving documentation of remaining hardware faults.

| Build | Differential rover | ICM20649 | PX4IO driver | Startup behavior | Outcome |
|---|---|---|---|---|---|
| **A** | Enabled | Disabled | Included | Normal boot-time check / initialization | Rover boots; PX4IO fails |
| **B** | Enabled | Disabled | Excluded | No PX4IO startup | Rover and two IMUs work; IOMCU still untested/unrepaired; heating persists |
| **C** | Enabled | Disabled | Included | Automatic check/update/start disabled in modified `rcS`; manual probe added | Probe executes; no valid IOMCU response; low-level UART/DMA counters captured |

### Key reproducible Build C result

```text
nsh> px4io status
INFO  [px4io] not running
nsh> px4io probe
ERROR [px4io] IOMCU communication failed: -1
px4io: txns: 1 events, 16us elapsed, 16.00us avg, min 16us max 16us   nanus rms
px4io: retries: 3 events
px4io: timeouts: 2 events
px4io: crcerrs: 0 events
arch_px4io_serial: DMA errors: 1 events
px4io: protoerrs: 0 events
px4io: uarterrs: 1 events
```

The `DMA errors` counter is **not proof** of traffic from the IOMCU. Neither failure counts nor the absence of CRC errors identify a single hardware root cause. The two remaining IMUs reported zero sensor error counts but temperatures rose together. A later sensor reading above 53 °C occurred after an **operator-initiated USB disconnect/reconnect**, not a spontaneous reboot. Physical heater state remains unknown.

## Documentation map
- [ArduPilot Rover: IOMCU Isolation and IMU Thermal Experiments](docs/ARDUPILOT_ROVER_THERMAL_AND_IOMCU_EXPERIMENTS.md)
- [`docs/BUILDS_A_B_CASE_STUDY.md`](docs/BUILDS_A_B_CASE_STUDY.md) — background, initial PX4/ArduPilot behavior and Builds A/B.
- [`docs/BUILDS_A_B_RELEASE_NOTES.md`](docs/BUILDS_A_B_RELEASE_NOTES.md) — historical release instructions for A/B; download links there are placeholders until releases exist.
- [`docs/BUILD_C_IOMCU_DIAGNOSTICS.md`](docs/BUILD_C_IOMCU_DIAGNOSTICS.md) — comprehensive implementation, build, boot safety, measurements, findings and uncertainty.
- [`docs/SOURCE_AND_REPRODUCIBILITY.md`](docs/SOURCE_AND_REPRODUCIBILITY.md) — exact revision, six changed files, export/replay strategy and verify steps.
- [`docs/EXPERIMENTAL_RESULTS.md`](docs/EXPERIMENTAL_RESULTS.md) — compact measurement record and known limitations.
- [`docs/HARDWARE_DIAGNOSTIC_PLAN.md`](docs/HARDWARE_DIAGNOSTIC_PLAN.md) — conservative next steps; no invasive measurements without pinout verification.
- [`docs/PUBLICATION_CHECKLIST.md`](docs/PUBLICATION_CHECKLIST.md) — attribution, source identity, evidence, releases and safety review.
- [`CONTRIBUTING.md`](CONTRIBUTING.md) — contribution and issue reporting guidance.
- [Mac/UTM ARM64 Setup Guide](docs/YAHBOOM_MICROROS_V2_MAC_UTM_ARM64_SETUP.md) — for USB passthrough, Wi-Fi networking, ROS 2 Humble,
micro-ROS Agent, camera integration, and LiDAR visualization.

## Source provenance

**The actual modified PX4 source is not inside this initial documentation package.** It remains in the operator's Ubuntu checkout at `~/orange_cube_rover_firmware/px4-rover`, on branch `cubeorange-iomcu-diagnostics`. Build C was built at:

```text
2092c87c6aed28e0c45580f0b061c2994d2923e7
```

Earlier rover configuration commit:

```text
b377a2093b
```

To publish source reproducibly, export the two commits as patches with [`scripts/export_build_c.sh`](scripts/export_build_c.sh), or publish a **properly attributed PX4 fork** containing the branch. The export script **must be executed by the operator on the original checkout**; do not mistake this repository template for the modified source code itself. A firmware `.px4` binary is also not included here.

## Intended future application

The research was motivated by a two-motor agricultural rover: Yahboom MicroROS V2 during prototyping, followed by a possible tracked chassis with ROS 2, Raspberry Pi 5, RTK GNSS, LiDAR and vision. **No vehicle drive or actuator output was validated using Build C.**

## Status

**Open investigation.** Pending: verify IOMCU power/reset, communication waveforms, carrier interconnect, and actual heater control hardware. Work on a cool, disconnected board and consult verified board schematics before probing any pins. No hardware fault location, component replacement or electrical repair is claimed.

## Attribution and license

This documentation is an independent project, **not affiliated with or endorsed by PX4, CubePilot, ArduPilot or Yahboom**. Upstream PX4 material and patches retain their applicable original copyright notices and licensing; review upstream `LICENSE` and third-party component licenses before redistributing. See [`LICENSE-NOTICE.md`](LICENSE-NOTICE.md). No project-specific documentation license is asserted without the owner's approval.
