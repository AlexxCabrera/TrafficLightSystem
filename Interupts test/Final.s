		.include 	"address_map_arm.s"
		.include	"defines.s"
		.include	"interrupt_ID.s"

/*********************************************************************************
 * Initialize the exception vector table
 ********************************************************************************/
				.section .vectors, "ax"

				B 			_start					// reset vector
				B 			SERVICE_UND				// undefined instruction vector
				B 			SERVICE_SVC				// software interrrupt vector
				B 			SERVICE_ABT_INST		// aborted prefetch vector
				B 			SERVICE_ABT_DATA		// aborted data vector
				.word 	0							// unused vector
				B 			SERVICE_IRQ				// IRQ interrupt vector
				B 			SERVICE_FIQ				// FIQ interrupt vector

/* ********************************************************************************
 * This program demonstrates use of interrupts with assembly code. It first starts
 * two timers: an HPS timer, and the Altera interval timer (in the FPGA). The 
 * program responds to interrupts from these timers in addition to the pushbutton 
 * KEYs in the FPGA.
 *
 * The interrupt service routine for the HPS timer causes the main program to flash
 * the green light connected to the HPS GPIO1 port.
 * 
 * The interrupt service routine for the Altera interval timer displays a pattern 
 * on the HEX3-0 displays, and rotates this pattern either left or right:
 *		KEY[0]: loads a new pattern from the SW switches
 *		KEY[1]: rotates the displayed pattern to the right
 *		KEY[2]: rotates the displayed pattern to the left
 *		KEY[3]: stops the rotation
 ********************************************************************************/
 //       .text
        .global _start


_start:

	LDR		R0, =JP2_BASE

	LDR		R1, =0xF0F0F1E //working properly with B1 being D5
	STR		R1,	[R0,#4]

	LDR		R1, =0x0000000
	STR		R1,	[R0]

	
	BL		Delay1
CODE:	
	BL		Pattern1
	
	BL		Delay1

	BL		Pattern2

	BL		Delay1

	BL		Pattern4

	BL		LIGHTSOUT

B	CODE

Delay:
	PUSH	{LR}
	movt	R5, #0xAF50
LOOPL:
	SUBS	R5,#1
	BNE	LOOPL
	POP		{PC}

Delay1:
	PUSH	{LR}
	movt	R5, #0x5F50
LOOPL1:
	SUBS	R5,#1
	BNE	LOOPL1
	POP		{PC}

Delay2:
	PUSH	{LR}
	movt	R5, #0x1F50
LOOPL2:
	SUBS	R5,#1
	BNE	LOOPL1
	POP		{PC}

LIGHTSOUT:
PUSH {LR}
	LDR		R1, =0x0000000
	STR		R1,	[R0]
POP {PC}

Pattern1: //Clockwise starting at 12:00 (Green, Red, Green, Red)
PUSH {LR}
    LDR		R1, =0x08020802
	STR		R1,	[R0]
	BL		Delay
	LDR		R1, =0x04020402
	STR		R1,	[R0]
	BL		Delay1
	LDR		R1, =0x02020202
	STR		R1,	[R0]
POP {PC}

Pattern2://	(Red, Green, Red, Green)
PUSH {LR}
    LDR		R1, =0x02080208
	STR		R1,	[R0]
	BL		Delay
	LDR		R1, =0x02040204
	STR		R1,	[R0]
	BL		Delay1
	LDR		R1, =0x02020202
	STR		R1,	[R0]
POP {PC}

/*Pattern3:// (Blinking Reds / malfunction / maintanace )
//PUSH {LR}
    LDR		R1, =0x02020202 //long time on
	STR		R1,	[R0]
	BL		Delay
	LDR		R1, =0x00000000// short blink

	B	Pattern3

//POP {PC}*/

Pattern4:// All reds and Blues, Blues will blink before turning off
PUSH {LR}
	LDR		R6,	=HEX3_HEX0_BASE
    LDR		R1, =0x02020202
	STR		R1,	[R0]
	BL		Delay1

	LDR		R1, =0x03030312
	STR		R1,	[R0]
	BL		Delay

	LDR		R4,	=0x5
Pattern4b:

	LDR	R6, =HEX3_HEX0_BASE

	CMP	R4, #5
	LDR	R1,	=FIVE
	STREQ	R1, [R6]

	LDR		R1, =0x02020202
	STR		R1,	[R0]
	BL		Delay2

	LDR		R1, =0x03030312
	STR		R1,	[R0]
	BL		Delay2

	LDR		R1, =0x02020202
	STR		R1,	[R0]

	SUBS	R4,	#1
	BL		UpdateTimer
	BNE		Pattern4b
	BL		Delay1
POP {PC}
	
UpdateTimer:
PUSH {LR}
	LDR	R6, =HEX3_HEX0_BASE

	CMP	R4, #5
	LDR	R1,	=FIVE
	STREQ	R1, [R6]

	CMP	R4, #4
	LDR	R1,	=FOUR
	STREQ	R1, [R6]

	CMP	R4, #3
	LDR	R1,	=THREE
	STREQ	R1, [R6]

	CMP	R4, #2
	LDR	R1,	=TWO
	STREQ	R1, [R6]

	CMP	R4, #1
	LDR	R1,	=ONE
	STREQ	R1, [R6]

	CMP	R4, #0
	LDR	R1,	=ZERO
	STREQ	R1, [R6]
	BLEQ	Delay1
	LDR	R1,	=0x0
	STREQ	R1, [R6]

POP {PC}
	
	/* Global variables */

.global TICK

TICK:

.word 0x0 //used by HPS timer

.global PATTERN

PATTERN:

.word 0x0000000F // initial pattern for HEX displays

.global KEY_PRESSED

KEY_PRESSED:

.word KEY1 //stores code representing pushbutton key pressed

.global SHIFT_DIR

SHIFT_DIR:

.word RIGHT //pattern shifting direction
.end
