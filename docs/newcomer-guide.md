# Newcomer's Guide to Videomancer Community Programs

A complete, step-by-step walkthrough for people who have never used GitHub, never built FPGA software, and never written VHDL. Follow it from top to bottom and you will end with your own Videomancer program running on hardware and submitted as a pull request to this repository.

This guide assumes nothing. If a step seems obvious, skip it.

## Table of Contents

1. [What you will need](#1-what-you-will-need)
2. [Create a GitHub account and fork the repository](#2-create-a-github-account-and-fork-the-repository)
3. [Install prerequisites and clone the repository](#3-install-prerequisites-and-clone-the-repository)
4. [Build the repository](#4-build-the-repository)
5. [Create your own program from `passthru`](#5-create-your-own-program-from-passthru)
6. [Load the program onto Videomancer (LZX Connect / microSD)](#6-load-the-program-onto-videomancer-lzx-connect--microsd)
7. [Submit a pull request back to this repository](#7-submit-a-pull-request-back-to-this-repository)
8. [Where to get help](#8-where-to-get-help)

---

## 1. What you will need

**Hardware**
- A computer running **Linux**, **macOS** (Intel or Apple Silicon), or **Windows 10/11**.
- About **5 GB of free disk space** (the FPGA toolchain is large).
- A **Videomancer** unit, its power supply, and an HDMI monitor and source for testing.
- A **microSD card** (any size, formatted FAT32) and a card reader for transferring programs.
- A **USB-A to USB-C cable** if you also plan to update firmware.

**Accounts**
- A free **GitHub** account (created in step 2).

**Approximate time**
- Initial setup (downloads + first build): 30–90 minutes depending on internet speed.
- Per-edit rebuild of one program: a few minutes.

---

## 2. Create a GitHub account and fork the repository

GitHub is the website that hosts this repository. A *fork* is your personal copy of the repository on GitHub; you make changes there before proposing them back to the original.

### 2.1 Create a GitHub account

1. Open https://github.com/signup in a web browser.
2. Enter your email, choose a password, and pick a username. Your username will appear in URLs and in your program directory name, so choose something durable and lowercase-friendly (e.g., `janedoe`, not `J@ne_Doe!`).
3. Verify your email address by clicking the link GitHub sends you.
4. Sign in at https://github.com/login.

### 2.2 Fork this repository

1. Go to https://github.com/lzxindustries/videomancer-community-programs.
2. In the top-right corner of the page, click the **Fork** button.
3. On the "Create a new fork" page, leave the defaults (owner = your username, repository name unchanged) and click **Create fork**.
4. After a few seconds you will land on `https://github.com/<your-username>/videomancer-community-programs`. This is your personal copy.

Your fork tracks the original repository but is fully under your control. All edits you make for this guide will live there until you propose them back via a pull request in step 7.

---

## 3. Install prerequisites and clone the repository

You need **Git** (to download the code) and platform-specific build tools. The setup script in this repository installs the FPGA toolchain (OSS CAD Suite) for you, but Git and a working shell must already be present.

### 3.1 Linux (Ubuntu / Debian)

Open a terminal and run:

```bash
sudo apt update
sudo apt install -y git build-essential cmake python3 python3-pip python3-pil python3-cryptography
```

For other distributions, install the equivalents (`git`, a C/C++ toolchain, CMake, Python 3, Pillow, and `cryptography`).

### 3.2 macOS

1. Install **Homebrew** (https://brew.sh) if you do not already have it. Open Terminal and paste:
   ```bash
   /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
   ```
2. Install Git and Python:
   ```bash
   brew install git python
   ```
3. The Apple-provided Xcode Command Line Tools (compilers, `make`) install automatically the first time you run `git`. If prompted, click **Install**.

### 3.3 Windows

The build toolchain is Linux-native. The supported way to use it on Windows is **WSL2** (Windows Subsystem for Linux), which runs a real Ubuntu environment inside Windows.

1. Open **PowerShell** as Administrator and run:
   ```powershell
   wsl --install
   ```
   This installs WSL2 and Ubuntu. Reboot when asked.
2. Launch **Ubuntu** from the Start menu. Create a Linux username and password when prompted.
3. From now on, **all the Linux instructions in this guide apply inside the Ubuntu (WSL) terminal**, not in PowerShell or Command Prompt. Run the apt commands from section 3.1 inside Ubuntu.
4. Your Windows drives are accessible inside WSL under `/mnt/c/`, `/mnt/d/`, and so on. For best performance keep this repository inside the WSL filesystem (e.g., `~/code/`), not under `/mnt/c/`.

> Native Windows builds (without WSL) are not supported by the SDK setup script.

### 3.4 Clone your fork

Replace `<your-username>` with the GitHub username you chose in step 2.

```bash
cd ~                                       # or any directory you prefer
git clone https://github.com/<your-username>/videomancer-community-programs.git
cd videomancer-community-programs
git submodule update --init --recursive
```

The last command downloads the bundled [videomancer-sdk](videomancer-sdk/README.md), which lives inside this repository as a Git submodule. You **must** run it, otherwise the build will fail.

### 3.5 Run the one-time setup

```bash
./scripts/setup.sh
```

This script:

- Detects your operating system.
- Installs additional system dependencies (Linux uses `sudo apt`, macOS uses `brew`).
- Downloads the **OSS CAD Suite** (~1.5 GB), which includes Yosys, nextpnr, GHDL, and Icestorm — the tools that turn your VHDL into an FPGA bitstream.
- Extracts it to `videomancer-sdk/build/oss-cad-suite/`.

The download can take a long time on a slow connection. If it fails partway, just rerun the script — it reuses any partial download.

When the script ends with `Setup complete!`, you are ready to build.

---

## 4. Build the repository

The build script is [build_programs.sh](../build_programs.sh) at the repository root. It compiles VHDL programs into `.vmprog` files that Videomancer can load.

### 4.1 Build everything

```bash
./build_programs.sh
```

This compiles every program under [programs/](../programs/) for every hardware revision listed in each program's TOML file. The first build is the slowest; later builds reuse cached toolchain state.

### 4.2 Build a single vendor's programs

Where `<vendor>` is one of the directory names under `programs/`:

```bash
./build_programs.sh boneoh
```

### 4.3 Build a single program

```bash
./build_programs.sh boneoh rgb_window_key
```

This is what you will run repeatedly while developing your own program.

### 4.4 Where the output files go

After a successful build:

```
out/
└── rev_b/
    └── <vendor>/
        └── <program_name>.vmprog
```

The `.vmprog` file is a single self-contained package: bitstreams, configuration, and (optionally) an Ed25519 signature. **This is the file you copy to Videomancer.**

Intermediate build artifacts (per-program logs, generated bitstreams, synthesis reports) are kept under `build/programs/<vendor>/<program>/<hardware>/`. Look there if a build fails — the scrolled-back terminal output will reference these files.

### 4.5 Common first-run problems

| Symptom | Cause / Fix |
|---|---|
| `videomancer-sdk not found` | You skipped `git submodule update --init --recursive`. Run it now. |
| `OSS CAD Suite not found` | You skipped `./scripts/setup.sh`. Run it now. |
| `Permission denied` on `build_programs.sh` | Make it executable: `chmod +x build_programs.sh`. |
| Build fails on macOS with `command not found` | Reopen the terminal after installing Homebrew so `$PATH` updates. |
| Out-of-disk-space | OSS CAD Suite is ~3 GB extracted. Free space and rerun setup. |

---

## 5. Create your own program from `passthru`

The simplest reference program is `passthru`, which forwards the input video stream to the output unchanged. We will copy it, rename it, run it as-is to confirm everything works, then make a small change to prove you can edit and re-build successfully.

The original lives in the SDK at `videomancer-sdk/programs/passthru/`. Do **not** edit it there — that is shared upstream code.

### 5.1 Copy the passthru template into your vendor directory

Pick a vendor name. Use your GitHub username, lowercase, no spaces. The example below uses `janedoe` — replace it with your own throughout.

```bash
mkdir -p programs/janedoe
cp -r videomancer-sdk/programs/passthru programs/janedoe/my_first_program
cd programs/janedoe/my_first_program
```

You will see four files copied:

```
my_first_program/
├── passthru.toml          # configuration / metadata
├── passthru.vhd           # VHDL source
├── passthru.py            # optional build hook
└── .lzx-status.toml       # internal status file (delete this)
```

### 5.2 Rename the files

Each program directory must contain `<program_name>.vhd` and `<program_name>.toml`, where the names match the directory.

```bash
rm .lzx-status.toml
mv passthru.toml my_first_program.toml
mv passthru.vhd  my_first_program.vhd
mv passthru.py   my_first_program.py     # rename only if you want to keep it; otherwise delete
```

If you do not need a Python build hook, simply delete `passthru.py`.

### 5.3 Update the TOML metadata

Open [my_first_program.toml](../programs/) in any text editor. Replace the `[program]` block with values that describe your program. A minimum viable file looks like this:

```toml
# Copyright (C) 2026 Jane Doe
# SPDX-License-Identifier: GPL-3.0-only

[program]
program_id              = "com.github.janedoe.my_first_program"
program_name            = "My First Program"
program_version         = "0.1.0"
abi_version             = ">=1.0,<2.0"
author                  = "Jane Doe"
license                 = "GPL-3.0"
categories              = ["Color"]
program_type            = "processing"
description             = "My first Videomancer program, based on passthru."
url                     = "https://github.com/janedoe/videomancer-community-programs"
hardware_compatibility  = ["rev_b"]
core                    = "yuv444_30b"
```

Field reference: [TOML Configuration Guide](../videomancer-sdk/docs/toml-config-guide.md). Rules to remember:

- `program_id` must be globally unique. The convention is `com.github.<your-username>.<program_name>`.
- `program_name` is what appears on the Videomancer's LCD (max 31 characters).
- `program_version` follows [Semantic Versioning](https://semver.org). Start at `0.1.0` while developing.
- `program_type` is `"processing"` (transforms incoming video) or `"synthesis"` (generates video without an input).
- `categories` is an array of up to 8 tags from [program-categories.md](../videomancer-sdk/docs/program-categories.md).
- `hardware_compatibility = ["rev_b"]` is correct for current shipping units.

### 5.4 Update the VHDL header

Open `my_first_program.vhd`. Update the comment block at the top (program name, author, description) and change the architecture name on the last `architecture` line so it matches your program. The architecture name in VHDL must match the file's program identity:

```vhdl
architecture my_first_program of program_top is
begin
    -- ...existing code...
end architecture my_first_program;
```

The original file declares `architecture passthru of program_top is` — change `passthru` to `my_first_program` in **both** the opening line and the closing `end architecture` line.

### 5.5 First build of the unmodified copy

From the repository root:

```bash
cd ../../..                          # back to the repo root
./build_programs.sh janedoe my_first_program
```

If the build succeeds you will see:

```
out/rev_b/janedoe/my_first_program.vmprog
```

If it fails, the most common causes are:

- The architecture name in the `.vhd` file does not match what the build expects (it expects `architecture <something> of program_top`; the `<something>` can be any identifier as long as both opening and closing lines agree).
- The `.toml` file references a `program_id` that contains illegal characters.
- File names do not match the directory name.

### 5.6 Make a real change — invert the picture

Now do something visible. Replace the body of the architecture in `my_first_program.vhd` with a one-line color inversion:

```vhdl
architecture my_first_program of program_top is
begin
    p_invert : process(clk)
    begin
        if rising_edge(clk) then
            -- Forward sync signals unchanged
            data_out.hsync_n <= data_in.hsync_n;
            data_out.vsync_n <= data_in.vsync_n;
            data_out.field_n <= data_in.field_n;
            data_out.avid    <= data_in.avid;

            -- Invert each video channel (10-bit, max value 1023)
            data_out.y <= std_logic_vector(to_unsigned(1023, 10) - unsigned(data_in.y));
            data_out.u <= std_logic_vector(to_unsigned(1023, 10) - unsigned(data_in.u));
            data_out.v <= std_logic_vector(to_unsigned(1023, 10) - unsigned(data_in.v));
        end if;
    end process p_invert;
end architecture my_first_program;
```

Rebuild:

```bash
./build_programs.sh janedoe my_first_program
```

You now have a working color inverter at `out/rev_b/janedoe/my_first_program.vmprog`.

### 5.7 (Optional) Simulate before you load

The SDK ships a still-image simulator that runs the actual VHDL through GHDL — no hardware required. See the [VHDL Image Tester README](../videomancer-sdk/tools/vhdl-image-tester/README.md). This is the fastest way to iterate on visual effects.

### 5.8 Where to learn more

When you are ready to write something more interesting than an inverter:

- [Program Development Guide](../videomancer-sdk/docs/program-development-guide.md) — full VHDL workflow, pipeline structure, register handling.
- [TOML Configuration Guide](../videomancer-sdk/docs/toml-config-guide.md) — every parameter type and option.
- [ABI Format](../videomancer-sdk/docs/abi-format.md) — what the registers mean.
- [AI Program Generation Guide](../videomancer-sdk/docs/ai-program-generation-guide.md) — using LLMs to scaffold programs.

---

## 6. Load the program onto Videomancer (LZX Connect / microSD)

There are two ways to get a `.vmprog` file onto Videomancer. Today, **microSD card** is the supported method for loading user programs. **LZX Connect** is currently a desktop application for firmware updates; library/program management is planned but not yet shipping. Both paths are described below so you can use whichever fits.

### 6.1 Method A — microSD card (works today)

#### 6.1.1 Format the card

- Use any microSD card up to 2 TB.
- Format it **FAT32** on your computer. (Videomancer also accepts FAT12, FAT16, and exFAT, but FAT32 is the recommended default.)
  - **Linux**: use `gnome-disks`, KDE's Partition Manager, or `mkfs.vfat -F 32 /dev/sdX1` (replace `sdX1` with the correct device — *be very careful, this command erases the target*).
  - **macOS**: open **Disk Utility**, select the card, click **Erase**, choose **MS-DOS (FAT)**.
  - **Windows**: right-click the card in File Explorer → **Format** → File system **FAT32**.

#### 6.1.2 Copy the `.vmprog`

Just copy `out/rev_b/janedoe/my_first_program.vmprog` to the card. Folder structure does not matter — Videomancer recursively scans the entire card for `.vmprog` files. A clean layout helps you stay organised:

```
<microSD>/
└── community/
    └── janedoe/
        └── my_first_program.vmprog
```

Eject the card cleanly from your operating system before removing it.

#### 6.1.3 Insert the card and enable Developer Mode

Third-party programs (anything with a version below `1.0.0`, or any program not signed by LZX) are hidden by default. Turn on **Developer Mode** so they appear in the program list:

1. Power Videomancer on.
2. Press the **SYSTEM** button.
3. Turn the **Rotary Encoder** until the display shows **Developer Mode**.
4. Press the encoder, turn it to **Enabled**, press to confirm.
5. When asked **Restart Device?**, select **Yes**.

After reboot, Videomancer rescans internal flash and the microSD card, including your new program.

#### 6.1.4 Load and test

1. Press **SYSTEM** so the top row shows the currently loaded program name.
2. Press the **Rotary Encoder** — a `>` cursor appears on the left.
3. Turn the encoder until you see **My First Program** (or whatever you set in `program_name`).
4. Press the encoder to load it. Outputs go dark for a few seconds during reconfiguration.
5. Apply a video signal. If you used the inverter from section 5.6 you should see the picture with inverted luma and chroma.
6. The Parameter knobs map to the registers your program defines in its TOML. The unmodified passthru ignores all of them.

### 6.2 Method B — LZX Connect (firmware updates today, library management planned)

LZX Connect is the official LZX desktop application. As of the time of writing, its public role is **firmware updates** for Videomancer (and forthcoming Chromagnon). Program library/sideloading features are on the roadmap but are not yet released.

If you want to install LZX Connect now (e.g., to update firmware before testing your program):

1. Visit https://lzxindustries.net/connect.
2. Download the build for **Windows**, **macOS**, or **Linux**.
3. Install it like any other desktop application:
   - **Windows**: run the installer, follow prompts.
   - **macOS**: open the `.dmg`, drag the app to **Applications**, right-click → **Open** the first time to bypass Gatekeeper.
   - **Linux**: extract the archive (or install the provided package) and run the binary.
4. Connect Videomancer to the computer with a **USB-A to USB-C** cable into Videomancer's **Device** port (not the Host port).
5. Launch LZX Connect; follow the in-app prompts to update firmware.

When LZX Connect adds program-library management, this guide will be updated. Until then, **use the microSD method in section 6.1 to deploy your `.vmprog` files**.

> Manual firmware update without LZX Connect (in case you prefer it) is documented in the [Videomancer User Manual — Firmware Update section](https://lzxindustries.net/instruments/videomancer/manual/user-manual). It involves copying a `.UF2` file to a USB mass-storage device that appears when Videomancer is booted with the **BOOT** button held.

---

## 7. Submit a pull request back to this repository

When your program works on hardware and you are ready to share it, you propose your changes back to the upstream community repository as a *pull request* (PR).

### 7.1 Pre-flight checklist

Before you open a PR, confirm:

- [ ] The program lives under `programs/<your-vendor>/<program_name>/`, with file names matching the directory.
- [ ] Both `<program_name>.vhd` and `<program_name>.toml` are present.
- [ ] The TOML has unique `program_id`, valid `program_version`, your `author` and `license`, and a meaningful `description`.
- [ ] Every source file has a GPL-3.0 license header.
- [ ] `./build_programs.sh <your-vendor> <program_name>` succeeds with no errors.
- [ ] You tested the resulting `.vmprog` on actual hardware.
- [ ] You did **not** modify anything inside `videomancer-sdk/` (it is a submodule and is managed upstream).

### 7.2 Configure Git the first time

If this is your first time using Git on this machine, set your identity. Use the same email as your GitHub account (or a no-reply address from GitHub's email settings if you prefer privacy):

```bash
git config --global user.name  "Jane Doe"
git config --global user.email "you@example.com"
```

### 7.3 Create a branch

Never commit directly to `main`. Create a feature branch with a descriptive name:

```bash
cd ~/videomancer-community-programs       # repository root
git checkout main
git pull origin main                      # make sure your fork's main is current
git checkout -b add-janedoe-my-first-program
```

### 7.4 Commit your changes

Stage just your program directory (don't accidentally commit `out/` or `build/`):

```bash
git add programs/janedoe/my_first_program/
git status                                # review the list — make sure it's only your files
git commit -m "Add janedoe/my_first_program: simple color inverter"
```

### 7.5 Push to your fork

```bash
git push origin add-janedoe-my-first-program
```

The first push prompts for credentials. GitHub no longer accepts account passwords here — use a **Personal Access Token** (Profile → **Settings** → **Developer settings** → **Personal access tokens** → **Tokens (classic)** → **Generate new token**, give it `repo` scope) or set up an SSH key (https://docs.github.com/authentication/connecting-to-github-with-ssh). Save the token in a password manager.

### 7.6 Open the pull request on GitHub

1. Open https://github.com/lzxindustries/videomancer-community-programs in your browser.
2. GitHub typically shows a yellow banner: **"add-janedoe-my-first-program had recent pushes — Compare & pull request"**. Click that button. If it does not appear, click **Pull requests** → **New pull request** → **compare across forks** and pick your fork and branch.
3. Ensure:
   - **base repository**: `lzxindustries/videomancer-community-programs`, **base**: `main`.
   - **head repository**: `<your-username>/videomancer-community-programs`, **compare**: `add-janedoe-my-first-program`.
4. Fill out the PR description. A good template:

   ```markdown
   ## Program Description
   A brief description of what the program does and what visual effect it produces.

   ## Hardware Compatibility
   - [x] rev_b (tested on hardware)

   ## Testing
   - [x] Builds successfully via `./build_programs.sh janedoe my_first_program`
   - [x] Loaded onto Videomancer via microSD and verified working
   - [x] All declared parameters function correctly

   ## Notes
   Any caveats, known limitations, or interesting implementation details.
   ```

5. Click **Create pull request**.

### 7.7 The review cycle

- Continuous integration runs automatically — wait a few minutes for the green check or a red ✗.
- If CI fails, click the failing check to see the log. Fix the issue locally, commit, and `git push`. The PR updates automatically.
- A maintainer will review and may request changes. Reply in the PR conversation, push fixes, repeat until approved.
- Once merged, your program is part of the official community programs repository. Your name in the TOML credits you as author.

### 7.8 Keeping your fork up to date for future contributions

Periodically sync your fork with upstream so future branches start from current code:

```bash
git remote add upstream https://github.com/lzxindustries/videomancer-community-programs.git   # one-time
git fetch upstream
git checkout main
git merge upstream/main
git push origin main
git submodule update --init --recursive
```

---

## 8. Where to get help

- **Repository documentation**: [README](../README.md), [CONTRIBUTING](../CONTRIBUTING.md).
- **SDK documentation**: [videomancer-sdk/docs/](../videomancer-sdk/docs/).
- **GitHub Issues**: https://github.com/lzxindustries/videomancer-community-programs/issues for bug reports.
- **GitHub Discussions** (where enabled) for questions and ideas.
- **LZX Community**: https://community.lzxindustries.net and the LZX Discord (linked from https://lzxindustries.net).
- **Videomancer User Manual**: https://lzxindustries.net/instruments/videomancer/manual/user-manual.

Welcome to the community.
