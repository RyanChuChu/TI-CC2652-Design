;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                                                            ;
;                                    HW4                                     ;
;              Stepper Motor Interface Initialization Functions              ;
;                                                                            ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; This file contains the initialization of the HW4 stepper motor interface system.
; This file include the following functions:
;       InitPower          - Turn on the power to the peripherals.
;       InitClocks         - Turn on the clock to the peripherals.
;       MoveVecTable       - moves the interrupt vector table from
;                            its current location to SRAM at the 
;                            location VecTable.
;       InitGPIO           - Initialize the I/O pins for stepper motor and LCD
;       InstallGPT1Handler - Install the event handler for the GPT1 
;                            timer interrupt
;       InitGPTs           - Initialize GPT 0-3 and sets up the timer
;                            according to their roles, respectively.
;
; Revision History:
;       11/30/25     Li-Yu Chu             initial revision
;       12/01/25     Li-Yu Chu             update GPIO and GPT
;       12/03/25     Li-Yu Chu             update comments


; local include files
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
        .def    InitPower               ;turn on power to everything
        .def    InitClocks              ;turn on clocks to everything
        .def    MoveVecTable            ;move the vector table to RAM
        .def    InitGPIO                ;setup the I/O pins for stepper motor
        .def    InstallGPT1Handler      ;install the main routine event handler
        .def    InitGPTs                ;initialize the general purpose timer

        ;interrupt vector table
        .global VecTable                ;the interrupt vector table in SRAM

        ;stepper motor event handler
        .ref    GPT1EventHandler           ;main routine event handler

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
; Revision History:  11/30/25   Li-Yu Chu      initial revision

InitClocks:
        MOV32   R1, PRCM_BASE_ADDR                 ;get base for power registers
        STREG   GPIOCLK_EN, R1, GPIOCLKGR_OFF      ;turn on GPIO clocks
        STREG   GPTCLK_EN, R1, GPTCLKGR_OFF        ;turn on all timer clocks
        STREG   GPTCLKDIV_1, R1, GPTCLKDIV_OFF     ;timers get 48MHz system clock (by default)

        STREG   CLKLOADCTL_LD, R1, CLKLOADCTL_OFF  ;load clock settings

WaitClocksLoaded:                                  ;wait for clocks to be loaded
        LDR     R0, [R1, #CLKLOADCTL_OFF]          ;get clock status
        ANDS    R0, #CLKLOADCTL_STAT               ;check if clocks are on (Z = 1)
        BEQ     WaitClocksLoaded                   ;if not, keep checking
        ;BNE    DoneClockSetup                     ;otherwise done

DoneClockSetup:                                    ;done setting up clock
        BX      LR


; MoveVecTable
;
; Description:       This function moves the interrupt vector table from its
;                    current location to SRAM at the location VecTable.
;
; Operation:         The function reads the current location of the vector
;                    table from the Vector Table Offset Register and copies
;                    the words from that location to VecTable.  It then
;                    updates the Vector Table Offset Register with the new
;                    address of the vector table (VecTable).
;
; Arguments:         None.
; Return Values:     None.
;
; Local Variables:   None.
; Shared Variables:  None.
; Global Variables:  VecTable - the interrupt vector table in SRAM
;
; Input:             VTOR.
; Output:            VTOR.
;
; Error Handling:    None.
;
; Registers Changed: flags, R0, R1, R2, R3
; Stack Depth:       1 word
;
; Algorithms:        None.
; Data Structures:   None.
;
; Known Bugs:        None.
; Limitation:        None.
;
; Revision History:  11/07/25   Li-Yu Chu      initial revision


MoveVecTable:

        PUSH    {R4}                    ;store necessary changed registers
        ;B      MoveVecTableInit        ;start doing the copy


MoveVecTableInit:                       ;setup to move the vector table
        MOV32   R1, SCS_BASE_ADDR       ;get base for CPU SCS registers
        LDR     R0, [R1, #VTOR_OFF]     ;get current vector table address

        MOVA    R2, VecTable            ;load address of new location
        MOV     R3, #VEC_TABLE_SIZE     ;get the number of words to copy
        ;B      MoveVecCopyLoop         ;now loop copying the table


MoveVecCopyLoop:                        ;loop copying the vector table
        LDR     R4, [R0], #BYTES_PER_WORD   ;get value from original table
        STR     R4, [R2], #BYTES_PER_WORD   ;copy it to new table

        SUBS    R3, #1                  ;update copy count

        BNE     MoveVecCopyLoop         ;if not done, keep copying
        ;B      MoveVecCopyDone         ;otherwise done copying


MoveVecCopyDone:                        ;done copying data, change VTOR
        MOVA    R2, VecTable            ;load address of new vector table
        STR     R2, [R1, #VTOR_OFF]     ;and store it in VTOR
        ;B      MoveVecTableDone        ;and all done


MoveVecTableDone:                       ;done moving the vector table
        POP     {R4}                    ;restore registers and return
        BX      LR


; InitGPIO
;
; Description:       Initialize the I/O pins for the stepper motor and LCD
;                    control signals.
;
; Operation:         Setup GPIO pins 22, 21, 5, 4 to output PWM signals for
;                    stepper motor inputs through a L293D driver. Also, setup
;                    DIO[18..20] to be outputs for LCD control signals and
;                    bi-directional buffer input T/R.
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
; Limitation:        It only supports the stepper motor with 4-wire interface
;                    and LCD with only 2 rows (1 Enable pin only)
;
; Revision History:  12/01/25   Li-Yu Chu      initial revision

InitGPIO:                               
                                        ;configure outputs for stepper motor (driver) inputs
        MOV32   R1, IOC_BASE_ADDR       ;get base for I/O control registers
        MOV32   R0, IOCFG_EVENT7_DOUT   ;setup for DIO4 for port event 7 (GPT3B)
        STR     R0, [R1, #IOCFG4]       ;write configuration for stepper motor input B_bar

        MOV32   R0, IOCFG_EVENT6_DOUT   ;setup for DIO5 for port event 6 (GPT3A)
        STR     R0, [R1, #IOCFG5]       ;write configuration for stepper motor input B

        MOV32   R0, IOCFG_EVENT5_DOUT   ;setup for DIO21 for port event 5 (GPT2B)
        STR     R0, [R1, #IOCFG21]      ;write configuration for stepper motor input A_bar

        MOV32   R0, IOCFG_EVENT4_DOUT   ;setup for DIO22 for port event 4 (GPT2A)
        STR     R0, [R1, #IOCFG22]      ;write configuration for stepper motor input A

                                        ;LCD control signal initialization
        MOV32   R0, IOCFG_GEN_DOUT      ;setup for general outputs
        STR     R0, [R1, #IOCFG18]      ;write configuration for Enable
        STR     R0, [R1, #IOCFG19]      ;write configuration for R/W
        STR     R0, [R1, #IOCFG20]      ;write configuration for RS

                                        ;enable outputs for stepper motor
        MOV32   R1, GPIO_BASE_ADDR      ;get base for GPIO registers

        STREG   LCD_CONTROL, R1, GPIO_DCLR31_0_OFF ;clear output for buffer input
        STREG   LCD_CONTROL, R1, GPIO_DOE31_0_OFF  ;enable GPIO output for  LCD input
                                        

        BX      LR                      ;done so return
        
; InstallGPT1Handler
;
; Description:       Install the event handler for the GPT1 timer interrupts.
;
; Operation:         Writes the address of the GPT1 event handler to the
;                    appropriate interrupt vector.
;
; Arguments:         None.
; Return Value:      None.
;
; Local Variables:   None.
; Shared Variables:  None.
; Global Variables:  GPT1EventHandler - main routine event handler for stepper motor
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
; Revision History:  11/30/25   Li-Yu Chu      initial revision

InstallGPT1Handler:

        MOVA    R0, GPT1EventHandler    ;get GPT1 event handler address
        MOV32   R1, SCS_BASE_ADDR       ;get address of SCS registers
        LDR     R1, [R1, #VTOR_OFF]     ;get table relocation address
        STR     R0, [R1, #(4 * GPT1A_EX_NUM)]   ;store vector address

        BX      LR                      ;all done, return


; InitGPTs
;
; Description:       This function initializes GPT0 and 1. Their functions are 
;                    described below:
;                    GPT0 - one-shot timer for LCD initialization and main loop delay
;                    GPT1 - 50Hz periodic timer that generates interrupt for every 
;                           20ms, which is for main routine event handler.
;
; Operation:         The appropriate values are written to the timer control
;                    registers.  Also, the timer count registers are reset. 
;                    Finally, interrupts are enabled for GPT1.
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
; Revision History:  12/01/25   Li-Yu Chu       initial revision

InitGPTs:

GPT0AConfig:                                    ;configure timer 0 as a one-shot down counter

        MOV32   R1, GPT0_BASE_ADDR              ;get GPT0 base address
        STREG   GPT_CFG_32x1, R1, GPT_CFG_OFF   ;setup one 32-bit timer
        STREG   GPT0A_MODE, R1, GPT_TAMR_OFF    ;set timer A mode   
        STREG   CLK_PER_US, R1, GPT_TAILR_OFF   ;set 32-bit timer count
        STREG   GPT_CTL_TAEN, R1, GPT_CTL_OFF   ;enable timer A   

GPT1AConfig:
        
        MOV32   R1, GPT1_BASE_ADDR              ;get GPT1 base address
        STREG   GPT_CFG_32x1, R1, GPT_CFG_OFF   ;setup one 32-bit timer
        STREG   GPT_IRQ_TATO, R1, GPT_IMR_OFF   ;enable timer A timeout interrupts
        STREG   GPT1A_MODE, R1, GPT_TAMR_OFF    ;set timer A mode

        STREG   MAIN_ROUTINE_ILR, R1, GPT_TAILR_OFF   ;set 32-bit timer count
        STREG   GPT_CTL_TAEN, R1, GPT_CTL_OFF   ;enable GPT1A

        BX      LR                              ;done so return

        .end
