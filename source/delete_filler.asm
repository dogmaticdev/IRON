section .data
align 16
    words1 db 0x61, 0x73, 0x61, 0x74, 0x62, 0x79, 0x69, 0x73, 0x6F, 0x66, 0x6F, 0x72, 0x74, 0x6F, 0x69, 0x6E
 ;            as          at         by           is          of          or          to          in
    words2 db 0x61, 0x6E, 0x64, 0x00, 0x66, 0x6F, 0x72, 0x00, 0x68, 0x61, 0x73, 0x00, 0x74, 0x68, 0x65, 0x00
 ;            and                     for                     has                     the
    words3 db 0x66, 0x72, 0x6F, 0x6D, 0x69, 0x6E, 0x74, 0x6F, 0x74, 0x68, 0x61, 0x6E, 0x77, 0x69, 0x74, 0x68
 ;            from                    into                    than                    with
    halfmask0: db 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff
    halfmask1: db 0x00, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff
    halfmask2: db 0x00, 0x00, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff
    halfmask3: db 0x00, 0x00, 0x00, 0xff, 0xff, 0xff, 0xff, 0xff
    halfmask4: db 0x00, 0x00, 0x00, 0x00, 0xff, 0xff, 0xff, 0xff
    halfmask5: db 0x00, 0x00, 0x00, 0x00, 0x00, 0xff, 0xff, 0xff
    halfmask6: db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xff, 0xff
    halfmask7: db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xff
    halfmask8: db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
    extern input_pointer
    extern input_size
section .text
    global delete_filler

delete_filler:
;61 a 62 b
;63 c 64 d
;65 e 66 f
;67 g 68 h
;69 i 6A j
;6B k 6C l
;6D m 6E n 
;6F o 70 p 
;71 q 72 r
;73 s 74 t
;75 u 76 v
;77 w 78 x
;79 y 7A z
    movdqa xmm15, [words1] ;0x64, 0x6F, 0x65, 0x73
    movdqa xmm14, [words2]
    movdqa xmm13, [words3]
    lea rsi, [rel jump_table]
    mov r15, [halfmask2]
    mov r14, [halfmask3]
    mov r13, [halfmask4]
    mov r8, [input_pointer]
    add r8, [input_size]
    add r8, 16
    mov r9, [input_pointer]
    mov r10, [input_pointer]
    add r10, [input_size]
    xor ecx, ecx
main_loop:
    cmp r9, r10
    jae end
    movdqu xmm1, [r9]
    pxor xmm0, xmm0
    pcmpeqb xmm0, xmm1
    pmovmskb eax, xmm0
    tzcnt cx, ax
    jc full
    cmp cx, 5 ;cx is string length
    jae skip
    cmp cx, 2
    jb skip
    pextrd eax, xmm1, 0
    mov rbx, rcx
    sub rbx, 2
    jmp [rsi + rbx*8]

two:
    andn rax, r15, rax
    .as:
        pextrw rbx, xmm15, 0
        cmp rax, rbx
        jne .at
        jmp found_2
    .at:
        pextrw rbx, xmm15, 1
        cmp rax, rbx
        jne .by
        jmp found_2
    .by:
        pextrw rbx, xmm15, 2
        cmp rax, rbx
        jne .is
        jmp found_2
    .is:
        pextrw rbx, xmm15, 3
        cmp rax, rbx
        jne .of
        jmp found_2
    .of:
        pextrw rbx, xmm15, 4
        cmp rax, rbx
        jne .or
        jmp found_2
    .or:
        pextrw rbx, xmm15, 5
        cmp rax, rbx
        jne .to
        jmp found_2
    .to:
        pextrw rbx, xmm15, 6
        cmp rax, rbx
        jne .so
        jmp found_2
    .so:
        pextrw rbx, xmm15, 7
        cmp rax, rbx
        jne skip
        jmp found_2
three:
    andn rax, r14, rax
    .and:
        pextrd ebx, xmm14, 0
        cmp rax, rbx
        jne .for
        jmp found_3
    .for:
        pextrd ebx, xmm14, 1
        cmp rax, rbx
        jne .has
        jmp found_3
    .has:
        pextrd ebx, xmm14, 2
        cmp rax, rbx
        jne .the
        jmp found_3
    .the:
        pextrd ebx, xmm14, 3
        cmp rax, rbx
        jne skip
        jmp found_3
four:
    andn rax, r13, rax
    .from:
        pextrd ebx, xmm13, 0
        cmp rax, rbx
        jne .into
        jmp found_4
    .into:
        pextrd ebx, xmm13, 1
        cmp rax, rbx
        jne .that
        jmp found_4
    .that:
        pextrd ebx, xmm13, 2
        cmp rax, rbx
        jne .with
        jmp found_4
    .with:
        pextrd ebx, xmm13, 3
        cmp rax, rbx
        jne skip
        jmp found_4
found_2:
    add r9, 3
    jmp main_loop

found_3:
    add r9, 4
    jmp main_loop

found_4:
    add r9, 5
    jmp main_loop

full:
    movdqu [r8], xmm1
    add r8, 16
    add r9, 16
    movdqu xmm1, [r9]
    pxor xmm0, xmm0
    pcmpeqb xmm0, xmm1
    pmovmskb eax, xmm0
    tzcnt cx, ax
    jc full
    jmp skip

skip:
    movdqu [r8], xmm1
    inc rcx
    add r8, rcx
    add r9, rcx
    jmp main_loop

end:
    pxor xmm1, xmm1
    movdqu [r8], xmm1
    sub r8, [input_pointer]
    sub r8, [input_size]
    sub r8, 16
    mov [input_size], r8
    ret

section .data
    jump_table:
        dq two
        dq three
        dq four
