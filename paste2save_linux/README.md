# paste2save (Linux Edition)

Lightweight, native clipboard image capture and auto-save utility for Linux.

Works on both **Wayland** and **X11** desktop environments (GNOME, KDE Plasma, XFCE, Sway, Hyprland, etc.).

---

## ⚡ Features

* **Wayland & X11 Auto-Detection**: Uses `wl-paste` on Wayland and `xclip` on X11.
* **Instant In-Memory Capture**: Saves clipboard image data straight to disk without opening any photo viewer or GUI app.
* **Auto-Save Watcher Mode (`-w` / `--watch`)**: Continuously monitors your clipboard. Copy images from Firefox, Chrome, or screenshot tools (`PrintScreen`, `Spectacle`), and they are saved automatically.
* **Interactive Settings Menu (Option 7)**:
  * Select your default action (Timestamp, Sequential, Random, Overwrite, or Watcher).
  * Configure timeout countdown delay (0 to 60 seconds).
  * Configure destination folder.
* **Desktop Notifications & Audio Feedback**: Alerts you when images are saved via `notify-send` and terminal bell.

---

## 📦 Prerequisites

Install the clipboard tool for your display server:

```bash
# Ubuntu / Debian / Pop!_OS
sudo apt install wl-clipboard xclip

# Fedora / RHEL
sudo dnf install wl-clipboard xclip

# Arch Linux / Manjaro
sudo pacman -S wl-clipboard xclip
```

---

## 🚀 How to Use

### 1. Run Directly
```bash
chmod +x paste2save.sh
./paste2save.sh
```

### 2. Optional: Install System-Wide
```bash
./install.sh
# Now run from anywhere:
paste2save
```

### 3. Command Line Arguments
```bash
# Save single clipboard image with timestamp (default)
./paste2save.sh

# Start Auto-Save Watcher mode
./paste2save.sh --watch

# Open Settings menu directly
./paste2save.sh --settings

# Save to custom directory with sequential numbering
./paste2save.sh -d ~/Pictures/Captures -n sequential -o
```
