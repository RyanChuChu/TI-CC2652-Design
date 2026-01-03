;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;                                                                            ;
;                                    HW4                                     ;
;                           Stepper Motor Interface                          ;
;                                                                            ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; Description:      This program demonstrates the complete operation of a  
;                   stepper motor control system using an event-driven architecture.  
;                   The software initializes power, clocks, GPIO pins, interrupt 
;                   structures, and internal timers, then controls a stepper  
;                   motor through a set of high-level motor-control functions.
;                   The test loop utilizes a test table and sequentially executes
;                   each command with a 1 second delay between each test cases.
;                
; Input:            None.
;                   
; Output:           PWM signals on the four stepper-motor output pins through GPT2  
;                   (DIO22, 21) and GPT3 (DIO5, 4) timers. The signals determine 
;                   coil energizing sequences through current sinking and sourcing 
;                   by driver L293D, and rotate the motor in microsteps. 
;
; User Interface:   The user controls the behavior of stepper motor through
;                   pre-configured test table.
;
; Error Handling:   SetAngle wraps all value of angles specified to range [0, 359],
;                   not only supporting positive integer values.
;
; Algorithms:       The core of the system is event-driven stepper motor control  
;                   using periodic GPT1 timeout interrupts, which fires every 20 ms. 
;                   The GPT1 event handler compares the current angle against the
;                   desired target angle by absolute value of their difference, and  
;                   rotates the motor by 1 microstep (6°) toward the goal. It updates  
;                   PWM match registers for GPT2 and GPT3 through a table-driven method  
;                   to generate the correct coil currents as soon as possible and maintains 
;                   real-time tracking of the motor’s current position. It also supports 
;                   automatic wrap-around and pointer cycling in the PWM table.
;                   
; Data Structures:  Microstepping PWM value lookup table, LCD initialization table,
;                   and stepper motor test table.
;
; Revision History:
;     11/30/25  Li-Yu Chu      initial revision
;     12/02/25  Li-Yu Chu      update test table
;     12/03/25  Li-Yu Chu      updated comments


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

        .sect   ".const"
        ;PWM lookup table
        .align  4
PWMStepperTab:

        .word       4157, 0000, 0000, 2400
        .word       4799, 0000, 0000, 0000
        .word       4157, 0000, 2400, 0000
        .word       2400, 0000, 4157, 0000
        .word       0000, 0000, 4799, 0000
        .word       0000, 2400, 4157, 0000
        .word       0000, 4157, 2400, 0000
        .word       0000, 4799, 0000, 0000
        .word       0000, 4157, 0000, 2400
        .word       0000, 2400, 0000, 4157
        .word       0000, 0000, 0000, 4799
        .word       2400, 0000, 0000, 4157

EndPWMStepperTab:

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

        ;stepper motor test table
        .align 4  
TestStepperMotorTab:

                ;operation      ;argument(if any)
        .word            1,                     6
        .word            4    
        .word            1,                     6  
        .word            1,                     6
        .word            4  
        .word            1,                     6  
        .word            1,                     6  
        .word            1,                     6
        .word            4  
        .word            1,                     6  
        .word            1,                     6  
        .word            1,                     6
        .word            4  
        .word            1,                     6  
        .word            1,                     6  
        .word            1,                     6
        .word            4  
        .word            1,                     6  
        .word            1,                     6  
        .word            1,                     6
        .word            4 
        .word            1,                     6  
        .word            1,                     6  
        .word            4
        .word            1,                    -6  
        .word            1,                    -6  
        .word            4      

        ; .word           0,                    90
        ; .word           1,                    60
        ; .word           3
        ; .word           0,                    60
        ; .word           1,                    30 
        ; .word           2
        ; .word           1,                    -6
        ; .word           2
        ; .word           0,                   359
        ; .word           1,                   -90
        ; .word           1,                   180
        ; .word           4

EndTestStepperMotorTab:


        .data
        
        ;initialization functions
        .ref    InitPower               ;turn on power to everything
        .ref    InitClocks              ;turn on clocks to everything
        .ref    MoveVecTable            ;move the vector table to RAM
        .ref    InitGPIO                ;setup the I/O pins for stepper motor
        .ref    InstallGPT1Handler      ;install the main routine event handler
        .ref    InitGPTs                ;initialize the general purpose timer

        ;interrupt vector table
        .global VecTable                ;the interrupt vector table in SRAM

        ;stepper motor timer initialization
        .ref    InitStepperGPT

        ;stepper motor event handler
        .ref    GPT1EventHandler        ;main routine event handler

        ;stepper motor PWM table and pointer
        .def    PWMStepperTab           ;start of PWM table
        .def    EndPWMStepperTab        ;end of PWM table
        .def    PWMPointer              ;the pointer in PWM table
        
        ;global angle tracking variables for all projects
        .global CurrentPos              ;the actual current motor angle (updated by motor driver)
        .global TargetPos               ;the desired angle the motor should rotate to

        ;imported stepper motor functions
        .global SetAngle
        .global SetRelAngle
        .global HomeStepper
        .global SetHomeStepper
        .global GetAngle

        ;LCD functions
        .ref    InitLCD                 ;LCD initialization

        ; the stack (must be double-word aligned)
        .align  8
TopOfStack:     .space  TOTAL_STACK_SIZE

        ; the interrupt vector table in SRAM
        .align  512
VecTable:       .space  VEC_TABLE_SIZE * BYTES_PER_WORD

        ; variables

        .align  4
CurrentPos:     .space  BYTES_PER_WORD  ;the current angle stepper motor is pointing to
TargetPos:      .space  BYTES_PER_WORD  ;the expected angle stepper motor is going to
PWMPointer:     .space  BYTES_PER_WORD  ;the pointer in PWM table

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
        BL      InitGPIO                     ;setup the I/O pins for stepper motor
                                             
                                             ;initialize the variable
        MOVA    R0, PWMStepperTab            ;get address of first entry of PWM table
        MOVA    R1, PWMPointer               ;reset PWM pointer to the second entry of PWM table
        ADD     R0, #BYTE_PER_ENTRY          ;preventing loading invalid entries from PWM table
        STR     R0, [R1]

        MOVA    R1, CurrentPos               ;initialize angle tracking variables to 0
        STREG   HOME_POS, R1, 0

        MOVA    R1, TargetPos
        STREG   HOME_POS, R1, 0


        BL      InstallGPT1Handler           ;install the main routine event handler
        BL      InitGPTs                     ;initialize the internal timers

        MOVA    R1, LCDInitTab                  ;get start address of LCD initialization table
        MOVA    R2, EndLCDInitTab               ;get end address of LCD initialization table
        BL      InitLCD                      ;initialize LCD

        BL      InitStepperGPT               ;initialize timers for stepper motor 

        MOV32   R1, SCS_BASE_ADDR            ;and finally allow interrupts
        STREG   (1 << GPT1A_IRQ_NUM), R1, NVIC_ISER0

        MOVA    R3, TestStepperMotorTab      ;get the start address of test table
        MOVA    R4, EndTestStepperMotorTab   ;get the end address of test table

        B       TestStepperMotor             ;start testing

TestStepperMotor: 

        LDR     R1, [R3], #BYTES_PER_WORD    ;load operation code and call functions respectively
                                             ;0 - SetAngle
                                             ;1 - SetRelAngle
                                             ;2 - HomeStepper
                                             ;3 - SetHomeStepper
                                             ;4 - GetAngle

        TEQ     R1, #SETANGLE_OPCODE
        BEQ     CallSetAngle

        TEQ     R1, #SETRELANGLE_OPCODE
        BEQ     CallSetRelAngle

        TEQ     R1, #HOMESTEPPER_OPCODE
        BEQ     CallHomeStepper

        TEQ     R1, #SETHOMESTEPPER_OPCODE
        BEQ     CallSetHomeStepper

        TEQ     R1, #GETANGLE_OPCODE
        BEQ     CallGetAngle

        B       DoneTest                        ;invalid test opcode

CallSetAngle:

        LDR     R0, [R3], #BYTES_PER_WORD       ;load argument (angle)
        BL      SetAngle                        
        
        B       MainPrevTimeout                 ;wait for delay between test cases

CallSetRelAngle:

        LDR     R0, [R3], #BYTES_PER_WORD       ;load argument (angle)
        BL      SetRelAngle

        B       MainPrevTimeout                 ;wait for delay between test cases

CallHomeStepper:

        BL      HomeStepper                     ;no input argument

        B       MainPrevTimeout                 ;wait for delay between test cases

CallSetHomeStepper:

        BL      SetHomeStepper                  ;no input argument

        B       MainPrevTimeout                 ;wait for delay between test cases

CallGetAngle:

        BL      GetAngle                        ;no input argument

        B       MainPrevTimeout                 ;wait for delay between test cases

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

DoneTest:

        TEQ     R3, R4                          ;check if it's end of test table
        BNE     TestStepperMotor                ;if not, loop next command

        BEQ     DoneTest                        ;if yes, stay in forever loop

        .end