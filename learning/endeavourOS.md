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
