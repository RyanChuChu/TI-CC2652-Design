;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                                                            ;
;                                    HW3                                     ;
;                                LCD Interface                               ;
;                                                                            ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Description:      This program demonstrates the initialization and display 
;                   of LCD interface. The main function calls the initialization 
;                   functions of launchpad regarding peripheral power, clock,
;                   GPIO and GPT0. Then, it calls the initialization of LCD.
;                   Finally, the test loop calls DisplayChar to display a 
;                   character or Display to display a string start from a
;                   designated position.
;
;
; Input:            DIO[8..15] - Data/Command read from LCD (Busy Flag on DIO15)
;                   
; Output:           DIO[8..15] - Data/Command written to LCD
;                   DIO18      - LCD Enable (E)
;                   DIO19      - LCD Read/Write (RW)
;                   DIO20      - LCD Register Select (RS)
;                   
;
; User Interface:   The LCD interface HDM24216H-2 with 2 lines and 24 characters
;                   on each row. The valid position for cursor is row = 0-1, 
;                   column = 0-23. Users make a test table with each case specified
;                   (for Display, first byte of content must be the length of 
;                    the string), and the content will be displayed sequentially.
;
; Error Handling:   If a specified position is illegal, it will display a "Invalid"
;                   in at row = 0, column = 0.
;
; Algorithms:       The main routine initializes the system-level peripherals
;                   (power, clock, GPIO, GPT0) and then performs LCD setup by
;                   stepping through the LCDInitTab table. The test loop reads
;                   entries from TestLCDTab one by one: each entry indicates
;                   whether to call DisplayChar or Display, along with the
;                   requested row, column, and data. The loop updates the test
;                   pointer, processes the operation, restores the pointer when
;                   Display is used, wait 300ms delay to differentiate test cases,
;                   and repeats until reaching EndTestLCDTab.
;                   
; Data Structures:  None.
;
; Revision History:
;     11/20/25  Li-Yu Chu      initial revision
;     11/24/25  Li-Yu Chu      update test table & loop 


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

        .sect ".const"

        ;initialization table
        .align  4
LCDInitTab:
                ;Command            Delay Count
        .word   00111000b,   20000 * CLK_PER_US
        .word   00111000b,    4100 * CLK_PER_US
        .word   00111000b,     100 * CLK_PER_US
        .word   00111000b,       NO_DELAY_COUNT         ;function set
        .word   00001000b,       NO_DELAY_COUNT         ;display off
        .word   00000001b,       NO_DELAY_COUNT         ;clear display
        .word   00000110b,       NO_DELAY_COUNT         ;entry mode set
        .word   00001111b,       NO_DELAY_COUNT         ;display/cursor on  

EndLCDInitTab:

        ;test case table
TestLCDTab:
                ;String(1)/Char(0)
                ;Operation     Row      Column          Content
        .byte           0,     -1,         -1,          'A'
        .byte           1,      0,         22,          11, 'H', 'e', 'l', 'l', 'o', 0x20, 'w', 'o', 'r', 'l', 'd'
        .byte           0,      1,         23,          'B'
        .byte           1,     -1,         -1,          2, 'h', 'i'
        .byte           1,      1,         23,          4, 'R', 'y', 'a', 'n'
        .byte           0,      0,         90,          'c'
        .byte           1,      0,         10,          3, 'L', 'C', 'D'
        .byte           1,     -1,         -1,          4, 't', 'e', 's', 't'          

EndTestLCDTab:

        .data
        
        ;initialization functions
        .ref InitPower                  ;turn on power to everything
        .ref InitClocks                 ;turn on clocks to everything
        .ref InitGPIO                   ;setup the I/O pins for LCD control signals
        .ref InitGPT0                   ;initialize the general purpose timer
        
        ;LCD main functions
        .ref InitLCD                    ;initialization of LCD
        .ref DisplayChar                ;display a character
        .ref Display                    ;display a string

        ;Invalid string
        .def InvalidString              ;display "Invalid" for illegal start position

        ; the stack (must be double-word aligned)
        .align  8
TopOfStack:     .space      TOTAL_STACK_SIZE

        ; variables
        .align  4
TestAddress:    .space      BYTES_PER_WORD      ;local variable for storing test table pointer

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; code
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
   
        .text
        .global resetISR                        ;reset interrupt service routine

resetISR:

main:
        MOVA    R0, TopOfStack                  ;initialize the stack pointers
        MSR     MSP, R0                         ;Main Stack Pointer
        SUB     R0, R0, #HANDLER_STACK_SIZE
        MSR     PSP, R0                         ;Process Stack Pointer

        BL      InitPower                       ;turn on power to everything
        BL      InitClocks                      ;turn on clocks to everything
        BL      InitGPIO                        ;setup the I/O pins for LCD control signals
        BL      InitGPT0                        ;initialize the general purpose timer

        MOVA    R1, LCDInitTab                  ;get start address of LCD initialization table
        MOVA    R2, EndLCDInitTab               ;get end address of LCD initialization table
        BL      InitLCD                         ;start initialization

        MOVA    R5, TestLCDTab                  ;get start address of LCD test table
        MOVA    R1, TestAddress                 ;initialize local variable for storing test table pointer
        STR     R5, [R1]                        
        MOVA    R7, EndTestLCDTab               ;get end address of LCD initialization table
        B       TestLCD                         ;start testing

TestLCD:

        LDRB    R3, [R5], #1                    ;load operation code
        LDRSB   R0, [R5], #1                    ;load row with sign extension
        LDRSB   R1, [R5], #1                    ;load column with sign extension
        LDRB    R2, [R5], #1                    ;load char for DisplayChar
                                                ;or string length for Display 

        TEQ     R3, #DISPLAY_MODE               ;check operation code
        BEQ     CallDisplay                     ;R3 = 1
        ;BNE    CallDisplayChar                 ;R3 = 0

CallDisplayChar:
        
        BL      DisplayChar                     ;display character
        B       MainPrevTimeout                 ;done display character

CallDisplay:

        MOV     R4, R2                          ;store length to R4
        MOV     R2, R5                          ;move string address to R2 for input argument
        ADD     R5, R4                          ;compute theoretical test table pointer after Display
        MOVA    R6, TestAddress                 ;store to local variable
        STR     R5, [R6]   
        BL      Display                         ;display string

        MOVA    R6, TestAddress                 ;restore next operation's pointer to R5
        LDR     R5, [R6]

        ;B      MainPrevTimeout                 ;done display string

MainPrevTimeout:
                                                ;wait for previous timeout
        MOV32   R1, GPT0_BASE_ADDR              ;get base address of GPT0
        LDR     R0, [R1, #GPT_RIS_OFF]          ;get timer 0 raw interrupt status
        TEQ     R0, #GPT0_TIMEOUT               ;check if timeout interrupt generated
        BNE     MainPrevTimeout                 ;if not, wait until timeout
        ;BEQ    SetupMainDelay                  ;if yes, check the type of new delay

SetupMainDelay:
                                                ;wait a new delay between test cases
        STREG   GPT_IRQ_TATO, R1, GPT_ICLR_OFF  ;clear previous timeout
        STREG   MAIN_DELAY, R1, GPT_TAILR_OFF   ;setup 300ms timer
        STREG   GPT_CTL_TAEN, R1, GPT_CTL_OFF   ;enable timer 0
        ;B      MainWaitDelay

MainWaitDelay:

        LDR     R0, [R1, #GPT_RIS_OFF]          ;get timer 0 raw interrupt status
        TEQ     R0, #GPT0_TIMEOUT               ;check if timeout interrupt generated
        BNE     MainWaitDelay                   ;if not, wait until timeout
        ;BEQ    DoneCall                        ;if yes, check if there's still test cases

DoneCall:

        TEQ     R5, R7                          ;check if all the operations are done           
        BNE     TestLCD                         ;if not, execute next operation

        BEQ     DoneCall                        ;if yes, stay in forever loop

InvalidString:

        .byte   7, 'I', 'n', 'v', 'a', 'l', 'i', 'd'

EndInvalidString:

        .end   