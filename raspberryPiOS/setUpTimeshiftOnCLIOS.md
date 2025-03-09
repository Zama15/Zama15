# Timeshift Backup System Setup

## 1. Update the system
```
sudo apt update
sudo apt upgrade
```

## 2. Install Timeshift
```
sudo apt install timeshift
```

## 3. Make the partition where the snapshots will be allocated
```
sudo parted /dev/sda
```
### 3.1 Create a new partition table
```
(parted) mklabel gpt
```
### 3.2 Create first partition (from 0% of the disk to 50%)
```
(parted) mkpart primary ext4 0% 50%
```
### 3.3 Create second partition (from 50% of the disk to 100%)
```
(parted) mkpart primary ext4 50% 100%
```
### 3.4 Verify partitions
```
(parted) print
```
### 3.5 Exit partition
```
(parted) quit
```

## 4. Format partitions
```
sudo mkfs.ext4 /dev/sda1
sudo mkfs.ext4 /dev/sda2
```

## 5. Label partitions
```
sudo e2label /dev/sda1 timeshift
sudo e2label /dev/sda2 storage
```

## 6. Create Mount points
```
sudo mkdir -p /mnt/timeshift
sudo mkdir -p /mnt/storage
```

## 7. Mount partitions
```
sudo mount /dev/sda1 /mnt/timeshift
sudo mount /dev/sda2 /mnt/storage
```

## 8. Verify Mounts
```
df -h
```

## 9. Save UUID of the partitions
Save this in a note, it will be used later
```
sudo blkid
```

## 10. Configure Timeshift
```
sudo vim /etc/timeshift/timeshift.json
```
### 10.1 Change the file
```json
{
    "backup_device_uuid" : "a0b2ba8a-02cc-4069-9e5e-17b659110abc",
    "parent_device_uuid" : "",
    "do_first_run" : "false",
    "btrfs_mode" : "false",
    "include_btrfs_home_for_backup" : "false",
    "include_btrfs_home_for_restore" : "false",
    "stop_cron_emails" : "true",
    "schedule_monthly" : "false",
    "schedule_weekly" : "true",
    "schedule_daily" : "true",
    "schedule_hourly" : "false",
    "schedule_boot" : "false",
    "count_monthly" : "2",
    "count_weekly" : "2",
    "count_daily" : "2",
    "count_hourly" : "6",
    "count_boot" : "5",
    "date_format" : "%Y-%m-%d %H:%M:%S",
    "exclude" : [
        "/home/**",
        "/mnt/timeshift/**",
        "/mnt/storage/**",
        "/proc/**",
        "/sys/**",
        "/dev/**",
        "/tmp/**",
        "/run/**",
        "/lost+found/**",
        "/root/**",
        "/home/admon/**"
    ],
    "exclude-apps" : []
}
```
### 10.2 Save and Exit
```
ESC :wq
```

## 11. Automount the partitions
```
sudo vim /etc/fstab
```
### 11.1 Add entries of the partitions
```
UUID=your-timeshift-partition-uuid /mnt/timeshift ext4 defaults,nofail 0 2
UUID=your-storage-partition-uuid /mnt/storage ext4 defaults,nofail 0 2
```
### 11.2 Save and Exit
```
ESC :wq
```
### 11.3 Ensure there are no errors
```
sudo mount -a
```

## 12. Verify setup
```
df -h
```
### 12.1 Test Timeshift
```
sudo timeshift --create --comments "Test Snapshot"
```
