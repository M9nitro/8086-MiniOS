;=============================================
;                 MiniOS(8060)
;                CSE341 Project                      
;=============================================
;
;Features:
;         1. User login 
;         2. File Manager
;         3. Calculator
;         4. Notepad
;         5. Task Manager
;         6. Command Prompt 
;         7. Command History
;         8. System Clock
;
;=============================================

.MODEL SMALL
 
.STACK 100H

.DATA   
        ;==================== System Messages =================
        stance_msg DB 0DH,0AH,'===================================',0DH,0AH ; ODH --> 13 CR, 0AH --> 10 LF
                   DB '      Welcome to MiniOS (8060)      ',0DH,0AH
                   DB '===================================',0DH,0AH,'$'

        login_msg  DB 0DH,0AH,'Enter Username: $'
        pass_msg   DB 0DH,0AH,'Enter Password: $'
        login_success_msg DB 0DH,0AH,'Login Successful! Welcome, $'
        login_fail_msg    DB 0DH,0AH,'Login Failed! Try Again.$'
        
        main_menu_msg DB 0DH,0AH,'-------------Main Menu:-------------',0DH,0AH
                      DB '1. File Manager',0DH,0AH
                      DB '2. Calculator',0DH,0AH
                      DB '3. Notepad',0DH,0AH
                      DB '4. Task Manager',0DH,0AH
                      DB '5. Command Prompt',0DH,0AH
                      DB '6. Command History',0DH,0AH
                      DB '7. System Clock',0DH,0AH
                      DB '8. Exit',0DH,0AH
                      DB '------------------------------------',0DH,0AH
                      DB 'Enter choice: $'
        ;======================================================





        
        









; declare variables here

.CODE
MAIN PROC

; initialize DS

MOV AX,@DATA
MOV DS,AX
MOV ES,AX
 
; enter your code here
; display welcome message

    CALL clear_screen

    LEA DX,stance_msg
    MOV AH,09H
    INT 21H
;exit to DOS


               
MOV AX,4C00H
INT 21H

MAIN ENDP
    

; ============================== Mini OS utility calls ==============================
clear_screen PROC
; Clear Screen
        PUSH AX
        PUSH BX
        PUSH CX
        PUSH DX
        
        MOV AX, 0600H ; Scroll Up function
        MOV BH, 02H   ; Attribute for blank lines
        ; 0 --> Black  1 --> Blue  2 --> Green 3 --> Aqua 4 --> Red 5 --> Purple 6 --> Yellow 7 --> Light Gray
        XOR CX, CX   ; Upper left corner (row=0, col=0)
        MOV DX, 184FH ; Lower right corner (row=24, col=79)
        INT 10H       ; BIOS video interrupt
        
        MOV AH, 02H  ; Set cursor position function
        MOV BH, 0    ; Page number
        XOR DX, DX   ; Row=0, Col=0
        int 10H       ; BIOS video interrupt
        
        POP DX
        POP CX
        POP BX
        POP DX
        RET
clear_screen ENDP

; Read Character from Keyboard
;Usage: CALL read_char
;Return: AL = ASCII code of the key pressed
read_char PROC
        MOV AH, 01H 
        INT 21H
        RET
read_char ENDP

; Print Character Procedure
print_char PROC
; Print Character in AL
        MOV AH, 02H
        INT 21H
        RET
print_char ENDP

; Read String Procedure
;Usage:
read_string PROC
        ;Read String to (DI == Buffer, CX == Max Length)
        PUSH AX
        PUSH BX
        PUSH CX
        PUSH DX
        
        ;Clear BX
        XOR BX, BX
read_char_loop:
        CALL read_char

        CMP AL, 0DH ; Enter key
        JE input_done
        
        CMP Al, 08H ; Backspace key
        JE backspace_key
        
        CMP BX, CX
        JGE read_char_loop ; If max length reached, ignore further input
        
        ;Store character in buffer
        MOV [DI + BX], AL
        INC BX
        JMP read_char_loop
backspace_key:
        CMP BX, 0 ; If at beginning of buffer, ignore backspace
        JE read_char_loop
        
        DEC BX
        MOV BYTE PTR [DI + BX], 0 ; Optional: Clear the character visually

        ;Remove the character from Screen
        MOV AH, 02H
        MOV DL, ' ' ; Space character
        INT 21H
        MOV DL, 8 ; Move cursor back
        INT 21H
        
        JMP read_char_loop
input_done:
        MOV BYTE PTR [DI + BX], '$' ; End of string marker
       
        POP DX
        POP CX
        POP BX
        POP AX
        RET
read_string ENDP


;Pint String Procedure
;Usage:
;   LEA DX, string_to_print     
;   CALL print_string
print_string PROC
; Print String at DS:DX
        PUSH AX
        MOV AH, 09H
        INT 21H
        POP AX
        RET
print_string ENDP


comp_strings PROC
        PUSH BX
        PUSH CX
        PUSH SI
        PUSH DI

compare_loop:
        MOV AL,[SI]
        MOV BL,[DI]
        
        CMP AL, BL
        JNE strings_not_equal
        
        CMP AL, '$' ; End of string
        JE strings_equal
        
        INC SI
        INC DI
        JMP compare_loop
strings_not_equal:
        MOV AL, 1 ; Not equal
        JMP compare_done
strings_equal:
        XOR AL, AL ; Equal
compare_done:
        POP DI
        POP SI
        POP CX
        POP BX
        RET
comp_strings ENDP


; Read Number Procedure
;Usage: CALL read_number
read_number PROC
        PUSH BX
        PUSH CX
        PUSH DX
        PUSH SI

; ============================== End of Mini OS utility calls =======================

END MAIN
