Uiliser une image Debian Jessie :

LIEN OFFICIEL RASPBIAN JESSIE LITE (pas de serveur X)
https://downloads.raspberrypi.org/raspbian_lite_latest

<<<<<<< Updated upstream
####Procedure:
- Download Raspbian Jessie Lite Image (link above).
- Write Raspbian Jessie Lite image to SD Card.
- Insert SD card into RPI, Connect Network, connect sound card, and Power to Pi
- Obtain Dynamic IP Address
- Connect to Pi using SSH.  Login as pi (password raspberry).
- sudo su to root
- Execute "apt-get update && apt-get dist-upgrade"
- Use raspi-config to configure Timezone, Locale, Check GPU Mem(0), and Expand FS
- enable the following kernel modules spi-bcm2708 i2c-bcm2708 i2c-dev w1-gpio w1-therm
- Reboot Pi.
- Connect to Pi using SSH.  Login as pi (password raspberry).
- sudo su to root
- Transfer svxlink install_script to Pi.  (wget or scp or flashdrive)
- wget https://raw.githubusercontent.com/kb3vgw/svxlink-scripts/master/RELEASE/RaspberryPi/Raspi2-RaspBian-Jessie-SvxLink-Release-embedded-pkg-install.sh
- Edit SvxLink install_script (nano install_script).   Set Callsign.
- Change permissions on install_script (chmod +x install_script)
- Execute install_script ( ./install_script )
- Perform final tasks.... 
- Reboot
=======
####Procèdure:
- Télécharger l'image Rasbian Jessie Lite (lien ci-dessus).
- Ecrire l'image Raspbian Jessie Lite sur la carte SD Card.
- Insérer la carte SD  dans le Raspberry, connecter le réseau, connecter une carte son USB, finir par l'alimentation
- Trouver l'adresse IP Dynamic
- Connectez vous sur le Raspberry en utilisant SSH.  Le Login est pi (et mot de passe raspberry).
- "sudo su" pour passer en root
- Exécuter "apt-get update && apt-get dist-upgrade"
- Utiliser "raspi-config" pour configurer le Timezone, Locale, Check GPU Mem(0), et Expand FS
- Activer les modules Kernel suivants: spi-bcm2708 i2c-bcm2708 i2c-dev w1-gpio w1-therm
- Rebooter le Raspberry Pi.
- Connecter le Raspberry en utilisant SSH. Login pi (mot de passe: raspberry).
- "sudo su" pour ce mettre en root
- Transferer le fichier install svxlink  install_script ver le Raspberry.  (wget ou scp ou flashdrive) avec wget utiliser la commande ci-dessous (copier/coller):
- wget https://raw.githubusercontent.com/kb3vgw/svxlink-scripts/master/RELEASE/RaspberryPi/Raspi2-RaspBian-Jessie-SvxLink-Release-embedded-pkg-install-french.sh
- Editer SvxLink install_script "nano install_script".   Définir l'indicatif (Callsign).
- Changer les permissions au niveau du fichier install_script avec la command "chmod +x install_script"
- Exécuter le script install_script  "./install_script"
- Attendre le deroulement de l'installation.... 
- Reboot automatique
>>>>>>> Stashed changes

