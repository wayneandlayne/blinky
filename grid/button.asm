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

	extern  delay_w_ms, delay_w00_ms

button_section code
init_button
    global init_button
	BANKSEL OPTION_REG ;globally enable weak pullups
	bcf	OPTION_REG, NOT_WPUEN

	BANKSEL TRISA	;set trisa5 to an input
	bsf	TRISA, 5

	BANKSEL WPUA ;turn on weak pullups for pin 5
	bsf WPUA, WPUA5

	return


button_release
	global button_release

	banksel PORTA
	btfsc	PORTA, 5 ; while button is unpressed do nothing
	goto $-1

	movlw	D'100'
	call	delay_w_ms


	banksel PORTA
	btfss	PORTA, 5 ; while button is pressed do nothing
	goto $-1

	movlw	D'100'
	call	delay_w_ms
	return

	
        end
