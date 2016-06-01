#!/bin/bash
(
#######################################
# Auto Install Configuration options
# (set it, forget it, run it)
#######################################

##################################################################
# check to confirm running as root. # First, we need to be root...
##################################################################
if [ "$(id -u)" -ne "0" ]; then
  sudo -p "$(basename "$0") must be run as root, please enter your sudo password : " "$0" "$@"
  exit 0
fi
echo
echo "Looks Like you are root.... continuing!"
echo

###############################################
#if lsb_release is not installed it installs it
###############################################
if [ ! -s /usr/bin/lsb_release ]; then
	apt-get update && apt-get -y install lsb-release
fi

#################
# Os/Distro Check
#################
lsb_release -c |grep -i jessie &> /dev/null 2>&1
if [ $? -eq 0 ]; then
	echo " OK you are running Debian 8 : Jessie "
else
	echo " This script was written for Debian 8 Jessie "
	echo
	echo " Your OS appears to be: " lsb_release -a
	echo
	echo " Your OS is not currently supported by this script ... "
	echo
	echo " Exiting the install. "
	exit
fi

###########################################
# Run a OS and Platform compatabilty Check
###########################################
########
# ARMEL
########
case $(uname -m) in armv[4-5]l)
echo
echo " ArmEL is currenty UnSupported "
echo
exit
esac

########
# ARMHF
########
case $(uname -m) in armv[6-9]l)
echo
echo " ArmHF arm v7 v8 v9 boards supported "
echo
esac

#############
# Intel/AMD
#############
case $(uname -m) in x86_64|i[4-6]86)
echo
echo " Intel / Amd boards currently UnSupported"
echo
exit
esac

#####################################
#Update base os with new repo in list
#####################################
apt-get update

###############################################################################################
#Testing for internet connection. Pulled from and modified
#http://www.linuxscrew.com/2009/04/02/tiny-bash-scripts-check-internet-connection-availability/
###############################################################################################
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


#####################
#ModProbe moules
####################
modprobe w1-gpio
modprobe w1-therm

######################
# Enable the spi & i2c
######################
echo "w1-gpio" >> /etc/modules
echo "w1-therm" >> /etc/modules

##############################
#Set a reboot if Kernel Panic
##############################
cat > /etc/sysctl.conf << DELIM
kernel.panic = 10
DELIM

################################################################################################
# Setting apt_get to use the httpredirecter to get
# To have <APT> automatically select a mirror close to you, use the Geo-ip redirector in your
# sources.list "deb http://httpredir.debian.org/debian/ jessie main".
# See http://httpredir.debian.org/ for more information.  The redirector uses HTTP 302 redirects
# not dnS to serve content so is safe to use with Google dnS.
# See also <which httpredir.debian.org>.  This service is identical to http.debian.net.
#################################################################################################
cat > "/etc/apt/sources.list" << DELIM
deb http://httpredir.debian.org/debian/ jessie main contrib non-free
deb-src http://httpredir.debian.org/debian/ jessie main contrib non-free
deb http://httpredir.debian.org/debian/ jessie-updates main contrib non-free
deb-src http://httpredir.debian.org/debian/ jessie-updates main contrib non-free
deb http://httpredir.debian.org/debian/ jessie-backports main contrib non-free
deb-src http://httpredir.debian.org/debian/ jessie-backports main contrib non-free

DELIM

############
# Pine64 Repo
###########################################################################
# Put in Proper Location. All addon repos should be source.list.d sub dir
###########################################################################
cat > /etc/apt/sources.list.d/pine64.list << DELIM

DELIM

#############################
# SvxLink Release Repo ArmHF
#############################
cat > "/etc/apt/sources.list.d/svxlink.list" <<DELIM
deb http://repo.openrepeater.com/svxlink/release/debian/ jessie main
DELIM

#############################
# Wiringpi Release Repo ArmHF
#############################
cat > "/etc/apt/sources.list.d/wiringpi.list" <<DELIM
deb http://repo.openrepeater.com/wiringpi/release/debian/ jessie main
DELIM

######################
#Update base os
######################
for i in update upgrade clean ;do apt-get -y "${i}" ; done

##########################
#Installing svxlink Deps
##########################
apt-get install -y --force-yes  sqlite3 libopus0 alsa-utils vorbis-tools sox libsox-fmt-mp3 librtlsdr0 \
		ntp libasound2 libspeex1 libgcrypt20 libpopt0 libgsm1 tcl8.6 tk8.6 alsa-base bzip2 \
		sudo gpsd gpsd-clients flite wvdial inetutils-syslogd screen time uuid vim install-info \
		usbutils whiptail dialog logrotate cron gawk watchdog python3-serial network-manager \
		git-core wiringpi python-pip libsigc++-2.0-0c2a libhamlib2 libhamlib2++c2 libhamlib2-perl \
		libhamlib-utils libhamlib-doc libhamlib2-tcl python-libhamlib2 fail2ban hostapd resolvconf \
		libasound2-plugin-equal watchdog i2c-tools python-configobj python-cheetah python-imaging \
		python-serial python-usb python-dev python-pip
		
		pip install spidev

#################
#install weewex
#################
wget http://weewx.com/downloads/weewx_3.5.0-1_all.deb && dpkg -i weewx_3.5.0-1_all.deb && rm weewx_3.5.0-1_all.deb

#####################
# edit
#/usr/bin/wee_device
#####################
sed -i /usr/bin/wee_device -e "s#print 'Using configuration file %s' % config_fn#\# print 'Using configuration file %s' % config_fn#"
sed -i /usr/bin/wee_device -e "s#print 'Using %s driver version %s (%s)' % (#\#print 'Using %s driver version %s (%s)' % (#"
sed -i /usr/bin/wee_device -e "s#driver_name, driver_vers, driver)#\#driver_name, driver_vers, driver)#")#"

#################
#Install svxlink
#################
apt-get -y --force-yes install svxlink-server remotetrx

#cleanup
apt-get clean

#adding user svxlink to gpio user group
usermod -a -G gpio svxlink

##############################
#Install Courtesy Sound Files
##############################
wget --no-check-certificate http://github.com/kb3vgw/Svxlink-Courtesy_Tones/archive/15.10.2.tar.gz
tar xzvf 15.10.2.tar.gz
mv Svxlink-Courtesy_Tones-15.10.2/Courtesy_Tones /usr/share/svxlink/sounds
rm -rf Svxlink-Courtesy_Tones-15.10.2 15.10.2.tar.gz

#################################
# Make and link Local event.d dir
# based on how Tobias says to in 
# manual/web site.
#################################
mkdir /etc/svxlink/local-events.d
ln -s /etc/svxlink/local-events.d /usr/share/svxlink/events.d/local

###########################
#Get Custom Files
###########################
git clone https://github.com/kb3vgw/SVXLink-Custom.git

###########################
#Install Custom Config File
###########################
cp -r SVXLink-Custom/svxlink-config/svxlink.conf /etc/svxlink/

###########################
#Install Custom Logic Files
###########################
cp -rp SVXLink-Custom/Custom-Logic/* /etc/svxlink/local-events.d

############################
#Board Test Scripts
############################
chmod +x SVXLink-Custom/board-scripts/*
cp SVXLink-Custom/board-scripts/* /usr/bin

######################
#Remove SVXLink-Custom
######################
rm -rf SVXLink-Custom

############################################
#Backup Basic svxlink original config files
############################################
mkdir -p /usr/share/examples/svxlink/conf
cp -rp /etc/svxlink/* /usr/share/examples/svxlink/conf

###########################################################
#Disable onboard hdmi soundcard not used in openrepeater
#/boot/config.txt and /etc/modules
###########################################################
#/boot/config.txt
sed -i /boot/config.txt -e"s#dtparam=audio=on#\#dtparam=audio=on#"

#/etc/modules
sed -i /etc/modules -e"s#snd-bcm2835#\#snd-bcm2835#"

################################
#Set up usb sound for alsa mixer
################################
if ( ! `grep "snd-usb-audio" /etc/modules >/dev/null`) ; then
   echo "snd-usb-audio" >> /etc/modules
fi
FILE=/etc/modprobe.d/alsa-base.conf
sed "s/options snd-usb-audio index=-2/options snd-usb-audio index=0/" $FILE > ${FILE}.tmp
mv -f ${FILE}.tmp ${FILE}
if ( ! `grep "options snd-usb-audio nrpacks=1" ${FILE} > /dev/null` ) ; then
  echo "options snd-usb-audio nrpacks=1 index=0" >> ${FILE}
fi

######################
#Install svxlink Menu
#####################
git clone https://github.com/kb3vgw/arris-menu.git
chmod +x arris-menu/arris_config
cp -r arris-menu/arris_config /usr/bin
rm -rf arris-menu

##############################################
# Enable New shellmenu for logins  on enabled 
# for root and only if the file exist
##############################################
cat >> /root/.profile << DELIM

if [ -f /usr/bin/arris_config ]; then
        . /usr/bin/arris_config
fi

DELIM

#cat >> /~/.profile << DELIM

#if [ -f /usr/bin/arris_config ]; then
#        . /usr/bin/arris_config
#fi

#DELIM

#######################
#Enable Systemd Service
####################### 
echo " Enabling the Svxlink systemd Service Daemon "
systemctl enable svxlink.service

####################################
# Set fs to run in a tempfs ramdrive
####################################
cat >> /etc/fstab << DELIM
tmpfs /tmp  tmpfs nodev,nosuid,mode=1777  0 0
tmpfs /var/tmp  tmpfs nodev,nosuid,mode=1777  0 0
tmpfs /var/cache/apt/archives tmpfs   size=100M,defaults,noexec,nosuid,nodev,mode=0755 0 0
DELIM

############################################
#reboot sysem for all changes to take effect
############################################
echo " rebooting system for full changes to take effect "
reboot

if [ install_irlp == "Y" ]; then
#!/bin/bash

# This script downloads all the IRLP install files and starts them from
# /root for the user. This script is located in the initrd of the 
# install CD.

# Added Oct 3, 2012 - Adding support for Debian installs
# Added Jan 2, 2013 - Added support for Raspberry Pi installs
# Added Nov 4, 2015 - Added changes that ver4 kernel changed
# Added Jan 17, 2016 - Added support for Debian Jessie (ver 8)
# Added Jan 21, 2016 - Remkoved support for Pi installs on anything but Jessie

# Make sure we are user root!!!
if [ "`whoami`" != "root" ] ; then
  echo "This program must be run as user ROOT!"
  exit 1
fi

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
elif (grep -q "7." /etc/debian_version) ; then
  DEBIAN_VERSION=7
elif (grep -q "6." /etc/debian_version) ; then
  DEBIAN_VERSION=6
else
  DEBIAN_VERSION=UNSUPPORTED
fi

########### START DEBIAN ###########
# This is a Debian setup/cleanup/install script for IRLP

clear

echo "This script is required in order to prepare your Debian $DEBIAN_VERSION"
echo "system to run IRLP. It is very agressive, and can take up to an"
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

# Updates the apt database to the latest packages
echo
echo -n "Updating the apt-get software repository database ... "
  apt-get -qq update >/dev/null 2>&1
echo "[ DONE ]"

# Ask user if they want to perform an update to the filesystem now. This will take some time
# but it will make sure the user starts with the latest and greatest software.

echo
echo "**** DEBIAN LINUX SOFTWARE UPDATE ****"
echo "Would you like to perform a software update to ensure this system is running"
echo "the latest versions of the software packages installed? This process will take"
echo "a few minutes, but is recommended as a lot can change between when the software"
echo "image was written and when you perform this install."
echo
echo -n "Press ENTER to continue, or type n to skip : " ; read CHOOSE

if [ "$CHOOSE" = "n" ] || [ "$CHOOSE" = "N" ] ; then
  echo "Skipping software update"
else
  echo -n "Updating installed software packages (~5 mins) ... "
  apt-get -y -qq upgrade
  echo "[ DONE ]"
fi

# Clean up script for Raspberry Pi only!
# Configs USB, flags in the environment file, etc.
# Jan 21, 2016 - Made it only work on the Jessie images.
# There is no easy way to make it work on both Jessie and Wheezy now

if [ "$IRLP_ARM" = "YES" ] ; then

  echo -n "Pi - Configuring the system to use USB sound and ALSA/OSS ... "
    # Removes the snd_bcm2835 sound device (onboard) by adding the module to a blacklist
    # file. This prevents the onboard sound from starting

    echo "blacklist snd-bcm2835" > /etc/modprobe.d/alsa-blacklist.conf

    # Change this to set the USB sound card as the first device and
    # adds the nrpacks=1 options (studder sound)

    echo "options snd-usb-audio index=0 nrpacks=1" > /etc/modprobe.d/aliases.conf

  echo "[ DONE ]"

  # Installs and configures a watchdog timer (experimental)
  # FUTURE

  echo -n "Pi - Removing the swap partition ... "
    # Turns off the swap and removes the swap daemon and swap file
    swapoff /var/swap >/dev/null 2>&1
    update-rc.d dphys-swapfile disable >/dev/null 2>&1
    apt-get -y -qq purge dphys-swapfile >/dev/null 2>&1
    rm -f /var/swap
  echo "[ DONE ]"

fi

## END Pi updates

# Installs required packages:
# Consider removing aumix (2015-11-04)
echo -n "Installing packages needed for IRLP to run (~5 mins) ... "
  apt-get -y -qq install ncftp rsync ntp openssh-server \
                         lynx rdate sox wget alsa-oss curl alsa-utils \
                         netcat sed gawk mlocate less busybox ftp bzip2 \
                         telnet host dnsutils psmisc pppoeconf \
                         alsa-base wicd-curses >/dev/null 2>&1
echo "[ DONE ]"

# removes exim, portmap, rpc, mpt-status
echo -n "Removing extra packages not required for IRLP ... "
  apt-get -y -qq autoremove mpt-status portmap exim4-base nfs-common \
                            >/dev/null 2>&1
echo "[ DONE ]"

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

########### END DEBIAN ###########

# Updates the mlocate database (common)
echo -n "Updating the mlocate database ... "
updatedb
echo done.

fi

) | tee /~/install.log