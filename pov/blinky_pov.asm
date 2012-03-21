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

    ;__config _CONFIG2, _LVP_OFF & _BORV_19 & _STVREN_ON & _PLLEN_OFF
;Low voltage on MCLR/VPP must be used for programming
;Brown-out Reset Voltage (VBOR) set to 1.9 V
;Stack Overflow or Underflow will cause a Reset
;4x PLL disabled

; NOTE: There is no write protection here!

	extern delay_w_ms

	extern eeprom_read
	extern parse_messages

	extern data_block_start, data_block_end, data_index

	extern init_button

	extern message_config, end_type, speed, display_type

	extern load_slice_from_font
	
	extern button_release

	extern larson
;Variable space reservations;
    udata
message_num res 1
num_messages res 1

char_to_show res 1
char_index res 1
tmr0_reset_val res 1

slice res 1
fake_porta res 1
fake_portc res 1

known_zero res 1
rev_slice res 1

	global char_to_show, char_index, slice
;;code!

Reset_Vector code 0x400
                GOTO    Start
blinky_grid                code 0x450
;
;RESET_VECTOR CODE 0X000
;                GOTO    START
;BLINKY_GRID                CODE 0X050

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
				BANKSEL	PORTC
				CLRF	PORTC

				banksel TRISC
				clrf	TRISC ;PORTC is all outputs

				MOVLW	0xFF 
				BANKSEL TRISA
				MOVWF	TRISA ;PORTA is all inputs
				BCF		TRISA, 0; ;except TRISA0 and TRISA1
				BCF		TRISA, 1;

				banksel	char_index
				clrf	char_index
				

                ;;setup timer0

				banksel OPTION_REG
				bcf		OPTION_REG, 5 ; bit 5  TMR0 Clock Source Select bit...0 = Internal Clock (CLKO) 1 = Transition on T0CKI pin
				bcf		OPTION_REG, 4 ; bit 4 TMR0 Source Edge Select bit 0 = low/high 1 = high/low
				bcf		OPTION_REG, 3 ; bit 3  Prescaler Assignment bit...0 = Prescaler is assigned to the Timer0
				bsf		OPTION_REG, 2	; bits 2-0, prescaler rate bits
				bsf		OPTION_REG, 1
				bsf		OPTION_REG, 0
				banksel	TMR0
				movwf	TMR0




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
				;set tmr0 reset value
				;tmr0_reset_val max is 248, or 1.9khz
				;tmr0_reset_val is determined by speed, with a low number for speed meaning fast, and a high number meaning slow.
				;tmr0_reset_val is the opposite.
				;tmr0_reset_val 248 - 3*speed, which means it goes from 248 to 203, or 1.9khz  to 300hz
				banksel	speed
				movf	speed, w
				addwf	speed, f ; speed = 2*speed
				addwf	speed, w ; w = 3*original_speed
				;speed is now messed up, and equal to 2x speed.  if we need it, call parse _messages again.
				
				sublw	d'248'
				; w = 248-2*speed
				banksel tmr0_reset_val
				movwf	tmr0_reset_val
				
check_message_type

				;check if its easter egg first

				banksel	end_type
				movf	end_type, w
				sublw	d'3'
				btfsc	STATUS, Z
				goto	larson

				movlw B'10000000'
				banksel	message_config
				andwf	message_config, w
				btfsc	STATUS, Z
				goto	read_fonty_message
				goto	read_animation_message

read_animation_message
				banksel	known_zero
				clrf	known_zero
               			bsf     known_zero, 3  ; known_zero = 8
				banksel	data_index
				movf	data_index, w
				call	eeprom_read
				;this is upside down, because of the programmer and grid and just "the way it is"
				banksel	rev_slice
				movwf	rev_slice
rev_byte        
				banksel rev_slice
				rrf rev_slice, f
				banksel	slice
		               	rlf slice, f
				banksel known_zero
       		        	decfsz known_zero, f
      		        	goto rev_byte
				;;at this point, slice is forward
				banksel slice
				movf	slice, w
				
				goto	show_slice

read_fonty_message
				BANKSEL data_index
				movf	data_index, w
				call	eeprom_read
				banksel	char_to_show
				movwf	char_to_show

		;if we are after a character, show a space
		banksel	char_index
		movf	char_index, w
		sublw	d'4'
		btfss	STATUS, C ; if char_index > 4 (so 5 or 6)
		goto	empty_slice

	;if we have a space character
		banksel	char_to_show
		movf	char_to_show, w
		sublw	0x29
		btfss	STATUS, Z
		goto	get_address
empty_slice
		banksel	slice
		clrf	slice
		goto	show_slice


get_address
		call	load_slice_from_font
		goto	show_slice
		

show_slice

				banksel INTCON
				btfsc	INTCON, TMR0IF
				goto	reset_tmr
				
				banksel	PORTA;
				btfss	PORTA, 5
				goto	advance_message_after_release
				goto	show_slice

reset_tmr
				banksel	tmr0_reset_val
				movf	tmr0_reset_val, w
				banksel	TMR0
				movwf	TMR0
				banksel	INTCON
				bcf		INTCON, TMR0IF

				banksel	slice
				movf	slice, w
				lsrf	WREG, w
				lsrf	WREG, w
				lsrf	WREG, w
				lsrf	WREG, w
				lsrf	WREG, w
				lsrf	WREG, w
				banksel	fake_porta
				movwf	fake_porta
				banksel	slice
				movf	slice, w
				banksel	PORTC
				movwf	PORTC
				banksel	fake_porta
				movf	fake_porta, w
				banksel	PORTA
				movwf	PORTA
				
				movlw B'10000000'
				banksel	message_config
				andwf	message_config, w
				btfsc	STATUS, Z
				goto	advance_char_index
				goto	common_next ;;if it's flashy, go to the common next


advance_char_index
				;;increment char_index
				banksel	char_index
				incf	char_index, f
				movf	char_index, w
				sublw	d'7' ;5 wide, plus 1 space
				btfsc	STATUS, Z
				goto	common_next 
				goto	read_fonty_message ;advance to the next slice


common_next
				banksel	char_index
				clrf	char_index

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
				BANKSEL PORTA
				CLRF	PORTA
				BANKSEL	PORTC
				CLRF	PORTC
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
				;;it should never get here, we handle this at the top with the call to larson

advance_message_after_release
				banksel PORTA
				btfss	PORTA, 5 ; while button is pressed do nothing
				goto $-1
				movlw	D'100'
				call	delay_w_ms
				banksel	speed
				goto	advance_message

advance_message
	global	advance_message_after_release
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
