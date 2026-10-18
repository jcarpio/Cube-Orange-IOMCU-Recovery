# Contributing

This repository documents an experimental hardware fault investigation. Contributions are welcome in the form of source review, reproducibility checks, referenced pinout/schematic analysis, repeatable diagnostic methods and independently collected measurements.

Please include hardware variant and revision, carrier variant, PX4 base and modified commit identifiers, ambient conditions, power source, steps to reproduce, raw console output and a clear separation between measurements and hypotheses. Do not share credentials or unique personal identifiers. Avoid recommendations involving bypassed safety protections, unverified signal injection, or live motor tests.

A useful report format:

```markdown
## Hardware / carrier revision
## Firmware and source commit
## Setup and power conditions
## Steps to reproduce
## Direct measurements and logs
## Hypotheses (explicitly speculative)
## Safety observations
```

No contributor should infer that successful sensor readings imply verified actuator or flight safety.
