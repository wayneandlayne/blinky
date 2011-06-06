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

    LIST P=16F1823
    include "P16F1823.INC"

 udata 

; the reason why the memory is reserved this way is so that in watch windows, things are more easily discernable.
curr_display_addr  res 2
display res 1
led0_trisc res 1
led0_porta res 1
led0_portc res 1
led1_trisa res 1
led1_trisc res 1
led1_porta res 1
led1_portc res 1
led2_trisa res 1
led2_trisc res 1
led2_porta res 1
led2_portc res 1
led3_trisa res 1
led3_trisc res 1
led3_porta res 1
led3_portc res 1
led4_trisa res 1
led4_trisc res 1
led4_porta res 1
led4_portc res 1
led5_trisa res 1
led5_trisc res 1
led5_porta res 1
led5_portc res 1
led6_trisa res 1
led6_trisc res 1
led6_porta res 1
led6_portc res 1
led7_trisa res 1
led7_trisc res 1
led7_porta res 1
led7_portc res 1

fake_trisa res 1
fake_porta res 1
fake_portc res 1
fake_trisc res 1


    global display, curr_display_addr

show_display_section   code
show_display
    global show_display
                ;movwf   curr_display_addr
                ;movf    curr_display_addr+1, W
                CLRF   FSR0H
                movf    curr_display_addr, W
                movwf   FSR0L ;;load current display address into FSR0
                BANKSEL fake_trisa
                moviw   FSR0++
				
                MOVWF   fake_trisa
                MOVIW   FSR0++
				banksel	fake_trisc
                MOVWF   fake_trisc
                BANKSEL fake_porta
                MOVIW   FSR0++
                MOVWF   fake_porta
                MOVIW   FSR0++
                MOVWF   fake_portc

				banksel	TRISA
				movlw	0x3F
				movwf	TRISA
				banksel	fake_trisc
				movf	fake_trisc, w
				banksel	TRISC
				movwf	TRISC

				banksel PORTC
				clrf	PORTC
				
				banksel fake_trisa
				movf	fake_trisa, w
				banksel	TRISA
				movwf	TRISA

				banksel	fake_porta
				movf	fake_porta, W
				banksel	PORTA
				movwf	PORTA

				banksel	fake_portc
				movf	fake_portc, W
				banksel	PORTC
				movwf	PORTC
		
			
				
				
				
                                    ;;check if we've overflowed display, and need to reset
                movf    FSR0, W
                banksel STATUS
                sublw   display+d'31'
                btfsc   STATUS, C ;;check if FSR0 > display+d32
                goto    display_addr_ok ;; FSR0 <= display+d32
                goto    reset_display_addr ;; FSR> display+d32
display_addr_ok:
                movf    FSR0, W
                movwf   curr_display_addr ;;TODO: can we always dedicate FSR0 to display? if so, we can clean this up
                return



reset_display_addr
    global reset_display_addr
                movlw   display ; this is loading the *address* of display into w ;TODO see if it works
                movwf   curr_display_addr
                return



clear_display
    global clear_display
                CLRF   FSR0H
                movlw   display
                movwf   FSR0L
clear_row_in_array
				;TODO: change to MOVWI and MOVIW here.  When I tried it at first, I couldn't get it to work, but I had toolchain problems.
                movlw   0xFF
                movwf   INDF0; //trisa
                INCF    FSR0, F;
                MOVWF   INDF0; //trisc
                incf    FSR0, F;
                movlw   0x00
                movwf   INDF0; //porta
                incf    FSR0, F;
                movwf   INDF0; //portc
                incf    FSR0, F;

                                    ;;check if we've overflowed display, and need to reset
                movf    FSR0L, W
                banksel STATUS
                sublw   display+d'31' 
                btfsc   STATUS, C ;;check if FSR0 > display+d32
                goto    clear_row_in_array ;; FSR0 <= display+d32
                return ;; FSR> display+d32




                end
