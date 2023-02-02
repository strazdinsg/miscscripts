#!/bin/bash
set -e

if [[ $# -lt 7 ]]; then
  echo "This script creates multiple VM's with custom allow-lists of which"
  echo "users are allowed to log in. All based on a input-file with the"
  echo "following format, one line per server:"; echo
  echo "<servername>:<username1>[,<username2>[,<usernameN>]]"
  echo
  echo -n "Usage: $0 <coursename> <image> <flavor> <network> <external-network>"
  echo " <security-group> <input-file>"
  exit 1
fi

coursename=$1
image=$2
flavor=$3
network=$4
externalnet=$5
secgroup=$6
inputFile=$7

cloudconfigTemplate="cloudconf-template-ldap.yaml"
adminkey="ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGOUa4umWBvM+++eVKXHs4CDrir+aWqrcMtLkPhQR1UF user@host"

echo "Creating a VM-set with the following properties:"
echo " - Flavor: $flavor"
echo " - Image: $image"
echo " - Network: $network (floating-IP from $externalnet)"
echo " - Security-Group: $secgroup"

while IFS='' read -r line || [[ -n "$line" ]]; do
  servername=$(echo $line | cut -d ':' -f '1')
  hostname="${coursename}-${servername}"
  users=$(echo $line | cut -d ':' -f '2' | tr ',' ' ')

  if ! openstack server show $hostname &> /dev/null; then
    cloudconfig="cloudconfig-${servername}.yaml"
    cp $cloudconfigTemplate $cloudconfig
    sed -i "sUSERLIST${users}g" $cloudconfig
    sed -i "sADMINKEY${adminkey}g" $cloudconfig

    echo "Creating the server $hostname"
    serverid=$(openstack server create --image $image --network $network \
        --flavor $flavor --security-group $secgroup --user-data $cloudconfig \
        --tag $coursename --tag VM-Set --wait $hostname -f value -c id)
    
    echo "Reserving a floating-IP for $hostname from $externalnet"
    floatingIP=$(openstack floating ip create $externalnet \
      --tag $coursename --tag VM-Set \
      --description "IP for $hostname" -f value -c floating_ip_address)
    
    echo "Assigning the floating-IP ($floatingIP) to the server $hostname:"
    openstack server add floating ip $serverid $floatingIP > /dev/null

    echo "The server $hostname is created!"
    rm $cloudconfig
  else
    echo "The server $hostname already exists"
  fi
done < $inputFile
