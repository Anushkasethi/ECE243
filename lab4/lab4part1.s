              .equ      EDGE_TRIGGERED,    0x1
               .equ      LEVEL_SENSITIVE,   0x0
               .equ      CPU0,              0x01    // bit-mask; bit 0 represents cpu0
               .equ      ENABLE,            0x1

               .equ      KEY0,              0b0001
               .equ      KEY1,              0b0010
               .equ      KEY2,              0b0100
               .equ      KEY3,              0b1000

               .equ      IRQ_MODE,          0b10010
               .equ      SVC_MODE,          0b10011

               .equ      INT_ENABLE,        0b01000000
               .equ      INT_DISABLE,       0b11000000
/*********************************************************************************
 * Initialize the exception vector table
 ********************************************************************************/
                .section .vectors, "ax"

                B        _start             // reset vector
                .word    0                  // undefined instruction vector
                .word    0                  // software interrrupt vector
                .word    0                  // aborted prefetch vector
                .word    0                  // aborted data vector
                .word    0                  // unused vector
                B        IRQ_HANDLER        // IRQ interrupt vector
                .word    0                  // FIQ interrupt vector

/*********************************************************************************
 * Main program
 ********************************************************************************/
                .text
                .global  _start
_start:        
                /* Set up stack pointers for IRQ and SVC processor modes */
                MSR		CPSR_c, #0b11010010 			// interrupts masked (off), MODE = IRQ
				LDR		SP, =0x20000           			// set IRQ stack pointer
				
				MSR		CPSR_c, #0b11010011			// interrupts masked, MODE = Supervisor (SVC)								
				LDR		SP, =0x40000				// set supervisor mode (SVC) stack 

				BL		CONFIG_GIC				// configure the ARM generic interrupt controller

				// enable interrupts from parallel port - write to the pushbutton KEY interrupt mask register
				LDR		R0, =0xFF200050				// pushbutton KEY base address
				MOV		R1, #0xF				// set interrupt mask bits
				STR		R1, [R0, #0x8]				// interrupt mask register is (base + 8)

				// enable IRQ interrupts in the processor
				MSR		CPSR_c, #0b01010011			// IRQ unmasked (enabled), MODE = SVC

IDLE:
                B        IDLE                    // main program simply idles

IRQ_HANDLER:
                PUSH     {R0-R7, LR}
    
                /* Read the ICCIAR in the CPU interface */
                LDR      R4, =0xFFFEC100
                LDR      R5, [R4, #0x0C]         // read the interrupt ID

CHECK_KEYS:
                CMP      R5, #73
UNEXPECTED:     BNE      UNEXPECTED              // if not recognized, stop here
    
                BL       KEY_ISR
EXIT_IRQ:
                /* Write to the End of Interrupt Register (ICCEOIR) */
                STR      R5, [R4, #0x10]
    
                POP      {R0-R7, LR}
                SUBS     PC, LR, #4

/*****************************************************0xFF200050***********************************
 * Pushbutton - Interrupt Service Routine                                
 *                                                                          
 * This routine checks which KEY(s) have been pressed. It writes to HEX3-0
 ***************************************************************************************/
                .global  KEY_ISR
				
				
KEY_ISR:      PUSH {R0-R7}
              LDR R4, =0xFF200020 //HEX ADDRESS
              
                //... Code not shown
CHECKKEY:       LDR R3, =0xFF200050
                LDR R2, [R3, #0xC] //Loads the key value in r2
				
				
CLEARINTERRUPT:	LDR		R0, =0xFF200050	// base address of pushbutton KEY port
				MOV		R3, #0xF
				STR		R3, [R0, #0xC]	// clear the interrupt

//Check if key0 has been pressed and also load the previous value in hex0
//go to display load wtever the hex3-0 has and check if hex0 has a value already
//or if its empty. if its empty then add the value in hex3-0 and the value u get
//from the hex0, otherwise if not empty then u sub making it empty but keeping
//the other values in hex1-3 intact!!! So this only affects the hex0  bit!!!
HEX0:			CMP R2, #0b0001
				BNE HEX1
				MOV R0, #0b00111111
				LDRB R7, [R4]
				B DISPLAY
				
HEX1: CMP R2, #0b0010
      BNE HEX2
	  MOV R0, #0b00000110
	  LSL R0, #8
	  LDRB R7, [R4, #1]
	  //LSL R7, #8
	  B DISPLAY
	  

HEX2: CMP R2, #0b0100
      BNE HEX3
	  MOV R0, #0b01011011
	  LSL R0, #16
	  LDRB R7, [R4, #2]
	  B DISPLAY

HEX3: CMP R2, #0b1000
      MOV R0, #0b01001111
	  LSL R0, #24
	  LDRB R7, [R4, #3]
	  B DISPLAY


DISPLAY:        LDR R6, [R4]
                CMP R7, #0
				BNE SUB
ADDI:			ADD R6, R0
				B STORE
SUB:            SUB R6, R0

STORE:          STR R6, [R4]
				B END			
				
END:  POP {R0-R7}
      MOV PC, LR
	  
SEG7_CODE: PUSH {LR}
LDR R1, =BIT_CODES

ADD R1, R0 // index into the BIT_CODES "array"
LDRB R0, [R1] // load the bit pattern (to be returned)
POP {LR}
MOV PC, LR

BIT_CODES: .byte 0b00111111, 0b00000110, 0b01011011, 0b01001111, 0b01100110
.byte 0b01101101, 0b01111101, 0b00000111, 0b01111111, 0b01100111
.skip   2      // pad with 2 bytes to maintain word alignment

/* 
 * Configure the Generic Interrupt Controller (GIC)
*/
                .global  CONFIG_GIC
CONFIG_GIC:
                PUSH     {LR}
                /* Enable the KEYs interrupts */
                MOV      R0, #73
                MOV      R1, #CPU0
                /* CONFIG_INTERRUPT (int_ID (R0), CPU_target (R1)); */
                BL       CONFIG_INTERRUPT

                /* configure the GIC CPU interface */
                LDR      R0, =0xFFFEC100        // base address of CPU interface
                /* Set Interrupt Priority Mask Register (ICCPMR) */
                LDR      R1, =0xFFFF            // enable interrupts of all priorities levels
                STR      R1, [R0, #0x04]
                /* Set the enable bit in the CPU Interface Control Register (ICCICR). This bit
                 * allows interrupts to be forwarded to the CPU(s) */
                MOV      R1, #1
                STR      R1, [R0]
    
                /* Set the enable bit in the Distributor Control Register (ICDDCR). This bit
                 * allows the distributor to forward interrupts to the CPU interface(s) */
                LDR      R0, =0xFFFED000
                STR      R1, [R0]    
    
                POP      {PC}
/* 
 * Configure registers in the GIC for an individual interrupt ID
 * We configure only the Interrupt Set Enable Registers (ICDISERn) and Interrupt 
 * Processor Target Registers (ICDIPTRn). The default (reset) values are used for 
 * other registers in the GIC
 * Arguments: R0 = interrupt ID, N
 *            R1 = CPU target
*/
CONFIG_INTERRUPT:
                PUSH     {R4-R5, LR}
    
                /* Configure Interrupt Set-Enable Registers (ICDISERn). 
                 * reg_offset = (integer_div(N / 32) * 4
                 * value = 1 << (N mod 32) */
                LSR      R4, R0, #3               // calculate reg_offset
                BIC      R4, R4, #3               // R4 = reg_offset
                LDR      R2, =0xFFFED100
                ADD      R4, R2, R4               // R4 = address of ICDISER
    
                AND      R2, R0, #0x1F            // N mod 32
                MOV      R5, #1                   // enable
                LSL      R2, R5, R2               // R2 = value

                /* now that we have the register address (R4) and value (R2), we need to set the
                 * correct bit in the GIC register */
                LDR      R3, [R4]                 // read current register value
                ORR      R3, R3, R2               // set the enable bit
                STR      R3, [R4]                 // store the new register value

                /* Configure Interrupt Processor Targets Register (ICDIPTRn)
                  * reg_offset = integer_div(N / 4) * 4
                  * index = N mod 4 */
                BIC      R4, R0, #3               // R4 = reg_offset
                LDR      R2, =0xFFFED800
                ADD      R4, R2, R4               // R4 = word address of ICDIPTR
                AND      R2, R0, #0x3             // N mod 4
                ADD      R4, R2, R4               // R4 = byte address in ICDIPTR

                /* now that we have the register address (R4) and value (R2), write to (only)
                 * the appropriate byte */
                STRB     R1, [R4]
    
                POP      {R4-R5, PC}

                .end   

	
	
	
	
	
	