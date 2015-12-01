#!/bin/bash
(
###################################################################
# Auto Install Configuration options 
# (set it, forget it, run it)
###################################################################

# ----- Start Edit Here ----- #
####################################################
# Repeater call sign
# Please change this to match the repeater call sign
####################################################
cs="Set-This"

# ----- Stop Edit Here ------- #
######################################################################
# check to see that the configuration portion of the script was edited
######################################################################
if [[ $cs == "Set-This" ]]; then
  echo
  echo "Looks like you need to configure the scirpt before running"
  echo "Please configure the script and try again"
  exit 0
fi

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
echo " Intel / Amd boards currently Support is comming soon "
echo
exit
esac

###################
# Notes / Warnings
###################
echo
cat << DELIM
                   Not Ment For L.a.m.p Installs

                  L.A.M.P = Linux Apache Mysql PHP

                 THIS IS A ONE TIME INSTALL SCRIPT

             IT IS NOT INTENDED TO BE RUN MULTIPLE TIMES

         This Script Is Ment To Be Run On A Fresh Install Of

                         Debian 8 (Jessie)

     If It Fails For Any Reason Please Report To kb3vgw@gmail.com

   Please Include Any Screen Output You Can To Show Where It Fails
   
  Note:

  Pre-Install Information:

       This script uses Sqlite by default. No plans to use Other DB. 

DELIM

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
cat > /etc/sysctl.conf << DELIM
kernel.panic = 10
DELIM

####################################
# Set fs to run in a tempfs ramdrive
####################################
cat >> /etc/fstab << DELIM
tmpfs /tmp  tmpfs nodev,nosuid,mode=1777  0 0
tmpfs /var/tmp  tmpfs nodev,nosuid,mode=1777  0 0
tmpfs /var/cache/apt/archives tmpfs   size=100M,defaults,noexec,nosuid,nodev,mode=0755 0 0
DELIM

######################
# Enable the spi & i2c
######################
echo "spicc" >> /etc/modules
echo "aml_i2c" >> /etc/modules


#############################
#Setting Host/Domain name
#############################
cat > /etc/hostname << DELIM
$cs-repeater
DELIM

#################
#Setup /etc/hosts
#################
cat > /etc/hosts << DELIM
127.0.0.1       localhost
::1             localhost ip6-localhost ip6-loopback
fe00::0         ip6-localnet
ff00::0         ip6-mcastprefix
ff02::1         ip6-allnodes
ff02::2         ip6-allrouters

127.0.0.1       $cs-repeater
DELIM

#################################################################################################
# Setting apt_get to use the httpredirecter to get
# To have <APT> automatically select a mirror close to you, use the Geo-ip redirector in your
# sources.list "deb http://httpredir.debian.org/debian/ jessie main".
# See http://httpredir.debian.org/ for more information.  The redirector uses HTTP 302 redirects
# not dnS to serve content so is safe to use with Google dnS.
# See also <which httpredir.debian.org>.  This service is identical to http.debian.net.
#################################################################################################
cat > "/etc/apt/sources.list" << DELIM
deb http://httpredir.debian.org/debian/ jessie main contrib non-free
deb http://httpredir.debian.org/debian/ jessie-updates main contrib non-free
deb http://httpredir.debian.org/debian/ jessie-backports main contrib non-free

DELIM

# HardKernel-Odroid repo
cat > /etc/apt/sources.list.d/odroid.list << DELIM
deb http://deb.odroid.in/c1/ trusty main
deb http://deb.odroid.in/ trusty main
DELIM

# SVXLink Testing repo
cat > "/etc/apt/sources.list.d/svxlink.list" <<DELIM
deb http://repo.openrepeater.com/svxlink/release/debian/ jessie main
DELIM

#Update base os
for i in update upgrade clean ;do apt-get -y "${i}" ; done


#Install Dependancies
apt-get install -y --force-yes libopus0 alsa-utils vorbis-tools sox libsox-fmt-mp3 librtlsdr0 \
		ntp libasound2 libspeex1 libgcrypt20 libpopt0 libgsm1 tcl8.6 alsa-base bzip2 sudo gpsd \
		gpsd-clients flite wvdial screen time uuid vim install-info usbutils whiptail dialog \
		logrotate cron gawk watchdog python3-serial

# Install SvxLink
		
apt-get install -y --force-yes svxlink-server remotetrx 

#Adding a link for customlogic and override tcl files for local events

ln -s /etc/svxlink/local-events.d/ /usr/share/svxlink/events.d/local

###########
# Clean Up
###########
apt-get clean

#Working on sounds pkgs for future release of svxlink
cd /usr/share/svxlink/sounds
wget https://github.com/sm0svx/svxlink-sounds-en_US-heather/releases/download/14.08/svxlink-sounds-en_US-heather-16k-13.12.tar.bz2
tar xjvf svxlink-sounds-en_US-heather-16k-13.12.tar.bz2
mv en_US-heather* en_US
rm svxlink-sounds-en_US-heather-16k-13.12.tar.bz2
cd ~

######################
#Install svxlink Menu
#####################
wget https://github.com/rneese45/svxlink_menu
chmod +x svxlink_menu 
mv svxlink_menu /usr/bin

##############################################
# Enable New shellmenu for logins  on enabled 
# for root and only if the file exist
##############################################
cat >> /root/.profile << DELIM

if [ -f /usr/bin/svxlink_conf ]; then
        . /usr//bin/svxlink_conf
fi

DELIM

echo " ########################################################################################## "
echo " #             The SVXLink Repeater / Echolink server Install is now complete             # "
echo " #                          and your system is ready for use..                            # "
echo " #                                                                                        # "
echo " #                   To Start the service fo svxlink on the cmd line                      # "
echo " #                        run cmd: systemctl enable svxlink.service                       # "
echo " #                                                                                        # "
echo " #                   To Start the service fo remotetrx on the cmd line                    # "
echo " #                        run cmd: systemctl enable remotetrx.service                     # "
echo " #                                                                                        # "
echo " ########################################################################################## "
) | tee /root/install.log