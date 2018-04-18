#!/bin/bash

scriptName=$1

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

cp -a -n /home/pc/DP/GPIO/$scriptName.py ${PATH_TO_WORK}/usr/bin/diod.py

filename=${PATH_TO_WORK}/etc/systemd/system/$scriptName.service
test -f $filename || touch $filename

filename=${PATH_TO_WORK}/DEBIAN/control
test -f $filename || touch $filename

filename=${PATH_TO_WORK}/DEBIAN/changelog
test -f $filename || touch $filename

filename=${PATH_TO_WORK}/DEBIAN/copyright
test -f $filename || touch $filename

filename=${PATH_TO_WORK}/DEBIAN/postinst
test -f $filename || touch $filename
chmod 775 $filename

echo "[Unit]
Description=$scriptName
Documentation=Check open the box
Wants=network-online.target
After=network-online.target

[Service]
ExecStart=/usr/bin/python  /usr/bin/$scriptName.py
Restart=always

[Install]
WantedBy=multi-user.target" > ${PATH_TO_WORK}/etc/systemd/system/diod.service

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

echo "#!/bin/sh
sudo systemctl enable $scriptName
sudo service $scriptName start
" > ${PATH_TO_WORK}/DEBIAN/postinst

cd ${PATH_TO_WORK}
find * -type f ! -regex '^DEBIAN/.*' -exec md5sum {} \; > DEBIAN/md5sums

echo "App: Structure of folder is ready to make .deb"

cd ${PATH_TO_WORK}
cd ..
sudo chown -hR root:root work
# dpkg didn't accept "_"
# sudo dpkg-deb -b filebeat nsw-filebeat-1.0.deb
sudo dpkg-deb -b work nsw-$scriptName.deb

echo "App: Build $scriptName.deb"

sudo rm -r -f ${PATH_TO_WORK}

mv  nsw-$scriptName.deb ${PATH_TO_PACKAGE}/

              
