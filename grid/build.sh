#!/bin/bash
#
# Build script for Blinky GRID userland code, written in assembly
# Written by Matthew Beckler and Adam Wolf, for Wayne and Layne, LLC
# Released under the GNU General Public License, version 2 (or later, your choice)
# Last updated: June 6, 2011

MPLABX="/opt/microchip/mplabx"
export PATH="$PATH:/usr/hitech/picc/9.80/bin:/usr/hitech/picc/9.80a/bin:/usr/share/pk2/:$HOME/installers/pk2cmdv1-20Linux2-6:$MPLABX/mpasmx"

PIC="16F1823"
PROJECT="blinky_grid"
SOURCE_PARTS="marquee eeprom_table font messages blinky_grid uart set_led display delay pin_mapping button"

LINKER_FILE="16F1823_g.lkr"

LINKER_OBJECTS=""
TERMINAL=gnome-terminal


if [ `whoami` == "wolf" ]; then
    SVN_BASE="/home/wolf"
else
    echo "Unknown user" 
    exit 1
fi

tty -s; if [ $? -ne 0 ]; then $TERMINAL -e "$0"; exit; fi

cd $SVN_BASE/wnl_svn/blinky/code/grid

for PART in $SOURCE_PARTS; do
    echo "Compiling $PART.asm..."
    mpasmx   -p$PIC -u -l"$PART.lst" -e"$PART.err"  -o"$PART.o" $PART.asm 

    LINKER_OBJECTS="$LINKER_OBJECTS $PART.o"
    if `grep ^Error $PART.err > /dev/null`; then
        echo ""
        cat $PART.err
        echo ""
        echo "Problem while compiling $PART.asm, exiting!"
        exit 1
    else
        echo " OK!"
    fi
done

#mplink $LINKER_FILE  -p16f1823  -w   -z__MPLAB_BUILD=1  -o$PROJECT.cof $PROJECT.o     
mplink $LINKER_FILE  -p16f1823  -v -m$PROJECT.map -o$PROJECT.cof $LINKER_OBJECTS

if [ $? -ne 0 ]; then
    echo "Problem while linking, exiting!"
    exit 1
fi


cd ../bootloader/
./build.sh
cp bootloader_grid.hex ../grid/bootloader.hex

cd -

# combine bootloader and user code into a single hex file
hexmate bootloader.hex $PROJECT.hex > combined.hex


#pk2cmd -PPIC$PIC -E -J -F $PROJECT.hex -M -R -W
pk2cmd -PPIC$PIC -E -J -F combined.hex -M -R -W

# -P to specify which part
# -E to erase part
# -J Show progress percent complete
# -F is hex file
# -M program all memories and verify
# -T keep power on after program
# -R turn the pic on after program
# -W for external power

#./pic_power.sh reset
#sleep 1
#./slow_transfer.py break

echo "cleaning up"
rm -f blinky.{cof,hxl,lst,p1,pre,sdb,sym}
#rm -f bootloader.{cof,hxl,lst,p1,pre,sdb,sym}
#rm -f startup*
#rm -f funclist
