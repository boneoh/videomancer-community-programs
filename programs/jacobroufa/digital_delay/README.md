# Digital Delay

Advanced feedback video processor providing frame strobe, threshold gating, multi-echo delay with Fibonacci/Exponential spacing, independent Y/U/V channel delays, and blend control. The design uses a pipelined architecture with a total latency of 13 clock cycles, ensuring proper timing alignment between the video data and sync signals.

## Architecture

### Frame Strobe Stage
- Temporal posterization: holds entire frames to reduce frame rate
- 0-127 frames hold time (~2.1 seconds max @ 60Hz)
- Creates stop-motion, stutter, or freeze-frame effects
- 1 clock latency

### Threshold Gate Stage
- Selective feedback based on pixel luminance (Y channel)
- Bidirectional: -100% to +100% (center = 0% = unity/disabled)
- Negative values: pass only shadows (Y <= threshold)
- Positive values: pass only highlights (Y >= threshold)
- Gates circular buffer writes for selective persistence
- 1 clock latency

### Circular Buffer
- 512-pixel delay per channel (Y, U, V independent)
- Block RAM inference with synchronous reads
- Supports parallel multi-echo reads from single buffer
- No additional RAM needed for multi-echo operation

### Multi-Echo Processing

#### Echo Address Calculation
Fibonacci or Exponential spacing:
- **Fibonacci**: 1/8, 2/8, 5/8, 8/8 (golden ratio, organic echoes)
- **Exponential**: 1/8, 2/8, 4/8, 8/8 (powers of 2, reverb-like)
- All ratios use constant power-of-2 divisions (optimized to bit shifts)
- Pipelined: 2 clock latency (amount calculation + address calculation)

#### Echo Density Control
Progressive repeat activation (0-100%):
- **0-25%**: 1 echo active (shortest delay, sparse)
- **25-50%**: 2 echoes averaged (moderate density)
- **50-75%**: 3 echoes averaged (dense repeats)
- **75-100%**: 4 echoes averaged (maximum reverb density)
- 1 clock latency for echo count calculation

#### Synchronous RAM Read
- 1 clock latency

#### Echo Mixing
Weighted averaging based on active echo count:
- Division by 2, 4: exact (shift right)
- Division by 3: approximated as ÷4 for timing (75% amplitude)
- 1 clock latency

### Blend/Interpolation Stage
- Three `interpolator_u` instances for Y, U, V channels
- Blends current pixels with multi-echo delayed output
- 0% = current only, 100% = delayed only
- 4 clock latency per channel

### Bypass Path
- Optional bypass mode to pass through unprocessed video
- 9-clock delay line compensates for processing pipeline before interpolator
- Total bypass latency: 13 clocks (matches processing path)

## Submodules

### interpolator_u
Unsigned linear interpolator:
- Performs linear interpolation: `result = a + (b - a) * t`
- Used for blend/decay effects where t is the effect amount
- 4 clock pipeline stages

## Register Map

Compatible with Videomancer ABI 1.x

### Register 0: Strobe Amount
- Bits [9:3]: 0-127 frames (7-bit range, ~2.1 sec @ 60Hz)

### Register 1: Threshold Level
- Range: 0-1023
- Display: -100% to +100%, where 512 = 0% (unity/disabled)
- < 512: pass shadows
- > 512: pass highlights

### Register 2: Echo Density
- Range: 0-1023
- Display: 0-100%
- Controls active echo count (1-4 echoes)

### Register 3: Y Channel Delay
- Bits [9:1]: 0-511 pixels (9-bit range)

### Register 4: U Channel Delay
- Bits [9:1]: 0-511 pixels (9-bit range)

### Register 5: V Channel Delay
- Bits [9:1]: 0-511 pixels (9-bit range)

### Register 6: Control Flags
- **Bit 0**: Enable strobe
- **Bit 1**: Enable delay (consolidated Y/U/V enable)
- **Bit 2**: Multi-echo enable (0=single echo, 1=multi-echo mode)
- **Bit 3**: Echo spacing (0=Fibonacci, 1=Exponential)
- **Bit 4**: Bypass enable (1=bypass all processing)

### Register 7: Effect Amount/Blend
- Range: 0-1023
- Display: 0-100%, decay/feedback amount
- 0 = current pixels only
- 1023 = delayed pixels only

## Timing

**Total pipeline latency: 13 clocks**

| Stage | Latency |
|-------|---------|
| Frame strobe | 1 clock |
| Threshold gate + buffer write | 1 clock |
| Echo amount calculation | 1 clock (pipelined) |
| Echo address calculation | 1 clock (pipelined) |
| Synchronous RAM read | 1 clock |
| Active echo count | 1 clock |
| Echo mixing | 1 clock |
| Interpolator | 4 clocks |
| Output mux | combinatorial (0 clocks) |

All sync signals are delayed to match video data path.

## Resource Usage (ICE40 HX4K)

| Resource | Usage | Percentage |
|----------|-------|------------|
| Block RAM | 24 of 32 blocks | 75% |
| Logic Cells | 3957 of 7680 LCs | 52% |
| I/O Pins | 107 of 256 | 42% |
| PLLs | 0-1 of 2 | 0-50% (depending on video mode) |

**Timing**: Fmax = 69-84 MHz (meets 74.25 MHz HD and 27 MHz SD requirements)

### Optimizations
- No variable divisions (constant power-of-2 only)
- Parallel echo reads from single buffer
- Pipelined address calculations for timing closure
- Division by 3 approximated as ÷4 (shift) for timing
