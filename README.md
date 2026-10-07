# paste2save (Paste To Save)

A lightweight utility for Windows that captures clipboard images and saves them directly to your desired folder.

---

## ⚡ What's New in Version 3.0 (Recommended)

**paste2save v3.0** is built natively for **Windows 10 & Windows 11**:
* **Direct In-Memory Saving**: Uses PowerShell and .NET (`System.Windows.Forms.Clipboard` & `System.Drawing.Bitmap`) to save images instantly.
* **No MS Paint or SendKeys**: Does away with slow GUI delays, key simulations, and `taskkill` that could disrupt open Paint sessions.
* **Auto-Save Watcher Mode (`-Watch`)**: Automatically monitors your clipboard as you browse the web (Chrome, Edge, Firefox) or take screenshots (`Win + Shift + S`). Every time you copy an image, it is automatically saved to disk without any manual clicks or interruptions!
* **Naming Options**: Supports `timestamp` (`paste_YYYYMMDD_HHMMSS.png`), `sequential` (`paste_0001.png`), `random` (`x12345.png`), or `overwrite` (`x.png`).
* **Format Flexibility**: Saves in `.png`, `.jpg`, or `.bmp`.

### Quick Start (v3.0)
1. Double-click `paste2save.bat` at the root (or inside `paste2save_v3`).
2. An interactive menu with a 5-second countdown will appear:
   * Press **1** (or wait 5s) to save the current clipboard image.
   * Press **5** to start **Auto-Save Watcher** mode (copy images freely while browsing!).
3. Alternatively, run via PowerShell:
   ```powershell
   # Instant save
   .\paste2save_v3\paste2save.ps1

   # Continuous browser watcher
   .\paste2save_v3\paste2save.ps1 -Watch
   ```

---

## 📁 Repository Structure & Versions

* **`paste2save_v3/` (Latest)**: Modern Windows 10/11 engine with Auto-Save Watcher, multiple naming strategies, and zero GUI dependencies.
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
