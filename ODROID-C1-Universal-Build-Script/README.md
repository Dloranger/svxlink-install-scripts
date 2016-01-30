Use this base Debian Jessie image: 

http://repo.openrepeater.com/odroid-imgs/odroid-c1-jessie-minimal.img.xz

####Procedure:
- Write odroid-c1-jessie-minimal.img to SD Card or emmc.
- Connect emmc to socket on board or incert sd into sd slot.
- Connect Network, and Power to C1/C1+
- Boot C1/C1+.   
- Connect to C1/C1+ using SSH.  Login as root (password odroid).
- Resize the filesystem to full sd size "fs-resize"
- ReConnect to C1/C1+ using SSH.  Login as root (password odroid)
- Upgrade Base pkgs "apt-get update && apt-get dist-upgrade"
- Upgrade kernel "apt-get install linux-image-c1"
- Transfer SvxLink install_script to C1/C1+  (Download, wget, scp or flashdrive)
- Edit SvxLink install_script (nano HardKernel-Odroid-Jessie-SvxLink-Release-embedded-pkg-install-english). 
- Set Callsign. " cs="Set-This" " save 
- Change permissions on install_script (chmod +x HardKernel-Odroid-Jessie-SvxLink-Release-embedded-pkg-install-english)
- Execute install_script ( ./HardKernel-Odroid-Jessie-SvxLink-Release-embedded-pkg-install-english )
...


