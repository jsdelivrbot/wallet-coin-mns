#!/bin/bash
# install.sh
# Installs masternode on Ubuntu 16.04 x64 & Ubuntu 18.04
# ATTENTION: The anti-ddos part will disable http, https and dns ports.

if [[ $UID != 0 ]]; then
    echo "Please run this script with sudo:"
    echo "sudo $0 $*"
    exit 1
fi

echo 'Coin tiker to install:'
read  namecoin

if [ ${namecoin} == "" ]; then
    echo "Please enter tiker coin:"
    exit 1
fi

echo 'Amount to install:'
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





# install

while [ $counter -lt $amount ]
do

   echo "Please enter ip of VPS"
   read ip

  if [ -z "$ip" ]
  then
      echo "Ip cann't empty"
      exit 1
  fi
 # Choose a random created user in vps and for the RPC
  username=$namecoin$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 6 ; echo '')
  # Choose a random and secure password for the RPC
  _rpcPassword=$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 32 ; echo '')

  echo "user:" $username
  echo "password:" $password

  let port++
  let counter++
  echo 'masternode'  $namecoin  '-'  $counter  ' install width :'  $port

  #check port already empty
  sudo lsof -t -i:$port
  if [ "$?" -le 0 ]; then
    echo "Cannot install " $namecoin " masternode with "  $ip "and port " + $port
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
    # login user

    sudo chmod 777 -R "/home/${username}"
    su $username
    send "${password}\r"
    sudo ls

    
    wget https://cdn.jsdelivr.net/gh/GeekCash/masternode/install.sh
    chmod +x ./install.sh
    sudo bash ./install.sh

done