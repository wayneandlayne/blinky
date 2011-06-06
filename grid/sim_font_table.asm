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

font_table code 0x0300
        db 0x0f, B'00111110', 0x0f, B'01010001', 0x0f, B'01001001', 0x0f, B'01000101', 0x0f, B'00111110' ; 0x00 0       
        db 0x0f, B'00000000', 0x0f, B'01000010', 0x0f, B'01111111', 0x0f, B'01000000', 0x0f, B'00000000' ; 0x01 1
        db 0x0f, B'01000010', 0x0f, B'01100001', 0x0f, B'01010001', 0x0f, B'01001001', 0x0f, B'01000110' ; 0x02 2
        db 0x0f, B'00100010', 0x0f, B'01000001', 0x0f, B'01001001', 0x0f, B'01001001', 0x0f, B'00110110' ; 0x03 3
        db 0x0f, B'00001100', 0x0f, B'00001010', 0x0f, B'01001001', 0x0f, B'01111111', 0x0f, B'01001000' ; 0x04 4
        db 0x0f, B'00101111', 0x0f, B'01001001', 0x0f, B'01001001', 0x0f, B'01001001', 0x0f, B'00110001' ; 0x05 5
        db 0x0f, B'00111110', 0x0f, B'01001001', 0x0f, B'01001001', 0x0f, B'01001001', 0x0f, B'00110010' ; 0x06 6
        db 0x0f, B'00000001', 0x0f, B'01110001', 0x0f, B'00001001', 0x0f, B'00000101', 0x0f, B'00000011' ; 0x07 7
        db 0x0f, B'00110110', 0x0f, B'01001001', 0x0f, B'01001001', 0x0f, B'01001001', 0x0f, B'00110110' ; 0x08 8
        db 0x0f, B'00100110', 0x0f, B'01001001', 0x0f, B'01001001', 0x0f, B'01001001', 0x0f, B'00111110' ; 0x09 9
        db 0x0f, B'01111110', 0x0f, B'00001001', 0x0f, B'00001001', 0x0f, B'00001001', 0x0f, B'01111110' ; 0x0A A
        db 0x0f, B'01111111', 0x0f, B'01001001', 0x0f, B'01001001', 0x0f, B'01001001', 0x0f, B'00110110' ; 0x0B B
        db 0x0f, B'00111110', 0x0f, B'01000001', 0x0f, B'01000001', 0x0f, B'01000001', 0x0f, B'00100010' ; 0x0C C
        db 0x0f, B'01111111', 0x0f, B'01000001', 0x0f, B'01000001', 0x0f, B'01000001', 0x0f, B'00111110' ; 0x0D D
        db 0x0f, B'01111111', 0x0f, B'01001001', 0x0f, B'01001001', 0x0f, B'01001001', 0x0f, B'01000001' ; 0x0E E
        db 0x0f, B'01111111', 0x0f, B'00001001', 0x0f, B'00001001', 0x0f, B'00001001', 0x0f, B'00001001' ; 0x0F F
        db 0x0f, B'00111110', 0x0f, B'01000001', 0x0f, B'01001001', 0x0f, B'01001001', 0x0f, B'00111010' ; 0x10 G
        db 0x0f, B'01111111', 0x0f, B'00001000', 0x0f, B'00001000', 0x0f, B'00001000', 0x0f, B'01111111' ; 0x11 H
        db 0x0f, B'00000000', 0x0f, B'01000001', 0x0f, B'01111111', 0x0f, B'01000001', 0x0f, B'00000000' ; 0x12 I
        db 0x0f, B'00110000', 0x0f, B'01000000', 0x0f, B'01000001', 0x0f, B'00111111', 0x0f, B'00000001' ; 0x13 J
        db 0x0f, B'01111111', 0x0f, B'00001000', 0x0f, B'00001000', 0x0f, B'00010100', 0x0f, B'01100011' ; 0x14 K
        db 0x0f, B'00000000', 0x0f, B'01111111', 0x0f, B'01000000', 0x0f, B'01000000', 0x0f, B'01000000' ; 0x15 L
        db 0x0f, B'01111111', 0x0f, B'00000010', 0x0f, B'00001100', 0x0f, B'00000010', 0x0f, B'01111111' ; 0x16 M
        db 0x0f, B'01111111', 0x0f, B'00000010', 0x0f, B'00001100', 0x0f, B'00010000', 0x0f, B'01111111' ; 0x17 N
        db 0x0f, B'00111110', 0x0f, B'01000001', 0x0f, B'01000001', 0x0f, B'01000001', 0x0f, B'00111110' ; 0x18 O
        db 0x0f, B'01111111', 0x0f, B'00001001', 0x0f, B'00001001', 0x0f, B'00001001', 0x0f, B'00000110' ; 0x19 P
        db 0x0f, B'00111110', 0x0f, B'01000001', 0x0f, B'01010001', 0x0f, B'00100001', 0x0f, B'01011110' ; 0x1A Q
        db 0x0f, B'01111111', 0x0f, B'00001001', 0x0f, B'00011001', 0x0f, B'00101001', 0x0f, B'01000110' ; 0x1B R
        db 0x0f, B'01000110', 0x0f, B'01001001', 0x0f, B'01001001', 0x0f, B'01001001', 0x0f, B'00110001' ; 0x1C S
        db 0x0f, B'00000001', 0x0f, B'00000001', 0x0f, B'01111111', 0x0f, B'00000001', 0x0f, B'00000001' ; 0x1D T
        db 0x0f, B'00111111', 0x0f, B'01000000', 0x0f, B'01000000', 0x0f, B'01000000', 0x0f, B'00111111' ; 0x1E U
        db 0x0f, B'00011111', 0x0f, B'00100000', 0x0f, B'01000000', 0x0f, B'00100000', 0x0f, B'00011111' ; 0x1F V
        db 0x0f, B'00111111', 0x0f, B'01000000', 0x0f, B'00111000', 0x0f, B'01000000', 0x0f, B'00111111' ; 0x20 W
        db 0x0f, B'01100011', 0x0f, B'00010100', 0x0f, B'00001000', 0x0f, B'00010100', 0x0f, B'01100011' ; 0x21 X
        db 0x0f, B'00000111', 0x0f, B'00001000', 0x0f, B'01110000', 0x0f, B'00001000', 0x0f, B'00000111' ; 0x22 Y
        db 0x0f, B'01100001', 0x0f, B'01010001', 0x0f, B'01001001', 0x0f, B'01000101', 0x0f, B'01000011' ; 0x23 Z
        db 0x0f, B'00000000', 0x0f, B'00000000', 0x0f, B'01100000', 0x0f, B'01100000', 0x0f, B'00000000' ; 0x24 .
        db 0x0f, B'00000000', 0x0f, B'00000000', 0x0f, B'01011111', 0x0f, B'00000000', 0x0f, B'00000000' ; 0x25 !
        db 0x0f, B'00110110', 0x0f, B'01001001', 0x0f, B'01010101', 0x0f, B'00100010', 0x0f, B'01010000' ; 0x26 &
        db 0x0f, B'00000010', 0x0f, B'00000001', 0x0f, B'01010001', 0x0f, B'00001001', 0x0f, B'00000110' ; 0x27 ?
        db 0x0f, B'00000000', 0x0f, B'00000000', 0x0f, B'01010000', 0x0f, B'00110000', 0x0f, B'00000000' ; 0x28 ,
	END
