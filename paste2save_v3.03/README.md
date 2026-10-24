# paste2save v3.03

Modern, high-performance clipboard image capture utility designed natively for **Windows 10 & Windows 11**.

---

### What's New in Version 3.03?

1. **FT1: Standby / Persistent Mode (Zero Delay & App Stays Open)**:
   * **Problem solved**: In previous versions, the app auto-closed after saving a screenshot, forcing users to repeatedly click desktop shortcuts or hotkeys.
   * Setting Timeout Delay to `0` enables **Standby Mode**:
     * Stops the auto-firing countdown timer completely.
     * The app stays open in the background waiting indefinitely for user selection.
     * After saving a screenshot, instead of closing, the app **returns immediately to the main menu** ready for your next capture.
   * You can also toggle **Keep App Open** independently in Settings (`Option [7] -> [3]`).

2. **FT2: Graceful Watcher Exit Returning to Main Menu**:
   * **Problem solved**: Previously, stopping Auto-Save Watcher mode killed the entire process via `Ctrl+C`.
   * In v3.03, pressing **`Q`**, **`M`**, **`Esc`**, or `Ctrl+C` while inside Watcher mode cleanly exits the watcher and **returns directly to the Main Menu** without closing the application.

3. **Settings Submenu Enhancements**:
   * `[1]` Change Default Action Option (1 to 5).
   * `[2]` Change Timeout Delay (0 to 60 seconds) — setting to `0` automatically activates Standby / Persistent Mode.
   * `[3]` Toggle Keep App Open after saving (ON/OFF).
   * `[4]` Change Destination Folder (mirrored to `location.txt`).
   * `[5]` Reset All to Factory Defaults.
   * `[0]` Return to Main Menu.

---

### Menu Layout

```text
=======================================================
           paste2save v3.03 (Windows 10/11)            
=======================================================
Save folder:    <TargetFolder>
Default Action: Option [<DefaultOption>] (<OptionDescription>)
Timeout Delay:  Disabled (Standby / Persistent Mode Active)
Behavior:       App stays open after saving screenshots (FT1)

Main Menu:
  [1] Save clipboard image (Timestamp: paste_YYYYMMDD_HHMMSS.png)
  [2] Save clipboard image (Sequential: paste_0001.png)
  [3] Save clipboard image (Random ID:  x12345.png)
  [4] Save clipboard image (Overwrite:  x.png)
  [5] Auto-Save Watcher (Copy images from browser & auto-save)
  [6] Open destination folder in Explorer
  [7] Settings (Configure default action, delay, persistent mode, & folder)
  [0] Exit
```

---

### How to Use

#### Method 1: Double-Click Launcher
Double-click `paste2save.bat`:
* If delay is configured (e.g. 5s), it counts down to your default action.
* If delay is 0, it stays open in standby mode until you choose an option.
* Choose option **5** to start continuous browser image auto-saving; press **`Q`** or **`Esc`** at any time to return to the menu.

#### Method 2: Command Line / Automation
```powershell
# Save single clipboard image with timestamp
.\paste2save.ps1

# Launch in persistent mode (app stays open after saving)
.\paste2save.ps1 -KeepOpen

# Start continuous Auto-Save Watcher
.\paste2save.ps1 -Watch

# Open Settings menu directly
.\paste2save.ps1 -Settings
```
