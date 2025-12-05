# 8086-MiniOS

A simple Operating System simulation written in 8086 Assembly Language.

## Features

### 1. User Login System
- Secure login with username and password authentication
- **Password masking** - displays asterisks (*) instead of actual characters
- Default credentials: `admin` / `1234`
- Supports backspace for input correction

### 2. File Manager Simulation
- **Create File** - Add new files to the virtual file system (up to 10 files)
- **Delete File** - Remove files by name
- **List Files** - View all stored files
- File names support up to 20 characters

### 3. Calculator (Advanced Arithmetic)
- **Addition** - Add two numbers
- **Subtraction** - Subtract two numbers
- **Multiplication** - Multiply two numbers
- **Division** - Divide with zero-check protection
- **Modulo** - Calculate remainder
- **Power** - Calculate exponentiation (x^y)

### 4. Notepad System
- **Write Text** - Store text up to 200 characters
- **View Text** - Display stored content
- **Clear Text** - Reset notepad buffer
- Text stored in memory array

### 5. Task Manager
- View all active/running modules in the system
- Displays status of all 8 core components:
  - Login System
  - File Manager
  - Calculator
  - Notepad System
  - Task Manager
  - Command Line
  - History Stack
  - System Clock

### 6. Command Line Mode
Interactive shell with the following commands:
- `help` - Display available commands
- `clear` - Clear the screen
- `time` - Show current system time
- `files` - List all stored files
- `ver` - Show version information
- `history` - Display command history
- `exit` - Return to main menu

### 7. History Stack
- Stores up to 10 previous commands
- Circular buffer implementation (oldest commands are replaced when full)
- View history from the Command Line or main menu

### 8. System Clock Display
- Shows current system time (HH:MM:SS format)
- Uses DOS interrupt 21h (function 2Ch) for time retrieval

## Requirements

- 8086/8088 compatible assembler (MASM, TASM, NASM, or EMU8086)
- DOS environment or DOS emulator (DOSBox)

## Building

### Using MASM (Microsoft Assembler)
```bash
masm minios.asm;
link minios.obj;
```

### Using TASM (Turbo Assembler)
```bash
tasm minios.asm
tlink minios.obj
```

### Using EMU8086
1. Open EMU8086
2. Load `minios.asm`
3. Click "Compile" then "Run"

## Running

After compilation, run the executable:
```bash
minios.exe
```

Or use an emulator like DOSBox:
```bash
dosbox -c "mount c ." -c "c:" -c "minios.exe"
```

## Default Credentials

- **Username:** `admin`
- **Password:** `1234`

## Technical Details

- **Memory Model:** SMALL
- **Stack Size:** 256 bytes (100h)
- **File Storage:** 10 files × 20 characters = 200 bytes
- **History Storage:** 10 commands × 30 characters = 300 bytes
- **Notepad Buffer:** 200 characters

## Architecture

The program uses DOS interrupts:
- INT 21h - DOS services (keyboard, display, time)
- INT 10h - BIOS video services (screen control)

## License

This project is open source and available for educational purposes.