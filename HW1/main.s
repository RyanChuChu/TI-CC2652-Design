;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                                                            ;
;                                    HW1                                     ;
;                        Processor Familiarization                           ;
;                                                                            ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Description:      This project is a demonstration program. When the left 
;                   switch (connected to DIO13) is pressed, the red LED 
;                   (connected to DIO6) is turned on; when the right switch
;                   (connected to DIO14) is pressed, the green LED (connected)
;                   (connected to DIO7) is turned on. Otherwise, the LEDs
;                   remain dark.
;
; Input:            The left switch (connected to DIO13) and the right switch
;                   (connected to DIO14)
; Output:           The red LED (connected to DIO6) is turned on when the left 
;                   switch is turned on; the green LED (connected to DIO7) is 
;                   turned on when the right switch is turned on
;
; User Interface:   None, the LEDs are directly controlled by switches
; Error Handling:   None.
;
; Algorithms:       None.
; Data Structures:  None.
;
; Revision History:
;     10/22/25  Li-Yu Chu      initial revision
;     10/24/25  Li-Yu Chu      update comments

; local include files
    .include "constant.inc"
    .include "macro.inc"


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; data
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        .data

        ; the stack (must be double-word aligned)
        .align  8
TopOfStack:     .bes    TOTAL_STACK_SIZE

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; code
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    
    .text
    .global resetISR

resetISR:

main:
    MOVA    R0, TopOfStack               ;initialize the stack pointers
    MSR     MSP, R0                      ;Main Stack Pointer
    SUB     R0, R0, #HANDLER_STACK_SIZE
    MSR     PSP, R0                      ;Process Stack Pointer


    BL      InitPower                    ;turn on power to everything
    BL      InitGPIOClocks               ;turn on clocks to GPIO
    BL      InitGPIO                     ;setup the I/O (only output)

    B Forever                            ;main logic for LED control

Forever:
    MOV32   R2,  GPIO_BASE_ADDR                     ;get base for GPIO registers
    LDR     R1,  [R2, #GPIO_DIN31_0_OFF]            ;load input data from GPIO input registers
    LSR     R1,  R1,  #LED_SWITCH_DIFF              ;right shift to align input bit locations with output bit locations
    MVN     R1,  R1                                 ;bitwise invert to turn active low signal to active high
    AND     R4,  R1,  #(1 << REDLED_IO_BIT)         ;use R4 to record status of left swtich
    AND     R5,  R1,  #(1 << GREENLED_IO_BIT)       ;use R5 to record status of right swtich

    CMP     R4,  #(1 << REDLED_IO_BIT)              ;check if left switch is presssed (Z = 1)
    ITE     EQ                                      ;if pressed, then set, else clear (red LED)
    BLEQ    SetRedLED                               ;if pressed, turn on red LED
    BLNE    ClearRedLED                             ;if not pressed, turn off red LED

    CMP     R5,  #(1 << GREENLED_IO_BIT)            ;check if right switch is presssed (Z = 1)
    ITE     EQ                                      ;if pressed, then set, else clear  (green LED)
    BLEQ    SetGreenLED                             ;if pressed, turn on green LED
    BLNE    ClearGreenLED                           ;if not pressed, turn off green LED

    B Forever                                       ;repeat this procedure to control the behavior of LEDs

SetRedLED:
    STREG   (1 << REDLED_IO_BIT), R2, GPIO_DSET31_0_OFF     ;turn on red LED
    BX      LR                                              ;finish turning on and return

ClearRedLED:
    STREG   (1 << REDLED_IO_BIT), R2, GPIO_DCLR31_0_OFF     ;turn off red LED
    BX      LR                                              ;finish turning off and return

SetGreenLED:
    STREG   (1 << GREENLED_IO_BIT), R2, GPIO_DSET31_0_OFF   ;turn on green LED
    BX      LR                                              ;finish turning on and return

ClearGreenLED:
    STREG   (1 << GREENLED_IO_BIT), R2, GPIO_DCLR31_0_OFF   ;turn off green LED
    BX      LR                                              ;finish turning off and return


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
; Revision History:  10/22/25   Li-Yu Chu      initial revision

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


; InitGPIOClocks
;
; Description:       Turn on the clock to the GPIO. 
;
; Operation:         Setup PRCM registers to turn on clock to the GPIO.
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
; Revision History:  10/22/25   Li-Yu Chu      initial revision

InitGPIOClocks:
        MOV32   R1, PRCM_BASE_ADDR                 ;get base for power registers
        STREG   GPIOCLK_EN, R1, GPIOCLKGR_OFF      ;turn on GPIO clocks
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
; Description:       Initialize the I/O pins for the LEDs.
;
; Operation:         Setup GPIO pins 6 and 7 to be 4 mA outputs for the LEDs.
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
; Revision History:  10/22/25   Li-Yu Chu      initial revision

InitGPIO:                               
                                        ;configure red and green LED outputs
        MOV32   R1, IOC_BASE_ADDR       ;get base for I/O control registers
        MOV32   R0, IOCFG_GEN_DOUT_4MA  ;setup for general 4 mA outputs
        STR     R0, [R1, #IOCFG6]       ;write configuration for red LED I/O
        STR     R0, [R1, #IOCFG7]       ;write configuration for green LED I/O

                                        ;configure left and right switch inputs
        MOV32   R0, IOCFG_GEN_DIN_PU    ;setup for general input
        STR     R0, [R1, #IOCFG13]      ;write configuration for left switch
        STR     R0, [R1, #IOCFG14]      ;write configuration for right switch

                                        ;enable outputs for LEDs
        MOV32   R1, GPIO_BASE_ADDR      ;get base for GPIO registers
        STREG   ((1 << REDLED_IO_BIT) | (1 << GREENLED_IO_BIT)), R1, GPIO_DOE31_0_OFF ;set output enable for LEDs

        BX      LR                      ;done so return