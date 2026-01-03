;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                                                            ;
;                                  GPTreg.inc                                ;
;                            GPT Register Constants                          ;
;                                 Include File                               ;
;                                                                            ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; This file contains the constants for the general purpose timer (GPT)
; control registers for the TI CC2652 microcontroller.
;
; Revision History:
;     12/01/25  Li-Yu Chu        initial revision


; base addresses
GPT0_BASE_ADDR     .equ    0x40010000   ;general purpose timer 0
GPT1_BASE_ADDR     .equ    0x40011000   ;general purpose timer 1
GPT2_BASE_ADDR     .equ    0x40012000   ;general purpose timer 2
GPT3_BASE_ADDR     .equ    0x40013000   ;general purpose timer 3

; register offsets (applies to all timers)
; GPT - General Purpose Timers
GPT_CFG_OFF        .equ    0x0000       ;configuration register
GPT_TAMR_OFF       .equ    0x0004       ;timer A mode register
GPT_TBMR_OFF       .equ    0x0008       ;timer B mode register
GPT_CTL_OFF        .equ    0x000C       ;control register
GPT_IMR_OFF        .equ    0x0018       ;interrupt mask register
GPT_RIS_OFF        .equ    0x001C       ;raw interrupt status register
GPT_ICLR_OFF       .equ    0x0024       ;interrupt clear register
GPT_TAILR_OFF      .equ    0x0028       ;timer A interval load register
GPT_TBILR_OFF      .equ    0x002C       ;timer B interval load register
GPT_TAMATCHR_OFF   .equ    0x0030       ;timer A match register
GPT_TBMATCHR_OFF   .equ    0x0034       ;timer B match register


; register bit and value definitions
; CFG - configuration register
GPT_CFG_32x1       .equ    0x00000000   ;configure as a single 32-bit timer
GPT_CFG_16x2       .equ    0x00000004   ;configure as two 16-bit timers

; CTL - control register
GPT_CTL_TAEN          .equ    0x00000001   ;enable timer A
GPT_CTL_TABEN_PWM_INV .equ    0x00004141   ;enable timer A and B with inverted PWM output

; IMR - interrupt mask register
; RIS - raw interrupt status register
; MIS - masked interrupt status register
; ICLR - interrupt clear register
GPT_IRQ_TATO       .equ    0x00000001   ;timer A timeout interrupt

; TxMR - timer A/B mode register
GPT0A_MODE         .equ    0x00000001   ;timer 0A is a down counting one-shot timer
GPT1A_MODE         .equ    0x00000002   ;timer 1A is a down counting periodic timer
GPT2A_MODE         .equ    0x0000100A   ;timer 2A is a down counting PWM timer 
                                        ;with output starting low and interrupts disabled
GPT2B_MODE         .equ    0x0000100A   ;timer 2B is a down counting PWM timer
                                        ;with output starting low and interrupts disabled
GPT3A_MODE         .equ    0x0000100A   ;timer 3A is a down counting PWM timer
                                        ;with output starting low and interrupts disabled
GPT3B_MODE         .equ    0x0000100A   ;timer 3B is a down counting PWM timer
                                        ;with output starting low and interrupts disabled


