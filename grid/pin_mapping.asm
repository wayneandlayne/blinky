; Wayne and Layne present:
; Blinky GRID, firmware revision 1.01
; Last Updated: June 6, 2011
; Copyright (c) 2011, Wayne and Layne, LLC
;
; This program is free software; you can redistribute it and/or modify
; it under the terms of the GNU General Public License as published by
; the Free Software Foundation; either version 2 of the License, or
; (at your option) any later version.
;
; This program is distributed in the hope that it will be useful,
; but WITHOUT ANY WARRANTY; without even the implied warranty of
; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
; GNU General Public License for more details.
;
; You should have received a copy of the GNU General Public License along
; with this program; if not, write to the Free Software Foundation, Inc.,
; 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
;
;
; For pictures, instructions, and software, please visit:
; http://www.wayneandlayne.com/projects/blinky/

    include "P16F1823.INC"


pin_mapping_section code 


pin_mapping
	global pin_mapping
				BRW
mapping_table

                RETLW   0x40
                RETLW   0x30
                RETLW   0x20
                RETLW   0x10

                RETLW   0x21
                RETLW   0x70
                RETLW   0x60
                RETLW   0x50

                RETLW   0x61
                RETLW   0x51
                RETLW   0x41
                RETLW   0x31

                RETLW   0x52
                RETLW   0x42
                RETLW   0x32
                RETLW   0x71

                RETLW   0x53
                RETLW   0x43
                RETLW   0x72
                RETLW   0x62

                RETLW   0x64
                RETLW   0x54
                RETLW   0x73
                RETLW   0x63

                RETLW   0x76
                RETLW   0x75
                RETLW   0x65
                RETLW   0x74
;This flips the image over the vertical.
;                RETLW   0x01
;                RETLW   0x02
;                RETLW   0x03
;                RETLW   0x04
;                RETLW   0x05
;                RETLW   0x06
;                RETLW   0x07
;                RETLW   0x12
;                RETLW   0x13
;                RETLW   0x14
;                RETLW   0x15
;                RETLW   0x16
;                RETLW   0x17
;                RETLW   0x23
;                RETLW   0x24
;                RETLW   0x25
;                RETLW   0x26
;                RETLW   0x27
;                RETLW   0x34
;                RETLW   0x35
;                RETLW   0x36
;                RETLW   0x37
;                RETLW   0x45
;                RETLW   0x46
;                RETLW   0x47
;                RETLW   0x56
;                RETLW   0x57
;                RETLW   0x67

	end
