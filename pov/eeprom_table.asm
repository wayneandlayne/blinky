; Wayne and Layne present:
; Blinky GRID, firmware revision 1.01
; Last Updated: January 26, 2012
; Copyright (c) 2012, Wayne and Layne, LLC
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


eeprom_table code 0xF000 ;eeprom
	de d'6' ; this is the number of messages stored in the eeprom
	
        de 0x91, d'16', 0x18,0x3C,0x3E,0x1F,0x3E,0x3C,0x18,0x00,0x60,0xF0,0xF8,0x7C,0xF8,0xF0,0x60,0x00; Two hearts, vertically offset to use all 8 LEDs
        de B'00100001', d'10', 0x0B,0x15,0x12,0x17,0x14,0x22, 0x29, 0x19,0x18,0x1F; BLINKY POV
	;de B'10000001', d'13', 0x01, 0x02,0x04,0x08,0x10,0x20,0x30,0x20, 0x10, 0x08 , 0x04,0x02,0x01; slanty lines
        de 0x91, d'14', 0x80,0x40,0x20,0x10,0x08,0x04,0x02,0x01,0x02,0x04,0x08,0x10,0x20,0x40; better slanty lines that use all eight leds
	de B'00010001', 0x07, 0x11, 0x0e, 0x15, 0x15, 0x18, 0x29, 0x29 ; HELLO
	de B'11111101', d'14', 0xAA, 0x55,0xAA,0x55,0xAA,0x55,0xAA,0x55, 0xAA, 0x55 , 0xAA,0x55,0xAA,0x55; ;checkerboard

	;de B'00100001', d'14', 0x16, 0x0a, 0x14, 0x03, 0x1b, 0x29, 0x0F, 0x0A, 0x12, 0x1B, 0x03, 0x29, 0x29, 0x29; MAKER FAIRE
	;de B'00100001', d'14', 0x16, 0x0a, 0x14, 0x03, 0x1b, 0x29, 0x1C, 0x11, 0x0e, 0x0d, 0x29, 0x29, 0x29, 0x29; MAKER SHED
	
	de B'11010011', d'01', 0xAA; //larson, low power, good speed.
	;de B'01010011', d'01', 0xAA; //larson, high power, good speed.
	;de B'11110011', d'01', 0xAA; //larson, low power, slooooow
	;de B'11001011', d'01', 0xAA; //larson, low power, fast!

	END

