# YUV Window Key

A per-channel YUV window keying effect for the [LZX Industries Videomancer](https://lzxindustries.net/videomancer) FPGA video processor.

## Effect

Window keying isolates a range of pixel values within a defined lower–upper threshold window. For each channel (Y, U, V) a Low and High knob define the window; pixels whose values fall within that range are considered "in-window." The three per-channel results are then combined into a matte according to the selected Matte Mode, and that matte controls what appears in the output. Because the keying operates directly in YUV space (no colour conversion), the thresholds work on luma (Y) and the two chroma-difference channels (U = Cr, V = Cb) as they arrive from the hardware.

## Controls

### Knobs

| Control | Function |
|---------|----------|
| Y Low   | Lower threshold for the Y (luma) channel (0% = black, 100% = white) |
| U Low   | Lower threshold for the U (Cr, red-difference) channel |
| V Low   | Lower threshold for the V (Cb, blue-difference) channel |
| Y High  | Upper threshold for the Y channel |
| U High  | Upper threshold for the U channel |
| V High  | Upper threshold for the V channel |

U and V neutral (no colour) is at 50% (512). Values below 50% are negative chroma; values above 50% are positive chroma.

### Switches

| Switch          | Off                              | On                          |
|-----------------|----------------------------------|-----------------------------|
| S1  Show Matte  | Keyed output (original or black) | Greyscale matte preview     |
| S2  Matte Bit 2 | 0 (MSB of matte mode word)       | 1                           |
| S3  Matte Bit 1 | 0 (middle bit)                   | 1                           |
| S4  Matte Bit 0 | 0 (LSB of matte mode word)       | 1                           |
| S5  Fine        | Normal (full-range knobs)        | Fine (1/8-sensitivity)      |

### Matte Modes

Matte Bit 2 (S2), Matte Bit 1 (S3), and Matte Bit 0 (S4) form a 3-bit word (S2 = MSB, S4 = LSB) that selects one of eight matte modes:

  S2     S3     S4    Mode           Description   
 ----   ----   ----  -------------- ------------- 

  0      0      0    Logical OR     Matte = white (1023) if **any** channel is in-window, else black  

  0      0      1    Bitwise OR     Matte = bitwise OR of in-window channel values; failing channels 																			contribute 0  

  0      1      0    Logical AND    Matte = white (1023) if **all** channels are in-window, else black  

  0      1      1    Bitwise AND    Matte = bitwise AND of in-window channel values; failing channels 																			contribute 0  

  1      0      0    Luma           Matte = Luma (Y) value of the pixel, gated by logical AND  

  1      0      1    LFSR           Matte = frame-locked noise value, gated by logical OR  

  1      1      0    PRNG           Matte = free-running noise value, gated by logical OR  

  1      1      1    Passthrough    Original pixel output 1  all channels — keying disabled  
  
### Slider

| Control      | Function |
|--------------|----------|
| Global Blend | Wet/dry blend between the original and keyed signal (0% = original, 100% = keyed) |

## Key Inversion

When a channel's Low knob is set **above** its High knob, the window inverts automatically for that channel: pixels outside the normal (High, Low) gap pass, and pixels inside are blocked. Each channel inverts independently — no extra switch is needed.

## Show Matte

With Show Matte **On**, the computed matte value is output as a greyscale signal: Y is set to the matte value, and U and V are forced to 512 (neutral chroma). This produces a true monochrome luma signal with no colour information — suitable for feeding other devices directly. Use this to dial in your thresholds visually, then switch Show Matte Off for the actual keyed output.

With Show Matte **Off**, the matte is used as a binary gate: pixels where the matte is greater than zero pass through as the original YUV pixel; pixels where the matte is zero are replaced with black (Y=0, U=512, V=512).

The Passthrough mode (S2=1, S3=1, S4=1) always outputs the original pixel on all channels regardless of the Show Matte setting.

## Matte Mode Details

**Logical OR / AND** — produce a pure black-or-white matte. OR passes if any channel is in-window; AND requires all three channels to be in-window simultaneously.

**Bitwise OR / AND** — produce a greyscale matte from the channel values themselves. Failing channels contribute 0 to the bitwise operation, so only in-window values appear.

**Y value** — the Y (luma) value of the pixel is used directly as the matte. The Y value is output only if all three channels are in-window (logical AND gate); otherwise matte = 0. This mode is useful for producing a luma-shaped matte from a luminance-selected region.

**LFSR** — the matte is a 10-bit frame-locked noise value (Fibonacci LFSR, polynomial x¹⁰ + x⁷ + 1, reseeded each frame). The noise value is gated by logical OR: it appears only for pixels where at least one channel is in-window.

**PRNG** — the same polynomial as LFSR but never reseeded. The noise pattern shifts by the number of active pixels each frame, producing a different phase every frame. Also gated by logical OR.

**Passthrough** — the original pixel is output directly on all three channels. The window checks and Show Matte setting are both ignored.

## Fine Mode

With Fine **On**, the current knob positions are latched as reference values at the moment of switching. Each knob then controls its threshold as `(knob + 7 × reference) / 8`, giving one-eighth the normal sensitivity and allowing very precise adjustment anywhere in the 0–1023 range. Switching back to Fine Off restores full-range control immediately.

## Typical Use

1. Set a matte mode (Logical AND, S2=0 S3=1 S4=0, is the default).
2. Turn Show Matte On and adjust each channel's Low/High knobs until the target region shows as white in the preview.
3. Turn Show Matte Off to switch to the keyed output.
4. Use the Global Blend slider to fade between the original and keyed result.
5. Use Fine mode for precise threshold adjustment once the range is roughly set.

## Comparison with RGB Window Key

| Feature              | YUV Window Key               | RGB Window Key                      |
|----------------------|------------------------------|-------------------------------------|
| Colour space         | YUV direct                   | RGB (full BT.601 YUV↔RGB conv.)     |
| Pipeline latency     | 7 clocks                     | 14 clocks                           |
| BRAM usage           | 0 block RAMs                 | 11 block RAMs                       |
| Mode 100 matte       | Y value (luma passthrough)   | BT.601 computed luma                |
| Best for             | Luma/chroma ranges, fast     | Isolating specific RGB colours      |

Use YUV Window Key when your threshold decisions map naturally onto luma or chroma values (e.g., isolating a bright sky, removing a specific hue cast). Use RGB Window Key when the region of interest is best defined in terms of red, green, and blue levels.

## Technical Notes

- **Colour space:** Direct YUV (no colour conversion)
- **Pipeline latency:** 7 clock cycles
- **FPGA:** Lattice iCE40 HX4K (tq144) on Videomancer rev_b
- **BRAM usage:** 0 (no lookup tables required)
- **UV convention:** U = Cr (red-difference), V = Cb (blue-difference) — Videomancer hardware convention; thresholds apply to the raw hardware values
- **Neutral chroma:** U = V = 512 (50%)

## Hardware Requirements

- LZX Industries Videomancer (rev_b)
- Firmware: v1.0.0-rc.12 or later

## License

Copyright (C) 2026 Pete Appleby  
GPL-3.0-only — see [LICENSE](../LICENSE)
