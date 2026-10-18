# Hardware investigation plan — no repair claimed

## Safety boundary

The controller has an unexplained thermal anomaly and a nonresponsive IOMCU. Prefer board-off visual inspection. Do not attach motors, ESCs, high-energy packs or tools. Do not leave USB powered unattended. Do not assume that PX4's absent `heater start` command electrically disables a heater. Do not probe fine-pitch connector pins or unknown nets without matching the exact module and carrier schematics.

## Priority sequence

1. **Document hardware identity**: original Cube Orange, carrier variant, board revisions, connector condition, visible damage or contamination. Photograph with power removed.
2. **Find authoritative schematics**: establish supply rails, IOMCU type, its reset/boot pins, relevant UART/USART paths and heater drive. Distinguish Cube Orange from Cube Orange+.
3. **Passive electrical checks**: with power removed, perform visually guided continuity/short checks only on nets whose safe measurement points are verified. Do not force connector pins or bridge signals.
4. **Controlled low-energy powered measurements**: only with suitably rated instruments and operator expertise, establish supply voltage and reset state at documented test pads. Disconnect upon excessive heat or electrical symptoms.
5. **USART investigation**: with an appropriate logic analyzer or oscilloscope and reference grounding, assess whether the STM32H7 side sends a command and whether any response is present. Respect voltage levels; do not inject 5 V into 3.3 V or lower-voltage nets.
6. **Heater investigation**: confirm the physical heater-enable state and supply path from verified schematics; look for a stuck driver, regulator problem, or uncontrolled heat source. The software findings do not distinguish these possibilities.
7. **Cross-validation**: if available, compare against a known-good same-revision Cube Orange and carrier under identical conditions; test a separated module/carrier only through manufacturer-approved methods.
8. **Only after root cause isolation**: decide whether professional repair, module replacement or retirement is justified. Requalify sensors, outputs and thermal stability independently before any vehicle operation.

## Evidence to record

For each test save: date, board/carrier revisions, firmware version/hash, power source, ambient temperature, elapsed power-on time, instrument and probe setup, measured values, photo references, and stop conditions. Label each result as *observed*, *inferred* or *unverified*.

## Decision boundary

A functioning main MCU and two IMUs **do not establish a usable autopilot**, especially when the IOMCU, MAIN outputs, heater control and safety path are defective or unverified. No new firmware modifications should be used to bypass electrical safety checks.
