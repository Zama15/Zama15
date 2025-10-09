# Setup Guide

Follow these steps to install and enable the GRUB theme and configuration.

1. **Copy the Theme Directory**: The theme files (images and `theme.txt`) need to be placed in the GRUB themes directory. We'll create a new folder named `custom` for it.

```bash
# Create the 'custom' theme directory and copy the theme files into it
sudo cp -r theme /boot/grub/themes/custom
```

2. **Copy the GRUB Configuration**: The `grub` file contains the settings that point to the new theme. This file should replace the default GRUB configuration.

> [!IMPORTANT]
> Always back up the original file first!

```bash
# Backup the original configuration
sudo cp /etc/default/grub /etc/default/grub.bak

# Copy the new configuration file
sudo cp grub /etc/default/grub
```

3. **Apply the Changes**: After moving the files, it is needed to tell the GRUB to update its boot configuration based on the new settings.

```bash
# This command regenerates the /boot/grub/grub.cfg file
sudo grub-mkconfig -o /boot/grub/grub.cfg
```

> [!NOTE]
> On Debian-based systems like Ubuntu, it often use the alias `sudo update-grub`.

4. **Reboot and Enjoy**: That's it! Reboot the system to see the new custom GRUB menu.

```bash
sudo reboot
```

## Why the Files Are Structured This Way

This setup is split into two key parts: the **configuration** (`/etc/default/grub`) and the **theme** (`/boot/grub/themes/custom/`). This separation makes managing the bootloader clean and modular.

### The Configuration File: `grub` (becomes `/etc/default/grub`)

This file acts as the **master settings panel** for GRUB. It doesn't contain the theme's visual details, but rather high-level instructions on how GRUB should behave.

- **Role**: To define core GRUB settings like the default OS, timeout, kernel parameters, and—most importantly for us—**which theme to load**.
- **Why it's separate**: By keeping settings here, themes can easily switch just by changing the `GRUB_THEME` line, without having to edit the theme's assets. It's the "brain" that tells the "body" (the theme) what to do.

### The Theme Directory: `theme/` (becomes `/boot/grub/themes/custom/`)

This directory is a self-contained package that holds all the **visual assets and layout instructions** for the GRUB menu.

- **`theme.txt`**: This is the **stylesheet** for the GRUB menu, much like CSS is for a website. It defines the position, size, font, and color of every element on the screen, from the boot menu list to the countdown timer.
- **Image Files (`.png`)**: These are the graphical components.
  - `background.png`: The wallpaper for the GRUB menu.
  - `avatar.png`: A custom chosen image to display, positioned by the `+ image` block in `theme.txt`.
  - `select_*.png`: These files are used to create the selection highlight. The `*` is a wildcard. GRUB can cycle through these images (e.g., `select_c.png`, `select_e.png`) to create an animated or styled box around the currently selected menu item.

## How to Customize This Setup

Now, let's break down how can be tweak the files.

### Customizing the Main `grub` Configuration

Edit `/etc/default/grub` (with `sudo`) to change GRUB's behavior.

> [!IMPORTANT]
> After any change, remember to run `sudo grub-mkconfig -o /boot/grub/grub.cfg`.

- **Change the Timeout**:

```ini
# Time in seconds before the default entry is booted
GRUB_TIMEOUT=5
```

- **Change the Default Boot Entry**:

```ini
# This combo remembers the last booted OS and makes it the default for the next boot.
# Super useful for dual-booting!
GRUB_SAVEDEFAULT=true
GRUB_DEFAULT=saved
```

To always boot the first entry, use `GRUB_DEFAULT=0`.

- **Change Screen Resolution**:

```ini
# Set the resolution for the GRUB menu.
GRUB_GFXMODE=1920x1080
```

Make sure the system supports the resolution chose. To see available modes type `vbeinfo` in the GRUB command line (press `C` at the boot menu).

### Customizing the `theme.txt` File

This is where it control the look and feel. The syntax consists of global properties and components defined with `+ component_name { ... }`.

- **Changing Fonts and Colors**:
  Edit the `+ boot_menu` section to easily change the text colors.

```ini
+ boot_menu {
    ...
    item_color = "#edf2f4"         # Color for normal boot entries
    selected_item_color = "#ef233c"  # Color for the highlighted entry
    ...
}
```

> [!NOTE]
> For GRUB to use a custom font like `VictorMono Nerd Font`, first convert it to GRUB's `.pf2` format and place it in the theme directory. This can be done with the `grub-mkfont` command:
>
> ```bash
> sudo grub-mkfont -v -s 32 -o grub/theme/VictorMono32.pf2 /path/to/VictorMono.ttf
> ```
>
> Then, update the `theme.txt` to point to the new font file: `item_font = "VictorMono32"`.

- **Adjusting Element Positions**:
  Move elements around by changing their `left`, `top`, `width`, and `height` properties. The theme uses percentages and simple calculations for centering. For example, to move the avatar slightly to the left:

```ini
+ image {
    left = 40%-200   # Was 50%-200, moved it 10% to the left
    top = 7%
    width = 400
    height = 400
    file = "avatar.png"
}
```

- **Modifying the Countdown Timer**:
  The `+ label` section with `id = "__timeout__"`, change the text that appears. The `%d` is a placeholder for the number of seconds remaining.

```ini
+ label {
    ...
    id = "__timeout__"
    text = "Launching in %d..."  # Changed the text
    color = "#ffbe0b"           # Changed the color to yellow
    ...
}
```
