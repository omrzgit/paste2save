# paste2save v3.0

Modern, high-performance clipboard image capture utility designed natively for **Windows 10 & Windows 11**.

---

### What's New in Version 3.0?

1. **Native Windows 10/11 Engine**:
   * Saves clipboard images directly from memory to file via .NET and PowerShell.
   * **Zero reliance on MS Paint**: No GUI windows popping up, no keystroke simulation (`SendKeys`), and no `taskkill` killing your active work.
   * Runs in milliseconds with 100% reliability.

2. **Auto-Save Watcher Mode (`-Watch`)**:
   * Solves the Version 3 roadmap goal: *"automate copying images from browser and saving multiple images without intervention easily"*.
   * Run with `-Watch` or choose Option 5 in the menu: as you browse any web browser (Chrome, Edge, Firefox), simply right-click any image and click **"Copy Image"** (or use `Win + Shift + S` / `PrintScreen`).
   * The utility automatically detects the new clipboard image, saves it to your folder, logs the filename, and provides an audio chime.

3. **Flexible File Naming Strategies**:
   * **Timestamp** (`paste_YYYYMMDD_HHMMSS.png`): Default, never collides, easy chronological sorting.
   * **Sequential** (`paste_0001.png`, `paste_0002.png`): Clean, ordered numbering.
   * **Random** (`x12345.png`): Retains the legacy v2.5 naming scheme.
   * **Overwrite** (`x.png`): Retains the legacy v1/v2 overwrite workflow.

4. **Multiple Formats**:
   * Supports `.png` (default), `.jpg`, and `.bmp`.

---

### How to Use

#### Method 1: Double-Click Launcher
Double-click `paste2save.bat`:
* An interactive menu will appear with a 5-second countdown defaulting to option 1 (instant timestamp save).
* Choose option **5** to enter continuous **Auto-Save Watcher Mode**.

#### Method 2: Command Line / Automation
You can run `paste2save.ps1` or `paste2save.bat` with command-line arguments:

```powershell
# Save single clipboard image with timestamp (default)
.\paste2save.ps1

# Start continuous Auto-Save Watcher
.\paste2save.ps1 -Watch

# Save as sequential JPEG to a custom directory
.\paste2save.ps1 -Destination "D:\Screenshots" -Naming sequential -Format jpg

# Save and automatically open folder in Explorer
.\paste2save.ps1 -OpenFolder
```

---

### Configuration
Edit `location.txt` to set your default save folder. You can use relative paths (like `saved_images` or `..\Pictures`) or absolute paths (like `D:\MyImages`).
