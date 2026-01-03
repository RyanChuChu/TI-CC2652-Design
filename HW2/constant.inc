;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                                                            ;
;                                 constant.inc                               ;
;                             HW2 General Constants                          ;
;                                 Include File                               ;
;                                                                            ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; This file contains the constants for the HW2, including general constants, 
; system constants, event handler constants, I/O constants and timing constatns
;
; Revision History:
;    11/07/25  Li-Yu Chu      initial revision
;    11/08/25  Li-Yu Chu      threshold adjustment    


; general constants
FALSE                   .equ    0            ;false
TRUE                    .equ    1            ;true - non-zero
BYTES_PER_WORD          .equ    4            ;4 bytes in each word


; system constants
HANDLER_STACK_SIZE      .equ    128          ;interrupt handler stack size
PROCESS_STACK_SIZE      .equ    256          ;main loop stack size
TOTAL_STACK_SIZE        .equ    PROCESS_STACK_SIZE + HANDLER_STACK_SIZE

VEC_TABLE_SIZE          .equ    54           ;number of interrupts in table

QUEUE_SIZE              .equ    100          ;the size of queue for storing debounced keys

GPT0A_EX_NUM            .equ    31           ;exception number for GPT0 Timer A
GPT0A_IRQ_NUM           .equ    GPT0A_EX_NUM - 16       ;interrupt number for GPT0 Timer A

; event handler constants
RESET_POSITION          .equ    0            ;reset current position to row = 0, column = 0
RESET_CNTR              .equ    0            ;reset debounce counter to 0
DEBOUNCE_LOOP_THRESHOLD .equ    40          ;the lower bound number of loops for a key to be debounced
ROW_DECODER_DIFF        .equ    6            ;the row is stored on bit 3 and 2 on the register
                                             ;the decoder reads output from DIO[9..8]
                                             ;9 - 3 = 8 - 2 = 6
POS1_POS2_DIFF          .equ    4            ;to store 2 keys, we use bit 7 to bit 4 to store the
                                             ;position of the second key, so we shift 4 bits

; row bits: bit 3 and bit 2
ROW0                    .equ    0            ;current row = 0
ROW1                    .equ    4            ;current row = 1
ROW2                    .equ    8            ;current row = 2
ROW3                    .equ    12           ;current row = 3
TRANS_ROW               .equ    4            ;transition from row n to row n+1

;column bits: bit 1 and bit 0
COL0                    .equ    0            ;current column = 0
COL1                    .equ    1            ;current column = 1
COL2                    .equ    2            ;current column = 2
COL3                    .equ    3            ;current column = 3

;pattern constants
HIGH_INPUT              .equ    0x0000F000   ;all high inputs from DIO[15..12]
COL0_PRESSED            .equ    0x0000E000   ;if pressed key is on column 0 (DIO 12 = 0)
COL1_PRESSED            .equ    0x0000D000   ;if pressed key is on column 1 (DIO 13 = 0)
COL2_PRESSED            .equ    0x0000B000   ;if pressed key is on column 2 (DIO 14 = 0)
COL3_PRESSED            .equ    0x00007000   ;if pressed key is on column 3 (DIO 15 = 0)

COL_01_PRESSED          .equ    0x0000C000   ;if pressed key is on both column 0 and 1 (DIO12 = 0, DIO 13 = 0)
COL_02_PRESSED          .equ    0x0000A000   ;if pressed key is on both column 0 and 2 (DIO12 = 0, DIO 14 = 0)
COL_03_PRESSED          .equ    0x00006000   ;if pressed key is on both column 0 and 3 (DIO12 = 0, DIO 15 = 0)
COL_12_PRESSED          .equ    0x00009000   ;if pressed key is on both column 1 and 2 (DIO13 = 0, DIO 13 = 0)
COL_13_PRESSED          .equ    0x00005000   ;if pressed key is on both column 1 and 3 (DIO13 = 0, DIO 14 = 0)
COL_23_PRESSED          .equ    0x00003000   ;if pressed key is on both column 2 and 3 (DIO14 = 0, DIO 15 = 0)


; I/O constants
DECODERA_TO_BIT         .equ    8            ;decoder Input A on bit 8
DECODERB_TO_BIT         .equ    9            ;decoder Input B on bit 9


; timing constants
CLK_PER_MS              .equ    48000        ;timer clocks per millisecond