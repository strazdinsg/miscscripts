#!/bin/bash
projectID=f0a9af1e93984a3d8450931176a262b7
username=gist
keystoneURL=https://api.stack.it.ntnu.no:5000
 
unset OS_TOKEN
unset OS_AUTH_TYPE
 
export OS_AUTH_URL=$keystoneURL
export OS_IDENTITY_API_VERSION=3
export OS_TENANT_ID=$projectID
export OS_INTERFACE="public"
export OS_ENDPOINT_TYPE=publicURL
 
export OS_USERDOMAIN_NAME="NTNU"
export OS_USERNAME=$username
export OS_DOMAIN_NAME=NTNU
 
tcommand="openstack token issue -f value -c id"
 
echo "Please supply the password to the $OS_DOMAIN_NAME user $username:"
token=$($tcommand)
status=$?
while [[ $status -ne 0 ]]; do
  echo "Could not get a token. Please try again:"
  token=$($tcommand)
  status=$?
done
 
export OS_TOKEN="$token"
export OS_AUTH_TYPE="token"
 
unset OS_DOMAIN_NAME
unset OS_USERDOMAIN_NAME
unset OS_USERNAME
 
echo "You are now authenticated to use the openstack CLI client."
