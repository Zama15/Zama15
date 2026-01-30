---
slug: "password-less-ssh"
title: "Setting Up Password-less SSH Login"
description: "Setting up a Raspberry Pi OS password-less SSH login as remote server."
tags: ["linux", "raspios", "raspberry"]
date: 2025-10-09
---

## Setting Up Password-less SSH Login (on Server)

1. Install and Enable SSH

```sh
sudo apt update && sudo apt install -y openssh-server
sudo systemctl enable --now ssh
```

2. Check that SSH is running:

```sh
sudo systemctl status ssh
```

3. Change SSH Port (Security Measure)

Open the SSH configuration file:

```sh
sudo vim /etc/ssh/sshd_config
```

Find and change the line:

```
#Port 22
```

To a custom port, e.g.:

```
Port 2222
```

Save and Exit:

Press `ESC`, then type:

```
:wq
```

4. Restart SSH service to apply changes:

```sh
sudo systemctl restart ssh
```

5. Configure Firewall (UFW)

```sh
sudo ufw allow <NEW_PORT>/tcp
sudo ufw reload
```

> [!NOTE]
> An alternative command is with `firewalld`:
>
> ```bash
> sudo firewall-cmd --add-port=<NEW_PORT>/tcp --permanent
> sudo firewall-cmd --reload
> ```
>
> Make sure the `firewalld` service is running with `sudo systemctl enable --now firewalld`.

### Disable password authentication (OPTIONAL - Forces SSH key usage)

1. Edit the SSH config:

```sh
sudo vim /etc/ssh/sshd_config
```

Set the following:

```
PasswordAuthentication no
PermitRootLogin no
```

Press `ESC`, then type:

```
:wq
```

2. Restart SSH:

```sh
sudo systemctl restart ssh
```

## Setting Up SSH Key-Based Authentication (on Local)

1. Initialize agent:

```sh
eval "$(ssh-agent -s)"
```

2. Set the desired SSH key (in case of multiple keys):

```sh
ssh-add /path/to/ssh/id_ed25519_<USER>
```

3. Check the default key used:

```sh
ssh-add -l
```

4. Add a config file for easy access:

```sh
nvim ~/.ssh/config
```

Add the following host block:

```ini
Host <HOST_NAME>
    HostName <RASPBERRY_IP>
    Port <NEW_PORT>
    User <RASPBERRY_USER>
    IdentityFile /path/to/ssh/id_ed25519
```

Save and Exit:

Press `ESC`, then type:

```
:wq
```

5. Copy your public key to the Raspberry Pi:

```sh
ssh-copy-id -p <NEW_PORT> -i /path/to/ssh/id_ed25519 user@raspberrypi-ip
```

6. Now you can log in without a password and without specifying the user or IP:

```sh
ssh <HOST_NAME>
```
