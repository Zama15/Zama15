---
slug: "welcome-message"
title: "Welcome Message"
description: "Making a welcome message for a linux system"
tags: ["linux", "raspios", "raspberry", "utils"]
date: 2025-03-08
---

## Welcome Message

This tutorial guides you through modifying your shell profile to display RAM and Storage stats every time you open a new session.

1. Edit `.profile`

```bash
vim ~/.profile
```

Add the following into the file

```
# Display system information only on first login
if [ -z "$FIRST_LOGIN" ]; then
    export FIRST_LOGIN=1

    # Storage usage for the root filesystem: Used/Total
    storage_usage=$(df -h / | awk 'NR==2 {print $3 "/" $2 " (" $5 ")"}')

    # RAM usage
    ram_usage=$(free -h | awk '/Mem:/ {print $3 "/" $2 " (" $4 " free)"}')

    # Display the information
    echo -e "\n\e[1;35mWelcome, \e[1;34m$(whoami)\e[0m!"
    echo -e "\n\e[1;35mStorage:\e[0m $storage_usage"
    echo -e "\e[1;35mRAM:\e[0m $ram_usage"
fi
```

2. Save and Exit

```
ESC :wq
```

3. Reload .bashrc

```bash
source ~/.bashrc
```
