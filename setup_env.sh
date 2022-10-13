# Update the list of packages
sudo apt update -y
# Install pre-requisite packages.
sudo apt install -y wget apt-transport-https software-properties-common gcc binutils make perl liblzma-dev mtools genisoimage syslinux isolinux git build-essential zlib1g-dev binutils-dev
# Download the Microsoft repository GPG keys
wget -q "https://packages.microsoft.com/config/ubuntu/$(lsb_release -rs)/packages-microsoft-prod.deb"
# Register the Microsoft repository GPG keys
sudo dpkg -i packages-microsoft-prod.deb
# Update the list of packages after we added packages.microsoft.com
sudo apt update
# Install PowerShell
sudo apt install -y powershell