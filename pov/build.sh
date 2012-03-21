#!/bin/bash
#
# Build script for Blinky POV bootloader, written in assembly
# Written by Matthew Beckler and Adam Wolf, for Wayne and Layne, LLC
# Released under the GNU General Public License, version 2 (or later, your choice)
# Last updated: January 26, 2012

MPLABX="/opt/microchip/mplabx"
export PATH="$PATH:/usr/hitech/picc/9.82/bin:/usr/hitech/picc/9.81/bin:/usr/share/pk2/:$HOME/installers/pk2cmdv1-20Linux2-6:$MPLABX/mpasmx"

PIC="16F1823"
PROJECT="blinky_pov"
SOURCE_PARTS="larson eeprom_table font messages blinky_pov uart delay  button"
WITH_BOOTLOADER=1
LINKER_FILE="16F1823_g.lkr"

LINKER_OBJECTS=""
TERMINAL=gnome-terminal


if [ -z "$WITH_BOOTLOADER" ]; then
    echo "without bootloader"
    SOURCE_PARTS="$SOURCE_PARTS sim_font_table"
fi

if [ `whoami` == "wolf" ]; then
    SVN_BASE="/home/wolf"
elif [ `whoami` == "matthew" ]; then
    SVN_BASE="/home/matthew/repo"
else
    echo "Unknown user" 
    exit 1
fi

tty -s; if [ $? -ne 0 ]; then $TERMINAL -e "$0"; exit; fi

cd $SVN_BASE/wnl_svn/blinky/code/pov

for PART in $SOURCE_PARTS; do
    echo "Compiling $PART.asm..."
    mpasmx   -p$PIC -u -l"$PART.lst" -e"$PART.err"  -o"$PART.o" $PART.asm 

    LINKER_OBJECTS="$LINKER_OBJECTS $PART.o"
    if `grep ^Error $PART.err > /dev/null`; then
        echo ""
        cat $PART.err
        echo ""
        echo "Problem while compiling $PART.asm, exiting!"
        sleep 5
        exit 1
    else
        echo " OK!"
    fi
done

mplink $LINKER_FILE  -p16f1823  -v -m$PROJECT.map -o$PROJECT.cof $LINKER_OBJECTS

if [ $? -ne 0 ]; then
    echo "Problem while linking, exiting!"
    exit 1
fi

if [ $WITH_BOOTLOADER ]; then
    
    cd ../bootloader/
    ./build.sh
    cp bootloader_pov.hex ../pov/bootloader.hex

    cd -

    # combine bootloader and user code into a single hex file
    hexmate bootloader.hex $PROJECT.hex > combined.hex
    HEXFILE=combined.hex
else
    echo "booyah"
    HEXFILE=$PROJECT.hex
fi

pk2cmd -PPIC$PIC -E -J -F $HEXFILE -M -R -W

# -P to specify which part
# -E to erase part
# -J Show progress percent complete
# -F is hex file
# -M program all memories and verify
# -T external power, and keep power on after program
# -R turn the pic on after program
# -W for external power

#./pic_power.sh reset
#sleep 1
#./slow_transfer.py break

echo "cleaning up"
rm -f blinky_grid.{cof,hxl,lst,p1,pre,sdb,sym}
rm -f blinky_pov.{cof,hxl,lst,p1,pre,sdb,sym}
rm -f bootloader.{cof,hxl,lst,p1,pre,sdb,sym}
rm -f startup*
rm -f funclist
