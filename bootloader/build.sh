#!/bin/bash
#
# Build script for Blinky POV/GRID bootloader, written in C using the PICC compiler
# Written by Matthew Beckler and Adam Wolf, for Wayne and Layne, LLC
# Released under the GNU General Public License, version 2 (or later, your choice)
# Last updated: June 6, 2011

export PATH="$PATH:/usr/hitech/picc/9.81/bin:/usr/hitech/picc/9.80/bin:/usr/hitech/picc/9.80a/bin:/usr/share/pk2/:$HOME/installers/pk2cmdv1-20Linux2-6"

# compile bootloader code for POV units
picc --chip=16F1823 -Q --ROM=000-3FF -DPOV bootloader.c 
if [ $? -ne 0 ]; then
    echo "Problem while compiling bootloader, exiting!"
    exit 1
fi
mv bootloader.hex bootloader_pov.hex

# compile bootloader code for GRID units
picc --chip=16F1823 -Q --ROM=000-3FF -DGRID bootloader.c 
if [ $? -ne 0 ]; then
    echo "Problem while compiling bootloader, exiting!"
    exit 1
fi
mv bootloader.hex bootloader_grid.hex

echo "Cleaning up"
rm -f bootloader.{cof,hxl,lst,p1,pre,sdb,sym,as}
rm -f startup*
rm -f funclist

