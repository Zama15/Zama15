# System Information Script Setup

## 1. Create the script
```
vim ~/sysinfo
```

### 1.1 Add the code
```bash
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

### 1.2 Save and Exit
```
ESC :wq
```

## 2. Make the script executable
```
chmod +x ~/sysinfo
```

## 3. Move it to a directory in your PATH
```
sudo mv ~/sysinfo /usr/local/bin/sysinfo
```

## 4. Test the command
```
sysinfo
```
