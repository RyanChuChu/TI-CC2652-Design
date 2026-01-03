;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                                                            ;
;                                  IOCreg.inc                                ;
;                            IOC Register Constants                          ;
;                                 Include File                               ;
;                                                                            ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; This file contains the constants for the IOC control registers for the TI
; CC2652 microcontroller.
;
; Revision History:
;     11/20/25  Li-Yu Chu      initial revision

; base addresses
IOC_BASE_ADDR      .equ    0x40081000   ;I/O Controller registers

; register offsets
; IOC - I/O Controller registers
IOCFG8             .equ    0x0020       ;I/O configuration for DIO8
IOCFG9             .equ    0x0024       ;I/O configuration for DIO9
IOCFG10            .equ    0x0028       ;I/O configuration for DIO10
IOCFG11            .equ    0x002C       ;I/O configuration for DIO11
IOCFG12            .equ    0x0030       ;I/O configuration for DIO12
IOCFG13            .equ    0x0034       ;I/O configuration for DIO13
IOCFG14            .equ    0x0038       ;I/O configuration for DIO14
IOCFG15            .equ    0x003C       ;I/O configuration for DIO15

IOCFG18            .equ    0x0048       ;I/O configuration for DIO18
IOCFG19            .equ    0x004C       ;I/O configuration for DIO19
IOCFG20            .equ    0x0050       ;I/O configuration for DIO20

; register value definitions (applies to all registers)
IOCFG_GEN_DIN      .equ    0x20006000   ;general purpose data input pin
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
                                        ;-----------------11------------- no pull up/down
                                        ;-------------------0------------ normal slew
                                        ;--------------------00---------- 2mA output
                                        ;----------------------00-------- auto drive strength control
                                        ;------------------------0------- no edge detect RTC event
                                        ;-------------------------0------ no edge detect wake up event
                                        ;--------------------------000000 general purpose I/O

IOCFG_GEN_DOUT     .equ    0x00006000   ;general purpose data output pin
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
