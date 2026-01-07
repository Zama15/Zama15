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

Since `bootctl install` created the boot structure in `/boot/efi/`, we need to copy the necessary files there for systemd-boot to work properly:

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
initrd  /initramfs-linux-fallback.img
options root=UUID=<your-root-partition-uuid> rw loglevel=3 nowatchdog
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
Description = Copy kernel and initramfs to EFI system partition...
When = PostTransaction
Exec = /usr/bin/bash -c 'cp -v /boot/vmlinuz-linux /boot/initramfs-linux*.img /boot/efi/'
```

This will ensure you’re always booting from the **latest kernel and initramfs**.

> [!WARNING]
> This hook assumes you're using the **default kernel packages** (`linux`, `linux-lts`) provided by Arch/EndeavourOS.
> If you're using a **custom kernel** like `linux-zen`, `linux-hardened`, or `linux-xanmod`, you'll need to **add those to the hook** with additional `Target =` lines. Otherwise, the hook won’t run when those kernels are updated, and your EFI files could become out of sync.
> You can check your installed kernels with:
> ```bash
> pacman -Q | grep linux
> ```

### b. Splash Animation (Optional)

To get a good-looking boot animation, I recommend installing **Plymouth** with this command:

```bash
sudo pacman -S plymouth
```

> [!WARNING]
> Arch-based systems like EndeavourOS support two initramfs generators: `mkinitcpio` and `dracut`. This guide assumes you're using the latest EndeavourOS, which defaults to `dracut`. If you're still using `mkinitcpio`, skip this section. This method is a minimal setup specifically for dracut users.

Normally, configuring Plymouth with dracut requires creating a config file that manually adds the `plymouth` module. But in recent versions, simply installing the `plymouth` package automatically enables the module in dracut. We’ll take advantage of that and regenerate the initramfs directly.

> [!TIP]
> If you're a KDE user like me, I recommend installing these extra tools for better integration:
> * `breeze-plymouth` – a splash theme that matches KDE's style
> * `plymouth-kcm` – a GUI tool to manage Plymouth themes
> ```bash
> sudo pacman -S breeze-plymouth plymouth-kcm
> ```

#### I. Edit the systemd-boot Entry

Open your bootloader entry file:

```bash
sudo nano /boot/efi/loader/entries/endeavouros.conf
```

Edit or add the `options` line to include `quiet splash` for a cleaner boot:

```ini
efi /EFI/Linux/endeavouros.efi
options root=UUID=... rw quiet splash loglevel=3 nowatchdog
```

#### II. Regenerate Initramfs (via Dracut)

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

This confirms that the initramfs was regenerated and copied successfully, with Plymouth now included.

To verify everything is in place, run:

```bash
bootctl list
```

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

---

# Adding Virtual RAM on Low Resources Laptop

## 1. ZRAM

Compresses and decompresses memory in real time. Here it's used more like RAM, effectively getting virtual RAM from physical drives.

> \[!WARNING]
>
> * Because of the compress/decompress process, CPU load may increase, especially during heavy multitasking.
> * On a low-end or thermally throttled CPU, this could cause performance dips.

### Setting up ZRAM

#### a. Install

```bash
sudo pacman -S zram-generator
```

#### b. Create Config File

Create the following file to configure ZRAM:

```bash
sudo nano /etc/systemd/zram-generator.conf
```

Add these lines to the file:

```
[zram0]
zram-size = min(min(ram, 4096) + max(ram - 4096, 0) / 2, 32 * 1024)
compression-algorithm = zstd
```

> \[!NOTE]
> This will create a "linear size 1:1 for the first 4G, then 1:2 above, up to a max of 32GB."
> If you want a specific, unchanging amount of ZRAM, replace the formula with a simple value in megabytes. For example, to set it to 2GB (2048 MB):
>
> ```ini
> [zram0]
> zram-size = 2048 
> compression-algorithm = zstd
> ```
>
> More examples and tweaks [here](https://man.archlinux.org/man/zram-generator.conf.5)

#### c. Reload service and start ZRAM generator

Reload systemd daemons to apply the new config:

```bash
sudo systemctl daemon-reload
```

Start the ZRAM service:

```bash
sudo systemctl start systemd-zram-setup@zram0
```

> \[!NOTE]
> `@zram0` refers to the first ZRAM device (`/dev/zram0`). You can configure multiple devices (zram1, zram2…) but usually only one is needed.
>
> It's not necessary to enable the service because the generator dynamically creates the unit at boot time based on the config file.

### Editing ZRAM

To change the amount of ZRAM, edit the configuration file created.

Open the config file:

```bash
sudo nano /etc/systemd/zram-generator.conf
```

Modify the size:

```ini
[zram0]
zram-size = 4096
compression-algorithm = zstd
```

To apply the changes the easiest and most reliable way to apply the new configuration is to simply **rebooting**.

```bash
reboot
```

> [!NOTE]
> If you want to apply it without rebooting, you can run:
>
> ```bash
> sudo systemctl daemon-reload
> sudo systemctl restart systemd-zram-setup@zram0
> ```

To verify the new size with the `zramctl` command:
```bash
zramctl
```

This will show you the `DISKSIZE` of your `/dev/zram0` device.

## 2. SWAP

This will be used when the RAM overflows to the point where it would crash. It effectively works as a fallback, making it reliable for low-RAM machines during multitasking or heavy app usage. Here it's set up with the idea that [ZRAM](#zram) won’t be enough on its own.

> \[!WARNING]
>
> * Swap on an SSD adds write cycles, which can reduce SSD lifespan over years of intense use.
> * Although, if only using 2–4GB occasionally, it’s a minimal risk.

### On Ext4
#### a.1 Create a 4GB swapfile (change size as needed)

```bash
sudo fallocate -l 4G /swapfile
```

This command **reserves 4GB of space** on your disk and creates a file named `/swapfile`.
You can change `4G` to any value depending on how much fallback swap you want.

#### a.2 Secure the file

```bash
sudo chmod 600 /swapfile
```

This sets permissions to **owner read/write only**, preventing other users or processes from accessing it — important for security and system stability.

#### a.3 Format it as swap

```bash
sudo mkswap /swapfile
```

This command **initializes the file** as swap space so the system can recognize and use it as additional memory.

#### a.4 Enable it

```bash
sudo swapon /swapfile
```

This tells the kernel to **start using the swapfile immediately**, without needing a reboot.

You can verify it’s active with:

```bash
free -h
```

Look under the `Swap:` line — it should now show 4GB (or whatever size you picked).

#### a.5 Make it permanent

Open `/etc/fstab`:

```bash
sudo nano /etc/fstab
```

Add this line to the bottom of the file:

```
/swapfile none swap defaults,pri=-10 0 0
```

This tells the system to **mount the swapfile automatically at every boot**, so you don’t have to enable it manually each time.


### b.1 Editing Swap File Size

Changing a swap file is a bit more involved because it can't be modify it while it's used. So it have to be disabled, removed, and created again.

Let's say you want to change your swap from 4GB to 2GB.


Turn off the current swap file

```bash
sudo swapoff /swapfile
```

Remove the old file:

```bash
sudo rm /swapfile
```

Create the new swap file. In this example, we'll create a 2GB file.

```bash
sudo fallocate -l 2G /swapfile
```

Re-apply the correct permissions and format:

```bash
sudo chmod 600 /swapfile
sudo mkswap /swapfile
```

Turn the new swap file on:

```bash
sudo swapon /swapfile
```

Verify the new size checking the output of `free -h`. The `Swap:` line should now show `2.0G`.

```bash
free -h
```

> [!NOTE]
> You **do not need to edit `/etc/fstab` again**. Since the filename and path (`/swapfile`) are the same, the system will automatically mount your new, resized swap file on the next boot.



### On Btrfs

#### a.1 Setting up Swap File

We will use the native Btrfs utility which handles the complexity (disabling CoW, allocating correctly) in one command.

```bash
sudo btrfs filesystem mkswapfile --size 4G --uuid clear /swapfile
```
> [!NOTE]
> Replace `4G` with your desired size (e.g., `8G`, `2G`).
> This command automatically creates the file, disables CoW (Copy-on-Write), allocates the space, and formats it as swap.

#### a.2 Activate the Swap File
```bash
sudo swapon /swapfile
```

#### a.3 Make it permanent
You need to add this to your `/etc/fstab` so it loads on boot.
```bash
sudo bash -c "echo '/swapfile none swap defaults 0 0' >> /etc/fstab"
```

#### a.4 Verify everything
Run `swapon --show` or `free -h`. You should see both your `/dev/zram0` (with higher priority, usually 100) and your `/swapfile` (with lower priority, usually -2).
