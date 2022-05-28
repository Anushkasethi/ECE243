/* Program that converts a binary number to decimal */
.text // executable code follows
.global _start
_start:
MOV R4, #N
MOV R6, #DIVISOR
LDR R6, [R6]
MUL R7, R6, R6 //divisor for giving the digit for the hundred's place 
MUL R8, R7, R6 //divisor for giving the digit for the thousand's place
MOV R5, #Digits // R5 points to the decimal digits storage location
LDR R4, [R4] // R4 holds N
MOV R0, R4 // parameter for DIVIDE goes in R0
MOV R1, R8
BL DIVIDE
STRB R1, [R5, #3] //Thousand's digit 
MOV R1, R7
BL DIVIDE
STRB R1, [R5, #2] //Hundred's digit 
MOV R1, R6
BL DIVIDE
STRB R1, [R5, #1] // Tens digit is now in R1
STRB R0, [R5] // Ones digit is in R0
END: B END
/* Subroutine to perform the integer division R0 / 10.
* Returns: quotient in R1, and remainder in R0 */
DIVIDE: MOV R2, #0
CONT: 
CMP R0, R1
BLT DIV_END
SUB R0, R1
ADD R2, #1
B CONT
DIV_END: MOV R1, R2 // quotient in R1 (remainder in R0) it will hv value 9
MOV PC, LR

N: .word 9876 // the decimal number to be converted
Digits: .space 4 // storage space for the decimal digits
DIVISOR: .word 16 //choosing any divisor to divide the any 4 digit no.
.end

We use multiply function as 
suppose we have  a number (9876)10
Now to convert to hexadecimal we first divide 9876 by 16^3 which gives us the thousand's 
digit. then we divide the remiander by 16^2 giving us the hundred's digit 
then we divide the remiander further by 16 giving us the one's digit and the remainder is
the zeroth  digit. This is the principle applied in conversion from decimal to hex
hence we use the same principle to this assembly code in order to get the answer using any
divisor that we want.