

		.include 	"address_map_arm.s"
       	.text
        .global _start


_start:

	LDR		R0, =JP2_BASE
	LDR		R2,	=SW_BASE

	LDR		R1, =0x0F0F0F1E //working properly with B1 being D5
	STR		R1,	[R0,#4]

	LDR		R1, =0x02020202
	STR		R1,	[R0]

	
	BL		Delay1
CODE:	
	BL		Pattern1
	
	BL		Check

	BL		Delay1

	BL		Pattern2

	BL		Check

	BL		Delay1

	BL		Pattern4

	BL		Check

//	BL		LIGHTSOUT

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

Pattern3:// (Blinking Reds / malfunction / maintanace )
//PUSH {LR}
	LDR		R7,	[R2]
	CMP		R7,	#1
	POPNE	{PC}	//CODE

    LDR		R1, =0x02020202 //long time on
	STR		R1,	[R0]
	BL		Delay2
	LDR		R1, =0x00000000// short blink
	STR		R1,	[R0]
	BL		Delay2
    LDR		R1, =0x02020202 //long time on
	STR		R1,	[R0]

	B	Pattern3

//POP {PC}

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

	
Check:
PUSH {LR}

	LDR		R7,	[R2]
	CMP		R7,	#1
	BLEQ	Pattern3

POP	{PC}