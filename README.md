# Radar Driveway
Code to run a radar sensor to determine if a car is coming up the driveway.

# Table Of Contents
- [Overview](#overview)
- [Development](#development)

# Overview
Uses an [Infineon Sense2Go Pulse radar unit](https://www.infineon.com/cms/en/product/evaluation-boards/demo-sense2gol-pulse/) connected to a Raspberry Pi to sense vehicles.

# Development
This code was developed to run on a Raspberry Pi connected to the development machine over a direct Ethernet connection.

## Connecting To Raspberry PI
A private network between the development machine and the Raspberry Pi is set up to upload and diagnose code. This subnet occupies the 10.0.0.0/24 CIDR block (To change this edit the `SUBNET_CIDR` variable in [`scripts/dhcp-server.sh`](./scripts/dhcp-server.sh) and edit [`conf/dhcpd.conf`](./conf/dhcpd.conf) with the different subnet and range).

1. First setup the Raspberry PI with an operating system, and make it so you can SSH in (For Raspberry PI OS put a file named `ssh` in the boot directory).
2. Connect an Ethernet cable between the Raspberry PI and your computer.
3. Make a copy of `.env-example` named `.env` and add your own configuration values. 
4. Run the DHCP server:  
   ```
   ./scripts/dhcp-server.sh &
   ```
5. Find the Raspberry Pi's IP.  
   There is no specific configuration which dictates what the Pi's IP will be. One can do the following things to find the IP:
  - Examine the DHCP server leases file to find the Raspberry PI's IP:
    ```
    cat ./.run/leases
    ```
  - Scan the private network for the Pi:  
    ```
	nmap 10.0.0.0/24
	```
	One should see the development machine's IP (Which can be found using `ip addr show <ethernet interface>`) and another IP running an SSH server. This is the Pi.
6. SSH in. For Raspberry Pi OS the default username is `pi` and the password is `raspberry`.


