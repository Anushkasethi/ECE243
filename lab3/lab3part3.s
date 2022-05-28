.global _start
.equ TIMER, 0xFFFEC600

_start: MOV R3, #0

//this will check for a key press!!!!! the first key press to start the counter
LOOP: LDR R1, =0xFF200050
      LDR R2, [R1, #0xC]
	  CMP R2, #0
	  BEQ LOOP  
	  STR R2, [R1, #0xC] 
	  //this needs to reset the edge capture just after it has been detected
	  //in order to detect another key press, so it can act accordingly!!
	  
	  

RESET: MOV R3, #0
CHECKIF99: CMP R3, #100
BEQ RESET

//this will start the timer!!Causing a delay to occur
 //we have to check if a button has been pressed again so as to stop and 
		//not display anything until the key has been pressed once more to start the
		//display again.. this will stop the timer and prevent it from counting down 
		//making it stop until the key press

DO_DELAY: LDR R7, =TIMER // for CPUlator use =500000
		LDR R10, =50000000
		STR R10, [R7]
		BL CHECKBUTTONPRESS
		MOV R10, #0b011    //to enable the E and A bit which helps timer to start(when E=1) as well as automatically reload its value (when A=1)
		STR R10, [R7, #0x8]


//when timer reaches 0 then F bit=1, so if its not 1 that means timer is still going so 
//loop back to TOLOOp, but when it does become 1 then we need to reset it back to 0 so 
//we do that by storing a 1 in the F bit again!!
TOLOOP:  LDR R1, [R7, #0xC]
         CMP R1, #0
		 BEQ TOLOOP
		 STR R1, [R7, #0xC]

//after the timer has finished we proceed to the display part
STARTC: LDR R5, =0xFF200020

CONT:   MOV R0, R3
		BL DIVIDE
		MOV R9, R1
		BL SEG7_CODE
		MOV R4, R0
		MOV R0, R9
		BL SEG7_CODE
		MOV R8, R0
		LSL R8, #8
		ORR R4, R8
		STR R4, [R5]
		
		
        
RESET1: ADD R3, #1
       B CHECKIF99
	   
//the button to stop the timer has been pressed so set edge capture to 1 and 
//reset it again so it can detect the other key press!!
//if key hasnt been pressed then dont stop the timer and make it continue as it was 
//previously!!
CHECKBUTTONPRESS: LDR R1, =0xFF200050
                  LDR R11, [R1, #0xC]
                  CMP R11, #0
				  BEQ MOVE
				  STR R11, [R1, #0xC]
				  
//to start the timer again we need to press the key once more which is what this loop
//does for us:
LOOP2:   		  LDR R11, [R1, #0xC]
				  CMP R11, #0
				  BEQ LOOP2
				  STR R11, [R1, #0xC]
				  MOV PC, LR
				  
MOVE: MOV PC, LR	   
	   
	   
DIVIDE: PUSH {R4, LR}
MOV R4, #0
CONT2:  CMP R0, #10
		BLT DIV_DENT
		SUB R0, #10
		ADD R4, #1
		B CONT2
		POP {R4, LR}
DIV_DENT: PUSH { LR}
          MOV R1, R4
		  POP {LR}
          MOV PC, LR


SEG7_CODE:// PUSH {R0, R1, LR}
           MOV R1, #BIT_CODES
           ADD R1, R0
		   LDRB R0, [R1]
		   //POP {R0, R1, LR}
		   MOV PC, LR
BIT_CODES: .byte 0b00111111, 0b00000110, 0b01011011, 0b01001111, 0b01100110
.byte 0b01101101, 0b01111101, 0b00000111, 0b01111111, 0b01100111
.skip   2      // pad with 2 bytes to maintain word alignment