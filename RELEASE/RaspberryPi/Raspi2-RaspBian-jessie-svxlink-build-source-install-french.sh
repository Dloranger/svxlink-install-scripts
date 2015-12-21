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

#####################################
#Update base os with new repo in list
#####################################
echo ""
echo "--------------------------------------------------------------"
echo "Updating Raspberry Pi repository keys..."
echo "--------------------------------------------------------------"
echo ""
gpg --keyserver pgp.mit.edu --recv 8B48AD6246925553 
gpg --export --armor 8B48AD6246925553 | apt-key add -
gpg --keyserver pgp.mit.edu --recv  7638D0442B90D010
gpg --export --armor  7638D0442B90D010 | apt-key add -
gpg --keyserver pgp.mit.edu --recv CBF8D6FD518E17E1
gpg --export --armor CBF8D6FD518E17E1 | apt-key add -
wget https://www.raspberrypi.org/raspberrypi.gpg.key
gpg --import raspberrypi.gpg.key | apt-key add -
wget https://archive.raspbian.org/raspbian.public.key
gpg --import raspbian.public.key | apt-key add -
for i in update upgrade clean ;do apt-get -y --force-yes "${i}" ; done

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
	librtlsdr-dev git-core uuid-dev git-core flite screen time inetutils-syslogd vim install-info \
	whiptail dialog logrotate cron usbutils gawk watchdog python3-serial network-manager wiringpi

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
ADDGROUP="audio dialout gpio daemon"
     
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
wget https://github.com/rneese45/svxlink/archive/15.11.1.tar.gz
tar xzvf 15.11.1.tar.gz -C /usr/src
rm 15.11.1.tar.gz

#############################
#Build & Install svxllink
#############################
cd /usr/src/svxlink-15.11.1/src
mkdir build
cd build
cmake -DCMAKE_INSTALL_PREFIX=/usr -DSYSCONF_INSTALL_DIR=/etc -DBUILD_STATIC_LIBS=YES -DWITH_SYSTEMD ..
make -j5
make doc
make install
ldconfig

#####################################################
#Working on sounds pkgs for future release of svxlink
#####################################################
wget https://raw.githubusercontent.com/sm0svx/svxlink/master/src/svxlink/scripts/play_sound.sh
wget https://raw.githubusercontent.com/sm0svx/svxlink/master/src/svxlink/scripts/filter_sounds.sh
chmod +x play_sound.sh filter_sounds.sh
git clone https://github.com/rneese45/svxlink-sounds-fr_FR-heather.git orig-fr-FR-heather
./filter_sounds.sh orig-fr-FR-heather fr-FR-heather-16k
mv fr-FR-heather-16k /usr/share/svxlink/sounds/fr-FR
rm -rf orig-fr-FR-heather *.bz2 play_sound.sh filter_sounds.sh

##############################
#Install Courtesy Sound Files
##############################
git clone https://github.com/rneese45/Svxlink-Custom-Sounds.git
cp -rp Svxlink-Custom-Sounds/* /usr/share/svxlink/sounds/
rm -rf Svxlink-Custom-Sounds

################################
#Make and Link Custome Sound Dir
################################
mkdir -p /root/sounds/Custom_Courtesy_Tones
ln -s /root/sounds/Custom_Courtesy_Tones /usr/share/svxlink/sounds/fr_FR/Custom_Courtesy_Tones
mkdir -p /root/sounds/Custom_Identification
ln -s /root/sounds/Custom_identification /usr/share/svxlink/sounds/fr_FR/Custom_Identification

#################################
# Make and link Local event.d dir
#################################
mkdir /etc/svxlink/local-events.d
ln -s /etc/svxlink/local-events.d /usr/share/svxlink/events.d/local

###########################
#Install Custom Logic Files
###########################
git clone https://github.com/rneese45/Svxlink-Custom-Logic.git
cp -rp Svxlink-Custom-Logic/* /etc/svxlink/local-events.d
rm -rf Svxlink-Custom-Logic

######################
#Install svxlink Menu
#####################
git clone https://github.com/rneese45/svxlink-menu.git
chmod +x svxlink-menu/svxlink_config
cp -r svxlink-menu/svxlink_config /usr/bin
rm -rf svxlink-menu

##############################################
# Enable New shellmenu for logins  on enabled 
# for root and only if the file exist
##############################################
cat >> /root/.profile << DELIM

if [ -f /usr/bin/svxlink_config ]; then
        . /usr//bin/svxlink_config
fi

DELIM

##################################
#Backup Basic svxlink config files
##################################
mkdir -p /usr/share/examples/svxlink/conf
cp -rp /etc/svxlink/* /usr/share/examples/svxlink/conf

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

##########################################
#addon extra scripts for cloning the drive
##########################################
wget https://raw.githubusercontent.com/billw2/rpi-clone/master/rpi-clone
chmod +x rpi-clone
cp rpi-clone /usr/bin
rm rpi-clone

###########################################################
#Disable onboard hdmi soundcard not used in openrepeater
###########################################################
#/boot/config.txt
sed -i /boot/config.txt -e"s#dtparam=audio=on#\#dtparam=audio=on#"

# Enable audio (loads snd_bcm2835)
# dtparam=audio=on
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

############################################
#reboot sysem for all changes to take effect
############################################
echo " rebooting system forfull changes to take effect "
reboot

) | tee /root/install.log

