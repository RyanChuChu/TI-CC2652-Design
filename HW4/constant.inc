;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                                                            ;
;                                 constant.inc                               ;
;                             HW4 General Constants                          ;
;                                 Include File                               ;
;                                                                            ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; This file contains the constants for the HW4, including general constants, 
; system constants, I/O constants and timing constants for both stepper motor
; and LCD.
;
; Revision History:
;    11/30/25  Li-Yu Chu      initial revision
;    12/02/25  Li-Yu Chu      update stepper motor constants


; general constants
FALSE                   .equ    0            ;false
TRUE                    .equ    1            ;true - non-zero
BYTES_PER_WORD          .equ    4            ;4 bytes in each word


; system constants
HANDLER_STACK_SIZE      .equ    128          ;interrupt handler stack size
PROCESS_STACK_SIZE      .equ    256          ;main loop stack size
TOTAL_STACK_SIZE        .equ    PROCESS_STACK_SIZE + HANDLER_STACK_SIZE

VEC_TABLE_SIZE          .equ    54           ;number of interrupts in table

GPT1A_EX_NUM            .equ    33           ;exception number for GPT1 Timer A
GPT1A_IRQ_NUM           .equ    GPT1A_EX_NUM - 16       ;interrupt number for GPT1 Timer A

HOME_POS                .equ    0            ;home position angle is 0
ANGLE_RES               .equ    6            ;the degree resolution for angle
ANGLE_HALFRES           .equ    ANGLE_RES/2  ;the degree resolution for angle
ANGLE_FULL              .equ    360          ;a full circle is 360 degrees

BYTE_PER_ENTRY          .equ    16           ;for PWM table, there are 16 bytes per entry

SETANGLE_OPCODE         .equ    0            ;for test table, SetAngle opcode is 0
SETRELANGLE_OPCODE      .equ    1            ;for test table, SetRelAngle opcode is 1
HOMESTEPPER_OPCODE      .equ    2            ;for test table, HomeStepper opcode is 2
SETHOMESTEPPER_OPCODE   .equ    3            ;for test table, SetHomeStepper opcode is 3
GETANGLE_OPCODE         .equ    4            ;for test table, GetAngle opcode is 4

ANGLE_STRING_LENGTH     .equ    3            ;output a 3-digit decimal string in GetAngle
NUM_ASCII_OFF           .equ    0x30         ;the conversion offset between value and character
                                             ;is '0' = 0x30
HUNDRED                 .equ    100          ;100, for computing first digit of the string
TEN                     .equ    10           ;10, for computing second digit of the string


;I/O constants
; STEPPER_ALL           .equ    0x00600018   ;stepper motor GPIO bit location
;                                            ;A and A_bar: DIO22, DIO21
;                                            ;B and B_bar: DIO5, DIO4
                                             ;DOE doesn't affect PWM output, no need to set
                                             ;specific DOE bits

;timing constants
MAIN_ROUTINE_ILR        .equ    20 * CLK_PER_MS     ;set main routine generate 20Hz interrupt
PWM_ILR                 .equ    4800                ;set output PWM to 10kHz
RESET_MATCHR            .equ    0                   ;reset to 0% duty cycle for all outputs

;LCD constants
;system constants
NO_DELAY_COUNT          .equ    -1           ;no delay count specified in initialization

GPT0_TIMEOUT            .equ    1            ;timer 0 generated timeout at GPT0:RIS

DISPLAY_MODE            .equ    1            ;Operation code for Display
DISPLAYCHAR_MODE        .equ    0            ;Operation code for DisplayChar

INSTR_RS                .equ    0            ;RS = 0 when writing LCD command
DATA_RS                 .equ    1            ;RS = 1 when writing data

RESET_COUNTER           .equ    1            ;counter is initialized to 1 at display


;position constants
CURRENT_POS             .equ    -1           ;current position expression

ROW_LOW                 .equ    0            ;lower bound of rows
ROW_HIGH                .equ    2            ;upper bound of rows (effective row: 0 - 1)
COL_LOW                 .equ    0            ;lower bound of columns
COL_HIGH                .equ    24           ;upper bound of columns (effective columns: 0 - 23)

ROW_MASK                .equ    1            ;only bit 0 matters for wrapping output


; I/O constants
LCD_DATA                .equ    0x0000FF00   ;LCD data bit location
LCD_CONTROL             .equ    0x001C0000   ;LCD control signals bit location
LCD_ALL                 .equ    0x001CFF00   ;LCD all GPIO pins for output enable
LCD_ENABLE              .equ    18           ;LCD enable is on DIO18
LCD_RW                  .equ    19           ;LCD read/write is on DIO19,
                                             ;also for bi-directional buffer transmit/receive (T/R)
LCD_RS                  .equ    20           ;LCD register select is on DIO20

DATA_TO_DIO             .equ    8            ;align data to data pins DIO[8..15]
SET_DD_RAM              .equ    0x00000080   ;for set DD RAM, DB7 = 1
ROW_TO_ADDR             .equ    6            ;row is specified on DB6
                                             ;column uses DB[5:0]

READ_MASK               .equ    0x00008000   ;Busy flag is on DIO15
READ_DONE               .equ    0x00000000   ;Busy flag = 0 when finished

; timing constants
CLK_PER_MS              .equ    48000        ;timer clocks per millisecond
CLK_PER_US              .equ    48           ;timer clocks per microsecond
ENABLE                  .equ    12           ;the pulse width for read/write is 250ns
INSTR_DELAY             .equ    2 * CLK_PER_MS      ;for InitLCD, setup a 2ms waiting time for LCD command
DISPLAY_DELAY           .equ    40 * CLK_PER_US     ;for Display, setup a 40us waiting time for LCD command
MAIN_DELAY              .equ    1000 * CLK_PER_MS   ;for main loop, setup a 1s waiting time
                                                    ;between each test case 