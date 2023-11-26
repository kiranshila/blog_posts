---
title: Two Tone Distortion Tests with the PNA-X
date: 2023-06-27
draft: true
tags:
  - rf
  - school
---

I've been working on characterizing some circuits for my PhD work..TODO

- 500 MHz to 4 GHz (IP3 and IP2 from 510 to 2 GHz)
- 100 Hz IFBW (To help with averaging)
- 1 MHz tone spacing
- 201 Points
- -10 dBm input power to receiver
- N5242A PNA-X with option 080
- -20 dBm input (~10 dB gain)
- 128 Averages

Calibrate noise power first first at source power level (-30 dBm) (power meter,etc)

# Characterizing the EVM

Unlike app note, we're going to sweep to characterize EVM vs freq.

Connect input to output through external coupler.

Calibrate noise power first

## Low Level random noise

- datasheet table of test port noise floor
- reduced by decreasing the IFBW
- 10 Hz to 1 khz are often used
- does not depend on tone power or spacing, but does on frequency

```latex
N_{L} (dBm/Hz) = 10*log(N_{L} (mW)) - 10 * log(Bandwidth (Hz))
```

### Characterization

Set freq, ifbw, points, turn off sources, measure the receiver power (B) in linear, analysis menu show statistics. I'll be doing averaging, which will ofc affect the stats.

- 0.87 fW \pm 0.27 std dev

compare with datasheet of 10 Hz bandwidth

## High Level Random Noise

- phase-noise driven from source RF and receiver LO
- In two tone, caused by fundamental tone closest to the distortion product
- reduced by decreasing measurement bandwidth or tone power
- datasheet table for phase noise

We can measure by removing the high frequency tone and measuring low side modulation. We're measuing the effect of the closest tone (phase nosie). We're assuming the high-side tone won't have any effect.

High level noise is superimposed on the low-level noise, so

```latex
N_{H} = nh measures (mW) - nL measured (mW)
```

### Characterization

No DUT, directly connected (like LLN)

Freuqncy setup like two tone, except turn off the high frequency tone (source 2) 2f1 - -f2, zero span

# Receiver Intermodulation

- Characteristically identical to the DUT
- dependent on tone powers, freq, and spacing
- primary source is mixer and amplifiers

### Characterization

Same as two tone, but now with output power set to RX power (add gain)



# Order of operations

Calibration
- preset
- connect power combiner, power meter to output
- freq to full band
- points
- secret NBF path
- ifbw
- power level (incident)
- source cal (zero and cal sensor first), both ports 1 and 3
- connect output to port 2
- receiver cal

EVM Test

Nl Measurement
- set freq range offset for measurement (550.0001 to 2000.0001 MHz)
- Set two tone setup
- Turn off sources
- Measure port B with averaging across band (low level intermod tone)

Nh Measurement
- Turn on the lower of the two tones
- Still measuing the intermod, average across band
- At 1 MHz tone spacing, this is basically zero

Receiver distortion
- Set power to Rx power (-10 dBm) (which will interpolate the calibration)
- Turn on other source
