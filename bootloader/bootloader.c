// Wayne and Layne present:
// Blinky Bootloader, firmware revision 1.01
// Last Updated: January 20, 2016
// Copyright (c) 2016, Wayne and Layne, LLC
//
// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License along
// with this program; if not, write to the Free Software Foundation, Inc.,
// 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
//
//
// For pictures, instructions, and software, please visit:
// http://www.wayneandlayne.com/projects/blinky/
//
// Hardware pinout plans:
//   Infrastructure:
//              1               Vdd - 2+ AA/AAA batteries
//              4               MCLRb - Reset and programming pin
//              14              Vss - Ground
//   POV/GRID LEDs:
//              10              RC0 - LED0
//              9               RC1 - LED1
//              8               RC2 - LED2
//              7               RC3 - LED3
//              6               RC4 - LED4
//              5               RC5 - LED5
//              13              RA0 - LED6 / ICSPDAT - TX (connect to the yellow wire (#5) on the FTDI cable)
//              12              RA1 - LED7 / ICSPCLK - RX (connect to the orange wire (#4) on the FTDI cable)
//   Pushbutton input:
//              2               RA5 - Has a nice built-in weak pullup that we can use.
//   Ambient light sensor input:
//              3               RA4 - DATA
//              11              RA2 - CLOCK

#include <htc.h>

// Config register CONFIG1
__CONFIG(
    FCMEN_OFF &             // Fail-Safe Clock Monitor is disabled
    IESO_OFF &              // Internal/External Switchover mode is disabled
    CLKOUTEN_OFF &          // CLKOUT function is disabled. I/O or oscillator function on the CLKOUT pin
    BOREN_OFF &             // Brown-out Reset disabled
    CPD_OFF &               // Data memory code protection is disabled
    CP_OFF &                // Program memory code protection is disabled
    MCLRE_ON &              // MCLRE/VPP pin function is MCLR
    PWRTE_ON &              // PWRT enabled
    WDTE_OFF &              // WDT disabled
    FOSC_INTOSC             // INTOSC oscillator: I/O function on CLKIN pin
);

// Config register CONFIG2
__CONFIG(
    LVP_OFF &               // Low-voltage on MCLR/VPP must be used for programming
    BORV_19 &               // Brown-out Reset Voltage (VBOR) set to 1.9 V
    STVREN_ON &             // Stack Overflow or Underflow will cause a Reset
    PLLEN_OFF &             // 4x PLL disabled
    WRT_HALF                // 000h to 3FFh write protected, 400h to 7FFh may be modified
);

// Frequency of oscillator in hertz (Fosc), used by the compiler's delay functions.
// NOTE: This is the raw oscillator frequency (Fosc), not the Fcy (instr. clock).
// You also set the Processor Frequency in the simulator settings to this (Fosc).
#define _XTAL_FREQ             16000000

// ---------------------------------------------------------------------
// Some interesting things to play around with:

//#define POV
//#define GRID

//#define DEBUG // initializes and uses uart for feedback

#define M_Min(a,b) ((a) < (b) ? (a) : (b))
#define M_Max(a,b) ((a) > (b) ? (a) : (b))

// pick one of these to use for bootloading from
#define getch() getch_blinky()
//#define getch() getch_uart()
// ---------------------------------------------------------------------

// Here, we define how much size the bootloader takes up (currently, half the program memory)
// The regular reset/interrupt vector are at 0x000/0x004, but we offset those to make space for the bootloader
#define BOOTLOADER_SIZE         0x400
#define USER_VECTOR             BOOTLOADER_SIZE
#define USER_ISR_VECTOR         BOOTLOADER_SIZE + 4

// To protect against errors in blinky transmission, we have checksums computed over each record
// Simply sum up all data in each record (mod 0xFF). The sum should be 0x00 if there were no errors.
persistent unsigned char cksum;

__EEPROM_DATA(0x01, 0x1E, 0x05, 0x11, 0x0E, 0x15, 0x15, 0x18); // font-based "HELLO" message

// the threshold value for the light sensors
unsigned char threshold_clock = 0;
unsigned char threshold_data = 0;

#define ANALOG_PIN_CLOCK        0
#define ANALOG_PIN_DATA         1
unsigned char analog_read(unsigned char which)
{
    /*
     * From datasheet 16.2.6:
     *
     * 4. Wait the required acquisition time (2 - See section 16.3).
     * 5. Start conversion by setting the GO/DONE bit.
     * 6. Wait for ADC conversion to complete by one of the following:
     * - Polling the GO/DONE bit
     * - Waiting for the ADC interrupt (interrupts enabled)
     * 7. Read ADC Result.
     * 8. Clear the ADC interrupt flag (required if interrupt is enabled).
     */
    // select the proper analog input pin - decide between AN2 (clock) and AN3 (data)
    CHS0 = which;


    //clear ADC interrupt
    ADIF = 0; // TODO do we really need to do this? (Probably not)


    //wait? TODO does this happen automatically for us anyway? Also, I think the datasheet says max Taq is like 5us, but it shouldn't really matter for timing, in the long run, I think.
    // It appears that this acquisition delay does not automatically happen.
    // After changing the channel or enabling the ADC hardware we must provide sufficient time for the charge holding capacitor to reach the input channel voltage level.
    // Check out section 16.3 for details.
    // TODO what is the effective input impedance for our analog source? They suggest a maximum of 10 k ohms. ("The maximum recommended impedance for analog sources is 10 k ohm. This is required to meet the pin leakage specification.")
    // Tacq = amplifier settling time + hold capacitor charging time + temperature coefficient (let's assume 50 deg C worst case - matches datasheet)
    //      = 2 us + Tc + [(temp - 25C)(0.05 us/C)]
    //      = 2 us + Tc + 1.25 us
    //      = 3.25 us + Tc
    // Tc can be approximated by Tc = -C_hold ( R1C + Rss + Rs ) ln(1/2047)
    // Where Rs = source impedance
    //       Rss = internal sampling switch impedance (4 k ohm)
    //       R1C = ??? (datasheet said 1 k ohm)
    //       Chold = Charge holding capacitor (12.5 pF)
    __delay_us(50);



    //start conversion
    GO = 1;
    //poll for go/done bit
    while (GO);

    // We are ignoring the two least-significant bits of the 10-bit sample.
    return ADRESH;
}

void init_adc(void)
{
    //disable pin output drivers (TRIS) on pins RA2 and RA4
    TRISA2 = 1;
    TRISA4 = 1;
    //configure pin as analog (ANSEL)
    ANSA2 = 1;
    ANSA4 = 1;
    //set the conversion clock and voltage reference
    // datasheet says that for 16 mhz, we need to use Fosc/16, Fosc/32, or Fosc/64
    ADCON1 = 0b01010000; // left justified, use Fosc/16, Vref+ is Vdd

    //select ADC input channel
    //CHS is set to 0x0000 by default, but we need to pick between ch2 and ch3 (using CHS0),
    // so we set CHS1 = 1 below, and turn on ADC module
    ADCON0 = 0b00001001;
}

#ifdef DEBUG
void init_uart(void)
{
    //oh my god, the combination of ANSEL and RXDTSEL and TXCKSEL wasted about 5 hours of my life
    // For the 1823, TX is pin 13 (RA0) and RX is pin 12 (RA1)
    TXCKSEL = 1; // TX function is on RA0
    RXDTSEL = 1; // RX function is on RA1
    TRISA0 = 0; // tx
    TRISA1 = 1; // rx
    ANSA0 = 0; // tx
    ANSA1 = 0; // rx

    // these next three set us up for 16-bit asynchronous operation, using Fosc/(4 * (n+1)) in the baud rate formula
    SYNC = 0;
    BRGH = 1;
    BRG16 = 1;
    SPBRG = 68; // 57600 at FOSC 16 mhz
    TXEN = 1;
    CREN = 1;
    SPEN = 1;
}

void putch(char data)
{
    while (!TXIF);
    TXREG = data;
}

void puthex(unsigned char data)
{
    if (data > 9)
    {
        putch('A' + data - 10);
    }
    else
    {
        putch('0' + data);
    }
}

// Prints a byte as two hex characters
void unsigned_char_to_hex_uart(unsigned char a)
{
    puthex(a >> 4);
    puthex(a & 0x0F);
}
#endif

// Samples the initial dark screen 16 times for each sensor
// Stores the max value + THRESHOLD_OFFSET into threshold_{clock,data}
#define NUM_THRESHOLD_SAMPLES 16
#define THRESHOLD_OFFSET 0x10
void do_auto_thresholding(void)
{
    unsigned char count = NUM_THRESHOLD_SAMPLES;
    unsigned char temp = 0;
    while (count)
    {
        temp = analog_read(ANALOG_PIN_CLOCK);
        if (temp > threshold_clock)
        {
            threshold_clock = temp;
        }

        temp = analog_read(ANALOG_PIN_DATA);
        if (temp > threshold_data)
        {
            threshold_data = temp;
        }

        count--;
    }

    threshold_clock += THRESHOLD_OFFSET;
    threshold_data += THRESHOLD_OFFSET;

#ifdef DEBUG
    putch('c');
    unsigned_char_to_hex_uart(threshold_clock);
    putch('d');
    unsigned_char_to_hex_uart(threshold_data);
    putch('\n');
#endif
}

// This function assumes that we've already synchronized
unsigned char getch_blinky(void)
{
    #define POST_CLOCK_DELAY_US 500
    unsigned char byte = 0;
    unsigned char count = 8;
    static bit temp;
    static bit prior_clock = 0;
    while (count)
    {
        // waiting for the clock to change
        while ((temp = (analog_read(ANALOG_PIN_CLOCK) > threshold_clock)) == prior_clock)
        {
            // TODO add a check of the pushbutton to take us to some sort of sensor debugging routine
            // Once there maybe have it use the LEDs to show the sensor level? Or UART debug?
            // Press the button again to toggle between clock and data sensors?
        }
        // wait for the data sample time - TODO why do we need this? The data should be ready to sample when the clock has an edge
        __delay_us(POST_CLOCK_DELAY_US); // it would appear that if I move this line down by four, things break!
        prior_clock = temp;
        byte <<= 1;
        if (analog_read(ANALOG_PIN_DATA) >= threshold_data)
            byte |= 0b00000001; // set bit

        count--;
    }
    cksum += byte;
#ifdef GRID
    RC0 = ~RC0;
#endif //GRID

#ifdef POV
    RC1 = ~RC1;
#endif //POV
    //unsigned_char_to_hex_uart(byte);
    return byte;
}

unsigned char getch_uart(void)
{
    while (!RCIF);
    return RCREG;
}

// check the checksum
void checksum(void)
{
    getch(); // fetch the checksum byte
    if (cksum != 0) // if checksum does not add to zero, bad checksum, flash the lights! TODO what do do for grid?
    {
#ifdef DEBUG
        putch('n');
        putch('o');
        putch('\n');
        unsigned_char_to_hex_uart(cksum);
        __delay_ms(1);
#endif

        // this new "error!" 'message', on POV,  flashes  the 4th LED, indicating that you need to power cycle and retry
        PORTC = 0x00;
#ifdef GRID
        TRISA1 = 1;
        TRISA2 = 1;
        TRISC = 0b11111010;
        PORTC = 0b00000100;

        __delay_ms(250);

        while (1)
        {
            RC2 = ~RC2;
            RC0 = ~RC0;
            __delay_ms(250);
        }
#endif //GRID

#ifdef POV
        TRISC2 = 0;
        TRISC3 = 0;
        RC2 = 0;
        RC3 = 1;
        while (1)
        {
            RC2 = ~RC2;
            RC3 = ~RC3;
            __delay_ms(250);
        }
#endif //POV

    }

#ifdef DEBUG
    putch('\n');
#endif
}

// initiate a write to memory - this is the "required sequence" from the datasheet's example 11-5
void write_required_sequence(void)
{
    EECON2 = 0x55;
    EECON2 = 0xAA;
    WR = 1;              // initiate the write
    NOP();
    NOP();              // processor will stop here until write finishes
}

static void interrupt true_isr_vector(void)
{
    // ljmp is a macro instruction that will expand to a GOTO, along with any required instructions to set the bank
    #asm
        ljmp USER_ISR_VECTOR
    #endasm
}

void redirect_to_user(void)
{
    #asm
        ljmp USER_VECTOR
    #endasm
}

// Each byte is a vertical slice of the character, but it's 'upside down',
// meaning that the most significant bit of each slice is on the bottom.
// If we switched the order of LED connections, we could have it the other way.
#define FONT_NUM_LETTERS        0x29
#define FONT_WIDTH              5
const unsigned char font_table[FONT_NUM_LETTERS][FONT_WIDTH] @ 0x300 = {
    {0b00111110, 0b01010001, 0b01001001, 0b01000101, 0b00111110}, // 0x00 0
    {0b00000000, 0b01000010, 0b01111111, 0b01000000, 0b00000000}, // 0x01 1
    {0b01000010, 0b01100001, 0b01010001, 0b01001001, 0b01000110}, // 0x02 2
    {0b00100010, 0b01000001, 0b01001001, 0b01001001, 0b00110110}, // 0x03 3
    {0b00001100, 0b00001010, 0b01001001, 0b01111111, 0b01001000}, // 0x04 4
    {0b00101111, 0b01001001, 0b01001001, 0b01001001, 0b00110001}, // 0x05 5
    {0b00111110, 0b01001001, 0b01001001, 0b01001001, 0b00110010}, // 0x06 6
    {0b00000001, 0b01110001, 0b00001001, 0b00000101, 0b00000011}, // 0x07 7
    {0b00110110, 0b01001001, 0b01001001, 0b01001001, 0b00110110}, // 0x08 8
    {0b00100110, 0b01001001, 0b01001001, 0b01001001, 0b00111110}, // 0x09 9
    {0b01111110, 0b00001001, 0b00001001, 0b00001001, 0b01111110}, // 0x0A A
    {0b01111111, 0b01001001, 0b01001001, 0b01001001, 0b00110110}, // 0x0B B
    {0b00111110, 0b01000001, 0b01000001, 0b01000001, 0b00100010}, // 0x0C C
    {0b01111111, 0b01000001, 0b01000001, 0b01000001, 0b00111110}, // 0x0D D
    {0b01111111, 0b01001001, 0b01001001, 0b01001001, 0b01000001}, // 0x0E E
    {0b01111111, 0b00001001, 0b00001001, 0b00001001, 0b00001001}, // 0x0F F
    {0b00111110, 0b01000001, 0b01001001, 0b01001001, 0b00111010}, // 0x10 G
    {0b01111111, 0b00001000, 0b00001000, 0b00001000, 0b01111111}, // 0x11 H
    {0b00000000, 0b01000001, 0b01111111, 0b01000001, 0b00000000}, // 0x12 I
    {0b00110000, 0b01000000, 0b01000001, 0b00111111, 0b00000001}, // 0x13 J
    {0b01111111, 0b00001000, 0b00001000, 0b00010100, 0b01100011}, // 0x14 K
    {0b00000000, 0b01111111, 0b01000000, 0b01000000, 0b01000000}, // 0x15 L
    {0b01111111, 0b00000010, 0b00001100, 0b00000010, 0b01111111}, // 0x16 M
    {0b01111111, 0b00000010, 0b00001100, 0b00010000, 0b01111111}, // 0x17 N
    {0b00111110, 0b01000001, 0b01000001, 0b01000001, 0b00111110}, // 0x18 O
    {0b01111111, 0b00001001, 0b00001001, 0b00001001, 0b00000110}, // 0x19 P
    {0b00111110, 0b01000001, 0b01010001, 0b00100001, 0b01011110}, // 0x1A Q
    {0b01111111, 0b00001001, 0b00011001, 0b00101001, 0b01000110}, // 0x1B R
    {0b01000110, 0b01001001, 0b01001001, 0b01001001, 0b00110001}, // 0x1C S
    {0b00000001, 0b00000001, 0b01111111, 0b00000001, 0b00000001}, // 0x1D T
    {0b00111111, 0b01000000, 0b01000000, 0b01000000, 0b00111111}, // 0x1E U
    {0b00011111, 0b00100000, 0b01000000, 0b00100000, 0b00011111}, // 0x1F V
    {0b00111111, 0b01000000, 0b00111000, 0b01000000, 0b00111111}, // 0x20 W
    {0b01100011, 0b00010100, 0b00001000, 0b00010100, 0b01100011}, // 0x21 X
    {0b00000111, 0b00001000, 0b01110000, 0b00001000, 0b00000111}, // 0x22 Y
    {0b01100001, 0b01010001, 0b01001001, 0b01000101, 0b01000011}, // 0x23 Z
    {0b00000000, 0b01100000, 0b01100000, 0b00000000, 0b00000000}, // 0x24 period
    {0b00000000, 0b00000000, 0b01011110, 0b00000000, 0b00000000}, // 0x25 !
    {0b00110110, 0b01001001, 0b01010101, 0b00100010, 0b01010000}, // 0x26 &
    {0b00000010, 0b00000001, 0b01010001, 0b00001001, 0b00000110}, // 0x27 ?
    {0b00000000, 0b01010000, 0b00110000, 0b00000000, 0b00000000}, // 0x28 comma
                                                                  // 0x29 space (handled in user code)
};

void main(void)
{
    unsigned char count, addr_hi, addr_lo, rectype;

    di(); // disable interrupts
    OSCCON = 0b01111000; // 16 mhz

    // init button
    nWPUEN = 0;                 // globally enable weak pullups
    TRISA5 = 1;                 // RA5 is an input
    WPUA5 = 1;                  // turn on weak pullup on this pin

    // Should we start up the bootloader, or go straight to user code?
    // With a power switch on the battery holder, we just check if the switch is pressed at startup
    if (RA5 == 1)
    {
        // switch is not pressed
        redirect_to_user();
    }

    // init buttons
    ANSELC = 0;                 // all digital
    TRISC = 0xFF;               // all inputs
    PORTC = 0;

    TRISC0 = 0; // set PORTC0 to an output
    TRISC1 = 0;
    RC1 = 0;


    // switch is pressed, wait for the release to start
    while (!RA5)
    {
        //toggle the first led
        RC0 = ~RC0;
        __delay_ms(500);
    }
    __delay_ms(50);
    while (RA5)
    {
        RC0 = ~RC0;
        __delay_ms(250);
    }
    __delay_ms(50);
    while (!RA5)
    {
        RC0 = ~RC0;
        __delay_ms(100);
    }

    RC0 = 0;

    init_adc();
#ifdef DEBUG
    init_uart();
    __delay_ms(1);
    putch('\n');
    putch('\n');
    putch('o');
    putch('n');
    putch('\n');
    __delay_ms(1);
#endif

    // receive data and write it to progmem / eeprom
    CFGS = 0; // not config space

    do_auto_thresholding();
    RC1 = 1;

/*
    // This is a simple blinky-to-uart translator, good for testing operation and being cool.
    while (1)
    {
        putch(getch());
    }
*/

    /*
    // This helps to troubleshoot light levels to both sensors
    while (1)
    {
        unsigned int temp;
        temp = analog_read(ANALOG_PIN_CLOCK);
        unsigned_char_to_hex_uart(temp >> 8);
        unsigned_char_to_hex_uart(temp & 0xFF);
        putch('/');
        unsigned_char_to_hex_uart(threshold_clock >> 8);
        unsigned_char_to_hex_uart(threshold_clock & 0xFF);
        putch(' ');
        temp = analog_read(ANALOG_PIN_DATA);
        unsigned_char_to_hex_uart(temp >> 8);
        unsigned_char_to_hex_uart(temp & 0xFF);
        putch('/');
        unsigned_char_to_hex_uart(threshold_data >> 8);
        unsigned_char_to_hex_uart(threshold_data & 0xFF);
        putch('\n');
    }
    */


    /*
    // clear out the eeprom
    CFGS = 0;  // not config space
    EEPGD = 0; // destination is EEPROM
    WREN = 1; // enable writes
    EEADRL = 0x00;
    EEADRH = 0x00;
    count = 0xFF;
    while (count)
    {
        EEDATL = 0x00;
        EECON2 = 0x55;
        EECON2 = 0xAA;
        WR = 1;
        while (WR);
        EEADRL++;
        count--;
    }
    */

    while(1)
    {
        cksum = 0;                          // reset the checksum
        count = getch();                    // get the byte count
        unsigned char addr_hi = getch();
        unsigned char addr_lo = getch();
        rectype = getch();                  // get record type
        // 01   end of file record (comes last, causes us to jump to user code)
        // 06   eeprom data record
        if (rectype == 1)
        {
            // END OF FILE record: prepare to run new program
            checksum(); // will reset if error
#ifdef DEBUG
            putch('u');
            putch('\n');
#endif
#ifdef POV
            PORTC = 0xFF;
            PORTA = 0xFF;
            __delay_ms(500); // TODO why would this be only for POV?
#endif
            redirect_to_user();
        }
        else if (rectype == 6)
        {
            // EEPROM data record for blinky messages
            EEADRL = addr_lo;
            EEADRH = addr_hi;
            unsigned char data[16];
            unsigned char i;
            for (i = 0; i < count; i++)
            {
                data[i] = getch();
            }
            checksum();
            CFGS = 0;  // not config space
            EEPGD = 0; // destination is EEPROM
            WREN = 1; // enable writes
            //unsigned_char_to_hex_uart(EEADRH);
            //unsigned_char_to_hex_uart(EEADRL);
            //putch('\n');
            for (i = 0; i < count; i++)
            {
                EEDATL = data[i];
                EECON2 = 0x55;
                EECON2 = 0xAA;
                WR = 1;
                while (WR);
                EEADRL++;
            }
            WREN = 0; // disable writes
        }
        else
        {
            // some other record type
#ifdef DEBUG
            putch('!');
            putch('\n');
#endif
            continue;
        }
    } // main reception loop
}

