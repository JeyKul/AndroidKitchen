#!/usr/bin/env bash

## EXTRACT FOR AP, BL, CP, HOME_CSC FILES ##

# UNPACK AP ARCHIVE #

mkdir -p $EXTR $AP $CP $CSC $BL

tar -xvf $EXTR/AP*.tar.md5 -C $AP
tar -xvf $EXTR/CP*.tar.md5 -C $CP
tar -xvf $EXTR/BL*.tar.md5 -C $BL
tar -xvf $EXTR/CSC*.tar.md5 -C $CSC