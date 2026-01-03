;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                                                            ;
;                                    HW2                                     ;
;                              Keypad Interface                              ;
;                                                                            ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Description:      This program demonstrates the usage of keypad and how 
;                   event handler deal with the pressed keys through an event-
;                   driven software. The timer generate interrupts every
;                   millisecond, and the event handler scans and debounces if 
;                   any key is pressed and enqueue it. It handles for one key
;                   pressed at a time. This file include the following function:
;                       Enqueue         - Store the debounced key into a queue
;                   
;
; Input:            Input signals from keypad through GPIO (DIO[15..12])
;                   
; Output:           Output signal for scanning the rows of the keypad through GPIO  
;                   (DIO[9..8]) and a 2:4 decoder (74LS139)
;
; User Interface:   The keypad which user can press one key at once.
; Error Handling:   None.
;
; Algorithms:       This program harnesses an event-driven debounce software for keypads.
;                   After initialization of power, clocks, GPIO, event handler moving interrupt
;                   vector tables, every millisecond GPT0 will generate a timeout interrupt, 
;                   which passes through NVIC and find event handler from new vector interrupt 
;                   table. Then the event handler scans each row and debounces if a key is pressed.
;                   If debounced enough loops, the key will be stored by enqueue function. Then
;                   the interrupt is cleared and PC returns to an empty forever loop to wait for
;                   the next interrupt.
;                   
; Data Structures:  A queue for storing the debounced keys.
;
; Revision History:
;     11/07/25  Li-Yu Chu      initial revision
;     11/08/25  Li-Yu Chu      update comments
;     11/10/25  Li-Yu Chu      update header
;     11/12/25  Li-Yu Chu      update header, enqueue header


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
        
        ;initialization global variables
        .global InitPower               ;turn on power to everything
        .global InitClocks              ;turn on clocks to everything
        .global MoveVecTable            ;move the vector table to RAM
        .global InitGPIO                ;setup the I/O pins for keypad
        .global InstallGPT0Handler      ;install the event handler
        .global InitGPT0                ;initialize the general purpose timer
        .global VecTable                ;the interrupt vector table in SRAM

        .global QueueHead
        .global QueueTail
        .global QueueWrite

        ;keypad global variables
        .global CurRow                  ;current scanning row
        .global PrevPosPattern          ;stored position for current debouncing key
        .global DebounceCntr            ;counter for debouncing
        .global GPT0EventHandler        ;keypad event handler

        ;enqueue function called by keypad.s
        .global Enqueue                 ;store debounced function into a queue
        

        ; the stack (must be double-word aligned)
        .align  8
TopOfStack:     .space  TOTAL_STACK_SIZE

        ; the interrupt vector table in SRAM
        .align  512
VecTable:       .space  VEC_TABLE_SIZE * BYTES_PER_WORD

        ; the queue for storing debounced keys
        .align  4
QueueHead:      .space  QUEUE_SIZE * BYTES_PER_WORD

        ; variables

        .align  4
QueueWrite:     .space  BYTES_PER_WORD       ;current write pointer in the queue
QueueTail:      .space  BYTES_PER_WORD       ;tail pointer of the queue
CurRow:         .space  BYTES_PER_WORD       ;current scanning row
PrevPosPattern: .space  BYTES_PER_WORD       ;stored position for current debouncing key
DebounceCntr:   .space  BYTES_PER_WORD       ;counter for debouncing

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
; code
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
   
        .text
        .global resetISR                     ;reset interrupt service routine

resetISR:

main:
        MOVA    R0, TopOfStack               ;initialize the stack pointers
        MSR     MSP, R0                      ;Main Stack Pointer
        SUB     R0, R0, #HANDLER_STACK_SIZE
        MSR     PSP, R0                      ;Process Stack Pointer

        BL      InitPower                    ;turn on power to everything
        BL      InitClocks                   ;turn on clocks to everything
        BL      MoveVecTable                 ;move the vector table to RAM
        BL      InitGPIO                     ;setup the I/O pins for keypad
                                             
                                             ;initialize the variable
        MOVA    R1, CurRow                   ;reset the current row = 0
        MOV32   R0, RESET_POSITION           
        STR     R0, [R1]

        MOVA    R1, PrevPosPattern           ;reset the stored position to row = 0, column = 0
        MOV32   R0, RESET_POSITION           
        STR     R0, [R1] 

        MOVA    R1, DebounceCntr             ;reset the debounce counter to 0
        MOV32   R0, RESET_CNTR           
        STR     R0, [R1] 

        MOVA    R0, QueueHead                ;reset the write pointer to the head pointer of the queue
        MOVA    R1, QueueWrite
        STR     R0, [R1]

        ADD     R0, #(QUEUE_SIZE * BYTES_PER_WORD) ;set the tail pointer = head pointer + queue size
        MOVA    R1, QueueTail                
        STR     R0, [R1]

        BL      InstallGPT0Handler           ;install the event handler
        BL      InitGPT0                     ;initialize the internal timer

        MOV32   R1, SCS_BASE_ADDR            ;and finally allow interrupts
        STREG   (1 << GPT0A_IRQ_NUM), R1, NVIC_ISER0

        B Forever                            ;enter an empty non-stop main loop

Forever:       
        B Forever

; Enqueue
;
; Description:       Store the position of the debounced key into a queue. 
;
; Operation:         After receiving the position of the debounced key, we first check if
;                    the queue is full or not. The queue is composed of a head pointer
;                    (QueueHead), a tail pointer (QueueTail), and a write pointer
;                    (QueueWrite) indicating the current position we are going to store
;                    the key. If the queue is full (QueueWrite = QueueTail), then we 
;                    store the key back to QueueHead and reset QueueWrite to the next
;                    position (QueueHead + BYTES_PER_WORD); if the queue is not full,
;                    we store the key to where QueueWrite is pointing, and increment
;                    QueueWrite by BYTES_PER_WORD. After enqueueing, we return to 
;                    event handler to clear GPT0 timer interrupt.
;
; Arguments:         The position of the debounced key is passed in through R3.
; Return Value:      None.
;
; Local Variables:   QueueHead          - head pointer of the queue (initialized in main loop, never updated)
;                    QueueWrite         - current write pointer in the queue 
;                                         (initialized in main loop, incremented during enqueue, and reset when
;                                          the queue is full)
;                    QueueTail          - tail pointer of the queue (initialized in main loop, never updated)
; Shared Variables:  None.
; Global Variables:  None.
;
; Input:             None.
; Output:            None.
;
; Error Handling:    None.
;
; Algorithms:        None.
; Data Structures:   A queue (circular buffer) for storing the debounced keys.
;
; Registers Changed: flags, R0, R1, R2, R3, R4
; Stack Depth:       0 words
;
; Known Bugs:        None.
; Limitation:        Since the main loop is not dequeueing, the earliest debounced keys
;                    will be overwritten when over 100 (queue size = 100) keys are stored.
;
; Revision History:  11/12/25   Li-Yu Chu      initial revision

Enqueue:                                        ;store the debounced key into a queue
                                                ;instead of storing the value of the key, we store the position
                                                ;defined as following diagram:
                                                ;---------------------------------
                                                ;|       |       |       |       |
                                                ;|   3   |   2   |   1   |   0   |
                                                ;|       |       |       |       |
                                                ;---------------------------------
                                                ;|       |       |       |       |
                                                ;|   7   |   6   |   5   |   4   |
                                                ;|       |       |       |       |
                                                ;---------------------------------
                                                ;|       |       |       |       |
                                                ;|  11   |  10   |   9   |   8   |
                                                ;|       |       |       |       |
                                                ;---------------------------------
                                                ;|       |       |       |       |
                                                ;|  15   |  14   |  13   |  12   |
                                                ;|       |       |       |       |
                                                ;---------------------------------

        MOVA    R0, QueueHead                   ;get the address of head pointer
        MOVA    R1, QueueWrite                  ;get the address of write pointer
        LDR     R2, [R1]                        ;load what write pointer is pointing to
        MOVA    R4, QueueTail                   ;get the address of tail pointer 
        LDR     R4, [R4]                        ;load what tail pointer is pointing to

                                                ;determine the location to store debounced keys
        ADD     R0, #BYTES_PER_WORD             ;reset position for write pointer
        TEQ     R2, R4                          ;check if the queue is full (write pointer = tail pointer)
        ITE     EQ                              ;if the queue is full 
        STREQ   R3, [R0]                        ;then store the key back to the head pointer
        STRNE   R3, [R2]                        ;if not full, store the key to write pointer

                                                ;determine the value of write pointer
        ADD     R3, R2, #BYTES_PER_WORD         ;add write pointer address by one word
        TEQ     R2, R4                          ;check if the queue is full (write pointer = tail pointer)
        ITE     EQ                              ;if the queue is full
        STREQ   R0, [R1]                        ;then set the write pointer back to (head pointer + bytes per word)
        STRNE   R3, [R1]                        ;if not full, then update what the write pointer is pointing to 
                                                ;as usual

        BX      LR                              ;return to clear interrupt

        .end