# ArduPilot Rover 4.6.3 — IOMCU Isolation and IMU Thermal Experiments

**Project:** Cube Orange IOMCU Recovery  
**Hardware:** CubePilot Cube Orange (original, not Orange+), board ID 140  
**Firmware:** ArduPilot Rover 4.6.3  
**Ground stations:** ArduDeck Beta 1.1 (flashing/connection); QGroundControl on macOS (parameters and MAVLink Inspector)  
**Test date:** 2026-10-18  
**Status:** Experimental field observations; hardware fault unresolved

> [!CAUTION]
> **Not suitable for controlling a vehicle.** These observations concern a second-hand autopilot with known IOMCU communication failures and indicated IMU temperatures up to **75.55 °C**. Keep motors, ESCs, servos, and other actuators disconnected. Do not repeat sustained powered thermal tests based on this report. The internal temperatures are sensor telemetry, not independent thermocouple or calibrated case-temperature measurements.

## 1. Purpose

This experiment revisited ArduPilot Rover after custom PX4 diagnostic Build C established that the main MCU could run, two IMUs could publish plausible measurements without reported sample errors, and communication with the IOMCU failed (read-only `px4io probe`: two timeouts, one DMA error, one UART error, no valid protocol-version response).

The questions were:

1. Can the inertial sensors operate in ArduPilot when IOMCU initialization/update is bypassed?
2. Does skipping automatic IOMCU firmware updates change the outcome?
3. Does the configured board heater target of 28 °C represent effective physical temperature regulation?
4. How does the IMU temperature telemetry behave under different `BRD_IO_ENABLE` settings?

## 2. Initial ArduPilot symptom

An earlier Mission Planner photograph from **2026-07-19**, showing **ArduRover V4.6.3**, contained recurring startup messages:

```text
Config Error: Failed to update IO firmware
Config Error: fix problem then reboot
```

The screenshot also showed an IOMCU initialization message (`IOMCU: 0 0 0`, as legible in the photograph). These errors establish an IOMCU firmware update/configuration failure, **not**, by themselves, an IMU hardware failure. In the earlier boot, normal startup/calibration progress appeared obstructed.

## 3. Environment and procedure

1. Flashed official **ArduPilot Rover 4.6.3 for Cube Orange** using ArduDeck Beta 1.1 on macOS. ArduDeck correctly recognized the USB-connected Cube Orange.
2. Connected using QGroundControl's parameter editor and MAVLink Inspector.
3. Confirmed the following parameters before the comparisons:

   | Parameter | Observed value | Interpretation |
   | --- | --- | --- |
   | `BRD_HEAT_TARG` | `28` °C | Heater setpoint, **not proof of regulation** |
   | `BRD_HEAT_LOWMGN` | `5` °C | Lower temperature margin parameter |
   | `BRD_IO_ENABLE` | Initially `Enabled` (`1`) | IOMCU enabled, firmware update attempted |

4. With `BRD_IO_ENABLE=1`, the earlier error **`Failed to update IO firmware`** remained visible in ArduDeck/QGroundControl.
5. Changed `BRD_IO_ENABLE` to `0` and rebooted. The operator reported that the IMUs began working; QGroundControl subsequently displayed `SCALED_IMU2` and `SCALED_IMU3` messages with plausible inertial values.
6. The operator later set `BRD_IO_ENABLE` to `2` (IOMCU enabled, firmware update skipped), rebooted, and observed further inertial data and temperatures via **Analyze Tools → MAVLink Inspector**.

**Important control limitation:** These tests were not performed at identical initial temperatures, elapsed times, ambient temperatures, or heater states. They are observational troubleshooting, not a controlled A/B experiment.

## 4. Interpretation of `BRD_IO_ENABLE`

| Value | Relevant intended behavior | Observed in this case |
| --- | --- | --- |
| `0` | Disable IOMCU use | ArduPilot was able to publish usable IMU telemetry; elevated temperatures subsequently observed |
| `1` | Enable IOMCU and attempt firmware update | Repeated `Failed to update IO firmware` messages |
| `2` | Enable IOMCU while skipping automatic firmware update | IMU messages present; significant temperature rise persisted |

**Critical distinction:** Selecting `2` avoids the attempted firmware update. It does **not** establish healthy communications or confirm that a physical heater duty-cycle command reaches or is obeyed by the IOMCU.

## 5. MAVLink measurement method

In QGroundControl, **Analyze Tools → MAVLink Inspector**, the operator selected `SCALED_IMU2` and `SCALED_IMU3`. The relevant fields were:

- `temperature`: in **centidegrees Celsius**, so `6139` = 61.39 °C.
- `time_boot_ms`: milliseconds since the ArduPilot boot, not elapsed wall time between screenshots.
- `xacc`, `yacc`, `zacc`, `xgyro`, `ygyro`, `zgyro`: live inertial readings.

Receiving plausible inertial readings shows that messages are being published, but is **not a complete sensor-health, calibration, or flight-readiness test**. The `SCALED_IMU2`/`SCALED_IMU3` message numbering also does not on its own identify a physical IMU chip on the Cube Orange PCB; device IDs and driver mapping should be retrieved separately.

## 6. Recorded thermal observations

The readings below are transcribed from screenshots supplied during the troubleshooting session. Values from different sessions/settings must **not** be plotted as if they formed one continuous experiment.

### 6.1 IOMCU disabled (`BRD_IO_ENABLE=0`)

| MAVLink message | Raw temperature field | Temperature | Time since boot | Notes |
| --- | ---: | ---: | ---: | --- |
| `SCALED_IMU2` | `6139` | **61.39 °C** | 98.979 s | Screenshot at approximately 09:10 |
| `SCALED_IMU3` | `7459` | **74.59 °C** | 86.379 s | Separate screenshot, **not simultaneous** with IMU2 |

The operator reported that the module was warm/hot to touch but not burning, and seemed hotter than during prior tests with IO enabled. Tactile assessment is qualitative and cannot determine component junction temperature.

### 6.2 IOMCU enabled, firmware update skipped (`BRD_IO_ENABLE=2`)

| MAVLink message | Raw temperature field | Temperature | Time since boot | Notes |
| --- | ---: | ---: | ---: | --- |
| `SCALED_IMU2` | `4823` | **48.23 °C** | 64.098 s | First screenshot in this configuration |
| `SCALED_IMU3` | `7096` | **70.96 °C** | 162.098 s | Separate screenshot |
| `SCALED_IMU2` | `5005` | **50.05 °C** | 167.598 s | Later reading from same reported configuration |
| `SCALED_IMU3` | `7555` | **75.55 °C** | 313.098 s | Latest high-temperature screenshot |

Within the `BRD_IO_ENABLE=2` session, the IMU3 temperature rose from 70.96 °C at ~162 s to 75.55 °C at ~313 s. IMU2 rose from 48.23 °C at ~64 s to 50.05 °C at ~168 s. The samples were not synchronized; do not infer an exact same-instant inter-IMU temperature difference from the table.

### 6.3 Thermal summary

- **Highest observed value:** 75.55 °C on `SCALED_IMU3` with `BRD_IO_ENABLE=2`.
- A substantial discrepancy between `SCALED_IMU2` and `SCALED_IMU3` is repeatedly apparent, but these telemetry slots have **not yet been conclusively mapped to physical chips**.
- With `BRD_IO_ENABLE=2`, the data do **not** demonstrate stabilization at the configured **28 °C** heater target.
- Reducing the heater setpoint from 28 °C to 20 °C was **discussed**, but there is **no verified, controlled before/after comparison** establishing an effect of that change.
- A heater provides heat only; a setpoint lower than naturally generated device temperature cannot cool the board.
- These measurements alone cannot distinguish heater power, processor/self-heating, another defective component, inaccurate thermal telemetry, or thermal coupling and chip location.

## 7. Additional reboot/watchdog observation

During the `BRD_IO_ENABLE=2` observations, QGroundControl displayed a warning beginning:

```text
WDG: T17 SL0 FL217 ...
```

This indicates a watchdog-related diagnostic report, **but the exact cause or timing of the event has not been established**. Do not treat this warning as proof that changing `BRD_IO_ENABLE` caused an unexpected reboot. A prior change in boot timestamps in the broader investigation was explicitly explained by the operator manually disconnecting USB.

Preserve the complete `STATUSTEXT`, onboard ArduPilot log, and reboot context if this warning is investigated further.

## 8. What the experiment establishes — and what it does not

### Supported observations

1. Official ArduPilot Rover 4.6.3 runs on the Cube Orange main processor and publishes IMU telemetry in configurations where previous IOMCU firmware-update problems interrupted startup.
2. Bypassing IOMCU operation (`BRD_IO_ENABLE=0`) allowed IMU readings to become available.
3. Skipping the IOMCU firmware update (`BRD_IO_ENABLE=2`) also allowed IMU telemetry, but did not eliminate elevated thermal readings.
4. The earlier firmware-update error and PX4 Build C's IOMCU communication failure are **consistent with an IOMCU subsystem fault**, but the root cause remains undetermined.
5. A configured heater target of 28 °C is **not evidence** that the heater or IOMCU controls the measured chip temperatures.

### Not established

- That all three physical IMUs are electrically healthy or correctly calibrated.
- That any specific IMU chip is defective.
- That the heater is stuck on, stuck off, or commanded correctly.
- That the IOMCU is physically dead (rather than unpowered, held in reset, running incompatible firmware, or unable to communicate due to UART/power faults).
- That setting `BRD_IO_ENABLE=2` repairs the IOMCU or makes the autopilot safe for actuators.
- That the `WDG` report identifies a root cause.

## 9. Recommended next investigation (do not sustain additional heating)

1. **Preserve evidence first:** save QGroundControl screenshots, parameter file, ArduPilot logs, current firmware version, and the precise `BRD_IO_ENABLE` sequence. Record ambient/case temperatures when safe to do so.
2. **Map IMU channels to physical sensors:** inspect `INS_ACC_ID`, `INS_ACC2_ID`, `INS_ACC3_ID`, corresponding `INS_GYR*` values, and hardware definition/driver configuration. Do not assume `SCALED_IMU3` is a particular physical component.
3. **Inspect fault logs:** retain full watchdog text and IO startup errors to establish when and why they occurred.
4. **Use non-invasive electrical instrumentation:** a suitable USB power meter that supports USB data passthrough can record input voltage/current. This provides aggregate input-power clues, **not direct heater current**. Avoid probing the 80-pin module connector or energized fine-pitch contacts using metal clips.
5. **Consider thermal imaging:** a suitable thermal camera or contactless thermal inspection could locate a hot region without electrically contacting the module; interpret emissivity and the module enclosure carefully.
6. **Only with correct schematics and experience**, investigate IOMCU power/reset, USART6 TX/RX, and heater power/control using proper fixtures and instrumentation.

**Safety stop:** Disconnect USB if the module heats unexpectedly, becomes uncomfortably hot, smells abnormal, or displays temperatures approaching previously observed highs. No additional high-temperature soak test is justified by the current evidence.

## 10. Recommended repository integration

Save this document as:

```text
docs/ARDUPILOT_ROVER_THERMAL_AND_IOMCU_EXPERIMENTS.md
```

Add a link in the root README under **Experimental Results**:

```markdown
- [ArduPilot Rover 4.6.3: IOMCU isolation and IMU thermal experiments](docs/ARDUPILOT_ROVER_THERMAL_AND_IOMCU_EXPERIMENTS.md)
```

Suggested commit message:

```text
docs: document ArduPilot IOMCU modes and IMU thermal observations
```

This report should remain separate from the PX4 Build C study because it concerns **official ArduPilot Rover 4.6.3**, not a new custom PX4 firmware build.

## 11. Related materials

- [Project repository](https://github.com/jcarpio/Cube-Orange-IOMCU-Recovery)
- `docs/BUILD_C_IOMCU_DIAGNOSTICS.md` — prior PX4 diagnostic investigation (if using the repository template structure).
- ArduPilot Rover parameter reference and Cube Orange board definition should be consulted against the exact firmware revision before making claims about physical pin assignments or heater drive implementation.

## 12. Conclusions

Disabling IOMCU use (`BRD_IO_ENABLE=0`) and skipping its firmware update (`BRD_IO_ENABLE=2`) allowed ArduPilot Rover 4.6.3 to produce usable IMU telemetry despite the previously observed IO firmware-update failure. Neither configuration established effective temperature regulation at the configured 28 °C target; telemetry from `SCALED_IMU3` reached **75.55 °C**. The distinct behaviors help narrow the investigation but do not identify the precise electrical cause. Further work should favor **log preservation, physical sensor mapping, and non-invasive electrical/thermal inspection**, rather than repeated high-temperature powered testing.
