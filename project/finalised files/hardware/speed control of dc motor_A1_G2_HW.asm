ORG 0000H
MOV SP, #70H
MOV PSW, #00H
LED EQU P0.4 ; Define BUZZER pin
LED25 EQU P1.5
LED50 EQU P1.6
LED75 EQU P1.7
LED100 EQU P0.3
;-------------------------------------------------------------
RS EQU P1.1
EN EQU P1.2
;-------------------------------------------------------------
INITIALIZATION:
MOV P0, #00H
MOV P1, #00H
MOV P2, #00H
MOV P3, #0FEH ;11111110
SETB LED
;-------------------------------------------------------------

;--------------------------------------------------------------
LCD_INIT:
MOV R2, #38H ;INITIALIZING LCD, 2 LINES, 5X7 MATRIX
ACALL COMMAND ;CALLING COMMAND SUBROUTINE

MOV R2, #0EH ;DISPLAY ON, CURSOR ON
ACALL COMMAND

MOV R2, #01H ;CLEARING SCREEN
ACALL COMMAND
MOV A,#06H ;INCREMENT CURSOR POSITION
ACALL COMMAND
MOV R2, #80H ;CURSOR AT START OF 1ST LINE
ACALL COMMAND
MOV A,#3CH
ACALL COMMAND
MOV DPTR,#MSG ;Display Starting message
ACALL LCD_PRINT ;Subroutine for displaying in LCD
MOV DPTR,#MSG2
ACALL LCD_PRINT
MOV R2,#01H
ACALL COMMAND
MOV DPTR,#MSG3 ;Display Starting message
ACALL LCD_PRINT ;Subroutine for displaying in LCD
MOV DPTR,#MSG4
ACALL LCD_PRINT

MOV R2,#01H
ACALL COMMAND
MOV DPTR,#MSG5 ;Display Starting message
ACALL LCD_PRINT ;Subroutine for displaying in LCD
MOV DPTR,#MSG6
ACALL LCD_PRINT

MOV R2,#01H
ACALL COMMAND
MOV DPTR,#MSG7 ;Display Starting message
ACALL LCD_PRINT ;Subroutine for displaying in LCD
MOV DPTR,#MSG8
ACALL LCD_PRINT

MOV R2,#01H
ACALL COMMAND
MOV DPTR,#MSG9 ;Display Starting message
ACALL LCD_PRINT ;Subroutine for displaying in LCD
MOV DPTR,#MSG10
ACALL LCD_PRINT

MOV R2,#01H
ACALL COMMAND
MOV DPTR,#MSG11 ;Display Starting message
ACALL LCD_PRINT ;Subroutine for displaying in LCD
MOV DPTR,#MSG12
ACALL LCD_PRINT

MOV R2, #01H 
ACALL COMMAND
MOV DPTR,#START1 ;Display Starting message
ACALL LCD_PRINT ;Subroutine for displaying in LCD
MOV DPTR,#START2
ACALL LCD_PRINT
MOV R2, #01H 
ACALL COMMAND
MOV DPTR,#ACTIVE
ACALL LCD_PRINT
LJMP DECISION

;LCD display subroutine-----------------------------------------
LCD_PRINT:
LOOP:
CLR A
MOVC A, @A+DPTR
MOV R2, A
JZ EXIT ;stop writing when null char is detected
ACALL DISPLAY ;main display part
ACALL DELAY ;giving a short delay for LCD
INC DPTR
LJMP LOOP
EXIT:
MOV R2, #0C0H ;go to the 2nd line of LCD
ACALL COMMAND
RET

DISPLAY:
MOV P2, R2 ;subroutine for displaying in LCD
SETB RS ;RW is grounded in Hardware
SETB EN
ACALL DELAY
CLR EN
RET
;---------------------------------------------------------------
COMMAND:
MOV P2, R2 ;giving instructions to LCD
CLR RS
SETB EN
ACALL DELAY
CLR EN
ACALL DELAY
RET
;---------------------------------------------------------------
DELAY:
MOV 52H, #100 ;50 ms delay (approx)
D1: MOV 51H, #255
DJNZ 51H, $
DJNZ 52H, D1
RET
;---------------------------------------------------------------

;---------------------------------------------------------------
DECISION:
LJMP MOTOR_ROTATION ;Start Motor part

;MOTOR PART------------------------------------------------------
MOTOR_ROTATION:
SETB P1.0
SETB P1.3 ;Input to motor driver
CLR P1.4 ;Clockwise direction
;---------------------------------------------------------------
STARTUP_MOTOR:
MOV R2, #01H
ACALL COMMAND
MOV DPTR, #INT_MSG ;print 'ENTER RPM LEVEL'
LCALL LCD_PRINT
MOV R2, #01H
ACALL COMMAND
MOV DPTR, #LEVEL ;print 'LEVEL: 1 TO A'
LCALL LCD_PRINT
LCALL DELAY
MOV DPTR, #STOP ;print 'PRESS 0 TO STOP'
LCALL LCD_PRINT
MOV DPTR, #ACLCL
LCALL LCD_PRINT

;keyboard RPM Input Scanning------------------------------------
;---------------------------------------------------------------
;SCANNING ALL COLUMN ------------------------------------------
ML:
JNB P3.0, CC1 
JNB P3.1, CC2
JNB P3.2, CC3
JNB P3.3, CC4
SJMP ML
;---------------------------------------------------------------
;SCANNING COLUMN1 ----------------------------------------------
CC1:
JNB P3.4, JMP_TO_1
JNB P3.5, JMP_TO_2
JNB P3.6, JMP_TO_3
JNB P3.7, JMP_TO_A

SETB P3.0
CLR P3.1
SJMP ML
;SCANNING COLUMN2 ---------------------------------------------

CC2:
JNB P3.4, JMP_TO_4
JNB P3.5, JMP_TO_5
JNB P3.6, JMP_TO_6
JNB P3.7, JMP_TO_B

SETB P3.1
CLR P3.2
SJMP ML
;SCANNING COLUMN3 ---------------------------------------------

CC3:
JNB P3.4, JMP_TO_7
JNB P3.5, JMP_TO_8
JNB P3.6, JMP_TO_9
JNB P3.7, JMP_TO_C

SETB P3.2
CLR P3.3
SJMP ML
;SCANNING COLUMN4 ---------------------------------------------

CC4:
JNB P3.4, JMP_TO_F
JNB P3.5, JMP_TO_0
JNB P3.6, JMP_TO_E
JNB P3.7, JMP_TO_D

SETB P3.3
CLR P3.0
LJMP ML
;---------------------------------------------------------------
JMP_TO_0: LJMP M_0 ;MOTOR OFF
JMP_TO_1: LJMP M_1 ;LEVEL 1
JMP_TO_2: LJMP M_2 ;LEVEL 2
JMP_TO_3: LJMP M_3 ;LEVEL 3
JMP_TO_4: LJMP ML ;NOT NEEDED
JMP_TO_5: LJMP ML ;continue scanning
JMP_TO_6: LJMP ML
JMP_TO_7: LJMP ML
JMP_TO_8: LJMP ML
JMP_TO_9: LJMP ML
JMP_TO_A: LJMP M_A ;LEVEL 4
JMP_TO_B: LJMP ML
JMP_TO_C: LJMP ML
JMP_TO_D: LJMP ML
JMP_TO_E: LJMP M_E ;CLOCKWISE
JMP_TO_F: LJMP M_F ;ANTI-CLOCKWISE
;---------------------------------------------------------------

M_0:
SETB LED ; Turn off LED when '0' is pressed
JNB P3.5,M_0 ;wait for key release
MOV R2, #01H
ACALL COMMAND ;clear LCD screen
MOV DPTR, #OFF_MSG ;display 'Motor off'
ACALL LCD_PRINT
LJMP MOTOR_0 ;MOTOR OFF STATE
M_1:
SETB LED ; Turn off LED when '0' is pressed
JNB P3.4,M_1
MOV R2, #01H
ACALL COMMAND
MOV DPTR, #LVL1
ACALL LCD_PRINT
MOV DPTR, #STOP
ACALL LCD_PRINT
LJMP MOTOR_1 ;RPM LEVEL 1

M_2:
SETB LED ; Turn off LED when '0' is pressed
JNB P3.5,M_2
MOV R2, #01H
ACALL COMMAND
MOV DPTR, #LVL2
ACALL LCD_PRINT
MOV DPTR, #STOP
ACALL LCD_PRINT
LJMP MOTOR_2 ;RPM LEVEL 2

M_3:
SETB LED ; Turn off LED when '0' is pressed
JNB P3.6,M_3
MOV R2, #01H
ACALL COMMAND
MOV DPTR, #LVL3
ACALL LCD_PRINT
MOV DPTR, #STOP
ACALL LCD_PRINT
LJMP MOTOR_3 ;RPM LEVEL 3

M_A:
SETB LED ; Turn off LED when '0' is pressed
JNB P3.7,M_A
MOV R2, #01H
ACALL COMMAND
MOV DPTR, #LVL4
ACALL LCD_PRINT
MOV DPTR, #STOP
ACALL LCD_PRINT
LJMP MOTOR_4 ;RPM LEVEL 4
;---------------------------------------------------------------
M_F:
SETB LED ; Turn off LED when '0' is pressed
JNB P3.4,M_F
MOV R2, #01H
ACALL COMMAND
MOV DPTR, #ANTICLK ;Display 'Anticlockwise'
ACALL LCD_PRINT
MOV DPTR, #CLM
ACALL LCD_PRINT
SETB P1.0
SETB P1.4 ;anticlockwise rotation
CLR P1.3
LJMP ML ;scan for new input

M_E:
SETB LED ; Turn off LED when '0' is pressed
JNB P3.6,M_E
MOV R2, #01H
ACALL COMMAND
MOV DPTR, #CLKWISE
ACALL LCD_PRINT
MOV DPTR, #CLM
ACALL LCD_PRINT
SETB P1.0
SETB P1.3 ;clockwise rotation (In1=1,In2=0)
CLR P1.4
LJMP ML
;---------------------------------------------------------------
;Delay subroutine for PWM
;---------------------------------------------------------------
DELAYM:
MOV R5, #1
Hl: MOV R4, #100
H2: MOV R3, #255
H3: DJNZ R3, H3
DJNZ R4, H2
DJNZ R5, Hl
RET
;---------------------------------------------------------------
LC: MOV P3, #0FEH ;INITIAL CONDITION
LJMP ML ;SCAN KEYPAD AGAIN
;---------------------------------------------------------------
MOTOR_0:
CLR P1.0 ;MOTOR OFF
CLR P1.3
CLR P1.4
JNB P3.4,LL ;JNB IS SHORT JUMP,
JNB P3.5,LL ;SO LL IS USED AS AN INTERMEDIATE STAGE
JNB P3.6,LL
JNB P3.7,LL
SETB P3.0
CLR P3.3 ;CHECK ROW 4 (* 0 # D)
JNB P3.4,LC ;'*' PRESSED
JNB P3.5,LC ;'0' PRESSED
JNB P3.6,LC ;'#' PRESSED
SETB P3.3
SETB LED ; Turn off LED when '0' is pressed
CLR LED25
CLR LED50
CLR LED75
CLR LED100
CLR P3.0 ;AGAIN CHECK ROW 1(1 2 3 A)
SJMP MOTOR_0
;---------------------------------------------------------------
LL: LJMP ML ;JUMP TO L1
;---------------------------------------------------------------
MOTOR_1: ;25% DUTY CYCLE
SETB LED
SETB LED25
CLR LED50
CLR LED75
CLR LED100
SETB P1.0
SETB P1.3
CLR P1.4
ACALL DELAYM
CLR P1.3
CLR P1.4
ACALL DELAYM
ACALL DELAYM
ACALL DELAYM
ACALL DELAYM
JNB P3.4,LL ;CHECK FOR NEW INPUT
JNB P3.5,LL ;KEY 1,2,3,A FOR LEVEL 1-4
JNB P3.6,LL
JNB P3.7,LL
SETB P3.0
CLR P3.3
JNB P3.4,ACL1_1 ;'*' FOR ANTI-CLOCKWISE
JNB P3.5,LC ;GO OUT WHEN '0' IS PRESSED
JNB P3.6,CL1_1 ;# FOR CLOCKWISE
SETB P3.3
CLR P3.0

MOV R2,#01H
ACALL COMMAND
MOV DPTR,#MSG13 ;Display Starting message
ACALL LCD_PRINT ;Subroutine for displaying in LCD
MOV DPTR,#MSG13
ACALL LCD_PRINT

MOV R2,#01H
ACALL COMMAND
MOV DPTR,#MSG14 ;Display Starting message
ACALL LCD_PRINT ;Subroutine for displaying in LCD
MOV DPTR,#MSG15
ACALL LCD_PRINT
;JNB P1.0, LIM1
LJMP M_0

LC1_2: LJMP LC
ACL1_1:LJMP ACL1
CL1_1: LJMP CL1
LL_2:LJMP LL

MOTOR_1_ACL: ;25% DUTY CYCLE
SETB LED
SETB LED25
CLR LED50
CLR LED75
CLR LED100
SETB P1.0
SETB P1.4
CLR P1.3
ACALL DELAYM
CLR P1.4
CLR P1.3
ACALL DELAYM
ACALL DELAYM
ACALL DELAYM
ACALL DELAYM
JNB P3.4,LL_2 ;CHECK FOR NEW INPUT
JNB P3.5,LL_2 ;KEY 1,2,3,A FOR LEVEL 1-4
JNB P3.6,LL_2
JNB P3.7,LL_2
SETB P3.0
CLR P3.3
JNB P3.4,ACL1 ;'*' FOR ANTI-CLOCKWISE
JNB P3.5,LC1_2 ;GO OUT WHEN '0' IS PRESSED
JNB P3.6,CL1 ;# FOR CLOCKWISE
SETB P3.3
CLR P3.0

MOV R2,#01H
ACALL COMMAND
MOV DPTR,#MSG13 ;Display Starting message
ACALL LCD_PRINT ;Subroutine for displaying in LCD
MOV DPTR,#MSG13
ACALL LCD_PRINT

MOV R2,#01H
ACALL COMMAND
MOV DPTR,#MSG14 ;Display Starting message
ACALL LCD_PRINT ;Subroutine for displaying in LCD
MOV DPTR,#MSG15
ACALL LCD_PRINT

;JNB P1.0, LIM1A
LJMP M_0


;---------------------------------------------------------------
LL_1: LJMP LL
LC1_1: LJMP LC1_2
;......................................
CL1:ACALL CL_MAIN ;FOR CLOCKWISE ROTATION
LJMP MOTOR_1 ;CONTINUE SAME RPM LEVEL
ACL1:ACALL ACL_MAIN
LJMP MOTOR_1_ACL
;---------------------------------------------------------------
MOTOR_2: ;50% DUTY CYCLE
SETB LED
CLR LED25
CLR LED75
CLR LED100
SETB LED50
SETB P1.0
SETB P1.3
CLR P1.4
ACALL DELAYM
ACALL DELAYM
CLR P1.3
CLR P1.4
ACALL DELAYM
ACALL DELAYM
JNB P3.4,LL_1
JNB P3.5,LL_1
JNB P3.6,LL_1
JNB P3.7,LL_1
SETB P3.0
CLR P3.3
JNB P3.4,ACL2_1 ;'*' pressed
JNB P3.5,LC1_1
JNB P3.6,CL2_1
SETB P3.3
CLR P3.0
SJMP MOTOR_2

LL_12:LJMP LL_1

ACL2_1: LJMP ACL2
CL2_1: LJMP CL2

MOTOR_2_ACL: ;50% DUTY CYCLE
SETB LED
CLR LED25
CLR LED75
CLR LED100
SETB LED50
SETB P1.0
SETB P1.4
CLR P1.3
ACALL DELAYM
ACALL DELAYM
CLR P1.4
CLR P1.3
ACALL DELAYM
ACALL DELAYM
JNB P3.4,LL_12
JNB P3.5,LL_12
JNB P3.6,LL_12
JNB P3.7,LL_12
SETB P3.0
CLR P3.3
JNB P3.4,ACL2 ;'*' pressed
JNB P3.5,LC1
JNB P3.6,CL2
SETB P3.3
CLR P3.0
SJMP MOTOR_2_ACL

;---------------------------------------------------------------
CL2: ACALL CL_MAIN
LJMP MOTOR_2
ACL2: ACALL ACL_MAIN ;rotation anticlockwise
LJMP MOTOR_2_ACL ;continue with the same RPM
;---------------------------------------------------------------
LC1: LJMP ML ;used as a redirect
;---------------------------------------------------------------
;CLOCKWISE ROTATION---------------------------------------------
CL_MAIN:
MOV R2, #01H
ACALL COMMAND
MOV DPTR, #CLKWISE
ACALL LCD_PRINT
MOV DPTR, #ACLM
ACALL LCD_PRINT
RET
;ANTI-CLOCKWISE ROTATION----------------------------------------
ACL_MAIN:
MOV R2, #01H
ACALL COMMAND
MOV DPTR, #ANTICLK
ACALL LCD_PRINT
MOV DPTR, #CLM
ACALL LCD_PRINT
RET
;---------------------------------------------------------------

MOTOR_3: ;75% DUTY CYCLE
SETB LED
CLR LED25
CLR LED50
CLR  LED100
SETB LED75
SETB P1.0
SETB P1.3
CLR P1.4
;SETB LED75
ACALL DELAYM
ACALL DELAYM
ACALL DELAYM
CLR P1.3
CLR P1.4
ACALL DELAYM
JNB P3.4,LL1_12
JNB P3.5,LL1_12
JNB P3.6,LL1_12
JNB P3.7,LL1_12
SETB P3.0
CLR P3.3
JNB P3.4,ACL3_1
JNB P3.5,LC1
JNB P3.6,CL3_1
SETB P3.3
CLR P3.0
SJMP MOTOR_3


LC11_1: LJMP LC1
LL1_12:LJMP LL1_1
ACL3_1:LJMP ACL3
CL3_1:LJMP CL3

MOTOR_3_ACL: ;75% DUTY CYCLE
SETB LED
CLR LED25
CLR LED50
CLR  LED100
SETB LED75
SETB P1.0
SETB P1.4
CLR P1.3
ACALL DELAYM
ACALL DELAYM
ACALL DELAYM
CLR P1.4
CLR P1.3
ACALL DELAYM
JNB P3.4,LL1_1
JNB P3.5,LL1_1
JNB P3.6,LL1_1
JNB P3.7,LL1_1
SETB P3.0
CLR P3.3
JNB P3.4,ACL3
JNB P3.5,LC11_1
JNB P3.6,CL3
SETB P3.3
CLR P3.0
;JNB P1.0, LIM3A
LJMP MOTOR_3_ACL

;---------------------------------------------------------------
CL3:ACALL CL_MAIN
LJMP MOTOR_3
ACL3:ACALL ACL_MAIN
LJMP MOTOR_3_ACL

LL1_1: LJMP LL1_2
LC111_1: LJMP LC11_1
;---------------------------------------------------------------
MOTOR_4: ;KEY 'A'
CLR LED25
CLR LED50
CLR LED75
SETB LED100
SETB P1.0 ;100% DUTY CYCLE
SETB P1.3
CLR P1.4
CLR LED ; Turn on buzzer when motor reaches 3000 RPM

ACALL DELAYM
ACALL DELAYM
ACALL DELAYM
ACALL DELAYM
JNB P3.4,LL1_2
JNB P3.5,LL1_2
JNB P3.6,LL1_2
JNB P3.7,LL1_2
SETB P3.0
CLR P3.3
JNB P3.4,ACL4_1
JNB P3.5,LC111_1
JNB P3.6,CL4_1
SETB P3.3
CLR P3.0
;JNB P1.0, LIM4
CLR P1.0
SJMP MOTOR_4

LL1_2: LJMP LL1
ACL4_1:LJMP ACL4
CL4_1: LJMP CL4
LC111_2: LJMP LC111_1

MOTOR_4_ACL: ;KEY 'A'
CLR LED25
CLR LED50
CLR LED75
SETB LED100
SETB P1.0 ;100% DUTY CYCLE
SETB P1.4
CLR P1.3
CLR LED ; Turn on buzzer when motor reaches 3000 RPM
ACALL DELAYM
ACALL DELAYM
ACALL DELAYM
ACALL DELAYM
JNB P3.4,LL1
JNB P3.5,LL1
JNB P3.6,LL1
JNB P3.7,LL1
SETB P3.0
CLR P3.3
JNB P3.4,ACL4
JNB P3.5,LC111_2
JNB P3.6,CL4
SETB P3.3
CLR P3.0
;JNB P1.0, LIM4A
CLR P1.0
LJMP MOTOR_4_ACL

;---------------------------------------------------------------
CL4:ACALL CL_MAIN
LJMP MOTOR_4
ACL4:ACALL ACL_MAIN
SJMP MOTOR_4_ACL
;---------------------------------------------------------------
LL1:LJMP ML
;---------------------------------------------------------------

;Display messages----------------------------------------------------
INT_MSG: DB 'ENTER RPM LEVEL',0 ;INITIAL MESSAGE
OFF_MSG: DB 'MOTOR OFF',0
LVL1: DB 'L1:600 RPM,25%',0
LVL2: DB 'L2:1200 RPM,50%',0
LVL3: DB 'L3:1800 RPM,75%',0
LVL4: DB 'L4:2400 RPM,100%',0
CLKWISE: DB 'CLOCKWISE',0
ANTICLK: DB 'ANTI-CLOCKWISE',0
;---------------------------------------------------------------
MSG:    DB 'EEE-4706',0
MSG2:   DB 'A1-GROUP-02',0
MSG3:   DB 'AFIF',0
MSG4:   DB 'ID:141',0
MSG5:   DB 'TASNIA',0
MSG6:   DB 'ID:113',0
MSG7:   DB 'FABBIHA',0
MSG8:   DB 'ID:105',0
MSG9:   DB 'FARUK',0
MSG10:   DB 'ID:133',0
MSG11:   DB 'SHERIFFO',0
MSG12:   DB 'ID:153',0
MSG13:   DB 'OVERLOAD!!',0
MSG14:   DB 'GOING TO STOP',0
MSG15:   DB 'THE MOTOR',0
START1: DB 'DC MOTOR WITH',0
START2: DB 'SPEED CONTROL',0
MSG16:   DB 'MOTOR IS OFF',0
ACTIVE: DB 'MOTOR IS ON',0
;DENY_MSG: DB 'WRONG PASSWORD',0
;TRY_AGN: DB 'TRY AGAIN',0
LEVEL: DB 'LEVELS: 1 TO A',0
STOP: DB 'PRESS 0 TO STOP',0
ACLM: DB 'ANTICLK: PRESS *',0
CLM: DB 'CLK    : PRESS #',0
ACLCL: DB 'ACL: *     CL: #',0
END

