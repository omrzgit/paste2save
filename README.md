# paste2save (Paste To Save)

A lightweight utility that captures clipboard images and saves them directly to your desired folder.

Available natively for **Windows (PowerShell / Batch)** and **Linux (Bash for Wayland & X11)**.

---

## ⚡ What's New in Version 3.01 (Recommended)

**paste2save v3.01** brings full configuration customization on top of native clipboard engines:

* **⚙️ Interactive Settings Menu (Option 7)**:
  * **Configurable Default Action**: Select any action ([1] Timestamp, [2] Sequential, [3] Random ID, [4] Overwrite, or [5] Auto-Save Watcher) to run automatically.
  * **Configurable Countdown Delay**: Choose any delay from 0 to 60 seconds (setting to 0 executes your default action immediately).
  * **Destination Management**: Update the save folder directly from the menu.
  * **Persistent Config (`config.json`)**: Modern JSON configuration while maintaining backwards compatibility with `location.txt`.
* **Direct In-Memory Saving**: Saves images instantly without opening any photo viewer or GUI app.
* **No MS Paint or SendKeys**: Completely avoids fragile GUI key simulation, timing delays, or killing open Paint sessions.
* **Auto-Save Watcher Mode (`-Watch` / `--watch`)**: Automatically monitors your clipboard as you browse the web (Chrome, Edge, Firefox, Brave) or take screenshots. Every time you copy an image, it is automatically saved to disk without any manual clicks or interruptions!
* **Naming Options**: Supports `timestamp` (`paste_YYYYMMDD_HHMMSS.png`), `sequential` (`paste_0001.png`), `random` (`x12345.png`), or `overwrite` (`x.png`).
* **Format Flexibility**: Saves in `.png`, `.jpg`, or `.bmp`.

---

## 🚀 Quick Start

### Windows (Windows 10 / 11)
1. Double-click `paste2save.bat` at the root (or inside `paste2save_v3`).
2. An interactive menu with countdown will appear:
   * Press **1** (or wait for the configured timeout) to save the current clipboard image.
   * Press **5** to start **Auto-Save Watcher** mode (copy images freely while browsing!).
   * Press **7** to access **Settings** (change default option, timeout delay, or save folder).
3. Alternatively, run via PowerShell:
   ```powershell
   # Instant save
   .\paste2save_v3\paste2save.ps1

   # Continuous browser watcher
   .\paste2save_v3\paste2save.ps1 -Watch

   # Open settings menu directly
   .\paste2save_v3\paste2save.ps1 -Settings
   ```

### Linux (Wayland & X11)
Prerequisites: install `wl-clipboard` (Wayland) or `xclip` (X11):
```bash
# Ubuntu / Debian
sudo apt install wl-clipboard xclip

# Fedora
sudo dnf install wl-clipboard xclip

# Arch Linux
sudo pacman -S wl-clipboard xclip
```

Run the script:
```bash
chmod +x paste2save.sh
./paste2save.sh

# Continuous browser watcher
./paste2save.sh --watch

# Optional: Install system-wide to ~/.local/bin
cd paste2save_linux && ./install.sh
```

---

## 📁 Repository Structure & Versions

* **`paste2save_v3/` (Windows v3.01)**: Modern Windows 10/11 engine with Auto-Save Watcher, multiple naming strategies, settings menu, and zero GUI dependencies.
* **`paste2save_linux/` (Linux v3.01)**: Native Bash implementation supporting Wayland (`wl-paste`) and X11 (`xclip`).
* **`paste2save_v2.5/`**: Added choice timeout menu (overwrite vs random filename `x[rnd].png`) using MS Paint keystrokes.
* **`paste2save_v2.2/`**: Added random filename generation and speed improvements.
* **`paste2save/` (v1.0)**: Initial version using MS Paint keystroke automation to overwrite `x.png`.

---

## ⚙️ How Legacy Versions (v1.0 - v2.5) Worked

1. Copies clipboard image into MS Paint by opening a tiny template image `x.png`.
2. Sends simulated keystrokes (`SendKeys`) via VBScript to paste and open the save dialog.
3. Reads the destination folder from `location.txt` and completes the save dialog.
4. Closes MS Paint via `taskkill`.

*Note: For Windows 11 users, `paste2save_v3` is strongly recommended as modern Windows Paint UI changes can cause keystroke automation to fail.*

---

## 🗺️ Roadmap & Timeline

- [x] **Version 1.0**: Clipboard to `x.png` via MS Paint automation.
- [x] **Version 1.8 / 2.2**: Choice menu to prevent accidental overwrite.
- [x] **Version 2.5**: Fixed timing issues, replaced prompt loops with `CHOICE`.
- [x] **Version 3.0**: Native Windows 11 compatibility without MS Paint / SendKeys, plus **Auto-Save Watcher** mode for seamless browser image copying.
- [x] **Version 3.01**: Settings menu for customizable default action, timeout delay adjustment (0-60s), and unified configuration (`config.json` + `location.txt`).
- [x] **Linux Edition**: Native Bash script with dual Wayland/X11 auto-detection, desktop notifications, and watcher mode.
