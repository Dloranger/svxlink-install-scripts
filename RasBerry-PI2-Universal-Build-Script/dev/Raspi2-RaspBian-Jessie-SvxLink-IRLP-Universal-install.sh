#!/bin/bash
(

# check to confirm running as root. # First, we need to be root...
if [ "$(id -u)" -ne "0" ]; then
  sudo -p "$(basename "$0") must be run as root, please enter your sudo password : " "$0" "$@"
  exit 0
fi
echo
echo "Looks Like you are root.... continuing!"
echo

# Detects ARM devices, and sets a flag for later use
if (cat /proc/cpuinfo | grep ARM >/dev/null) ; then
  IRLP_ARM=YES
fi

# Debian Systems

if [ -f /etc/debian_version ] ; then
  OS=Debian
else
  OS=Unknown
fi

# Prepare debian systems for the installation process
if [ "$OS" = "Debian" ] ; then

# Jan 17, 2016
# Detect the version of Debian, and do some custom work for different versions

if (grep -q "8." /etc/debian_version) ; then
  DEBIAN_VERSION=8
else
  DEBIAN_VERSION=UNSUPPORTED
fi

# This is a Debian setup/cleanup/install script for IRLP

clear

echo "This script is required in order to prepare your Debian $DEBIAN_VERSION"
echo "system to run SVXLink & IRLP. It is very agressive, and can take up to an"
echo "hour to complete. Please be patient."
echo
echo "WARNING - DO NOT RUN this script on an EXISTING install!"
echo "The results are unpredictable, as it will autoremove some packages"
echo "that may harm existing files/setups."
echo
echo "If you are proficient in Linux, you should view this script in detail"
echo "before running it."
echo
echo -n "Press ENTER to continue, or CTRL-C to exit : " ; read ENTER

if [ "$IRLP_ARM" = "YES" ] && [ "$DEBIAN_VERSION" != "8" ] ; then 
  echo
  echo "**** ERROR ****"
  echo "This script will only work on Debian Jessie Lite images at this time."
  echo "No other version of Debian is supported at this time. If you require"
  echo "assistance finding the right image, please refer to the IRLP wiki at"
  echo "http://wiki.irlp.net or the directions for installing on a Pi system"
  echo "at http://www.irlp.net/pi/"
  echo "**** EXITING ****"
  exit -1
fi

#Update base os with new repo in list
apt-get update

#Testing for internet connection
echo
echo "This Script Currently Requires a internet connection "
echo
wget -q --tries=10 --timeout=5 http://www.google.com -O /tmp/index.google &> /dev/null

if [ ! -s /tmp/index.google ];then
	echo "No Internet connection. Please check ethernet cable"
	/bin/rm /tmp/index.google
	exit 1
else
	echo "I Found the Internet ... continuing!!!!!"
	/bin/rm /tmp/index.google
fi
echo
printf ' Current ip is : '; ip -f inet addr show dev eth0 | sed -n 's/^ *inet *\([.0-9]*\).*/\1/p'
echo

#ModProbe moules
modprobe w1-gpio
modprobe w1-therm

# Enable the spi & i2c
echo "#snd-bcm2835" >> /etc/modules
echo "i2c-dev" >> /etc/modules
echo "spi-bcm2708" >> /etc/modules
echo "w1-gpio" >> /etc/modules
echo "w1-therm" >> /etc/modules

#Set a reboot if Kernel Panic
cat > /etc/sysctl.conf << DELIM
kernel.panic = 10
DELIM

#edit /boot/config.txt
# Uncomment some or all of these to enable the optional hardware interfaces
sed -i /boot/config.txt -e"s#\#dtparam=i2c_arm=on#dtparam=i2c_arm=on#"
sed -i /boot/config.txt -e"s#\#dtparam=i2s=on#dtparam=i2s=on#"
sed -i /boot/config.txt -e"s#\#dtparam=spi=on#dtparam=spi=on#"

# set usb power level
cat >> /boot/config.txt << DELIM

#usb max current
usb_max_current=1

#enable 1wire onboard temp
dtoverlay=w1-gpio,gpiopin=4
DELIM

# Disable the dphys swap file # Extend life of sd card
swapoff --all
update-rc.d dphys-swapfile disable
apt-get -y remove dphys-swapfile
apt-get -y -qq purge dphys-swapfile
rm -rf /var/swap

# Setting apt_get to use the httpredirecter to get
# To have <APT> automatically select a mirror close to you, use the Geo-ip redirector in your
# sources.list "deb http://httpredir.debian.org/debian/ jessie main".
# See http://httpredir.debian.org/ for more information.  The redirector uses HTTP 302 redirects
# not dnS to serve content so is safe to use with Google dnS.
# See also <which httpredir.debian.org>.  This service is identical to http.debian.net.
cat > "/etc/apt/sources.list" << DELIM
deb http://httpredir.debian.org/debian/ jessie main contrib non-free
deb-src http://httpredir.debian.org/debian/ jessie main contrib non-free

deb http://httpredir.debian.org/debian/ jessie-updates main contrib non-free
deb-src http://httpredir.debian.org/debian/ jessie-updates main contrib non-free

deb http://httpredir.debian.org/debian/ jessie-backports main contrib non-free
deb-src http://httpredir.debian.org/debian/ jessie-backports main contrib non-free
DELIM

# Raspi Repo Put in Proper Location. All addon repos should be source.list.d sub dir
cat > /etc/apt/sources.list.d/raspi.list << DELIM
deb http://mirrordirector.raspbian.org/raspbian/ jessie main contrib firmware non-free rpi
DELIM

# SvxLink Release Repo ArmHF
cat > "/etc/apt/sources.list.d/svxlink.list" <<DELIM
deb http://repo.openrepeater.com/svxlink/release/debian/ jessie main
DELIM

# Wiringpi Release Repo ArmHF
cat > "/etc/apt/sources.list.d/wiringpi.list" <<DELIM
deb http://repo.openrepeater.com/wiringpi/release/debian/ jessie mainDELIM

#Update base os
for i in update upgrade clean ;do apt-get -y "${i}" ; done

# Installs Dep required packages:
apt-get install -y --force-yes sqlite3 libopus0 alsa-utils vorbis-tools sox libsox-fmt-mp3 librtlsdr0 \
		ntp libasound2 libspeex1 libgcrypt20 libpopt0 libgsm1 tcl8.6 tk8.6 alsa-base bzip2 \
		sudo gpsd gpsd-clients flite wvdial inetutils-syslogd screen time uuid vim install-info \
		usbutils whiptail dialog logrotate cron gawk watchdog python3-serial network-manager \
		git-core wiringpi python-pip libsigc++-2.0-0c2a libhamlib2 libhamlib2++c2 libhamlib2-perl \
		libhamlib-utils libhamlib-doc libhamlib2-tcl python-libhamlib2 fail2ban hostapd resolvconf \
		libasound2-plugin-equal watchdog i2c-tools python-configobj python-cheetah python-imaging \
		python-serial python-usb python-dev python-pip fswebcam ncftp rsync ntp openssh-server \
		lynx rdate sox wget alsa-oss curl netcat sed gawk mlocate less busybox ftp telnet host \
		dnsutils psmisc pppoeconf wicd-curses 

# install spidev
pip install spidev

#cleanup
apt-get clean

#Install svxlink
apt-get -y --force-yes install svxlink-server remotetrx

#cleanup
apt-get clean

#adding user svxlink to gpio user group
usermod -a -G gpio svxlink

#Install Courtesy Sound Files
wget --no-check-certificate http://github.com/kb3vgw/Svxlink-Courtesy_Tones/archive/15.10.2.tar.gz
tar xzvf 15.10.2.tar.gz
mv Svxlink-Courtesy_Tones-15.10.2/Courtesy_Tones /usr/share/svxlink/sounds
rm -rf Svxlink-Courtesy_Tones-15.10.2 15.10.2.tar.gz

# Make and link Local event.d dir based on how Tobias says to in manual/web site.
mkdir /etc/svxlink/local-events.d
ln -s /etc/svxlink/local-events.d /usr/share/svxlink/events.d/local

# Clone Source
git clone https://github.com/kb3vgw/SVXLink-Custom.git

#install sa818/dra818 programmer
chmod +x SVXLink-Custom/818-programming/src/*
cp -rp SVXLink-Custom/818-programming/src/* /usr/bin

#Board Test Scripts
chmod +x SVXLink-Custom/board-test-scripts/*
cp -rp SVXLink-Custom/board-test-scripts/* /usr/bin

#update executabe apps
chmod +x SVXLink-Custom/exec-apps/*
cp SVXLink-Custom/exec-apps/* /usr/bin

#Update SVXCard Menu
chmod +x  SVXLink-Custom/SVXCard-Menu/SVXCard-Pi-Config
cp -r SVXLink-Custom/SVXCard-Menu/SVXCard-Pi-Config /usr/bin

cat > /root/.profile << DELIM
if [ -f /usr/bin/SVXCard-Pi-Config ]; then
        . /usr/bin/SVXCard-Pi-Config
fi
DELIM

#svxcard svxlink config
cp -rp SVXLink-Custom/SVXCard-svxlink-config/svxlink.conf /etc/svxlink

#install svxcard python menu
#cp -r SVXLink-Custom/SVXCard /etc/svxlink/local-events.d/

#install update script
chmod +x SVXLink-Custom/update/update-svxcard.sh
cp -rp SVXLink-Custom/update/update-svxcard.sh /usr/bin

#Remove SVXLink-Custom
rm -rf SVXLink-Custom

#Disable onboard hdmi soundcard not used in openrepeater
#/boot/config.txt and /etc/modules
sed -i /boot/config.txt -e"s#dtparam=audio=on#\#dtparam=audio=on#"

#/etc/modules
sed -i /etc/modules -e"s#snd-bcm2835#\#snd-bcm2835#"

#Set up usb sound for alsa mixer
if ( ! `grep "snd-usb-audio" /etc/modules >/dev/null`) ; then
   echo "snd-usb-audio" >> /etc/modules
fi
FILE=/etc/modprobe.d/alsa-base.conf
sed "s/options snd-usb-audio index=-2/options snd-usb-audio index=0/" $FILE > ${FILE}.tmp
mv -f ${FILE}.tmp ${FILE}
if ( ! `grep "options snd-usb-audio nrpacks=1" ${FILE} > /dev/null` ) ; then
  echo "options snd-usb-audio nrpacks=1 index=0" >> ${FILE}
fi

#Enable Systemd Service
echo " Enabling the Svxlink systemd Service Daemon "
systemctl enable svxlink.service

# Set fs to run in a tempfs ramdrive
cat >> /etc/fstab << DELIM
tmpfs /tmp  tmpfs nodev,nosuid,mode=1777  0 0
tmpfs /var/tmp  tmpfs nodev,nosuid,mode=1777  0 0
tmpfs /var/cache/apt/archives tmpfs   size=100M,defaults,noexec,nosuid,nodev,mode=0755 0 0
DELIM

#IRLP Install

clear

apt-get clean

if [ "$IRLP_ARM" = "YES" ] ; then

# 2016-02-02 - Temporary fix to ensure that the OSS sound modules are loaded. For some
# reason, the modules are not loading at boot in Debian

# Modifies the /etc/modules file to include the OSS PCM and mixer modules.
# CHECK IF IT IS DONE ALREADY!

if ! (grep -q snd-pcm-oss /etc/modules >/dev/null) ; then
  echo "snd-pcm-oss" >> /etc/modules
fi

if ! (grep -q snd-mixer-oss /etc/modules >/dev/null) ; then
  echo "snd-mixer-oss" >> /etc/modules
fi

modprobe -q snd-pcm-oss
modprobe -q snd-mixer-oss

# Creates a symlink to use busybox for usleep.
ln -s /bin/busybox /usr/bin/usleep >/dev/null 2>&1

# Creates a timeconfig script that points to the dpkg-reconfigure tzdata, rdate, and hwclock
# Creates the dummy "yum" script to help with transition to apt-get
# Copies the timeconfig script from the Debian utilities for IRLP
ncftpget ftp.irlp.net /usr/bin \
	/pub/debian/scripts/aumix \
	/pub/debian/scripts/yum \
	/pub/debian/scripts/timeconfig \
	/pub/debian/scripts/sndconfig \
	/pub/debian/scripts/netconfig \
	/pub/debian/scripts/soundtest.wav

chmod +x /usr/bin/aumix
chmod +x /usr/bin/timeconfig
chmod +x /usr/bin/sndconfig
chmod +x /usr/bin/netconfig
chmod +x /usr/bin/yum

# Links alsaconf and sndconfig to the alsactl init script, and still plays the test audio file.
ln -s /usr/bin/sndconfig /usr/bin/alsaconf >/dev/null 2>&1

# Disables IPv6 by default (2015-11-04)
echo net.ipv6.conf.all.disable_ipv6=1 > /etc/sysctl.d/disableipv6.conf

# Changes alsactl so it can be run by users other than root without sudo
# (2015-11-04)
ln -s /usr/sbin/alsactl /usr/bin/alsactl
chmod 4755 /usr/sbin/alsactl

# Modifies the /etc/issue files to include info to ID this as an IRLP node
# CHECK IF IT IS DONE ALREADY!
if ! (grep Linking /etc/issue >/dev/null) ; then
  echo "Internet Radio Linking Project Version" >> /etc/issue
  echo "Internet Radio Linking Project Version" >> /etc/issue.net
fi

# Removes the attempt by aumix to reload mixer settings at boot (and the associated error)
update-rc.d -f aumix remove

# Allows the rc.local script to be run automatically at boot
update-rc.d rc.local enable

# Changes the first line of rc.local so it does not stop on errors
# (2105-11-04)
FILE=/etc/rc.local
sed "s/sh -e/sh/" $FILE > ${FILE}.tmp
mv -f ${FILE}.tmp ${FILE}

# Updates the date/time, and starts ntp
echo -n "Obtaining IP address of IRLP.net from DNS ... "
HOST_IP=`host -t A irlp.net | cut -d" " -f4`

if [ ${#HOST_IP} -lt 8 ] ; then
  HOST_IP=208.67.255.162
  echo "FAILED. Using $HOST_IP"
else
  echo "OK."
  # This assumes the internet is here, and does an automated
  # update of the system clock from ntp.ubc.ca, so that the time
  # if going to be partially right
  echo "Setting local clock ... "
  /etc/init.d/ntp stop
  rdate -s $HOST_IP
  if [ "$IRLP_ARM" != "YES" ] ; then
    hwclock --systohc
  fi
  /etc/init.d/ntp start
  echo "done."
fi

# Added 2016-01-17 to allow remote root logins on Debian 8 systems (disabled by default)
if [ "$DEBIAN_VERSION" = "8" ] ; then
  FILE=/etc/ssh/sshd_config
  sed "s/PermitRootLogin without-password/PermitRootLogin yes/" $FILE > ${FILE}.tmp
  mv -f ${FILE}.tmp ${FILE}
fi

# Added 2016-01-17 if the wicd manager-settings.conf does not have wlan0, this adds it
if ! (grep -q wlan0 /etc/wicd/manager-settings.conf) ; then
  FILE=/etc/wicd/manager-settings.conf
  sed "s/wireless_interface = None/wireless_interface = wlan0/" $FILE > ${FILE}.tmp
  mv -f ${FILE}.tmp ${FILE}
fi

# Added 2016-01-17 Removes the annoying udev generator for network interfaces
# This is for all Debian versions
touch /etc/udev/rules.d/75-persistent-net-generator.rules
rm -f  /etc/udev/rules.d/70-persistent-net.rules

cd /root
rm -fr irlp*install*

ncftpget $HOST_IP ./ /pub/debian/irlp-install-debian /pub/debian/irlp-reinstall-debian

if [ -f /root/irlp-install-debian ] && [ -f /root/irlp-reinstall-debian ] ; then
  chmod 755 /root/irlp*install-debian
  while [ -z $CHOICE ] ; do
    echo
    echo "Files downloaded successfully. Please choose which to perform:"
    echo "--------------------------------------------------------------"
    echo "1) New install"
    echo "2) Re-install from backup"
    echo
    echo -n "Choice : " ; read CHOICE
    if [ "$CHOICE" = "1" ] ; then
      /root/irlp-install-debian
      exit
    fi
    if [ "$CHOICE" = "2" ] ; then
      /root/irlp-reinstall-debian
      exit
    fi
    CHOICE=""
  done
else
  echo
  echo "There is a problem with downloading the install files. This can"
  echo "be caused by a problem with your connection to the internet. Please"
  echo "contact installs@irlp.net by email, and describe your problem."
fi

# Updates the mlocate database (common)
echo -n "Updating the mlocate database ... "
updatedb
echo done.

#reboot sysem for all changes to take effect
echo " rebooting system for full changes to take effect "
reboot

) | tee ~/install.log