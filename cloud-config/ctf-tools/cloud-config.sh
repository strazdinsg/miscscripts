#!/bin/bash

# This will generate a random CTF-like flag and post the server's hostname, IP and flag to a callback server
# The callback server must understand a post request with JSON data. An example is given in this repo

# TO MAKE IT WORK:
# Change the URL to your callback server
# Eventually; change the flag prefix given in $FLAG, and
# the path of the flag file

# Send this as user-data with cloud-init :-)

STRING=$(cat /dev/urandom | tr -dc '[:alpha:]' | fold -w ${1:-20} | head -n 1)
FLAG="{NCR}$STRING"
IP=$(hostname -I | cut -d' ' -f1)
HOSTNAME=$(hostname)
DATA="{\"hostname\":\"$HOSTNAME ($IP)\", \"flag\":\"$FLAG\"}"
echo $FLAG > /opt/flag.txt
chmod 755 /opt/flag.txt

curl -d "$DATA" -H "Content-Type: application/json" -X POST http://callbackserver.foo:8000
