# Contributing to Videomancer Community Programs

Thank you for your interest in contributing FPGA programs to the Videomancer community! This repository welcomes community-created video processing programs.

## Table of Contents

- [How to Contribute](#how-to-contribute)
- [Program Submission Guidelines](#program-submission-guidelines)
- [Development Process](#development-process)
- [Program Requirements](#program-requirements)
- [Testing Your Program](#testing-your-program)
- [Pull Request Process](#pull-request-process)
- [Code of Conduct](#code-of-conduct)
- [License](#license)

## How to Contribute

Community members can contribute new video processing programs by:

1. Creating a new VHDL program following the Videomancer program architecture
2. Organizing it under your vendor/author directory (e.g., `programs/yourname/`)
3. Ensuring it builds successfully
4. Submitting a pull request

## Program Submission Guidelines

### Directory Structure

Place your program under `programs/<vendor>/<program_name>/`:

```
programs/
  yourname/
    awesome_effect/
      awesome_effect.vhd       # Main VHDL architecture
      awesome_effect.toml      # Configuration file
      component1.vhd           # Optional: additional modules
      README.md                # Optional: program documentation
```

### Vendor/Author Naming

- Use your GitHub username, company name, or a consistent identifier
- Use lowercase with underscores (e.g., `john_smith`, `acme_video`)
- Keep it professional and permanent (avoid changing it later)

### Program Naming

- Use descriptive, clear names (e.g., `color_inverter`, `feedback_mixer`)
- Use lowercase with underscores
- Avoid generic names like `test` or `program1`

## Development Process

### 1. Set Up Your Environment

Follow the setup instructions in the main [README.md](README.md#-quick-start).

### 2. Create Your Program

Follow the [Program Development Guide](videomancer-sdk/docs/program-development-guide.md) in the SDK documentation.

**Key Resources:**
- **[Program Development Guide](videomancer-sdk/docs/program-development-guide.md)** - Complete VHDL development workflow
- **[TOML Configuration Guide](videomancer-sdk/docs/toml-config-guide.md)** - How to configure your program
- **Example Programs:** See `programs/lzx/` for reference implementations

### 3. Build and Test

```bash
# Build your specific program
./build_programs.sh yourname programname
```

See [README.md](README.md#%EF%B8%8F-building-programs) for more build options.

Verify your program:
- Builds without errors for all supported hardware variants
- Produces valid `.vmprog` files in `out/`
- Works correctly on actual Videomancer hardware

## Program Requirements

Your program must meet these requirements to be accepted:

### Technical Requirements

✅ **Implements the standard interface**: Uses `program_yuv444` entity  
✅ **Builds successfully**: No synthesis, place & route, or timing errors  
✅ **Meets timing**: Achieves required frequency (74.25 MHz for HD, 27 MHz for SD)  
✅ **Includes TOML config**: Complete metadata and parameter definitions  
✅ **Proper sync handling**: Correctly delays sync signals to match processing latency

### Documentation Requirements

✅ **VHDL comments**: Clear architecture description, pipeline stages, register map  
✅ **TOML metadata**: Complete program information (name, author, description)  
✅ **Optional README**: Complex programs should include additional documentation

### Code Quality

✅ **Readable code**: Clear signal names, labeled processes, logical organization  
✅ **No warnings**: Clean synthesis with no unintended latches or undefined logic  
✅ **Proper license header**: GPL-3.0 header in all source files  

### Example License Header

```vhdl
-- Copyright (C) 2025 Your Name
-- SPDX-License-Identifier: GPL-3.0-only
--
-- This file is part of Videomancer Community Programs.
-- See LICENSE file in the repository root for full license text.
```

## Testing Your Program

Before submitting:

1. **Build test**: Ensure your program builds for all supported hardware
   ```bash
   ./build_programs.sh yourname programname
   ```

2. **Hardware test**: Load onto Videomancer hardware and verify functionality
   - Test all parameter ranges
   - Check for visual artifacts
   - Verify sync signal integrity

3. **Edge case testing**:
   - Minimum/maximum parameter values
   - Rapid parameter changes
   - Different video formats (HD/SD, analog/HDMI)

## Pull Request Process

### Before Submitting

- [ ] Program builds successfully for all hardware variants
- [ ] Tested on actual hardware
- [ ] All files include proper license headers
- [ ] TOML configuration is complete and valid
- [ ] Code is well-commented and readable

### Submitting Your PR

1. **Fork the repository** on GitHub

2. **Create a feature branch**:
   ```bash
   git checkout -b add-yourname-programname
   ```

3. **Add your program**:
   ```bash
   git add programs/yourname/
   git commit -m "Add yourname/programname: Brief description"
   ```

4. **Push to your fork**:
   ```bash
   git push origin add-yourname-programname
   ```

5. **Create a Pull Request** on GitHub with:
   - Clear description of what your program does
   - List of supported hardware variants
   - Any special considerations or limitations
   - Screenshots or video demonstrations (if applicable)

### PR Template

```markdown
## Program Description
[Describe what your program does and what effect it creates]

## Hardware Compatibility
- [ ] rev_a (if tested)
- [ ] rev_b (if tested)

## Testing
- [ ] Built successfully
- [ ] Tested on hardware
- [ ] All parameters function correctly

## Additional Notes
[Any special information about usage, limitations, or interesting features]
```

### Review Process

- Maintainers will review your submission
- May request changes or improvements
- Once approved, your program will be merged
- You'll be credited as the author in the TOML metadata

## Code of Conduct

### Our Pledge

We are committed to providing a welcoming and inclusive community for everyone interested in video synthesis and FPGA development.

### Expected Behavior

- Be respectful and professional
- Provide constructive feedback
- Focus on the code and technical aspects
- Help others learn and grow

### Unacceptable Behavior

- Harassment or discriminatory language
- Personal attacks or trolling
- Spam or off-topic content
- Malicious code or intentional security vulnerabilities

## License

All contributions must be licensed under **GPL-3.0-only**. By submitting a pull request:
- You confirm the work is your original creation or properly licensed
- You agree to distribute it under GPL-3.0
- You include the required license header in all source files
- You retain copyright with your name in the header

See [LICENSE](LICENSE) for the complete license text.

## Questions?

- **GitHub Issues**: For bug reports or technical problems
- **GitHub Discussions**: For questions, ideas, and community chat
- **SDK Documentation**: See `videomancer-sdk/docs/` for technical reference

Thank you for contributing to the Videomancer community! 🎨📺✨
