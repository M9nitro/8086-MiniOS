;=============================================
;        System Clock Module (8086)
;        With Repeat Option
;=============================================

.MODEL SMALL
.STACK 100H

.DATA
clock_title DB 0DH,0AH,'System Clock: $'
colon_char  DB ':$'
newline     DB 0DH,0AH,'$'
ask_msg     DB 0DH,0AH,'Show again? (Y/N): $'

.CODE
MAIN PROC

        ; Initialize DS
        MOV AX, @DATA
        MOV DS, AX

clock_start:
        CALL system_clock

        ; Ask user
        LEA DX, ask_msg
        MOV AH, 09H
        INT 21H

        ; Read choice
        MOV AH, 01H
        INT 21H
        ; AL = user input

        CMP AL, 'Y'
        JE clock_start
        CMP AL, 'y'
        JE clock_start

        ; Exit
        MOV AX, 4C00H
        INT 21H

MAIN ENDP

;====================== SYSTEM CLOCK ======================
; Displays current time in HH:MM:SS
; All registers preserved
system_clock PROC
        PUSH AX
        PUSH BX
        PUSH CX
        PUSH DX
        PUSH SI
        PUSH DI

        ; New line
        LEA DX, newline
        MOV AH, 09H
        INT 21H

        ; Print title
        LEA DX, clock_title
        MOV AH, 09H
        INT 21H

        ; Get system time
        MOV AH, 2CH
        INT 21H
        ; CH = hour, CL = minute, DH = second

        ; Print Hour
        MOV AL, CH
        CALL print_2_digit

        ; :
        LEA DX, colon_char
        MOV AH, 09H
        INT 21H

        ; Print Minute
        MOV AL, CL
        CALL print_2_digit

        ; :
        LEA DX, colon_char
        MOV AH, 09H
        INT 21H

        ; Print Second
        MOV AL, DH
        CALL print_2_digit

        POP DI
        POP SI
        POP DX
        POP CX
        POP BX
        POP AX
        RET
system_clock ENDP

;====================== PRINT 2 DIGITS ====================
; AL = value (0–99)
print_2_digit PROC
        PUSH AX
        PUSH BX
        PUSH DX

        XOR AH, AH
        MOV BL, 10
        DIV BL              ; AL=tens, AH=units

        ADD AL, '0'
        MOV DL, AL
        MOV AH, 02H
        INT 21H

        MOV AL, AH
        ADD AL, '0'
        MOV DL, AL
        MOV AH, 02H
        INT 21H

        POP DX
        POP BX
        POP AX
        RET
print_2_digit ENDP

END MAIN
