# How to Install Raspberry Pi OS

This guide will walk you through downloading and installing Raspberry Pi OS onto a microSD card.

## Step 1: Download Raspberry Pi OS Image

1. Visit the official Raspberry Pi OS download page:
   - Go to [https://www.raspberrypi.com/software/operating-systems/](https://www.raspberrypi.com/software/operating-systems/)
   - Or search for "raspberry pi os images" and select the raspberrypi.com site

2. Choose the image you want to download:
   - Raspberry Pi OS (recommended for most users)
   - Raspberry Pi OS Lite (no desktop environment)
   - Other specialized versions

## Step 2: Prepare the Image File

If your downloaded image is compressed (has an .xz extension), you'll need to decompress it:

```bash
unxz path/to/image.img.xz
```

This will create a .img file in the same directory.

## Step 3: Write the Image to microSD Card

1. Insert your microSD card into your computer
2. Identify the device path (be very careful to select the correct one):
   - On Linux: typically `/dev/sdX` (where X is a letter)
   - Use `lsblk` or `sudo fdisk -l` to identify the correct device

3. Write the image (replace paths with your actual paths):
```bash
sudo dd if=path/to/image.img of=/dev/sdX bs=4M status=progress conv=fsync
```

4. Wait for the process to complete - this may take several minutes

5. Sync to ensure all writes are completed:
```bash
sync
```

## Step 4: Set Up Your Raspberry Pi

1. Safely eject the microSD card from your computer
2. Insert it into your Raspberry Pi
3. Connect peripherals (keyboard, mouse, display) and power supply
4. Follow the initial setup instructions on first boot

---

# Directory Contents

This repository contains the following setup and configuration guides:

| File | Description |
|------|-------------|
| [clear memory usage in cache with crontab](clearMemoryUsageInCacheWithCrontab.md) | Setup automated memory cache clearing with crontab |
| [make greeting message on SSH login boot](makeGreetingMsgOnSSHLoginBoot.md) | Configure system information display on SSH login |
| [make system info script/command](makeSystemInfoScript.md) | Create a script for showing system information on demand |
| [set up SSH remotely without password](setUpSSHRemotelyWithoutPassword.md) | Configure SSH with key-based authentication |
| [set up timeshift on CLI OS](setUpTimeshiftOnCLIOS.md) | Set up Timeshift backup system for Raspberry Pi |
| [set up VPN with openVPN](setUpVPNWithOpenVPN.md) | Complete guide to setting up an OpenVPN server |
| [Installing Minecraft on PiOS Desktop](installingMinecraft.md) | Guide to install Minecraft on Raspberry Pi OS Desktop 64-bit |

