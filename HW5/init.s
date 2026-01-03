;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                                                            ;
;                                    HW5                                     ;
;               Servomotor Interface Initialization Functions                ;
;                                                                            ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; This file contains the initialization of the HW5 servomotor interface system.
; This file include the following functions:
;       InitPower          - Turn on the power to the peripherals.
;       InitClocks         - Turn on the clock to the peripherals.
;       InitGPIO           - Initialize the I/O pins for servomotor and LCD
;       InitGPT0           - Initialize general purpose timer 0
;       InitADC            - initializes analog-to-digital converter
;
; Revision History:
;       12/10/25     Li-Yu Chu             initial revision


; local include files
        .include  "CPUreg.inc"
        .include  "GPIOreg.inc"
        .include  "IOCreg.inc"
        .include  "GPTreg.inc"
        .include  "ADCreg.inc"
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
        .def    InitGPIO                ;setup the I/O pins for servomotor
        .def    InitGPT0                ;initialize the general purpose timer
        .def    InitADC                 ;initialize analog-to-digital converter

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


; InitGPIO
;
; Description:       Initialize the I/O pins for the servomotor MG996R and LCD
;                    control signals.
;
; Operation:         Setup GPIO pin 3 to output PWM signals for servomotor,
;                    and GPIO pin 23 to AUXIO 26 for analog feedback input
;                    from servomotor. Also, setup DIO[18..20] to be outputs
;                    for LCD control signals and bi-directional buffer input T/R.
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
; Limitation:        It only supports LCD with only 2 rows (1 Enable pin only)
;
; Revision History:  12/10/25   Li-Yu Chu      initial revision

InitGPIO:                               
                                        ;configure outputs for servomotor inputs
        MOV32   R1, IOC_BASE_ADDR       ;get base for I/O control registers
        MOV32   R0, IOCFG_EVENT2_DOUT   ;setup for DIO3 for port event 2 (GPT1A)
        STR     R0, [R1, #IOCFG3]       ;write configuration for PWM output to servomotor

        MOV32   R0, IOCFG_AUXIO_DIN     ;setup for DIO23 for AUXIO26
        STR     R0, [R1, #IOCFG23]      ;write configuration for feedback input from servomotor

                                        ;LCD control signal initialization
        MOV32   R0, IOCFG_GEN_DOUT      ;setup for general outputs
        STR     R0, [R1, #IOCFG18]      ;write configuration for Enable
        STR     R0, [R1, #IOCFG19]      ;write configuration for R/W
        STR     R0, [R1, #IOCFG20]      ;write configuration for RS

                                        ;enable outputs for stepper motor
        MOV32   R1, GPIO_BASE_ADDR      ;get base for GPIO registers

        STREG   LCD_CONTROL, R1, GPIO_DCLR31_0_OFF ;clear output for buffer input
        STREG   LCD_CONTROL, R1, GPIO_DOE31_0_OFF  ;enable GPIO output for LCD input
                                        

        BX      LR                      ;done so return


; InitGPT0
;
; Description:       This function initializes GPT0, a one-shot timer for LCD 
;                    initialization and main loop delay.
;
; Operation:         The appropriate values are written to the timer control
;                    registers.  Also, the timer count registers are reset. 
;                    Finally, GPT0 is enabled.
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
; Revision History:  12/10/25   Li-Yu Chu       initial revision

InitGPT0:

GPT0AConfig:                                    ;configure timer 0 as a one-shot down counter

        MOV32   R1, GPT0_BASE_ADDR              ;get GPT0 base address
        STREG   GPT_CFG_32x1, R1, GPT_CFG_OFF   ;setup one 32-bit timer
        STREG   GPT0A_MODE, R1, GPT_TAMR_OFF    ;set timer A mode   
        STREG   CLK_PER_US, R1, GPT_TAILR_OFF   ;set 32-bit timer count
        STREG   GPT_CTL_TAEN, R1, GPT_CTL_OFF   ;enable timer A   

        BX      LR                              ;done so return

; InitADC
;
; Description:       This function initializes the analog-to-digital converter 
;                    subsystem in the AUX domain.
;
; Operation:         First, ADC clock is enabled via the AUX System Interface. After
;                    ADC clock enable is acknowledged, it configures ADC input to 
;                    AUXIO26 with analog input mode. Then, ADC is configured to 
;                    normal asynchronous node and both ADC and its reference module 
;                    are enabled. Finally, flush the ADC FIFO and enable the ADC
;                    interface for manual triggerring.      
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
; Revision History:  12/11/25   Li-Yu Chu       initial revision
;                    12/12/25   Li-Yu Chu       update comments


InitADC:

InitADCClock:
                                                        ;initialize ADC Clock
        MOV32   R1, AUX_SYSIF_BASE_ADDR                 ;get base address of AUX System Interface
        STREG   ADCCLKCTL_EN, R1, ADCCLKCTL_OFF         ;enable ADC clock

WaitADCClocksLoaded:

        LDR     R0, [R1, #ADCCLKCTL_OFF]                ;load ADC clock status
        TEQ     R0, #ADCCLKCTL_ACK_EN                   ;check if clock is enabled by ACK
        BNE     WaitADCClocksLoaded                     ;if not enabled, wait until enabled
        ;BEQ    InitAUXIO                               ;if enabled, start initialize I/O

InitAUXIO:
                                                        ;initialize AUX domain I/O 26
        MOV32   R1, AUX_ADI4_BASE_ADDR                  ;get base address of AUX Analog Digital Interface
        STREG   MUX_3_AUXIO26, R1, MUX_3_OFF            ;connect ADC input to AUXIO26 by MUX3

                                                        ;26 = 8 * 3 + 2
        MOV32   R1, AUX_AIODIO3_BASE_ADDR               ;get base address of Analog Digital I/O 3
        STREG   AUXIO26_INPUT_MODE, R1, IOMODE_OFF      ;switch IO2 to input mode for AUXIO26
        STREG   ADC_GPIODIE_DIS, R1, GPIODIE_OFF        ;disable digital input buffer for AUXIO26

InitADC0:
                                                        ;initialize ADC
        MOV32   R1, AUX_ADI4_BASE_ADDR                  ;get base address of AUX Analog Digital Interface         
        STREG   ADC_ASYNC_NOR_EN, R1, ADC0_OFF          ;set ADC mode and enable ADC to normal operation
        STREG   ADCREF_EN, R1, ADCREF0_OFF              ;enable ADC reference module
        
InitADCFIFO:
                                                        ;initialize ADC interface
                                                        ;already reset to manual trigger
        MOV32   R1, AUX_ANAIF_BASE_ADDR                 ;get base address of AUX Analog Interface 
        STREG   ADC_CFG_FLUSH, R1, ADCCTL_OFF           ;flush ADC FIFO
        MOV     R0, #ADC_CFG_EN                         
        NOP
        NOP                                             ;wait for two system clock before enabling
        STR     R0, [R1, #ADCCTL_OFF]                   ;enable ADC interface

        BX      LR                                      ;done so return
        
        .end
