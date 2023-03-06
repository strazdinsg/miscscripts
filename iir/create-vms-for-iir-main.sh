#!/bin/bash

# Use this script to create default virtual machines inside the project IIR_Main
if [[ $# -lt 2 ]]; then
  echo "Use this script to create default virtual machines for a project at IIR, inside the OpenStack project IIR_Undervisning."
  echo "User for each VM are specified in the CSV file, one line per server:"
  echo "<groupname>:<username1>[,<username2>[,<usernameN>]]"
  echo
  echo "The servers will have a public IPv4 and public IPv6 address."
  echo "The name of the servers will be in the format <project>-<groupname>"
  echo
  echo "Usage: $0 <project> <path-to-csv-file>"
  exit 1
fi

IIR_MAIN_PROJECT=a8eb3493bbaa421d9d44d346619a710f
IIR_MAIN_NETWORK=c59bebf1-0b12-42a1-9b48-6a1333b49b1e
IIR_MAIN_DEFAULT_SECURITY_GROUP=fd26d8fe-a136-4807-a837-aa24e1404155
UBUNTU_22_IMAGE=c15481d3-e1ac-4331-9379-c63cb14d12b1
SERVER_WITH_2_CPU_6GB_RAM=0e0d3604-c25c-458f-b212-72f66944ce7b
IIR_TEACHING_ADMIN_PUBLIC_KEY="ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDF8Ypri5Y3ynfVM0n1UxNJ/MzKBJmVbgdiWu8oref9TkmYZmryCNXAK765DdKNJcXgt5fN5XaNoktJqxLeE9OJUc7oDWRG9QoqTMKt2WIjTjTThfAv1hjRoRU06aQJsh9vD+43rl80eb6E7DC9EpaIvBNskWl/M0stNNqvMLTMYh//9i5rzmHymt+3KOlhpFu0Bw1cOTWiMK0OHlpcTKcBaF9yW/ZGNFZ6/0exiJuowM9G5GuGvE/udx/v1m9rD4MabhuF9ZO8s837Arev+Xc/sWPVy+wlM2ETwGC3fm5keYfAUj49iPvZdaJaMmzGn1ZMvjdI/kZ0H3GKbjV6r7Kv Generated-by-Nova"

COURSE_CODE=$1
CSV_FILE=$2
PROJECT_ID=${IIR_MAIN_PROJECT}
NETWORK_ID=${IIR_MAIN_NETWORK}
EXTERNAL_NETWORK=ntnu-global
SECURITY_GROUP_ID=${IIR_MAIN_DEFAULT_SECURITY_GROUP}
IMAGE_ID=${UBUNTU_22_IMAGE}
FLAVOR=${SERVER_WITH_2_CPU_6GB_RAM}
ADMIN_KEY=${IIR_TEACHING_ADMIN_PUBLIC_KEY}

echo "creating VMs for project $COURSE_CODE, reading users from file $CSV_FILE ..."
echo

./vmset-create-ldap.sh ${COURSE_CODE} ${IMAGE_ID} ${FLAVOR} ${NETWORK_ID} ${EXTERNAL_NETWORK} ${SECURITY_GROUP_ID} ${CSV_FILE} ${ADMIN_KEY}
