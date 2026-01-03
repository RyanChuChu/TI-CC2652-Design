
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                                                            ;
;                                    HW2                                     ;
;                       Keypad Interface Event Handler                       ;
;                          Appendix: 1-row version                           ;
;                                                                            ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; This file contains the event handler of timer interrupts for every 
; millisecond. In every interrupt, the event handler scans one row and 
; debounces a pressed key if any. If a key is debounced enough loops, it will 
; be enqueued into a queue.
;
; Revision History:
;    11/15/25     Li-Yu Chu             inital revision
;    11/17/25     Li-Yu Chu             tackle timing issue



; local include files
        .include "init.inc"
        .include "constant.inc"
        .include "macro.inc"

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; data
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

        .data
        ;global variables across files
        .global CurRow                  ;current scanning row
        .global PrevPosPattern          ;stored position for current debouncing key
        .global DebounceCntr            ;counter for debouncing
        .global GPT0EventHandler        ;keypad event handler

        ;enqueue function in main.s
        .global Enqueue                 ;store debounced function into a queue

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; code
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; GPT0EventHandler
;
; Description:       This procedure is the event handler for the timer
;                    interrupt. It scans one row and debounces any pressed
;                    key into a queue, utilizing an event-driven method. It
;                    supports auto-repeat for longer time pressing.
;
; Operation:         By setting the GPIO output to a 2:4 decoder, the event handler
;                    scans each row one by one. If detecting any 0 in GPIO input, 
;                    we start debouncing the pressed key value and enqueue it when 
;                    the debouncing loop threshold is met. The queue is a circular 
;                    buffer, so if the queue is full, the write pointer will 
;                    return to the head pointer of the queue and overwrite the
;                    keys that are written earliest. After all the instructions
;                    finished, clear the GPT0 timer interrupt.
;
; Arguments:         None.
; Return Value:      None.
;
; Local Variables:   None.
; Shared Variables:  None.
; Global Variables:  CurRow             - current scanning row (initialized in main loop, updated during
;                                         every scanning)
;                    PrevPosPattern     - stored position for current debouncing key 
;                                         (initialized in main loop, updated when a new key is debounced,
;                                          and reset when debouncing completed)
;                    DebounceCntr       - counter for debouncing 
;                                         (initialized in main loop, incremented when debouncing a specific key,
;                                          and reset when debouncing completed or a new key is debounced)
;
; Input:             DIO12, DIO13, DIO14, DIO15 from keypad 
; Output:            DIO8, DIO9 to decoder
;
; Error Handling:    None.
;
; Algorithms:        When we scan a row, DIO[9..8] will output 00, 01, 10, 11 to decoder sequentially, and the 
;                    decoder will output 1110, 1101, 1011, 0111 to keypad row[3..0], respectively. The position 
;                    of zero indicates the current row we are scanning, and if a key on this row is pressed,
;                    we start debouncing. DIO[15..12] will receive a zero, and the position corresponds to column
;                    3 to 0 respectively. Since we know the row and column of the pressed key after debouncing,
;                    we can store this unique information to PrevPosPattern to determine if we are debouncing
;                    the same key or not. If we are debouncing a new key, we update PrevPosPattern and reset
;                    counter DebounceCntr to 0; if we are debouncing an old key, we increment DebounceCntr by 1
;                    for each debouncing and check if the debouncing loop threshold is met. If they matches,
;                    we reset both PrevPosPattern and DebounceCntr for auto-repeat and call enqueue function
;                    to store the debounced key into the queue. Finally, no matter we scan any 0 or not, we 
;                    clear DIO[9..8] and the GPT0 timer interrupt. This method is an event-driven method. 
; Data Structures:   None.
;
; Registers Changed: None.
; Stack Depth:       5 words
;
; Known Bugs:        None.
; Limitation:        This event handler is only suitable for 4x4 keypad, and also ensures the correct key is 
;                    debounced only when one key is pressed at a time. Auto repeat is also supported. If two
;                    keys are pressed at the same time, no keys are debounced since we only detect outputs 
;                    for 1 column (1 zero), or the position with the last two bits being 0 are debounced
;                    since no matching patterns in debouncing will cause the current position to remain from
;                    scanning. 
;
; Revision History:  
;        11/15/25   Li-Yu Chu      initial revision
;        11/17/25   Li-Yu Chu      tackle timing issue


GPT0EventHandler:
        PUSH    {R0, R1, R2, R3, R4}            ;save the registers

Scan:                                           ;scan one row at a time                        
        MOV32   R2, GPIO_BASE_ADDR              ;get base for GPIO registers
        MOVA    R4, CurRow                      
        LDR     R3, [R4]                        ;load current scanning row
                                                
        LSL     R1, R3, #ROW_DECODER_DIFF       ;align row bits with I/O output
        NOP
        NOP
        NOP
        STR     R1, [R2, #GPIO_DSET31_0_OFF]    ;set output for decoder
        NOP
        NOP
        NOP
        NOP
        NOP
        NOP
        NOP
        NOP
        NOP
        NOP
        NOP
        NOP
        NOP
        NOP
        NOP
        LDR     R1, [R2, #GPIO_DIN31_0_OFF]     ;load input data from GPIO input registers
        NOP
        NOP
        NOP

                                                ;update CurRow for next scanning
        ADD     R0, R3, #TRANS_ROW              ;update from row n to n+1
        AND     R0, #0x0000000F                 ;mask irrelevant bits for position 
        STR     R0, [R4]                        ;update CurRow

        TEQ     R1, #HIGH_INPUT                 ;compare input data with 1111
        BNE     Debounce                        ;if any 0 detected (any key pressed), start debounce
        ;B      DoneScan                        ;if all 1, prepare to clear interrupt
        
DoneScan:                                       ;if no 0 is detected in any row (no key is pressed)
                                                ;In ClearInterrupt, we will pop R2 to get the value of
                                                ;DebounceCntr and check if the enqueue function is called
                                                ;and link register needed to be restored. So we set R2
                                                ;to 0 if no debounce occurred to ensure a deterministic
                                                ;value of R2 and LR will not be incorrectly restored.
        PUSH    {R2}                            ;store R2 for POP in ClearInterrupt
        B       ClearInterrupt

Debounce:                                       ;debounce the pressed key
                                                
        TEQ     R1, #COL0_PRESSED               ;check if column 0 is pressed (DIO[15:12] = 1110)
        IT      EQ                              ;if same pattern, then add column to current position
        ADDEQ   R3, #COL0                       ;current position column = 0

        TEQ     R1, #COL1_PRESSED               ;check if column 1 is pressed (DIO[15..12] = 1101)
        IT      EQ                              ;if same pattern, then add column to current position
        ADDEQ   R3, #COL1                       ;current position column = 1

        TEQ     R1, #COL2_PRESSED               ;check if column 2 is pressed (DIO[15..12] = 1011)
        IT      EQ                              ;if same pattern, then add column to current position
        ADDEQ   R3, #COL2                       ;current position column = 2

        TEQ     R1, #COL3_PRESSED               ;check if column 3 is pressed (DIO[15..12] = 0111)
        IT      EQ                              ;if same pattern, then add column to current position
        ADDEQ   R3, #COL3                       ;current position column = 3


                                                ;check if the current debouncing key is a new key
        MOVA    R1, PrevPosPattern              ;get address of stored debouncing key
        LDR     R0, [R1]                        ;load position of stored debouncing key
        MOVA    R4, DebounceCntr                ;get address of debounce counter
        LDR     R2, [R4]                        ;load debounce counter
        TEQ     R3, R0                          ;check if the current debouncing key is an old key
        ITT     NE                              ;if the current debouncing key is a new key (not old)
        STRNE   R3, [R1]                        ;then update the stored position
        MOVNE   R2, #RESET_CNTR                 ;then reset the debounce counter
        
        ADD     R2, #1                          ;increment counter by 1

        MOVA    R1, PrevPosPattern              ;get address of stored debouncing key
        MOV32   R0, RESET_POSITION
        TEQ     R2, #DEBOUNCE_LOOP_THRESHOLD    ;check if the key is debounced 40 loops
        IT      EQ                              ;if finish debouncing, then reset
        STREQ   R0, [R1]                        ;reset the stored position to row = 0, column = 0

        MOVA    R4, DebounceCntr                ;get address of debounce counter
        MOV32   R0, RESET_CNTR
        TEQ     R2, #DEBOUNCE_LOOP_THRESHOLD    ;check if the key is debounced 40 loops
        ITE     EQ                              ;if finish debouncing
        STREQ   R0, [R4]                        ;then reset the debounce counter to 0
        STRNE   R2, [R4]                        ;if not finished, store incremented debounce counter
                                                
                                                
        TEQ     R2, #DEBOUNCE_LOOP_THRESHOLD    ;check if the key is debounced 40 loops
        BEQ     CallEnqueue                     ;if finish debouncing, prepare to call Enqueue
        BNE     DoneDebounce                    ;if not, finish all instructions for 1 debounce

CallEnqueue:

        PUSH    {R2, LR}                        ;store R2 for ClearInterrupt to check if LR
                                                ;needed to be restored, and store LR for
                                                ;ClearInterrupt to return back to main loop
                                                ;since LR is modified when calling Enqueue
        BL      Enqueue                         ;enqueue the debounced key
        B       ClearInterrupt                  ;finish enqueue

DoneDebounce:

        PUSH    {R2}                            ;store counter for ClearInterrupt to check
        ;B      ClearInterrupt

ClearInterrupt:                                 ;done with interrupt
        POP     {R2}                            ;restore DebounceCntr to check
        TEQ     R2, #DEBOUNCE_LOOP_THRESHOLD    ;check if the key is debounced 30 loops
        IT      EQ                              ;if finish debouncing (Enqueue is called)
        POPEQ   {LR}                            ;restore link register to return to main loop
        
        MOV32   R2, GPIO_BASE_ADDR              ;get base for GPIO registers
        STREG   ((1 << DECODERB_TO_BIT) | (1 << DECODERA_TO_BIT)),  R2, GPIO_DCLR31_0_OFF       ;reset GPIO output

        MOV32   R1, GPT0_BASE_ADDR              ;get base address
        STREG   GPT_IRQ_TATO, R1, GPT_ICLR_OFF  ;clear timer A timeout interrupt

        POP     {R0, R1, R2, R3, R4}            ;restore registers

        BX      LR                              ;return from interrupt

        .end
