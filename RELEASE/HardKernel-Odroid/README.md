Use this base Debian Jessie image: 

http://repo.openrepeater.com/odroid-imgs/odroid-c1-jessie-minimal.img.xz

####Procedure:
- Write odroid-c1-jessie-minimal.img to SD Card.
- Connect Network, and Power to C1/C1+
- Boot C1/C1+.   
- Connect to C1/C1+ using SSH.  Login as root (password odroid).
- Execute "apt-get update && apt-get dist-upgrade"
- Transfer SvxLink install_script to C1/C1+  (wget or scp or flashdrive)
- Edit SvxLink install_script (nano install_script). Set Callsign.
- Change permissions on install_script (chmod +x install_script)
- Execute install_script ( ./install_script )
- Perform final tasks...
reboot
...


