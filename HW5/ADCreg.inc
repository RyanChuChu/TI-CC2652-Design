;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                                                            ;
;                                 ADCreg.inc                                 ;
;                           ADC Register Constants                           ;
;                                Include File                                ;
;                                                                            ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; This file contains the constants for the ADC control registers for the TI
; CC2652 microcontroller.
;
; Revision History
;     12/11/25  Li-Yu Chu        initial revision

; base addresses
AUX_SYSIF_BASE_ADDR     .equ    0x400C6000      ;AUX Domain System Interface
AUX_ANAIF_BASE_ADDR     .equ    0x400C9000      ;AUX Domain Analog Interface   
AUX_ADI4_BASE_ADDR      .equ    0x400CB000      ;AUX Domain Analog Digital Interface Master
AUX_AIODIO3_BASE_ADDR   .equ    0x400CF000      ;AUX Domain Analog Digital I/O 3


; register offsets
; ADI_4_AUX - AUX Domain Analog Digital Interface Master
MUX_3_OFF               .equ    0x3             ;ADCCOMPB_IN, select AUXIO input
ADC0_OFF                .equ    0x8             ;ADC Sample Control
ADCREF0_OFF             .equ    0xA             ;ADC Reference 0

; AUX_AIODIO3 - AUX Domain Analog Digital I/O 3
IOMODE_OFF              .equ    0x0             ;Input Output Mode
GPIODIE_OFF             .equ    0x4             ;General Purpose Input Output Digital Input Enable

; AUX_SYSIF - AUX Domain System Interface
ADCCLKCTL_OFF           .equ    0x50            ;ADC Clock Control

; AUX_ANAIF - AUX Domain Analog Interface 
ADCCTL_OFF              .equ    0x10            ;ADC Control
ADCFIFOSTAT_OFF         .equ    0x14            ;ADC FIFO Status
ADCFIFO_OFF             .equ    0x18            ;ADC FIFO
ADCTRIG_OFF             .equ    0x1C            ;ADC Trigger


; register bit and value definitions
; ADCCLKCTL - ADC Clock Control
ADCCLKCTL_EN            .equ    0x01            ;enable ADC clock
ADCCLKCTL_ACK_EN        .equ    0x03            ;ADC clock enabled

; COMPB - Low-power clocked comparator
; MUX3 - Selecting AUXIO inputs for ADCCOMPB_IN
MUX_3_AUXIO26           .equ    0x01            ;select AUX26 for MUX3 input

; ADC0 - ADC Sample Control
ADC_ASYNC_NOR_EN        .equ    0x83            ;asynchronous sample mode, normal mode and enable

; ADCREF0 - ADC Reference 0
ADCREF_EN               .equ    0x01            ;ADC reference module enabled

; IOMODE - Input Output Mode
AUXIO26_INPUT_MODE      .equ    0x0010          ;set AUXIO26 to input mode

; GPIODIE - General Purpose Input Output Digital Input Enable
ADC_GPIODIE_DIS         .equ    0x00            ;disable digital input buffer for analog input

; ADCCTL - ADC Control
ADC_CFG_FLUSH           .equ    0x3F03          ;flush ADC FIFO
ADC_CFG_EN              .equ    0x3F01          ;enable ADC Interface

; ADCFIFOSTAT - ADC Status
ADCFIFO_NOT_EMPTY       .equ    0x00            ;ADC FIFO is not empty
ADCFIFO_EMPTY           .equ    0x01            ;ADC FIFO is empty

; ADCTRIG - ADC Trigger
ADCTRIG_START           .equ    0x1             ;Single ADC trigger