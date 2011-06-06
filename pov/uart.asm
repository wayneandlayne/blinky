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

;    include "P16F1823.INC"
;
;
;uart_section code
;init_uart
    ;global init_uart
;        BANKSEL APFCON
;        BSF APFCON, TXCKSEL ; TX function is on RA0
;        BSF APFCON, RXDTSEL ; RX Function is on RA1
;        BANKSEL TRISA
;        BCF TRISA, RA0; tx is an output
;        BSF TRISA, RA1; rx is an input
;        BANKSEL ANSELA
;        BCF ANSELA, ANSA0 ; tx is not an analog thing
;        BCF ANSELA, ANSA1 ; rx is not an analog thing either
;        BANKSEL TXSTA ; TODO: not really needed, as it's in the same bank as ASNSEL0
		;TODO: optimize this by not setting single bytes.
;        BCF TXSTA, SYNC
;        BSF TXSTA, BRGH
;        BSF BAUDCON, BRG16
;
;        CLRF  SPBRGH
;        movlw d'68'
;        movwf SPBRGL
;
;        BSF TXSTA, TXEN
;        BSF RCSTA, CREN
;        BSF RCSTA, SPEN
;        return

;putch
;    global putch
;        BANKSEL PIR1
;wait_for_transmit_to_finish
;        btfss   PIR1, 4
;        goto    wait_for_transmit_to_finish
;        BANKSEL TXREG
;        movwf   TXREG
;        return
;
;
;
;test_uart
;    global test_uart
;
;                movlw   'b'
;                call    putch
;                movlw   'o'
;                call    putch
;                movlw   'o'
;                call    putch
;                movlw   'y'
;                call    putch
;                movlw   'a'
;                call    putch
;                movlw   'h'
;                call    putch
;                return
        end
;
