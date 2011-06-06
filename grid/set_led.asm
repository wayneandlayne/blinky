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

	extern	GET_BIT, display
	extern	pin_mapping

grp2		udata	
mapping res 1
led	res 1
pos res 1
neg res 1
index res 1
blah_minus_six res 1
temp res 1

set_led_section code

set_led
	global set_led
		banksel INTCON
        BCF INTCON, GIE ; disable global interrupts
		banksel	led
		movwf	led		;preserve w as led
		lsrf	led, w
		call pin_mapping; w = pin_mapping[led >> 1]
		banksel mapping
		movwf	mapping; mapping = pin_mapping[led >> 1]
		
		banksel	led
		btfss	led, 0
		goto	led_even
		goto	led_odd
led_odd
		;need to swap
		banksel mapping
		movf	mapping, w
		ANDLW	0x0F
		banksel	pos
		movwf	pos; pos = mapping & 0x0F
		banksel mapping
		swapf	mapping, w
		ANDLW	0x0F
		banksel	neg
		movwf	neg; neg = mapping & 0x0F
		goto	check_pos_neg
led_even
		banksel mapping
		movf	mapping, w
		ANDLW	0x0F
		banksel	neg
		movwf	neg; neg = mapping & 0x0F
		banksel mapping
		swapf	mapping, w
		ANDLW	0x0F
		banksel	pos
		movwf	pos; pos = mapping & 0x0F
		goto	check_pos_neg
		
check_pos_neg
		banksel pos
		movf	pos, w
		banksel index
		clrf	index
		addwf	index, f
		addwf	index, f
		addwf	index, f
		addwf	index, f ; index = 4*pos;
check_pos
	                        ; if pos < 6
		banksel pos
        movf pos, w
        sublw   5
        btfsc   STATUS, C
        goto pos_less_than_6
        goto pos_six_or_higher

pos_less_than_6
        ;we need to set portC pin POS to an output, and high ;;technically we don't
		banksel	display
        movlw   display
		banksel	index
        addwf   index, w
        addlw   1
        movwf   FSR1; FSR1 = display+index+1
		banksel	pos
        movf    pos, w
        call    GET_BIT
		banksel temp
        movwf   temp    ; temp is bitmask of 0's with bit pos set
        comf    WREG, W    ;W = bitmask of 1's with bit pos cleared
        andwf   INDF1, F;  TRISC.pos = 0;
        moviw   2[FSR1]; w = PORTC
		banksel temp
        IORWF   temp, W; W = PORTC with bit pos set
        movwi   2[FSR1]; PORTC.pos = 1;
        goto    check_neg
pos_six_or_higher
;we need to set portA pin POS-6 to an output, and high ;;technically we don't
		banksel	pos
        movf    pos, w
		banksel blah_minus_six
		movwf	blah_minus_six
        movlw   6
		subwf   blah_minus_six, f
		banksel	display
        movlw   display
		banksel index
        addwf   index, w
        movwf   FSR1; FSR1 = display+index
		banksel	blah_minus_six
        movf    blah_minus_six, w
        call    GET_BIT
		banksel	temp
        movwf   temp    ; temp is bitmask of 0's with bit pos-6 set
        comf    WREG, W    ;W = bitmask of 1's with bit pos-6 cleared
        andwf   INDF1, F;  TRISA.pos-6 = 0;
        moviw   2[FSR1]; w = PORTA
        IORWF   temp, W; W = PORTA with bit pos-6 set
        movwi   2[FSR1]; PORTA.pos-6 = 1;
        goto    check_neg
check_neg
                        ; if neg < 6
        movf neg, w
        sublw   5
        btfsc   STATUS, C
        goto neg_less_than_6
        goto neg_six_or_higher
neg_less_than_6
        ;we need to set portC pin NEG to an output, and low ;;technically we don't
        movlw   display
        addwf   index, w
        addlw   1
        movwf   FSR1; FSR1 = display+index+1
        movf    neg, w
        call    GET_BIT
        comf    WREG, W    ;W = bitmask of 1's with bit neg cleared
        movwf   temp;
        andwf   INDF1, f;  TRISC.neg = 0;
        moviw   2[FSR1]; w = PORTC
        andwf   temp, W; W = PORTC with bit neg cleared
        movwi   2[FSR1]; PORTC.neg = 1;
        goto    done
neg_six_or_higher
;we need to set portA pin neg-6 to an output, and low
		banksel	neg
        movf    neg, w
		banksel blah_minus_six
		movwf	blah_minus_six
        movlw   6
		subwf   blah_minus_six, f

        movlw   display
        addwf   index, w
        movwf   FSR1; FSR1 = display+index
        movf    blah_minus_six, w
        call    GET_BIT
        comf    WREG, W    ;W = bitmask of 1's with bit pos cleared
        movwf   temp    ;

        andwf   INDF1, F;  TRISA.neg-6 = 0;
        moviw   2[FSR1]; w = PORTA
        andWF   temp, W; W = PORTA with bit neg-6 cleared
        movwi   2[FSR1]; PORTA.pos = 1;
        goto    done
done
				banksel INTCON
                BSF INTCON, GIE ; enable global interrupts
		return



	END
