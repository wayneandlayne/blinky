#!/bin/bash
#
# Build script for Blinky POV/GRID bootloader, written in C using the PICC compiler
# This script programs the specified bootloader hex file to the microcontroller
# Written by Matthew Beckler and Adam Wolf, for Wayne and Layne, LLC
# Released under the GNU General Public License, version 2 (or later, your choice)
# Last updated: June 6, 2011

export PATH="$PATH:/usr/share/pk2:$HOME/installers/pk2cmdv1-20Linux2-6"

if [ $# -ne 1 ]; then
    echo "Usage:    $0 hexfile"
    exit 1
fi

# -P to specify which part
# -E to erase part
# -J Show progress percent complete
# -F is hex file
# -M program all memories and verify
# -R turn the pic on after program

# -W for external power
# -T for internal power and keep it powered after programming
pk2cmd -PPIC16F1823 -E -J -F $1 -M -R -T
