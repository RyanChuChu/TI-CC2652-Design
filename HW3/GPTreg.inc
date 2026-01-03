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
;     11/20/25  Li-Yu Chu        initial revision


; base addresses
GPT0_BASE_ADDR     .equ    0x40010000   ;general purpose timer 0


; register offsets (applies to all timers)
; GPT - General Purpose Timers
GPT_CFG_OFF        .equ    0x0000       ;configuration register
GPT_CTL_OFF        .equ    0x000C       ;control register
GPT_TAMR_OFF       .equ    0x0004       ;timer A mode register
GPT_RIS_OFF        .equ    0x001C       ;raw interrupt status register
GPT_ICLR_OFF       .equ    0x0024       ;interrupt clear register
GPT_TAILR_OFF      .equ    0x0028       ;timer A interval load register


; register bit and value definitions
; CFG - configuration register
GPT_CFG_32x1       .equ    0x00000000   ;configure as a single 32-bit timer

; CTL - control register
GPT_CTL_TAEN       .equ    0x00000001   ;enable timer A

; RIS - raw interrupt status register
; ICLR - interrupt clear register
GPT_IRQ_TATO       .equ    0x00000001   ;timer A timeout interrupt

; TAMR - timer A mode register
GPT0A_MODE         .equ    0x00000001   ;timer 0A is a down counting one-shot timer
