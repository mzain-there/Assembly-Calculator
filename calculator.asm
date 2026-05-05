; ============================================================
; SCIENTIFIC CALCULATOR - 8086 Assembly Language
; For use with emu8086
; 
; Features:
;   - Addition, Subtraction, Multiplication, Division
;   - Square Root (integer approximation)
;   - Power (base^exponent, integer)
;   - Factorial (n!)
;   - Modulus (remainder)
;   - Display menu and results
; ============================================================

.MODEL SMALL
.STACK 100H

.DATA
    ; ---- Strings ----
    clrscr_msg  DB 27,'[2J',27,'[H','$'   ; ANSI clear screen (may not work in all emu8086)

    title_msg   DB  13,10
                DB  "  ============================================",13,10
                DB  "       SCIENTIFIC CALCULATOR (8086 ASM)      ",13,10
                DB  "  ============================================",13,10,'$'

    menu_msg    DB  13,10
                DB  "  [1] Addition          (A + B)",13,10
                DB  "  [2] Subtraction       (A - B)",13,10
                DB  "  [3] Multiplication    (A * B)",13,10
                DB  "  [4] Division          (A / B)",13,10
                DB  "  [5] Modulus           (A MOD B)",13,10
                DB  "  [6] Power             (A ^ B)",13,10
                DB  "  [7] Factorial         (A!)",13,10
                DB  "  [8] Square Root       (sqrt A)",13,10
                DB  "  [9] Exit",13,10
                DB  13,10
                DB  "  Enter choice: ",'$'

    prompt_a    DB  13,10,"  Enter A: ",'$'
    prompt_b    DB  13,10,"  Enter B: ",'$'
    result_msg  DB  13,10,"  Result  = ",'$'
    newline     DB  13,10,'$'
    divzero_msg DB  13,10,"  ERROR: Division by zero!",13,10,'$'
    overflow_msg DB 13,10,"  ERROR: Result overflow!",13,10,'$'
    neg_msg     DB  13,10,"  ERROR: Negative input not allowed!",13,10,'$'
    bye_msg     DB  13,10,"  Thank you for using Sci-Calc. Goodbye!",13,10,'$'
    invalid_msg DB  13,10,"  Invalid choice. Try again.",13,10,'$'
    cont_msg    DB  13,10,"  Press any key to continue...",'$'

    ; Variables
    numA        DW  0
    numB        DW  0
    result      DW  0
    result_hi   DW  0          ; high word for multiply

.CODE
MAIN PROC
    MOV AX, @DATA
    MOV DS, AX

    ; Print title
    LEA DX, title_msg
    CALL print_str

MENU_LOOP:
    ; Print menu
    LEA DX, menu_msg
    CALL print_str

    ; Read single char choice
    MOV AH, 01H
    INT 21H                    ; AL = character pressed

    ; Print newline after choice
    LEA DX, newline
    CALL print_str

    CMP AL, '1'
    JE  DO_ADD
    CMP AL, '2'
    JE  DO_SUB
    CMP AL, '3'
    JE  DO_MUL
    CMP AL, '4'
    JE  DO_DIV
    CMP AL, '5'
    JE  DO_MOD
    CMP AL, '6'
    JE  DO_POW
    CMP AL, '7'
    JE  DO_FACT
    CMP AL, '8'
    JE  DO_SQRT
    CMP AL, '9'
    JE  DO_EXIT

    ; Invalid choice
    LEA DX, invalid_msg
    CALL print_str
    JMP CONT

; ---- Addition ----
DO_ADD:
    CALL read_A
    CALL read_B
    MOV AX, numA
    ADD AX, numB
    MOV result, AX
    CALL print_result
    JMP CONT

; ---- Subtraction ----
DO_SUB:
    CALL read_A
    CALL read_B
    MOV AX, numA
    SUB AX, numB
    MOV result, AX
    CALL print_result
    JMP CONT

; ---- Multiplication ----
DO_MUL:
    CALL read_A
    CALL read_B
    MOV AX, numA
    MOV BX, numB
    MUL BX                     ; DX:AX = AX * BX (unsigned)
    MOV result, AX
    MOV result_hi, DX
    ; Print result (handle large number)
    LEA DX, result_msg
    CALL print_str
    ; If DX != 0, print high word too
    MOV AX, result_hi
    CMP AX, 0
    JE  MUL_LOW_ONLY
    CALL print_num             ; print high word
    MOV AX, result
    CALL print_low_word        ; print low 4 digits
    JMP CONT
MUL_LOW_ONLY:
    MOV AX, result
    CALL print_num
    JMP CONT

; ---- Division ----
DO_DIV:
    CALL read_A
    CALL read_B
    MOV BX, numB
    CMP BX, 0
    JE  DIV_ZERO_ERR
    MOV AX, numA
    MOV DX, 0
    DIV BX                     ; AX = quotient, DX = remainder
    MOV result, AX
    CALL print_result
    JMP CONT
DIV_ZERO_ERR:
    LEA DX, divzero_msg
    CALL print_str
    JMP CONT

; ---- Modulus ----
DO_MOD:
    CALL read_A
    CALL read_B
    MOV BX, numB
    CMP BX, 0
    JE  MOD_ZERO_ERR
    MOV AX, numA
    MOV DX, 0
    DIV BX                     ; DX = remainder
    MOV result, DX
    CALL print_result
    JMP CONT
MOD_ZERO_ERR:
    LEA DX, divzero_msg
    CALL print_str
    JMP CONT

; ---- Power (A^B) ----
DO_POW:
    CALL read_A
    CALL read_B
    MOV CX, numB               ; exponent in CX
    MOV AX, 1                  ; result starts at 1
    CMP CX, 0
    JE  POW_DONE               ; A^0 = 1
    MOV BX, numA
POW_LOOP:
    MUL BX                     ; AX = AX * BX
    CMP DX, 0                  ; overflow check
    JNE POW_OVERFLOW
    LOOP POW_LOOP
    JMP POW_DONE
POW_OVERFLOW:
    LEA DX, overflow_msg
    CALL print_str
    JMP CONT
POW_DONE:
    MOV result, AX
    CALL print_result
    JMP CONT

; ---- Factorial (A!) ----
DO_FACT:
    CALL read_A
    MOV CX, numA
    CMP CX, 0
    JE  FACT_ZERO
    MOV AX, 1
FACT_LOOP:
    MUL CX                     ; AX = AX * CX
    CMP DX, 0
    JNE FACT_OVERFLOW
    LOOP FACT_LOOP
    MOV result, AX
    CALL print_result
    JMP CONT
FACT_ZERO:
    MOV result, 1              ; 0! = 1
    CALL print_result
    JMP CONT
FACT_OVERFLOW:
    LEA DX, overflow_msg
    CALL print_str
    JMP CONT

; ---- Square Root (integer, Newton's method approx) ----
DO_SQRT:
    CALL read_A
    MOV AX, numA
    CMP AX, 0
    JE  SQRT_ZERO
    ; Simple method: count up until i*i > AX
    MOV CX, 0                  ; i = 0
SQRT_LOOP:
    INC CX
    MOV BX, CX
    IMUL BX                    ; DX:AX = CX * CX  (uses AX as input)
    ; BUG FIX: reload AX = numA before compare
    MOV BX, AX                 ; save CX^2 in BX (low word)
    MOV AX, numA
    CMP BX, AX
    JA  SQRT_FOUND             ; CX^2 > numA => answer is CX-1
    JE  SQRT_EXACT             ; exact
    MOV AX, numA               ; restore AX for next IMUL
    JMP SQRT_LOOP
SQRT_EXACT:
    MOV result, CX
    JMP SQRT_PRINT
SQRT_FOUND:
    DEC CX
    MOV result, CX
SQRT_PRINT:
    CALL print_result
    JMP CONT
SQRT_ZERO:
    MOV result, 0
    CALL print_result
    JMP CONT

DO_EXIT:
    LEA DX, bye_msg
    CALL print_str
    MOV AH, 4CH
    INT 21H

CONT:
    LEA DX, cont_msg
    CALL print_str
    MOV AH, 01H
    INT 21H                    ; wait for key
    LEA DX, newline
    CALL print_str
    JMP MENU_LOOP

MAIN ENDP

; ============================================================
; PROCEDURE: read_A
; Reads a decimal number from keyboard into numA
; ============================================================
read_A PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    LEA DX, prompt_a
    CALL print_str
    CALL read_num
    MOV numA, AX
    POP DX
    POP CX
    POP BX
    POP AX
    RET
read_A ENDP

; ============================================================
; PROCEDURE: read_B
; Reads a decimal number from keyboard into numB
; ============================================================
read_B PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    LEA DX, prompt_b
    CALL print_str
    CALL read_num
    MOV numB, AX
    POP DX
    POP CX
    POP BX
    POP AX
    RET
read_B ENDP

; ============================================================
; PROCEDURE: read_num
; Reads decimal digits from keyboard, returns value in AX
; Stops on Enter (CR = 0Dh)
; ============================================================
read_num PROC
    PUSH BX
    PUSH CX
    PUSH DX
    MOV BX, 0                  ; accumulator
READ_DIGIT:
    MOV AH, 01H
    INT 21H                    ; read char into AL
    CMP AL, 0DH                ; Enter?
    JE  READ_DONE
    CMP AL, '0'
    JB  READ_DIGIT             ; ignore non-digit
    CMP AL, '9'
    JA  READ_DIGIT
    SUB AL, '0'                ; convert ASCII to digit
    MOV CL, AL
    MOV AX, BX
    MOV DX, 10
    MUL DX                     ; AX = BX * 10
    MOV BX, AX
    MOV AL, CL
    MOV AH, 0
    ADD BX, AX
    JMP READ_DIGIT
READ_DONE:
    MOV AX, BX
    POP DX
    POP CX
    POP BX
    RET
read_num ENDP

; ============================================================
; PROCEDURE: print_result
; Prints result_msg then the value in [result]
; ============================================================
print_result PROC
    PUSH AX
    PUSH DX
    LEA DX, result_msg
    CALL print_str
    MOV AX, result
    CALL print_num
    POP DX
    POP AX
    RET
print_result ENDP

; ============================================================
; PROCEDURE: print_num
; Prints unsigned word in AX as decimal
; ============================================================
print_num PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    MOV BX, 10
    MOV CX, 0                  ; digit count
PNUM_LOOP:
    MOV DX, 0
    DIV BX                     ; AX = quotient, DX = remainder
    PUSH DX                    ; push digit (0-9)
    INC CX
    CMP AX, 0
    JNE PNUM_LOOP
PNUM_PRINT:
    POP DX
    ADD DL, '0'
    MOV AH, 02H
    INT 21H
    LOOP PNUM_PRINT
    POP DX
    POP CX
    POP BX
    POP AX
    RET
print_num ENDP

; ============================================================
; PROCEDURE: print_low_word
; Prints AX as exactly 5 zero-padded decimal digits (for
; the low 16-bit part after a large multiply)
; ============================================================
print_low_word PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    MOV BX, 10
    MOV CX, 5
    ; We print exactly 5 digits of AX
PL_LOOP:
    MOV DX, 0
    DIV BX
    PUSH DX
    LOOP PL_LOOP
    MOV CX, 5
PL_PRINT:
    POP DX
    ADD DL, '0'
    MOV AH, 02H
    INT 21H
    LOOP PL_PRINT
    POP DX
    POP CX
    POP BX
    POP AX
    RET
print_low_word ENDP

; ============================================================
; PROCEDURE: print_str
; Prints $ terminated string at DS:DX
; ============================================================
print_str PROC
    PUSH AX
    MOV AH, 09H
    INT 21H
    POP AX
    RET
print_str ENDP

END MAIN