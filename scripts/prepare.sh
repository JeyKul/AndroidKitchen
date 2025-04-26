#!/usr/bin/env bash

# MESSAGE #
echo "setting up workspace "

# CREATE WORKSPACE FOLDER TO KEEP ROOT CLEAR #
mkdir -p $WKSPCE

# CREATE FOLDER INSIDE WORKSPACE #
mkdir -p $PRJCT $DWNLD

mkdir -p $LOG

# DOWNLOAD LPUNPACK AND SIMG2IMG #

mkdir -p $WKSPCE/bin

wget -N https://github.com/unix3dgforce/lpunpack/raw/refs/heads/master/lpunpack.py -O $WKSPCE/bin/lpunpack

chmod +x $WKSPCE/bin/lpunpack

PATH=$WKSPCE/bin:$PATH


LATEST_URL=$(curl -s https://api.github.com/repos/JeyKul/android-simg2img/releases/latest | jq -r '.assets[] | select(.name | endswith(".tar.gz")) | .browser_download_url')

wget -q $LATEST_URL -O /tmp/simg_tools.tar.gz && \
mkdir -p $WKSPCE/bin && \
tar -xzf /tmp/simg_tools.tar.gz -C $WKSPCE/bin/

rm /tmp/simg_tools.tar.gz
