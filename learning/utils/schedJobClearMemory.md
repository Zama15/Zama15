---
slug: "sched-job-to-clear-memory"
title: "Automate Clearing Linux RAM Cache with a Cron Job"
description: "Learn how to schedule a root cron job to automatically clear your Linux RAM cache. Follow this simple guide to use crontab and drop_caches safely."
tags: ["linux", "endeavour", "utils"]
keywords: "clear linux memory, automate ram cache clearing, cron job memory management, linux drop_caches, crontab clear ram, free up linux memory"
date: 2025-03-08
---

## Setup Locally

1. Enter as root with crontab

```bash
sudo crontab -e
```

2. Add the following cron job

```
0 3 * * * sync; echo 3 > /proc/sys/vm/drop_caches
```

3. Check there is no error

```bash
sudo crontab -l
```

## Test the command individually

If you want to test the command to verify it work on your system

```bash
echo 3 | sudo tee /proc/sys/vm/drop_caches
```

To check if the memory usage slow down

```bash
top
```

or for a more visual representation you can use `bottom`

```bash
# pacman -S btm
btm
```
