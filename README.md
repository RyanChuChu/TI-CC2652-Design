# EE110A: Embedded System Design Laboratory (ARM Assembly)

![Language](https://img.shields.io/badge/Language-ARM%20Assembly-blue)
![Hardware](https://img.shields.io/badge/Hardware-TI%20CC2652R1F-red)
![University](https://img.shields.io/badge/Caltech-EE110A-orange)

## 📖 Overview
This repository contains low-level ARM Assembly drivers and applications developed for **EE110A: Embedded System Design Laboratory** at the **California Institute of Technology (Caltech)**. 

The code targets the **Texas Instruments CC2652R1 LaunchPad** (ARM Cortex-M4F) and demonstrates bare-metal control of various peripherals without the use of high-level HAL libraries.

## ⚙️ Hardware Components
The project interfaces with the following hardware:
* **MCU Development Board:** TI CC2652R1F LaunchPad
* **Display:** 2x24 LCD Character Display
* **Input:** 4x4 Matrix Keypad (with 74LS139 2:4 Decoder)
* **Actuators:**
    * On-board LEDs
    * Stepper Motor (with L293D driver)
    * Micro Servomotor (PWM controlled)

## 🔌 Pinout Configuration
Mapping of the CC2652 GPIO pins to external peripherals:

| Component | Pin Function | CC2652 LaunchPad GPIO Pin |
|-----------|--------------|---------------------------|
| **Keypad**| Rows (0-3)   | DIO_8 - DIO_9        |
|           | Cols (0-3)   | DIO_12 - DIO_15      |
| **LCD**   | RS           | DIO_20               |
|           | RW           | DIO_19               |
|           | E            | DIO_18               |
|           | Data Bus     | DIO_8 - DIO_15       |
| **Stepper**| IN1 - IN4   | DIO_4 - DIO_5, DIO_21 - DIO_22 |
| **Servo** | PWM Signal, Analog feedback signal   | DIO_3, DIO_23     |

## 📂 Project Structure
* `HW*/`: Main assembly source files (`.s`) and include files
   -  HW1: On-board LED blinking
   -  HW2: 4x4 keypad scanning & debouncing
   -  HW3: LCD string & character displaying
   -  HW4: Stepper motor microstepping
   -  HW5: Servomotor positioning and feedback

## 🚀 Key Features implemented in Assembly
1.  **GPIO Control:** Direct memory access to toggle LEDs and read Keypad matrix states.
2.  **LCD Driver:** Initialization sequence and 8-bit data transmission protocols.
3.  **Timing & Delays:** Precise software delay loops calculated for the CPU clock frequency.
4.  **Stepper Logic:** Microstepping for clockwise and counter-clockwise rotation.
5.  **PWM Generation:** PWM Timer configuration to control Servomotor position.

## 🛠️ Tools & Build Instructions
* **IDE:** Code Composer Studio (CCS) 20.4.0
* **Assembler:** TI Arm Clang Assembler
* **RTOS:** None
* **Debug Probe:** XDS110 (On-board)

### How to Run
1.  Clone this repository.
2.  Import the project folder into Code Composer Studio.
3.  Build the project to generate the binary.
4.  Flash the `.out` file to the CC2652 LaunchPad.

## 📜 License
Demonstration only, not for commercial or educational usage.

## 👤 Author
**Li-Yu Chu** Department of Electrical Engineering  
California Institute of Technology
Instructor: **Glen George**
