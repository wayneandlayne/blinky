    include "P16F1823.INC"

	extern delay_200_us, delay_10_us

	extern advance_message_after_release
	extern speed
	extern message_config
	udata
eye_pos res 1
data_addr res 1
pre_porta res 1
pre_portc res 1
data_byte res 1
loops res 1
loop_temp res 1
brightness res 1
inner_loop_temp res 1

larson_data code 0x600

	data 0x0005
	data 0x0001
	data 0x0003
	data 0x0001
	data 0x0001
	data 0x0001
	data 0x0003
	data 0x0001
	data 0x0001
	data 0x0001
	data 0x0003
	data 0x0001
	data 0x0001
	data 0x0001
	data 0x0003
	data 0x0001
	
	
	
	data 0x000A
	data 0x0002
	data 0x0006
	data 0x0003
	data 0x0002
	data 0x0006
	data 0x0003
	data 0x0002
	data 0x0002
	data 0x0002
	data 0x0006
	data 0x0003
	data 0x0002
	data 0x0006
	data 0x0003
	data 0x0002
	
	
	data 0x0014
	data 0x0005
	data 0x000C
	data 0x0006
	data 0x0004
	data 0x000C
	data 0x0006
	data 0x0004
	data 0x0004
	data 0x0004
	data 0x000C
	data 0x0006
	data 0x0004
	data 0x000C
	data 0x0006
	data 0x0004
	
	
	data 0x0028
	data 0x000A
	data 0x0018
	data 0x000C
	data 0x0008
	data 0x0018
	data 0x000C
	data 0x0008
	data 0x0008
	data 0x0008
	data 0x0018
	data 0x000C
	data 0x0008
	data 0x0018
	data 0x000C
	data 0x0008
	
	
	data 0x0050
	data 0x0014
	data 0x0030
	data 0x0018
	data 0x0010
	data 0x0030
	data 0x0018
	data 0x0010
	data 0x0010
	data 0x0010
	data 0x0030
	data 0x0018
	data 0x0010
	data 0x0030
	data 0x0018
	data 0x0010
	
	
	data 0x00A0
	data 0x0028
	data 0x0060
	data 0x0030
	data 0x0020
	data 0x0060
	data 0x0030
	data 0x0020
	data 0x0020
	data 0x0020
	data 0x0060
	data 0x0030
	data 0x0020
	data 0x0060
	data 0x0030
	data 0x0020
	
	
	
	data 0x0040
	data 0x0050
	data 0x00C0
	data 0x0060
	data 0x0040
	data 0x00C0
	data 0x0060
	data 0x0040
	data 0x0040
	data 0x0040
	data 0x00C0
	data 0x0060
	data 0x0040
	data 0x00C0
	data 0x0060
	data 0x0040
	
	
	data 0x0080
	data 0x00A0
	data 0x0080
	data 0x00C0
	data 0x0080
	data 0x0080
	data 0x00C0
	data 0x0080
	data 0x0080
	data 0x0080
	data 0x0080
	data 0x00C0
	data 0x0080
	data 0x0080
	data 0x00C0
	data 0x0080

larson_section code
larson
	global larson
	;;first show it going one way
	banksel	eye_pos
	clrf	eye_pos

	;calculate wait time
	;;speed is 0 to 31, and 0 means fast


	banksel	speed
	incf	speed, w ; w = speed + 1
	addwf	speed, w ; w = speed + 1 + speed
	addwf	speed, w ; 
	banksel	loops
	movwf	loops
	banksel	loop_temp
	clrf	loop_temp

	banksel	inner_loop_temp
	clrf	inner_loop_temp

	banksel	brightness
	clrf	brightness
	movlw B'10000000'
	banksel	message_config
	andwf	message_config, w
	banksel	brightness
	btfsc	STATUS, Z
	goto	set_high_brightness
	goto	set_low_brightness


set_high_brightness
	incf	brightness, f
	goto	done_w_brightness
set_low_brightness
	;brightness is already set to 0, nbd
done_w_brightness
	;;init address
	banksel	data_addr
	clrf	data_addr
	banksel	FSR0L
	clrf	FSR0L
	;we want to read from 0x600...
	banksel FSR0H
	movlw	0x86; //the 8 means "progmem"
	movwf	FSR0H
down
	banksel	loops
	movf	loops, w
	banksel	loop_temp
	movwf	loop_temp
	movlw	d'16'
	banksel	inner_loop_temp
	movwf	inner_loop_temp

down_loop
	moviw	FSR0++
	;;w is now the data byte
	banksel data_byte
	movwf	data_byte
	call	show_eye
	call	delay_10_us


	banksel	brightness
	movf	brightness, w
	btfsc	STATUS, Z
	call	low_brightness
    sublw   0xFF
    btfsc   STATUS, Z
    goto    advance_message_after_release

	banksel	brightness
	movf	brightness, w
	btfss	STATUS, Z
	call	delay_200_us	; compensate for low brightness
    sublw   0xFF
    btfsc   STATUS, Z
    goto    advance_message_after_release

	banksel	inner_loop_temp
	decfsz	inner_loop_temp, f ;;when this is zero, we're done with this eye position
	goto	down_loop
	goto	check_down_speed_loop
	
check_down_speed_loop

	banksel	loop_temp
	decfsz	loop_temp, f
	goto	repeat_down_segment
	goto	advance_down

repeat_down_segment
	banksel	inner_loop_temp
	movlw	d'16'
	movwf	inner_loop_temp

	movlw	d'16'
	banksel FSR0L
	subwf	FSR0L, f
	goto	down_loop
	
advance_down

	banksel	loops
	movf	loops, w
	banksel	loop_temp
	movwf	loop_temp

	banksel	inner_loop_temp
	movlw	d'16'
	movwf	inner_loop_temp

	banksel	FSR0L
	movf	FSR0L, w
	sublw	d'128'
	btfss	STATUS, Z
	goto	down


up
	banksel	loops
	movf	loops, w
	banksel	loop_temp
	movwf	loop_temp
	movlw	d'16'
	banksel	inner_loop_temp
	movwf	inner_loop_temp



up_loop
	moviw	--FSR0
	;;w is now the data byte
	banksel data_byte
	movwf	data_byte
	call	show_eye

	call	delay_10_us    

	banksel	brightness
	movf	brightness, w
	btfsc	STATUS, Z
	call	low_brightness
    sublw   0xFF
    btfsc   STATUS, Z
    goto    advance_message_after_release

	banksel	brightness
	movf	brightness, w
	btfss	STATUS, Z
	call	delay_200_us	; compensate for low brightness
    sublw   0xFF
    btfsc   STATUS, Z
    goto    advance_message_after_release

	banksel	inner_loop_temp
	decfsz	inner_loop_temp, f ;;when this is zero, we're done with this eye position
	goto	up_loop
	goto	check_up_speed_loop


check_up_speed_loop

	banksel	loop_temp
	decfsz	loop_temp, f
	goto	repeat_up_segment
	goto	advance_up

repeat_up_segment
	banksel	inner_loop_temp
	movlw	d'16'
	movwf	inner_loop_temp

	movlw	d'16'
	banksel FSR0L
	addwf	FSR0L, f
	goto	up_loop
	
advance_up

	banksel	loops
	movf	loops, w
	banksel	loop_temp
	movwf	loop_temp

	banksel	inner_loop_temp
	movlw	d'16'
	movwf	inner_loop_temp

	banksel	FSR0L
	movf	FSR0L, w
	btfss	STATUS, Z
	goto	up
	goto	down




low_brightness
	banksel	PORTA
	CLRF	PORTA
	banksel	PORTC
	CLRF	PORTC
	call	delay_200_us
    sublw   0xFF
    btfsc   STATUS, Z
	retlw	0xFF
	retlw	0x00
	

	
show_eye
	banksel	data_byte
	movf	data_byte, w

	andlw 	B'00111111'
	banksel	pre_portc
	movwf	pre_portc

	banksel	data_byte
	movf	data_byte, w
	lsrf	WREG, w
	lsrf	WREG, w
	lsrf	WREG, w
	lsrf	WREG, w
	lsrf	WREG, w
	lsrf	WREG, w
	;;		now w is pre_porta
	banksel	PORTA
	movwf	PORTA
	banksel	pre_portc
	movf	pre_portc, w
	
	banksel	PORTC
	movwf	PORTC
	return


	END
