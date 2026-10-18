# Cube Orange PX4 1.17 — Experimental Rover Firmware

> **EXPERIMENTAL / DIAGNOSTIC BUILDS — NOT FLIGHT-SAFE OR FIELD-READY**
>
> These firmware images were created to investigate a malfunctioning **original CubePilot Cube Orange** and to run the **PX4 Differential Rover** controller while isolating a problematic IMU driver and, in the second build, the unresponsive I/O coprocessor. **Neither build repairs the hardware.** Do not use either image to fly an aircraft, operate a mower, or drive motors until the electrical faults and safety systems have been independently diagnosed and validated.

## Release overview

- **PX4 source:** `release/1.17`, Git identity `v1.17.0-13-gf65ddce539`
- **Target:** `cubepilot_cubeorange_rover`
- **Hardware:** original CubePilot **Cube Orange** (**Board ID 140**); **not Cube Orange+**
- **Toolchain:** GNU Arm Embedded GCC 10.3.1; Ubuntu 22.04 ARM64 build environment
- **Airframe:** `50000_generic_rover_differential`
- **Vehicle controller:** `rover_differential`
- **Ground station:** QGroundControl via MAVLink

## Download the firmware

Attach the following **two `.px4` files** to this GitHub Release (use these names when uploading, or update the links below to match the actual uploaded filenames):

| Image | Download | PX4IO driver | ICM20649 driver | Linked FLASH usage |
|---|---|---|---|---:|
| **Build A — Rover + ICM20649 excluded** | [CubeOrange_PX4_1.17_Rover_NoICM20649.px4](./CubeOrange_PX4_1.17_Rover_NoICM20649.px4) | Included | Excluded | 1,954,992 / 1,966,080 bytes (99.44%) |
| **Build B — Rover + ICM20649 and PX4IO excluded** | [CubeOrange_PX4_Rover_NoICM20649_NoPX4IO.px4](./CubeOrange_PX4_Rover_NoICM20649_NoPX4IO.px4) | Excluded | Excluded | 1,937,484 / 1,966,080 bytes (98.55%) |

**GitHub note:** GitHub Release asset links generally use `https://github.com/OWNER/REPOSITORY/releases/download/TAG/FILE.px4`. The relative links above are placeholders for the published assets; replace them with the actual release asset URLs once uploaded. The linked FLASH figures refer to the **firmware linker memory report**, not the on-disk size of the compressed `.px4` package.

**Build A** retains the PX4IO driver for investigation of the I/O coprocessor. On the affected device, PX4 attempted to check/update the IOMCU firmware, reported that its bootloader did not respond, and failed to start PX4IO. This image is useful for reproducing the diagnostic behavior, **not for bypassing the fault**.

**Build B** omits PX4IO entirely. It started as a Differential Rover without the PX4IO firmware-check/update failure messages, but this **only avoids communicating with the faulty IOMCU**. **MAIN outputs remain unavailable/unverified.** The software PWM AUX controller was present, but its physical outputs were **not electrically validated**.

Both builds retain the existing aircraft-related PX4 modules (multicopter, fixed-wing and VTOL) from the original board configuration. **This does not make either custom build suitable for flight**, especially given the unresolved hardware problems and disabled IMU driver.

## Motivation and observed fault

A used Cube Orange exhibited persistent IOMCU initialization/update errors with ArduPilot. Its third IMU, identified in PX4 as **ICM20649** (device ID `2424842`), also reported unusually high temperatures of approximately **79–87 °C**; the other two IMUs were previously observed around **58–68 °C**.

Stopping the ICM20649 driver manually (`icm20649 stop`) removed its sensor instance and was followed by a noticeable reduction in heating, suggesting a possible connection but **not establishing the root cause**. This motivated firmware variants that omit the driver while retaining the two remaining IMUs.

## Source configuration changes

Relative to `boards/cubepilot/cubeorange/default.px4board`:

**Build A:**

```ini
# CONFIG_DRIVERS_IMU_INVENSENSE_ICM20649 is not set
CONFIG_MODULES_ROVER_DIFFERENTIAL=y
CONFIG_DRIVERS_PX4IO=y
CONFIG_DRIVERS_PWM_OUT=y
```

**Build B:**

```ini
# CONFIG_DRIVERS_IMU_INVENSENSE_ICM20649 is not set
CONFIG_MODULES_ROVER_DIFFERENTIAL=y
# CONFIG_DRIVERS_PX4IO is not set
CONFIG_DRIVERS_PWM_OUT=y
```

These snippets are **changes/selected settings**, not complete `.px4board` files. To reproduce them, copy the source revision's Cube Orange `default.px4board` to `rover.px4board`, apply the selected changes, and build:

```bash
make cubepilot_cubeorange_rover
```

For a reproducible public release, also publish the **complete `rover.px4board` configurations for both builds**, or a Git commit/patch for each variant, and the SHA-256 checksums of the actual binary files. The two firmware binaries are **not** interchangeable with Cube Orange+ images.

## Observations after flashing

The following findings come from tests on **one defective Cube Orange**. They are not general compatibility or safety certifications.

| Test | Build A | Build B |
|---|---|---|
| Boot as Generic Rover Differential (`SYS_AUTOSTART=50000`) | Confirmed | Confirmed |
| `rover_differential status` | `running` | `running` |
| ICM20649 CLI command | `command not found` | Excluded in build configuration |
| Remaining IMU gyroscopes | Two instances, zero reported sensor errors | Two instances, zero reported sensor errors |
| EKF2 | Two healthy IMU-backed instances | Two healthy IMU-backed instances |
| PX4IO | Fails to communicate/update | Not compiled; no PX4IO update attempt |
| PWM AUX | Software controller active | Software controller active |
| Physical PWM outputs | **Not tested** | **Not tested** |

**Temperature remains an unresolved issue.** Build A's remaining IMUs rose from around **38 °C to 48 °C** during an early observation window. During a later Build B test, the two IMUs reported about **67.35 °C and 67.29 °C** with zero reported sensor errors. Those sessions were not controlled A/B thermal tests, so **do not infer that Build B caused the temperature increase or that either build fixes overheating**.

Other observed warnings included inconsistent compasses and insufficient GPS horizontal-position accuracy. No autonomous-driving, arming, physical actuator-output, or flight tests have been validated.

## IOMCU and heater investigation

The main PX4 startup script (`ROMFS/px4fmu_common/init.d/rcS`) attempts to check the PX4IO firmware CRC, update firmware if needed, and start PX4IO. With Build A, the affected board reported errors such as:

```text
WARN  [px4io] check CRC failed: -1
WARN  [px4io] IO refused to reboot
[PX4IO] bootloader not responding
ERROR [px4io] error updating PX4IO - check that bootloader mode is enabled
ERROR [px4io] Failed to communicate with IO, abort.
PX4IO start failed
```

The Cube Orange board configuration defines `PX4IO_HEATER_ENABLED`. In the PX4IO-V2 source, the heater control GPIO is **PB14**; the IOMCU initialization code configures that output low and explicitly requests `HEATER_OUTPUT_EN(false)`. The IOMCU firmware's initial thermal register is `PX4IO_THERMAL_IGNORE`, meaning its control loop does not actively change the output until instructed otherwise.

**This code does not establish the actual voltage on PB14, whether the IOMCU executes initialization, or whether the heater is physically energized.** The heating source remains undiagnosed. Do not assume that omitting the PX4IO driver turns off the heater.

## Installation — bench diagnostics only

1. **Verify the board is the original Cube Orange (Board ID 140).** Do not flash a Cube Orange+ or another Pixhawk board.
2. Disconnect **all motors, ESCs, servos, mower mechanisms, and actuator power**. Use a controlled, supervised bench setup.
3. Keep a known-good official PX4 image and a backup of parameters available for recovery.
4. In **QGroundControl → Vehicle Setup → Firmware**, use the custom firmware file option and select the appropriate `.px4` asset. Confirm the detected board ID before flashing.
5. After reboot, use **Analyze Tools → MAVLink Console** to run **read-only** checks such as:

   ```text
   rover_differential status
   listener sensor_gyro
   listener sensor_accel
   ekf2 status
   pwm_out status
   dmesg
   ```

6. Confirm the differential Rover controller is running, that **only two IMU instances** are present, and that temperatures are not climbing abnormally. **Stop and disconnect power if abnormal heating occurs.**
7. Do **not** arm the board, test actuators, attach propulsion, or attempt flight based only on successful firmware installation or software PWM status.

Build A may attempt an **automatic IOMCU firmware update during boot**, because that is part of PX4's standard PX4IO startup path. Be aware of this before using it on a board with an unresponsive IOMCU. Build B prevents this specific PX4IO code path by omitting the driver, but does not repair I/O hardware.

## Known limitations and safety

- **Unresolved thermal problem:** remaining IMUs reached approximately **67 °C** in one test; thermal stability and the source of heat are unknown.
- **Unresolved IOMCU problem:** communication/update failed under both ArduPilot and PX4 with the PX4IO driver enabled. Physical cause has not been established.
- **MAIN outputs:** unavailable or unverified in the reported setup; do not depend on them.
- **AUX outputs:** PWM driver starts in software, but connector-level signals, failsafes, and output behavior have not been tested.
- **Navigation:** GPS and compass warnings must be resolved before autonomous navigation.
- **Safety-critical use:** these images must **not** be used to fly aircraft, control cutting equipment, or operate a mobile robot near people or property without a full independent hardware and safety validation.
- **No hardware repair claim:** omitting a driver can suppress errors and isolate subsystems, but cannot fix an electrical fault.

## Files to include with the release

For future maintainers and users, ideally attach or link:

- Both `.px4` firmware images, with distinct names.
- The exact `rover.px4board` used for **each** build (or their patches).
- SHA-256 checksums, generated from the actual assets (`shasum -a 256 FILE.px4` on macOS; `sha256sum FILE.px4` on Linux).
- Build logs and a full technical case study describing observations, hypotheses, and remaining diagnostics.

## Acknowledgment / contributions

If you have the same Cube Orange symptoms (IOMCU bootloader not responding, PX4IO update failure, unusually hot IMUs), please share your hardware revision, measured supply voltages, relevant logs, and whether the heating is localized to the IMU/heater circuitry. **Do not attempt undocumented hardware modifications or bypass safety-critical preflight checks.**

This release documents **experimental recovery work in progress**, not a definitive fix.
