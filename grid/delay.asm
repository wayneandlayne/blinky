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
delay1  res 1
delay2  res 1
delay3	res 1
delay4	res 1
save_w	res 1
save_w1	res 1
save_w2	res 1
save_w3 res 1
pressed res 1
d_temp res 1


;;None of these are nearly as accurate as they say.
;;they came from a code generator, awesome, but it didn't take interrupts
;;into account.  No big deal, but don't expect "100 ms" to be exactly 100 ms.

delay_section code


delay_w_ms
	global delay_w_ms
	banksel save_w
	addlw	1
	movwf	save_w

delay_w_ms_0
	decfsz	save_w, f
	goto	delay_w_ms_1
	return
delay_w_ms_1
	call delay_992_us
	goto delay_w_ms_0

delay_988_us
			;3948 cycles
	banksel	delay1
	movlw	0x15
	banksel	delay1
	movwf	delay1
	movlw	0x04
	banksel	delay2
	movwf	delay2
delay_988_us_0
	banksel	delay1
	decfsz	delay1, f
	goto	$+2
	decfsz	delay2, f
	goto	delay_988_us_0
			;4 cycles (including call)
	return

delay_992_us
			;3963 cycles
	movlw	0x18
	movwf	delay1
	movlw	0x04
	movwf	delay2
delay_992_us_0
	decfsz	delay1, f
	goto	$+2
	decfsz	delay2, f
	goto	delay_992_us_0

			;1 cycle
	nop

			;4 cycles (including call)
	return

delay_w00_ms
	global delay_w00_ms

	banksel save_w3
	addlw	1
	movwf	save_w3

delay_w00_ms_0
	decfsz	save_w3, f
	goto	delay_w00_ms_1
	return
delay_w00_ms_1
	movlw	d'100'
	call delay_w_ms
	goto delay_w00_ms_0


delay_w_ms_breakable
	global delay_w_ms_breakable
	banksel save_w1
	addlw	1
	movwf	save_w1
	banksel	pressed
	clrf	pressed
delay_w_ms_breakable_0
	decfsz	save_w1, f
	goto	delay_w_ms_breakable_1
	retlw	0x00
delay_w_ms_breakable_1
	banksel PORTA
	btfss PORTA, 5 
	call inc_pressed	
	call delay_988_us

	banksel	d_temp
	movlw	2
	movwf	d_temp
	banksel pressed
	movf	pressed, w
	subwf	d_temp, w
	btfss	STATUS, Z
	goto delay_w_ms_breakable_0 ;hasn't been pushed 2 times
	movlw	D'100'
	call	delay_w_ms
	retlw	0xff
	
delay_w00_ms_breakable
	global delay_w00_ms_breakable
	banksel save_w2
	addlw	1
	movwf	save_w2
	movlw	0
	banksel	pressed
	clrf pressed
delay_w00_ms_breakable_0
	decfsz	save_w2, f
	goto	delay_w00_ms_breakable_1
	retlw	0x00
delay_w00_ms_breakable_1
	movlw	d'100';
	call delay_w_ms_breakable
	movlw	5
	movwf	d_temp
	movf	pressed, w
	subwf	d_temp, w
	btfss	STATUS, Z
	goto delay_w00_ms_breakable_0
	movlw	D'100'
	call	delay_w_ms
	retlw	0xff

inc_pressed
	banksel pressed
	incf	pressed, f
	return

	END
