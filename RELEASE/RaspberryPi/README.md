Use this base Debian Jessie image:

OFFICIAL RASPBIAN JESSIE LITE (NO X)
https://downloads.raspberrypi.org/raspbian_lite_latest

####Procedure:
- Download Raspbian Jessie Lite Image (link above).
- Write Raspbian Jessie Lite image to SD Card.
- Insert SD card into RPI, Connect Network, connect sound card, and Power to Pi
- Obtain Dynamic IP Address
- Connect to Pi using SSH.  Login as pi (password raspberry).
- "sudo su" to root
- Execute "apt-get update && apt-get dist-upgrade"
- Use "raspi-config" to configure Timezone, Locale, Check GPU Mem(0), and Expand FS
- enable the following kernel modules spi-bcm2708 i2c-bcm2708 i2c-dev w1-gpio w1-therm
- Reboot Pi.
- Connect to Pi using SSH.  Login as pi (password raspberry).
- "sudo su" to root
- Transfer svxlink install_script to Pi.  (download, wget, scp or flashdrive)
- wget https://raw.githubusercontent.com/kb3vgw/svxlink-scripts/master/RELEASE/RaspberryPi/Raspi2-RaspBian-Jessie-SvxLink-Release-embedded-pkg-install.sh
- Edit SvxLink install_script (nano install_script). Set Callsign. CS="Set-This"
- Change permissions on install_script (chmod +x install_script)
- Execute install_script ( ./install_script )
- Automatic Reboot

