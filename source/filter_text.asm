section .data
align 16
    spaces       db 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20 ; " "
    temp         db 0x21, 0x21, 0x21, 0x21, 0x21, 0x21, 0x21, 0x21, 0x21, 0x21, 0x21, 0x21, 0x21, 0x21, 0x21, 0x21 ; " "
    quotes       db 0x22, 0x22, 0x22, 0x22, 0x22, 0x22, 0x22, 0x22, 0x22, 0x22, 0x22, 0x22, 0x22, 0x22, 0x22, 0x22 ; "
    lefts        db 0x5C, 0x5C, 0x5C, 0x5C, 0x5C, 0x5C, 0x5C, 0x5C, 0x5C, 0x5C, 0x5C, 0x5C, 0x5C, 0x5C, 0x5C, 0x5C ; "/"
    rights       db 0x0A, 0x0A, 0x0A, 0x0A, 0x0A, 0x0A, 0x0A, 0x0A, 0x0A, 0x0A, 0x0A, 0x0A, 0x0A, 0x0A, 0x0A, 0x0A ; "/n"
    left_square  db 0x5B, 0x5B, 0x5B, 0x5B, 0x5B, 0x5B, 0x5B, 0x5B, 0x5B, 0x5B, 0x5B, 0x5B, 0x5B, 0x5B, 0x5B, 0x5B ; "["
    right_square db 0x5D, 0x5D, 0x5D, 0x5D, 0x5D, 0x5D, 0x5D, 0x5D, 0x5D, 0x5D, 0x5D, 0x5D, 0x5D, 0x5D, 0x5D, 0x5D ; "]"
    commas       db 0x2C, 0x2C, 0x2C, 0x2C, 0x2C, 0x2C, 0x2C, 0x2C, 0x2C, 0x2C, 0x2C, 0x2C, 0x2C, 0x2C, 0x2C, 0x2C ; ","
    colons       db 0x3A, 0x3A, 0x3A, 0x3A, 0x3A, 0x3A, 0x3A, 0x3A, 0x3A, 0x3A, 0x3A, 0x3A, 0x3A, 0x3A, 0x3A, 0x3A ; ":"
    extern input_pointer
    extern input_size
    extern bitmask0
    extern input_size
section .text
    global filter_text

; turns the spaces within quotes, "" into 0xFF, so that the whitespace remover doesnt delete the spaces.
; removes text within parenthesis and the parenthesis aswell.
; deletes colons
; spaces out commas from the text before it. i.e. "hey," -> "hey ,"
filter_text:
    movdqa xmm15, [quotes]
    %define Quote xmm15

    movdqa xmm14, [lefts]
    %define Left xmm14

    movdqa xmm13, [rights]
    %define Right xmm13

    movdqa xmm12, [spaces]
    %define Space xmm12

    movdqa xmm11, [commas]
    %define Comma xmm11

    movdqa xmm10,  [colons]
    %define Colon xmm10

    movdqa xmm9, [temp]
    %define Temp xmm9

    movdqa xmm8, [left_square]
    %define Left_Square xmm8

    movdqa xmm7, [right_square]
    %define Right_Square xmm7

    lea r12, [rel jump_table]
    %define Jump_Table r12

    mov r13, [input_pointer] ;increase the read pointer by 16 bytes and read the file into memory with an offset of 16 bytes.
    %define Write_Pointer r13

    mov r14, [input_pointer]
    add r14, [input_size]
    %define Read_Pointer r14

    mov r15, [input_pointer]
    add r15, [input_size]
    add r15, [input_size]
    %define End_Pointer r15

    xor rdx, rdx
    xor rbx, rbx
    xor rcx, rcx

    %define String xmm0
    %define Copy xmm1

main_loop:
    cmp Read_Pointer, End_Pointer
    jae end
    movdqu String, [Read_Pointer]
    mov rbx, 5
    mov rdx, 16
    ; i may need to xor rdx here?

.check_quote:
    movdqa Copy, String
    pcmpeqb Copy, Quote
    pmovmskb eax, Copy
    tzcnt cx, ax
    jc .check_comment
    jz zero_quote
    mov rdx, rcx
    mov rbx, 0

.check_comment:
    movdqa Copy, String
    pcmpeqb Copy, Left
    pmovmskb eax, Copy
    tzcnt cx, ax
    jc .check_comma
    jz start_comment
    mov rax, 1
    cmp rdx, rcx
    cmova rdx, rcx
    cmova rbx, rax
    jmp .check_comma

.check_colon:
    movdqa Copy, String
    pcmpeqb Copy, Colon
    pmovmskb eax, Copy
    tzcnt cx, ax
    jc .check_comma
    jz zero_colon
    mov rax, 2
    cmp rdx, rcx
    cmova rdx, rcx
    cmova rbx, rax

.check_comma:
    movdqa Copy, String
    pcmpeqb Copy, Comma
    pmovmskb eax, Copy
    tzcnt cx, ax
    jc .check_square
    jz zero_comma
    mov rax, 3
    cmp rdx, rcx
    cmova rdx, rcx
    cmova rbx, rax

.check_square:
    movdqa Copy, String
    pcmpeqb Copy, Left_Square
    pmovmskb eax, Copy
    tzcnt cx, ax
    jc route
    jz zero_square
    mov rax, 4
    cmp rdx, rcx
    cmova rdx, rcx
    cmova rbx, rax

route:
    cmp rbx, 5
    je skip
    jmp [Jump_Table + rbx*8]

zero_quote:
    movdqu [Write_Pointer], String
    inc Write_Pointer
    inc Read_Pointer
    jmp quote_again

quote_again:
    cmp Read_Pointer, End_Pointer
    jae end
    movdqu String, [Read_Pointer]
    movdqa Copy, String
    pcmpeqb Copy, Quote
    pmovmskb eax, Copy
    tzcnt dx, ax
    jc next_quote
    jmp start_quote

do_quote:
    movdqu [Write_Pointer], String
    inc rdx
    add Write_Pointer, rdx
    add Read_Pointer, rdx
    jmp quote_again

start_quote:
    shl rdx, 4
    movdqa xmm2, [bitmask0 + rdx]
    movdqa Copy, String
    pcmpeqb Copy, Space
    pandn xmm2, Copy
    por String, xmm2

    shr rdx, 4
    inc rdx
    movdqu [Write_Pointer], String
    add Write_Pointer, rdx
    add Read_Pointer, rdx
    jmp main_loop

next_quote:
    movdqa Copy, String
    pcmpeqb Copy, Space
    por String, Copy

find_end_quote:
    movdqu [Write_Pointer], String

    add Write_Pointer, 16
    add Read_Pointer, 16
    jmp quote_again

zero_square:
    movdqu [Write_Pointer], String
    inc Write_Pointer
    inc Read_Pointer
    jmp square_again

square_again:
    cmp Read_Pointer, End_Pointer
    jae end
    movdqu String, [Read_Pointer]
    movdqa Copy, String
    pcmpeqb Copy, Right_Square
    pmovmskb eax, Copy
    tzcnt dx, ax
    jc next_square
    jmp start_square

do_square:
    movdqu [Write_Pointer], String
    inc rdx
    add Write_Pointer, rdx
    add Read_Pointer, rdx
    jmp square_again

start_square:
    shl rdx, 4
    movdqa xmm2, [bitmask0 + rdx]
    movdqa Copy, String
    pcmpeqb Copy, Space
    pandn xmm2, Copy
    por String, xmm2

    shr rdx, 4
    inc rdx
    movdqu [Write_Pointer], String
    add Write_Pointer, rdx
    add Read_Pointer, rdx
    jmp main_loop

next_square:
    movdqa Copy, String
    pcmpeqb Copy, Space
    por String, Copy

find_end_square:
    movdqu [Write_Pointer], String

    add Write_Pointer, 16
    add Read_Pointer, 16
    jmp square_again

comment_again:
    add Read_Pointer, 16
    cmp Read_Pointer, End_Pointer
    jae end
    movdqu String, [Read_Pointer]
    jmp start_comment

do_comment:
    movdqu [Write_Pointer], String
    add Write_Pointer, rdx
    add Read_Pointer, rdx
    inc Read_Pointer
    movdqu String, [Read_Pointer]

start_comment:
    movdqa Copy, String
    pcmpeqb Copy, Right
    pmovmskb eax, Copy

    tzcnt cx, ax
    jc comment_again
    inc cx

    add Read_Pointer, rcx
    jmp main_loop

zero_colon:
    inc Read_Pointer
    jmp main_loop

do_colon:
    movdqa Copy, String
    pcmpeqb Copy, Colon
    pmovmskb eax, Copy
    tzcnt dx, ax

start_colon:
    movdqu [Write_Pointer], String
    add Write_Pointer, rdx
    add Read_Pointer, rdx
    mov [Write_Pointer], byte 0x00
    inc Write_Pointer
    jmp main_loop

zero_comma:
    xor rdx, rdx

start_comma:
    mov eax, 0x00002C00
    movdqu [Write_Pointer], String
    add Write_Pointer, rdx
    add Read_Pointer, rdx
    mov [Write_Pointer], eax
    add Write_Pointer, 3
    inc Read_Pointer
    jmp main_loop

skip:
    movdqu [Write_Pointer], String
    add Write_Pointer, 16
    add Read_Pointer, 16
    jmp main_loop

end:
    pxor xmm0, xmm0
    movdqu [Write_Pointer], xmm0
    sub Write_Pointer, [input_pointer]
    mov [input_size], Write_Pointer
    ret

section .data
align 16
    jump_table:
        dq do_quote
        dq do_comment
        dq do_colon
        dq start_comma
        dq do_square
