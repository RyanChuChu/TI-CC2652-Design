;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                                                            ;
;                                constant.inc                                ;
;                              HW1 Include File                              ;
;                                                                            ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; This file contains the constants for HW1 program, including base addresses,
; offsets, and register bit and value definitions.
;
; Revision History
;     10/22/25  Li-Yu Chu        initial revision


; general constants
FALSE              .equ    0            ;false
TRUE               .equ    1            ;true - non-zero
BYTES_PER_WORD     .equ    4            ;4 bytes in each word


; system constants
HANDLER_STACK_SIZE .equ    128          ;interrupt handler stack size
PROCESS_STACK_SIZE .equ    256          ;main loop stack size
TOTAL_STACK_SIZE   .equ    PROCESS_STACK_SIZE + HANDLER_STACK_SIZE


; base addresses
PRCM_BASE_ADDR     .equ    0x40082000   ;power/reset/clock module registers
SCS_BASE_ADDR      .equ    0xE000E000   ;core system control space registers
IOC_BASE_ADDR      .equ    0x40081000   ;I/O Controller registers
GPIO_BASE_ADDR     .equ    0x40022000   ;General Purpose I/O registers



; register offsets
; PRCM - power/reset/clock module registers
PDCTL0_OFF         .equ    0x012C       ;power domain control register 0
PDSTAT0_OFF        .equ    0x0140       ;power domain status register 0

GPIOCLKGR_OFF      .equ    0x0048       ;GPIO clock gate settings
CLKLOADCTL_OFF     .equ    0x0028       ;load PRCM settings to CLKCTRL domain

; IOC - I/O Controller register 
IOCFG6             .equ    0x0018       ;I/O configuration for DIO6
IOCFG7             .equ    0x001C       ;I/O configuration for DIO7
IOCFG13            .equ    0x0034       ;I/O configuration for DIO13
IOCFG14            .equ    0x0038       ;I/O configuration for DIO14

; GPIO - General Purpose I/O Registers
GPIO_DOE31_0_OFF   .equ    0x00D0       ;data output enable bits 0 to 31
GPIO_DIN31_0_OFF   .equ    0x00C0       ;data input bits 0 to 31
GPIO_DSET31_0_OFF  .equ    0x0090       ;set data out bits 0 to 31
GPIO_DCLR31_0_OFF  .equ    0x00A0       ;clear data out bits 0 to 31


; register bit and value definitions
; PDCTL0 - power domain control register 0
PD_PERIPH_EN       .equ    0x00000004   ;enable power to peripheral domain

; PDSTAT0 - power domain status register 0
PD_PERIPH_STAT     .equ    0x00000004   ;status of peripheral power domain

; GPIOCLKGR - GPIO clock gate settings
GPIOCLK_EN         .equ    0x00000001   ;enable GPIO clock in run mode

; CLKLOADCTL - load PRCM settings to CLKCTRL domain
CLKLOADCTL_LD      .equ    0x00000001   ;load CLKCTRL power domain
CLKLOADCTL_STAT    .equ    0x00000002   ;status of CLKCTRL power domain load


; IOC - I/O Controller register 
IOCFG_GEN_DIN_PU    .equ   0x20004000   ;general purpose data input pin for switches
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
                                        ;-----------------10------------- pull up (switches are active low)
                                        ;-------------------0------------ normal slew
                                        ;--------------------00---------- 2mA output
                                        ;----------------------00-------- auto drive strength control
                                        ;------------------------0------- no edge detect RTC event
                                        ;-------------------------0------ no edge detect wake up event
                                        ;--------------------------000000 general purpose I/O

IOCFG_GEN_DOUT_4MA .equ    0x00006400   ;general purpose data output pin with 4mA drive
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
                                        ;--------------------01---------- 4mA output
                                        ;----------------------00-------- auto drive strength control
                                        ;------------------------0------- no edge detect RTC event
                                        ;-------------------------0------ no edge detect wake up event
                                        ;--------------------------000000 general purpose I/O

; I/O constants
REDLED_IO_BIT      .equ    6            ;red LED on bit 6
GREENLED_IO_BIT    .equ    7            ;green LED on bit 7
LEFTSWITCH_IO_BIT  .equ    13           ;left switch on bit 13
RIGHTSWITCH_IO_BIT .equ    14           ;right switch on bit 14
LED_SWITCH_DIFF    .equ    7            ;the bit location difference between LED and switch 
                                        ;7 = 13 - 6 = 14 - 7