# SSH Setup Guide for Raspberry Pi

## 1. Install and Enable SSH
```sh
sudo apt update && sudo apt install -y openssh-server
sudo systemctl enable --now ssh
```

### 1.1 Check that SSH is running:
```sh
sudo systemctl status ssh
```

## 2. Change SSH Port (Security Measure)

### 2.1 Open the SSH configuration file:
```sh
sudo vim /etc/ssh/sshd_config
```

### 2.2 Find and change the line:
```sh
#Port 22
```
To a custom port, e.g.:
```sh
Port 2222
```

### 2.3 Save and Exit:
Press `ESC`, then type:
```sh
:wq
```

### 2.4 Restart SSH service to apply changes:
```sh
sudo systemctl restart ssh
```

## 3. Configure Firewall (UFW)
```sh
sudo ufw allow <NEW_PORT>/tcp
sudo ufw reload
```

## 4. Set Up SSH Key-Based Authentication (on remote device)

### 4.1 Initialize agent:
```sh
eval "$(ssh-agent -s)"
```

### 4.2 Set the desired SSH key (in case of multiple keys):
```sh
ssh-add /path/to/ssh/id_ed25519_<USER>
```

### 4.3 Check the default key used:
```sh
ssh-add -l
```

### 4.4 Add a config file for easy access:
```sh
nvim /path/to/ssh/config
```

### 4.5 Add the following host block:
```ini
Host <HOST_NAME>
    HostName <RASPBERRY_IP>
    Port <NEW_PORT>
    User <RASPBERRY_USER>
    IdentityFile /path/to/ssh/id_ed25519
```

### 4.6 Save and Exit:
Press `ESC`, then type:
```sh
:wq
```

### 4.7 Copy your public key to the Raspberry Pi:
```sh
ssh-copy-id -p <NEW_PORT> -i /path/to/ssh/id_ed25519 user@raspberrypi-ip
```

### 4.8 Now you can log in without a password and without specifying the user or IP:
```sh
ssh <HOST_NAME>
```

## 5. Disable password authentication (OPTIONAL - Forces SSH key usage)

### 5.1 Edit the SSH config:
```sh
sudo vim /etc/ssh/sshd_config
```

### 5.2 Set the following:
```sh
PasswordAuthentication no
PermitRootLogin no
```

### 5.3 Restart SSH:
```sh
sudo systemctl restart ssh
