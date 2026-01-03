;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                                                            ;
;                                    HW2                                     ;
;                  Keypad Interface Initialization Functions                 ;
;                                                                            ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; This file contains the initialization of the HW2 keypad interface system.
; This file include the following functions:
;       InitPower          - Turn on the power to the peripherals.
;       InitClocks         - Turn on the clock to the peripherals.
;       MoveVecTable       - moves the interrupt vector table from
;                            its current location to SRAM at the 
;                            location VecTable.
;       MoveVecTable       - moves the interrupt vector table from
;                            its current location to SRAM at the 
;                            location VecTable.
;       InitGPIO           - Initialize the I/O pins for the keypad.
;       InstallGPT0Handler - Install the event handler for the GPT0 
;                            timer interrupt
;       InitGPT0           - Initialize GPT0 and sets up the timer to
;                            generate interrupts every millisecond.
;
; Revision History:
;       11/12/25     Li-Yu Chu             initial revision (split files)

; local include file
        .include "init.inc"
        .include "constant.inc"
        .include "macro.inc"

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; data
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        .data
        
        ;initialization global variables
        .global InitPower               ;turn on power to everything
        .global InitClocks              ;turn on clocks to everything
        .global MoveVecTable            ;move the vector table to RAM
        .global InitGPIO                ;setup the I/O pins for keypad
        .global InstallGPT0Handler      ;install the event handler
        .global InitGPT0                ;initialize the general purpose timer
        .global VecTable                ;the interrupt vector table in SRAM

        ;keypad global variables
        .global GPT0EventHandler        ;keypad event handler

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; code
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

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
; Description:       Initialize the I/O pins for the keypad.
;
; Operation:         Setup GPIO pins 8 and 9 to be outputs for the decoder 
;                    (keypad) inputs, and pins 12, 13, 14, 15 to be outputs
;                    for the keypad inputs. 
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
; Limitation:        This setup is only for the schematic that a decoder is 
;                    connecting to a 4x4 keypad.
;
; Revision History:  11/07/25   Li-Yu Chu      initial revision

InitGPIO:                               
                                        ;configure outputs for decoder (keypad) inputs
        MOV32   R1, IOC_BASE_ADDR       ;get base for I/O control registers
        MOV32   R0, IOCFG_GEN_DOUT      ;setup for general outputs
        STR     R0, [R1, #IOCFG8]       ;write configuration for decoder input A
        STR     R0, [R1, #IOCFG9]       ;write configuration for decoder input B

                                        ;configure keypad inputs
        MOV32   R0, IOCFG_GEN_DIN_PU    ;setup for general input
        STR     R0, [R1, #IOCFG12]      ;write configuration for column 0
        STR     R0, [R1, #IOCFG13]      ;write configuration for column 1
        STR     R0, [R1, #IOCFG14]      ;write configuration for column 2
        STR     R0, [R1, #IOCFG15]      ;write configuration for column 3

                                        ;enable outputs for LEDs
        MOV32   R1, GPIO_BASE_ADDR      ;get base for GPIO registers
        STREG   ((1 << DECODERA_TO_BIT) | (1 << DECODERB_TO_BIT)), R1, GPIO_DOE31_0_OFF ;set output enable for decoders

        BX      LR                      ;done so return
        
; InstallGPT0Handler
;
; Description:       Install the event handler for the GPT0 timer interrupt.
;
; Operation:         Writes the address of the timer event handler to the
;                    appropriate interrupt vector.
;
; Arguments:         None.
; Return Value:      None.
;
; Local Variables:   None.
; Shared Variables:  None.
; Global Variables:  GPT0EventHandler - keypad event handler
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
; Revision History:  11/07/25   Li-Yu Chu      initial revision

InstallGPT0Handler:

        MOVA    R0, GPT0EventHandler    ;get handler address
        MOV32   R1, SCS_BASE_ADDR       ;get address of SCS registers
        LDR     R1, [R1, #VTOR_OFF]     ;get table relocation address
        STR     R0, [R1, #(4 * GPT0A_EX_NUM)]   ;store vector address

        BX      LR                      ;all done, return


; InitGPT0
;
; Description:       This function initializes GPT0. It sets up the timer to
;                    generate interrupts every millisecond.
;
; Operation:         The appropriate values are written to the timer control
;                    registers.  Also, the timer count registers are reset. 
;                    Finally, interrupts are enabled.
;
; Arguments:         None.
; Return Value:      None.
;
; Local Variables:   None.
; Shared Variables:  None.
; Global Variables:  
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
; Revision History:  11/07/25   Li-Yu Chu       initial revision

InitGPT0:

GPT0AConfig:                                    ;configure timer 0A as a down counter generating
                                                ;interrupts every millisecond

        MOV32   R1, GPT0_BASE_ADDR              ;get GPT0 base address
        STREG   GPT_CFG_32x1, R1, GPT_CFG_OFF   ;setup one 32-bit timer
        STREG   GPT_IRQ_TATO, R1, GPT_IMR_OFF   ;enable timer A timeout interrupts
        STREG   GPT0A_MODE, R1, GPT_TAMR_OFF    ;set timer A mode
                                                
                                                
        STREG   CLK_PER_MS, R1, GPT_TAILR_OFF   ;set 32-bit timer count

        STREG   GPT_CTL_TAEN, R1, GPT_CTL_OFF   ;enable timer A

        BX      LR                              ;done so return

        .end
