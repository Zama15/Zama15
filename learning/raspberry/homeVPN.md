---
slug: "home-vpn"
title: "Setting Up a VPN to a in-Home Server"
description: "How to set up a Raspberry server in-home to direct trafict remotly with Open VPN."
tags: ["linux", "raspios", "raspberry"]
date: 2026-03-22
draft: true
---

# OpenVPN Setup Tutorial

## Part 1: Set up the OpenVPN Server

### 1. Install OpenVPN & Easy-RSA

1.1 Update your system and install the required packages:

```bash
sudo apt update && sudo apt install openvpn easy-rsa -y
```

### 2. Set Up the PKI (Public Key Infrastructure)

2.1 Create a directory for Easy-RSA:

```bash
make-cadir ~/openvpn-ca
cd ~/openvpn-ca
```

2.2 Initialize the PKI:

```bash
./easyrsa init-pki
```

2.3 Build the Certificate Authority (CA):

```bash
./easyrsa build-ca
```

2.4 Enter and confirm the CA passphrase.  
2.5 Enter and confirm the PEM passphrase.  
2.6 Enter CA Common Name.  
2.7 Generate the Server Certificate & Key:

```bash
./easyrsa gen-req <FILENAME> nopass
```

2.8 Enter the server Common Name.  
2.9 Sign the Server Certificate:

```bash
./easyrsa sign-req server <FILENAME>
```

2.10 Enter 'yes' to continue.  
2.11 Enter the PEM passphrase.  
2.12 Generate the Diffie-Hellman parameters (for key exchange security):

```bash
./easyrsa gen-dh
```

2.13 Create a TLS-Auth key (extra layer of security):

```bash
openvpn --genkey secret ta.key
```

### 3. Configure OpenVPN Server

3.1 Copy the required files:

```bash
sudo cp ~/openvpn-ca/pki/ca.crt /etc/openvpn/
sudo cp ~/openvpn-ca/pki/issued/<FILENAME>.crt /etc/openvpn/
sudo cp ~/openvpn-ca/pki/private/<FILENAME>.key /etc/openvpn/
sudo cp ~/openvpn-ca/pki/dh.pem /etc/openvpn/
sudo cp ~/openvpn-ca/ta.key /etc/openvpn/
```

3.2 Create a new OpenVPN server configuration file:

```bash
sudo vim /etc/openvpn/server.conf
```

3.3 Paste the following configuration:

```
port <CUSTOM_PORT>
proto udp
dev tun
ca /etc/openvpn/ca.crt
cert /etc/openvpn/<FILENAME>.crt
key /etc/openvpn/<FILENAME>.key
dh /etc/openvpn/dh.pem
tls-auth /etc/openvpn/ta.key 0
server 10.8.0.0 255.255.255.0
push "redirect-gateway def1 bypass-dhcp"
push "dhcp-option DNS 8.8.8.8"
keepalive 10 60
cipher AES-256-GCM
persist-key
persist-tun
status /var/log/openvpn-status.log
verb 4
```

### 4. Configure Firewall (UFW)

4.1 Allow the OpenVPN port through the firewall:

```bash
sudo ufw allow <CUSTOM_PORT>/udp
sudo ufw reload
```

4.2 Enable NAT forwarding (replace `<CONNECTION>` based on your connection type: `eth0` for ethernet, `wlan0` for wifi):

```bash
sudo iptables -t nat -A POSTROUTING -s 10.8.0.0/24 -o <CONNECTION> -j MASQUERADE
```

4.3 Save the firewall rules:

```bash
sudo mkdir /etc/iptables
sudo sh -c "iptables-save > /etc/iptables/rules.v4"
```

4.4 (Optional) To automatically save and restore firewall rules after reboot:

```bash
sudo apt update && sudo apt install iptables-persistent -y
```

4.5 During installation, answer “Yes” to saving current rules.

4.6 Enable the Auto-Restore Service:

```bash
sudo systemctl enable netfilter-persistent
```

4.7 Check that the rules persist after reboot:

```bash
sudo iptables -t nat -L -v -n
```

### 5. Enable IP Forwarding

5.1 Edit the sysctl configuration:

```bash
sudo vim /etc/sysctl.conf
```

5.2 Uncomment the following line:

```
net.ipv4.ip_forward=1
```

5.3 Apply changes:

```bash
sudo sysctl -p
```

### 6. Start & Enable OpenVPN

6.1 Start the OpenVPN service:

```bash
sudo systemctl start openvpn@server
```

6.2 Enable OpenVPN to start on boot:

```bash
sudo systemctl enable openvpn@server
```

6.3 Check the status:

```bash
sudo systemctl status openvpn@server
```

---

## Part 2: Add Clients to the VPN

### 7. Generate Client Configurations

7.1 Generate a client key & certificate:

```bash
cd ~/openvpn-ca
./easyrsa gen-req <FILENAME_CLIENT_N> nopass
```

7.2 Enter the server Common Name.  
7.3 Sign the client certificate:

```bash
./easyrsa sign-req client <FILENAME_CLIENT_N>
```

7.4 Enter 'yes' to continue.  
7.5 Enter PEM passphrase.

7.6 Copy the necessary files:

```bash
sudo cp ~/openvpn-ca/pki/issued/<FILENAME_CLIENT_N>.crt /etc/openvpn/
sudo cp ~/openvpn-ca/pki/private/<FILENAME_CLIENT_N>.key /etc/openvpn/
```

### 8. Create a Script to Generate Client Configurations

8.1 Create a script for generating client configuration files:

```bash
vim create_client.sh
```

8.2 Paste the following script (modify `<YourPublicIP>`):

```bash
#!/bin/bash

# Check if a client name was provided
if [ -z "$1" ]; then
  echo "Usage: $0 <CLIENT_NAME>"
  exit 1
fi

# Variables
CLIENT_NAME="$1"
OPENVPN_DIR="/etc/openvpn"
CLIENT_CONFIG_DIR="$HOME/openvpn-clients"
CLIENT_CONFIG="$CLIENT_CONFIG_DIR/$CLIENT_NAME.ovpn"

# Ensure the client config directory exists
mkdir -p "$CLIENT_CONFIG_DIR"

# Step 2: Create the client configuration file
{
  echo "client"
  echo "dev tun"
  echo "proto udp"
  echo "remote <PUBLIC_IP> <PORT>"
  echo "resolv-retry infinite"
  echo "nobind"
  echo "persist-key"
  echo "persist-tun"
  echo "remote-cert-tls server"
  echo "tls-auth ta.key 1"
  echo "cipher AES-256-GCM"
  echo "verb 4"
  echo ""
  echo "<ca>"
  sudo cat "$OPENVPN_DIR/ca.crt"
  echo "</ca>"
  echo ""
  echo "<cert>"
  sudo cat "$OPENVPN_DIR/$CLIENT_NAME.crt"
  echo "</cert>"
  echo ""
  echo "<key>"
  sudo cat "$OPENVPN_DIR/$CLIENT_NAME.key"
  echo "</key>"
  echo ""
  echo "<tls-auth>"
  sudo cat "$OPENVPN_DIR/ta.key"
  echo "</tls-auth>"
} > "$CLIENT_CONFIG"

# Step 3: Notify the user
echo "Client configuration file created: $CLIENT_CONFIG"
```

8.3 Save and exit:

```
ESC :wq
```

8.4 Make the script executable:

```bash
chmod +x create_client.sh
```

8.5 Run the script with the client name you created:

```bash
./create_client.sh <FILENAME_CLIENT_N>
```

---

## Part 3: Delete Clients from the VPN

### 9. Remove Clients

#### 9.1 Revoke a Certificate

To revoke a client certificate:

```bash
./easyrsa revoke <FILENAME_CLIENT_N>
./easyrsa gen-crl
```

#### 9.2 Delete Certificate Files

Remove the certificate and key files:

```bash
rm pki/issued/<FILENAME_CLIENT_N>.crt
rm pki/private/<FILENAME_CLIENT_N>.key
rm pki/reqs/<FILENAME_CLIENT_N>.req
```

#### 9.3 Delete Copied Files

Remove the client’s files from OpenVPN:

```bash
rm /etc/openvpn/<FILENAME_CLIENT_N>.crt
rm /etc/openvpn/<FILENAME_CLIENT_N>.key
```

#### 9.4 Clean up the PKI Index

If needed, manually edit the `pki/index.txt` file to fix/delete invalid entries.

---

## Part 4: Connect to the VPN via Client

### 10. Transfer the `.ovpn` File to Your Client Device

```bash
scp -P <CUSTOM_PORT> <USER>@<RASPBERRY_PI_IP>:<PATH_TO_FILE> <LOCAL_DESTINATION>
```

### 10.1 Install OpenVPN (version 2.4+):

```bash
sudo pacman -S openvpn
```

### 10.2 Connect to the VPN:

```bash
sudo openvpn --config ~/<FILENAME>.ovpn
```

### 10.3 Verify the Connection and Internet Access

#### 10.4 Check for the `tun0` interface with the IP `10.8.0.X`:

```bash
ip a
```

#### 10.5 Check if it matches your server’s public IP:

```bash
curl ifconfig.me
```

#### 10.6 Check for Internet connection (ensure there is not 100% packet loss):

```bash
ping -c 4 8.8.8.8
```
