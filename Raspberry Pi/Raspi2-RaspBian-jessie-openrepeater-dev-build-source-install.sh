#!/bin/bash
(
####################################################################
#
#   Open Repeater Project
#
#    Copyright (C) <2015>  <Richard Neese> kb3vgw@gmail.com
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
###################################################################
# Auto Install Configuration options
# (set it, forget it, run it)
###################################################################

# ----- Start Edit Here ----- #
####################################################
# Repeater call sign
# Please change this to match the repeater call sign
####################################################
cs="Set_This"

###################################################
# Put /var/log into a tmpfs to improve performance 
# Super user option dont try this if you must keep 
# logs after every reboot
###################################################
put_logs_tmpfs="n"

###################################################
# Install openrepeater gui dev dir
###################################################
install_php_dev="y"

# ----- Stop Edit Here ------- #
########################################################
# Set mp3/wav file upload/post size limit for php/nginx
# ( Must Have the M on the end )
########################################################
upload_size="25M"

#######################
# Nginx default www dir
#######################
WWW_PATH="/var/www"

#################################
#set Web User Interface Dir Name
#################################
gui_name="openrepeater"

#####################
#Php ini config file
#####################
php_ini="/etc/php5/fpm/php.ini"
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
echo " ArmHF arm v6 v7 v8 v9 boards supported "
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
# Enable the spi/i2c
######################


##########################################
# SETUP configuration for /tmpfs for logs
##########################################
if [[ $put_logs_tmpfs == "y" ]]; then
#################
#configure fstab
#################
cat >>/etc/fstab << DELIM
tmpfs   /var/log                tmpfs   size=20M,defaults,noatime,mode=0755 0 0 
DELIM


########################
# cnfigure tmpfs sizes
########################
cp /etc/default/tmpfs /etc/default/tmpfs.orig
cat > /etc/default/tmpfs << DELIM
RAMLOCK=yes
RAMSHM=yes
RAMTMP=yes

TMPFS_SIZE=10%VM
RUN_SIZE=10M
LOCK_SIZE=5M
SHM_SIZE=10M
TMP_SIZE=25M

DELIM

#######################################
# Configure /var/log dir's on reboots
#######################################
cat > /etc/init.d/preplog-dirs << DELIM
#!/bin/bash
#
### BEGIN INIT INFO
# Provides:          prepare-dirs
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Required-Start:
# Required-Stop:
# Short-Description: Create needed directories on /var/log/ for tmpfs at startup
# Description:       Create needed directories on /var/log/ for tmpfs at startup
### END INIT INFO
# needed Dirs
DIR[0]=/var/log/nginx
DIR[1]=/var/log/apt
DIR[2]=/var/log/ConsoleKit
DIR[3]=/var/log/fsck
DIR[4]=/var/log/news
DIR[5]=/var/log/ntpstats
DIR[6]=/var/log/samba
DIR[7]=/var/log/lastlog
DIR[8]=/var/log/exim
DIR[9]=/var/log/watchdog
case "${1:-''}" in
  start)
        typeset -i i=0 max=${#DIR[*]}
        while (( i < max ))
        do
                mkdir  ${DIR[$i]}
                chmod 755 ${DIR[$i]}
                i=i+1
        done
        # set rights
        chown www-data.adm ${DIR[0]}
        chown root.adm ${DIR[6]}
    ;;
  stop)
    ;;
  restart)
   ;;
  reload|force-reload)
   ;;
  status)
   ;;
  *)
DELIM

chmod 755 /etc/init.d/preplog-dirs

fi

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
#deb-src http://httpredir.debian.org/debian/ jessie main contrib non-free

deb http://httpredir.debian.org/debian/ jessie-updates main contrib non-free
#deb-src http://httpredir.debian.org/debian/ jessie-updates main contrib non-free

deb http://httpredir.debian.org/debian/ jessie-backports main contrib non-free
#deb-src http://httpredir.debian.org/debian/ jessie-backports main contrib non-free

DELIM

############
#Raspi Repo
############
cat > /etc/apt/sources.list.d/raspbian.list << DELIM
deb http://mirrordirector.raspbian.org/raspbian/ jessie main contrib non-free rpi
DELIM

######################
#Update base os
######################
for i in update upgrade clean ;do apt-get -y "${i}" ; done

########################
# Install Build Depends
########################
apt-get install -y g++ make cmake libsigc++-2.0-dev libgsm1-dev libpopt-dev libgcrypt11-dev \
	libspeex-dev libspeexdsp-dev libasound2-dev alsa-utils vorbis-tools sox flac libsox-fmt-mp3 \
	sqlite3 unzip opus-tools tcl8.6-dev tk8.6-dev alsa-base ntp groff doxygen libopus-dev \
	librtlsdr-dev git-core uuid-dev qtbase5-dev qttools5-dev-tools qttools5-dev git-core flite screen \
	time inetutils-syslogd vim install-info whiptail dialog logrotate cron usbutils gawk watchdog \
	python3-serial

##################################
# Add User and include in groupds
# Required for svxlink to install 
# and run properly
#################################
# Sane defaults:
[ -z "$SERVER_HOME" ] && SERVER_HOME=/usr/bin
[ -z "$SERVER_USER" ] && SERVER_USER=svxlink
[ -z "$SERVER_NAME" ] && SERVER_NAME="Svxlink-related Daemons"
[ -z "$SERVER_GROUP" ] && SERVER_GROUP=daemon
     
# Groups that the user will be added to, if undefined, then none.
ADDGROUP="audio dialout"
     
# create user to avoid running server as root
# 1. create group if not existing
if ! getent group | grep -q "^$SERVER_GROUP:" ; then
   echo -n "Adding group $SERVER_GROUP.."
   addgroup --quiet --system $SERVER_GROUP 2>/dev/null ||true
   echo "..done"
fi
    
# 2. create homedir if not existing
test -d $SERVER_HOME || mkdir $SERVER_HOME
    
# 3. create user if not existing
if ! getent passwd | grep -q "^$SERVER_USER:"; then
   echo -n "Adding system user $SERVER_USER.."
   adduser --quiet \
           --system \
           --ingroup $SERVER_GROUP \
           --no-create-home \
           --disabled-password \
           $SERVER_USER 2>/dev/null || true
   echo "..done"
fi
    
# 4. adjust passwd entry
usermod -c "$SERVER_NAME" \
    -d $SERVER_HOME   \
    -g $SERVER_GROUP  \
    $SERVER_USER
# 5. Add the user to the ADDGROUP group

for group in $ADDGROUP ; do
if test -n "$group"
then
    if ! groups $SERVER_USER | cut -d: -f2 | grep -qw "$group"; then
	adduser $SERVER_USER "$group"
    fi
fi
done

#########################
# get svxlink src
#########################
git clone git://github.com/rneese45/svxlink.git /usr/src/svxlink
cd /usr/src/svxlink
git pull git://github.com/rneese45/svxlink.git test-full-patches-deb-pkg

#############################
#Build & Install svxllink
#############################
cd /usr/src/svxlink/src
mkdir build
cd build
time wc cmake -DCMAKE_INSTALL_PREFIX=/usr -DSYSCONF_INSTALL_DIR=/etc -DBUILD_STATIC_LIBS=YES ..
time wc make -j5
time wc make doc
make install
ldconfig

ln -s /etc/openrepeater/svxlink/local-events.d/ /usr/share/svxlink/events.d/local

systemctrl enable svxlink.serviceclear

service svxlink start

#######################################################
#Install svxlink en_US sounds
#Working on sounds pkgs for future release of svxlink
########################################################
cd /usr/src || exit
wget https://github.com/sm0svx/svxlink-sounds-en_US-heather/releases/download/14.08/svxlink-sounds-en_US-heather-16k-13.12.tar.bz2
tar xjvf svxlink-sounds-en_US-heather-16k-13.12.tar.bz2
rm *.bz2
mv en_US-heather* en_US
mv en_US /usr/share/svxlink/sounds
cd  ~ || exit

##############################################
# Enable New shellmenu for logins  on enabled 
# for root and only if the file exist
##############################################
cat >> /root/.profile << DELIM

if [ -f /usr/bin/svxlink-conf ]; then
        . /usr//bin/svxlink-conf
fi

DELIM


echo " ########################################################################################## "
echo " #             The SVXLink Repeater / Echolink server Install is now complete             # "
echo " #                          and your system is ready for use..                            # "
echo " #                                                                                        # "
echo " #                This is a build from dev source install with systemd                    # "
echo " #                                                                                        # "
echo " #                   To Start the service fo svxlink on the cmd line                      # "
echo " #                        run cmd: systemctl enable svxlink.service                       # "
echo " #                                                                                        # "
echo " #                   To Start the service fo remotetrx on the cmd line                    # "
echo " #                        run cmd: systemctl enable remotetrx.service                     # "
echo " #                                                                                        # "
echo " ########################################################################################## "
) | tee /root/install.log

