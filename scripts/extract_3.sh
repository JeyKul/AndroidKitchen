#!/usr/bin/env bash

for img in super.img prism.img optics.img omr.img; do
    simg2img "$EXTRPRJ/$img"
done


lpunpack $EXTRPRJ/super.raw.img $PARTPRJ