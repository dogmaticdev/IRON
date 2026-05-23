;nasm -f elf64 factorize.asm -o factorize.o && ld factorize.o -o factorize
;./factorize instructions.txt instructions.db
BITS 64
section .data
align 16
    ampersands: db 0x26, 0x26, 0x26, 0x26, 0x26, 0x26, 0x26, 0x26, 0x26, 0x26, 0x26, 0x26, 0x26, 0x26, 0x26, 0x26
    colons:     db 0x3A, 0x3A, 0x3A, 0x3A, 0x3A, 0x3A, 0x3A, 0x3A, 0x3A, 0x3A, 0x3A, 0x3A, 0x3A, 0x3A, 0x3A, 0x3A
    semicolons: db 0x3B, 0x3B, 0x3B, 0x3B, 0x3B, 0x3B, 0x3B, 0x3B, 0x3B, 0x3B, 0x3B, 0x3B, 0x3B, 0x3B, 0x3B, 0x3B
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
    mov r14, r15
    add r15, [input_size]
    mov r13, [output_pointer]

    movdqa xmm15, [ampersands]
    movdqa xmm12, [semicolons]
    movdqa xmm11, [colons]
    pxor xmm10, xmm10
    xor rcx, rcx
    .main_loop:
        cmp r14, r15
        jae .second_part
        movdqu xmm0, [r14]
        mov rbx, 1
        xor rdx, rdx

    .check_ampersand:
        movdqa xmm1, xmm0
        pcmpeqb xmm1, xmm15
        pmovmskb eax, xmm1
        tzcnt cx, ax
        jc .check_colons
        jz .add_null_skip
        mov rdx, rcx
        xor rbx, rbx

    .check_colons:
        movdqa xmm1, xmm0
        pcmpeqb xmm1, xmm11
        pmovmskb eax, xmm1
        tzcnt cx, ax
        jc .route
        jz .add_null_skip
        mov rdx, rcx
        xor rbx, rbx

    .route:
        movdqu [r13], xmm0
        cmp rbx, 1
        jne .add_null
        add r13, 16
        add r14, 16
        jmp .main_loop

    .add_null:
        add r13, rdx
        add r14, rdx
    .add_null_skip:
        call string_copy
        pxor xmm14, xmm14
        movdqu [r13], xmm14
        add r13, 5
        jmp .main_loop

    .second_part:
        mov r15, r13
        sub r13, [output_pointer]
        mov [output_size], r13
        mov r14, [output_pointer]
        mov r13, r14

    .second_loop:
        cmp r14, r15
        jae .end
        movdqu xmm0, [r14]
        mov rbx, 2
        xor rdx, rdx

    .scan_ampersand:
        movdqa xmm1, xmm0
        pcmpeqb xmm1, xmm15
        pmovmskb eax, xmm1
        tzcnt cx, ax
        jc .scan_semicolon
        jz .ampersand_offset_zero
        mov rdx, rcx
        xor rbx, rbx

    .scan_semicolon:
        movdqa xmm1, xmm0
        pcmpeqb xmm1, xmm12
        pmovmskb eax, xmm1
        tzcnt cx, ax
        jc .second_route
        jz .semicolon_offset_zero
        mov rax, 1
        cmp rdx, rcx
        cmova rdx, rcx
        cmova rbx, rax

    .second_route:
        cmp rbx, 1
        jb .ampersand_offset
        je .semicolon_offset
        add r14, 16
        jmp .second_loop

    .ampersand_offset:
        add r14, rdx

    .ampersand_offset_zero:
        movdqu xmm1, [r14]
        call isolate_string
        movdqa xmm0, xmm1
        mov rax, 0x24
        pinsrb xmm0, eax, 0
        call skip_string
        mov r13, r14
        add r14, 5 ;skips the 4 byte address.

    .ampersand_loop:
        cmp r14, r15
        jae .ampersand_lost
        mov al, [r14]
        cmp al, 0x26 ; &
        je .ampersand_skip
        cmp al, 0x3A ; :
        je .ampersand_skip
        cmp al, 0x24 ; $
        jne .ampersand_small_skip
        movdqu xmm1, [r14]
        call isolate_string
        call compare
        jnc .ampersand_small_skip
        call skip_string
        sub r14, r13
        mov [r13], r14d
        add r13, 5
        mov r14, r13
        jmp .second_loop

    .ampersand_lost:
        add r13, 5
        mov r14, r13
        jmp .second_loop

    .ampersand_skip:
        call skip_string
        add r14, 5
        jmp .ampersand_loop

    .ampersand_small_skip:
        call skip_string
        jmp .ampersand_loop

    .semicolon_offset:
        add r14, rdx

    .semicolon_offset_zero:
        movdqu xmm1, [r14]
        call isolate_string
        movdqa xmm0, xmm1
        mov rax, 0x3A ; :
        pinsrb xmm0, eax, 0
        call skip_string
        mov r13, r14

    .semicolon_loop:
        cmp r14, r15
        jae .semicolon_lost
        mov al, [r14]
        cmp al, 0x26 ; &
        je .semicolon_skip
        cmp al, 0x3A ; :
        jne .semicolon_small_skip
        movdqu xmm1, [r14]
        call isolate_string
        call compare
        jnc .semicolon_skip
        call skip_string
        mov r12, r14
        sub r12, r13
        mov [r14], r12d
        add r14, 5
        jmp .semicolon_loop

    .semicolon_lost:
        mov r14, r13
        jmp .second_loop

    .semicolon_skip:
        call skip_string
        add r14, 5
        jmp .semicolon_loop

    .semicolon_small_skip:
        call skip_string
        jmp .semicolon_loop

    .end:
        ret

isolate_string:
    movdqa xmm14, xmm1
    pxor xmm1, xmm1
    pcmpeqb xmm1, xmm14
    pmovmskb eax, xmm1
    tzcnt cx, ax
    jc .end
    jz .end
    shl ecx, 4
    movdqa xmm1, [bitmask0 + rcx]
    pandn xmm1, xmm14
.end:
    ret

string_copy:
    pxor xmm14, xmm14
    movdqu xmm13, [r14]
    pcmpeqb xmm14, xmm13
    pmovmskb eax, xmm14
    tzcnt cx, ax
    jc .next_string
    jz .end
    movdqu [r13], xmm13

.end:
    inc rcx
    add r13, rcx
    add r14, rcx
    ret

.next_string:
    movdqu [r13], xmm13
    add r14, 16
    add r13, 16
    jmp string_copy

skip_string: ; +
    movdqu xmm13, [r14]
    pcmpeqb xmm13, xmm10
    pmovmskb eax, xmm13
    tzcnt cx, ax
    jc .next_string

    inc rcx
    add r14, rcx
    ret

.next_string:
    add r14, 16
    jmp skip_string

compare:
    pcmpeqb xmm1, xmm0
    pmovmskb eax, xmm1
    not eax
    tzcnt cx, ax
    ret
