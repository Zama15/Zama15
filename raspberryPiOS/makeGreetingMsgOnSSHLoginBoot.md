# Bash Profile Configuration for System Information Display

## 1. Edit .profile
```
vim ~/.profile
```

### 1.1 Add the code
```bash
# Display system information only on first login
if [ -z "$FIRST_LOGIN" ]; then
    export FIRST_LOGIN=1

    # Storage usage for the root filesystem (32GB)
    storage_usage=$(df -h / | awk 'NR==2 {print $3 "/" $2 " (" $5 ")"}')

    # RAM usage
    ram_usage=$(free -h | awk '/Mem:/ {print $3 "/" $2 " (" $4 " free)"}')

    # Alternative drive usage (128GB drive)
    timeshift_drive_usage=$(df -h /mnt/timeshift | awk 'NR==2 {print $3 "/" $2 " (" $5 ")"}')
    storage_drive_usage=$(df -h /mnt/storage | awk 'NR==2 {print $3 "/" $2 " (" $5 ")"}')

    # Display the information
    echo -e "\n\e[1;35mWelcome, \e[1;34m$(whoami)\e[0m!"
    echo -e "\n\e[1;35mStorage (32GB):\e[0m $storage_usage"
    echo -e "\e[1;35mRAM:\e[0m $ram_usage"
    echo -e "\e[1;35mTimeshift Drive (30GB):\e[0m $timeshift_drive_usage"
    echo -e "\e[1;35mStorage Drive (88GB):\e[0m $storage_drive_usage"
fi
```

### 1.2 Save and Exit
```
ESC :wq
```

## 2. Reload .bashrc
```
source ~/.bashrc
```
