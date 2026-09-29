---
slug: "system-information-command"
title: "How to Create a Custom Linux System Info Command"
description: "Discover how to create a custom Linux system information command using a bash script. Easily monitor RAM and storage directly from the terminal."
tags: ["linux", "raspios", "raspberry", "utils"]
keywords: "custom linux command, bash script system info, linux terminal utilities, check linux storage and ram, executable bash script, raspberry pi system monitor"
date: 2025-03-08
---

## System Information Command

1. Create the file

```bash
vim ~/sysinfo
```

Add the following into the file

```
#!/bin/bash

# Storage usage for the root filesystem (32GB)
storage_usage=$(df -h / | awk 'NR==2 {print $3 "/" $2 " (" $5 ")"}')

# RAM usage
ram_usage=$(free -h | awk '/Mem:/ {print $3 "/" $2 " (" $4 " free)"}')

# Alternative drive usage (128GB drive)
timeshift_drive_usage=$(df -h /mnt/timeshift | awk 'NR==2 {print $3 "/" $2 " (" $5 ")"}')
storage_drive_usage=$(df -h /mnt/storage | awk 'NR==2 {print $3 "/" $2 " (" $5 ")"}')

# Display the information
echo -e "\e[1;35mStorage (32GB):\e[0m $storage_usage"
echo -e "\e[1;35mRAM:\e[0m $ram_usage"
echo -e "\e[1;35mTimeshift Drive (30GB):\e[0m $timeshift_drive_usage"
echo -e "\e[1;35mStorage Drive (88GB):\e[0m $storage_drive_usage"
```

2. Save and Exit

```
ESC :wq
```

3. Make the script executable

```bash
chmod +x ~/sysinfo
```

3. Move it to the PATH

```
sudo mv ~/sysinfo /usr/local/bin/sysinfo
```

5. Test the command

```
sysinfo
```
