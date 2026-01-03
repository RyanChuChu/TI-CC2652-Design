;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                                                            ;
;                                    HW3                                     ;
;                        LCD Interface Helper Function                       ;
;                         Appendix: wait delay version                       ;
;                                                                            ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; This file contains the helper functions of the HW3 LCD interface system.
; This file include the following functions:
;       InitLCDDataOutput  - Initialize the I/O pins for LCD data.
;       CheckPos           - Validate the requested LCD cursor position.
;       WaitLCDReady       - Wait specific delay depending on caller context
;       WriteLCD           - Write either a command or a data byte to LCD
;
; Revision History:
;    11/20/25     Li-Yu Chu             inital revision
;    11/24/25     Li-Yu Chu             update cursor tracking


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
        ;helper fucntions
        .def CheckPos                           ;check validity of start position
                                                ;if invalid, set CallInvalid to TRUE
                                                ;and Display InvalidString
        .def WaitLCDReady                       ;setup specified delay 
        .def WriteLCD                           ;write a command or data to LCD

        ;Invalid String
        .ref InvalidString                      ;display "Invalid" for illegal start position

        ;variables
        .ref CursorRow                          ;current row where cursor is
        .ref CursorCol                          ;current column where cursor is
        .ref CallInvalid                        ;Invalid status of start position

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; code
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        .text

; InitLCDDataOutput
;
; Description:       Initialize the I/O pins for LCD data.
;
; Operation:         Setup DIO[8..15] to be outputs for bi-directional buffer 
;                    inputs. The control signals are cleared in advance.
;                    Then, setup all DIOs to general 2mA output. Finally, set
;                    data in R3 to GPIO output pins and enable all data and 
;                    control signals to output.
;
; Arguments:         R3 - output data/command to LCD
; Return Value:      None.
;
; Local Variables:   None.
; Shared Variables:  None.
; Global Variables:  None.
;
; Input:             None.
; Output:            DIO[8..15] - LCD data pins (through bi-directional buffer)
;                    DIO[18..20] - LCD control signals, all clear to 0 for write mode
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
; Revision History:  11/20/25   Li-Yu Chu      initial revision

InitLCDDataOutput:                    
                                        ;clear outputs before setting configuration
        MOV32   R1, GPIO_BASE_ADDR      ;get base for GPIO registers
        STREG   LCD_CONTROL, R1, GPIO_DCLR31_0_OFF ;clear control signals to LCD

                                        ;configure outputs for LCD and buffer inputs
        MOV32   R1, IOC_BASE_ADDR       ;get base for I/O control registers
        MOV32   R0, IOCFG_GEN_DOUT      ;setup for general outputs
        STR     R0, [R1, #IOCFG8]       ;write configuration for DB0
        STR     R0, [R1, #IOCFG9]       ;write configuration for DB1
        STR     R0, [R1, #IOCFG10]      ;write configuration for DB2
        STR     R0, [R1, #IOCFG11]      ;write configuration for DB3
        STR     R0, [R1, #IOCFG12]      ;write configuration for DB4
        STR     R0, [R1, #IOCFG13]      ;write configuration for DB5
        STR     R0, [R1, #IOCFG14]      ;write configuration for DB6
        STR     R0, [R1, #IOCFG15]      ;write configuration for DB7

                                        ;set outputs for LCD data pins
        MOV32   R1, GPIO_BASE_ADDR      ;get base for GPIO registers
        STR     R3, [R1, #GPIO_DOUT31_0_OFF]     ;set output data bits to data in R3
        STREG   LCD_ALL, R1, GPIO_DOE31_0_OFF    ;enable GPIO output

        BX      LR                      ;done so return


; CheckPos
;
; Description:       This function validate the requested LCD cursor position.
;                    If the position is (-1, -1), check the current cursor
;                    location stored in R8 (row) and R9 (col). Otherwise,
;                    check whether the requested (row, col) is valid.
;                    If invalid, mark CallInvalid = TRUE and prepare LCD
;                    to display the InvalidString at (0, 0).   
;
; Operation:         First, the function copies input row/col from R0/R1 into
;                    private temporaries (R6/R7). For current position, we load
;                    temporaries from cursor tracking variables R8/R9. Then, 
;                    we validate boundaries (0 ≤ row < 2, 0 ≤ col < 24). 
;                    If success, update cursor tracking registers R8 and R9. 
;                    If failure, set CallInvalid, load InvalidString and its length, 
;                    and reset cursor to (0, 0).                    
;
; Arguments:         R0 - proposed row
;                    R1 - proposed column
; Return Value:      R8 - validated row for cursor tracking
;                    R9 - validated column for cursor tracking
;                    If the start position is invalid, then the following value are also returned:
;                    R0 - current row set to 0
;                    R1 - current column set to 0
;                    R4 - length of InvalidString
;                    R5 - pointer to InvalidString
;
; Local Variables:   None.
; Shared Variables:  None.
; Global Variables:  CursorRow          - row cursor tracking variable
;                                         (initialized in InitLCD, updated when a new position is validated
;                                          or set to invalid in CheckPos, and wrapping around during Display)
;                    CursorRow          - column cursor tracking variable
;                                         (initialized in InitLCD, updated when a new position is validated
;                                          or set to invalid in CheckPos, after DisplayChar, and wrapping around 
;                                          during Display)
;                    CallInvalid        - invalid status for a specified position
;                                         (initialized in InitLCD as False, set to True if invalid position
;                                          and reset to false every time after string is fully displayed)
;
; Input:             None.
; Output:            None.
;
; Error Handling:    Detects illegal cursor positions and marks invalid.
;
; Algorithms:        Boundary check and special handling for current position. 
; Data Structures:   None.
;
; Registers Changed: R0, R1, R4, R5, R8, R9
; Stack Depth:       3 words
;
; Known Bugs:        None.
; Limitation:        The boundary is specified for HDM24216H-2 LCD interface (2 row x 24 columns)
;
; Revision History:  11/24/25   Li-Yu Chu      initial revision

CheckPos:  

        PUSH    {R3, R6, R7}                    ;store registers
        
                                                ;R6 and R7 serve as temporary variables for
                                                ;position checking since we don't want to
                                                ;modify R0, R1 and R8, R9 except special cases
        MOV     R6, R0                          ;R6 = new row
        MOV     R7, R1                          ;R7 = new column
        AND     R3, R0, R1                      ;R3 = -1 iff R0 = -1 and R1 = -1
        TEQ     R3, #CURRENT_POS                ;check if it is current position
        BNE     CheckValidRow                   ;if not, check the specified position
        ;BEQ    GetCurPos                       ;if yes, load current position

GetCurPos:

        MOV     R6, R8                          ;current row is stored in R8
        MOV     R7, R9                          ;current column is stored in R9
        ;B      CheckValidRow                   ;start checking validity of position

CheckValidRow:
                                                ;check if 0 <= row < 2, or invalid row
        CMP     R6, #ROW_LOW
        BLT     SetInvalid    
        CMP     R6, #ROW_HIGH
        BGE     SetInvalid
        ;B      CheckValidCol    

CheckValidCol:
                                                ;check if 0 <= col < 24, or invalid col
        CMP     R7, #COL_LOW
        BLT     SetInvalid    
        CMP     R7, #COL_HIGH
        BGE     SetInvalid
        
        B       UpdateCurPos                    ;if all passed, update current position
                                                ;of cursor to new value

SetInvalid:

        MOVA    R1, CallInvalid                 ;set invalid status to TRUE
        MOV     R0, #TRUE
        STR     R0, [R1]

        MOVA    R5, InvalidString               ;get address of invalid string
        LDRB    R4, [R5], #1                    ;load string length to R4
        MOV32   R0, ROW_LOW                     ;set cursor position to (0, 0)
        MOV32   R1, COL_LOW 

        MOV32   R6, ROW_LOW                     ;temporary variables need to be synchronized also
        MOV32   R7, COL_LOW

        ;B      UpdateCurPos

UpdateCurPos:
                                                ;update the final outcome of cursor position 
                                                ;back to cursor tracking variables
        MOV     R8, R6                          ;move row
        MOV     R9, R7                          ;move column
        ;B      DoneCheckPos

DoneCheckPos:

        POP     {R3, R6, R7}                    ;restore registers
        BX      LR                              ;done so return


; WaitLCDReady
;
; Description:       Delay routine used by LCD interface. Waits either
;                    a 2 ms instruction-initialization delay or a 40 µs
;                    display-write delay depending on caller context.
;
; Operation:         Save registers, poll GPT0 timeout flag, clear the
;                    previous interrupt, load the appropriate delay
;                    (INSTR_DELAY for InitLCD, DISPLAY_DELAY for
;                    DisplayChar), start one-shot timer, restore registers, 
;                    and return.
;
; Arguments:         R4 = delay selector (NO_DELAY_COUNT → initialization)
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
; Registers Changed: None.
; Stack Depth:       4 words
;
; Known Bugs:        None.
; Limitation:        The delay is specified according to timing requirements 
;                    of HDM24216H-2 LCD interface. 
;
; Revision History:  11/20/25   Li-Yu Chu      initial revision

WaitLCDReady:                            
                                                
        PUSH    {R0 - R1, R5 - R6}              ;store registers
        MOV32   R5, GPT0_BASE_ADDR              ;get base address for GPT0

WaitPrevTimeout:
                                                ;wait for previous timeout
        LDR     R6, [R5, #GPT_RIS_OFF]          ;get timer 0 raw interrupt status
        TEQ     R6, #GPT0_TIMEOUT               ;check if timeout interrupt generated
        BNE     WaitPrevTimeout                 ;if not, wait until timeout
        ;BEQ    SetupWaitDelay                  ;if yes, start setup new timer

SetupWaitDelay:
                                                ;setup a new one-shot timer                                    
        STREG   GPT_IRQ_TATO, R5, GPT_ICLR_OFF  ;clear previous timeout interrupt
        TEQ     R4, #NO_DELAY_COUNT             ;check if waiting is called from initialization
        BNE     DisplayDelay                    ;if not, it's called from DisplayChar
        ;BEQ    InitializationDelay             ;if yes, it's called from InitLCD

InitializationDelay:

        STREG   INSTR_DELAY, R5, GPT_TAILR_OFF  ;for InitLCD, setup a 2ms delay
        B       StartDelay

DisplayDelay:
        
        STREG   DISPLAY_DELAY, R5, GPT_TAILR_OFF    ;for DisplayChar, setup a 40us delay
        ;B      StartDelay

StartDelay:

        STREG   GPT_CTL_TAEN, R5, GPT_CTL_OFF   ;enable timer 0
        ;B      WaitDelay

; WaitDelay:
;                                               ;wait for specific delay time
;         LDR     R6, [R5, #GPT_RIS_OFF]        ;get timer 0 raw interrupt status
;         TEQ     R6, #GPT0_TIMEOUT             ;check if timeout interrupt generated
;         BNE     WaitDelay                     ;if not, wait until timeout
;         ;BEQ    DoneWaitLCDReady              ;if yes, waiting ends and prepare to return
;                                               ;since we will check previous timeout before
;                                               ;writing to LCD, we don't need to wait here

DoneWaitLCDReady:

        POP     {R0 - R1, R5 - R6}              ;restore registers
        BX      LR                              ;done so return


; WriteLCD
;
; Description:       This function writes either a command or a data byte to 
;                    the LCD. It handles GPIO pin configuration, control signals,
;                    LCD timing (Enable pulse), and required hardware delay
;                    using GPT0 one-shot timer.
;
; Operation:         First, this function configures GPIO outputs via
;                    InitLCDDataOutput. Then, it waits for prior timer timeout.
;                    It selects RS based on write type (R4 = DATA_RS or INSTR_RS).
;                    After clearing old GPT0 flags and setting up new timer for 
;                    LCD Enable pulse width, it asserts LCD Enable, starts GPT0 and
;                    wait for timeout. Finally, it deasserts Enable and return.
;
; Arguments:         R3 - byte to write to LCD (already loaded in InitLCDDataOutput)
;                         already aligned to DIO[8..15]
;                    R4 - write type (DATA_RS → data, INSTR_RS → command)
; Return Value:      None.
;
; Local Variables:   None.
; Shared Variables:  None.
; Global Variables:  None.
;
; Input:             None.
; Output:            DIO[8..15] - LCD data pins (through bi-directional buffer)
;                    DIO[18..20] - LCD control signals, all clear to 0 for write mode
;
; Error Handling:    None.
;
; Algorithms:        The enable pulse is determined by GPT0 (hardware timed)
; Data Structures:   None.
;
; Registers Changed: None.
; Stack Depth:       5 words
;
; Known Bugs:        None.
; Limitation:        It only supports 8-bit LCD interface, and GPT0 should be configured
;                    without clearing the interrupt GPT0:RIS
;
; Revision History:  11/20/25   Li-Yu Chu      initial revision

WriteLCD:                            
                                                
        PUSH    {R0, R1, R5, R6, LR}            ;store registers
        MOV32   R5, GPT0_BASE_ADDR              ;get base address for GPT0
        BL      InitLCDDataOutput               ;setup GPIO as outputs and store R3 to output data
                                                ;R1 = base address of GPIO

WriteWaitPrevTimeout:
                                                ;wait for previous timeout
        LDR     R6, [R5, #GPT_RIS_OFF]          ;get timer 0 raw interrupt status
        TEQ     R6, #GPT0_TIMEOUT               ;check if timeout interrupt generated
        BNE     WriteWaitPrevTimeout            ;if not, wait until timeout
        ;BEQ    SetupWriteData                  ;if yes, start setup new timer and LCD control signals

SetupWriteData:
                                                ;setup control signals
        ;STREG  (1 << LCD_RW), R1, GPIO_DCLR31_0_OFF    ;Clear R/W = 0 (write mode)
                                                        ;already done in InitLCDDataOutput
        TEQ     R4, #DATA_RS                    ;check if it's writing data
        BNE     SetupInstrRS                    ;if not, RS = 0 for writing command
        ;BEQ    SetupDataRS                     ;if yes, RS = 0 for writing data

SetupDataRS:

        STREG   (1 << LCD_RS), R1, GPIO_DSET31_0_OFF    ;for writing data, set RS = 1
        B       SetupWriteTimer

SetupInstrRS:

        STREG   (1 << LCD_RS), R1, GPIO_DCLR31_0_OFF    ;for writing command, clear RS = 0
        ;B      SetupWriteTimer

SetupWriteTimer:
                                                ;setup a new one-shot timer
        STREG   GPT_IRQ_TATO, R5, GPT_ICLR_OFF  ;clear previous timeout interrupt
        STREG   ENABLE, R5, GPT_TAILR_OFF       ;Set Enable to high with 250ns

StartWriteLCD:
                                                ;notice that tAS = 40ns, timing requirement is met
        STREG   (1 << LCD_ENABLE), R1, GPIO_DSET31_0_OFF    ;set Enable = 1
        STREG   GPT_CTL_TAEN, R5, GPT_CTL_OFF   ;enable timer 0
        ;B      WaitWriteLCD

WaitWriteLCD:
                                                ;wait for specific delay time
        LDR     R6, [R5, #GPT_RIS_OFF]          ;get timer 0 raw interrupt status
        TEQ     R6, #GPT0_TIMEOUT               ;check if timeout interrupt generated
        BNE     WaitWriteLCD                    ;if not, wait until timeout
        ;BEQ    ResetWriteEnable                ;if yes, reset enable to 0  

ResetWriteEnable:

        STREG   (1 << LCD_ENABLE), R1, GPIO_DCLR31_0_OFF    ;clear Enable = 0

DoneWriteLCD:

        POP     {R0, R1, R5, R6, LR}            ;restore registers
        BX      LR                              ;done so return

       .end