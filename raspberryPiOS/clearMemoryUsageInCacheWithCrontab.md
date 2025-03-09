# Memory Cache Clearing Setup

## 1. Enter as root with crontab
```
sudo crontab -e
```

### 1.1 Add the following cron job
```
0 3 * * * sync; echo 3 > /proc/sys/vm/drop_caches
```

## 2. Check there is no error
```
sudo crontab -l
```

## 3. Test the command by yourself to ensure no errors
```
echo 3 | sudo tee /proc/sys/vm/drop_caches
```

### 3.1 Check if the memory usage slow down
```
top
```
