# Kubuntu 24.04 LTS "Workhorse" Setup Guide

This document records the complete configuration of a stable, professional Linux environment on a Geekom A5 (AMD Ryzen Mini PC), optimized for developers and creative professionals.

## 1. Initial Installation Details

* **Version**: Kubuntu 24.04.3 LTS (Noble Numbat).
* **Mode**: Minimal Installation (Clean, no bloat).
* **Keyboard Layout**: English (US, Macintosh).
* **Mirrors**: Updated to `https://mirrors.edge.kernel.org/ubuntu` for fast, reliable package downloads.

## 2. Hardware & Connectivity (The "Stable Wi-Fi" Fix)

### GUI Settings

1. Go to **System Settings** -> **Connections**.
2. Select your Wi-Fi network:
   * **IPv6 Tab**: Set Method to **Disabled**.
   * **Wi-Fi Tab**: Set **BSSID** to lock to your specific router access point.
   * **Wi-Fi Tab**: Check **Restrict to device** to bind the connection to your Wi-Fi card.

### Terminal Optimization

Force the network card to ignore 2.4GHz interference and use 5GHz exclusively:

```bash
nmcli connection modify "Your_WiFi_Name" 802-11-wireless.band a
nmcli connection up "Your_WiFi_Name"
```

### Permanent IPv6 Purge (Kernel Level)

To ensure IPv6 never "wakes up," apply these settings:

1. Create `/etc/sysctl.d/99-disable-ipv6.conf` with:

```text
net.ipv6.conf.all.disable_ipv6 = 1
net.ipv6.conf.default.disable_ipv6 = 1
net.ipv6.conf.lo.disable_ipv6 = 1
```

2. Apply with: `sudo sysctl -p /etc/sysctl.d/99-disable-ipv6.conf`
3. Edit `/etc/default/grub` and add `ipv6.disable=1` and `pcie_aspm=off` to the `GRUB_CMDLINE_LINUX_DEFAULT` line.
   Example: `GRUB_CMDLINE_LINUX_DEFAULT='quiet splash ipv6.disable=1 pcie_aspm=off'`
4. Finalize with: `sudo update-grub`
5. **Restart for changes to take effect.** `sudo reboot`

## 3. Desktop & Input Customization (Mac Style)

### Keyboard Mapping

* **Input Remapper**: Swapped `Grave` and `Section` buttons to match the physical MacBook keyboard.

### Login Screen (SDDM) & NumLock

1. **NumLock**: In **System Settings** -> **Input Devices** -> **Keyboard**, set NumLock to **"Turn On"** on startup.
2. **Persistence**: Go to **Colors & Themes** -> **Login Screen (SDDM)** and click **Apply Plasma Settings...**. This ensures your keyboard layout and NumLock state work at the login screen.
3. **Restart for changes to take effect.**

## 4. Performance Tuning (Ryzen & 32GB RAM)

### Swappiness Tuning
With 32GB of RAM, you want the system to avoid using the slow SSD swap as much as possible.

```bash
# Set swappiness to 10 (default is 60)
sudo sysctl vm.swappiness=10
# Make it permanent
echo 'vm.swappiness=10' | sudo tee -a /etc/sysctl.conf
```

### Feral GameMode
Essential for Godot and Blender to ensure the CPU stays in high-performance mode during heavy tasks.

```bash
sudo apt install gamemode
# To use: launch apps with 'gamemoderun' or add to launch options
```

## 5. Professional Software Suite

### Browsers (Native .deb) & Hardware Acceleration

Installed via terminal to ensure high performance. To ensure smooth video playback and 3D performance in browsers, the Mesa drivers and GPU acceleration platform must be present.

```bash
# Install Browsers
sudo apt install ./google-chrome-stable_current_amd64.deb

# Ensure GPU Acceleration (Mesa/VA-API drivers)
sudo apt install mesa-va-drivers libva-drm2 libva-x11-2
```

### Git Configuration

To fix the "Please tell me who you are" error when committing code:

```bash
sudo dnf install git

# Set your identity globally
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"

# Verify settings
git config --list
```

### Creative & Dev Tools (Flatpak)

Installed via Flatpak to get the absolute latest stable versions (e.g., Blender 5.0).

```bash
# Setup
sudo apt install flatpak
flatpak remote-add --if-not-exists flathub [https://dl.flathub.org/repo/flathub.flatpakrepo](https://dl.flathub.org/repo/flathub.flatpakrepo)

# App Installation
flatpak install flathub org.blender.Blender      # v5.0
flatpak install flathub org.kde.krita            # Latest
flatpak install flathub com.google.AndroidStudio # Latest
flatpak install flathub org.godotengine.Godot    # v4.5.1
flatpak install flathub com.github.tchx84.Flatseal

# Essential GPU Driver for Flatpaks (Option 6 in prompt)
flatpak install flathub org.freedesktop.Platform.GL.default//24.08
```

**Restart for changes to take effect.**

### Permission Fix (Removing the Sandbox Wall)

To allow these apps to see your project files without "Permission Denied" errors:

```bash
sudo flatpak override --filesystem=home
```

## 6. Maintenance & Updates

Run this weekly to keep the system, browsers, and creative tools current:

```bash
sudo apt update && sudo apt upgrade -y && flatpak update -y && flatpak uninstall --unused -y
```

## ✅ Post-Setup Checklist & Restarts

* [ ] **TODO 1**: After Wi-Fi/GRUB changes — **RESTART** (to kill IPv6 and lock 5GHz).
* [ ] **TODO 2**: After Flatpak installation — **RESTART** (to make application icons appear in the menu).
* [ ] **TODO 3**: After SDDM configuration — **RESTART** (to test Numpad Enter on login).

## 7. Disable Wi-Fi Power Management (Most Likely Fix)
This is the most common resolution for Wi-Fi cards disappearing during streaming.

1. Open your terminal (Ctrl+Alt+T).

2. Open the configuration file: sudo nano /etc/NetworkManager/conf.d/default-wifi-powersave-on.conf

3. Change the value from wifi.powersave = 3 to wifi.powersave = 2.

4. Save and exit (Ctrl+O, Enter, Ctrl+X), then restart your network: sudo systemctl restart NetworkManager

## 8. DON'T INSTALL SPOTIFY

- Use the web player
- deb, snap, flatpak packages causes network issues

## 9. Apply RTW89 Driver Tweaks
The 8852BE uses the rtw89 driver. You can disable certain PCIe power-saving features (ASPM) that often interfere with Realtek cards on Linux. 
- Create a driver config file:
   ```
   sudo nano /etc/modprobe.d/rtw89.conf
   ```
- Paste these options:
   ```
   options rtw89_pci disable_aspm_l1=y disable_aspm_l1ss=y
   options rtw89_core disable_ps_mode=y
   ```
   _(Note: disable_ps_mode=y is a second layer of power-save disabling at the driver core level)_
- Save (Ctrl+O, Enter) and Exit (Ctrl+X).
- Reboot your system to apply these hardware-level changes.

## 10. Set the Correct Regulatory Domain
Linux sometimes restricts Wi-Fi power or available channels if it doesn't know your country's regulations. Setting this can occasionally "unblock" higher transmit power. 
- Check current domain: `iw reg get`
- Set it manually: `sudo iw reg set US` (Replace US with your ISO 3166-1 alpha-2 country code).

## 11. Changing Band Preference
Your nmcli command is partially correct. Setting it to a tells NetworkManager to prefer the 5GHz band. However, if your router uses the same name (SSID) for both 2.4GHz and 5GHz, the card might still drift back to 2.4GHz if the signal is "stronger" (even if it's slower).  

To make it more robust, use these three commands (replace `Your_WiFi_Name` with your actual connection name):

- Prefer 5GHz: `sudo nmcli connection modify "Your_WiFi_Name" 802-11-wireless.band a`
- Ensure it stays on 5GHz: (Optional) If you want to force it and never use 2.4GHz for this specific network, run:
  
  `sudo nmcli connection modify "Your_WiFi_Name" 802-11-wireless.band a`
- Apply: `sudo nmcli connection up "Your_WiFi_Name"`

## 12. Checking Firmware
You are right to check before updating. On Fedora, "firmware" for Wi-Fi cards comes in the `linux-firmware` package. 

- Check the installed package version:
`rpm -q linux-firmware`
- Check what the card is actually using right now:
`dmesg | grep rtw89`  
Look for a line that says `loaded firmware rtw89/rtw8852b_fw-1.bin` and a corresponding Firmware version number (e.g., `0.29.x.x`).
- Check for available updates:
`sudo dnf check-update linux-firmware`  
If it returns nothing, you are already on the latest version provided by Fedora for your release. 

## Final Verification
To see if your signal strength is actually improving in real-time, run:

`watch -n 1 "nmcli dev wifi list | grep '*'"`

This will show you the BARS, SIGNAL (higher is better), and RATE (speed) every second.