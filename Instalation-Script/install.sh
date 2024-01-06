#!/bin/bash

# Ensure script is run with root privileges
if [[ $EUID -ne 0 ]]; then
  echo "This script must be run as root."
  exit 1
fi

# Install required dependencies
sudo nala install curl wget gpg apt-transport-https ca-certificates gnupg


# Add repositories for Brave, VS Code, VSCodium, and Docker
curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] https://brave-browser-apt-release.s3.brave.com/ stable main" | sudo tee /etc/apt/sources.list.d/brave-browser-release.list

wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor | sudo tee /etc/apt/keyrings/packages.microsoft.gpg > /dev/null
echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" | sudo tee /etc/apt/sources.list.d/vscode.list

wget -qO - https://gitlab.com/paulcarroty/vscodium-deb-rpm-repo/raw/master/pub.gpg | gpg --dearmor | sudo dd of=/usr/share/keyrings/vscodium-archive-keyring.gpg
echo 'deb [ signed-by=/usr/share/keyrings/vscodium-archive-keyring.gpg ] https://download.vscodium.com/debs vscodium main' | sudo tee /etc/apt/sources.list.d/vscodium.list

curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
  bookworm stable" | sudo tee /etc/apt/sources.list.d/docker.list

# Update package lists
sudo nala update
sudo apt update

# Install the software
sudo nala install brave-browser code codium docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Install Postman (assuming the archive is in Downloads)
username=$(id -u -n 1000)
if [[ ! -f /home/$username/Downloads/Postman-linux-x64.tar.gz ]]; then
  echo "Postman archive not found in Downloads. Please download and place it there."
  exit 1
fi
mkdir -p /opt/apps/
tar -xzf /home/$username/Downloads/Postman-linux-x64.tar.gz -C /opt/apps/
ln -s /opt/apps/Postman/Postman /usr/local/bin/postman
cat << EOF > /usr/share/applications/postman.desktop
[Desktop Entry]
Type=Application
Name=Postman
Icon=/opt/apps/Postman/app/resources/app/assets/icon.png
Exec="/opt/apps/Postman/Postman"
Comment=Postman Desktop App
Categories=Development;Code;
EOF

postman || echo "Postman launch failed. Please check installation."
