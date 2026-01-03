;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                                                            ;
;                                    HW3                                     ;
;                     LCD Interface Initialization Functions                 ;
;                                                                            ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; This file contains the initialization of the HW3 LCD interface system.
; This file include the following functions:
;       InitPower          - Turn on the power to the peripherals.
;       InitClocks         - Turn on the clock to the peripherals.
;       InitGPIO           - Initialize the I/O pins for the keypad.
;       InitGPT0           - Initialize GPT0 and sets up the timer to
;                            generate interrupts every millisecond.
;
; Revision History:
;       11/20/25     Li-Yu Chu             initial revision

; local include file
        .include  "CPUreg.inc"
        .include  "GPIOreg.inc"
        .include  "IOCreg.inc"
        .include  "GPTreg.inc"
        .include  "constant.inc"
        .include  "macro.inc"

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; data
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        .data
        
        ;initialization functions
        .def InitPower               ;turn on power to everything
        .def InitClocks              ;turn on clocks to everything
        .def InitGPIO                ;setup the I/O pins for LCD control signals
        .def InitGPT0                ;initialize the general purpose timer


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; code
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        .text

; InitPower
;
; Description:       Turn on the power to the peripherals. 
;
; Operation:         Setup PRCM registers to turn on power to the peripherals.
;
; Arguments:         None.
; Return Value:      None.
;
; Local Variables:   None.
; Shared Variables:  None.
; Global Variables:  None.
;
; Input:             None.
; Output:            None.
;
; Error Handling:    None.
;
; Algorithms:        None.
; Data Structures:   None.
;
; Registers Changed: flags, R0, R1
; Stack Depth:       0 words
;
; Known Bugs:        None.
; Limitation:        None.
;
; Revision History:  11/07/25   Li-Yu Chu      initial revision

InitPower:
        MOV32   R1, PRCM_BASE_ADDR              ;get base for power registers
        STREG   PD_PERIPH_EN, R1, PDCTL0_OFF    ;turn on peripheral power

WaitPowerOn:                                    ;wait for power on
        LDR     R0, [R1, #PDSTAT0_OFF]          ;get power status
        ANDS    R0, #PD_PERIPH_STAT             ;check if power is on (Z = 1)
        BEQ     WaitPowerOn                     ;if not, keep checking
        ;BNE    DonePeriphPower                 ;otherwise done

DonePeriphPower:                                ;done turning on peripherals
        BX      LR


; InitClocks
;
; Description:       Turn on the clock to the peripherals. 
;
; Operation:         Setup PRCM registers to turn on clock to the peripherals.
;
; Arguments:         None.
; Return Value:      None.
;
; Local Variables:   None.
; Shared Variables:  None.
; Global Variables:  None.
;
; Input:             None.
; Output:            None.
;
; Error Handling:    None.
;
; Algorithms:        None.
; Data Structures:   None.
;
; Registers Changed: flags, R0, R1
; Stack Depth:       0 words
;
; Known Bugs:        None.
; Limitation:        None.
;
; Revision History:  11/07/25   Li-Yu Chu      initial revision

InitClocks:
        MOV32   R1, PRCM_BASE_ADDR                 ;get base for power registers
        STREG   GPIOCLK_EN, R1, GPIOCLKGR_OFF      ;turn on GPIO clocks
        STREG   GPT0CLK_EN, R1, GPTCLKGR_OFF       ;turn on Timer 0 clocks
        STREG   GPTCLKDIV_1, R1, GPTCLKDIV_OFF     ;timers get 48MHz system clock (by default)

        STREG   CLKLOADCTL_LD, R1, CLKLOADCTL_OFF  ;load clock settings

WaitClocksLoaded:                                  ;wait for clocks to be loaded
        LDR     R0, [R1, #CLKLOADCTL_OFF]          ;get clock status
        ANDS    R0, #CLKLOADCTL_STAT               ;check if clocks are on (Z = 1)
        BEQ     WaitClocksLoaded                   ;if not, keep checking
        ;BNE    DoneClockSetup                     ;otherwise done

DoneClockSetup:                                    ;done setting up clock
        BX      LR

; InitGPIO
;
; Description:       Initialize the I/O pins for the LCD.
;
; Operation:         Setup DIO[18..20] to be outputs for LCD control signals
;                    and bi-directional buffer input T/R. 
;
; Arguments:         None.
; Return Value:      None.
;
; Local Variables:   None.
; Shared Variables:  None.
; Global Variables:  None.
;
; Input:             None.
; Output:            None.
;
; Error Handling:    None.
;
; Algorithms:        None.
; Data Structures:   None.
;
; Registers Changed: R0, R1
; Stack Depth:       0 words
;
; Known Bugs:        None.
; Limitation:        This setup is only for LCD with only 2 rows (1 Enable pin only)
;
; Revision History:  11/07/25   Li-Yu Chu      initial revision

InitGPIO:                               
                                        ;configure outputs for LCD and buffer inputs
        MOV32   R1, IOC_BASE_ADDR       ;get base for I/O control registers
        MOV32   R0, IOCFG_GEN_DOUT      ;setup for general outputs
        STR     R0, [R1, #IOCFG18]      ;write configuration for Enable
        STR     R0, [R1, #IOCFG19]      ;write configuration for R/W
        STR     R0, [R1, #IOCFG20]      ;write configuration for RS

                                        ;enable outputs for LCD control signal bits
        MOV32   R1, GPIO_BASE_ADDR      ;get base for GPIO registers
        STREG   LCD_CONTROL, R1, GPIO_DCLR31_0_OFF ;clear output for buffer input
        STREG   LCD_CONTROL, R1, GPIO_DOE31_0_OFF  ;enable GPIO output

        BX      LR                      ;done so return

; InitGPT0
;
; Description:       This function initializes GPT0. 
;
; Operation:         The appropriate values are written to the timer control
;                    registers.  Also, the timer count registers are reset. 
;
; Arguments:         None.
; Return Value:      None.
;
; Local Variables:   None.
; Shared Variables:  None.
; Global Variables:  None.
;
; Input:             None.
; Output:            None.
;
; Error Handling:    None.
;
; Algorithms:        None.
; Data Structures:   None.
;
; Registers Changed: R0, R1
; Stack Depth:       0 words
;
; Known Bugs:        None.
; Limitation:        None.
;
; Revision History:  11/20/25   Li-Yu Chu       initial revision

InitGPT0:

GPT0AConfig:                                    ;configure timer 0 as a one-shot down counter

        MOV32   R1, GPT0_BASE_ADDR              ;get GPT0 base address
        STREG   GPT_CFG_32x1, R1, GPT_CFG_OFF   ;setup one 32-bit timer
        STREG   GPT0A_MODE, R1, GPT_TAMR_OFF    ;set timer A mode
                                                                                                
        STREG   CLK_PER_US, R1, GPT_TAILR_OFF   ;set 32-bit timer count

        STREG   GPT_CTL_TAEN, R1, GPT_CTL_OFF   ;enable timer A

        BX      LR                              ;done so return

        .end
