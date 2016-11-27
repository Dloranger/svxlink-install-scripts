#!/bin/bash
(
####################################################################
#
#   Svxlink Repeater Project
#
#    Copyright (C) <2015-2016>  <Richard Neese> kb3vgw@gmail.com
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.
#
#    If not, see <http://www.gnu.org/licenses/gpl-3.0.en.html>
#
####################################################################

##################################################################
# Check to confirm running as root. # First, we need to be root...
##################################################################
if [ "$(id -u)" -ne "0" ]; then
  sudo -p "$(basename "$0") must be run as root, please enter your sudo password : " "$0" "$@"
  exit 0
fi
echo "--------------------------------------------------------------"
echo "Looks Like you are root.... continuing!"
echo "--------------------------------------------------------------"

echo "reconfigure timezone"
dpkg-reconfigure tzdata

echo "reconfigure locale"
dpkg-reconfigure locales

############################################
# Request user input to ask for device type
############################################
echo ""
heading="What Arm Board?"
title="Please choose the device you are building on:"
prompt="Pick a Arm Board:"
options=("Raspberry_Pi_2" "Odroid_C1+" "Pine64" "Raspberry_Pi_3" "Odroid_C2" "CHIP")

echo "$heading"
echo "$title"
PS3="$prompt "
select opt1 in "${options[@]}" "Quit"; do
    case "$REPLY" in

    # RASPBERRY PI2 32bit
    1 ) echo ""; echo "Building for $opt1"; device_long_name="$opt1"; device_short_name="rpi2"; break;;

    # ODROID C1/C1+ 32bit
    2 ) echo ""; echo "Building for $opt1"; device_long_name="$opt1"; device_short_name="oc1+"; break;;

    # PINE64 64bit
    3 ) echo ""; echo "Building for $opt1"; device_long_name="$opt1"; device_short_name="pine64"; break;;

    # RASPBERRY PI3 64bit
    4 ) echo ""; echo "Building for $opt1"; device_long_name="$opt1"; device_short_name="rpi3"; break;;

    # ODROID-C2 64bit
    5 ) echo ""; echo "Building for $opt1"; device_long_name="$opt1"; device_short_name="oc2"; break;;

    # Chip  32bit
    6 ) echo ""; echo "Building for $opt1"; device_long_name="$opt1"; device_short_name="chip"; break;;
        
    # BBB  32bit
    7 ) echo ""; echo "Building for $opt1"; device_long_name="$opt1"; device_short_name="bbb"; break;;
    $(( ${#options[@]}+1 )) ) echo "Goodbye!"; exit;;
    *) echo "Invalid option. Try another one.";continue;;

    esac
done
echo ""
# check to confirm running as root. # First, we need to be root...
if [ "$(id -u)" -ne "0" ]; then
  sudo -p "$(basename "$0") must be run as root, please enter your sudo password : " "$0" "$@"
  exit 0
fi

echo "Looks Like you are root.... continuing!"

# Detects ARM devices, and sets a flag for later use
if (gerp -q "ARM" /proc/cpuinfo) ; then
  SVX_ARM=YES
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

if [ "$SVX_ARM" = "YES" ] && [ "$DEBIAN_VERSION" != "8" ] ; then
  echo
  echo "**** ERROR ****"
  echo "This script will only work on Debian Jessie Lite images at this time."
  echo "No other version of Debian is supported at this time. "
  echo "**** EXITING ****"
  exit -1
fi
fi

################################################################################################
# Testing for internet connection. Pulled from and modified
# http://www.linuxscrew.com/2009/04/02/tiny-bash-scripts-check-internet-connection-availability/
################################################################################################
echo "--------------------------------------------------------------"
echo "This Script Currently Requires a internet connection "
echo "--------------------------------------------------------------"
wget -q --tries=10 --timeout=5 http://www.google.com -O /tmp/index.google &> /dev/null

if [ ! -s /tmp/index.google ];then
	echo "No Internet connection. Please check ethernet cable"
	/bin/rm /tmp/index.google
	exit 1
else
	echo "I Found the Internet ... continuing!!!!!"
	/bin/rm /tmp/index.google
fi
echo "--------------------------------------------------------------"
printf ' Current ip is : '; ip -f inet addr show dev eth0 | sed -n 's/^ *inet *\([.0-9]*\).*/\1/p'
echo "--------------------------------------------------------------"
echo

##############################
# Set a reboot if Kernel Panic
##############################
cat >> /etc/sysctl.conf << DELIM
kernel.panic = 10
DELIM

#############################################
# Set Network Interface
#############################################
if [ $device_short_name == "rpi1" ] || [ $device_short_name == "rpi2" ] || [ $device_short_name == "pine64" ] ; then
cat > /etc/network/interfaces << DELIM
auto lo eth0
iface lo inet loopback
iface eth0 inet dhcp
DELIM
fi

#################################################################################################
# all boards
# Setting apt_get to use the httpredirecter to get
# To have <APT> automatically select a mirror close to you, use the Geo-ip redirector in your
# sources.list "deb http://httpredir.debian.org/debian/ jessie main".
# See http://httpredir.debian.org/ for more information.  The redirector uses HTTP 302 redirects
# not dnS to serve content so is safe to use with Google dnS.
# See also <which httpredir.debian.org>.  This service is identical to http.debian.net.
#################################################################################################
if [[ $device_short_name == "pine64" ]] || [[ $device_short_name == "rpi3" ]] || [[ $device_short_name == "rpi2" ]] ; then

cat > /etc/apt/sources.list << DELIM
deb http://httpredir.debian.org/debian/ jessie main contrib non-free
deb http://httpredir.debian.org/debian/ jessie-updates main contrib non-free
deb http://httpredir.debian.org/debian/ jessie-backports main contrib non-free
deb http://security.debian.org/ jessie/updates main contrib non-free
DELIM
fi

###########################################################################
# RASPBERRY PI ONLY:
# Raspi Repo
# Put in Proper Location. All addon repos should be source.list.d sub dir
###########################################################################
if [ $device_short_name == "rpi2" ] || [ $device_short_name == "rpi3" ] ; then
gpg --keyserver pgp.mit.edu --recv 8B48AD6246925553 
gpg --export --armor 8B48AD6246925553 | apt-key add -
gpg --keyserver pgp.mit.edu --recv  7638D0442B90D010
gpg --expor--armor  7638D0442B90D010 | apt-key add -
gpg --keyserver pgp.mit.edu --recv CBF8D6FD518E17E1
gpg --export --t armor CBF8D6FD518E17E1 | apt-key add -
wget https://www.raspberrypi.org/raspberrypi.gpg.key
gpg --import raspberrypi.gpg.key | apt-key add -
wget https://archive.raspbian.org/raspbian.public.key
gpg --import raspbian.public.key | apt-key add -
	
cat >/etc/apt/sources.list.d/raspian.list << DELIM
deb http://mirrordirector.raspbian.org/raspbian/ jessie main contrib firmware non-free rpi
DELIM
fi

#############################
# Svxlink Release Repo Arm64
#############################
if [[ $device_short_name == "pine64" ]] || [[ $device_short_name == "oc2" ]] ; then
cat > /etc/apt/sources.list.d/svxlink.list << DELIM
deb http://repo.openrepeater.com/svxlink/devel/debian/ jessie main
DELIM
fi

#############################
# Svxlink Release Repo ArmHF
#############################
if [[ $device_short_name == "rpi2" ]] || [[ $device_short_name == "oc1+" ]] || [[ $device_short_name == "rpi3" ]] || [[ $device_short_name == "chip" ]]  || [[ $device_short_name == "bbb" ]] ; then
cat > /etc/apt/sources.list.d/svxlink.list << DELIM
deb http://repo.openrepeater.com/svxlink/release/debian/ jessie main
DELIM
fi

##########################
# Adding OpenRepeater Repo arm64
##########################
if [[ $device_short_name == "pine64" ]] || [[ $device_short_name == "oc2" ]] ; then
cat > /etc/apt/sources.list.d/openrepeater.list << DELIM
deb http://repo.openrepeater.com/openrepeater/devel/debian/ jessie main
DELIM
fi

######################
# Update base OS
######################
for i in update upgrade clean ;do apt-get -y --force-yes "${i}" ; done


##########################
# Installing Dependencies
##########################
apt-get install -y --force-yes sqlite3 libopus0 alsa-utils vorbis-tools sox libsox-fmt-mp3 librtlsdr0 \
		ntp libasound2 libspeex1 libgcrypt20 libpopt0 libopus0 libgsm1 tcl8.6 tk8.6 alsa-base bzip2 \
		sudo gpsd gpsd-clients flite inetutils-syslogd uuid vim usbutils dialog logrotate cron gawk \
		watchdog network-manager libsigc++-2.0-0c2a libhamlib2 libhamlib2++c2 libasound2-plugin-equal \
		watchdog i2c-tools python-configobj python-cheetah python-imaging python-serial python-usb \
		python-dev python-pip
		
if [[ $device_short_name == "rpi2" ]] || [ $device_short_name == "oc1+" ] ; then #|| [ $device_short_name == "rpi3" ]; then
apt-get install -y --force-yes wiringpi
fi

pip install spidev
#pip install urwid

######################
# Install Svxlink
#####################
apt-get -y --force-yes install svxlink-server remotetrx
apt-get clean

#adding user Svxlink to gpio user group
usermod -a -G gpio svxlink

# RASPBERRY PI ONLY: Add Svxlink user to groups: gpio, audio, and daemon
if [[ $device_short_name == "rpi" ]] ; then
	usermod -a -G daemon,gpio,audio svxlink
fi

#####################################################
# Make and link Local event.d dir based on how Tobias
# says to in manual/web site.
#####################################################
mkdir /etc/svxlink/local-events.d
ln -s /etc/svxlink/local-events.d /usr/share/svxlink/events.d/local

# Clone Source
git clone https://github.com/kb3vgw/Svxlink-Custom.git

#install sa818/dra818 programmer
chmod +x Svxlink-Custom/818-programming/src/*
cp -rp Svxlink-Custom/818-programming/src/* /usr/bin

#Board Test Scripts
chmod +x Svxlink-Custom/Svxcard-test-scripts/*
cp -rp Svxlink-Custom/Svxcard-test-scripts/* /usr/bin

#update executabe apps
chmod +x Svxlink-Custom/exec-apps/*
cp Svxlink-Custom/exec-apps/* /usr/bin

#Update SVXCard Menu
chmod +x  Svxlink-Custom/Svxlink-Menu/Svxlink-Config
cp -r Svxlink-Custom/Svxlink-Menu/Svxlink-Config /usr/bin

#Copy Custom Logic into place
cp -rp Svxlink-Custom/Custom-Logic/* /etc/svxlink/local-events.d

#svxcard Svxlink config
cp -rp Svxlink-Custom/Svxlink-config/svxlink.conf /etc/svxlink

#cp perl and web into place
mkdir /var/www /var/spool/svxlink/state_info
touch /var/log/eventsource
chmod +x Svxlink-Custom/Svxlink-perl/*.pl *.sh
cp Svxlink-Custom/Svxlink-perl/*.pl /usr/bin
cp Svxlink-Custom/Svxlink-perl/net_loss_sim.sh /usr/bin
chmod +x Svxlink-Cuslinktom/Svxlink-perl/eventsource/eventsource.pl
cp Svxlink-Custom/Svx-perl/eventsource/eventsource.pl /usr/bin/
cp -r Svxlink-Custom/Svxlink-perl/eventsource/www/* /var/www
cp -r Svxlink-Custom/Svxlink-perl/eventsource/www2/* /var/www

#Remove Svxlink-Custom
rm -rf Svxlink-Custom

#################################
# Set up usb sound for alsa mixer
#################################
if [[ $device_short_name == "rpi2" ]] || [[ $device_short_name == "rpi3" ]] || [[ $device_short_name == "oc1+" ]] || [[ $device_short_name == "oc2" ]] || [[ $device_short_name == "pine64" ]] || [[ $device_short_name == "bbb" ]]; then
	if ( ! grep "snd-usb-audio" /etc/modules > /dev/null ) ; then
		echo "snd-usb-audio" >> /etc/modules
	fi
	FILE=/etc/modprobe.d/alsa-base.conf
	sed "s/options snd-usb-audio index=-2/options snd-usb-audio index=0/" $FILE > ${FILE}.tmp
	mv -f ${FILE}.tmp ${FILE}
	if ( ! grep "options snd-usb-audio nrpacks=1" ${FILE} >> /dev/null ) ; then
		echo "options snd-usb-audio nrpacks=1 index=0" >> ${FILE}
	fi
fi

#################################
# ODROIDc1+/c2:
#################################
if [[ $device_short_name == "oc1+" ]] || [[ $device_short_name == "oc2" ]] ; then
#blacklist driver
echo blacklist ads7846 >> /etc/modeprobe.d/spicc-blacklist.conf
#ModProbe moules
modprobe spicc aml-i2c i2c-dev spidev w1-gpio; modprobe w1-therm;
# Enable the modules at boot
{ echo spicc; echo aml-i2c; echo i2c-dev; echo spidev; echo w1-gpio; echo w1-therm; } >> /etc/modules;
fi

#################################
# RASPBERRY PI 2/3
# i2c &spi & set usb power
# configure 1 wire gpio pin
#################################
if [[ $device_short_name == "rpi2" ]] || [[ $device_short_name == "rpi3" ]]; then
#ModProbe moules
modprobe spi-bcm2835 spi-bcm2835 i2c-dev spidev w1-gpio w1-therm
# Enable the modules at boot
{ echoi2c-bcm2708; echo spi-bcm2835; echo i2c-dev; spidev; echo w1-gpio; echo w1-therm;  } >> /etc/modules

#edit /boot/config.txt
# Uncomment some or all of these to enable the optional hardware interfaces
sed -i /boot/config.txt -e"s#\#dtparam=i2c_arm=on#dtparam=i2c_arm=on#"
sed -i /boot/config.txt -e"s#\#dtparam=spi=on#dtparam=spi=on#"

# set usb power level
cat >> /boot/config.txt << DELIM

#usb max current
usb_max_current=1

#enable 1wire onboard temp
dtoverlay=w1-gpio,gpiopin=4
DELIM
fi

########################
# Enable Systemd Service
########################
systemctl enable svxlink.service

########################
# Enable Systemd Service
########################
systemctl enable remotetrx.service

####################################
# Set fs to run in a tempfs ramdrive
####################################
cat >> /etc/fstab << DELIM
tmpfs /tmp  tmpfs nodev,nosuid,mode=1777  0 0
tmpfs /var/tmp  tmpfs nodev,nosuid,mode=1777  0 0
tmpfs /var/cache/apt/archives tmpfs   size=100M,defaults,noexec,nosuid,nodev,mode=0755 0 0
DELIM

##################################
#Set up menu
#################################
cat >> /root/.profile << DELIM
if [ -f /usr/bin/Svxlink-Config ]; then 
	/usr/bin/Svxlink-Config
fi
DELIM

cat >> /home/pi/.profile << DELIM
if [ -f /usr/bin/Svxlink-Config ]; then
	sudo /usr/bin/Svxlink-Config
fi
DELIM

#################################
# Enable root account in ssh
#################################
printf '%s\n' '/PermitRootLogin/' "s/PermitRootLogin\ .*/PermitRootLogin\ yes/" w q  | ex /etc/ssh/sshd_config

#restart ssh
service ssh restart

##################################
# Set Root Password
#################################
sudo passwd root

echo " ########################################################################################## "
echo " #             The Svxlink Repeater / Echolink server Install is now complete             # "
echo " #                          and your system is ready for use..                            # "
echo " ########################################################################################## "
) | tee /root/install.log
