#! / bin / bash
(
#######################################
# Auto Install Options de configuration
# (D�fini, l'oublier, l'ex�cuter)
#######################################

# ----- D�but Edition Voici ----- #
################################################## ##
Signe # Repeater d'appel
# S'il vous pla�t changer pour correspondre le signe r�p�teur d'appel
################################################## ##
cs = "Set-Ce"

# ----- Stop Edit Voici ------- #
################################################## ####################
# V�rifier pour voir ce que la partie de la configuration du script a �t� modifi�
################################################## ####################
si [[== $ cs "Set-Ce"]]; puis
��faire �cho
��echo "On dirait que vous avez besoin pour configurer la scirpt avant de lancer"
��echo "S'il vous pla�t configurer le script et essayez � nouveau"
��exit 0
fi

################################################## ################
# V�rification afin de confirmer en tant que root. # D'abord, nous avons besoin d'�tre root ...
################################################## ################
if ["$ (id -u)" -ne "0"]; puis
��"$ (le nom de base� 0 $ �) de sudo doit �tre ex�cut� en tant que root, s'il vous pla�t entrer votre mot de passe sudo:" "$ 0" "$ @"
��exit 0
fi
faire �cho
echo "On dirait que vous �tes root .... continuez!"
faire �cho

###############################################
#if lsb_release est pas install�, il installe
###############################################
si [ ! -s / usr / bin / lsb_release]; puis
apt-get update && apt-get -y installer lsb-release
fi

#################
# Os / Distro V�rifier
#################
lsb_release -c | grep -i Jessie &> / dev / null 2> & 1
if [$? -eq 0]; puis
echo "OK vous utilisez Debian 8: Jessie"
autre
echo "Ce script a �t� �crit pour Debian 8 Jessie"
faire �cho
echo "Votre OS semble �tre:" lsb_release -a
faire �cho
echo "Votre OS est pas actuellement pris en charge par ce script ..."
faire �cho
echo "Quitter l'installation."
Sortie
fi

###########################################
# Ex�cutez un syst�me d'exploitation et le Programme compatabilty V�rifier
###########################################
########
# ARMEL
########
cas $ (uname -m) dans ArMV [4-5] l)
faire �cho
echo "Armel est currenty non pris en charge"
faire �cho
Sortie
esac

########
# ARMHF
########
cas $ (uname -m) dans ArMV [6-9] l)
faire �cho
echo "armhf bras v7 conseils v8 v9 pris en charge"
faire �cho
esac

#############
# Intel / AMD
#############
cas $ (uname -m) pour x86_64 | i [4-6] 86)
faire �cho
echo "cartes Intel / Amd actuellement non pris en charge"
faire �cho
Sortie
esac

#####################################
OS de base #update avec le nouveau repo dans la liste
#####################################
faire �cho ""
faire �cho "------------------------------------------------ -------------- "
echo "Mise � jour des cl�s de r�f�rentiel Raspberry Pi ..."
faire �cho "------------------------------------------------ -------------- "
faire �cho ""
GPG --keyserver pgp.mit.edu --recv 8B48AD6246925553
gpg --export --armor 8B48AD6246925553 | apt-key add -
GPG --keyserver pgp.mit.edu --recv 7638D0442B90D010
gpg --export --armor 7638D0442B90D010 | apt-key add -
CBF8D6FD518E17E1 GPG --keyserver pgp.mit.edu
gpg --export --armor CBF8D6FD518E17E1 | apt-key add -
wget https://www.raspberrypi.org/raspberrypi.gpg.key
gpg --import raspberrypi.gpg.key | apt-key add -
wget https://archive.raspbian.org/raspbian.public.key
gpg --import raspbian.public.key | apt-key add -
for i in mise � jour mise � niveau propre; faire apt-get -y --force-oui "$ {} i"; termin�

#####################################
OS de base #update avec le nouveau repo dans la liste
#####################################
apt-get update

###################
# Notes / Avertissements
###################
faire �cho
cat << DELIM
�������������������Non Ment Pour L.a.m.p Installe

������������������L.A.M.P = Linux Apache Mysql PHP

�����������������CECI EST UN SCRIPT INSTALLER UNE FOIS

�������������IL EST PAS destin� � �tre ex�cut� PLUSIEURS FOIS

���������Ce script est Ment pour �tre ex�cut� sur une nouvelle installation de

�������������������������8 Debian (Jessie)

�����Si elle �choue pour quelque raison S'il vous pla�t rapport au kb3vgw@gmail.com

���S'il vous pla�t inclure toute sortie d'�cran, vous pouvez pour montrer o� il �choue

DELIM

################################################## #############################################
#Testing Pour la connexion Internet. Tir� de et modifi�e
#http: //www.linuxscrew.com/2009/04/02/tiny-bash-scripts-check-internet-connection-availability/
################################################## #############################################
faire �cho
echo "Ce script n�cessite Actuellement une connexion Internet"
faire �cho
wget -q --tries = 10 = 5 --timeout http://www.google.com -O /tmp/index.google &> / dev / null

si [ ! -s /tmp/index.google], puis
echo "Pas de connexion Internet. S'il vous pla�t v�rifier le c�ble Ethernet"
/ bin / rm /tmp/index.google
sortie 1
autre
echo "I Found Internet ... continue !!!!!"
/ bin / rm /tmp/index.google
fi
faire �cho
printf 'IP actuelle est:'; inet addr show dev eth0 ip | sed -n 's / ^ * inet * \ ([. 0-9] * \). * / \ 1 / p'
faire �cho

##############################
#SET Un red�marrage si Kernel Panic
##############################
cat> /etc/sysctl.conf << DELIM
kernel.panic = 10
DELIM

####################################
# Set fs � courir dans un lecteur virtuel de tempfs
####################################
cat >> / etc / fstab << DELIM
tmpfs / tmp tmpfs nodev, nosuid, mode = 1,777 0 0
tmpfs / var / tmp tmpfs nodev, nosuid, mode = 1,777 0 0
tmpfs / var / cache / apt / tmpfs archives size = 100M, par d�faut, noexec, nosuid, nodev, mode = 0755 0 0
DELIM

############################
# D�finir le niveau d'alimentation USB
############################
cat >> << DELIM /boot/config.txt

actuelle #usb max
usb_max_current = 1
DELIM

###############################
# D�sactiver le fichier de swap dphys
# Pour prolonger la dur�e de la carte SD
###############################
swapoff --all
apt-get -y retirer dphys-swapfile
rm -rf / var / swap

################################################## ###
son #fix usb / question nic afin interface r�seau obtient IP
################################################## ###
cat> / etc / network / interfaces << DELIM
lo auto eth0
iface lo inet bouclage
iNet le DHCP du iface

DELIM

#############################
#REGLAGES H�te / Nom de domaine
#############################
cat> / etc / hostname << DELIM
$ cs-r�p�teur
DELIM

#################
#Setup / Etc / hosts
#################
cat> / etc / hosts << DELIM
Localhost 127.0.0.1
:: 1 localhost ip6-localhost ip6-bouclage
FE00 :: 0 ip6-localnet
ff00 :: 0 ip6-mcastprefix
FF02 :: 1 IP6-allnodes
FF02 :: 2 IP6-allrouters

127.0.0.1 $ cs-r�p�teur

DELIM

#####################################
OS de base #update avec le nouveau repo dans la liste
#####################################
faire �cho ""
faire �cho "------------------------------------------------ -------------- "
echo "Mise � jour des cl�s de r�f�rentiel Raspberry Pi ..."
faire �cho "------------------------------------------------ -------------- "
faire �cho ""
GPG --keyserver pgp.mit.edu --recv 8B48AD6246925553
gpg --export --armor 8B48AD6246925553 | apt-key add -
GPG --keyserver pgp.mit.edu --recv 7638D0442B90D010
gpg --export --armor 7638D0442B90D010 | apt-key add -
CBF8D6FD518E17E1 GPG --keyserver pgp.mit.edu
gpg --export --armor CBF8D6FD518E17E1 | apt-key add -
wget https://www.raspberrypi.org/raspberrypi.gpg.key
gpg --import raspberrypi.gpg.key | apt-key add -
wget https://archive.raspbian.org/raspbian.public.key
gpg --import raspbian.public.key | apt-key add -
for i in mise � jour mise � niveau propre; faire apt-get -y --force-oui "$ {} i"; termin�

################################################## ##############################################
# R�glage apt_get d'utiliser le httpredirecter pour obtenir
# Pour avoir <APT> s�lectionner automatiquement un miroir proche de chez vous, utilisez le redirecteur Geo-IP dans votre
# Sources.list "deb http://httpredir.debian.org/debian/ Jessie principale".
# Voir http://httpredir.debian.org/ pour plus d'informations. Le redirecteur utilise le protocole HTTP redirections 302
# NON DNS pour servir du contenu de sorte est s�r � utiliser avec Google DNS.
# Voir aussi <qui httpredir.debian.org>. Ce service est identique � http.debian.net.
################################################## ###############################################
cat> �/etc/apt/sources.list� << DELIM
deb http://httpredir.debian.org/debian/ Jessie main contrib non-free
deb http://httpredir.debian.org/debian/ jessie-updates main contrib non-free
deb http://httpredir.debian.org/debian/ Jessie-backports main contrib non-free

DELIM

############
# Raspi Repo
################################################## #########################
# Mettre en propre locatif. Tous repos addon devraient �tre source.list.d dir sous
################################################## #########################
cat> /etc/apt/sources.list.d/raspi.list << DELIM
deb http://mirrordirector.raspbian.org/raspbian/ Jessie main contrib firmware RPI non-libre
DELIM

#############################
# SvxLink sortie Repo armhf
#############################
cat> "/etc/apt/sources.list.d/svxlink.list" << DELIM
Jessie la principale deb
DELIM

######################
OS de base #update
######################
for i in mise � jour mise � niveau propre, ne apt-get -y "$ {} i"; termin�

##########################
#Installing Deps de svxlink
##########################
apt-get install -y sqlite3 libopus0 alsa-utils vorbis-tools sox libsox-fmt-mp3 librtlsdr0 \
NTP libasound2 libspeex1 libgcrypt20 libpopt0 libgsm1 tcl8.6 tk8.6 alsa-base bzip2 \
sudo gpsd gpsd-Flite clients inetutils-syslogd wvdial �cran temps vim UUID install-info \
usbutils logrotate dialogue cron gawk surveillance python3-s�rie network-manager whiptail \
git-core wiringpi

#################
Svxlink #Install
#################
apt-get -y --force-oui installer remotetrx svxlink-serveur

#nettoyer
apt-get clean

############################################
Les fichiers de configuration d'origine de #Backup de base
############################################
mkdir -p / usr / share / examples / svxlink / conf
cp -rp / etc / svxlink / * / usr / share / examples / svxlink / conf

#adding utilisateur svxlink au groupe d'utilisateurs gpio
usermod -a -G gpio svxlink

################################################## ###
#Working Sur les sons pkgs pour la lib�ration future de svxlink
################################################## ###
wget https://github.com/kb3vgw/svxlink-sounds-fr_FR-heather/releases/download/15.11.2/svxlink-sounds-fr_FR-heather-16k-15.11.2.tar.bz2
svxlink-sons-fr_FR-bruy�res-16k-15.11.2.tar.bz2 tar
mv fr_FR-bruy�res 16k fr_FR
fr_FR mv / usr / share / svxlink / sons
rm svxlink-sons-fr_FR-bruy�res-16k-15.11.2.tar.bz2

##############################
#Install Courtoisie fichiers audio
##############################
https://github.com/kb3vgw/Svxlink-Courtesy_Tones/archive/15.10.tar.gz
goudron xjvf 15.10.tar.gz
mv Svxlink-Courtesy_Tones-15.10 Courtesy_Tones
Courtesy_Tones mv / usr / share / svxlink / sons /
rm 15.10.tar.gz

################################
#make Et Link Custome son Dir
################################
mkdir -p / root / sons / Custom_Courtesy_Tones
sons / Custom_Courtesy_Tones ln -s / root / sons / Custom_Courtesy_Tones / usr / share / svxlink /
mkdir -p / root / sons / Custom_Identification
ln -s / root / sons / Custom_identification / usr / share / svxlink / sons / Custom_Identification

#################################
# Marque et relier event.d locale dir
#################################
mkdir /etc/svxlink/local-events.d
ln -s /etc/svxlink/local-events.d /usr/share/svxlink/events.d/local

###########################
#Install Fichiers Logic personnalis�e
###########################
git clone https://github.com/kb3vgw/Svxlink-Custom-Logic.git
Svxlink-Custom-Logic / * /etc/svxlink/local-events.d cp
rm -rf Svxlink-Custom-Logic

################################################## #########
#Disable Bord carte son HDMI pas utilis� dans openrepeater
# / boot / config.txt et / etc / modules
################################################## #########
# / boot / config.txt
sed -i /boot/config.txt -e "s # dtparam = = audio sur # \ # dtparam = = audio sur #"

# / etc / modules
-i sed / etc / modules -e "# SND-bcm2835 # \ # SND-bcm2835 N �"

################################
#SET Jusqu'� son USB pour mixer alsa
################################
si (`grep" SND-usb-audio "/ etc / modules> / dev / null`!); puis
���ECHO / etc / modules "SND-USB-audio" >>
fi
FILE = / etc / modprobe.d / alsa-base.conf
sed "de / options SND-usb-audio index = -2 / les options SND-usb-audio index = 0 /" $ FILE> $ {FILE} .tmp
$ {FILE} .tmp de $ de mv {FILE}
if (! `grep" options SND-usb-audio nrpacks = 1 "$ {FILE}> / dev / null`); puis
��echo "nrpacks les options SND-usb-audio = 1 index = 0" >> $ {FILE}
fi

##########################################
#addon scripts suppl�mentaires pour le clonage du disque
##########################################
wget https://raw.githubusercontent.com/billw2/rpi-clone/master/rpi-clone
chmod + x RPI-clone
cp RPI-clone / usr / bin
rm RPI-clone

######################
#Install De Menu
#####################
git clone https://github.com/kb3vgw/svxlink-menu.git
chmod + x svxlink menu / svxlink_config
cp -r svxlink menu / svxlink_config / usr / bin
rm -rf svxlink menu

##############################################
# Activer New shellmenu pour les connexions sur les permis
# Pour la racine et seulement si le fichier existe
##############################################
cat >> << DELIM /root/.profile

if [-f / usr / bin / svxlink_config]; puis
��������. / usr / bin / svxlink_config
fi

DELIM

#######################
#Active Service Systemd
#######################
echo "Activation de la Svxlink de Service Daemon"
systemctl permettre svxlink.service

#######################
#Active Service Systemd
#######################
echo "Activation de la Svxlink Remotetrx systemd d�mon du service"
systemctl permettre remotetrx.service

############################################
#reboot sysem pour tous les changements prennent effet
############################################
echo "syst�me de red�marrer for full modifications prennent effet"
red�marer

) | tee /root/install.log