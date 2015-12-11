Use this base Debian Jessie image:

OFFICIAL RASPBIAN JESSIE LITE (NO X)
https://downloads.raspberrypi.org/raspbian_lite_latest

####Procedure:
- Download Raspbian Jessie Lite Image (link above).
- Write Raspbian Jessie Lite image to SD Card.
- Insert SD card into RPI, Connect Network, connect sound card, and Power to Pi
- Obtain Dynamic IP Address
- Connect to Pi using SSH.  Login as pi (password raspberry).
- sudo su to root
- Execute "apt-get update && apt-get dist-upgrade"
- Use raspi-config to configure Timezone, Locale, Check GPU Mem(0), and Expand FS
- Reboot Pi.
- Connect to Pi using SSH.  Login as pi (password raspberry).
- sudo su to root
- Transfer ORP install_script to Pi.  (wget or scp or flashdrive)
- Edit SvxLink install_script (nano install_script).   Set Callsign.
- Change permissions on install_script (chmod +x install_script)
- Execute install_script ( ./install_script )
- Perform final tasks.... 
- Reboot

