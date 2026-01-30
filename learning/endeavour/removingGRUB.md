---
slug: "removing-grub"
title: "Removing GRUB"
description: "Guide to how to remove GRUB on boot without bricking your OS."
tags: ["endeavour", "linux"]
date: 2025-09-25
---

## Removing GRUB on Boot

This guide **does not** remove the GRUB package, its files, or touch anything that could brick your system through deletion. Instead, this will help you **create a new boot entry** that boots directly, cleanly — without GRUB and without all the annoying text logs.

Just like resizing partitions, messing with EFI entries and bootloaders **can** break things.

That said — I personally followed all of these steps and had **zero issues**. My system booted clean, without GRUB, and straight into EndeavourOS.

If something does go wrong (e.g. black screen, no boot), you’ll likely have to:

- Boot from a live USB
- Reinstall GRUB or systemd-boot
- Tweak the EFI entries manually
  Proceed carefully, and **always back things up**.

Let’s get into it.

## Create a New Boot Entry

1. Install the systemd-boot setup:

```bash
sudo bootctl install
```

This will create the necessary directories and files for a new boot entry. **Pay attention** to the output — you’ll need to know where these files live.

Example output:

```
Created "/boot/efi/EFI/systemd".
Created "/boot/efi/loader".
Created "/boot/efi/loader/keys".
Created "/boot/efi/loader/entries".
Created "/boot/efi/EFI/Linux".
Copied "/usr/lib/systemd/boot/efi/systemd-bootx64.efi" to "/boot/efi/EFI/systemd/systemd-bootx64.efi".
Copied "/usr/lib/systemd/boot/efi/systemd-bootx64.efi" to "/boot/efi/EFI/BOOT/BOOTX64.EFI".
Random seed file /boot/efi/loader/random-seed successfully written (32 bytes).
Successfully initialized system token in EFI variable with 32 bytes.
Created EFI boot entry "Linux Boot Manager".
```

Since `bootctl install` created the boot structure in `/boot/efi/`, we need to copy the necessary files there for systemd-boot to work properly.

2. Check Kernel and Initramfs files

These files usually live in the `/boot/` directory. Check it:

```bash
sudo ls -l /boot/
```

You should see something like:

```
drwxr-x--- 5 root root - Dec 31  1969 efi
drwxr-xr-x 6 root root - Jun  4 14:10 grub
-rw------- 1 root root - Jun  6 13:57 initramfs-linux-fallback.img
-rw------- 1 root root - Jun  6 13:57 initramfs-linux.img
-rw------- 1 root root - Jun  6 13:56 initramfs-linux-lts-fallback.img
-rw------- 1 root root - Jun  6 13:56 initramfs-linux-lts.img
-rw-r--r-- 1 root root - Jun  6 13:56 vmlinuz-linux
-rw-r--r-- 1 root root - Jun  6 13:56 vmlinuz-linux-lts
```

3. Copy the Kernel and Initramfs

```bash
sudo cp /boot/vmlinuz-linux /boot/efi/
sudo cp /boot/initramfs-linux.img /boot/efi/
sudo cp /boot/initramfs-linux-fallback.img /boot/efi/
```

4. Create a boot entry file:

```bash
sudo nano /boot/efi/loader/entries/endeavouros.conf
```

Paste this into the file:

```
title   EndeavourOS
linux   /vmlinuz-linux
initrd  /initramfs-linux.img
initrd  /initramfs-linux-fallback.img
options root=UUID=<your-root-partition-uuid> rw loglevel=3 nowatchdog
```

> Replace `<your-root-partition-uuid>` with your actual root partition UUID. To get it:
>
> ```bash
> lsblk -f
> ```

## Create a Pacman Hook to Auto-Copy on Kernel Updates

As you notice our new Entry live on `/boot/efi/` but the system manages it from `/boot/` so our new entry will always be out of sync because is not auto-updated by the system, we need a **Pacman hook** to keep them in sync.

1. Create a hook:

```bash
sudo mkdir -p /etc/pacman.d/hooks
sudo nano /etc/pacman.d/hooks/90-systemd-boot-copy.hook
```

2. Paste this in:

```
[Trigger]
Type = Package
Operation = Install
Operation = Upgrade
Operation = Remove
Target = dracut
Target = linux
Target = linux-lts
Target = amd-ucode
Target = intel-ucode
Target = systemd

[Trigger]
Type = Path
Operation = Install
Operation = Upgrade
Target = usr/lib/modules/*/vmlinuz
Target = usr/lib/dracut/*
Target = usr/lib/firmware/*
Target = usr/src/*/dkms.conf

[Action]
Description = Copy kernel and initramfs to EFI system partition entry...
When = PostTransaction
Exec = /usr/bin/bash -c 'cp -v /boot/vmlinuz-linux /boot/initramfs-linux*.img /boot/efi/'
```

This will ensure you’re always booting from the **latest kernel and initramfs**.

> [!WARNING]
> This hook assumes you're using the **default kernel packages** (`linux`, `linux-lts`) provided by Arch/EndeavourOS.
> If you're using a **custom kernel** like `linux-zen`, `linux-hardened`, or `linux-xanmod`, you'll need to **add those to the hook** with additional `Target =` lines. Otherwise, the hook won’t run when those kernels are updated, and your EFI files could become out of sync.
> You can check your installed kernels with:
>
> ```bash
> pacman -Q | grep linux
> ```

## Making an Splash Animation (Optional)

To get a good-looking boot animation, I recommend installing **Plymouth**:

```bash
sudo pacman -S plymouth
```

> [!WARNING]
> Arch-based systems like EndeavourOS support two initramfs generators: `mkinitcpio` and `dracut`. This guide assumes you're using the latest EndeavourOS, which defaults to `dracut`. **If you're still using `mkinitcpio`, skip this section**. This method is a minimal setup specifically for dracut users.

Normally, configuring Plymouth with dracut requires creating a config file that manually adds the `plymouth` module. But in recent versions, simply installing the `plymouth` package automatically enables the module in dracut. We’ll take advantage of that and regenerate the initramfs directly.

> [!TIP]
> If you're a KDE user like me, I recommend installing these extra tools for better integration:
>
> - `breeze-plymouth` – a splash theme that matches KDE's style
> - `plymouth-kcm` – a GUI tool to manage Plymouth themes
>
> ```bash
> sudo pacman -S breeze-plymouth plymouth-kcm
> ```

### Edit the systemd-boot Entry

1. Open your bootloader entry file:

```bash
sudo nano /boot/efi/loader/entries/endeavouros.conf
```

2. Edit or add the `options` line to include `quiet splash` for a cleaner boot:

```ini
efi /EFI/Linux/endeavouros.efi
options root=UUID=... rw quiet splash loglevel=3 nowatchdog
```

3. Regenerate Initramfs (via Dracut)

Now, simply reinstall `dracut` to trigger the regeneration of the initramfs and let the hook copy it to the EFI partition:

```bash
sudo pacman -S dracut
```

Look for this in the output:

```
(5/6) Copy kernel and initramfs to EFI system partition...
'/boot/vmlinuz-linux' -> '/boot/efi/vmlinuz-linux'
'/boot/initramfs-linux.img' -> '/boot/efi/initramfs-linux.img'
'/boot/initramfs-linux-fallback.img' -> '/boot/efi/initramfs-linux-fallback.img'
...
```

4. Confirm new settings:

```bash
bootctl list
```

## Remove or Reorder Unwanted Boot Entries

List your current boot entries:

```bash
sudo efibootmgr
```

You’ll see something like:

```
BootCurrent: 0000
Timeout: 0 seconds
BootOrder: 0000,0001,0002
Boot0000* Linux Boot Manager
Boot0001* Windows Boot Manager
Boot0002* endeavouros
```

To **remove** an entry:

```bash
sudo efibootmgr -b 0001 -B
```

Repeat for any entries you don’t want.

> [!NOTE]
> In my case:
>
> - `Boot0000` is the new systemd boot entry (✅ keep)
> - `Boot0001` was a leftover Windows entry (❌ removed)
> - `Boot0002` is the EndeavourOS GRUB entry (✅ keep)

If you **don’t want to delete** GRUB, you can just reorder boot priorities:

```bash
sudo efibootmgr -o 0000
```

### Clean Up the EFI Directory

Check what’s there:

```bash
sudo ls /boot/efi/EFI/
```

Expected output:

```
Boot/
Linux/
Microsoft/
systemd/
endeavouros/
```

To remove Windows leftovers:

```bash
sudo rm -r /boot/efi/EFI/Microsoft
```

> [!WARNING]
> You could also delete the GRUB folder here (`endeavouros/`), but I **don’t recommend** doing this unless you’re 100% sure.
> If something breaks, you may need to boot from live USB and fix it manually. Do your research.

## Done!

On your next reboot, you should boot straight into **EndeavourOS** — no GRUB, no boot menu, no verbose text logs. Just clean and simple.
