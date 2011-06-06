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


eeprom_table code 0xF000 ;eeprom
	de B'00001000'
	
	de B'00010010', d'12', 0x16, 0x0a, 0x14, 0x0e, 0x1b, 0x29, 0x0F, 0x0A, 0x12, 0x1B, 0x0E, 0x29; MAKER FAIRE
	de B'01100010', d'11', 0x16, 0x0a, 0x14, 0x0e, 0x1b, 0x29, 0x1C, 0x11, 0x0e, 0x0d, 0x29; MAKER SHED
	de B'10000010', d'13', 0x01, 0x02,0x04,0x08,0x10,0x20,0x30,0x20, 0x10, 0x08 , 0x04,0x02,0x01; ; slanty lines
	de B'00010010', 0x07, 0x11, 0x0e, 0x15, 0x15, 0x18, 0x29, 0x29 ; font based HELLO
	de B'11100110', d'14', 0xAA, 0x55,0xAA,0x55,0xAA,0x55,0xAA,0x55, 0xAA, 0x55 , 0xAA,0x55,0xAA,0x55; ;checkerboard
	
	de B'00001010', d'34' ,d'11', d'21', d'18', d'23', d'20', d'34', d'41', d'16', d'27', d'18', d'13';
	de d'41', d'18', d'28', d'41', d'10', d'41', d'28', d'22', d'10', d'27', d'29', d'41', d'21', d'14';
	de d'13', d'41', d'22', d'10', d'29', d'27', d'18', d'33', 0x29; //blinky grid is a smart led matrix


	de B'00001010', d'40', d'11', d'21', d'18' , d'23', d'20', d'34',d'41',d'16',d'27',d'18',d'13'; 
	de d'41', d'32',d'10',d'28',d'41',d'22',d'10',d'13',d'14',d'41',d'11',d'34',d'41',d'32',d'10',d'34';
	de d'23', d'14',d'41',d'10',d'23',d'13',d'41',d'21',d'10',d'34',d'23',d'14', 0x29 ;blinky grid was made by wayne and layne 
	
	de B'00001010',	d'60', d'11',d'21',d'18',d'23',d'20',d'34',d'41',d'16',d'27',d'18',d'13',d'41',d'18';
	de d'28',d'41',d'27',d'14',d'25',d'27',d'24',d'16',d'27',d'10',d'22',d'22',d'14',d'13',d'41',d'11';
	de d'34', d'41',d'17',d'24',d'21',d'13',d'18',d'23',d'16',d'41',d'18',d'29',d'41',d'30',d'25',d'41';
	de d'29',d'24',d'41',d'34',d'24',d'30',d'27',d'41',d'28',d'12',d'27',d'14',d'14',d'23', 0x29; ;blinky grid is reprogrammed by holding it up to your screen
	END
