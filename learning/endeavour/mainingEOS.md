---
slug: "maining-endevourOS"
title: "Maining EndevourOS"
description: "Guide to how to pass from a dual boot with Windows 11 and EndeavourOS to a full main EndeavourOS."
tags: ["endeavour", "linux"]
date: 2025-09-25
---

## Removing Windows From EOS Partition

1. Install **GParted**:

```bash
sudo pacman -S gparted
```

2. Open GParted:

```bash
sudo gparted
```

3. Locate the **EndeavourOS partitions** — the ones you **should not touch**. These usually include:
   - `/` (root)
   - `efi/`
   - Any other partitions you’ve set up, like `/home`, `/swap`, `/tmp`

4. After identifying those, find the **Windows partitions** and **delete them**:
   - Right-click the Windows partition > `Delete`
   - You’ll now see **unallocated space**.
   - Confirm everything looks correct, then click the **check mark** (✓) at the top to apply the changes.

## Expanding Your EndeavourOS Partition

Now that you’ve got unallocated space, you probably want to **expand your EndeavourOS partition** (e.g. `/`, `/home`) to use that space.

1. Right-click the partition you want to expand > `Resize/Move`
2. A window will pop up. **Slide** the edge to increase the partition size or manually enter the new size.

### Having Unallocated Space on the Left

> [!IMPORTANT]
> GParted **can’t move partitions to the left** if they’re mounted. That means if the unallocated space is on the **left**, and you want to grow your `/` partition into it, you'll need to use a _live boot environment_ where the system partition isn’t mounted.

> [!CAUTION]
> Note on Boot Issues.
> This action **could** mess up your boot loader. I personally did all of these steps and my system booted fine afterward. But just so you know — this is not guaranteed, so in case anything breaks, you’ll have to search for solutions online. (I don’t have a fix for that kind of issue at the moment.)

#### Create a Boot Stick

1. Download the EndeavourOS ISO from the [official website](https://endeavouros.com/).
2. Insert your flash drive.
3. Create the boot stick:

```bash
sudo dd if=EndeavourOS.iso of=/dev/sdX bs=4M status=progress && sync
```

Replace `/dev/sdX` with the **correct disk** (not a partition like `/dev/sdX1`).

> [!CAUTION]
> This will wipe everything on the flash drive, so back it up first if there is value data for you in it.

#### Use GParted from the Live Boot

1. Boot into the flash drive.
2. Open a terminal and install GParted (if not already there):

```bash
sudo pacman -S gparted
```

3. Launch GParted:

```bash
sudo gparted
```

4. Right-click your EndeavourOS partition > `Resize/Move`.

5. A window will pop up. **Slide** the edge to increase the partition size or manually enter the new size. This time, you’ll be able to move/slide the partition because it’s not mounted.

6. Click the **check mark** to apply the changes. A **warning** will pop up — **read it carefully.**

#### Done

You now have the ~~best~~ OS as your main and only system.
