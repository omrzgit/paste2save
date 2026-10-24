#!/usr/bin/env bash
# ==============================================================================
# paste2save v3.01 (Linux Edition)
# Lightweight, native clipboard image capture and auto-save utility for Linux.
# Supports both Wayland (wl-clipboard) and X11 (xclip / xsel).
# ==============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="${SCRIPT_DIR}/config.json"
LOCATION_FILE="${SCRIPT_DIR}/location.txt"

# ANSI Colors
C_RESET="\033[0m"
C_BOLD="\033[1m"
C_GREEN="\033[32m"
C_CYAN="\033[36m"
C_YELLOW="\033[33m"
C_GRAY="\033[90m"
C_RED="\033[31m"
C_WHITE="\033[97m"

# CLI Arguments defaults
CLI_DEST=""
CLI_NAMING="timestamp"
CLI_FORMAT="png"
CLI_WATCH=false
CLI_SETTINGS=false
CLI_NO_SOUND=false
CLI_OPEN_FOLDER=false
CLI_POLL_MS=500

detect_clipboard_backend() {
    if [[ "${XDG_SESSION_TYPE:-}" == "wayland" ]] && command -v wl-paste >/dev/null 2>&1; then
        CLIP_BACKEND="wayland"
    elif command -v xclip >/dev/null 2>&1; then
        CLIP_BACKEND="xclip"
    elif command -v wl-paste >/dev/null 2>&1; then
        CLIP_BACKEND="wayland"
    elif command -v xsel >/dev/null 2>&1; then
        CLIP_BACKEND="xsel"
    else
        CLIP_BACKEND=""
    fi
}

check_backend_installed() {
    if [[ -z "$CLIP_BACKEND" ]]; then
        echo -e "${C_RED}[!] Error: No supported clipboard tool found.${C_RESET}"
        echo -e "Please install either ${C_BOLD}wl-clipboard${C_RESET} (Wayland) or ${C_BOLD}xclip${C_RESET} (X11):"
        echo -e "  Ubuntu/Debian: ${C_CYAN}sudo apt install wl-clipboard xclip${C_RESET}"
        echo -e "  Fedora:        ${C_CYAN}sudo dnf install wl-clipboard xclip${C_RESET}"
        echo -e "  Arch Linux:    ${C_CYAN}sudo pacman -S wl-clipboard xclip${C_RESET}"
        exit 1
    fi
}

prompt_first_time_location() {
    clear || true
    echo -e "${C_GREEN}=======================================================${C_RESET}"
    echo -e "${C_CYAN}          paste2save v3.03 - First-Time Setup          ${C_RESET}"
    echo -e "${C_GREEN}=======================================================${C_RESET}"
    echo -e "${C_YELLOW}Welcome! 'location.txt' was not found.${C_RESET}"
    echo ""
    echo -e "${C_WHITE}Where would you like to store your saved images?${C_RESET}"
    echo ""
    echo -e "  [1] Same folder      (subfolder: ./saved_images) [DEFAULT in 5s]"
    echo -e "  [2] Different folder (enter custom path, e.g. ~/Pictures)"
    echo ""

    local choice=""
    echo -n -e "${C_YELLOW}Press [1] or [2] (or wait 5s for default [1]): ${C_RESET}"
    if ! read -t 5 -n 1 -r choice; then
        echo -e "\n${C_CYAN}Defaulting to [1] (Same folder)...${C_RESET}"
        choice="1"
    else
        echo ""
    fi

    if [[ "$choice" == "2" ]]; then
        echo -e "\n${C_CYAN}Enter directory path (e.g. ~/Pictures):${C_RESET}"
        read -r -p "Path: " custom_path
        if [[ -n "${custom_path// /}" ]]; then
            CONF_DEST="$custom_path"
        fi
    else
        CONF_DEST="saved_images"
    fi

    local resolved
    resolved="$(resolve_path "$CONF_DEST")"
    mkdir -p "$resolved"
    echo -e "${C_GREEN}[+] Storing images in: ${CONF_DEST} (${resolved})${C_RESET}"
    sleep 1
    save_config
}

# ------------------------------------------------------------------------------
# Configuration Handling
# ------------------------------------------------------------------------------
load_config() {
    CONF_DEST="saved_images"
    CONF_DEFAULT_OPT="1"
    CONF_DELAY=5

    if [[ -f "$CONFIG_FILE" ]]; then
        if command -v jq >/dev/null 2>&1; then
            CONF_DEST="$(jq -r '.Destination // "saved_images"' "$CONFIG_FILE" 2>/dev/null || echo "saved_images")"
            CONF_DEFAULT_OPT="$(jq -r '.DefaultOption // "1"' "$CONFIG_FILE" 2>/dev/null || echo "1")"
            CONF_DELAY="$(jq -r '.DefaultDelaySeconds // 5' "$CONFIG_FILE" 2>/dev/null || echo 5)"
        else
            # Simple grep/sed fallback when jq is not installed
            local dest_val def_val del_val
            dest_val="$(grep -o '"Destination"[[:space:]]*:[[:space:]]*"[^"]*"' "$CONFIG_FILE" | sed -E 's/.*"Destination"[[:space:]]*:[[:space:]]*"([^"]*)".*/\1/')"
            def_val="$(grep -o '"DefaultOption"[[:space:]]*:[[:space:]]*"[^"]*"' "$CONFIG_FILE" | sed -E 's/.*"DefaultOption"[[:space:]]*:[[:space:]]*"([^"]*)".*/\1/')"
            del_val="$(grep -o '"DefaultDelaySeconds"[[:space:]]*:[[:space:]]*[0-9]*' "$CONFIG_FILE" | sed -E 's/.*"DefaultDelaySeconds"[[:space:]]*:[[:space:]]*([0-9]*).*/\1/')"
            [[ -n "$dest_val" ]] && CONF_DEST="$dest_val"
            [[ -n "$def_val" ]] && CONF_DEFAULT_OPT="$def_val"
            [[ -n "$del_val" ]] && CONF_DELAY="$del_val"
        fi
    elif [[ -f "$LOCATION_FILE" ]]; then
        local loc_val
        loc_val="$(tr -d '\r\n' < "$LOCATION_FILE" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"
        [[ -n "$loc_val" ]] && CONF_DEST="$loc_val"
        save_config
    else
        if [[ "$CLI_WATCH" != "true" && "$CLI_SETTINGS" != "true" && "$HAS_CLI_ARGS" != "true" ]]; then
            prompt_first_time_location
        else
            save_config
        fi
    fi
}

save_config() {
    cat <<EOF > "$CONFIG_FILE"
{
  "Destination": "$CONF_DEST",
  "DefaultOption": "$CONF_DEFAULT_OPT",
  "DefaultDelaySeconds": $CONF_DELAY
}
EOF
    echo -n "$CONF_DEST" > "$LOCATION_FILE"
}

resolve_path() {
    local p="$1"
    if [[ "$p" = /* ]]; then
        echo "$p"
    else
        echo "${SCRIPT_DIR}/${p}"
    fi
}

get_option_description() {
    case "$1" in
        1) echo "Timestamp save (paste_YYYYMMDD_HHMMSS.png)" ;;
        2) echo "Sequential save (paste_0001.png)" ;;
        3) echo "Random ID save (x12345.png)" ;;
        4) echo "Overwrite save (x.png)" ;;
        5) echo "Auto-Save Watcher" ;;
        *) echo "Timestamp save" ;;
    esac
}

# ------------------------------------------------------------------------------
# Clipboard Image Operations
# ------------------------------------------------------------------------------
has_clipboard_image() {
    if [[ "$CLIP_BACKEND" == "wayland" ]]; then
        wl-paste --list-types 2>/dev/null | grep -q '^image/'
    elif [[ "$CLIP_BACKEND" == "xclip" ]]; then
        xclip -selection clipboard -t TARGETS -o 2>/dev/null | grep -q 'image/png'
    elif [[ "$CLIP_BACKEND" == "xsel" ]]; then
        return 1
    else
        return 1
    fi
}

get_clipboard_image_hash() {
    if ! has_clipboard_image; then
        return 1
    fi
    if [[ "$CLIP_BACKEND" == "wayland" ]]; then
        wl-paste --type image/png 2>/dev/null | md5sum | awk '{print $1}'
    elif [[ "$CLIP_BACKEND" == "xclip" ]]; then
        xclip -selection clipboard -t image/png -o 2>/dev/null | md5sum | awk '{print $1}'
    fi
}

generate_filename() {
    local target_dir="$1"
    local strategy="$2"
    local ext="$3"
    local clean_ext="${ext#.}"

    case "$strategy" in
        random)
            local rnd
            rnd=$((RANDOM % 90000 + 10000))
            echo "x${rnd}.${clean_ext}"
            ;;
        overwrite)
            echo "x.${clean_ext}"
            ;;
        sequential)
            local idx=1
            local fn
            while true; do
                fn=$(printf "paste_%04d.%s" "$idx" "$clean_ext")
                if [[ ! -f "${target_dir}/${fn}" ]]; then
                    echo "$fn"
                    return
                fi
                idx=$((idx + 1))
            done
            ;;
        *)
            local ts
            ts=$(date +"%Y%m%d_%H%M%S")
            local fn="paste_${ts}.${clean_ext}"
            if [[ -f "${target_dir}/${fn}" ]]; then
                fn="paste_${ts}_$(date +"%N" | cut -c1-3).${clean_ext}"
            fi
            echo "$fn"
            ;;
    esac
}

save_clipboard_image() {
    local target_dir="$1"
    local strategy="${2:-timestamp}"
    local img_format="${3:-png}"
    local quiet="${4:-false}"

    if ! has_clipboard_image; then
        if [[ "$quiet" != "true" ]]; then
            echo -e "${C_YELLOW}[!] No image found in clipboard! Copy an image first.${C_RESET}"
        fi
        return 1
    fi

    mkdir -p "$target_dir"
    local fn
    fn="$(generate_filename "$target_dir" "$strategy" "$img_format")"
    local full_path="${target_dir}/${fn}"

    if [[ "$CLIP_BACKEND" == "wayland" ]]; then
        wl-paste --type image/png > "$full_path" 2>/dev/null
    elif [[ "$CLIP_BACKEND" == "xclip" ]]; then
        xclip -selection clipboard -t image/png -o > "$full_path" 2>/dev/null
    fi

    if [[ ! -s "$full_path" ]]; then
        rm -f "$full_path"
        if [[ "$quiet" != "true" ]]; then
            echo -e "${C_RED}[!] Failed to capture image data.${C_RESET}"
        fi
        return 1
    fi

    local fsize
    fsize="$(du -h "$full_path" | cut -f1)"

    if [[ "$quiet" != "true" ]]; then
        echo -e "${C_GREEN}[+] Successfully saved:${C_RESET}"
        echo -e "    File:  ${C_CYAN}${fn}${C_RESET}"
        echo -e "    Size:  ${C_GRAY}${fsize}${C_RESET}"
        echo -e "    Path:  ${C_GRAY}${full_path}${C_RESET}"
    fi

    # Feedback: bell and optional desktop notification
    if [[ "$CLI_NO_SOUND" != "true" ]]; then
        printf '\a' 2>/dev/null || true
    fi

    if command -v notify-send >/dev/null 2>&1; then
        notify-send -i "$full_path" "paste2save" "Saved ${fn} to ${target_dir}" 2>/dev/null || true
    fi

    echo "$full_path"
}

# ------------------------------------------------------------------------------
# Watcher Mode
# ------------------------------------------------------------------------------
start_watcher() {
    local target_dir="$1"
    local strategy="$2"
    local img_format="$3"
    local poll_sec
    poll_sec="$(awk -v ms="$CLI_POLL_MS" 'BEGIN {print ms/1000}')"

    echo -e "\n${C_CYAN}=======================================================${C_RESET}"
    echo -e "${C_GREEN}       paste2save v3.01 - Auto-Save Watcher Active     ${C_RESET}"
    echo -e "${C_CYAN}=======================================================${C_RESET}"
    echo -e "Backend:     ${C_YELLOW}${CLIP_BACKEND}${C_RESET}"
    echo -e "Destination: ${C_YELLOW}${target_dir}${C_RESET}"
    echo -e "Naming:      ${C_GRAY}${strategy} | Format: ${img_format}${C_RESET}"
    echo -e "\n${C_WHITE}Instructions:${C_RESET}"
    echo -e "  1. Browse any webpage (Firefox, Chrome, Brave, etc.)"
    echo -e "  2. Right-click any image -> 'Copy Image' (or take a screenshot)"
    echo -e "  3. The image is automatically saved without manual steps!"
    echo -e "\n${C_YELLOW}Press Ctrl+C at any time to exit watcher mode.${C_RESET}\n"

    local last_hash=""
    local count=0

    # Capture initial hash if any
    last_hash="$(get_clipboard_image_hash || echo "")"

    while true; do
        sleep "$poll_sec"
        local current_hash
        current_hash="$(get_clipboard_image_hash || echo "")"
        if [[ -n "$current_hash" && "$current_hash" != "$last_hash" ]]; then
            last_hash="$current_hash"
            local saved
            saved="$(save_clipboard_image "$target_dir" "$strategy" "$img_format" "true" || echo "")"
            if [[ -n "$saved" ]]; then
                count=$((count + 1))
                local ts
                ts="$(date +"%H:%M:%S")"
                local base
                base="$(basename "$saved")"
                echo -e "${C_GREEN}[${ts}] [#${count}] Auto-saved: ${base} -> ${saved}${C_RESET}"
            fi
        fi
    done
}

# ------------------------------------------------------------------------------
# Interactive Settings Submenu
# ------------------------------------------------------------------------------
show_settings_menu() {
    while true; do
        clear || true
        local resolved_dest
        resolved_dest="$(resolve_path "$CONF_DEST")"
        local opt_desc
        opt_desc="$(get_option_description "$CONF_DEFAULT_OPT")"

        echo -e "${C_GREEN}=======================================================${C_RESET}"
        echo -e "${C_CYAN}               paste2save v3.01 - Settings             ${C_RESET}"
        echo -e "${C_GREEN}=======================================================${C_RESET}"
        echo -e "${C_WHITE}Current Configuration:${C_RESET}"
        echo -e "  1. Default Action:    ${C_YELLOW}Option [${CONF_DEFAULT_OPT}] - ${opt_desc}${C_RESET}"
        echo -e "  2. Timeout Delay:     ${C_YELLOW}${CONF_DELAY} second(s)${C_RESET}"
        echo -e "  3. Save Destination:  ${C_YELLOW}${CONF_DEST} (${resolved_dest})${C_RESET}"
        echo ""
        echo -e "${C_WHITE}Settings Options:${C_RESET}"
        echo -e "  [1] Change Default Action Option (1 to 5)"
        echo -e "  [2] Change Timeout Delay (0 to 60 seconds)"
        echo -e "  [3] Change Destination Folder"
        echo -e "  [4] Reset All to Factory Defaults"
        echo -e "  [0] Return to Main Menu"
        echo ""
        read -r -p "Select setting to change [0-4]: " set_choice

        case "$set_choice" in
            1)
                echo -e "\n${C_CYAN}Select which option should execute by default:${C_RESET}"
                echo "  [1] Timestamp save (paste_YYYYMMDD_HHMMSS.png)"
                echo "  [2] Sequential save (paste_0001.png)"
                echo "  [3] Random ID save  (x12345.png)"
                echo "  [4] Overwrite save  (x.png)"
                echo "  [5] Auto-Save Watcher (Continuous browser copy)"
                read -r -p "Enter default option number [1-5]: " new_opt
                if [[ "$new_opt" =~ ^[1-5]$ ]]; then
                    CONF_DEFAULT_OPT="$new_opt"
                    save_config
                    echo -e "${C_GREEN}[+] Default action set to Option [${new_opt}].${C_RESET}"
                else
                    echo -e "${C_RED}[!] Invalid choice. Must be 1, 2, 3, 4, or 5.${C_RESET}"
                fi
                sleep 1.2
                ;;
            2)
                echo -e "\n${C_CYAN}Set countdown timeout delay in seconds.${C_RESET}"
                echo -e "${C_GRAY}(0 = run default option immediately; 1-60 = countdown delay)${C_RESET}"
                read -r -p "Enter delay in seconds [0-60]: " new_delay
                if [[ "$new_delay" =~ ^[0-9]+$ ]] && [ "$new_delay" -ge 0 ] && [ "$new_delay" -le 60 ]; then
                    CONF_DELAY="$new_delay"
                    save_config
                    echo -e "${C_GREEN}[+] Timeout delay set to ${CONF_DELAY} second(s).${C_RESET}"
                else
                    echo -e "${C_RED}[!] Invalid input. Must be an integer between 0 and 60.${C_RESET}"
                fi
                sleep 1.2
                ;;
            3)
                echo -e "\n${C_CYAN}Current destination: ${CONF_DEST}${C_RESET}"
                read -r -p "Enter new folder path (e.g. saved_images or ~/Pictures): " new_path
                if [[ -n "${new_path// /}" ]]; then
                    CONF_DEST="$new_path"
                    save_config
                    echo -e "${C_GREEN}[+] Destination folder updated to: ${CONF_DEST}${C_RESET}"
                else
                    echo -e "${C_YELLOW}[!] Path was empty. Destination unchanged.${C_RESET}"
                fi
                sleep 1.2
                ;;
            4)
                CONF_DEST="saved_images"
                CONF_DEFAULT_OPT="1"
                CONF_DELAY=5
                save_config
                echo -e "${C_GREEN}[+] Settings reset to defaults.${C_RESET}"
                sleep 1.2
                ;;
            0)
                return 0
                ;;
            *)
                echo -e "${C_YELLOW}[!] Invalid selection.${C_RESET}"
                sleep 0.8
                ;;
        esac
    done
}

open_folder() {
    local target_dir="$1"
    mkdir -p "$target_dir"
    if command -v xdg-open >/dev/null 2>&1; then
        xdg-open "$target_dir" >/dev/null 2>&1 &
    fi
}

execute_action() {
    local act="$1"
    local target_dir="$2"

    case "$act" in
        1)
            save_clipboard_image "$target_dir" "timestamp" "$CLI_FORMAT"
            ;;
        2)
            save_clipboard_image "$target_dir" "sequential" "$CLI_FORMAT"
            ;;
        3)
            save_clipboard_image "$target_dir" "random" "$CLI_FORMAT"
            ;;
        4)
            save_clipboard_image "$target_dir" "overwrite" "$CLI_FORMAT"
            ;;
        5)
            start_watcher "$target_dir" "timestamp" "$CLI_FORMAT"
            ;;
        6)
            open_folder "$target_dir"
            ;;
        7)
            show_settings_menu
            return 2 # Loop back to main menu
            ;;
        0)
            echo -e "${C_GRAY}Goodbye!${C_RESET}"
            exit 0
            ;;
        *)
            save_clipboard_image "$target_dir" "timestamp" "$CLI_FORMAT"
            ;;
    esac
    return 0
}

# ------------------------------------------------------------------------------
# Parse CLI Options
# ------------------------------------------------------------------------------
HAS_CLI_ARGS=false

while [[ $# -gt 0 ]]; do
    case "$1" in
        -d|--destination)
            CLI_DEST="$2"
            HAS_CLI_ARGS=true
            shift 2
            ;;
        -n|--naming)
            CLI_NAMING="$2"
            HAS_CLI_ARGS=true
            shift 2
            ;;
        -f|--format)
            CLI_FORMAT="$2"
            HAS_CLI_ARGS=true
            shift 2
            ;;
        -w|--watch)
            CLI_WATCH=true
            HAS_CLI_ARGS=true
            shift
            ;;
        -s|--settings)
            CLI_SETTINGS=true
            HAS_CLI_ARGS=true
            shift
            ;;
        --no-sound)
            CLI_NO_SOUND=true
            shift
            ;;
        -o|--open-folder)
            CLI_OPEN_FOLDER=true
            shift
            ;;
        -h|--help)
            echo "paste2save v3.01 (Linux Edition)"
            echo "Usage: ./paste2save.sh [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  -d, --destination PATH   Target directory to save images"
            echo "  -n, --naming STRATEGY    Naming: timestamp (default), sequential, random, overwrite"
            echo "  -f, --format FORMAT      Format: png (default)"
            echo "  -w, --watch              Run continuous Auto-Save Watcher mode"
            echo "  -s, --settings           Open interactive Settings menu directly"
            echo "  -o, --open-folder        Open target folder with xdg-open after saving"
            echo "      --no-sound           Mute audible terminal bell"
            echo "  -h, --help               Display this help text"
            exit 0
            ;;
        *)
            shift
            ;;
    esac
done

detect_clipboard_backend
check_backend_installed
load_config

# Resolve effective target folder
EFFECTIVE_DEST="${CLI_DEST:-$CONF_DEST}"
TARGET_DIR="$(resolve_path "$EFFECTIVE_DEST")"

if [[ "$CLI_SETTINGS" == "true" ]]; then
    show_settings_menu
    exit 0
fi

if [[ "$CLI_WATCH" == "true" ]]; then
    start_watcher "$TARGET_DIR" "$CLI_NAMING" "$CLI_FORMAT"
    exit 0
fi

if [[ "$HAS_CLI_ARGS" == "true" ]]; then
    saved="$(save_clipboard_image "$TARGET_DIR" "$CLI_NAMING" "$CLI_FORMAT")"
    if [[ "$CLI_OPEN_FOLDER" == "true" && -n "$saved" ]]; then
        open_folder "$TARGET_DIR"
    fi
    exit 0
fi

# ------------------------------------------------------------------------------
# Interactive Main Menu
# ------------------------------------------------------------------------------
while true; do
    load_config
    EFFECTIVE_DEST="${CLI_DEST:-$CONF_DEST}"
    TARGET_DIR="$(resolve_path "$EFFECTIVE_DEST")"
    opt_desc="$(get_option_description "$CONF_DEFAULT_OPT")"

    clear || true
    echo -e "${C_GREEN}=======================================================${C_RESET}"
    echo -e "${C_CYAN}           paste2save v3.01 (Linux / ${CLIP_BACKEND})           ${C_RESET}"
    echo -e "${C_GREEN}=======================================================${C_RESET}"
    echo -e "Save folder:    ${C_YELLOW}${TARGET_DIR}${C_RESET}"
    echo -e "Default Action: ${C_GRAY}Option [${CONF_DEFAULT_OPT}] - ${opt_desc}${C_RESET}"
    echo -e "Default Delay:  ${C_GRAY}${CONF_DELAY} second(s)${C_RESET}"
    echo ""
    echo -e "${C_WHITE}Main Menu:${C_RESET}"
    echo -e "  [1] Save clipboard image (Timestamp: paste_YYYYMMDD_HHMMSS.png)"
    echo -e "  [2] Save clipboard image (Sequential: paste_0001.png)"
    echo -e "  [3] Save clipboard image (Random ID:  x12345.png)"
    echo -e "  [4] Save clipboard image (Overwrite:  x.png)"
    echo -e "  [5] ${C_GREEN}Auto-Save Watcher (Copy images from browser & auto-save)${C_RESET}"
    echo -e "  [6] Open destination folder in file manager"
    echo -e "  [7] ${C_YELLOW}Settings (Change default option, timeout delay, & folder)${C_RESET}"
    echo -e "  [0] ${C_GRAY}Exit${C_RESET}"
    echo ""

    user_sel=""
    if [ "$CONF_DELAY" -le 0 ]; then
        echo -e "${C_YELLOW}Timeout delay is 0s. Defaulting immediately to Option [${CONF_DEFAULT_OPT}]...${C_RESET}"
        echo -e "${C_GRAY}(Press any key within 1s to cancel and open menu...)${C_RESET}"
        read -t 1 -n 1 -r user_sel || user_sel="$CONF_DEFAULT_OPT"
    else
        echo -e "${C_YELLOW}Press 1-7 (0 to exit) or wait ${CONF_DELAY}s for default [${CONF_DEFAULT_OPT}]...${C_RESET}"
        if ! read -t "$CONF_DELAY" -n 1 -r user_sel; then
            echo -e "\n${C_CYAN}Defaulting to Option [${CONF_DEFAULT_OPT}] (${opt_desc})...${C_RESET}"
            user_sel="$CONF_DEFAULT_OPT"
        else
            echo ""
        fi
    fi

    [[ -z "$user_sel" ]] && user_sel="$CONF_DEFAULT_OPT"

    if execute_action "$user_sel" "$TARGET_DIR"; then
        break
    fi
    # If execute_action returned 2 (from settings), continue loop
done
