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
 if [ -d ~/.savenode ]; then
   printf "~/.savenode/ already exists! The installer will delete this folder. Continue anyway?(Y/n):"
   read REPLY
   if [ ${REPLY} == "Y" ]; then
      #pID=$(ps -ef | grep savenoded | awk '{print $2}')
      #kill ${pID}
      killall -v savenoded && sleep 5     
      
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
# Make a new directory for savenode daemon
rm -r ~/.savenode/
mkdir ~/.savenode/
touch ~/.savenode/savenode.conf

# Change the directory to ~/.savenode
cd ~/.savenode/

# Create the initial savenode.conf file
echo "rpcuser=${_rpcUserName}
rpcpassword=${_rpcPassword}
rpcallowip=127.0.0.1
listen=1
rpcport=6802
server=1
daemon=1
logtimestamps=1
maxconnections=64
txindex=1
masternode=1
${external_ip_line}
masternodeprivkey=${_nodePrivateKey}
" > savenode.conf

# Download savenode and put executable to /usr/local/bin

echo "savenode downloading..."
#wget -qO- --no-check-certificate --content-disposition https://github.com/savenode/savenode/releases/download/v1.0.1.2/savenode-1.0.1-x86_64-linux-gnu.tar.gz | tar -xzvf savenode-1.0.1-x86_64-linux-gnu.tar.gz

apt install unzip

cd ~
sudo wget https://github.com/hoanghiep1x0/wallet-coin-mns/raw/master/savecoin/savecoin.zip

echo "unzip..."
unzip savecoin.zip -d ./savenode 
chmod 777 -R ./savenode 

echo "Put executable to /usr/bin"
cp ./savenode/savenoded /usr/bin/
cp ./savenode/savenode-cli /usr/bin/

# rm -rf ./savenode
# rm -rf ./savenode.zip


# Create a directory for masternode's cronjobs and the anti-ddos script


# Firewall security measures
apt install ufw -y
ufw allow 6802
ufw allow ssh
ufw logging on
ufw default allow outgoing
ufw --force enable

# Start savenode Deamon
savenoded

# Reboot the server
reboot