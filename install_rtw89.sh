#!/bin/bash

### THIS FILE IS TO INSTALL WIFI DRIVER AFTER UPDATING THE KERNEL FOR UBUNTU

# Update package list and install necessary packages
sudo apt update
sudo apt install -y dkms build-essential linux-headers-$(uname -r) git

# Clone the rtw89 repository if it doesn't exist
if [ ! -d "rtw89" ]; then
    git clone https://github.com/lwfinger/rtw89.git
fi

# Navigate to the rtw89 directory
cd rtw89

# Add the module to DKMS
sudo dkms add .

# Build and install the module using DKMS
sudo dkms build 8852be/1.0
sudo dkms install 8852be/1.0

# Load the module
sudo modprobe 8852be

echo "Driver installation completed. Please reboot your system."
