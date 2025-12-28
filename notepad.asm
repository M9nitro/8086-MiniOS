.model small
.stack 100h

.data
menu        db 13,10,"==== NOTEPAD SYSTEM ====",13,10
            db "1. Write Text (Append)",13,10
            db "2. View Text",13,10
            db "3. Edit Text (Rewrite)",13,10
            db "4. Delete Text",13,10
            db "5. Exit",13,10
            db "Select option: $"

writeMsg    db 13,10,"Enter text (max 200 chars):",13,10,"$"
viewMsg     db 13,10,"Stored Text:",13,10,"$"
emptyMsg    db 13,10,"[No text stored]",13,10,"$"
deleteMsg   db 13,10,"Text deleted successfully.",13,10,"$"
fullMsg     db 13,10,"[Buffer Full]",13,10,"$"

buffer      db 200 dup('$')
bufLen      dw 0

inputBuf    db 201
            db ?
            db 200 dup(?)

newline     db 13,10,"$"

.code
main:
    mov ax, @data
    mov ds, ax

menu_loop:
    lea dx, menu
    mov ah, 09h
    int 21h

    mov ah, 01h
    int 21h
    sub al, '0'

    cmp al, 1
    je append_text
    cmp al, 2
    je view_text
    cmp al, 3
    je edit_text
    cmp al, 4
    je delete_text
    cmp al, 5
    je exit_prog

    jmp menu_loop

; ================================
; APPEND TEXT
; ================================
append_text:
    lea dx, writeMsg
    mov ah, 09h
    int 21h

    lea dx, inputBuf
    mov ah, 0Ah
    int 21h

    mov cl, inputBuf+1
    mov ch, 0

    mov ax, bufLen
    add ax, cx
    cmp ax, 200
    ja buffer_full

    lea si, inputBuf+2
    lea di, buffer
    add di, bufLen

append_loop:
    mov al, [si]
    mov [di], al
    inc si
    inc di
    loop append_loop

    mov byte ptr [di], '$'

    mov al, inputBuf+1
    cbw
    add bufLen, ax

    jmp menu_loop

buffer_full:
    lea dx, fullMsg
    mov ah, 09h
    int 21h
    jmp menu_loop

; ================================
; VIEW TEXT
; ================================
view_text:
    cmp bufLen, 0
    je empty_text

    lea dx, viewMsg
    mov ah, 09h
    int 21h

    lea dx, buffer
    mov ah, 09h
    int 21h

    lea dx, newline
    mov ah, 09h
    int 21h
    jmp menu_loop

empty_text:
    lea dx, emptyMsg
    mov ah, 09h
    int 21h
    jmp menu_loop

; ================================
; EDIT (REWRITE)
; ================================
edit_text:
    mov bufLen, 0
    mov byte ptr buffer, '$'
    jmp append_text

; ================================
; DELETE TEXT
; ================================
delete_text:
    mov bufLen, 0
    mov byte ptr buffer, '$'

    lea dx, deleteMsg
    mov ah, 09h
    int 21h
    jmp menu_loop

; ================================
; EXIT
; ================================
exit_prog:
    mov ah, 4Ch
    int 21h

end main
