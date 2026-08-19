# SOYO RGB Studio

Realtime RGB synchronization for Windows PCs with a SOYO ARGB controller, Razer Chroma peripherals, and Lexar ARES RGB memory.

## Features

- Static, breathing, spectrum, wave, screen, and music-reactive effects.
- Low-latency desktop capture with dominant-color extraction.
- System-audio loopback: the screen supplies the base color and loud hits flash red.
- Direct HID control for the SOYO/ASRock LED Dongle (`VID 0416`, `PID 0125`).
- Razer control through the official OpenRGB server.
- Lexar ARES control through a locally installed ASUS Aura SDK and ENE DRAM HAL.
- Per-device toggles, hardware brightness, tray support, and single-instance takeover.
- Latest-frame processing so slow devices never accumulate stale animation frames.

## Supported hardware

| Device | Backend | Notes |
| --- | --- | --- |
| SOYO/ASRock LED Dongle | HID | Tested with two ARGB channels |
| Razer Huntsman V2 | OpenRGB | OpenRGB SDK server on port `6742` |
| Razer Basilisk V3 Pro | OpenRGB | Uses Direct mode without stopping Synapse services |
| Lexar ARES DDR5 RGB | ASUS Aura SDK / ENE | Tested with two 8-LED modules |

Other devices may work but are not yet tested.

## Requirements

- Windows 10 or 11 x64
- Python 3.10+
- Node.js 20+ and pnpm
- [OpenRGB](https://openrgb.org/) with its SDK server enabled on port `6742`
- ASUS Armoury Crate/Aura SDK and the official Lexar/ENE DRAM RGB HAL for memory control

## Development

```powershell
git clone git@github.com:jenyaukraine/Soyo-Rgb.git
cd Soyo-Rgb
python -m pip install -r requirements.txt
pnpm install
pnpm start
```

OpenRGB must already be running with its SDK server enabled.

## Build

The project does not redistribute `AuraServiceLib.dll`. Obtain the managed interop assembly from the official ASUS Aura SDK package and point the build script to it. The script copies it locally and compiles `AuraReceiver.cs`.

```powershell
$env:AURA_SERVICE_LIB = "C:\path\to\official\AuraServiceLib.dll"
pnpm build
```

The portable executable is written to `dist/SOYO-RGB-Studio.exe`.

## SOYO HID protocol

The tested controller accepts 8-byte HID reports:

```text
02 <channel> <led-count> 00 00 00 00 00
03 <channel> 11 <red> <green> <blue> <brightness> <speed-inverse>
```

This implementation updates channels 1 and 2. Hardware revisions may use a different protocol; test cautiously.

## Razer compatibility

The app never terminates Razer processes or services. It uses OpenRGB Direct mode so audio devices, profiles, DPI, and button mappings provided by Synapse remain available. If Synapse Quick Effects visually compete with OpenRGB, disable only the Quick Effect in Synapse rather than closing Synapse itself.

## Security

No kernel driver is included. Download OpenRGB and vendor components only from official sources. See [SECURITY.md](SECURITY.md).

## License

[MIT](LICENSE)
