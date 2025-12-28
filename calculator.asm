.model small
.stack 100h
.data
    menu db 13,10,"Select Operation:",13,10
         db "1. Addition",13,10
         db "2. Subtraction",13,10
         db "3. Multiplication",13,10
         db "4. Division",13,10
         db "Enter choice: $"

    msg1 db 13,10,"Enter first number (1 or 2 digit): $"
    msg2 db 13,10,"Enter second number (1 or 2 digit): $"
    msg3 db 13,10,"Result: $"
    msg4 db 13,10,"Do you want to continue? (Y/N): $"

    num1 dw 0
    num2 dw 0
    result dw 0
    choice db ?
    cont db ?

.code
main:
    mov ax, @data
    mov ds, ax

start:

; -------- MENU --------
    lea dx, menu
    mov ah, 09h
    int 21h

    mov ah, 01h
    int 21h
    mov choice, al

; -------- FIRST NUMBER --------
    lea dx, msg1
    mov ah, 09h
    int 21h

    call read_number
    mov num1, ax

; -------- SECOND NUMBER --------
    lea dx, msg2
    mov ah, 09h
    int 21h

    call read_number
    mov num2, ax

; -------- OPERATION --------
    mov ax, num1

    cmp choice, '1'
    je add_op
    cmp choice, '2'
    je sub_op
    cmp choice, '3'
    je mul_op
    cmp choice, '4'
    je div_op
    jmp exit

add_op:
    add ax, num2
    jmp show

sub_op:
    sub ax, num2
    jmp show

mul_op:
    mov bx, num2
    mul bx
    jmp show

div_op:
    mov dx, 0
    mov bx, num2
    div bx

show:
    mov result, ax

    lea dx, msg3
    mov ah, 09h
    int 21h

    mov ax, result
    call print_number

; -------- CONTINUE --------
    lea dx, msg4
    mov ah, 09h
    int 21h

    mov ah, 01h
    int 21h
    mov cont, al

    cmp cont, 'Y'
    je start
    cmp cont, 'y'
    je start

exit:
    mov ah, 4Ch
    int 21h

; -------- READ NUMBER --------
read_number proc
    mov ax, 0
    mov cx, 0

read_loop:
    mov ah, 01h
    int 21h

    cmp al, 13
    je done

    sub al, '0'
    mov bl, al

    mov ax, cx
    mov dx, 10
    mul dx
    add ax, bx
    mov cx, ax
    jmp read_loop

done:
    mov ax, cx
    ret
read_number endp

; -------- PRINT NUMBER --------
print_number proc
    cmp ax, 0
    jge positive

    mov dl, '-'
    mov ah, 02h
    int 21h
    neg ax

positive:
    mov bx, 10
    mov cx, 0

div_loop:
    mov dx, 0
    div bx
    push dx
    inc cx
    cmp ax, 0
    jne div_loop

print_loop:
    pop dx
    add dl, '0'
    mov ah, 02h
    int 21h
    loop print_loop

    ret
print_number endp

end main
