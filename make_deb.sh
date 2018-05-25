#!/bin/bash

# Control of param
if [ "$1" != "diod" ] && [ "$1" != "power" ] && [ "$1" != "box" ]; then
  echo "Script for detection has name: diod|power|box."
  exit 1
else
  scriptName=$1
fi
# Path to home
HOMEPATH="$(readlink -f .)"

mkdir -p work
PATH_TO_WORK="$(readlink -f work)"

mkdir -p Package
PATH_TO_PACKAGE="$(readlink -f Package)"

# Make structure for filebeat.deb
cd ${PATH_TO_WORK}
mkdir -p DEBIAN
mkdir -p usr/bin
mkdir -p etc/systemd/system

cp -a -n /home/pc/DP/GPIO/$scriptName.py ${PATH_TO_WORK}/usr/bin/$scriptName.py

filename=${PATH_TO_WORK}/etc/systemd/system/$scriptName.service
test -f $filename || touch $filename

filename=${PATH_TO_WORK}/DEBIAN/control
test -f $filename || touch $filename

filename=${PATH_TO_WORK}/DEBIAN/changelog
test -f $filename || touch $filename

filename=${PATH_TO_WORK}/DEBIAN/copyright
test -f $filename || touch $filename

#filename=${PATH_TO_WORK}/DEBIAN/postinst
#test -f $filename || touch $filename
#chmod 775 $filename


echo "[Unit]
Description=$scriptName
Wants=network-online.target
After=network-online.target

[Service]
Type=simple
ExecStart=/usr/bin/python  /usr/bin/$scriptName.py
Restart=always
ExecStop=/bin/kill -s TERM \$MAINPID

[Install]
WantedBy=multi-user.target" > ${PATH_TO_WORK}/etc/systemd/system/$scriptName.service


echo "Package: nsw-$scriptName
Version: 1.0
Section: web
Priority: optional
Depends: libc6 (>= 2.2.4-4)
Architecture: all
Essential: no
Maintainer: Ondrej Fuchs
Description: Package for run check of open box
  Package is make for NSW run on Rpi" > ${PATH_TO_WORK}/DEBIAN/control

echo "Files: *
Copyright: $scriptName
License: via LICENCE.txt" > ${PATH_TO_WORK}/DEBIAN/copyright

echo "# Changelog
All notable changes to this project will be documented in this file.
" > ${PATH_TO_WORK}/DEBIAN/changelog

#echo "#!/bin/sh
#sudo systemctl enable $scriptName
#sudo service $scriptName start
#" > ${PATH_TO_WORK}/DEBIAN/postinst

cd ${PATH_TO_WORK}
find * -type f ! -regex '^DEBIAN/.*' -exec md5sum {} \; > DEBIAN/md5sums

echo "App: Structure of folder is ready to make .deb"

cd ${PATH_TO_WORK}
cd ..
sudo chown -hR root:root work
sudo dpkg-deb -b work nsw-$scriptName.deb

echo "App: Build nsw-$scriptName.deb"

sudo rm -r -f ${PATH_TO_WORK}

mv  nsw-$scriptName.deb ${PATH_TO_PACKAGE}/

cp ${PATH_TO_PACKAGE}/nsw-$scriptName.deb  /home/pc/Dropbox/DP/konfigurace/ansible/roles/detection/files/


              
