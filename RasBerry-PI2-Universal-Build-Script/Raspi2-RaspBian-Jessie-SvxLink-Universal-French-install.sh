#!/Bin/bash
(
#######################################
# Auto Install Options de configuration
# (D�fini, l'oublier, l'ex�cuter)
#######################################
################################################## ####################
# V�rifier que la partie de configuration du script a �t� modifi�
################################################## ####################
si [[== $ cs "Set-Ce"]]; puis
���cho
��echo "On dirait que vous avez besoin pour configurer le scirpt avant d'ex�cuter"
��echo "S'il vous pla�t configurer le script et essayez � nouveau"
��exit 0
fi

################################################## ################
# V�rifier pour confirmer en tant que root. # Tout d'abord, nous avons besoin d'�tre root ...
################################################## ################
if [ "$ (id -u)" -ne "0"]; puis
��"$ (Basename de� 0 $ �) sudo doit �tre ex�cut� en tant que root, s'il vous pla�t entrer votre mot de passe sudo:" "$ 0" "$ @"
��exit 0
fi
�cho
echo "On dirait que vous �tes root .... continuez!"
�cho

###############################################
#if lsb_release est pas install�, il installe
###############################################
si [ ! -s/usr/bin/lsb_release]; puis
apt-get update && apt-get -y installer lsb-release
fi

#################
# Os/Distro Check
#################
lsb_release -c | grep -i jessie &>/dev/null 2> & 1
if [$? -eq 0]; puis
echo "OK vous utilisez Debian 8: Jessie"
autre
echo "Ce script a �t� �crit pour Debian 8 Jessie"
�cho
echo "Votre OS semble �tre:" lsb_release -a
�cho
echo "Votre OS est pas pris en charge par ce script ..."
�cho
echo "Quitter l'installation."
Sortie
fi

###########################################
# Ex�cuter un syst�me d'exploitation et la plate-forme compatabilty Check
###########################################
########
# ARMEL
########
cas $ (uname -m) dans ArMV [4-5] l)
�cho
echo "ARMEL est currenty UNSUPPORTED"
�cho
Sortie
esac

########
# ARMHF
########
cas $ (uname -m) dans ArMV [6-9] l)
�cho
echo "armhf bras v7 planches v8 v9 support�es"
�cho
esac

#############
# Intel/AMD
#############
cas $ (uname -m) dans x86_64 | i [4-6] 86)
�cho
echo "cartes Intel/Amd actuellement UNSUPPORTED"
�cho
Sortie
esac

#####################################
os de base #update avec le nouveau repo dans la liste
#####################################
�cho ""
�cho "------------------------------------------------ -------------- "
echo "Mise � jour des cl�s de r�f�rentiel Raspberry Pi ..."
�cho "------------------------------------------------ -------------- "
�cho ""
gpg --keyserver pgp.mit.edu --recv 8B48AD6246925553
gpg --export --armor 8B48AD6246925553 | apt-key add -
gpg --keyserver pgp.mit.edu --recv 7638D0442B90D010
gpg --export --armor 7638D0442B90D010 | apt-key add -
CBF8D6FD518E17E1 GPG --keyserver pgp.mit.edu
gpg --export --armor CBF8D6FD518E17E1 | apt-key add -
wget https://www.raspberrypi.org/raspberrypi.gpg.key
gpg --import raspberrypi.gpg.key | apt-key add -
wget https://archive.raspbian.org/raspbian.public.key
gpg --import raspbian.public.key | apt-key add -
for i in mise � jour mise � niveau propre, faire apt-get -y --force-yes "$ {i}"; termin�

#####################################
os de base #update avec le nouveau repo dans la liste
#####################################
apt-get update

###################
# Notes/Avertissements
###################
�cho
cat << DELIM
�������������������Non Ment Pour L.a.m.p Installe

������������������L.A.M.P = Linux Apache Mysql PHP

�����������������CECI EST UN SCRIPT UNE FOIS INSTALLER

�������������IL EST PAS DESTINE A ETRE RUN PLUSIEURS FOIS

���������Ce script est Ment � ex�cuter sur une nouvelle installation de

�������������������������8 Debian (Jessie)

�����Si elle �choue pour une raison quelconque S'il vous pla�t rapport au kb3vgw@gmail.com

���S'il vous pla�t inclure toute sortie de l'�cran Vous pouvez pour montrer o� il �choue

DELIM

################################################## #############################################
#Testing Pour la connexion internet. Tir� de et modifi�
#http: //www.linuxscrew.com/2009/04/02/tiny-bash-scripts-check-internet-connection-availability/
################################################## #############################################
�cho
echo "Ce script n�cessite actuellement une connexion Internet"
�cho
wget -q --tries = 10 --timeout = 5 http://www.google.com -O /tmp/index.google &>/dev/null

si [ ! -s /tmp/index.google], puis
echo "Pas de connexion Internet. S'il vous pla�t v�rifier le c�ble Ethernet"
/ Bin/rm /tmp/index.google
sortie 1
autre
echo "I Found Internet ... continue !!!!!"
/ Bin/rm /tmp/index.google
fi
�cho
printf 'ip actuelle est:'; inet addr show dev eth0 ip | sed -n 's/^ * inet * \ ([. 0-9] * \). */\ 1/p'
�cho

#####################
#modprobe moules
####################
modprobe w1-gpio
modprobe w1-therm

######################
# Activer le spi & i2c
######################
echo "w1-gpio" >>/etc/modules
echo "w1-therm" >>/etc/modules

##############################
#SET Un red�marrage si Kernel Panic
##############################
cat> /etc/sysctl.conf << DELIM
kernel.panic = 10
DELIM

####################################
# Set fs � ex�cuter dans un ramdrive de tempfs
####################################
cat >>/etc/fstab << DELIM
tmpfs/tmp tmpfs nodev, nosuid, mode = 1777 0 0
tmpfs/var/tmp tmpfs nodev, nosuid, mode = 1777 0 0
tmpfs/var/cache/apt/tmpfs archives size = 100M, par d�faut, noexec, nosuid, nodev, mode = 0755 0 0
DELIM

############################
# D�finir le niveau de puissance usb
############################
cat >> /boot/config.txt << DELIM

courant #usb max
usb_max_current = 1
DELIM

###############################
# D�sactiver le fichier dphys d'�change
# Prolonger la vie de la carte sd
###############################
swapoff --all
apt-get -y supprimer dphys-swapfile
rm -rf/var/swap

################################################## ###
son #fix usb/question nic donc interface r�seau obtient IP
################################################## ###
cat>/etc/network/interfaces << DELIM
lo auto eth0
iface lo inet loopback
inet dhcp de iface de

DELIM


#####################################
os de base #update avec le nouveau repo dans la liste
#####################################
�cho ""
�cho "------------------------------------------------ -------------- "
echo "Mise � jour des cl�s de r�f�rentiel Raspberry Pi ..."
�cho "------------------------------------------------ -------------- "
�cho ""
gpg --keyserver pgp.mit.edu --recv 8B48AD6246925553
gpg --export --armor 8B48AD6246925553 | apt-key add -
gpg --keyserver pgp.mit.edu --recv 7638D0442B90D010
gpg --export --armor 7638D0442B90D010 | apt-key add -
CBF8D6FD518E17E1 GPG --keyserver pgp.mit.edu
gpg --export --armor CBF8D6FD518E17E1 | apt-key add -
wget https://www.raspberrypi.org/raspberrypi.gpg.key
gpg --import raspberrypi.gpg.key | apt-key add -
wget https://archive.raspbian.org/raspbian.public.key
gpg --import raspbian.public.key | apt-key add -
for i in mise � jour mise � niveau propre, faire apt-get -y --force-yes "$ {i}"; termin�

################################################## ##############################################
# R�glage apt_get utiliser le httpredirecter pour obtenir
# Pour avoir <APT> s�lectionner automatiquement un miroir pr�s de chez vous, utilisez le redirecteur Geo-ip dans votre
# Sources.list "deb http://httpredir.debian.org/debian/ jessie principale".
# Voir http://httpredir.debian.org/ pour plus d'informations. Le redirecteur utilise HTTP redirections 302
# pas dns pour servir le contenu est donc s�r � utiliser avec Google dns.
# Voir aussi <qui httpredir.debian.org>. Ce service est identique � http.debian.net.
################################################## ###############################################
cat> "/etc/apt/sources.list" << DELIM
deb http://httpredir.debian.org/debian/ jessie main contrib non-free
deb-src http://httpredir.debian.org/debian/ jessie main contrib non-free
deb http://httpredir.debian.org/debian/ jessie-updates main contrib non-free
deb-src http://httpredir.debian.org/debian/ jessie-updates main contrib non-free
deb http://httpredir.debian.org/debian/ jessie-backports main contrib non-free
deb-src http://httpredir.debian.org/debian/ jessie-backports main contrib non-free

DELIM

############
# Raspi Repo
################################################## #########################
# Mettre en bonne Situation. Tous les repos addon devraient �tre source.list.d dir sous
################################################## #########################
cat> /etc/apt/sources.list.d/raspi.list << DELIM
deb http://mirrordirector.raspbian.org/raspbian/ jessie main contrib firmware rpi non-free
DELIM

#############################
# SvxLink sortie Repo armhf
#############################
cat> "/etc/apt/sources.list.d/svxlink.list" << DELIM
jessie la principale deb
DELIM

######################
os de base #update
######################
for i in mise � jour mise � niveau propre, ne apt-get -y "$ {i}"; termin�

##########################
#Installing Deps de svxlink
##########################
apt-get install -y sqlite3 libopus0 alsa-utils vorbis-tools sox libsox-fmt-mp3 librtlsdr0 \
ntp libasound2 libspeex1 libgcrypt20 libpopt0 libgsm1 tcl8.6 tk8.6 alsa-base bzip2 \
sudo gpsd gpsd-clients Flite inetutils-syslogd wvdial �cran temps vim uuid install-info \
usbutils logrotate dialogue cron gawk watchdog python3-serial network-manager whiptail \
git-core wiringpi python-pip libsigc ++ - 2.0-0c2a libhamlib2 libhamlib2 ++ c2 libhamlib2-perl \
libhamlib-utils libhamlib-doc libhamlib2-tcl python-libhamlib2 fail2ban hostapd resolvconf \
watchdog i2c-tools libasound2-plugin-�galit�


#################
svxlink #Install
#################
apt-get -y --force-yes installer remotetrx svxlink-server

#nettoyer
apt-get clean

#Adding utilisateur svxlink au groupe d'utilisateurs gpio
usermod -a -G gpio svxlink

##############################
#Install Courtesy fichiers audio
##############################
wget --no-check-certificat http://github.com/kb3vgw/Svxlink-Courtesy_Tones/archive/15.10.2.tar.gz
tar xzvf 15.10.2.tar.gz
mv Svxlink-Courtesy_Tones-15.10.2/Courtesy_Tones/usr/share/svxlink/sons
rm -rf Svxlink-Courtesy_Tones-15.10.2 15.10.2.tar.gz

#################################
# Marque et lien event.d local dir
#################################
mkdir /etc/svxlink/local-events.d
ln -s /etc/svxlink/local-events.d /usr/share/svxlink/events.d/local

###########################
#Install Personnalis� Config File
###########################
git clone https://github.com/kb3vgw/arris-svxlink-config.git
cp -r arris-svxlink-config/svxlink.conf/etc/svxlink /
rm -rf arris-svxlink-config

###########################
#Install Fichiers Logic personnalis�s
###########################
git clone https://github.com/kb3vgw/Svxlink-Custom-Logic.git
Svxlink-Custom-Logic/* /etc/svxlink/local-events.d cp
rm -rf Svxlink-Custom-Logic

https://github.com/kb3vgw/arris-svxlink-config.git

############################################
les fichiers de configuration d'origine de #backup de base
############################################
mkdir -p/usr/share/examples/svxlink/conf
cp -rp/etc/svxlink/*/usr/share/examples/svxlink/conf

############################
Scripts #Board test
############################
git clone https://github.com/kb3vgw/board-scripts.git
mv boaboard-scripts/Logic.tcl /etc/svxlink/local-events.d
chmod + x conseil-scripts/*
cp boaboard-scripts/*/usr/bin
rm -rf soci�t�-scripts

################################################## #########
#disable Bord hdmi soundcard pas utilis� dans openrepeater
#/Boot/config.txt et/etc/modules
################################################## #########
#/Boot/config.txt
sed -i /boot/config.txt -e "s#dtparam=audio=on#\#dtparam=audio=sur#"

#/etc/modules
-i sed/etc/modules -e "#snd-bcm2835#\#snd-bcm2835N�"

################################
#SET Jusqu'� son USB pour mixer alsa
################################
if ( `grep" snd-usb-audio "/ etc/modules>/dev/null`!); puis
���echo/etc/modules "snd-usb-audio" >>
fi
FILE =/etc/modprobe.d/alsa-base.conf
sed "de/options snd-usb-audio index=-2/les options snd-usb-audio index=0/" $ FILE> $ {FILE} .tmp
$ {FILE} .tmp de $ de mv {FILE}
if (! `grep" options snd-usb-audio nrpacks=1 "$ {FILE}>/dev/null`); puis
��echo "nrpacks les options snd-usb-audio=1 index=0" >> $ {FILE}
fi

######################
#Install De Menu
#####################
git clone https://github.com/kb3vgw/arris-menu.git
chmod + x arris-menu/arris_config
cp -r arris-menu/arris_config/usr/bin
rm -rf arris menu

##############################################
# Activer New shellmenu pour les connexions sur les permis
# Pour la racine et seulement si le fichier existe
##############################################
cat >> /root/.profile << DELIM

if [-f/usr/bin/arris_config]; puis
��������./Usr/bin/arris_config
fi

DELIM

#######################
#enable Service Systemd
#######################
echo "Activation du Svxlink de service Daemon"
systemctl activer svxlink.service

############################################
#reboot sysem pour toutes les modifications prennent effet
############################################
echo "syst�me red�marrant forfull modifications prennent effet"
r�initialiser

) | tee /root/install.log