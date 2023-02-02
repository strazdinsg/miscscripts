# Creating class-sets of virtual machines

The scripts in this folder helps you to manage sets of virtual-machines intended
to be used by a class of students. There are two variant, one LDAP-based, and
one SSH-key-based, each described in this readme.

## Preparations

Check out these scripts, and jump into the correct folder:

```
git clone https://github.com/ntnusky/miscscripts.git
cd miscscripts/vmset/
```

Either through the CLI, or through the command-line clients, acquire the
following information:

 - The ID of the image to base the VM's out of
 - The ID or Name of the flavor which the VM's should use
 - The ID or Name of the network where the VM's should be connected
 - The Name of the external network where the VM's should get a floating-IP
   from. This typically is 'ntnu-internal'
 - The name or ID of a security-group which should control what traffic is
   allowed to/from the VMs.

Make sure to have an openstack-client installed on your terminal, and verify
that it works by using a command like 'openstack network list'.

## Creating the VM's

### The LDAP-Based approach 

At the LDAP-based approach each VM will be created with the required
configuration to allow NTNU-users to log in. In addition an 'administrator'
accound is created which uses ssh-keys to authenticate, to allow a 'backdoor' in
for the course-responsible(s).

The admin-key is set in the script, so change the line adminkey=... to whatever
key you would like to use for this purpose.

Create a file which lists the machines you want, and which ntnu usernames should
be allowed to log in. To create two servers (group1 and group2) where usera and
userb should have access to the first one, and userc should have access to the
second one you should create a file with the following content:

```
group1:usera,userb
group2:userc
```

Next up is creating the VMs using the script with the following parameters:

```
./vmset-create-ldap.sh <coursename> <image> <flavor> <network> <external-network> <security-group> <input-file>
```

This can for example look like this:

```
$ ./vmset-create-ldap.sh KURS001 db1bc18e-81e3-477e-9067-eecaa459ec33 gx1.2c4r ObreNetwork-NTNU ntnu-internal SSH-NTNU-IPv4 input-ldap-example.csv
Creating a VM-set with the following properties:
 - Flavor: gx1.2c4r
 - Image: db1bc18e-81e3-477e-9067-eecaa459ec33
 - Network: ObreNetwork-NTNU (floating-IP from ntnu-internal)
 - Security-Group: SSH-NTNU-IPv4
Creating the server KURS001-group1
Reserving a floating-IP for KURS001-group1 from ntnu-internal
Assigning the floating-IP (10.212.169.15) to the server KURS001-group1:
The server KURS001-group1 is created!
Creating the server KURS001-group2
Reserving a floating-IP for KURS001-group2 from ntnu-internal
Assigning the floating-IP (10.212.168.74) to the server KURS001-group2:
The server KURS001-group2 is created!
```

At this point two servers are created, and will soon be ready:

 - KURS001-group1 at 10.212.169.15, where usera and userb is allowed to log in
 - KURS001-group2 at 10.212.168.74, where userc is allowed to log in

### The SSH-Key based approach

## Deleting the VM's

There is also created a utility-script which helps you delete VMs. The VM's
created in the LDAP-example above can be deleted like so:

```
$ ./vmset-delete.sh KURS001
Deleting the server with an ID of 3e819664-519c-42f7-8fbd-b2f9f070a5df
Deleting the server with an ID of facf23ab-4ffa-49b7-827b-e2cf058a24a3
Releasing the floating-IP 10.212.168.74
Releasing the floating-IP 10.212.169.15
```
