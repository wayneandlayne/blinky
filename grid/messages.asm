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

	
	global display_type, end_type, speed, message_config, data_block_start, data_block_end, data_index, char_index
;Variable space reservations;
message_udata    udata 0xa0

message_config res 1

end_type res 1
display_type res 1
speed res 1

data_block_start res 1
data_block_end res 1
data_index res 1
char_index res 1
i res 1
temptemp res 1
which res 1


;;code!

messages    code

messages_start
        goto messages_start
parse_messages
	global parse_messages
;this takes in "which" in w
	banksel which
	movwf	which

	movlw	1
	banksel		i
	movwf	i
check_which
	banksel which
	movf	which, f
	banksel	STATUS
	btfss	STATUS, Z
	goto	next_message
	;;this is the message we want!
	banksel	i
	movf	i, w
	call	eeprom_read

get_speed
	banksel message_config
	movwf	message_config
	movlw	B'00111100'
	andwf	message_config, w
	lsrf	WREG, w
	lsrf	WREG, w
	banksel	speed
	movwf	speed

get_end_type
	banksel message_config
	movf	message_config, w
	movlw	B'00000011'
	andwf	message_config, w
	banksel	end_type
	movwf	end_type

get_display_type
	banksel message_config
	movf	message_config, w
	movlw	B'01000000'
	andwf	message_config, w
	lsrf	WREG, w
	lsrf	WREG, w
	lsrf	WREG, w
	lsrf	WREG, w
	lsrf	WREG, w
	lsrf	WREG, w
	banksel	display_type
	movwf	display_type

read_the_message
	banksel	i
	incf	i, f
	movf	i, w
	banksel data_block_end
	movwf	data_block_end; data_block_end = i
	call	eeprom_read
	banksel	data_block_end
	addwf	data_block_end, f ;  data_block_end += eeprom_read(i)
	banksel	i
	incf	i, f
	movf	i, w
	banksel data_block_start
	movwf	data_block_start; data_block_start = i;
	banksel data_index;
	movwf	data_index;
	banksel	char_index
	movwf	char_index
	return
next_message
	
	; i += 2 + eeprom_read(i+1)
	banksel i
	movf	i, w
	addlw	1
	call eeprom_read
	addlw	2
	banksel i
	addwf	i, f; 
	banksel	which
	decf	which, f
	goto check_which
	

	

eeprom_read
	global eeprom_read
	;address in W, returns with contents in W
	BANKSEL EEADRL;
	MOVWF EEADRL ;Data Memory
					;Address to read
	BCF EECON1, CFGS ;Deselect Config space
	BCF EECON1, EEPGD;Point to DATA memory
	BSF EECON1, RD ;EE Read
	MOVF EEDATL, W ;W = EEDATL
	return

	END
