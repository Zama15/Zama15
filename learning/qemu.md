---
slug: "qemu-virtual-machine-setup"
title: "Creating Virtual Machines with QEMU"
description: "A quick guide to creating disk images and running virtual machines using QEMU and KVM."
tags: ["virtualization", "qemu", "linux"]
date: 2026-01-26
---

## Create a Disk Image

Make an OS image with the `qcow2` format, which is the native format that QEMU uses to run virtual machines:

```bash
qemu-img create -f qcow2 <MACHINE_NAME>.img 10G
```

## Run the Installation

This is for running the installation:

```bash
qemu-system-x86_64 -enable-kvm -cdrom <ISO_FILE>.iso -boot menu=on -drive file=image.img -m 2G -cpu host -smp 2 -vga virtio -display gtk,gl=on
```

Explanation of Options

- `-enable-kvm` → enables hardware acceleration.
- `-cdrom <ISO_FILE>.iso` → specifies the ISO image for installation.
- `-boot menu=on` → enables the boot menu.
- `-drive file=image.img` → specifies the virtual disk.
- `-m 2G` → assigns 2 GB of memory.
- `-cpu host` → passes the host CPU configuration.
- `-smp 2` → assigns 2 CPU cores.
- `-vga virtio` → sets the display adapter (better performance).
- `-display gtk,gl=on` → uses GTK display with OpenGL enabled.

### Notes on Graphics Options

> [!NOTE]
> To enable `-vga qxl`, load the required modules:
>
> ```bash
> sudo modprobe qxl bochs_drm
> ```
>
> I recommend using `virtio`. You may also choose the display option with:
>
> - `-display sdl`
> - `-display gtk`

## After Installation

Once the ISO installation is complete, remove the option `-cdrom <ISO_FILE>.iso`:

```bash
qemu-system-x86_64 -enable-kvm -boot menu=on -drive file=image.img -m 2G -cpu host -smp 2 -vga virtio -display gtk,gl=on
```

## Useful Shortcuts

- **`Ctrl + Alt + G`** → release the mouse pointer to the host machine.
- **`Ctrl + Alt + F`** → toggle full screen.
