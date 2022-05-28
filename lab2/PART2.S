/* Program that counts consecutive 1’s */
.text // executable code follows
.global _start
_start:
MOV R1, #TEST_NUM // load the data word ...
MOV R3, #TEST_NUM
LDR R1, [R1] // into R1
MOV R0, #0 // R0 will hold the result
MOV R5, #0
ONES:CMP R1, #0 // loop until the data contains no more 1’s
BEQ GOTO
LSR R2, R1, #1 // perform SHIFT, followed by AND
AND R1, R1, R2
ADD R0, #1 // count the string length so far
B ONES
GOTO:CMP R5, R0 //if r5 has  a lesser length than r1 replace r5 with r1 otherwise 
BGT MOVEON
MOV R5, R0
MOVEON: ADD R3, #4
LDR R1, [R3]
MOV R0, #0
CMP R1, #0
BEQ END
B ONES

END: B END
TEST_NUM: .word 0x103fe00f, 0xffffff,  0x104fe00f, 0x105fe00f, 0x106fe00f 
           .word 0x107fe00f, 0x108fe00f, 0x109fe00f, 0x204fe00f, 0x304fe00f, 0
.end