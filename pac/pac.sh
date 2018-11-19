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
 if [ -d ~/.paccoincore ]; then
   printf "~/.paccoincore/ already exists! The installer will delete this folder. Continue anyway?(Y/n):"
   read REPLY
   if [ ${REPLY} == "Y" ]; then
      #pID=$(ps -ef | grep savenoded | awk '{print $2}')
      #kill ${pID}
      killall -v paccoind && sleep 5     
      
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
_rpcUserName=morioh

# Choose a random and secure password for the RPC
_rpcPassword=a7c43e2f2b93e8d65cdf4820e4e7de406d4e5ea00af17b653c5045607cd37dc6

# Get the IP address of your vps which will be hosting the masternode
apt install curl -y
_nodeIpAddress=`curl ifconfig.me/ip`
#_nodeIpAddress=$(curl -s 4.icanhazip.com)
if [[ ${_nodeIpAddress} =~ ^[0-9]+.[0-9]+.[0-9]+.[0-9]+$ ]]; then
  external_ip_line="externalip=${_nodeIpAddress}:8765"
else
  external_ip_line="#externalip=external_IP_goes_here:8765"
fi
# Make a new directory for paccoin daemon
rm -r ~/.paccoincore/
mkdir ~/.paccoincore/
touch ~/.paccoincore/paccoin.conf

# Change the directory to ~/.paccoin
cd ~/.paccoincore/

# Create the initial paccoin.conf file
echo "rpcuser=${_rpcUserName}
rpcpassword=${_rpcPassword}
rpcallowip=127.0.0.1
rpcport=6801
listen=1
server=1
daemon=1
logtimestamps=1
maxconnections=64
txindex=1
masternode=1
${external_ip_line}
masternodeprivkey=${_nodePrivateKey}
" > paccoin.conf
cd

# Download savenode and put executable to /usr/local/bin

echo "paccoin downloading..."
#wget -qO- --no-check-certificate --content-disposition https://github.com/savenode/savenode/releases/download/v1.0.1.2/savenode-1.0.1-x86_64-linux-gnu.tar.gz | tar -xzvf savenode-1.0.1-x86_64-linux-gnu.tar.gz

sudo apt-get install unzip

wget https://gitlab.com/hoanghiep1x0/bash-masternodes-coins/blob/master/PAC/pac.zip


sudo chmod 777 -R pac.zip

unzip pac.zip -d pac


echo "Put executable to /usr/bin"
cp ~/wallet-coin-mns/pac/coin/paccoind /usr/bin/
cp ~/wallet-coin-mns/pac/coin/paccoin-cli /usr/bin/


# rm -rf ~/wallet-coin-mns/pac/coin
# rm -rf ~/wallet-coin-mns/pac/pac.zip

# Create a directory for masternode's cronjobs and the anti-ddos script
# rm -r masternode/paccoin
# mkdir -p masternode/paccoin

# Change the directory to ~/masternode/
# cd ~/masternode/paccoin

# Firewall security measures
apt install ufw -y
ufw allow 6801
ufw allow ssh
ufw logging on
ufw default allow outgoing
ufw --force enable

# Start savenode Deamon
#paccoind

# Reboot the server
#reboot