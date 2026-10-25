# paste2save v3.05

Modern, high-performance clipboard image capture utility designed natively for **Windows 10 & Windows 11**.

---

### What's New in Version 3.05?

1. **🖥️ Windows System Tray (Taskbar Notification Area / Hidden Icons)**:
   * **Minimize to Tray (Option [8])**: Send the application to the hidden icons tray at any time to declutter your desktop.
   * **Silent Tray Launcher (`paste2save_tray.bat` / `-Tray`)**: Starts directly into the system tray completely hidden with zero console window popup. Perfect for placing in `shell:startup` (Windows Startup)!
   * **Left-Click Tray Icon**: Instantly captures and saves the current clipboard image with an audible chime and native Windows balloon popup.
   * **Double-Click Tray Icon**: Restores the console terminal window.
   * **Right-Click Context Menu**:
     * ⚡ **Save Clipboard Image Now**
     * 👁️ **Auto-Save Watcher: [ON / OFF]** *(Toggle background browser image capture directly from tray)*
     * 📁 **Open Saved Images Folder**
     * 🖥️ **Show Console / Main Menu**
     * ⚙️ **Settings**
     * ❌ **Exit**

2. **FT1: Standby / Persistent Mode (Zero Delay & App Stays Open)**:
   * Setting Timeout Delay to `0` enables **Standby Mode**: stops the countdown timer completely.
   * The app stays open in the background waiting indefinitely for user selection.
   * After saving a screenshot, instead of closing, the app **returns immediately to the main menu** ready for your next capture.
   * You can also toggle **Keep App Open** independently in Settings (`Option [7] -> [3]`).

3. **FT2: Graceful Watcher Exit Returning to Main Menu**:
   * In Auto-Save Watcher mode (Option `5`), pressing **`Q`**, **`M`**, **`Esc`**, or `Ctrl+C` cleanly exits the watcher and **returns directly to the Main Menu** without closing the application.

4. **First-Time Setup Prompt**:
   * If `location.txt` is missing on initial start, the app prompts you to choose between saving in the same folder (`.\saved_images`) or entering a custom folder path, setting up `location.txt` and `config.json` automatically.

---

### Menu Layout

```text
=======================================================
           paste2save v3.05 (Windows 10/11)            
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
  [8] Minimize to System Tray (Hidden Icons / Notification Area)
  [0] Exit
```

---

### How to Use

#### Method 1: Standard Launcher
Double-click `paste2save.bat`:
* Opens the interactive console menu.
* Press **`8`** to minimize to the system tray.

#### Method 2: Silent System Tray Launcher
Double-click `paste2save_tray.bat`:
* Runs immediately in the notification area / hidden icons without opening any console window.
* Click the tray icon to save images on demand, or right-click to enable Auto-Save Watcher mode.
* To launch on Windows boot, create a shortcut of `paste2save_tray.bat` in `shell:startup`.

#### Method 3: Command Line / Automation
```powershell
# Save single clipboard image with timestamp
.\paste2save.ps1

# Launch directly into system tray
.\paste2save.ps1 -Tray

# Launch in persistent mode (app stays open after saving)
.\paste2save.ps1 -KeepOpen

# Start continuous Auto-Save Watcher in terminal
.\paste2save.ps1 -Watch

# Open Settings menu directly
.\paste2save.ps1 -Settings
```
