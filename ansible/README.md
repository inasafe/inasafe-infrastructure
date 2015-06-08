This file still needs to be modified for InaSAFE
================================================


DEVELOPMENT ENVIRONMENT
=======================

First, install a recent version of Vagrant from https://www.vagrantup.com
Import the necessary base box(es) using:
```
vagrant box add hashicorp/precise64
```

Bring up your vagrants using:
```
vagrant up
```

Optionally, add the following entries to your `/etc/hosts` file so that you
and your vagrants can resolve their hostnames when DNS is down (i.e. when you
are not connected to the Internet).
```
10.0.3.3  web1-dev.tracks4africa.net web1-dev
10.0.3.4  db1-dev.tracks4africa.net db1-dev
```


DEPLOYMENT EXAMPLES
===================

Some deployment examples for the `t4a_django` project, which uses the `t4a`
Ansible role.

Deploy the feature/foo branch in development environment
```
ansible-playbook -i development.ini site.yml -t t4a -e t4a_branch=feature/foo
```

Deploy the default branch (production) to stage environment
```
ansible-playbook -i stage.ini site.yml -t t4a
```


TO PROVISION A VIRTUAL MACHINE USING ANSIBLE
============================================

You will require Ansible version 1.5 or newer in order to run all the playbooks
in this repository. See the Ansible website for information on how to obtain
the latest version for your platform.

You will also require Java 6/7 applet support in your web browser. Oracle/Sun
and OpenJDK are both supported.

1.  Log in to the Proxmox web interface by browsing to
    https://za1.tracks4africa.net:8006.
    Create the virtual machine with the following settings.

        General:
          Node: select an appropriate initial node host
          Name: full hostname, e.g. web2.tracks4africa.net
        OS:
          Linux 3.X/2.X kernel
        CD/DVD:
          ISO Image: select the ISO you wish to use for installation
        Hard disk:
          Bus: VIRTIO
          Device: 0
          Storage: shared
          Disk size: 16GB
          CPU: optionally increase the number of cores to suit the workload
          Memory: optionally increase RAM allocation to suit the workload
          Network:
            Bridge: vmbr0
            Model: VirtIO (paravirtualized)

2.  Select the new VM in the left pane, then click the `Hardware` tab in the
    right pane. Click the `Add` toolbar button and choose `Hard Disk`. Enter
    the following parameters to add a second hard disk for data storage.

        Bus: VIRTIO
        Device: 1
        Storage: shared
        Disk size: according to HOST DETAILS table below
        Cache: Default (no cache)

3.  Next click on the `Options` tab in the right pane. Double click on the
    `Start at boot` field and ensure that it is enabled.

4.  Select the new VM  in the left pane and click the `Console` button near the
    top right corner of the web interface.

5.  Accept any security warnings your browser may offer, and when the applet
    loads, click the Start button to the top left corner of the window.

6.  The VM will boot up from the previously selected ISO image and you can
    proceed with the OS installation. See the notes later in this document for
    guidance on Ubuntu or Debian installations.

7.  Create a DNS 'A' record for the server in the form
    "newserverX.tracks4africa.net" and point it to the IP addresses you entered
    during installation.

8.  Once the installation is complete, reboot the VM and log in as root (you
    may need to log in as a regular user and use `sudo -i` to become root on
    some distros such as Ubuntu). You should be able to log in over SSH using
    password authentication at this point, which should make the following
    steps easier.

9.  Set a root password if the installer did not set one for you.

10. Place your SSH pubkey into the `/root/.ssh/authorized_keys` file, creating
    the parent directory if it does not exist. 

11. Test a remote login by executing on your workstation:
    `ssh -p22 root@newserverX.tracks4africa.net`

12. Add an entry under the relevant group in the inventory file (production.ini)
    in this repository with the following paramaters:
    `newserverX.tracks4africa.net ansible_ssh_port=22 ansible_ssh_user=root`

13. Provision the server using Ansible by running the following command on your
    workstation, from the same directory as this README.
    `ansible-playbook -i production.ini --limit newserverX.tracks4africa.net site.yml`

14. In the Proxmox web UI, select the VM and click the `Hardware` tab. Double
    click on the `CD/DVD Drive` item and select `Do not use any media`. This
    step is important as live migrations will not be possible whilst the VM
    has a locally-stored ISO image mounted.

15. Once Ansible has provisioned the server, amend the previously added
    inventory entry and remove the parameters after the hostname, for example:
    `newserverX.tracks4africa.net`

TO BUILD A PROXMOX CLUSTER
==========================

Proxmox requires Debian 7 or later. Ansible will successfully build a Proxmox
cluster from a minimal Debian 7 install, as provided by Hetzner's Linux
installation system.

1. Create a DNS 'A' record for each server pointing to each host's IP address:
     - za1.tracks4africa.net - 197.189.211.98
     - za2.tracks4africa.net - 197.189.211.99

2. Activate the 64-bit rescue mode from within konsoleH and reboot each server

3. Log into each server (booted into rescue mode) over SSH using the temporary
   root password shown in konsoleH.

4. Run the command `installimage` and choose 'Debian-7x-wheezy-64-minimal'

5. Enter the following parameters in the configuration screen (replacing the
   hostname accordingly):

        DRIVE1 /dev/sda
        DRIVE2 /dev/sdb
        SWRAID 1
        SWRAIDLEVEL 1
        BOOTLOADER grub
        HOSTNAME newserverX.tracks4africa.net
        PART /boot ext3 512M
        PART lvm vg_hostname 100G
        PART /tmp/dummy ext2 all
        LV vg_hostname root / ext4 20G
        LV vg_hostname swap swap swap 4G

5. Leave any other settings at their default values and press F10 to proceed
   with the installation.
6. Type `reboot` to exit the rescue environment.
7. Connect via SSH using the same root temporary root password and save your
   ssh public key as `/root/.ssh/authorized_keys`
8. Configure both servers using Ansible by executing:
   `ansible-playbook -i production.ini site.yml`
9. Due to initial build complexity, Ansible will fail to complete and will
   display one or more commands for you to run manually as root. After each
   instruction, resume Ansible by simply running the command in step 9, until
   it completes.


### DRBD/LVM

In order to initialise DRBD and LVM devices for shared storage, you can invoke
Ansible to use the drbd.yml playbook. You will be prompted to do this at some
point during the main Ansible run or the site.yml playbook (step 9 above).

WARNING: This playbook has several checks to try and ensure that an existing
disk configuration does not get mistakenly destroyed/rebuilt, however disk
operations always carry an element of risk, so please bear this in mind when
running this playbook. Before running on an existing production server
deployment, ensure that your Ansible version is fully up-to-date and perform
a verbose dry-run beforehand!


HOST DETAILS
============


### Network Configuration

- Network Address: 197.189.211.97/27
- Address Range: 197.189.211.96 - 197.189.211.127
- Netmask: 255.255.255.224
- Broadcast: 197.189.211.127
- Gateway: 197.189.211.97
- Nameservers: 197.189.211.98, 197.189.211.99


### Physical Servers

Hostname              | Primary IP Address | BMC IP Address  | BMC User | BMC Pass | Hetzner Name
----------------------|--------------------|-----------------|----------|----------|--------------------------------
za1.tracks4africa.net | 197.189.211.98     | 197.189.210.230 | client   | cxg8Ewiq | tra007\_truservplus\_jhb1\_001
za2.tracks4africa.net | 197.189.211.99     | 197.189.210.238 | client   | UP48i8iM | tra007\_truservplus\_jhb1\_002


### Virtual Servers

VM ID | Hostname                     | IP Address      | Storage Volume
-----:|------------------------------|-----------------|----------------
100   | web1.tracks4africa.net       | 197.189.211.100 | 100GB
101   | web2.tracks4africa.net       | 197.189.211.101 | 20GB
102   | vcs1.tracks4africa.net       | 197.189.211.102 | 30GB
103   | mon1.tracks4africa.net       | 197.189.211.103 | -
104   | db1.tracks4africa.net        | 197.189.211.104 | 150GB
105   | map1.tracks4africa.net       | 197.189.211.105 | 200GB
106   | db2.tracks4africa.net        | 197.189.211.106 | 20GB
107   | sysadmin1.tracks4africa.net  | 197.189.211.107 | -
108   | db3.tracks4africa.net        | 197.189.211.108 | 50GB
109   | backup1.tracks4africa.net    | 197.189.211.109 | 30GB
110   | web1-stage.tracks4africa.net | 197.189.211.110 | 50GB
111   | db1-stage.tracks4africa.net  | 197.189.211.111 | 50GB


NOTES ON UBUNTU INSTALLATION
============================

- Language: English
- Country: South Africa
- Detect keyboard layout: no
- Keyboard country: English (US)
- Keyboard layout: English (US)
- Network configuration method: Configure network manually
- IP Address/Netmask/Gateway/Nameservers:
    see HOST DETAILS section above
- Hostname: newserverX.tracks4africa.net
- Full name for the new user: Ubuntu
- Username for your account: ubuntu
- Choose a password: any temporary password (remember it)
- Encrypt your home directory: no
- Time zone: Africa/Johannesburg
- Partitioning method: Guided - use entire disk - NOT LVM
- Select disk to partition: Virtual disk 1 (vda)
- Write the changes to disk: yes
- HTTP proxy: leave blank
- How to manage upgrades on this system: No automatic updates
  - Automated updates/upgrades will be configured by Ansible
- Choose software to install:
  - OpenSSH Server
- Install GRUB to the master boot record: yes
- Installation complete: reboot


NOTES ON DEBIAN INSTALLATION
============================

- Language: English
- Country: South Africa
- Keymap: American English
- Configure network manually
- IP address/netmask/gateway/nameservers:
    see HOST DETAILS section above
- Hostname: xxx.tracks4africa.net
- Root password: any temporary password
- Full name for new user: Debian
- Username: debian
- Password: any temporary password
- Partitioning method: Guided - use entire disk - NOT LVM
- Disk to partition: Virtual disk 1 (vda)
- Partitioning scheme: all files in one partition
- Finish and apply changes
- Write the changes to disk: yes
- Debian archive mirror country: South Africa
- Debian archive mirror: cdn.debian.net
- HTTP proxy: leave blank
- Participate in the package usage survey: no
- Choose software to install:
  - SSH server
  - Standard system utilities
- Install GRUB to the master boot record: yes
- Installation complete: reboot


GENERATING PASSWORD HASHES FOR USER ACCOUNTS
============================================

The included `mkpasswd` script generates salted SHA-512 hashes suitable for use
when setting passwords for user accounts using the Ansible user module. This
module is used extensively wherever system users are created or managed.

Usage example: `./mkpasswd mynewpassword`
