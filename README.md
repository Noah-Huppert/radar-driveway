# Radar Driveway
Code to run a radar sensor to determine if a car is coming up the driveway.

# Table Of Contents
- [Overview](#overview)
- [Development](#development)

# Overview
Uses an [Infineon Sense2Go Pulse radar unit](https://www.infineon.com/cms/en/product/evaluation-boards/demo-sense2gol-pulse/) connected to a Raspberry Pi to sense vehicles.

# Development
This code was developed to run on a Raspberry Pi connected to the development machine over a direct Ethernet connection.

## Setting Up Cross Compilation
[Rust](https://www.rust-lang.org/) with the `armv7-unknown-linux-gnueabihf` target is required.

A C++ cross compile toolchain for this target is also required (The package may be named something like `cross-arm-linux-gnueabihf`).

If the GCC executable is named anything other than `arm-linux-gnueabihf-gcc` then you must edit the [`radar_ctl/.cargo/config.toml`](./radar_ctl/.cargo/config.toml) file's `linker` key with your executable's name.

## Connecting To Raspberry PI
A private network between the development machine and the Raspberry Pi is set up to upload and diagnose code. This subnet occupies the 10.0.0.0/24 CIDR block (To change this edit the `SUBNET_CIDR` variable in [`scripts/dhcp-server.sh`](./scripts/dhcp-server.sh) and edit [`conf/dhcpd.conf`](./conf/dhcpd.conf) with the different subnet and range).

The [ISC DHCP server](https://www.isc.org/dhcp/) and [Avahi mDNS server](https://www.avahi.org/) (which often separately requires the `nss-mdns` package) must be installed.

1. First setup the Raspberry PI with an operating system, and make it so you can SSH in (For Raspberry PI OS put a file named `ssh` in the boot directory).
2. Connect an Ethernet cable between the Raspberry PI and your computer.
3. Make a copy of `.env-example` named `.env` and add your own configuration values. 
4. Run the DHCP and mDNS server:  
   ```
   ./scripts/dev-network.sh &
   ```
   The DHCP server will assign IP addresses for the private network between the development machine and the Pi.  
   
   The mDNS server will allow you to send network traffic to the Pi without knowing its IP. Instead all you need to know is the hostname of the Raspberry Pi. Then you can address the Pi on the `.local` DNS domain.  
   
   To find the hostname inspect the DHCP server's leases file, look at the `client-hostname` field: `cat ./.run/leases` (For Raspberry Pi OS the hostname will probably be `raspberrypi`).
5. SSH in. For Raspberry Pi OS the default username is `pi` and the password is `raspberry`:  
   ```
   ssh pi@raspberrypi.local
   ```


