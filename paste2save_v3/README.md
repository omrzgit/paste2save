# paste2save v3.01

Modern, high-performance clipboard image capture utility designed natively for **Windows 10 & Windows 11**.

---

### What's New in Version 3.01?

1. **Configurable Settings Menu (Option 7)**:
   * **Custom Default Option**: Choose which action runs automatically (Option 1: Timestamp, 2: Sequential, 3: Random, 4: Overwrite, or 5: Auto-Save Watcher).
   * **Customizable Countdown Delay**: Adjust the timeout delay between 0 and 60 seconds (setting to 0 executes the default option immediately).
   * **Destination Folder Management**: Easily change the save folder directly from the Settings menu.
   * **Persistent Settings (`config.json`)**: Settings persist across runs in `config.json` while maintaining full backwards compatibility with `location.txt`.
   * **Factory Reset**: Quickly reset settings to original defaults (Option 1, 5s delay, `saved_images`).

2. **Native Windows 10/11 Engine**:
   * Saves clipboard images directly from memory to file via .NET and PowerShell.
   * **Zero reliance on MS Paint**: No GUI windows popping up, no keystroke simulation (`SendKeys`), and no `taskkill` killing your active work.
   * Runs in milliseconds with 100% reliability.

3. **Auto-Save Watcher Mode (`-Watch` / Option 5)**:
   * Run with `-Watch` or choose Option 5 in the menu: as you browse any web browser (Chrome, Edge, Firefox, Brave), simply right-click any image and click **"Copy Image"** (or use `Win + Shift + S` / `PrintScreen`).
   * The utility automatically detects the new clipboard image, saves it to your folder, logs the filename, and provides an audio chime.

4. **Flexible File Naming Strategies**:
   * **Timestamp** (`paste_YYYYMMDD_HHMMSS.png`): Default, never collides, easy chronological sorting.
   * **Sequential** (`paste_0001.png`, `paste_0002.png`): Clean, ordered numbering.
   * **Random** (`x12345.png`): Retains legacy v2.5 naming scheme.
   * **Overwrite** (`x.png`): Retains legacy v1.0 overwrite workflow.

5. **Multiple Formats**:
   * Supports `.png` (default), `.jpg`, and `.bmp`.

---

### Menu Layout

```text
=======================================================
           paste2save v3.01 (Windows 10/11)            
=======================================================
Save folder:    <TargetFolder>
Default Action: Option [<DefaultOption>] (<OptionDescription>)
Default Delay:  [<DefaultDelaySeconds>] second(s)

Main Menu:
  [1] Save clipboard image (Timestamp: paste_YYYYMMDD_HHMMSS.png)
  [2] Save clipboard image (Sequential: paste_0001.png)
  [3] Save clipboard image (Random ID:  x12345.png)
  [4] Save clipboard image (Overwrite:  x.png)
  [5] Auto-Save Watcher (Copy images from browser & auto-save)
  [6] Open destination folder in Explorer
  [7] Settings (Change default option, timeout delay, & folder)
  [0] Exit
```

---

### How to Use

#### Method 1: Double-Click Launcher
Double-click `paste2save.bat`:
* An interactive menu will appear with your configured countdown delay, defaulting to your selected default action.
* Press **7** to access the Settings menu.

#### Method 2: Command Line / Automation
You can run `paste2save.ps1` or `paste2save.bat` with command-line arguments:

```powershell
# Save single clipboard image with timestamp (default)
.\paste2save.ps1

# Start continuous Auto-Save Watcher
.\paste2save.ps1 -Watch

# Open Settings menu directly
.\paste2save.ps1 -Settings

# Save as sequential JPEG to a custom directory
.\paste2save.ps1 -Destination "D:\Screenshots" -Naming sequential -Format jpg

# Save and automatically open folder in Explorer
.\paste2save.ps1 -OpenFolder
```

---

### Configuration
Settings are saved in `config.json` and mirrored to `location.txt`:
```json
{
  "Destination": "saved_images",
  "DefaultOption": "1",
  "DefaultDelaySeconds": 5
}
```

---

### Future Roadmap
* **Linux Bash Port**: Native Bash implementation using `xclip` / `wl-paste` for Linux desktop environments (X11 & Wayland).
