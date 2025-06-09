# Having EndeavourOS as the Only OS on Your Machine

## 1. Removing Windows

To remove Windows, first install **GParted**:

```bash
sudo pacman -S gparted
```

Then, open GParted:

```bash
sudo gparted
```

Here’s what to do:

1. Locate all your **EndeavourOS partitions** — the ones you **should not touch**. These usually include:

   * `/` (root)
   * `efi/`
   * Any other partitions you’ve set up, like `/home`, `/swap`, `/tmp`

2. After identifying those, find the **Windows partitions** and **delete them**:

   * Right-click the Windows partition → `Delete`
   * You’ll now see **unallocated space**.
   * Confirm everything looks correct, then click the **check mark** (✓) at the top to apply the changes.

## 2. Expanding Your EndeavourOS Partition

Now that you’ve got unallocated space, you probably want to **expand your EndeavourOS partition** (e.g. `/`, `/home`) to use that space.

* Right-click the partition you want to expand → `Resize/Move`
* A window will pop up. **Slide** the edge to increase the partition size or manually enter the new size.

> [!NOTE]
> If the Unallocated Space Is on the Left
> GParted **can’t move partitions to the left** if they’re mounted. That means if the unallocated space is on the **left**, and you want to grow your `/` partition into it, you'll need to use a **live boot environment** where the system partition isn’t mounted.

## 3. Resizing the Partition in a Live Boot

> [!CAUTION]
> Note on Boot Issues.
> This action **could** mess up your boot loader. I personally did all of these steps and my system booted fine afterward. But just so you know — this is not guaranteed, so in case anything breaks, you’ll have to search for solutions online. (I don’t have a fix for that kind of issue at the moment.)

### a. Create a Boot Stick

1. Download the EndeavourOS ISO from the [official website](https://endeavouros.com/).
2. Insert your flash drive.
3. Create the boot stick with:

```bash
sudo dd if=EndeavourOS.iso of=/dev/sdX bs=4M status=progress && sync
```

> [!WARNING]
> Replace `/dev/sdX` with the **correct disk** (not a partition like `/dev/sdX1`). **⚠️ This will wipe everything on the flash drive, so back it up first.**

### b. Use GParted from the Live Boot

1. Boot into the flash drive.
2. Open a terminal and install GParted (if not already there):

```bash
sudo pacman -S gparted
```

3. Launch GParted:

```bash
sudo gparted
```

4. Now do the same process:

   * Right-click your EndeavourOS partition → `Resize/Move`
   * This time, you’ll be able to **move/slide the partition to the left**, because it’s not mounted.
   * Resize it to take up the unallocated space.

5. Click the **check mark** to apply the changes. A **warning** will pop up — **read it carefully.**

## Done!

You now have the **best OS ever** as your main and only system. Goodbye Windows, hello power and freedom.

---

# Removing GRUB on Boot

Now that you only have **EndeavourOS**, GRUB might feel useless. If you want to **boot directly into EndeavourOS**, follow these steps.

But first, **let me be clear**:
This guide **does not** remove the GRUB package, its files, or touch anything that could brick your system through deletion.
Instead, this will help you **create a new boot entry** that boots directly, cleanly — without GRUB and without all the annoying text logs.

Let’s get into it.

> [!CAUTION]
> Note on Boot Issues
> Just like resizing partitions, messing with EFI entries and bootloaders **can** break things.
> That said — I personally followed all of these steps and had **zero issues**. My system booted clean, without GRUB, and straight into EndeavourOS.
> If something does go wrong (e.g. black screen, no boot), you’ll likely have to:
> * Boot from a live USB
> * Reinstall GRUB or systemd-boot
> * Tweak the EFI entries manually
> So proceed carefully, and **always back things up**.

## 1. Create the New Boot Entry

First, install the systemd-boot setup:

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

## 2. Check Kernel and Initramfs Paths

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

## 3. Create the `endeavouros.conf` Entry

Since `bootctl install` created the boot structure in `/boot/efi/`, we need to copy the files there:

```bash
sudo cp /boot/vmlinuz-linux /boot/efi/
sudo cp /boot/initramfs-linux.img /boot/efi/
sudo cp /boot/initramfs-linux-fallback.img /boot/efi/
```

Now create your boot entry file:

```bash
sudo nano /boot/efi/loader/entries/endeavouros.conf
```

Paste this into the file:

```
title   EndeavourOS
linux   /vmlinuz-linux
initrd  /initramfs-linux.img
options root=UUID=<your-root-partition-uuid> rw quiet splash loglevel=3 nowatchdog
```

Replace `<your-root-partition-uuid>` with your actual root partition UUID. To get it:

```bash
lsblk -f
```

### a. Create a Pacman Hook to Auto-Copy on Kernel Updates

> [!NOTE]
> Since the copied files in `/boot/efi/` are **not** auto-updated by the system, we need a **Pacman hook** to keep them in sync.

Create the hook:

```bash
sudo mkdir -p /etc/pacman.d/hooks
sudo nano /etc/pacman.d/hooks/90-systemd-boot-copy.hook
```

Paste this in:

```
[Trigger]
Type = Path
Path = /boot/vmlinuz-linux
Path = /boot/initramfs-linux.img
Path = /boot/initramfs-linux-fallback.img
Operation = Install
Operation = Upgrade

[Action]
Description = Copy kernel and initramfs to EFI system partition...
When = PostTransaction
Exec = /usr/bin/bash -c 'cp /boot/vmlinuz-linux /boot/initramfs-linux*.img /boot/efi/'
```

This will ensure you’re always booting from the **latest kernel and initramfs**.

## 4. Remove or Reorder Unwanted Boot Entries

To list your current boot entries:

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
> * `Boot0000` is the new systemd boot entry (✅ keep)
> * `Boot0001` was a leftover Windows entry (❌ removed)
> * `Boot0002` was the EndeavourOS GRUB entry (✅ keep)

If you **don’t want to delete** GRUB, you can just reorder boot priorities:

```bash
sudo efibootmgr -o 0000
```

## 5. Clean Up the EFI Directory

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

On your next reboot, you should boot straight into **EndeavourOS** —
no GRUB, no boot menu, no verbose text logs. Just clean and simple.
