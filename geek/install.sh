#!/bin/bash
# install.sh
# Installs masternode on Ubuntu 16.04 x64 & Ubuntu 18.04
# ATTENTION: The anti-ddos part will disable http, https and dns ports.

if [[ $UID != 0 ]]; then
    echo "Please run this script with sudo:"
    echo "sudo $0 $*"
    exit 1
fi

echo "prefix user using tiker coin example 'geek':"
read  namecoin

if [ ${namecoin} == "" ]; then
    echo "prefix user name:"
    exit 1
fi

echo 'Amount user auto create:'
read amount

if [ $amount -lt 0 ]; then
    echo "Please enter a number greater than 0"
    exit 1
fi

echo 'Port start of node:' 
read port

echo "Enter password of all user : "
read password

let counter=0


# install directory to ~/masternode/
cd ~/masternode/geekcash

curl -LJO https://github.com/GeekCash/geekcash/releases/download/v1.0.1.3/geekcash-1.0.1-x86_64-linux-gnu.tar.gz

echo "unzip..."
tar -xzvf ./geekcash-1.0.1-x86_64-linux-gnu.tar.gz
chmod +x ./geekcash-1.0.1/bin/


echo "Put executable to /usr/bin"
cp ./geekcash-1.0.1/bin/geekcashd /usr/bin/
cp ./geekcash-1.0.1/bin/geekcash-cli /usr/bin/


rm -rf ./geekcash-1.0.1
rm -rf ./geekcash-1.0.1-x86_64-linux-gnu.tar.gz

# Create a directory for masternode's cronjobs and the anti-ddos script

# Firewall security measures
apt install ufw -y
ufw allow 6889
ufw allow ssh
ufw logging on
ufw default allow outgoing
ufw --force enable

# created account in file config

while [ $counter -lt $amount ]
do

 # Choose a random created user in vps and for the RPC
  username=$namecoin$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 8 ; echo '')

  let port++
  let counter++


  #check port already empty
  sudo lsof -t -i:$port
  if [ "$?" -le 0 ]; then
    echo "Can't install   ${namecoin} with ${port} ! Please create this masternodes with port other"
    exit 1
  fi

   if [ $(id -u) -eq 0 ]; then
        egrep "^$username" /etc/passwd >/dev/null
        if [ $? -eq 0 ]; then
            echo  $username "xists!"
            exit 1
        else
            pass=$(perl -e 'print crypt($ARGV[0], "password")' $password)
            useradd -m -p $pass $username
            sudo usermod -aG sudo $username
            [ $? -eq 0 ] && echo "User has been added to system!" || echo "Failed to add a user!"
        fi
    else
        echo "Only root may add a user to the system"
        exit 2
    fi

 
    #set run with no password
    echo "%sudo ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
    echo "Created user and forder success";

    cd "/home/${username}"
    mkdir .geekcash
    
    # Choose a random and secure password for the RPC
    _rpcPassword=$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 32 ; echo '')

    read -p "Enter Ip Of Masternodes:" _nodeIpAddress
    
    printf -v _nodeIpAddress '%s' $_nodeIpAddress
    
    read -p "Enter nodePrivateKey Of Masternodes:" _nodePrivateKey

    rm -r .geekcash/
    mkdir .geekcash/
    cd .geekcash/
    
    echo "rpcuser=${username}
        rpcpassword=${_rpcPassword}
        rpcallowip=127.0.0.1
        rpcport=${port}
        bind=${_nodeIpAddress}:6889
        listen=0
        server=1
        daemon=1
        logtimestamps=1
        maxconnections=64
        txindex=1
        masternode=1
        externalip=${_nodeIpAddress}:6889
        masternodeprivkey=${_nodePrivateKey}
        "> geekcash.conf

  
    echo "user ${counter} ===> login:" $username
    echo "password login:" $password
    echo "Masternode ${counter}: ${namecoin} Running width ip ${_nodeIpAddress}:${port}"
    echo "GenKey masternode ${_nodePrivateKey}"
    
    su -l  $username -c "sudo geekcashd -datadir=/home/${username}/.geekcash -daemon"

    echo "-----------------------------------------------------------------------------------------------"

    # checkdaemon.sh

    previousBlock=$(cat ~/masternode/geekcash/blockcount)
    currentBlock=$(geekcash-cli getblockcount)

    sudo 0 0 * * *  geekcash-cli getblockcount > ~/masternode/geekcash/blockcount

    if [ "$previousBlock" == "$currentBlock" ]; then
    geekcash-cli stop
     su -l  $username -c "sudo geekcashd -datadir=/home/${username}/.geekcash -daemon"
    fi

done

reboot
