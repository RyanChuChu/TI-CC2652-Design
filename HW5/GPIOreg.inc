;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                                                            ;
;                                GPIOreg.inc                                 ;
;                           GPIO Register Constants                          ;
;                                Include File                                ;
;                                                                            ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; This file contains the constants for the GPIO control registers for the TI
; CC2652 microcontroller.
;
; Revision History
;     11/20/25  Li-Yu Chu        initial revision

; base addresses
GPIO_BASE_ADDR     .equ    0x40022000   ;General Purpose I/O registers


; register offsets
; GPIO - General Purpose I/O Registers
GPIO_DOUT31_0_OFF  .equ    0x0080       ;data out bits 0 to 31
GPIO_DSET31_0_OFF  .equ    0x0090       ;set data out bits 0 to 31
GPIO_DCLR31_0_OFF  .equ    0x00A0       ;clear data out bits 0 to 31
GPIO_DIN31_0_OFF   .equ    0x00C0       ;data input bits 0 to 31
GPIO_DOE31_0_OFF   .equ    0x00D0       ;data output enable bits 0 to 31
