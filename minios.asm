; ============================================================================
; 8086 MiniOS - A Simple Operating System Simulation
; ============================================================================
; Features:
;   1. User Login System (password masking)
;   2. File Manager Simulation (create/delete file names)
;   3. Calculator (advanced arithmetic)
;   4. Notepad System (store text in array)
;   5. Task Manager (view running modules)
;   6. Command Line Mode
;   7. History Stack (view previous commands)
;   8. System Clock Display
; ============================================================================

.MODEL SMALL
.STACK 100h

.DATA
    ; ==================== System Messages ====================
    welcome_msg     DB 13, 10, '========================================', 13, 10
                    DB '         8086 MiniOS v1.0', 13, 10
                    DB '========================================', 13, 10, '$'
    
    login_prompt    DB 13, 10, 'Username: $'
    pass_prompt     DB 13, 10, 'Password: $'
    login_success   DB 13, 10, 'Login successful! Welcome to MiniOS.', 13, 10, '$'
    login_fail      DB 13, 10, 'Invalid credentials. Try again.', 13, 10, '$'
    
    main_menu       DB 13, 10, '========== MAIN MENU ==========', 13, 10
                    DB '1. File Manager', 13, 10
                    DB '2. Calculator', 13, 10
                    DB '3. Notepad', 13, 10
                    DB '4. Task Manager', 13, 10
                    DB '5. Command Line', 13, 10
                    DB '6. History', 13, 10
                    DB '7. System Clock', 13, 10
                    DB '8. Logout', 13, 10
                    DB '9. Exit', 13, 10
                    DB '================================', 13, 10
                    DB 'Enter choice: $'
    
    ; ==================== File Manager ====================
    file_menu       DB 13, 10, '===== FILE MANAGER =====', 13, 10
                    DB '1. Create File', 13, 10
                    DB '2. Delete File', 13, 10
                    DB '3. List Files', 13, 10
                    DB '4. Back to Menu', 13, 10
                    DB 'Choice: $'
    file_name_prompt DB 13, 10, 'Enter filename: $'
    file_created    DB 13, 10, 'File created successfully!', 13, 10, '$'
    file_deleted    DB 13, 10, 'File deleted successfully!', 13, 10, '$'
    file_not_found  DB 13, 10, 'File not found!', 13, 10, '$'
    file_list_hdr   DB 13, 10, '--- File List ---', 13, 10, '$'
    no_files_msg    DB 'No files in system.', 13, 10, '$'
    file_full_msg   DB 13, 10, 'File storage full!', 13, 10, '$'
    
    ; File storage: 10 files max, 20 chars each
    MAX_FILES       EQU 10
    FILE_NAME_LEN   EQU 20
    file_count      DB 0
    file_storage    DB 200 DUP(0)  ; 10 files * 20 chars
    
    ; ==================== Calculator ====================
    calc_menu       DB 13, 10, '===== CALCULATOR =====', 13, 10
                    DB '1. Addition', 13, 10
                    DB '2. Subtraction', 13, 10
                    DB '3. Multiplication', 13, 10
                    DB '4. Division', 13, 10
                    DB '5. Modulo', 13, 10
                    DB '6. Power', 13, 10
                    DB '7. Back to Menu', 13, 10
                    DB 'Choice: $'
    num1_prompt     DB 13, 10, 'Enter first number: $'
    num2_prompt     DB 13, 10, 'Enter second number: $'
    result_msg      DB 13, 10, 'Result: $'
    div_zero_msg    DB 13, 10, 'Error: Division by zero!', 13, 10, '$'
    
    ; Calculator variables
    num1            DW 0
    num2            DW 0
    calc_result     DW 0
    
    ; ==================== Notepad ====================
    notepad_menu    DB 13, 10, '===== NOTEPAD =====', 13, 10
                    DB '1. Write Text', 13, 10
                    DB '2. View Text', 13, 10
                    DB '3. Clear Text', 13, 10
                    DB '4. Back to Menu', 13, 10
                    DB 'Choice: $'
    text_prompt     DB 13, 10, 'Enter text (max 200 chars): ', 13, 10, '$'
    text_display    DB 13, 10, '--- Notepad Content ---', 13, 10, '$'
    text_cleared    DB 13, 10, 'Notepad cleared!', 13, 10, '$'
    empty_notepad   DB 'Notepad is empty.', 13, 10, '$'
    
    ; Notepad storage
    notepad_buffer  DB 201 DUP(0)
    notepad_len     DB 0
    
    ; ==================== Task Manager ====================
    task_header     DB 13, 10, '===== TASK MANAGER =====', 13, 10
                    DB '--- Active Modules ---', 13, 10, '$'
    task_login      DB ' [ACTIVE] Login System', 13, 10, '$'
    task_file       DB ' [ACTIVE] File Manager', 13, 10, '$'
    task_calc       DB ' [ACTIVE] Calculator', 13, 10, '$'
    task_notepad    DB ' [ACTIVE] Notepad System', 13, 10, '$'
    task_taskmgr    DB ' [ACTIVE] Task Manager', 13, 10, '$'
    task_cmdline    DB ' [ACTIVE] Command Line', 13, 10, '$'
    task_history    DB ' [ACTIVE] History Stack', 13, 10, '$'
    task_clock      DB ' [ACTIVE] System Clock', 13, 10, '$'
    task_footer     DB '------------------------', 13, 10
                    DB 'Press any key to continue...', '$'
    
    ; ==================== Command Line ====================
    cmd_prompt      DB 13, 10, 'MiniOS> $'
    cmd_help        DB 13, 10, 'Available commands:', 13, 10
                    DB '  help    - Show this help', 13, 10
                    DB '  clear   - Clear screen', 13, 10
                    DB '  time    - Show system time', 13, 10
                    DB '  files   - List files', 13, 10
                    DB '  ver     - Show version', 13, 10
                    DB '  history - Show command history', 13, 10
                    DB '  exit    - Exit command line', 13, 10, '$'
    cmd_version     DB 13, 10, '8086 MiniOS Version 1.0', 13, 10
                    DB 'Built for 8086 processor', 13, 10, '$'
    cmd_unknown     DB 13, 10, 'Unknown command. Type "help" for list.', 13, 10, '$'
    cmd_cleared     DB 13, 10, 'Screen cleared.', 13, 10, '$'
    
    ; Command buffer
    cmd_buffer      DB 50 DUP(0)
    cmd_len         DB 0
    
    ; ==================== History Stack ====================
    hist_header     DB 13, 10, '===== COMMAND HISTORY =====', 13, 10, '$'
    hist_empty      DB 'No commands in history.', 13, 10, '$'
    hist_footer     DB '============================', 13, 10
                    DB 'Press any key to continue...', '$'
    
    ; History storage: 10 commands max, 30 chars each
    MAX_HISTORY     EQU 10
    HIST_CMD_LEN    EQU 30
    history_count   DB 0
    history_index   DB 0
    history_storage DB 300 DUP(0)  ; 10 commands * 30 chars
    
    ; ==================== System Clock ====================
    clock_header    DB 13, 10, '===== SYSTEM CLOCK =====', 13, 10
                    DB 'Current Time: $'
    clock_footer    DB 13, 10, '=========================', 13, 10
                    DB 'Press any key to continue...', '$'
    colon           DB ':', '$'
    
    ; ==================== User Authentication ====================
    ; Default credentials
    def_username    DB 'admin', 0
    def_password    DB '1234', 0
    
    ; User input buffers
    input_username  DB 20 DUP(0)
    input_password  DB 20 DUP(0)
    
    ; ==================== General ====================
    newline         DB 13, 10, '$'
    press_key       DB 13, 10, 'Press any key to continue...', '$'
    goodbye_msg     DB 13, 10, 'Thank you for using MiniOS. Goodbye!', 13, 10, '$'
    logout_msg      DB 13, 10, 'Logged out successfully.', 13, 10, '$'
    
    ; Temp buffer for input
    temp_buffer     DB 50 DUP(0)
    temp_len        DB 0
    
    ; Module active flags
    logged_in       DB 0

.CODE
MAIN PROC
    ; Initialize data segment
    MOV AX, @DATA
    MOV DS, AX
    MOV ES, AX
    
    ; Clear screen
    CALL clear_screen
    
    ; Display welcome message
    LEA DX, welcome_msg
    CALL print_string
    
login_loop:
    ; Login system
    CALL user_login
    CMP logged_in, 1
    JNE login_loop
    
main_loop:
    ; Display main menu
    LEA DX, main_menu
    CALL print_string
    
    ; Get user choice
    CALL read_char
    
    ; Process menu choice
    CMP AL, '1'
    JE do_file_manager
    CMP AL, '2'
    JE do_calculator
    CMP AL, '3'
    JE do_notepad
    CMP AL, '4'
    JE do_task_manager
    CMP AL, '5'
    JE do_command_line
    CMP AL, '6'
    JE do_history
    CMP AL, '7'
    JE do_clock
    CMP AL, '8'
    JE do_logout
    CMP AL, '9'
    JE exit_program
    
    JMP main_loop

do_file_manager:
    CALL file_manager
    JMP main_loop

do_calculator:
    CALL calculator
    JMP main_loop

do_notepad:
    CALL notepad
    JMP main_loop

do_task_manager:
    CALL task_manager
    JMP main_loop

do_command_line:
    CALL command_line
    JMP main_loop

do_history:
    CALL show_history
    JMP main_loop

do_clock:
    CALL system_clock
    JMP main_loop

do_logout:
    MOV logged_in, 0
    LEA DX, logout_msg
    CALL print_string
    JMP login_loop

exit_program:
    ; Display goodbye message
    LEA DX, goodbye_msg
    CALL print_string
    
    ; Exit to DOS
    MOV AH, 4Ch
    INT 21h
MAIN ENDP

; ============================================================================
; USER LOGIN SYSTEM - with password masking
; ============================================================================
user_login PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH SI
    PUSH DI
    
    ; Prompt for username
    LEA DX, login_prompt
    CALL print_string
    
    ; Read username
    LEA DI, input_username
    MOV CX, 19
    CALL read_string
    
    ; Prompt for password
    LEA DX, pass_prompt
    CALL print_string
    
    ; Read password with masking
    LEA DI, input_password
    MOV CX, 19
    CALL read_password_masked
    
    ; Verify credentials
    LEA SI, input_username
    LEA DI, def_username
    CALL compare_strings
    CMP AL, 0
    JNE login_failed
    
    LEA SI, input_password
    LEA DI, def_password
    CALL compare_strings
    CMP AL, 0
    JNE login_failed
    
    ; Login successful
    MOV logged_in, 1
    LEA DX, login_success
    CALL print_string
    JMP login_done

login_failed:
    MOV logged_in, 0
    LEA DX, login_fail
    CALL print_string

login_done:
    POP DI
    POP SI
    POP DX
    POP CX
    POP BX
    POP AX
    RET
user_login ENDP

; Read password with asterisk masking
read_password_masked PROC
    ; DI = buffer address, CX = max length
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    
    XOR BX, BX          ; Character count

read_pass_loop:
    ; Read character without echo
    MOV AH, 08h
    INT 21h
    
    ; Check for Enter
    CMP AL, 13
    JE read_pass_done
    
    ; Check for Backspace
    CMP AL, 8
    JE pass_backspace
    
    ; Check if buffer full
    CMP BX, CX
    JGE read_pass_loop
    
    ; Store character
    MOV [DI+BX], AL
    INC BX
    
    ; Display asterisk
    MOV AH, 02h
    MOV DL, '*'
    INT 21h
    
    JMP read_pass_loop

pass_backspace:
    CMP BX, 0
    JE read_pass_loop
    
    DEC BX
    MOV BYTE PTR [DI+BX], 0
    
    ; Erase asterisk on screen
    MOV AH, 02h
    MOV DL, 8       ; Backspace
    INT 21h
    MOV DL, ' '     ; Space
    INT 21h
    MOV DL, 8       ; Backspace again
    INT 21h
    
    JMP read_pass_loop

read_pass_done:
    MOV BYTE PTR [DI+BX], 0  ; Null terminate
    
    POP DX
    POP CX
    POP BX
    POP AX
    RET
read_password_masked ENDP

; ============================================================================
; FILE MANAGER - create/delete file names
; ============================================================================
file_manager PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH SI
    PUSH DI

file_menu_loop:
    LEA DX, file_menu
    CALL print_string
    
    CALL read_char
    
    CMP AL, '1'
    JE create_file
    CMP AL, '2'
    JE delete_file
    CMP AL, '3'
    JE list_files
    CMP AL, '4'
    JE file_exit
    
    JMP file_menu_loop

create_file:
    ; Check if storage is full
    MOV AL, file_count
    CMP AL, MAX_FILES
    JGE storage_full
    
    ; Prompt for filename
    LEA DX, file_name_prompt
    CALL print_string
    
    ; Calculate storage position
    MOV AL, file_count
    MOV BL, FILE_NAME_LEN
    MUL BL
    LEA DI, file_storage
    ADD DI, AX
    PUSH DI                     ; Save file storage position for history
    
    ; Read filename
    MOV CX, FILE_NAME_LEN - 1
    CALL read_string
    
    ; Increment file count
    INC file_count
    
    ; Add filename to history (use the stored filename)
    POP SI                      ; SI now points to the entered filename
    CALL add_to_history
    
    LEA DX, file_created
    CALL print_string
    JMP file_menu_loop

storage_full:
    LEA DX, file_full_msg
    CALL print_string
    JMP file_menu_loop

delete_file:
    ; Check if any files exist
    CMP file_count, 0
    JE no_files
    
    ; Prompt for filename
    LEA DX, file_name_prompt
    CALL print_string
    
    ; Read filename to delete
    LEA DI, temp_buffer
    MOV CX, FILE_NAME_LEN - 1
    CALL read_string
    
    ; Search for file
    XOR CX, CX          ; File index
    
search_file:
    CMP CL, file_count
    JGE file_not_exists
    
    ; Calculate file position
    MOV AL, CL
    MOV BL, FILE_NAME_LEN
    MUL BL
    LEA SI, file_storage
    ADD SI, AX
    
    ; Compare with input
    LEA DI, temp_buffer
    PUSH CX
    CALL compare_strings
    POP CX
    
    CMP AL, 0
    JE found_file
    
    INC CL
    JMP search_file

found_file:
    ; Shift remaining files up
    MOV AL, CL
    MOV BL, FILE_NAME_LEN
    MUL BL
    LEA DI, file_storage
    ADD DI, AX              ; DI = file to delete
    
    LEA SI, file_storage
    ADD SI, AX
    ADD SI, FILE_NAME_LEN   ; SI = next file
    
    ; Calculate bytes to move
    MOV AL, file_count
    DEC AL
    SUB AL, CL
    MOV BL, FILE_NAME_LEN
    MUL BL
    MOV CX, AX
    
    CMP CX, 0
    JE skip_shift
    
    REP MOVSB

skip_shift:
    DEC file_count
    
    LEA DX, file_deleted
    CALL print_string
    JMP file_menu_loop

file_not_exists:
    LEA DX, file_not_found
    CALL print_string
    JMP file_menu_loop

no_files:
    LEA DX, no_files_msg
    CALL print_string
    JMP file_menu_loop

list_files:
    LEA DX, file_list_hdr
    CALL print_string
    
    CMP file_count, 0
    JE no_files
    
    XOR CX, CX          ; File index
    
list_loop:
    CMP CL, file_count
    JGE list_done
    
    ; Calculate file position
    MOV AL, CL
    PUSH CX
    MOV BL, FILE_NAME_LEN
    MUL BL
    LEA SI, file_storage
    ADD SI, AX
    
    ; Print file number
    POP CX
    PUSH CX
    MOV AL, CL
    ADD AL, '1'
    MOV AH, 02h
    MOV DL, AL
    INT 21h
    MOV DL, '.'
    INT 21h
    MOV DL, ' '
    INT 21h
    
    ; Print filename
    CALL print_asciiz
    
    ; Newline
    LEA DX, newline
    CALL print_string
    
    POP CX
    INC CL
    JMP list_loop

list_done:
    JMP file_menu_loop

file_exit:
    POP DI
    POP SI
    POP DX
    POP CX
    POP BX
    POP AX
    RET
file_manager ENDP

; ============================================================================
; CALCULATOR - advanced arithmetic
; ============================================================================
calculator PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX

calc_menu_loop:
    LEA DX, calc_menu
    CALL print_string
    
    CALL read_char
    MOV BL, AL          ; Save operation
    
    CMP AL, '7'
    JE calc_exit
    
    CMP AL, '1'
    JB calc_menu_loop
    CMP AL, '6'
    JA calc_menu_loop
    
    ; Get first number
    LEA DX, num1_prompt
    CALL print_string
    CALL read_number
    MOV num1, AX
    
    ; Get second number
    LEA DX, num2_prompt
    CALL print_string
    CALL read_number
    MOV num2, AX
    
    ; Perform operation
    MOV AX, num1
    MOV CX, num2
    
    CMP BL, '1'
    JE do_add
    CMP BL, '2'
    JE do_sub
    CMP BL, '3'
    JE do_mul
    CMP BL, '4'
    JE do_div
    CMP BL, '5'
    JE do_mod
    CMP BL, '6'
    JE do_power

do_add:
    ADD AX, CX
    JMP show_result

do_sub:
    SUB AX, CX
    JMP show_result

do_mul:
    MUL CX
    JMP show_result

do_div:
    CMP CX, 0
    JE div_by_zero
    XOR DX, DX
    DIV CX
    JMP show_result

do_mod:
    CMP CX, 0
    JE div_by_zero
    XOR DX, DX
    DIV CX
    MOV AX, DX          ; Remainder is in DX
    JMP show_result

do_power:
    ; Calculate num1 ^ num2
    MOV BX, AX          ; Base
    MOV CX, num2        ; Exponent
    MOV AX, 1           ; Result
    
    CMP CX, 0
    JE show_result      ; x^0 = 1
    
power_loop:
    MUL BX
    LOOP power_loop
    JMP show_result

div_by_zero:
    LEA DX, div_zero_msg
    CALL print_string
    JMP calc_menu_loop

show_result:
    MOV calc_result, AX
    
    LEA DX, result_msg
    CALL print_string
    
    MOV AX, calc_result
    CALL print_number
    
    LEA DX, newline
    CALL print_string
    
    JMP calc_menu_loop

calc_exit:
    POP DX
    POP CX
    POP BX
    POP AX
    RET
calculator ENDP

; ============================================================================
; NOTEPAD SYSTEM - store text in array
; ============================================================================
notepad PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH SI
    PUSH DI

notepad_menu_loop:
    LEA DX, notepad_menu
    CALL print_string
    
    CALL read_char
    
    CMP AL, '1'
    JE write_text
    CMP AL, '2'
    JE view_text
    CMP AL, '3'
    JE clear_text
    CMP AL, '4'
    JE notepad_exit
    
    JMP notepad_menu_loop

write_text:
    LEA DX, text_prompt
    CALL print_string
    
    LEA DI, notepad_buffer
    MOV CX, 200
    CALL read_string
    
    ; Calculate length
    LEA SI, notepad_buffer
    XOR CX, CX
count_len:
    LODSB
    CMP AL, 0
    JE count_done
    INC CL
    JMP count_len
count_done:
    MOV notepad_len, CL
    
    JMP notepad_menu_loop

view_text:
    LEA DX, text_display
    CALL print_string
    
    CMP notepad_len, 0
    JE notepad_empty
    
    LEA SI, notepad_buffer
    CALL print_asciiz
    
    LEA DX, newline
    CALL print_string
    JMP notepad_menu_loop

notepad_empty:
    LEA DX, empty_notepad
    CALL print_string
    JMP notepad_menu_loop

clear_text:
    ; Clear notepad buffer
    LEA DI, notepad_buffer
    MOV CX, 200
    XOR AL, AL
    REP STOSB
    MOV notepad_len, 0
    
    LEA DX, text_cleared
    CALL print_string
    JMP notepad_menu_loop

notepad_exit:
    POP DI
    POP SI
    POP DX
    POP CX
    POP BX
    POP AX
    RET
notepad ENDP

; ============================================================================
; TASK MANAGER - view running modules
; ============================================================================
task_manager PROC
    PUSH AX
    PUSH DX
    
    LEA DX, task_header
    CALL print_string
    
    LEA DX, task_login
    CALL print_string
    
    LEA DX, task_file
    CALL print_string
    
    LEA DX, task_calc
    CALL print_string
    
    LEA DX, task_notepad
    CALL print_string
    
    LEA DX, task_taskmgr
    CALL print_string
    
    LEA DX, task_cmdline
    CALL print_string
    
    LEA DX, task_history
    CALL print_string
    
    LEA DX, task_clock
    CALL print_string
    
    LEA DX, task_footer
    CALL print_string
    
    ; Wait for keypress
    CALL read_char
    
    POP DX
    POP AX
    RET
task_manager ENDP

; ============================================================================
; COMMAND LINE MODE
; ============================================================================
command_line PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH SI
    PUSH DI

cmd_loop:
    LEA DX, cmd_prompt
    CALL print_string
    
    ; Read command
    LEA DI, cmd_buffer
    MOV CX, 49
    CALL read_string
    
    ; Add to history
    LEA SI, cmd_buffer
    CALL add_to_history
    
    ; Parse command
    LEA SI, cmd_buffer
    
    ; Check for 'exit'
    LEA DI, exit_cmd
    CALL compare_cmd
    CMP AL, 0
    JE cmd_done
    
    ; Check for 'help'
    LEA DI, help_cmd
    CALL compare_cmd
    CMP AL, 0
    JE cmd_do_help
    
    ; Check for 'clear'
    LEA DI, clear_cmd
    CALL compare_cmd
    CMP AL, 0
    JE cmd_do_clear
    
    ; Check for 'time'
    LEA DI, time_cmd
    CALL compare_cmd
    CMP AL, 0
    JE cmd_do_time
    
    ; Check for 'files'
    LEA DI, files_cmd
    CALL compare_cmd
    CMP AL, 0
    JE cmd_do_files
    
    ; Check for 'ver'
    LEA DI, ver_cmd
    CALL compare_cmd
    CMP AL, 0
    JE cmd_do_ver
    
    ; Check for 'history'
    LEA DI, hist_cmd
    CALL compare_cmd
    CMP AL, 0
    JE cmd_do_hist
    
    ; Unknown command
    LEA DX, cmd_unknown
    CALL print_string
    JMP cmd_loop

cmd_do_help:
    LEA DX, cmd_help
    CALL print_string
    JMP cmd_loop

cmd_do_clear:
    CALL clear_screen
    JMP cmd_loop

cmd_do_time:
    CALL display_time
    JMP cmd_loop

cmd_do_files:
    LEA DX, file_list_hdr
    CALL print_string
    
    CMP file_count, 0
    JE cmd_no_files
    
    XOR CX, CX
cmd_list_loop:
    CMP CL, file_count
    JGE cmd_loop
    
    MOV AL, CL
    PUSH CX
    MOV BL, FILE_NAME_LEN
    MUL BL
    LEA SI, file_storage
    ADD SI, AX
    
    CALL print_asciiz
    LEA DX, newline
    CALL print_string
    
    POP CX
    INC CL
    JMP cmd_list_loop

cmd_no_files:
    LEA DX, no_files_msg
    CALL print_string
    JMP cmd_loop

cmd_do_ver:
    LEA DX, cmd_version
    CALL print_string
    JMP cmd_loop

cmd_do_hist:
    CALL show_history
    JMP cmd_loop

cmd_done:
    POP DI
    POP SI
    POP DX
    POP CX
    POP BX
    POP AX
    RET

; Command strings
exit_cmd    DB 'exit', 0
help_cmd    DB 'help', 0
clear_cmd   DB 'clear', 0
time_cmd    DB 'time', 0
files_cmd   DB 'files', 0
ver_cmd     DB 'ver', 0
hist_cmd    DB 'history', 0

command_line ENDP

; Compare command (case insensitive first 4 chars)
compare_cmd PROC
    ; SI = user input, DI = command to compare
    PUSH BX
    PUSH CX
    PUSH SI
    PUSH DI
    
    CALL compare_strings
    
    POP DI
    POP SI
    POP CX
    POP BX
    RET
compare_cmd ENDP

; ============================================================================
; HISTORY STACK - view previous commands
; ============================================================================
show_history PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH SI
    
    LEA DX, hist_header
    CALL print_string
    
    CMP history_count, 0
    JE history_empty
    
    XOR CX, CX          ; Index
    
hist_loop:
    CMP CL, history_count
    JGE hist_done
    
    ; Calculate position
    MOV AL, CL
    PUSH CX
    MOV BL, HIST_CMD_LEN
    MUL BL
    LEA SI, history_storage
    ADD SI, AX
    
    ; Print index
    POP CX
    PUSH CX
    MOV AL, CL
    ADD AL, '1'
    MOV AH, 02h
    MOV DL, AL
    INT 21h
    MOV DL, '.'
    INT 21h
    MOV DL, ' '
    INT 21h
    
    ; Print command
    CALL print_asciiz
    
    LEA DX, newline
    CALL print_string
    
    POP CX
    INC CL
    JMP hist_loop

history_empty:
    LEA DX, hist_empty
    CALL print_string
    JMP hist_footer_print

hist_done:
hist_footer_print:
    LEA DX, hist_footer
    CALL print_string
    
    CALL read_char
    
    POP SI
    POP DX
    POP CX
    POP BX
    POP AX
    RET
show_history ENDP

; Add command to history
add_to_history PROC
    ; SI = command string to add
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH SI
    PUSH DI
    
    ; Check if history is full (circular buffer)
    MOV AL, history_count
    CMP AL, MAX_HISTORY
    JGE shift_history
    
    ; Calculate position for new command
    MOV BL, HIST_CMD_LEN
    MUL BL
    LEA DI, history_storage
    ADD DI, AX
    
    ; Copy command
    MOV CX, HIST_CMD_LEN - 1
copy_hist:
    LODSB
    CMP AL, 0
    JE pad_hist
    STOSB
    LOOP copy_hist
    
pad_hist:
    XOR AL, AL
    STOSB               ; Null terminate
    
    INC history_count
    JMP hist_add_done

shift_history:
    ; Shift all history entries up (remove oldest)
    LEA DI, history_storage
    LEA SI, history_storage
    ADD SI, HIST_CMD_LEN
    
    MOV CX, (MAX_HISTORY - 1) * HIST_CMD_LEN
    REP MOVSB
    
    ; Add new command at end
    POP SI
    PUSH SI
    LEA DI, history_storage
    ADD DI, (MAX_HISTORY - 1) * HIST_CMD_LEN
    
    MOV CX, HIST_CMD_LEN - 1
copy_new:
    LODSB
    CMP AL, 0
    JE pad_new
    STOSB
    LOOP copy_new
    
pad_new:
    XOR AL, AL
    STOSB

hist_add_done:
    POP DI
    POP SI
    POP DX
    POP CX
    POP BX
    POP AX
    RET
add_to_history ENDP

; ============================================================================
; SYSTEM CLOCK DISPLAY
; ============================================================================
system_clock PROC
    PUSH AX
    PUSH DX
    
    LEA DX, clock_header
    CALL print_string
    
    CALL display_time
    
    LEA DX, clock_footer
    CALL print_string
    
    CALL read_char
    
    POP DX
    POP AX
    RET
system_clock ENDP

; Display current system time
display_time PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    
    ; Get system time
    MOV AH, 2Ch
    INT 21h
    ; CH = hours, CL = minutes, DH = seconds
    
    ; Display hours
    MOV AL, CH
    CALL print_two_digits
    
    LEA DX, colon
    CALL print_string
    
    ; Display minutes
    MOV AL, CL
    CALL print_two_digits
    
    LEA DX, colon
    CALL print_string
    
    ; Display seconds
    MOV AL, DH
    CALL print_two_digits
    
    LEA DX, newline
    CALL print_string
    
    POP DX
    POP CX
    POP BX
    POP AX
    RET
display_time ENDP

; Print two-digit number
print_two_digits PROC
    ; AL = number to print (0-99)
    PUSH AX
    PUSH BX
    PUSH DX
    
    ; Save ones digit
    XOR AH, AH
    MOV BL, 10
    DIV BL              ; AL = tens, AH = ones
    
    ; Save ones digit in BL
    MOV BL, AH
    
    ; Print tens digit
    ADD AL, '0'
    MOV DL, AL
    MOV AH, 02h
    INT 21h
    
    ; Print ones digit
    MOV DL, BL
    ADD DL, '0'
    MOV AH, 02h
    INT 21h
    
    POP DX
    POP BX
    POP AX
    RET
print_two_digits ENDP

; ============================================================================
; UTILITY PROCEDURES
; ============================================================================

; Clear screen
clear_screen PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    
    MOV AX, 0600h       ; Scroll up function
    MOV BH, 07h         ; Normal attribute
    XOR CX, CX          ; Upper left corner
    MOV DX, 184Fh       ; Lower right corner
    INT 10h
    
    ; Set cursor to top-left
    MOV AH, 02h
    XOR BH, BH
    XOR DX, DX
    INT 10h
    
    POP DX
    POP CX
    POP BX
    POP AX
    RET
clear_screen ENDP

; Print string (DX = address of $-terminated string)
print_string PROC
    PUSH AX
    MOV AH, 09h
    INT 21h
    POP AX
    RET
print_string ENDP

; Print null-terminated string (SI = address)
print_asciiz PROC
    PUSH AX
    PUSH DX
    PUSH SI
    
print_loop:
    LODSB
    CMP AL, 0
    JE print_asciiz_done
    MOV AH, 02h
    MOV DL, AL
    INT 21h
    JMP print_loop
    
print_asciiz_done:
    POP SI
    POP DX
    POP AX
    RET
print_asciiz ENDP

; Read single character
read_char PROC
    MOV AH, 01h
    INT 21h
    RET
read_char ENDP

; Read string into buffer (DI = buffer, CX = max length)
read_string PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    
    XOR BX, BX          ; Character count

read_str_loop:
    MOV AH, 01h
    INT 21h
    
    ; Check for Enter
    CMP AL, 13
    JE read_str_done
    
    ; Check for Backspace
    CMP AL, 8
    JE str_backspace
    
    ; Check if buffer full
    CMP BX, CX
    JGE read_str_loop
    
    ; Store character
    MOV [DI+BX], AL
    INC BX
    JMP read_str_loop

str_backspace:
    CMP BX, 0
    JE read_str_loop
    
    DEC BX
    MOV BYTE PTR [DI+BX], 0
    
    ; Erase on screen
    MOV AH, 02h
    MOV DL, ' '
    INT 21h
    MOV DL, 8
    INT 21h
    
    JMP read_str_loop

read_str_done:
    MOV BYTE PTR [DI+BX], 0  ; Null terminate
    
    POP DX
    POP CX
    POP BX
    POP AX
    RET
read_string ENDP

; Compare two null-terminated strings
; SI = string1, DI = string2
; Returns AL = 0 if equal, AL = 1 if different
compare_strings PROC
    PUSH BX
    PUSH CX
    PUSH SI
    PUSH DI
    
compare_loop:
    MOV AL, [SI]
    MOV BL, [DI]
    
    CMP AL, BL
    JNE not_equal
    
    CMP AL, 0
    JE strings_equal
    
    INC SI
    INC DI
    JMP compare_loop

strings_equal:
    XOR AL, AL
    JMP compare_done

not_equal:
    MOV AL, 1

compare_done:
    POP DI
    POP SI
    POP CX
    POP BX
    RET
compare_strings ENDP

; Read a number from input
read_number PROC
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH SI
    
    XOR BX, BX          ; Result
    XOR CX, CX          ; Digit count
    MOV SI, 1           ; Sign (1 = positive)
    
read_num_loop:
    MOV AH, 01h
    INT 21h
    
    ; Check for Enter
    CMP AL, 13
    JE num_done
    
    ; Check for minus sign
    CMP AL, '-'
    JNE not_minus
    CMP CX, 0           ; Only at beginning
    JNE read_num_loop
    NEG SI
    JMP read_num_loop

not_minus:
    ; Check if digit
    CMP AL, '0'
    JB read_num_loop
    CMP AL, '9'
    JA read_num_loop
    
    ; Convert and add
    SUB AL, '0'
    XOR AH, AH
    
    ; BX = BX * 10 + AL
    PUSH AX
    MOV AX, BX
    MOV DX, 10
    MUL DX
    MOV BX, AX
    POP AX
    ADD BX, AX
    
    INC CX
    JMP read_num_loop

num_done:
    MOV AX, BX
    CMP SI, 0
    JGE num_positive
    NEG AX

num_positive:
    POP SI
    POP DX
    POP CX
    POP BX
    RET
read_number ENDP

; Print unsigned number in AX
print_number PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    
    ; Check if negative (signed)
    TEST AX, 8000h
    JZ positive_num
    
    ; Print minus sign
    PUSH AX
    MOV AH, 02h
    MOV DL, '-'
    INT 21h
    POP AX
    NEG AX

positive_num:
    XOR CX, CX          ; Digit count
    MOV BX, 10

divide_loop:
    XOR DX, DX
    DIV BX
    PUSH DX             ; Save remainder
    INC CX
    CMP AX, 0
    JNE divide_loop

print_digits:
    POP DX
    ADD DL, '0'
    MOV AH, 02h
    INT 21h
    LOOP print_digits
    
    POP DX
    POP CX
    POP BX
    POP AX
    RET
print_number ENDP

END MAIN
