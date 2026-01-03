;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                                                            ;
;                                    HW3                                     ;
;                       LCD Interface specific functions                     ;
;                                                                            ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; This file contains the specific functions of the HW3 LCD interface system.
; This file include the following functions:
;       InitLCD            - Initialize LCD to be ready for display
;       DisplayChar        - Display a character on specific position
;       Display            - Display a string on specific position
;
; Revision History:
;    11/20/25     Li-Yu Chu             initial revision
;    11/22/25     Li-Yu Chu             update DisplayChar
;    11/24/25     Li-Yu Chu             update Display


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
        ;LCD functions
        .def InitLCD                            ;initialization of LCD
        .def DisplayChar                        ;display a character
        .def Display                            ;display a string

        ;helper functions
        .ref CheckPos                           ;check validity of start position
                                                ;if invalid, set CallInvalid to TRUE
                                                ;and Display InvalidString
        .ref WaitLCDReady                       ;read busy flag until turning to 0
        .ref WriteLCD                           ;write a command or data to LCD

        ;Invalid String
        .ref InvalidString                      ;display "Invalid" for illegal start position

        ;cursor tracking variables
        .def CursorRow                          ;current row where cursor is
        .def CursorCol                          ;current column where cursor is
        .def CallInvalid                        ;Invalid status of start position

        .align  4
CursorRow:      .space      BYTES_PER_WORD      ;current row where cursor is
CursorCol:      .space      BYTES_PER_WORD      ;current column where cursor is
CallInvalid:    .space      BYTES_PER_WORD      ;Invalid status of start position

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; code
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        .text

; InitLCD
;
; Description:       Initializes the LCD module (HDM24216H-2) using the 8-bit parallel
;                    interface. This routine setups and performs the manufacturer-required
;                    post-power-up delays, and sends the function Set and Display
;                    commands to LCD loaded from initialization table. No busy-flag polling 
;                    is used; timing relies solely on specified delays. After initialization 
;                    completes, the cursor tracking variables (CursorRow, CursorCol) and
;                    CallInvalid are reset.
;
; Operation:         For each entry, the function performs the following operations:
;                    1. Load initialization command to R3 and delay count to R4 via R1.
;                    2. Wait for previous GPT0 timeout.
;                    3. If delay count is specified (≠ NO_DELAY_COUNT), program GPT0 for the delay.
;                       Otherwise call WaitLCDReady to read busy flag until turning to 0.
;                    4. Set RS to 0, align data bits, and write command to LCD using WriteLCD
;                    The operations is performed until all the entries are written (R1 == R2)
;                    Finally, initialize all global variables.
;
; Arguments:         R1 - pointer at initialization table for each command and delay count 
;                    R2 - end of initialization table
; Return Value:      None.
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
; Output:            LCD is placed into fully ready initial state, with cursor blinking at (0, 0).
;
; Error Handling:    None.
;
; Algorithms:        Sequential command execution with GPT0-based timing.
; Data Structures:   Initialization table with command and delay count (defined externally)
;
; Registers Changed: R0, R1, R3, R4, R5, R6
; Stack Depth:       1 word
;
; Known Bugs:        None.
; Limitation:        None.
;
; Revision History:  11/20/25   Li-Yu Chu      initial revision

InitLCD:

        PUSH    {LR}                            ;store link register
        MOV32   R5, GPT0_BASE_ADDR              ;get base address of GPT0
    
LoadWaitDelay:

        LDM     R1!, {R3, R4}                   ;load command and delay count, and update pointer
                                                ;R3 = command, R4 = delay count
        
InitWaitPrevTimeout:
                                                ;wait for previous timeout
        LDR     R6, [R5, #GPT_RIS_OFF]          ;get timer 0 raw interrupt status
        TEQ     R6, #GPT0_TIMEOUT               ;check if timeout interrupt generated
        BNE     InitWaitPrevTimeout             ;if not, wait until timeout
        ;BEQ    CheckInitDelay                  ;if yes, check the type of new delay

CheckInitDelay:

        TEQ     R4, #NO_DELAY_COUNT             ;check if delay is not specified
        BEQ     WaitLCD                         ;if not, wait LCD to be ready
        ;BNE     SetupInitDelay                 ;if yes, setup a new timer

SetupInitDelay:

        STREG   GPT_IRQ_TATO, R5, GPT_ICLR_OFF  ;clear previous timeout interrupt
        STR     R4, [R5, #GPT_TAILR_OFF]        ;setup specified delay timer
        STREG   GPT_CTL_TAEN, R5, GPT_CTL_OFF   ;enable timer 0
        ;B      WaitInitDelay

WaitInitDelay:
                                                ;wait for specific delay time
        LDR     R6, [R5, #GPT_RIS_OFF]          ;get timer 0 raw interrupt status
        TEQ     R6, #GPT0_TIMEOUT               ;check if timeout interrupt generated
        BNE     WaitInitDelay                   ;if not, wait until timeout
        BEQ     WriteCommand                    ;if yes, write command to LCD

WaitLCD:

        BL      WaitLCDReady                    ;no specified delay, so wait for LCD is ready
        ;B      WriteCommand                    ;after waiting, start write command

WriteCommand:

        MOV32   R4, INSTR_RS                    ;for writing command, RS = 0, passed in through R4
        LSL     R3, R3, #DATA_TO_DIO            ;align command to data pins DIO[8..15]
        BL      WriteLCD                        ;write command to LCD
        ;B      DoneWriteLCD

DoneWriteLCD:

        CMP     R1, R2                          ;check if it's end of initialization
        BNE     LoadWaitDelay                   ;if not, keep loading next command and delay
        ;BEQ    DoneInitLCD                     ;if yes, prepare to return to main loop

DoneInitLCD:
                                                ;initialize cursor tracking variables
        MOVA    R1, CursorRow                   ;initialize current row of cursor = 0
        MOV     R0, #ROW_LOW
        STR     R0, [R1]     

        MOVA    R1, CursorCol                   ;initialize current column of cursor = 0
        MOV     R0, #COL_LOW
        STR     R0, [R1]     

        MOVA    R1, CallInvalid                 ;initialize Invalid status = False
        MOV     R0, #FALSE
        STR     R0, [R1]     

        POP     {LR}                            ;restore link register
        BX      LR                              ;done so return

     
; DisplayChar
;
; Description:       Display a single character at a specified or current cursor
;                    position. If called with DISPLAYCHAR_MODE (from main loop),
;                    the function first validates the start position using CheckPos.
;                    If invalid, it triggers the display of InvalidString. Otherwise,
;                    the cursor may be moved (SetCursor) unless CURRENT_POS is used.
;                    The character in R2 is then written to LCD as data, and
;                    cursor tracking variables (CursorRow, CursorCol) are updated.    
;
; Operation:         DISPLAYCHAR_MODE (called directly): the function loads cursor
;                    tracking variables to R8 and R9, and validates the position via 
;                    CheckPos. If CallInvalid is TRUE, then branch to DisplayInvalid
;                    and call Display to output "Invalid" starting at (0, 0).
;                    DISPLAY_MODE (called from Display): position validity is checked,
;                    no need to check it again.
;                    Then, if CURRENT_POS is requested, just write data directly.
;                    Otherwise, compute DD RAM address and send SetCursor command.
;                    After setup, write data character through WriteLCD. Notice that both
;                    SetCursor and WriteLCD needs to call WaitLCDReady to read busy flag 
;                    until turning to 0 before performed. Finally, increment cursor column
;                    and store updated tracking values.
;
; Arguments:         R0 - proposed row (or -1 for CURRENT_POS)
;                    R1 - proposed column (or -1 for CURRENT_POS)
;                    R2 - character to display (byte)
;                    R3 - operation mode (DISPLAYCHAR_MODE or Display internal call counter)
; Return Value:      None.
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
; Output:            One character written to LCD at computed position.
;
; Error Handling:    Displays InvalidString at (0, 0) if starting position is invalid.
;
; Algorithms:        Position validation, cursor addressing, and auto-increment.
; Data Structures:   None.
;
; Registers Changed: R2, R8, R9
; Stack Depth:       7 words
;
; Known Bugs:        None.
; Limitation:        None.
;
; Revision History:  11/22/25   Li-Yu Chu      initial revision

DisplayChar:

        PUSH    {R0 - R1, R3 - R6, LR}          ;store registers
        
        TEQ     R3, #DISPLAYCHAR_MODE           ;check if DisplayChar is called by main loop
        BEQ     CheckStartPos                   ;if yes, need to check validity of start position
                                                ;if no, it's already checked at Display
        B       CheckSetCursor                  ;check if cursor need to be moved

CheckStartPos:

                                                ;load cursor tracking variables
        MOVA    R5, CursorRow                   ;load current row of cursor to R8
        LDR     R8, [R5]     

        MOVA    R5, CursorCol                   ;low current column of cursor to R9
        LDR     R9, [R5]

        BL      CheckPos                        ;check the validity of the starting position
                                                ;if invalid, display "Invalid" at row = 0, col = 0

        MOVA    R6, CallInvalid                 ;get invalid status
        LDR     R6, [R6]
        TEQ     R6, #TRUE                       ;check if invalid status is TRUE
        BEQ     DisplayInvalid                  ;if yes, prepare to Display "Invalid"
        ;BNE    CheckSetCursor                  ;if not, DisplayChar as usual

CheckSetCursor:

        AND     R3, R0, R1                      ;R3 = -1 iff R0 = -1 and R1 = -1
        TEQ     R3, #CURRENT_POS                ;check if it is current position
        BEQ     WriteData                       ;if yes, can directly write data to LCD
        ;BNE    SetCursor                       ;if not, need to set cursor to designated position

SetCursor:
                                                ;wait for previous LCD command
        BL      WaitLCDReady                    ;read busy flag until turning to 0 
                                                ;compute cursor address
        LSL     R3, R0, #ROW_TO_ADDR            ;move row from DB0 to DB6
        ORR     R3, R1                          ;column is on DB[5:0]
        ORR     R3, #SET_DD_RAM                 ;for set DD RAM, DB7 = 1
        LSL     R3, R3, #DATA_TO_DIO            ;align data to data pins DIO[8..15]
        MOV32   R4, INSTR_RS                     ;for writing data, set RS = 1

        BL      WriteLCD                        ;write command in R3 to LCD

WriteData:
                                                ;wait for previous LCD command
        BL      WaitLCDReady                    ;read busy flag until turning to 0 
        
        MOV32   R4, DATA_RS                     ;for writing data, set RS = 1
        LSL     R3, R2, #DATA_TO_DIO            ;align data to data pins DIO[8..15]
        BL      WriteLCD                        ;write data in R3 to LCD

DoneWriteData:

        ADD     R9, #1                          ;cursor move to next column, so
                                                ;increment cursor tracking variable
                                                ;update cursor tracking variable
        MOVA    R1, CursorRow                   ;update row
        STR     R8, [R1]     

        MOVA    R1, CursorCol                   ;update column
        STR     R9, [R1]     

        POP     {R0 - R1, R3 - R6, LR}          ;restore registers

        BX      LR

DisplayInvalid:

        MOV     R2, R5                          ;move address of invalid string in R5 to R2
                                                ;now R0 = R1 = 0 is set in CheckPos
                                                ;also length of "Invalid" in R4
        BL      Display                         ;Display "Invalid"

        POP     {R0 - R1, R3 - R6, LR}          ;restore registers

        BX      LR                              ;done and return


; Display
;
; Description:       Display a full string starting at a specified row and column.
;                    The caller provides starting position, pointer to string, and
;                    its length. The function validates the requested position via
;                    CheckPos; if invalid, the InvalidString is displayed instead.
;                    Otherwise, Display loops through each character, calling
;                    DisplayChar repeatedly with CURRENT_POS to rely on auto cursor
;                    tracking. Wrap-around to the next row occurs when end-of-row
;                    is reached. 
;
; Operation:         First, the function initializes loop counter R3 and string pointer
;                    R5, and load cursor tracking variables R8, R9. Then, it validates
;                    starting position using CheckPos. If the starting position is invalid,
;                    change the content to "Invalid" at (0, 0) in CheckPos and set CallInvalid
;                    to TRUE.
;                    Then for each loop, it performs
;                    the following operation:
;                    1. Load one byte from string to R2
;                    2. Call DisplayChar to display a character
;                    3. Check completeness (counter == length). If not, increment counter.
;                    4. Change expression of R0 and R1 to current position
;                    5. Apply wrap-around if at end column.
;                    Finally, reset CallInvalid to False and return
;
; Arguments:         R0 - row
;                    R1 - column
;                    R2 - start pointer of the string
;                    R4 - length of the string
;
; Return Value:      None.
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
; Output:            Entire string rendered to LCD.
;
; Error Handling:    Displays InvalidString at (0, 0) if starting position is invalid.
;
; Algorithms:        Sequential character output with auto-increment and wrapping.
; Data Structures:   None.
;
; Registers Changed: R0, R1, R2, R3, R4, R5, R8, R9
; Stack Depth:       1 word
;
; Known Bugs:        None.
; Limitation:        The length of the string must be specified, and it must match the exact
;                    length of the input string. 
;
; Revision History:  11/24/25   Li-Yu Chu      initial revision

Display:

        PUSH    {LR}                            ;store link register for return to main loop
        MOV32   R3, RESET_COUNTER               ;reset counter for looping through the string
        MOV     R5, R2                          ;let R5 be the pointer looping through the string
                                                ;since each char will be passed into DisplayChar
                                                ;through R2
                                                
                                                ;load cursor tracking variables
        MOVA    R2, CursorRow                   ;load current row of cursor to R8
        LDR     R8, [R2]     

        MOVA    R2, CursorCol                   ;low current column of cursor to R9
        LDR     R9, [R2]

        BL      CheckPos                        ;check the validity of the starting position
                                                ;if invalid, display "Invalid" at row = 0, col = 0

DisplayLoop:

        LDRB    R2, [R5], #1                    ;load char to R2, and update pointer to next char
        BL      DisplayChar                     ;write char to LCD

CheckCounter:

        TEQ     R3, R4                          ;check if it's end of the string
        BEQ     DoneDisplay                     ;if yes, display is finished
                                                ;if not, handle the next input position

        ADD      R3, #1                         ;update counter

        MOV32    R0, CURRENT_POS                ;change expression of position to current cursor position 
        MOV32    R1, CURRENT_POS

        TEQ      R9, #COL_HIGH                  ;check if it's end of the row
        BNE      DisplayLoop                    ;if not, return to display next character
        ;BEQ     WrapAround                     ;if yes, need to wrap around to next/prev row

WrapAround:

        MOV     R9, #COL_LOW                    ;also update cursor tracking variables to head of the row
        ADD     R8, #1                          ;move to next row
        AND     R8, #ROW_MASK                   ;mask bit 0 for row

        MOV     R0, R8                          ;move updated row and column to next DisplayChar's 
        MOV     R1, R9                          ;input position argument

        B       DisplayLoop                     ;return to display next character

DoneDisplay:

        MOVA    R1, CallInvalid                 ;reset Invalid status to False
        MOV     R0, #FALSE
        STR     R0, [R1]     

        POP     {LR}                            ;restore link register for return to main loop
        BX      LR

        .end