;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                                                            ;
;                                  init.inc                                  ;
;                           HW2 Control Registers                            ;
;                                Include File                                ;
;                                                                            ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; This file contains the constants for HW2 control registers, including base 
; addresses, offsets, and register bit and value definitions.
;
; Revision History
;     11/07/25  Li-Yu Chu        initial revision

; base addresses
PRCM_BASE_ADDR     .equ    0x40082000   ;power/reset/clock module registers
SCS_BASE_ADDR      .equ    0xE000E000   ;core system control space registers
IOC_BASE_ADDR      .equ    0x40081000   ;I/O Controller registers
GPIO_BASE_ADDR     .equ    0x40022000   ;General Purpose I/O registers
GPT0_BASE_ADDR     .equ    0x40010000   ;general purpose timer 0


; register offsets
; PRCM - power/reset/clock module registers
PDCTL0_OFF         .equ    0x012C       ;power domain control register 0
PDSTAT0_OFF        .equ    0x0140       ;power domain status register 0

GPIOCLKGR_OFF      .equ    0x0048       ;GPIO clock gate settings
GPTCLKGR_OFF       .equ    0x0054       ;GPT clock gate settings
GPTCLKDIV_OFF      .equ    0x00CC       ;GPT clock divisor register
CLKLOADCTL_OFF     .equ    0x0028       ;load PRCM settings to CLKCTRL domain

; SCS - system control space registers
NVIC_ISER0         .equ    0x0100       ;interrupt set enable (irq 0-31)
NVIC_ISER1         .equ    0x0104       ;interrupt set enable (irq 32-63)
VTOR_OFF           .equ    0x0D08       ;vector table offset register

; IOC - I/O Controller register 
IOCFG8             .equ    0x0020       ;I/O configuration for DIO8
IOCFG9             .equ    0x0024       ;I/O configuration for DIO9
IOCFG12            .equ    0x0030       ;I/O configuration for DIO12
IOCFG13            .equ    0x0034       ;I/O configuration for DIO13
IOCFG14            .equ    0x0038       ;I/O configuration for DIO14
IOCFG15            .equ    0x003C       ;I/O configuration for DIO15

; GPIO - General Purpose I/O Registers
GPIO_DOE31_0_OFF   .equ    0x00D0       ;data output enable bits 0 to 31
GPIO_DIN31_0_OFF   .equ    0x00C0       ;data input bits 0 to 31
GPIO_DSET31_0_OFF  .equ    0x0090       ;set data out bits 0 to 31
GPIO_DCLR31_0_OFF  .equ    0x00A0       ;clear data out bits 0 to 31

; GPT - General Purpose Timers
GPT_CFG_OFF        .equ    0x0000       ;configuration register
GPT_CTL_OFF        .equ    0x000C       ;control register
GPT_IMR_OFF        .equ    0x0018       ;interrupt mask register
GPT_TAMR_OFF       .equ    0x0004       ;timer A mode register
GPT_TAILR_OFF      .equ    0x0028       ;timer A interval load register
GPT_ICLR_OFF       .equ    0x0024       ;interrupt clear register


; register bit and value definitions
; PDCTL0 - power domain control register 0
PD_PERIPH_EN       .equ    0x00000004   ;enable power to peripheral domain

; PDSTAT0 - power domain status register 0
PD_PERIPH_STAT     .equ    0x00000004   ;status of peripheral power domain

; GPIOCLKGR - GPIO clock gate settings
GPIOCLK_EN         .equ    0x00000001   ;enable GPIO clock in run mode

; GPTCLKGR - GPT clock gate settings
GPT0CLK_EN         .equ    0x00000001   ;enable GPT0 clock in run mode

; GPTCLKDIV - GPT clock divisor register
GPTCLKDIV_1        .equ    0x00000000   ;divide GPT incoming clock by 1

; CLKLOADCTL - load PRCM settings to CLKCTRL domain
CLKLOADCTL_LD      .equ    0x00000001   ;load CLKCTRL power domain
CLKLOADCTL_STAT    .equ    0x00000002   ;status of CLKCTRL power domain load

; IOC - I/O Controller register 
IOCFG_GEN_DIN_PU   .equ    0x20004000   ;data input pin for keypad columns (debouncing)
                                        ;0------------------------------- reserved
                                        ;-0------------------------------ no hysteresis
                                        ;--1----------------------------- input
                                        ;---00--------------------------- no wakeup
                                        ;-----000------------------------ normal mode
                                        ;--------000--------------------- no edge detect events
                                        ;-----------00------------------- reserved
                                        ;-------------0------------------ no edge detect IRQ
                                        ;--------------00---------------- no edge detection
                                        ;----------------0--------------- reserved
                                        ;-----------------10------------- internal pull up
                                        ;-------------------0------------ normal slew
                                        ;--------------------00---------- 2mA output
                                        ;----------------------00-------- auto drive strength control
                                        ;------------------------0------- no edge detect RTC event
                                        ;-------------------------0------ no edge detect wake up event
                                        ;--------------------------000000 general purpose I/O

IOCFG_GEN_DOUT     .equ    0x00006000   ;data output pin for keypad rows (scanning)
                                        ;0------------------------------- reserved
                                        ;-0------------------------------ no hysteresis
                                        ;--0----------------------------- output
                                        ;---00--------------------------- no wakeup
                                        ;-----000------------------------ normal mode
                                        ;--------000--------------------- no edge detect events
                                        ;-----------00------------------- reserved
                                        ;-------------0------------------ no edge detect IRQ
                                        ;--------------00---------------- no edge detection
                                        ;----------------0--------------- reserved
                                        ;-----------------11------------- no pull up/down
                                        ;-------------------0------------ normal slew
                                        ;--------------------00---------- 2mA output
                                        ;----------------------00-------- auto drive strength control
                                        ;------------------------0------- no edge detect RTC event
                                        ;-------------------------0------ no edge detect wake up event
                                        ;--------------------------000000 general purpose I/O

; GPT - General Purpose Timer
; CFG - configuration register
GPT_CFG_32x1       .equ    0x00000000   ;configure as a single 32-bit timer  

; CTL - control register
GPT_CTL_TAEN       .equ    0x00000001   ;enable timer A

; IMR - interrupt mask register
; ICLR - interrupt clear register
GPT_IRQ_TATO       .equ    0x00000001   ;timer A timeout interrupt

; TAMR - timer A mode register
GPT0A_MODE         .equ    0x00000002   ;timer 0A is a down periodic timer
