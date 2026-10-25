# paste2save (Paste To Save)

A lightweight utility that captures clipboard images and saves them directly to your desired folder.

Available natively for **Windows (PowerShell / Batch)** and **Linux (Bash for Wayland & X11)**.

---

## ⚡ What's New in Version 3.05 (Recommended)

**paste2save v3.05** adds native **Windows System Tray (Taskbar Notification Area / Hidden Icons)** integration on top of the v3 engine:

* **🖥️ System Tray / Hidden Icons Mode**:
  * Run completely in the background without keeping a console window open on your taskbar or desktop.
  * **Option [8]**: Minimize from the console menu straight to the system tray.
  * **`paste2save_tray.bat` / `-Tray`**: Launch directly into the system tray with zero window popup. Place a shortcut in `shell:startup` for automatic background startup on Windows boot!
  * **Left-Click Tray Icon**: Instantly captures and saves the current clipboard image with a native balloon notification.
  * **Double-Click**: Restores the console terminal window.
  * **Right-Click Context Menu**:
    * ⚡ **Save Clipboard Image Now**
    * 👁️ **Auto-Save Watcher: [ON / OFF]** *(Toggle browser image auto-save directly from the tray)*
    * 📁 **Open Saved Images Folder**
    * 🖥️ **Show Console / Main Menu**
    * ⚙️ **Settings**
    * ❌ **Exit**
* **🛑 FT1: Standby / Persistent Mode (0 Delay & Keep App Open)**:
  * Setting Timeout Delay to `0` enables standby mode: stops the auto-closing countdown completely.
  * The app remains open in the background waiting indefinitely for your screenshots.
  * After saving a screenshot, the app **returns directly to the main menu** ready for the next capture.
* **🔄 FT2: Graceful Watcher Exit Returning to Menu**:
  * In Auto-Save Watcher mode, pressing **`Q`**, **`M`**, **`Esc`**, or `Ctrl+C` cleanly stops the watcher and **returns directly to the Main Menu** without terminating the app.
* **📁 First-Time Setup Prompt**:
  * If `location.txt` does not exist on initial start, asks the user whether to save in the same folder (`.\saved_images`) or input a custom destination.
* **Direct In-Memory Saving**: Uses PowerShell and .NET (`System.Windows.Forms.Clipboard` & `System.Drawing.Bitmap`) to save images instantly without opening any photo viewer or GUI app.
* **No MS Paint or SendKeys**: Avoids fragile GUI key simulations, timing delays, or killing open Paint sessions.
* **Flexible Naming**: Supports `timestamp` (`paste_YYYYMMDD_HHMMSS.png`), `sequential` (`paste_0001.png`), `random` (`x12345.png`), or `overwrite` (`x.png`).

---

## 🚀 Quick Start

### Windows (Windows 10 / 11)
1. **Interactive Console**: Double-click `paste2save.bat` at the root (or inside `paste2save_v3.05`).
   * Press **1** to save current clipboard image.
   * Press **5** for Auto-Save Watcher mode.
   * Press **8** to minimize to System Tray (Hidden Icons).
2. **Background System Tray**: Double-click `paste2save_tray.bat` to launch directly into the system tray without a console window.
3. Alternatively, run via PowerShell:
   ```powershell
   # Instant save
   .\paste2save_v3.05\paste2save.ps1

   # Run minimized in System Tray
   .\paste2save_v3.05\paste2save.ps1 -Tray

   # Continuous browser watcher
   .\paste2save_v3.05\paste2save.ps1 -Watch

   # Launch in persistent mode (stays open after saving)
   .\paste2save_v3.05\paste2save.ps1 -KeepOpen

   # Open settings menu directly
   .\paste2save_v3.05\paste2save.ps1 -Settings
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

* **`paste2save_v3.05/` (Latest Windows)**: Native System Tray integration (hidden icons / balloon tips / tray context menu), standby mode (FT1), watcher exit to menu (FT2), settings menu, and zero GUI dependencies.
* **`paste2save_v3.03/`**: Standby mode (FT1), graceful watcher exit to menu (FT2), and first-run setup prompt.
* **`paste2save_v3/`**: Initial Windows v3.01 PowerShell native engine.
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
- [x] **Version 3.03**: Standby / persistent mode (FT1) to keep app open across multiple screenshots with zero delay, and graceful watcher return to menu (FT2).
- [x] **Version 3.05**: Windows Taskbar System Tray (Notification Area / Hidden Icons) support, tray context menu, background watcher toggle, and silent startup.
