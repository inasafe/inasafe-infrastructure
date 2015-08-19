
# Proxmox setup

ProxMox have been used as the hypervisor for the VMs for this system.


## Proxmox installation on Hetzner.de

Hetzner.de's wiki have a page [http://wiki.hetzner.de/index.php/Proxmox_VE/en](http://wiki.hetzner.de/index.php/Proxmox_VE/en)
 explaning how to install ProxMox from a clean Debian installation.

However, during the time of this writing, there was another easier process:

1. boot server into the **Rescue** system (Linux 64bit), by activating it, and then issue a reset to the server via the [robot](https://robot.your-server.de/server) interface.
2. ssh as root with the passwd given when activating the Rescue system (Pinging the system to check when it responds, is a good indication when the ssh will succeed)
3. type in `installimage`
 * It'll bring up a choice of installation targets, got to: "Virtualzation" -> "Proxmox" (was Wheezy at time of writing, might be "Jessie" or later at time of reading/needing these instructions)
 * setup disks as follows:
 	* 	/boot - MDRAID (mirror RAID1) partition (About 512MB is enough)
 	*  REST - MDRAID RAID1 -> LVM2 (vg_proxmox1)
 	*  / - 20GB LVM2 Logical volume named: root
 	*  swap - 4GB LVM2 Logical volume named: swap
 * Run installation.
 * After installation, system will reboot and the root user's password will be the above mentioend Rescue system's root password.
4. Install `sshguard` with `apt-get isntall sshguard` -> Prevents and blocks remote brute force attacks
5. install ssh keys and users as need be, but preferably change the ssh password to something else.
6. From here on, the Hypervisor is managed via the webinterface available on `https://<IP-or-hostname>:8006`
  * root user with root's Linux password the simplest, but can add other users as need be using the PVE authentication and limiting to only some VMs etc.
  * The only "exception" is when downloading ISO images directly using the SSH CLI to `/var/lib/vz/template/iso`, more preferable when administrating this via ZA's ADSL infrastructure -> it's faster to download straight from the CLI than uploading from ADSL.
 
### Post install setups for Proxmox

Using the GUI on `http://<IP-or-hostname>:8006`

1. Add LVM2 storage named as `vg_proxmox1`:
	* Click on "Datacenter" on the left handlists
	* click on the top "Storage" tab
	* Click "Add" -> LVM
	* ID: vg_proxmox1
	* Volume group: vg_proxmox1 (The name from pull down menu you've used in the installation above)
2. Add the bridges
	* Click on the servername (Proxmox1) on the left hand side list
	* Click on the "Network" tab
	* Make notes of the eth0 IP address, netmask and gateway
	* Click on `eth0` and then click on "Edit"
		* remove all IP, netmask etc. information from `eth0` form.
		* Leave Autostart: **checked**
		* "OK"
	* "Create" Linux Bridge
		* Name: vmbr0
		* Autostart: checked
		* Bridge ports: eth0
		* IP Address/Netmask/Gateway: Fill in old `eth0` information
		* **DOUBLE CHECK**
		* "Create"
	* "Create" Linux Bridge
		* Name: vmbr100
		* Autostart: checked
		* *Rest is left empty*
		* "Create"
	* Double check settings
	* Reboot to apply changes (Hold thumbs everythings working, else you'll have to use the Rescue boot to fix things... reason I love Hetzner's root servers ;) )

You should now be able to do the next installations

## Installing the FireWall (pfSense)

1. In the Hetzner.de Robot's interface, got to the server's "IPs" tab, select the *EXTRA* IP requested, and **Request separate MAC** (If there is already a mac requested, then it'll bring op the request to cancel, in that case just record the MAC address)
	* This MAC will be used later for the `vmbr0` interface of the *firewall*

1. On the CLI of the firewall: 

```
cd /var/lib/vz/template/iso
wget http://files.nl.pfsense.org/mirror/downloads/pfSense-LiveCD-2.2.2-RELEASE-amd64.iso.gz
gunzip pfSense-LiveCD-2.2.2-RELEASE-amd64.iso.gz
chmod a+r pfSense-LiveCD-2.2.2-RELEASE-amd64.iso
```
Note: this is an old version, the place to get the current [pfSense](https://www.pfsense.org) is from their [download page](https://www.pfsense.org/download/mirror.php?section=downloads) going to 
  * Architecture: AMD64
  * Live CD with installer

2. On the GUI ie. `https://<ip-or-hostname>:8006`
  1. log in as root, Linux PAM authentication
  2. click on the "OK" button for the subscription service (Something to consider buying when the funds are there)
  3. click on `Create VM` (One of the top right hand corner buttons), and fill in the form as follows:
	    * General tab
	      * VM ID: 999 (HAs to be unique in cluster, but for FireWalls I prefer 999)
	      * Name: VFW1
		* OS Tab
		  * Other OS Types
	  * CD/DVD tab
		  * Use CD/DVD disc image file
		  * Storage: Local
		  * ISO Image: Select the pfSense-LiveCD-2.2.2-RELEASE.iso or the one downloaded above
	  * HArddisk tab
		  * BUS/Device: SATA
		  * Storage: vg_proxmox1
		  * DiskSize: 8GB
	  * CPU
		  * leave default
	  * Memory
		  * 512MB
	  * Network
		  * Model: VirtIO
		  * Bridge: vmbr0
		  * MAC address: **The Mac recorded above**
	  * Confirm
		  * Finish
  * Select the VFW1 in the left hand list (Might need to expand the "proxmox1" entry)
  * Click on "Hardware" tab
  * "Add" -> network device
	  * Model: VirtIO
	  * Bridge: vmbr100


3. on the top right, click on "Console" -> "**no**VNC" 
4. click on the power button of the pop-up window and select "Start"
	* FreeBSD should now boot.
	* *Be quick to type I for Installer*
		* "Accept these settings" for console
		* "Quick/Easy Install"
		* "OK to erase the harddisk"
		* "Standard kernel"
		* "Reboot"
5. Configure the WAN interface **only**
	* **DO NOT select a LAN interface YET** as the pfSense then automatically blocks the WAN interface's access unless you've added the needed rules.
	* set the WAN interface to em0
	* set the IP as per the Hetzner.de robot interface
	* select (3) reset the webConfigurator password.
* Logon to the web-UI with `https://<ip>/` using the webconfigurator password.
	* **Bypass the configuration**
	* go to "Diagnostics" => "Backup/Restore"
		* select the latest configuration in [Firewall](FireWall)
	* Will need to restart etc. to load the latest configuration
* The configuration as was saved by HendrikVisage, is a listening on `https://<ip>:4433`

## Installing/creating the first Ubuntu VM -> making it a template

On the proxmox CLI:
```
cd /var/lib/vz/template/iso
wget <ubuntu-*SERVER*.ISO>
```

Create a VM similar to the FireWall (pfSense) above, with the following settings:
  * Linux 3.x/2.6 kernel
  * CD/DVD setting as per the above UBUNTU-ISO
  * VIRTIO disk
  * Storage: vg_proxmox1
  * 20 GB HDD (Could be less, but a good mid way for a OS only disks)
  * 1024MB RAM
  * Bridge: `vmbr100`
  * VIRTIO Network model

 Continue installation ("noVNC" console, power, start)
   * select South Africa & English
   * Use Germany's ftp.de.debian.org for a software repository
   * user to create: ubuntu (Remember this password for future reference in bootstrap installations)
   * Guided - Use entire disk and setup LVM
   * OpenSSH server *only*
   * check you can login on the console
   * check the IP, and that you can connect to that (Check FW etc. for NAT mappings)

Shutdown the VM, and right clink on the VM in the list on the left hand side, and select "Convert to template"

## Setting up new VM


 