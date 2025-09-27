# TP-Link M7350 V9 – Rayhunter + Tailscale + Telegram

> 📡 This setup guide applies specifically to the TP-Link M7350 V9 running BusyBox-based firmware with Tailscale and Rayhunter installed.

---

### 📌 Device Specs

- **Device:** TP-Link M7350 V9
- **Firmware Version:** 9.0.3 Build 241219 Rel.1089n
- **Rayhunter Version:** 0.7.0
- **CPU:** ARMv7l (Qualcomm MDM9607)  
- **OS:** BusyBox/Linux-based embedded firmware  
- **Tailscale:** [arm: tailscale_1.88.3_arm.tgz](https://pkgs.tailscale.com/stable/tailscale_1.88.3_arm.tgz)


---


### 📥 Rayhunter Installation

Follow the official instructions to install Rayhunter:

🔗 [Rayhunter GitHub Repository](https://github.com/EFForg/rayhunter)  
📖 [Installation Guide](https://efforg.github.io/rayhunter/installation.html)

---

### 🛠️ Installing Tailscale on SD Card + Auto-Startup on Qualcomm MDM9607 Device
#### 📁 SD Card Layout

Create the following structure on your SD card (e.g., mounted under /media/sdcard/):

<img width="1117" height="313" alt="image" src="https://github.com/user-attachments/assets/3503efe5-a174-4b32-835b-12146cc33999" />

---

### ⚙️ Step 1: Download Tailscale Binaries

Download the Tailscale static binaries: [arm: tailscale_1.88.3_arm.tgz](https://pkgs.tailscale.com/stable/tailscale_1.88.3_arm.tgz)

Extract and copy them to `/media/sdcard/Tail/`.

<img width="1100" height="200" alt="image" src="https://github.com/user-attachments/assets/5c7c99ff-4a69-4700-a002-cc8324a2f047" />

Make sure they are executable:

```chmod +x /media/sdcard/Tail/tailscaled /media/sdcard/Tail/tailscale```

---

### ⚙️ Step 2: Create the Boot Script

Save [this script](https://github.com/MHSEA/TP-Link-M7350-V9_Rayhunter-Tailscale-Telegram/blob/main/tailscale-boot.sh) as /media/sdcard/scripts/tailscale-boot.sh and make it executable:

```chmod +x /media/sdcard/scripts/tailscale-boot.sh```

- ✅ The script handles:

  - Logging to /media/sdcard/scripts/tailscale-boot.log
  - Waiting for mobile data connection (4G) before launching
  - Starting tailscaled with a fixed state directory
  - Enabling NAT routing
  - Sending boot status to Telegram with HTML formatting

🔐 Configuration Notes

- Before using the script, make sure to:
  - Replace BOT_TOKEN with your Telegram Bot Token
  - Replace CHAT_ID with your Telegram user or group ID
  - Replace --authkey with your Tailscale Auth Key (Required for authenticating the device without an interactive login.)

- Useful guides:
  - 📖 [Create Telegram Bot](https://core.telegram.org/bots#how-do-i-create-a-bot)
  - 🔎 Find Telegram Chat ID (Your User ID) > start a conversation with [this bot](https://t.me/mhxgptbot), from menu select Account or type /acc and copy your Telegram User ID from the top. 🛡️ [ Account ] - [ xxxxxxxxxx ] 🛡️
  - 🔑 [Create Tailscale Auth Key](https://tailscale.com/kb/1085/auth-keys)

---

### ⚙️ Step 3: Enable Auto-Start via /etc/init.d/usb

On this device, the ```/etc/init.d/usb``` script is invoked towards the end of the boot process.

To ensure Tailscale starts cleanly only during boot, you should add the following block ``` sh /media/sdcard/scripts/tailscale-boot.sh & ``` inside the ```start)``` case of ```/etc/init.d/usb```:

<img width="1194" height="532" alt="image" src="https://github.com/user-attachments/assets/e090f03f-4e55-4812-8191-4f0b6f6d65b1" />


- ✅ This ensures:

  - Your Tailscale boot script only runs when the system is booting.
  - It does not run during manual stop/restart of USB services or during shutdown.

---

### ✅ Step 4: Reboot & Confirm

After rebooting, you should see:

- A log file at ```/media/sdcard/scripts/tailscale-boot.log```
- Your Tailscale daemon running in background
- Telegram alerts if configured (including boot status, IP, uptime, etc.)

<img width="622" height="372" alt="image" src="https://github.com/user-attachments/assets/f3192f91-0145-4b6a-8ad1-cb636ba20b0a" />
