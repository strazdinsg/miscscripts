#!/bin/bash
set -e

if [[ $# -lt 1 ]]; then
  echo "This script deletes all VM-s related to a certain course"
  echo "Usage: $0 <coursename>" 
  exit 1
fi

coursename=$1

for server in $(openstack server list --os-compute-api-version 2.26 --tags $coursename -f value -c ID); do
  echo "Deleting the server with an ID of $server"
  openstack server delete $server
done

for ip in $(openstack floating ip list --tags $coursename -f value -c 'Floating IP Address'); do
  echo "Releasing the floating-IP $ip"
  openstack floating ip delete $ip
done
