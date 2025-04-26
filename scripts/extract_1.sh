#!/usr/bin/env bash

## EXTRACT FOR AP, BL, CP, HOME_CSC FILES ##

# UNPACK AP ARCHIVE #

mkdir -p $EXTR $AP $CP $CSC $BL

tar -xvf $TARGETDL/AP*.tar.md5 -C $AP
tar -xvf $TARGETDL/CP*.tar.md5 -C $CP
tar -xvf $TARGETDL/BL*.tar.md5 -C $BL
tar -xvf $TARGETDL/CSC*.tar.md5 -C $CSC