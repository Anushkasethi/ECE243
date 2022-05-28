.global _start
_start: LDR SP, =20000
MOV R5, #0
        MOV R6, #0

.equ TIMER, 0xFFFEC600
.equ KEYS, 0xFF200050

SELECT: LDR R3, =KEYS
        LDR R12, [R3, #0xC]
		CMP R12, #0
		BEQ SELECT
		STR R12, [R3, #0xC] 

LOOP: LDR R1, =2000000
      LDR R2, =TIMER
	  STR R1, [R2]
	  MOV R1, #0b0011
	  STR R1, [R2, #0x8]
	  


DISPLAY: LDR R8, =0xFF200020 // base address of HEX3-HEX0
WRAP: BL CHECKKEYOFF
      CMP R5, #99
      MOVGT R5, #0
      ADDGT R6, #1
      CMP R6, #59
      MOVGT R5, #0
      MOVGT R6, #0

      MOV R0, R5 // display R5 on HEX1-0 (hundredths)
      BL DIVIDE // ones digit will be in R0; tens

// digit in R1
      MOV R9, R1 // save the tens digit
      BL SEG7_CODE
      MOV R4, R0 // save bit code
MOV R0, R9 // retrieve the tens digit, get bit

BL SEG7_CODE
LSL R0, #8
ORR R4, R0

MOV R0, R6 //hex2-3 (seconds)
BL DIVIDE
MOV R10, R1 //Has the 10's digit
BL SEG7_CODE
MOV R11, R0 //store the ones digit in r11
MOV R0, R10 //get the 10's digit in r0
BL SEG7_CODE
LSL R0, #24 //Has the 10's digit
LSL R11, #16
ORR R0, R11
ORR R4, R0
STR R4, [R8] // display the numbers from R6 and R5

ADD R5, #1
BL POLL
B WRAP

CHECKKEYOFF: LDR R12, [R3, #0xC]
             CMP R12, #0
			 BEQ MOVE
			 STR R12, [R3, #0xC]
			 
CHECK:    LDR R12, [R3, #0xC]
          CMP R12, #0
		  BEQ CHECK
		  STR R12, [R3, #0xC]
		  MOV PC, LR

POLL:// PUSH {R4, LR}
      LDR R2, =TIMER
      LDR R4, [R2, #0xC]
      CMP R4, #0
	  BEQ POLL
	  STR R4, [R2, #0xC]
	 // POP {R4, LR}
      MOV PC, LR

MOVE: MOV PC, LR

SEG7_CODE: MOV R1, #BIT_CODES

ADD R1, R0 // index into the BIT_CODES "array"
LDRB R0, [R1] // load the bit pattern (to be returned)
MOV PC, LR

BIT_CODES: .byte 0b00111111, 0b00000110, 0b01011011, 0b01001111, 0b01100110
.byte 0b01101101, 0b01111101, 0b00000111, 0b01111111, 0b01100111
.skip   2      // pad with 2 bytes to maintain word alignment
DIVIDE: PUSH {R11}
MOV R11, #0
CONT: CMP R0, #10
BLT DIV_END
SUB R0, #10
ADD R11, #1
B CONT

DIV_END: MOV R1, R11 // quotient in R1 (remainder in R0)
POP {R11}
MOV PC, LR
