# Experimental evidence — original Cube Orange

## Observed IOMCU diagnostics

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

The `px4io probe` result means no valid protocol-version register read. Error categorization does **not** prove that bytes were transmitted by the IOMCU or identify the physical fault. CRC/protocol zero counts do not establish signal integrity.

## IMU thermal measurements

All readings are accelerometer-reported internal temperatures, **not external surface or heater temperatures**. `timestamp` is relative PX4 uptime in microseconds. All listed accelerometer sample snapshots reported `error_count: 0`.

| PX4 uptime (s, approx.) | IMU 0 (°C) | IMU 1 (°C) | Measurement session |
|---:|---:|---:|---|
| 92.84 | 34.58 | 34.08 | Initial Build C session |
| 205.50 | 39.82 | 39.69 | Initial Build C session |
| 237.09 | 41.25 | 40.79 | Initial Build C session |
| 270.80 | 42.72 | 42.47 | Initial Build C session |
| 303.47 | 44.14 | 44.10 | Initial Build C session |
| 310.17 | 44.48 | 44.43 | Initial Build C session |
| 313.16 | 44.58 | 44.29 | Initial Build C session |
| 324.67 | 45.06 | 44.63 | Initial Build C session |
| 326.33 | 45.15 | 44.96 | Initial Build C session |
| 342.09 | 45.79 | 45.63 | Initial Build C session |
| 344.01 | 45.89 | 45.54 | Initial Build C session |
| 363.06 | 46.72 | 46.35 | Initial Build C session |
| 367.44 | 46.92 | 46.69 | Initial Build C session |
| 385.26 | 47.62 | 47.55 | Initial Build C session |
| 10.38 | 53.39 | 52.92 | **Subsequent boot after deliberate USB disconnect/reconnect** |

The second session starts already above 53 °C according to its reported sensor readings. Physical cooldown between sessions was not independently confirmed; therefore the later 10 s data must **not** be interpreted as evidence that the board heated from ambient to 53 °C in 10 seconds. The operator explicitly reported initiating the disconnect/reconnect; there is no evidence here of a spontaneous reset.

Earlier Build B measurements reached roughly 67.3 °C, and earlier three-IMU testing recorded ICM20649 at roughly 79–87.5 °C. These are different test configurations and are not directly comparable as controlled experiments.

## QGroundControl observation

The UI displayed `Invalid configuration for rate control: Neither feed forward nor feedback is setup`. This concerns differential rover rate-controller configuration; it is not evidence of an IOMCU electrical cause. Rover outputs/motors were not evaluated.

## Unknown / untested

- IOMCU supply voltage, reset state, boot mode and UART line levels.
- Hardware heater drive and board thermal maps.
- Carrier connectors, power rails, physical actuator paths.
- Whether `px4io probe` returns on another Cube Orange unit.
- Drive, steering, emergency stop, arming and field operation.

For full evidence sources and code-path discussion, see [`BUILD_C_IOMCU_DIAGNOSTICS.md`](BUILD_C_IOMCU_DIAGNOSTICS.md).
