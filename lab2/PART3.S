/* Program that counts consecutive 1's */

          .text                   // executable code follows
          .global _start                  
_start:                             
			MOV		R4, #TEST_NUM   // R4 HOLDS THE ADDRESS OF TEST_NUM - DON'T WANT TO MODIFY THIS     
			MOV     R5, #0          // R5 will hold 1S
			MOV		R6, #0			//R6 WILL HOLD 0S
			MOV		R7, #0			//R7 WILL HOLD ALTERNATE 01S
			MOV		R8, R4	
//LOOP_MAIN IS CALLING A FUNCTION REPEADEDLY 
//OUTPUT: 	R5 HAS LONGEST SERIES OF 1 IN ANY NUM 
//			R6 HAS LONGEST SERIES OF 0 IN ANY NUM
//			R7 HAS LONGEST SERIES OF 0/1 AND 1/0
LOOP_MAIN: 	LDR		R1, [R8]	//R8++ (4BYTES) (R4 WILL HOLD THE ADDRESS OF THE NEXT NUMBER AFTER IT LOADS INTO R1)
			CMP		R1, #0			//IS R1 HOLDING 0? YES->THAT'S THE LAST NUM
			BEQ		END
			//FIND LONGEST SEQ OF ONES AND STORE IT INTO R5
			BL		ONES
			CMP 	R5, R0
			MOVLT 	R5, R0			//IF R5 - R0 < 0 <=> R0 > R5, UPDATE R5
			
			//FIND LONGEST SEQ OF 0S AND STORE IT INTO R6
			BL		ZEROS
			CMP 	R6, R10
			MOVLT 	R6, R10 		
			//FIND LONGEST ALTERNATING 0/1 SEQUENCE (R1 CAN CHANGE, LAST TIME USING)
			MOV		R12, #ALT_NUM
			LDR		R12, [R12]
			EOR		R1, R1, R12
			BL 		ONES
			BL 		ZEROS 
			CMP		R0, R10
			BLT		ALT_LT
			BGT		ALT_GT
			BEQ		ALT_EQ
ALT_END: 	
END:   		B       END 


////INPUT: R1 HOLDS THE NUMBER WE'RE TESTING !!!!R1 CANNOT CHANGE -> USE R9
//R0 RETURNS RESULT 
ONES:		MOV		R0, #0
			MOV 	R9, R1			//PERSERVES THE VALUE OF R1
LOOP_ONES:	LSR     R2, R9, #1      //perform SHIFT, followed by AND
 			AND     R9, R9, R2      
         	ADD     R0, #1          //count the string length so far (NUMBER OF SHIFTS IS THE NUMBER OF LONGEST SEQ OF 1)
         	CMP     R9, #0
			BEQ     MOVEBACK
			B       LOOP_ONES            


//INPUT: R1 HOLDS THE NUMBER WE'RE TESTING  !!!!R1 CANNOT CHANGE -> USE R9
//OUTPUT: R10 RETURNS RESULT (LONGEST SEQ OF 0 IN THIS NUM) 
ZEROS: 		MOV 	R10, #0
			MOV 	R9,  R1
			MOV		R3, #FLIP_BITS
			LDR 	R3, [R3]
			EOR		R9, R9, R3	//flip the bits
LOOP_ZEROS:	LSR     R2, R9, #1      	//perform SHIFT, followed by AND
 			AND     R9, R9, R2      
         	ADD     R10, #1          	//count the string length so far (NUMBER OF SHIFTS IS THE NUMBER OF LONGEST SEQ OF 1)
         	CMP     R9, #0
			BEQ     MOVEBACK
			B       LOOP_ZEROS 
			
MOVEBACK: 	MOV 	PC, LR 

ALT_LT: 	CMP 	R10, R7
			MOVGT 	R7, R10
			ADD     R8, #4
			B		LOOP_MAIN		//NOW TEST THE NEXT NUMBER
ALT_GT: 	CMP 	R0, R7
			MOVGT 	R7, R0
			ADD     R8, #4
			B		LOOP_MAIN		//NOW TEST THE NEXT NUMBER
ALT_EQ: 	ADD     R8, #4
            B 		LOOP_MAIN  		//NOW TEST THE NEXT NUMBER

ALT_NUM: 	.word	0x55555555 //010101..(ALT PAIR of 0s n 1s)

FLIP_BITS: 	.word 	0xFFFFFFFF

TEST_NUM: 	.word 0xffffffff, 0x103fe00f, 0x104fe00f, 0x105fe00f, 0x106fe00f 
            .word 0x107fe00f, 0x108fe00f, 0x109fe00f, 0x204fe00f, 0x304fe00f
			.word	0x0				//WHEN PROGRAM SEES 0, IT STOPS LOOKING FOR MORE INPUTS                   
			
	
	
         
	
	