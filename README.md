# Radar Driveway
Code to run a radar sensor to determine if a car is coming up the driveway.

# Table Of Contents
- [Overview](#overview)
- [Development](#development)

# Overview
Uses a radar unit to sense vehicles.

# Development
This code was developed to run on a Raspberry PI.

## Connecting To Raspberry PI
1. First setup the Raspberry PI with an operating system, and make it so you can SSH in (For Raspberry PI OS put a file named `ssh` in the boot directory).
2. Connect an Ethernet cable between the Raspberry PI and your computer.
3. Make a copy of `.env-example` named `.env` and add your own configuration values
4. Run the DHCP server:  
   ```
   ./scripts/dhcp-server.sh
   ```
5. Examine the DHCP server leases file to find the Raspberry PI's IP:
   ```
   cat ./.run/leases
   ```


