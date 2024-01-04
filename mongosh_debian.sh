#!/bin/bash

sudo nala install gnupg

# Import the MongoDB GPG key
wget -qO- https://www.mongodb.org/static/pgp/server-7.0.asc | sudo tee /etc/apt/trusted.gpg.d/server-7.0.asc

# Create a list file for MongoDB
echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/debian bullseye/mongodb-org/7.0 main" | sudo tee /etc/apt/sources.list.d/mongodb-org-7.0.list

# Update the package list
sudo nala update

# Install the MongoDB shell
sudo nala install -y mongodb-mongosh