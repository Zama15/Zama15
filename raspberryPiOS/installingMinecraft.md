# Raspberry Pi 5 Minecraft Setup (1.16.5 and below)

This guide details how to configure a Raspberry Pi 5 (8GB RAM) to run Minecraft versions like **1.16.5**, which require **Java 8** and **X11/OpenGL support**. The setup involves:

- Compiling **PrismLauncher** from source
- Installing **Java 8** via Temurin (Adoptium)
- Switching from **Wayland to X11** for better OpenGL compatibility

---

## Requirements

- **Raspberry Pi 5**
- **Raspberry Pi OS Desktop 64-bit (Debian Bookworm)**
- 8GB RAM (recommended)
- A working OpenGL/X11 setup

---

## 1. System Preparation

Update system and install build tools & Qt dependencies to compile PrismLauncher:

```bash
sudo apt update && sudo apt upgrade
sudo apt install git cmake extra-cmake-modules build-essential \
  qtbase5-dev qtchooser qt5-qmake qtbase5-dev-tools qttools5-dev \
  qttools5-dev-tools libssl-dev libgl1-mesa-dev libpulse-dev \
  libxcb-keysyms1-dev libxcb-util0-dev libx11-xcb-dev libxrender-dev \
  libxi-dev libxext-dev libxfixes-dev zlib1g-dev libzip-dev
sudo apt install qt6-base-dev qt6-tools-dev qt6-tools-dev-tools qt6-l10n-tools
sudo apt install libqt6svg6-dev libqt6core5compat6-dev
sudo apt install qt6-networkauth-dev
```

---

## 2. Build and Install PrismLauncher

Clone and build PrismLauncher from source:

```bash
git clone https://github.com/PrismLauncher/PrismLauncher.git
cd PrismLauncher
git submodule update --init --recursive
mkdir build && cd build
cmake .. -DCMAKE_BUILD_TYPE=Release
make -j$(nproc)
sudo make install
```

This builds the launcher with full support for your system.

---

## 3. Install Java 8 (Temurin)

Older Minecraft versions like 1.16.5 require Java 8. Since it's not in APT, download from [Adoptium](https://adoptium.net/en-GB/temurin/releases/):

```bash
# After downloading the tar.gz from Adoptium:
tar -xvzf OpenJDK8U-jdk_*.tar.gz
sudo mkdir -p /opt/java
sudo mv jdk8u* /opt/java/jdk8
```

To use it in PrismLauncher:
- Go to **Settings > Java** in PrismLauncher
- Set the Java path to `/opt/java/jdk8/bin/java`

---

## 4. Switch to X11 (Fix OpenGL Errors)

Wayland doesn’t always play nice with older OpenGL or GLFW-based apps (like Minecraft). Switch to X11 for full compatibility:

### Install supporting X11 libraries:

```bash
sudo apt install libgl1-mesa-dri libgl1-mesa-glx libglu1-mesa libglfw3
sudo apt install mesa-utils
sudo apt install libglfw3 libglfw3-dev libgles2-mesa-dev libegl1-mesa-dev \
  libxrandr-dev libxinerama-dev libxcursor-dev libxi-dev libxxf86vm-dev libxss-dev
```

### Install and enable LXDE (X11 desktop environment):

```bash
sudo apt install lxde lxsession lxde-common
```

### Edit LightDM config to use X11 (LXDE-pi-x session):

```bash
sudo nano /etc/lightdm/lightdm.conf
```

Make sure this section looks like:

```ini
[Seat:*]
user-session=LXDE-pi-x
autologin-session=LXDE-pi-x
autologin-user=YOUR_USERNAME
```

Then reboot:

```bash
sudo reboot
```

Verify you're using X11:

```bash
echo $XDG_SESSION_TYPE
# Should return: x11
```

---

## Done!

Now you can:
- Open PrismLauncher
- Add a Minecraft 1.16.5 instance
- Select Java 8 from `/opt/java/jdk8/bin/java`
- Launch and play!

