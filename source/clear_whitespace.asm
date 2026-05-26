;nasm -f elf64 tokenizer.asm -o tokenizer.o && ld tokenizer.o -o whitespace
;./tokenizer hell.txt output.txt
BITS 64
section .data
align 16

    index0: db 0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0A, 0x0B, 0x0C, 0x0D, 0x0E, 0x0F
    index1: db 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0A, 0x0B, 0x0C, 0x0D, 0x0E, 0x0F, 0xff
    index2: db 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0A, 0x0B, 0x0C, 0x0D, 0x0E, 0x0F, 0xff, 0xff
    index3: db 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0A, 0x0B, 0x0C, 0x0D, 0x0E, 0x0F, 0xff, 0xff, 0xff
    index4: db 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0A, 0x0B, 0x0C, 0x0D, 0x0E, 0x0F, 0xff, 0xff, 0xff, 0xff
    index5: db 0x05, 0x06, 0x07, 0x08, 0x09, 0x0A, 0x0B, 0x0C, 0x0D, 0x0E, 0x0F, 0xff, 0xff, 0xff, 0xff, 0xff
    index6: db 0x06, 0x07, 0x08, 0x09, 0x0A, 0x0B, 0x0C, 0x0D, 0x0E, 0x0F, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff
    index7: db 0x07, 0x08, 0x09, 0x0A, 0x0B, 0x0C, 0x0D, 0x0E, 0x0F, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff
    index8: db 0x08, 0x09, 0x0A, 0x0B, 0x0C, 0x0D, 0x0E, 0x0F, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff
    index9: db 0x09, 0x0A, 0x0B, 0x0C, 0x0D, 0x0E, 0x0F, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff
    indexA: db 0x0A, 0x0B, 0x0C, 0x0D, 0x0E, 0x0F, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff
    indexB: db 0x0B, 0x0C, 0x0D, 0x0E, 0x0F, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff
    indexC: db 0x0C, 0x0D, 0x0E, 0x0F, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff
    indexD: db 0x0D, 0x0E, 0x0F, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff
    indexE: db 0x0E, 0x0F, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff
    indexF: db 0x0F, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff
    sign:   db 0x7F, 0x7F, 0x7F, 0x7F, 0x7F, 0x7F, 0x7F, 0x7F, 0x7F, 0x7F, 0x7F, 0x7F, 0x7F, 0x7F, 0x7F, 0x7F

extern bitmask0
extern input_pointer
extern input_size
extern despace
section .text
    global clear_whitespace

    ;r8 write pointer
    ;r9 read pointer
    ;10 end pointer
    ;rdx string length
    ;rcx count
    ;rax bitmask
    ;rdi offset
    ;rsi bool

clear_whitespace:
    ; ── Allocate Pointers ────────────────────────────────────────────────────
    mov r13, [input_pointer]
    %define Write_Pointer r13

    mov r14, r13
    %define Read_Pointer r14

    mov r15, r13
    add r15, [input_size]
    %define End_Pointer r15

    ; ── Constant Registers ───────────────────────────────────────────────────

    movdqa xmm15, [despace]
    %define Space xmm15

    movdqa xmm14, [index0]
    %define Index0 xmm14

    movdqa xmm13, [sign]
    %define Sign xmm13


    ; ── Variable Registers ───────────────────────────────────────────────────
    ;Example, in String is H e l l o SPACE SPACE W o r l d SPACE SPACE SPACE SPACE

    %define Blend_Mask xmm0
    %define String xmm1
    %define Index xmm2
    %define Temp_Index xmm3
    %define Byte_Mask xmm4
    %define Scratch xmm5

    %define Bool rsi

    xor rcx, rcx
    xor rdx, rdx
    xor rdi, rdi
    xor Bool, Bool
    xor r8, r8
    jmp .main_loop

.clear:
    cmp Bool, 0
    je .main_loop
    mov byte [Write_Pointer], 0x00
    inc Write_Pointer
    xor Bool, Bool

.main_loop:
    cmp Read_Pointer, End_Pointer
    jge .end

    movdqa   String, [Read_Pointer]
    add      Read_Pointer, 16

    pxor     Scratch, Scratch       ; 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
    movdqa   Byte_Mask, String      ; 48 65 6C 6C 6F 20 20 57 6F 72 6C 64 20 20 20 20
    movdqa   Index, String          ; 48 65 6C 6C 6F 20 20 57 6F 72 6C 64 20 20 20 20
    psubusb  Index, Sign            ; 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
    pcmpgtb  Scratch, Index         ; 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00
    pcmpgtb  Byte_Mask, Space       ; ff ff ff ff ff 00 00 ff ff ff ff ff 00 00 00 00
    por      Byte_Mask, Scratch     ; ff ff ff ff ff 00 00 ff ff ff ff ff 00 00 00 00
    movdqa   Scratch, Byte_Mask     ; ff ff ff ff ff 00 00 ff ff ff ff ff 00 00 00 00
    pextrb eax, Byte_Mask, 15
    cmp al, 0xFF
    sete dil

    pslldq   Scratch, 1             ; 00 ff ff ff ff ff 00 00 ff ff ff ff ff 00 00 00
    pand     String, Byte_Mask      ; 48 65 6C 6C 6F 00 00 57 6F 72 6C 64 00 00 00 00
    por      Byte_Mask, Scratch     ; ff ff ff ff ff ff 00 ff ff ff ff ff ff 00 00 00
    pmovmskb eax, Byte_Mask         ; 1 1 1 1 1 1 0 1 1 1 1 1 1 0 0 0

    cmp      ax, 0xFFFF
    jz .full

    tzcnt    cx, ax                 ; 0
    jc .clear
    jz .preskip                        ; jump taken

    shr      ax, cl
    test     sil, sil
    jz .check
    dec      cx
    test     cx, cx
    jnz .check
    jmp .skip

.preskip:
    xor rsi, rsi

.skip:
    xor      r8, r8
    movdqa   Index, Index0          ; 00 01 02 03 04 05 06 07 08 09 0A 0B 0C 0D 0E 0F
    jmp .next

.check:
    mov      r8, rcx
    shl      rcx, 4
    movdqa   Index, [index0 + rcx]

.next:
    not      ax                     ; 0 0 0 0 0 0 1 0 0 0 0 0 0 1 1 1
    tzcnt    cx, ax                 ; 6
    not      ax                     ; 1 1 1 1 1 1 0 1 1 1 1 1 1 0 0 0

    shr      ax, cl                 ; 0 1 1 1 1 1 1 0 0 0 0 0 0 0 0 0
    add      cl, sil
    add      dx, cx                 ; 6

    shl      rcx, 4                 ; 96
    movdqa   Blend_Mask, [bitmask0 + rcx] ; 00 00 00 00 00 00 FF FF FF FF FF FF FF FF FF FF

.string_loop:
    tzcnt    cx, ax
    jc .end_loop

    shr      ax, cl                 ; 1 1 1 1 1 1 0 0 0 0 0 0 0 0 0 0
    add      r8, rcx
    mov      rcx, r8
    shl      rcx, 4
    movdqa   Temp_Index, [index0 + rcx] ; 01 02 03 04 05 06 07 08 09 0A 0B 0C 0D 0E 0F FF
    pblendvb Index, Temp_Index          ; 00 01 02 03 04 05 07 08 09 0A 0B 0C 0D 0E 0F FF

.skip2:
    not      ax                     ; 0 0 0 0 0 0 1 1 1 1 1 1 1 1 1 1
    tzcnt    cx, ax                 ; 6
    not      ax                     ; 1 1 1 1 1 1 0 0 0 0 0 0 0 0 0 0

    shr      ax, cl                 ; 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0
    add      dx, cx                 ; 12
    mov      cx, dx                 ; 12

    shl      rcx, 4
    movdqa   Blend_Mask, [bitmask0 + rcx] ; 00 00 00 00 00 00 00 00 00 00 00 00 FF FF FF FF

    jmp .string_loop

.end_loop:
    cmp      dil, 1
    sete     sil
    xor      rdi, rdi

    pshufb   String, Index          ; 48 65 6C 6C 6F 00 57 6F 72 6C 64 00 00 00 00 00
    movdqu   [Write_Pointer], String
    add      Write_Pointer, rdx
    xor      rdx, rdx
    jmp .main_loop

.full:
    movdqu   [Write_Pointer], String
    cmp      dil, 1
    sete     sil
    xor      rdi, rdi
    add      Write_Pointer, 16
    jmp .main_loop

.end:
    pxor Scratch, Scratch
    movdqu [Write_Pointer], Scratch
    sub Write_Pointer, [input_pointer]
    mov [input_size], Write_Pointer
    ret
