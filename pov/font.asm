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


	udata 
char_address res 1

	extern char_to_show, slice, char_index

font_section code

load_slice_from_font
		global	load_slice_from_font
		banksel	char_to_show
		movf	char_to_show, w

        banksel char_address
        clrf    char_address
        addwf   char_address, f ; 
        addwf   char_address, f ; 
        addwf   char_address, f ; 
        addwf   char_address, f ; 
        addwf   char_address, f ; 
        ;char_address = char_num * 5

		banksel	char_index
		movf	char_index, w
		banksel	char_address
		addwf	char_address, w
	
		;w = char_num*5 + char_index

        ;let's start reading from progmem
        banksel FSR0L
        movwf  FSR0L

        movlw   B'10000011' ; we want to read from 0x300, so the top byte needs to be 0x3, but we have to set the highestth bit to mean "read from progmem"
        movwf   FSR0H

        ;;right now, INDF0 points us to the byte of the font entry we want

		banksel INDF0
		movf	INDF0, w
		banksel	slice
		movwf	slice

	end

