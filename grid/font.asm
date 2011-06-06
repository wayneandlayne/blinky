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


	extern set_led

;Variable space reservations;
    udata
temp_val res 1
char_num res 1
char_index res 1
i res 1
j res 1
tagalong_k res 1
;;code!



font    code
load_char
	global	load_char
        ;this takes a charnumber in w and sets the appropriate leds
        banksel char_num
        movwf   char_num

		;if we have a space character, return immediately
		sublw	0x29
		btfsc	STATUS, Z
		return
		movf	char_num, w


        banksel char_index
        clrf    char_index
        addwf   char_index, f 
        addwf   char_index, f 
        addwf   char_index, f 
        addwf   char_index, f 
        addwf   char_index, f 
        ;char_index = char_num * 5
        movf    char_index, w

        ;let's start reading from progmem
        banksel FSR0L
        movwf  FSR0L

        movlw   B'10000011' ; we want to read from 0x300, so the top byte needs to be 0x3, but we have to set the highestth bit to mean "read from progmem"
        movwf   FSR0H


	

        ;;right now, INDF0 points us to the first byte of the font entry we want

		;;iterate over each bit of all 5 bytes, setting leds of any set bits


		banksel tagalong_k
		clrf	tagalong_k
		banksel i
		clrf i		
next_i
		
		banksel j
		clrf	j
		moviw	FSR0++
		banksel temp_val
		movwf	temp_val
	
next_j
		banksel	tagalong_k
		incf	tagalong_k, f
		banksel temp_val
		btfsc	temp_val, 6
		call	set_the_led
		lslf	temp_val, f
		banksel	j
		incf	j, f
		movf	j, w
		sublw	8
		btfss	STATUS, Z
		goto	next_j
		
		banksel i
		incf	i, f
		movf	i, w
		sublw	5
		btfss STATUS, Z
		goto	next_i
done_w_all_5_bytes	
		return

set_the_led
	;at this point, tagalong_k is set to the led number
		banksel tagalong_k
		movf	tagalong_k, w
		addlw	7 ; offset one row and one pixel to center the char
		call set_led
		return


	END
