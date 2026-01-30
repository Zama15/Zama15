---
slug: "adding-vram"
title: "Adding SWAP or ZRAM"
description: "Guide to how to add more SWAP or ZRAM for low resources machines."
tags: ["endeavour", "linux"]
date: 2025-09-25
---

## ZRAM

Compresses and decompresses memory in real time. Here it's used more like RAM, effectively getting virtual RAM from physical drives.

> [!NOTE]
> Because of the compress/decompress process, CPU load may increase, especially during heavy multitasking. On a low-end or thermally throttled CPU, this could cause performance dips.

1. Install

```bash
sudo pacman -S zram-generator
```

2. Create Config File

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

> [!NOTE]
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

3. Reload service and start ZRAM generator

Reload systemd daemons to apply the new config:

```bash
sudo systemctl daemon-reload
```

Start the ZRAM service:

```bash
sudo systemctl start systemd-zram-setup@zram0
```

> [!NOTE]
> `@zram0` refers to the first ZRAM device (`/dev/zram0`). You can configure multiple devices (zram1, zram2…) but usually only one is needed.
>
> It's not necessary to enable the service because the generator dynamically creates the unit at boot time based on the config file.

### Editing ZRAM

To change the amount of ZRAM, edit the configuration file created.

1. Open the config file:

```bash
sudo nano /etc/systemd/zram-generator.conf
```

2. Modify the size:

```ini
[zram0]
zram-size = 4096
compression-algorithm = zstd
```

3. Apply the changes.

The easiest and most reliable way to apply the new configuration is to simply **rebooting**.

```bash
reboot
```

If you want to apply it without rebooting, you can run:

```bash
sudo systemctl daemon-reload
sudo systemctl restart systemd-zram-setup@zram0
```

3. Verify the new size:

```bash
zramctl
```

This will show you the `DISKSIZE` of your `/dev/zram0` device.

## 2. SWAP

This will be used when the RAM overflows to the point where it would crash. It effectively works as a fallback, making it reliable for low-RAM machines during multitasking or heavy app usage. Here it's set up with the idea that [ZRAM](#zram) won’t be enough on its own.

> [!NOTE]
> Swap on an SSD adds write cycles, which can reduce SSD lifespan over years of intense use. Although, if only using 2–4GB occasionally, it’s a minimal risk.

This part divides in two parts, based on the filesystem you have. To know what filesystem you are using

```bash
lsblk -f
```

Look fot the root entry `/` this tells you what you are using `btrfs` or `ext4`.

### Ext4

1. Create a 4GB swapfile

```bash
sudo fallocate -l 4G /swapfile
```

This command **reserves 4GB of space** on your disk and creates a file named `/swapfile`.
You can change `4G` to any value depending on how much fallback swap you want.

2. Secure the file

```bash
sudo chmod 600 /swapfile
```

This sets permissions to **owner read/write only**, preventing other users or processes from accessing it — important for security and system stability.

3. Format it as swap

```bash
sudo mkswap /swapfile
```

This command **initializes the file** as swap space so the system can recognize and use it as additional memory.

4. Enable it

```bash
sudo swapon /swapfile
```

This tells the kernel to **start using the swapfile immediately**, without needing a reboot.

You can verify it’s active with:

```bash
free -h
```

Look under the `Swap:` line — it should now show 4GB (or whatever size you picked).

5. Make it permanent

Open `/etc/fstab`:

```bash
sudo nano /etc/fstab
```

Add this line to the bottom of the file:

```
/swapfile none swap defaults 0 0
```

This tells the system to **mount the swapfile automatically at every boot**, so you don’t have to enable it manually each time.

#### Modifying Swap File Size

Changing a swap file is a bit more involved because it can't be modify it while it's used. So it have to be disabled, removed, and created again.

Let's say you want to change your swap from 4GB to 2GB.

1. Turn off the current swap file

```bash
sudo swapoff /swapfile
```

2. Remove the old file:

```bash
sudo rm /swapfile
```

3. Create the new swap file. In this example, we'll create a 2GB file.

```bash
sudo fallocate -l 2G /swapfile
```

4. Re-apply the correct permissions and format:

```bash
sudo chmod 600 /swapfile
sudo mkswap /swapfile
```

5. Turn the new swap file on:

```bash
sudo swapon /swapfile
```

6. Verify the new size checking the output of `free -h`. The `Swap:` line should now show `2.0G`.

```bash
free -h
```

> [!NOTE]
> You **do not need to edit `/etc/fstab` again**. Since the filename and path (`/swapfile`) are the same, the system will automatically mount your new, resized swap file on the next boot.

### On Btrfs

1. Setting up Swap File

We will use the native Btrfs utility which handles the complexity (disabling CoW, allocating correctly) in one command.

```bash
sudo btrfs filesystem mkswapfile --size 4G --uuid clear /swapfile
```

Replace `4G` with your desired size (e.g., `8G`, `2G`). This command automatically creates the file, disables CoW (Copy-on-Write), allocates the space, and formats it as swap.

2. Activate the Swap File

```bash
sudo swapon /swapfile
```

3. Make it permanent

Open `/etc/fstab`:

```bash
sudo nano /etc/fstab
```

Add this line to the bottom of the file:

```
/swapfile none swap defaults 0 0
```

4. Verify everything

Run `swapon --show` or `free -h`. You should see both your `/dev/zram0` (with higher priority, usually 100) and your `/swapfile` (with lower priority, usually -2).
