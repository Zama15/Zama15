---
slug: "sched-job-to-clear-memory"
title: "Schedule a Job to Clear Memory with Cron"
description: "Scheduling a job with crontab to clear memory on RAM with crontab command."
tags: ["linux", "endeavour", "utils"]
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
