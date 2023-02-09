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
that it works by using a command like `openstack network list`.

## Creating the VM's

Both the ´vmset-create-*.sh´ scripts uses the same logic. They take common
configuration options like image, flavor, network etc. as parameters, in
addition to a csv-file listing the VMs that is needed. For each VM that is
listed in the input-file the script does the following:

 - Takes a copy of the relevant cloudconf-template file.
 - Replaces a couple of macros (like ADMINKEY, SSHKEY, USERLIST) with the
   relevant parameters.
 - Creates a VM using the supplied cloudconf file.
 - Allocates a floating-IP and assigns it to the VM.

All resources created are tagged with the supplied coursecode, which simplifies
deletion (see [vmset-delete.sh](vmset-delete.sh)).

### The SSH-Key based approach

If you want VMs that is not authenticating using NTNU users we recommend to use
SSH-keys. The script [vmset-create-sshkey.sh](vmset-create-sshkey.sh) creates
VMs with two users: 'administrator' and 'user', where the administrator account
gets the same ssh-key for all machines and the user-accounts get individual keys.

When it comes to who should create the ssh-keypairs, the most secure way is to
have the users of the VM's to create the key pairs, and then send in the public
part to the course-responsible which in the end creates all the VMs. This
ensures that the private-keys are not needed to be sent anywhere. The easier
alternative is to generate a keypair per VM, and distribute the private-keys to
the students. The script [vmset-create-sshkey.sh](vmset-create-sshkey.sh)
supports both these approaches.

To create VM's using this approach you should first insert the public part of
the admin-key into the [vmset-create-sshkey.sh](vmset-create-sshkey.sh) file.
Next up you should create an input-file with the following format:

```
serverA:ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGOUa4umWBvM+++eVKXHs4CDrir+aWqrcMtLkPhQR1UF user@host
serverB
```

In this example the serverA machine is having the supplied key injected in the
'user' user, while serverB will have a ssh-keypair generated, and the
private-key has to be sent to whoever should use this VM. Next up is creating
the VM's using the script with the following parameters:

```
./vmset-create-sshkey.sh <coursename> <image> <flavor> <network> <external-network> <security-group> <input-file>
```

This can for example look like this, when using the input seen above:

```
$ ./vmset-create-sshkey.sh KURS002 db1bc18e-81e3-477e-9067-eecaa459ec33 gx1.2c4r ObreNetwork-NTNU ntnu-internal SSH-NTNU-IPv4 input-sshkey-example.csv
Creating a VM-set with the following properties:
 - Flavor: gx1.2c4r
 - Image: db1bc18e-81e3-477e-9067-eecaa459ec33
 - Network: ObreNetwork-NTNU (floating-IP from ntnu-internal)
 - Security-Group: SSH-NTNU-IPv4
Creating the server KURS002-serverA
Reserving a floating-IP for KURS002-serverA from ntnu-internal
Assigning the floating-IP (10.212.174.117) to the server KURS002-serverA:
The server KURS002-serverA is created!
Creating the server KURS002-serverB
Reserving a floating-IP for KURS002-serverB from ntnu-internal
Assigning the floating-IP (10.212.170.235) to the server KURS002-serverB:
The server KURS002-serverB is created!
```

At this point there exists two VMs:

 - KURS002-serverA at 10.212.174.117 where the supplied key is injected.
 - KURS002-serverB at 10.212.170.235 where a freshly generated private-key is
   injected.

The generated keypair(s) is placed in the same folder as the script:

```
$ ls -1 ssh-key-*
ssh-key-KURS002-serverB
ssh-key-KURS002-serverB.pub
```

When the servers are booted the first time they wil automatically install all
missing updates and then reboot. So, if you log into them quickly after creation
(within 5-minutes -ish) you should not be surprised if the VM suddenly reboots.

### The LDAP-Based approach 

At the LDAP-based approach each VM will be created with the required
configuration to allow NTNU-users to log in. In addition, an 'administrator'
account is created which uses ssh-keys to authenticate, to allow a 'backdoor' in
for the course-responsible(s).

The admin-key is set in the script, so change the line `adminkey=...` to whatever
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

When the servers are booted the first time they wil automatically install all
missing updates and then reboot. So, if you log into them quickly after creation
(within 5-minutes -ish) you should not be surprised if the VM suddenly reboots.

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
