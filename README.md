# paste2save (Paste To Save)

A lightweight utility that captures clipboard images and saves them directly to your desired folder.

Available natively for **Windows (PowerShell / Batch)** and **Linux (Bash for Wayland & X11)**.

---

## ⚡ What's New in Version 3.02 (Recommended)

**paste2save v3.02** introduces seamless standby and workflow continuity:

* **🛑 FT1: Standby / Persistent Mode (0 Delay & Keep App Open)**:
  * Setting Timeout Delay to `0` enables standby mode: stops the auto-closing countdown completely.
  * The app remains open in the background waiting indefinitely for your screenshots.
  * After saving a screenshot, instead of terminating, the app **returns directly to the main menu** so you never have to repeatedly relaunch it via shortcuts.
  * **Keep App Open** can also be toggled independently in Settings (`Option [7] -> [3]`).
* **🔄 FT2: Graceful Watcher Exit Returning to Menu**:
  * In Auto-Save Watcher mode (Option `5`), pressing **`Q`**, **`M`**, **`Esc`**, or `Ctrl+C` cleanly stops the watcher and **returns directly to the Main Menu** instead of terminating the app.
* **⚙️ Interactive Settings Menu (Option 7)**:
  * Configure Default Action (1 to 5).
  * Configure Countdown Timeout Delay (0 to 60 seconds).
  * Toggle Keep App Open after saving (ON/OFF).
  * Change Destination Folder (mirrored to `location.txt`).
  * Reset to Factory Defaults.
* **Direct In-Memory Saving**: Uses PowerShell and .NET (`System.Windows.Forms.Clipboard` & `System.Drawing.Bitmap`) to save images instantly without opening any photo viewer or GUI app.
* **No MS Paint or SendKeys**: Avoids fragile GUI key simulations, timing delays, or killing open Paint sessions.
* **Flexible Naming**: Supports `timestamp` (`paste_YYYYMMDD_HHMMSS.png`), `sequential` (`paste_0001.png`), `random` (`x12345.png`), or `overwrite` (`x.png`).

---

## 🚀 Quick Start

### Windows (Windows 10 / 11)
1. Double-click `paste2save.bat` at the root (or inside `paste2save_v3.02`).
2. An interactive menu will appear:
   * Press **1** (or wait for the configured timeout) to save the current clipboard image.
   * Press **5** to start **Auto-Save Watcher** mode (copy images freely while browsing; press **`Q`** to return to menu!).
   * Press **7** to access **Settings** (change default option, timeout delay, toggle keep open, or set save folder).
3. Alternatively, run via PowerShell:
   ```powershell
   # Instant save
   .\paste2save_v3.02\paste2save.ps1

   # Continuous browser watcher
   .\paste2save_v3.02\paste2save.ps1 -Watch

   # Launch in persistent mode (stays open after saving)
   .\paste2save_v3.02\paste2save.ps1 -KeepOpen

   # Open settings menu directly
   .\paste2save_v3.02\paste2save.ps1 -Settings
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

* **`paste2save_v3.02/` (Latest Windows)**: Standby / persistent mode (FT1), graceful watcher exit to menu (FT2), settings menu, and zero GUI dependencies.
* **`paste2save_v3/`**: Windows v3.01 PowerShell native engine.
* **`paste2save_linux/`**: Linux v3.01 native Bash implementation supporting Wayland (`wl-paste`) and X11 (`xclip`).
* **`paste2save_v2.5/`**: Added choice timeout menu (overwrite vs random filename `x[rnd].png`) using MS Paint keystrokes.
* **`paste2save_v2.2/`**: Added random filename generation and speed improvements.
* **`paste2save/` (v1.0)**: Initial version using MS Paint keystroke automation to overwrite `x.png`.

---

## 🗺️ Roadmap & Timeline

- [x] **Version 1.0**: Clipboard to `x.png` via MS Paint automation.
- [x] **Version 1.8 / 2.2**: Choice menu to prevent accidental overwrite.
- [x] **Version 2.5**: Fixed timing issues, replaced prompt loops with `CHOICE`.
- [x] **Version 3.0**: Native Windows 11 compatibility without MS Paint / SendKeys, plus **Auto-Save Watcher** mode for seamless browser image copying.
- [x] **Version 3.01**: Settings menu for customizable default action, timeout delay adjustment (0-60s), and unified configuration (`config.json` + `location.txt`).
- [x] **Linux Edition**: Native Bash script with dual Wayland/X11 auto-detection, desktop notifications, and watcher mode.
- [x] **Version 3.02**: Standby / persistent mode (FT1) to keep app open across multiple screenshots with zero delay, and graceful watcher return to menu (FT2).
