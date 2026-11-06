;nasm -f elf64 factorize.asm -o factorize.o && ld factorize.o -o factorize
;./factorize instructions.txt instructions.db
BITS 64
section .data
align 16
    ampersands: db 0x26, 0x26, 0x26, 0x26, 0x26, 0x26, 0x26, 0x26, 0x26, 0x26, 0x26, 0x26, 0x26, 0x26, 0x26, 0x26
    dollars:    db 0x24, 0x24, 0x24, 0x24, 0x24, 0x24, 0x24, 0x24, 0x24, 0x24, 0x24, 0x24, 0x24, 0x24, 0x24, 0x24
    zeros:      db 0x30, 0x30, 0x30, 0x30, 0x30, 0x30, 0x30, 0x30, 0x30, 0x30, 0x30, 0x30, 0x30, 0x30, 0x30, 0x30
    nines:      db 0x39, 0x39, 0x39, 0x39, 0x39, 0x39, 0x39, 0x39, 0x39, 0x39, 0x39, 0x39, 0x39, 0x39, 0x39, 0x39
    second_sub: db 0x37, 0x37, 0x37, 0x37, 0x37, 0x37, 0x37, 0x37, 0x37, 0x37, 0x37, 0x37, 0x37, 0x37, 0x37, 0x37
    A:          db 0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40
    F:          db 0x46, 0x46, 0x46, 0x46, 0x46, 0x46, 0x46, 0x46, 0x46, 0x46, 0x46, 0x46, 0x46, 0x46, 0x46, 0x46
    index:      db 0x0F, 0x0D, 0x0B, 0x09, 0x07, 0x05, 0x03, 0x01, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF
extern input_pointer
extern input_size
extern output_pointer
extern output_size
extern bitmask0
section .text
    global factor
factor:
    ; ── Allocate Pointers ────────────────────────────────────────────────────
    mov r15, [input_pointer]  
    mov r14, r15              ;r14 points to the input (first) memory region
    add r15, [input_size]     ;r15 points to the end of the input (first) memory region
    mov r13, [output_pointer] ;r13 points to the ouput (second) memory region

    movdqa xmm15, [ampersands]
    movdqa xmm14, [zeros]
    movdqa xmm13, [nines]
    movdqa xmm12, [A]
    movdqa xmm11, [F]
    movdqa xmm10, [second_sub]
    pxor xmm9, xmm9
    movdqa xmm8, [index]
    movdqa xmm7, [dollars]
    xor rcx, rcx
    xor r12, r12
    .main_loop:
        cmp r14, r15
        jae .grab_offset
        movdqu xmm0, [r14]
        
        movdqa xmm1, xmm0
        movdqa xmm2, xmm0
        pcmpeqb xmm1, xmm15 ;ampersand
        pcmpeqb xmm2, xmm14 ;0s
        por xmm1, xmm2

        pmovmskb eax, xmm1
        tzcnt cx, ax
        jc .next_loop
        ; jz .skip_initial_copy

        movdqu [r13], xmm0
        add r13, rcx
        add r14, rcx

        .route:
            cmp byte [r14-1], 0x00
            jne .invalid_op_code
            cmp byte [r14], 0x26
            je .add_null
        
        .hex_to_int:
            cmp byte [r14+1], 0x78
            jne .invalid_op_code
            add r14, 2
            movdqu xmm0, [r14]
            movdqa xmm1, xmm0

            pcmpeqb xmm1, xmm9 ; Empty Register
            pmovmskb eax, xmm1
            tzcnt cx, ax
            add r14, rcx
            inc r14

            shl rcx, 4
            movdqa xmm2, [bitmask0 + rcx]

            pandn xmm2, xmm0

            movdqa xmm1, xmm2
            movdqa xmm3, xmm2
            movdqa xmm4, xmm2

            pcmpgtb xmm1, xmm11 ; Fs
            pcmpgtb xmm2, xmm12 ; As
            pandn xmm1, xmm2
            pand xmm1, xmm0
            psubusb xmm1, xmm10 ; Second Subtraction

            pcmpgtb xmm3, xmm13 ; Nines
            pcmpgtb xmm4, xmm14 ; Zeros
            pandn xmm3, xmm4
            pand xmm3, xmm0
            psubusb xmm3, xmm14 ; Zeros

            por xmm1, xmm3
            movdqa xmm0, xmm1
            psllw xmm1, 12
            por xmm1, xmm0
            pshufb xmm1, xmm8 ; Index
            
            pextrq rax, xmm1, 0
            shr rcx, 2
            neg rcx
            add rcx, 64
            shr rax, cl

            mov [r13], rax
            add r13, 9
            jmp .main_loop

        .invalid_op_code:
            inc r14
            inc r13
            jmp .main_loop

        .next_loop:
            movdqu [r13], xmm0
            add r13, 16
            add r14, 16
            jmp .main_loop

        .add_null:
            movdqu xmm3, [r14]
            pcmpeqb xmm9, xmm3
            pmovmskb eax, xmm9
            pxor xmm9, xmm9
            tzcnt cx, ax
            movdqu [r13], xmm3
            inc rcx
            add r13, rcx
            add r14, rcx
            cmp rcx, 2
            je .main_loop
            mov [r13], r12
            add r13, 5
            jmp .main_loop

    .grab_offset:
        mov r15, r13
        sub r13, [output_pointer]
        mov [output_size], r13
        mov r14, [output_pointer]
        mov r13, r14

    .find_ampersand:
        cmp r14, r15 ;r14 output read pointer, r15 output end pointer
        jae .end
        movdqu xmm0, [r14]
        movdqa xmm1, xmm0
        pcmpeqb xmm1, xmm15 ; ampersand
        pmovmskb eax, xmm1
        tzcnt cx, ax
        jc .again ; the ampersand was not found in the register. jumps 16 bytes and tries again.
        cmp byte [r14-1], 0x00 ; checks if the label starts with a &
        jne .invalid_label
        cmp byte [r14+1], 0x00 ; checks if the label has atleast one character
        je  .short_label
        add r14, rcx
        movdqu xmm0, [r14]

        .store_label:
            movdqa xmm1, xmm0
            pcmpeqb xmm1, xmm9
            pmovmskb eax, xmm1 
            tzcnt cx, ax
            jc .full_register
            cmp rcx, 1
            je .empty_register

            mov rbx, rcx
            mov r12, rbx ; r12 is the string length
            inc r12 ; accounts for the null byte

            shl rbx, 4
            
            movdqa xmm1, xmm0
            movdqa xmm0, [bitmask0 + rbx] ; erases the unnecessary info
            pandn xmm0, xmm1 
            jmp .skip2

        .again:
            add r14, 16
            jmp .find_ampersand

        .invalid_label:
            inc r14
            jmp .find_ampersand
        
        .short_label:
            add r14, 2
            jmp .find_ampersand

        .full_register:
            mov rbx, 16
            mov r12, rbx ; r12 is the string length
            inc r12 ; accounts for the null byte
            movdqa xmm0, xmm1
            jmp .skip2

        .empty_register:
            add r14, 2
            jmp .find_ampersand

        .skip2:
            mov r13, r14 ; r13 stores the jump value pointer
            add r14, r12 ; r14 points to the jump value
            add r14, 5   ; r14 reads ahead for the jump endpoint
            mov eax, 0x24 ; $
            pinsrb xmm0, eax, 0 ;$ changes the & to a $

        .find_dollar:
            cmp r14, r15
            jae .lost
            movdqu xmm1, [r14]

            movdqa xmm2, xmm1
            pcmpeqb xmm2, xmm7 ; dollars
            pmovmskb eax, xmm2
            tzcnt cx, ax
            jc .dollar_again
            jz .dollar_skip
            add r14, rcx
            movdqu xmm1, [r14]

            .dollar_skip: ; Make sure xmm9 is always empty
                movdqa xmm2, xmm1
                pcmpeqb xmm2, xmm0 ; initial label
                pmovmskb eax, xmm2
                not ax
                tzcnt cx, ax

                cmp rcx, r12
                jae .found
                
                movdqa xmm2, xmm1
                pcmpeqb xmm2, xmm9
                pmovmskb eax, xmm2
                tzcnt cx, ax
                add r14, rcx
                jmp .find_dollar

            .found:
                sub r14, r13
                add r13, r12
                mov [r13], r14d
                add r13, 5
                mov r14, r13
                jmp .find_ampersand

            .dollar_again:
                add r14, 16
                jmp .find_dollar

            .dollar_zero:
                add r14, 5
                jmp .find_dollar

            .lost:
                add r13, 5
                mov r14, r13
                jmp .find_ampersand

    .end:
        ret
