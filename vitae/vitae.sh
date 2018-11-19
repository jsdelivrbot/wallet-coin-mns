#!/bin/bash
# install.sh
# Installs masternode on Ubuntu 16.04 x64 & Ubuntu 18.04
# ATTENTION: The anti-ddos part will disable http, https and dns ports.


if [[ $UID != 0 ]]; then
    echo "Please run this script with sudo:"
    echo "sudo $0 $*"
    exit 1
fi




while true; do
 if [ -d ~/.vitae ]; then
   printf "~/.vitae/ already exists! The installer will delete this folder. Continue anyway?(Y/n):"
   read REPLY
   if [ ${REPLY} == "Y" ]; then
      #pID=$(ps -ef | grep vitaed | awk '{print $2}')
      #kill ${pID}
      killall -v vitaed && sleep 5     
      
      break
   else
      if [ ${REPLY} == "n" ]; then
        exit
      fi
   fi
 else
   break
 fi
done
cd

# Get a new privatekey by going to console >> debug and typing masternode genkey
printf "Enter Masternode PrivateKey: "
read _nodePrivateKey

# The RPC node will only accept connections from your localhost
_rpcUserName=$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 12 ; echo '')

# Choose a random and secure password for the RPC
_rpcPassword=$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 32 ; echo '')

# Get the IP address of your vps which will be hosting the masternode
apt install curl -y
_nodeIpAddress=`curl ifconfig.me/ip`
#_nodeIpAddress=$(curl -s 4.icanhazip.com)
if [[ ${_nodeIpAddress} =~ ^[0-9]+.[0-9]+.[0-9]+.[0-9]+$ ]]; then
  external_ip_line="externalip=${_nodeIpAddress}:8765"
else
  external_ip_line="#externalip=external_IP_goes_here:8765"
fi
# Make a new directory for vitae daemon
rm -r ~/.vitae/
mkdir ~/.vitae/
touch ~/.vitae/vitae.conf

# Change the directory to ~/.vitae
cd ~/.vitae/

# Create the initial vitae.conf file
echo "rpcuser=${_rpcUserName}
rpcpassword=${_rpcPassword}
rpcallowip=127.0.0.1
listen=1
server=1
daemon=1
logtimestamps=1
maxconnections=64
txindex=1
masternode=1
${external_ip_line}
masternodeprivkey=${_nodePrivateKey}
" > vitae.conf
cd

# Download vitae and put executable to /usr/local/bin

echo "Vitae downloading..."
#wget -qO- --no-check-certificate --content-disposition https://github.com/vitae/vitae/releases/download/v1.0.1.2/vitae-1.0.1-x86_64-linux-gnu.tar.gz | tar -xzvf vitae-1.0.1-x86_64-linux-gnu.tar.gz

wget https://github.com/hoanghiep1x0/wallet-coin-mns/raw/master/vitae/vitae.zip -O vitae.zip

echo "unzip..."
tar -xzvf ./vitae.zip
chmod +x ./vitae/

echo "Put executable to /usr/bin"
cp ./vitae/vitaed /usr/bin/
cp ./vitae/vitae-cli /usr/bin/


# rm -rf ./vitae
# rm -rf ./vitae.zip


# Create a directory for masternode's cronjobs and the anti-ddos script
rm -r masternode/vitae
mkdir -p masternode/vitae

# Change the directory to ~/masternode/
cd ~/masternode/vitae

# Firewall security measures
apt install ufw -y
ufw allow 8765
ufw allow ssh
ufw logging on
ufw default allow outgoing
ufw --force enable

# Start vitae Deamon
vitaed

# Reboot the server
#reboot