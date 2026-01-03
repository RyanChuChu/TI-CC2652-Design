;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                                                            ;
;                                  CPUreg.inc                                ;
;                            CPU Register Constants                          ;
;                                 Include File                               ;
;                                                                            ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; This file contains the constants for the CPU control registers for the TI
; CC2652 microcontroller.
;
; Revision History:
;     12/10/25  Li-Yu Chu      initial revision


; base addresses
PRCM_BASE_ADDR     .equ    0x40082000   ;power/reset/clock module registers


; register offsets
; PRCM - power/reset/clock module registers
PDCTL0_OFF         .equ    0x012C       ;power domain control register 0
PDSTAT0_OFF        .equ    0x0140       ;power domain status register 0

CLKLOADCTL_OFF     .equ    0x0028       ;load PRCM settings to CLKCTRL domain
GPIOCLKGR_OFF      .equ    0x0048       ;GPIO clock gate settings
GPTCLKGR_OFF       .equ    0x0054       ;GPT clock gate settings
GPTCLKDIV_OFF      .equ    0x00CC       ;GPT clock divisor register


; register bit and value definitions
; PDCTL0 - power domain control register 0
PD_PERIPH_EN       .equ    0x00000004   ;enable power to peripheral domain

; PDSTAT0       - power domain status register 0
PD_PERIPH_STAT     .equ    0x00000004   ;status of peripheral power domain

; GPIOCLKGR - GPIO clock gate settings
GPIOCLK_EN         .equ    0x00000001   ;enable GPIO clock in run mode

; GPTCLKGR - GPT clock gate settings
GPTCLK_EN          .equ    0x0000000F   ;enable all GPT clocks in run mode

; GPTCLKDIV - GPT clock divisor register
GPTCLKDIV_1        .equ    0x00000000   ;divide GPT incoming clock by 1

; CLKLOADCTL - load PRCM settings to CLKCTRL domain
CLKLOADCTL_LD      .equ    0x00000001   ;load CLKCTL power domain
CLKLOADCTL_STAT    .equ    0x00000002   ;status of CLKCLK power domain load