#!/bin/bash
# install.sh
# Installs masternode on Ubuntu 16.04 x64 & Ubuntu 18.04
# ATTENTION: The anti-ddos part will disable http, https and dns ports.

wget https://cdn.jsdelivr.net/gh/GeekCash/masternode/install.sh
chmod +x ./install.sh
sudo bash ./install.sh

