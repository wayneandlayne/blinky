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

;;config bits

    ;__config _CONFIG1, _FCMEN_OFF & _IESO_OFF & _CLKOUTEN_OFF & _BOREN_OFF & _CPD_OFF & _CP_OFF & _MCLRE_ON & _PWRTE_ON & _WDTE_OFF & _FOSC_INTOSC


;Fail-Safe Clock Monitor is disabled
;Internal/External Switchover mode is disabled
;CLKOUT function is disabled. I/O or oscillator function on the CLKOUT pin
;Brown-out Reset disabled
;Data memory code protection is disabled
;Program memory code protection is disabled
;MCLRE/VPP pin function is MCLR
;PWRT enabled
;WDT disabled
;INTOSC oscillator: I/O function on CLKIN pin

   ; __config _CONFIG2, _LVP_OFF & _BORV_19 & _STVREN_ON & _PLLEN_OFF
;Low-voltage on MCLR/VPP must be used for programming
;Brown-out Reset Voltage (VBOR) set to 1.9 V
;Stack Overflow or Underflow will cause a Reset
;4x PLL disabled

; NOTE: There is no write protection here!


	extern marquee_char

	extern set_led
	extern display, show_display, clear_display, reset_display_addr
	extern delay_w_ms, delay_w00_ms, delay_w_ms_breakable, delay_w00_ms_breakable
	extern eeprom_read
	extern load_char

	extern parse_messages

	extern data_block_start, data_block_end, data_index, char_index

	extern button_release
	extern init_button

	extern message_config, end_type, speed, display_type
;Variable space reservations;
    udata
message_num res 1
num_messages res 1

char_to_show res 1
marquee_index res 1
temp_char res 1
temp_index res 1
led_index res 1
limit res 1

	global char_to_show, marquee_index
;;code!

Reset_Vector code 0x400
                GOTO    Start
Interrupt_Vector code 0x404
                GOTO    isr
blinky_grid                code 0x450


;Reset_Vector code 0x000
;                GOTO    Start
;Interrupt_Vector code 0x004
;                GOTO    isr
;blinky_grid                code 0x050

Start
                BANKSEL OSCCON
                MOVLW   B'01111000'
                MOVWF   OSCCON ;; set clock to 16 mhz

                BANKSEL INTCON
                bcf INTCON, GIE
                bcf INTCON, PEIE ;disable interrupts

				BANKSEL	ANSELA
				CLRF	ANSELA ;all digital on PORTA
				BANKSEL ANSELC
				CLRF	ANSELC ;all digital on PORTC

				BANKSEL PORTA
				CLRF	PORTA
				CLRF	PORTC

				BANKSEL	TRISC
				MOVLW	0xFF
				MOVWF	TRISA ;PORTA is all inputs
				MOVWF	TRISC ;PORTC is all inputs

				call	clear_display
				call	reset_display_addr
                ;;setup timer0
				BANKSEL TMR0
				movlw	d'220'
				movwf	TMR0


                BANKSEL OPTION_REG
				BCF OPTION_REG, PSA ; turn on prescaler



                BCF OPTION_REG, TMR0CS ; use fosc/4 as clock source
                BANKSEL INTCON
                BCF INTCON, TMR0IF ; clear interrupt bit
                BSF INTCON, TMR0IE ; enable timer1 interrupts
                BSF INTCON, PEIE ; enable peripheral interrupts
                BSF INTCON, GIE ; enable global interrupts


			;	call init_uart
			;	call test_uart

				call init_button

get_num_messages
				movlw	0x00
				call	eeprom_read
				andlw	B'00011111'
				banksel	num_messages
				movwf	num_messages


				movlw 0x00
				banksel message_num
				movwf message_num
main
				banksel message_num
				movf	message_num, w
				call parse_messages
check_message_type
				movlw B'10000000'
				banksel	message_config
				andwf	message_config, w
				btfsc	STATUS, Z
				goto	read_fonty_message
				goto	read_animation_message

read_animation_message
				banksel display_type


anim_flashy_part
				call	clear_display
				banksel led_index
				clrf	led_index
				banksel marquee_index
				clrf	marquee_index

				;;how many rows should we read?  normally, 6, but if this is a scrolly animation, we shouldn't read past the frame

				banksel	data_index
				movf	data_index, w
				banksel data_block_end
				subwf	data_block_end, w

				banksel	limit
				movwf	limit ;;if limit > 6, limit = 6.
				movlw	6
				subwf	limit, w
				btfss	STATUS, C ; this is a not-borrow bit
				goto	leave_limit_alone
				goto	set_limit_to_6
leave_limit_alone

				goto next_slice
set_limit_to_6
				banksel	limit
				movlw	6
				movwf	limit
				goto	next_slice
next_slice
				banksel temp_index
				clrf	temp_index
				banksel	data_index
				movf	data_index, W
				call	eeprom_read
				banksel temp_char
				movwf	temp_char
next_led ; marquee_index

				banksel temp_char
				btfsc	temp_char, 0
				call	set_the_led
				lsrf	temp_char, f
				banksel	led_index
				incf	led_index, f
				banksel	temp_index
				incf	temp_index, f
				movf	temp_index, w
				sublw	8
				btfss	STATUS, Z
				goto	next_led

				;advance to next slice


				banksel	marquee_index
				movf	marquee_index, w
				banksel limit
				subwf	limit, w
				btfsc	STATUS, Z
				goto	done_w_frame
				banksel	data_index
				incf	data_index, f
				banksel	marquee_index
				incf	marquee_index, f
				goto	next_slice

done_w_frame
				movlw	d'32'
				call	delay_w_ms_breakable
				banksel speed
				sublw	0xFF
				btfsc	STATUS, Z
				goto	advance_message_after_release

				;;we want to enable 30FPS ... yeah... :)
				;;let's do 32+64ms x speed.
				banksel	temp_index
				movlw	d'64' ; we want to delay 32 + 64 * speed * 1ms
				movwf	temp_index

user_anim_delay
				banksel	speed
				movf	speed, w
				call	delay_w_ms_breakable
				banksel speed
				sublw	0xFF
				btfsc	STATUS, Z
				goto	advance_message_after_release
				banksel	temp_index
				decfsz	temp_index, f
				goto	user_anim_delay

				banksel	display_type
				movf	display_type, w
				btfsc	STATUS, Z
				goto	anim_marquee_end ;; if its marquee-y, change some vars, then go to common next
				goto	common_next ;;if it's flashy, go to the common next

anim_marquee_end
				banksel	limit
				movf	limit, w
				banksel	data_index
				subwf	data_index, f
				goto	common_next


		;;done with the frame



set_the_led
	;at this point, led_index is set to the led number
		banksel led_index
                        movf	led_index, w

		call set_led
		return



read_fonty_message
				BANKSEL data_index
				movf	data_index, w
				call	eeprom_read
				banksel	char_to_show
				movwf	char_to_show

				banksel display_type
				movf	display_type, w
				btfsc	STATUS, Z
				goto	marquee_part ;; if bit 6 = 1
				goto	flashy_part ;;if bit 6 = 0

marquee_part
				banksel marquee_index
				clrf marquee_index

next_marquee_slice
				banksel	marquee_index
				incf marquee_index, f

				call	clear_display
				banksel	char_to_show
				movf	char_to_show, w

				call	marquee_char ;;show the primary character


wait_and_display
				banksel	temp_index
				movlw	d'32' ; we want to delay 32 * speed * 1ms
				movwf	temp_index
user_marquee_delay
				banksel	speed
				movf	speed, w 

				call	delay_w_ms_breakable
				banksel speed
				sublw	0xFF
				btfsc	STATUS, Z
				goto	advance_message_after_release
				banksel	temp_index
				decfsz	temp_index, f
				goto	user_marquee_delay

				banksel	marquee_index
				movf	marquee_index, w
				sublw	d'11'
				btfss	STATUS, Z
				goto	next_marquee_slice
				goto	common_next

flashy_part
				;;now W is the value of eeprom at address data_index
				call	clear_display
				movlw	d'50'
				call	delay_w_ms ; clear the screen and wait a bit to show a flash between characters

				banksel char_to_show
				movf	char_to_show, w
				call	load_char



				banksel	temp_index
				movlw	d'32' ; we want to delay 64 * speed * 1ms
				movwf	temp_index

user_flashy_delay
				banksel	speed
				movf	speed, w 
				addwf	speed, w

				call	delay_w_ms_breakable
				banksel speed
				sublw	0xFF
				btfsc	STATUS, Z
				goto	advance_message_after_release
				banksel	temp_index
				decfsz	temp_index, f
				goto	user_flashy_delay
				goto	common_next

common_next

				BANKSEL	data_index
				incf	data_index, f
				movf	data_index, w
				decf	WREG, w
				BANKSEL	data_block_end
				subwf	data_block_end, w
				BANKSEL	STATUS
				btfsc	STATUS, Z
				goto	end_of_message ; if data_index == data_block_end, then goto end_of_message

				goto	check_message_type
end_of_message
				;;check the end type
				BANKSEL	end_type
				movf	end_type, w
				BRW
				goto	stop_end_type
				goto	repeat_end_type
				goto	advance_end_type
				goto	easter_egg_end_type


stop_end_type
				call clear_display
				call button_release
				banksel	end_type
				goto advance_message

repeat_end_type
				banksel	data_block_start
				movf	data_block_start, w
				banksel	data_index
				movwf	data_index
				goto	check_message_type
advance_end_type
				goto	advance_message
easter_egg_end_type
				goto	stop_end_type ;TODO

advance_message_after_release
				banksel PORTA
				btfss	PORTA, 5 ; while button is pressed do nothing
				goto $-1
				movlw	D'100'
				call	delay_w_ms
				banksel	speed
				goto	advance_message

advance_message
				;;if message_num + 1 >= num_messages we know we've gone too far and have to loop back
				banksel message_num
				incf	message_num, f
				movf	message_num, w
				banksel	num_messages
				subwf	num_messages, w
				banksel	message_num
				btfsc	STATUS, Z
				;;we know that incremented message_num now equals num_messages
				clrf	message_num

				goto	main




isr
				banksel INTCON
                BCF INTCON, GIE ; disable global interrupts
                call    show_display
				BANKSEL TMR0
				movlw	d'220'
				movwf	TMR0
				banksel INTCON
                BCF     INTCON, TMR0IF
                BSF INTCON, GIE ; enable global interrupts
                RETFIE



GET_BIT
    global GET_BIT
                BRW
                RETLW	B'00000001'
                RETLW	B'00000010'
                RETLW	B'00000100'
                RETLW	B'00001000'
                RETLW	B'00010000'
                RETLW	B'00100000'
                RETLW	B'01000000'
                RETLW	B'10000000'
	END
