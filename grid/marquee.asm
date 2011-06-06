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


	extern set_led, marquee_index, clear_display

;Variable space reservations;
    udata
temp_val res 1
char_num res 1
char_index res 1

lines res 1
j res 1
tagalong_k res 1
temp_marquee_index res 1 
;;code!



marquee_section    code
marquee_char
	global	marquee_char
        ;this takes a charnumber in w and sets the appropriate leds
        banksel char_num
        movwf   char_num



		;; if the marquee index is 0, we want to clear and return.

		;;if the marquee_index is 1, we want to read 1 line of the character, and put it in the last row.
		;		only read 1 line, and set led_offset to 8*6
		; if the marquee index is 2, we want to read 2 lines of the character, and put it into the last two rows
		;		only read 2 lines, and set led_offset to 8*5


		;;if the marquee_index is 5, we want to read all 5 lines of the character, and put it in the last 5 rows.
		;;if the marquee_index is 7, we want to read all 5 lines of the character, and put it in the first 5 rows.
		;;if the marquee index is 11, we want to read only the last line of the character, and put it in the first row.



		sublw	0x29 ;space
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

		;;if marquee_index is <5 or >7, we want to change i
		banksel marquee_index
		movf	marquee_index, w
		sublw	4
		btfsc	STATUS, C ;;this is a NOT BORROW bit, so if it's set, it didn't borrow, so it's >= 5
		goto	marquee_index_less_than_5

		banksel marquee_index
		movf	marquee_index, w
		sublw	7
		btfsc	STATUS, C ;;this is a NOT BORROW bit, so if it's set, it didn't borrow, so it's <= 7
		goto	marquee_index_is_5_through_7_inclusive
		goto	marquee_index_greater_than_7

marquee_index_is_5_through_7_inclusive
		banksel lines
		movlw	5
		movwf	lines ; lines is number of lines of the thing to read
		banksel marquee_index
		movf	marquee_index, w
		brw
		nop 
		addlw	8
		addlw	8
		addlw	8
		addlw	8
		addlw	8
		addlw	8
		banksel	tagalong_k
		movwf	tagalong_k
		banksel marquee_index
		movf	marquee_index, w
		banksel tagalong_k	
		subwf	tagalong_k, f  ;;subtract our original index

		goto	start_loop


marquee_index_less_than_5
		;;we need to read marquee_index lines.
		banksel marquee_index
		movf	marquee_index , w
		banksel lines
		movwf	lines

		;;we need to offset the leds by 8*(7-marquee_index) times
		banksel marquee_index
		movf	marquee_index, w
		brw
		nop 
		addlw	8
		addlw	8
		addlw	8
		addlw	8
		addlw	8
		addlw	8
		banksel	tagalong_k
		movwf	tagalong_k
		banksel marquee_index
		movf	marquee_index, w
		banksel tagalong_k	
		subwf	tagalong_k, f  ;;subtract our original index

		goto start_loop




marquee_index_greater_than_7
		;;we need to read the last N lines, so we need to offset FSROL by marquee_index-7
		banksel	tagalong_k
		clrf	tagalong_k
		banksel marquee_index
		movf	marquee_index , w
		banksel temp_marquee_index
		movwf	temp_marquee_index
		movlw	7
		subwf	temp_marquee_index, f ; temp_marquee_index = marquee_index - 7


		movf	temp_marquee_index, w
		banksel lines
		sublw	5
		movwf	lines
increment_fsr0
		moviw	FSR0++ ;just doing this to properly loop FSR0L, dunno if there is a better way
		decfsz	temp_marquee_index, f
		goto	increment_fsr0

		goto	start_loop





start_loop
	
next_lines
		
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
		
		banksel lines
		decfsz	lines, f
		goto	next_lines
done_w_all_5_bytes	
		return

set_the_led
	;at this point, tagalong_k is set to the led number "plus a silly offset"
		banksel tagalong_k
		movlw	1
		subwf	tagalong_k, w
		call set_led
		return



	END
	
