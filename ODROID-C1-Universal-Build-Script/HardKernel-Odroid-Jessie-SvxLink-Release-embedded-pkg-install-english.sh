#!/bin/bash
(
###################################################################
# Auto Install Configuration options 
# (set it, forget it, run it)
###################################################################

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

######################################
# Reconfigure system for performance
######################################
##############################
#Set a reboot if Kernel Panic
##############################
cat >> /etc/sysctl.conf << DELIM
kernel.panic = 10
DELIM

####################################
# Set fs to run in a tempfs ramdrive
####################################
cat >> /etc/fstab << DELIM
tmpfs /var/tmp  tmpfs nodev,nosuid,mode=1777  0 0
tmpfs /var/cache/apt/archives tmpfs   size=100M,defaults,noexec,nosuid,nodev,mode=0755 0 0
DELIM

#####################
#ModProbe moules
####################
modprobe spicc
modprobe aml_i2c
modprobe w1-gpio
modprobe w1-therm

######################
# Enable the spi & i2c
######################
echo "spicc" >> /etc/modules
echo "aml_i2c" >> /etc/modules
echo "w1-gpio" >> /etc/modules
echo "w1-therm" >> /etc/modules

#######################
# SVXLink Package repo
#######################
cat > "/etc/apt/sources.list.d/svxlink.list" <<DELIM
deb http://104.236.193.157/svxlink/release/debian/ jessie main
DELIM

################
#Update base os
################
for i in update upgrade clean ;do apt-get -y "${i}" ; done

#######################
#Install Dependancies
#######################
apt-get install -y libopus0 alsa-base alsa-utils vorbis-tools sox libsox-fmt-mp3 librtlsdr0 \
		ntp libasound2 libspeex1 libgcrypt20 libpopt0 libgsm1 tcl8.6 tk8.6 bzip2 gpsd \
		gpsd-clients flite wvdial inetutils-syslogd screen vim usbutils whiptail dialog \
		logrotate cron gawk python3-serial git-core wiringpi python-pip libsigc++-2.0-0c2a

#cleanup
apt-get clean

# Install SvxLink
apt-get install -y --force-yes svxlink-server remotetrx 

###########
# Clean Up
###########
apt-get clean

############################################
#Backup Basic svxlink original config files
############################################
mkdir -p /usr/share/examples/svxlink/conf
cp -rp /etc/svxlink/* /usr/share/examples/svxlink/conf

##############################
#Install Courtesy Sound Files
##############################
wget --no-check-certificate http://github.com/kb3vgw/Svxlink-Courtesy_Tones/archive/15.10.1.tar.gz
tar xzvf 15.10.1.tar.gz
mv Svxlink-Courtesy_Tones-15.10.1 Courtesy_Tones
mv Courtesy_Tones /usr/share/svxlink/sounds/
rm 15.10.1.tar.gz

################################
#Make and Link Custome Sound Dir
################################
mkdir -p /root/sounds/Custom_Courtesy_Tones
ln -s /root/sounds/Custom_Courtesy_Tones /usr/share/svxlink/sounds/Custom_Courtesy_Tones
mkdir -p /root/sounds/Custom_Identification
ln -s /root/sounds/Custom_identification /usr/share/svxlink/sounds/Custom_Identification

################################
# Make and link Local event.d dir
#################################
mkdir /etc/svxlink/local-events.d
ln -s /etc/svxlink/local-events.d /usr/share/svxlink/events.d/local

###########################
#Install Custom Logic Files
###########################
git clone https://github.com/kb3vgw/Svxlink-Custom-Logic.git
cp -rp Svxlink-Custom-Logic/* /etc/svxlink/local-events.d
rm -rf Svxlink-Custom-Logic

############################
#Custom svxlink Shell Menu
############################
git clone https://github.com/kb3vgw/svxlink-menu.git
chmod +x svxlink-menu/svxlink_config
cp -r svxlink-menu/svxlink_config /usr/bin
rm -rf svxlink-menu

##############################################
# Enable New shell menu for logins  on enabled 
# for root and only if the file exist
##############################################
cat >> /root/.profile << DELIM

if [ -f /usr/bin/svxlink_config ]; then
        . /usr//bin/svxlink_config
fi

DELIM

#######################
#Enable Systemd Service
####################### 
echo " Enabling the Svxlink systemd Service Daemon "
systemctl enable svxlink.service

#######################
#Enable Systemd Service
####################### 
echo " Enabling the Svxlink Remotetrx systemd Service Daemon "
systemctl enable remotetrx.service

##########
#Set RTC 
#########
hwclock -w

############################################
#reboot sysem for all changes to take effect
############################################
#echo " rebooting system forfull changes to take effect "
#reboot

) | tee /root/install.log