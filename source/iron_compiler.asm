;   nasm -f elf64 iron_compiler.asm -o iron_compiler.o
;   nasm -f elf64 delete_filler.asm -o delete_filler.o
;   nasm -f elf64 filter_text.asm -o filter_text.o
;   nasm -f elf64 setup.asm -o setup.o
;   nasm -f elf64 clear_whitespace.asm -o clear_whitespace.o
;   ld iron_compiler.o delete_filler.o filter_text.o setup.o clear_whitespace.o -o iron
;./iron build instructions.txt database.iron instructions.asm
;./iron factor database.txt database.iron
BITS 64
section .data
align 16
    bitmask0: db 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff ;16
    bitmask1: db 0x00, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff
    bitmask2: db 0x00, 0x00, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff
    bitmask3: db 0x00, 0x00, 0x00, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff
    bitmask4: db 0x00, 0x00, 0x00, 0x00, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff
    bitmask5: db 0x00, 0x00, 0x00, 0x00, 0x00, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff
    bitmask6: db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff
    bitmask7: db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff
    bitmask8: db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff
    bitmask9: db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff
    bitmaskA: db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xff, 0xff, 0xff, 0xff, 0xff, 0xff
    bitmaskB: db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xff, 0xff, 0xff, 0xff, 0xff
    bitmaskC: db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xff, 0xff, 0xff, 0xff
    bitmaskD: db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xff, 0xff, 0xff
    bitmaskE: db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xff, 0xff
    bitmaskF: db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xff
    bitmaskG: db 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00

    symbols:  db 0x3C, 0x3E, 0x28, 0x29, 0x5B, 0x5C, 0x7B, 0x7C, 0x2B, 0x2C, 0x2E, 0x3D, 0x26, 0x5E, 0x3F, 0x3A
    ;            <     >     (     )     [     ]     {     }     +     ,     .     =     &     ^     ?     :
    symbols2: db 0x23, 0x40, 0x5C, 0x24, 0x3B, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF
    ;            #     @     \     $     ;
    letters1: db 0x61, 0x62, 0x63, 0x64, 0x65, 0x66, 0x67, 0x68, 0x69, 0x6A, 0x6B, 0x6C, 0x6D, 0x6E, 0x6F, 0x70
    letters2: db 0x71, 0x72, 0x73, 0x74, 0x75, 0x76, 0x77, 0x78, 0x79, 0x7A, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
    despace:  db 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20


    ;extra_table:
        ;dq .hex_table
        ;dq .alphabet_table

    factor_string: db "factor", 0x00

    build_string: db "build", 0x00


    usage:              db "Usage: ./iron <input> <database> <output>", 10
    usage_length:       equ $ - usage

    open_input:         db "Error: cannot open input file", 10
    open_input_length:  equ $ - open_input

    open_output:        db "Error: cannot open output file", 10
    open_output_length: equ $ - open_output

    fstat:              db "Error: fstat failed", 10
    fstat_length:       equ $ - fstat

    read:               db "Error: read source failed", 10
    read_length:        equ $ - read

    write:              db "Error: write failed", 10
    write_length:       equ $ - write

    error:              db "Error: this ", 0x22 ; 0x22 is quote
    error_length:       equ $ - error

    invalid_db:         db 0x22, " is invalid database syntax", 10
    invalid_db_length:  equ $ - invalid_db

    invalid_src:        db 0x22, " is invalid source code syntax", 10
    invalid_src_length: equ $ - invalid_src

section .bss
    input_descriptor    resb 8
    input_size          resb 8
    input_pointer       resb 8
    orignial_size       resb 8

    database_descriptor resb 8
    database_size       resb 8
    database_pointer    resb 8

    output_pointer      resb 8
    output_descriptor   resb 8
    output_size         resb 8

    save1               resb 8
    save2               resb 8
    save3               resb 8
    save4               resb 8

    stat_buffer         resb 144        ; sizeof(struct stat) on x86-64
extern factor
extern clear_whitespace
extern delete_filler
extern filter_text
section .text
    global input_pointer
    global input_size
    global output_pointer
    global output_size
    global bitmask0
    global despace
    global _start

_start:
    ; ── Check argument count ─────────────────────────────────────────────────
    mov rax, [rsp]              ; argc
    cmp rax, 4
    jb usage_error
    cmp rax, 5
    ja usage_error
    ; ── Open input file ──────────────────────────────────────────────────────
    mov rax, 2        ; open
    mov rdi, [rsp+24] ; argv[2] = input path
    xor rsi, rsi      ; read only: 0
    xor rdx, rdx
    syscall
    test rax, rax
    js  open_input_error
    mov [input_descriptor], rax      ; r14 is input descriptor

    ; ── fstat to get file size ───────────────────────────────────────────────
    mov rax, 5 ;fstat
    mov rdi, [input_descriptor] ; file descriptor
    mov rsi, stat_buffer        ; pointer to stat struct
    syscall
    test rax, rax
    js  fstat_error
    mov rax, [stat_buffer + 48]
    mov [input_size], rax

    ; ── Check Usage ──────────────────────────────────────────────────────────
    mov rax, [rsp]
    cmp rax, 4
    je do_factor
    cmp rax, 5
    jne usage_error

    ; ── brk allocate ─────────────────────────────────────────────────────────
    mov rax, 12         ; sys_brk
    xor rdi, rdi        ; pass 0 to get current break
    syscall
    mov [input_pointer], rax

    mov rax, 12
    mov rdi, [input_pointer]
    add rdi, [input_size]
    add rdi, [input_size] ;if someone uses a lot of commas, it can cause a segfault, this is done to avoid that.
    add rdi, 16 ;avoids segfault on small inputs. aka 7 bytes or less.
    syscall

    ; ── Read file into buffer ────────────────────────────────────────────────
    mov     rax, 0
    mov     rdi, [input_descriptor]                ; input fd
    mov     rsi, [input_pointer]                ; buffer pointer
    add     rsi, [input_size]
    mov     rdx, [input_size]                ; read exactly file-size bytes
    syscall
    test     rax, rax
    js      read_error

    ; ── Close input file ─────────────────────────────────────────────────────
    mov rax, 3 ;close
    mov rdi, [input_descriptor]
    syscall

    ; ── brk allocate ─────────────────────────────────────────────────────────
    mov rax, 12         ; sys_brk
    xor rdi, rdi        ; pass 0 to get current break
    syscall
    add rax, 16 ;stops the program from reading into the second allocation.
    mov [output_pointer], rax

    mov rax, 12
    mov rdi, [output_pointer]
    add rdi, [input_size]
    add rdi, [input_size] ;allocating double the length to the output so i dont have to reallocate.
    syscall

build:
    call filter_text

    call clear_whitespace

    mov rax, [input_size]
    mov [orignial_size], rax

    call delete_filler

    ; ── Open database ────────────────────────────────────────────────────────
    mov rax, 2        ; open
    mov rdi, [rsp+32] ; argv[3] = database path
    xor rsi, rsi      ; read only: 0
    xor rdx, rdx
    syscall
    test rax, rax
    js  open_input_error
    mov [database_descriptor], rax

    ; ── fstat to get file size ───────────────────────────────────────────────
    mov rax, 5 ;fstat
    mov rdi, [database_descriptor] ; file descriptor
    mov rsi, stat_buffer        ; pointer to stat struct
    syscall
    test rax, rax
    js  fstat_error
    mov rax, [stat_buffer + 48]
    mov [database_size], rax

    ; ── brk allocate ─────────────────────────────────────────────────────────
    mov rax, 12         ; sys_brk
    xor rdi, rdi        ; pass 0 to get current break
    syscall
    add rax, 16
    mov [database_pointer], rax

    mov rax, 12
    mov rdi, [database_pointer]
    add rdi, [database_size]
    syscall

    ; ── Read file into buffer ────────────────────────────────────────────────
    mov     rax, 0
    mov     rdi, [database_descriptor]
    mov     rsi, [database_pointer]
    mov     rdx, [database_size]
    syscall
    test     rax, rax
    js      read_error

    ; ── Close database file ──────────────────────────────────────────────────
    mov rax, 3 ;close
    mov rdi, [database_descriptor]
    syscall

    movdqa xmm15, [symbols]
    movdqa xmm14, [letters1]
    movdqa xmm13, [letters2]
    movdqa xmm9, [despace]
    movdqa xmm7, [symbols2]
    pcmpeqb xmm6, xmm6
    pxor xmm10, xmm10
    lea r9, [rel jump_table2]
    lea r10, [rel jump_table]
    mov r12, [database_pointer]
    mov r13, [output_pointer]
    mov r14, [input_pointer]
    add r14, [orignial_size]
    add r14, 16

    mov r15, r14
    add r15, [input_size]
    xor rcx, rcx

main_loop:
    call isolate_string
    mov r12, [database_pointer]
    ;movdqu xmm1, [r14]
    ;call isolate_string
next_loop:
    cmp r14, r15
    jae end
    mov al, [r12]
    pinsrb xmm12, eax, 0
    pshufb xmm12, xmm10
    movdqa xmm8, xmm12
    pcmpeqb xmm12, xmm15
    pmovmskb eax, xmm12

    tzcnt cx, ax
    jc second_table

    jmp [r10 + rcx*8]

second_table:
    pcmpeqb xmm8, xmm7
    pmovmskb eax, xmm8

    tzcnt cx, ax
    jc invalid_database_error
    jmp [r9 + rcx*8]

hashtag:
    mov rdx, r14
    call get_string_length
    cmp rbx, 16
    ja invalid_source_error
    cmp rbx, 0
    je invalid_source_error
    dec rbx
    add r12, 5
    shl rbx, 3
    add r12, rbx

    mov eax, [r12]
    add r12, rax
    jmp next_loop

next_string:
    movdqu xmm13, [r14]
    pcmpeqb xmm13, xmm10
    pmovmskb eax, xmm13
    not eax
    tzcnt cx, ax
    jc .next_loop
    add r14, rcx
    jmp main_loop

.next_loop:
    add r14, 16
    cmp r14, r15
    jae end
    jmp next_string

at_sign:
    pextrb eax, xmm0, 0
    sub al, 0x61
    cmp al, 25
    ja invalid_source_error
    mov rcx, 10
    mul rcx
    add r12, 7
    add r12, rax
    mov eax, [r12]
    add r12, rax
    jmp next_loop

colon:
    call database_skip_string
    mov eax, [r12]
    sub r12, rax
    jmp next_loop

open_arrow:
    mov [save1], r14
    add r12, 2
    jmp next_loop

close_arrow:
    mov rax, [save1]
    mov [save1], r14
    mov r14, rax
    call copy_string
    mov r14, [save1]
    jmp next_loop

open_parenthesis:
    mov [save2], r14
    add r12, 2
    jmp next_loop

close_parenthesis:
    mov rax, [save2]
    mov [save2], r14
    mov r14, rax
    call copy_string
    mov r14, [save2]
    jmp next_loop

open_bracket:
    add r12, 2
    mov [save3], r12
    jmp next_loop

close_bracket:
    mov r12, [save3]
    jmp next_loop

open_curly:
    add r12, 2
    mov [save4], r12
    call database_skip_string
    jmp next_loop

close_curly:
    mov rax, [save4]
    mov [save4], r14
    mov r14, rax
    call copy_string
    mov r14, [save4]
    jmp next_loop

plus_sign:
    call isolate_string
    add r12, 2
    jmp next_loop

comma:
    dec r13
    mov [r13], word 0x002C ; comma
    add r13, 2
    add r12, 2
    jmp next_loop

period:
    dec r13
    mov [r13], byte 10 ;new line
    add r13, 2
    add r12, 2
    jmp main_loop

equal_sign:
    add r12, 2
    call database_copy_string
    jmp next_loop

ampersand:
    call database_skip_string
    mov eax, [r12]
    add r12, rax
    jmp next_loop

skip_ampersand:
    call database_skip_string
    add r12, 5
    jmp next_loop

exponent:
    call copy_string
    jmp next_loop

question_mark:
    add r12, 2
    call isolate_database_string
    cmp rdi, rsi
    jne .false
    call compare
    jnc .false

.true:
    mov al, [r12]
    cmp al, 0x26
    jne next_loop
    call isolate_string
    jmp ampersand

.false:
    mov al, [r12]
    cmp al, 0x26
    je skip_ampersand
    call database_skip_string
    jmp next_loop

backslash:
    dec r14
    jmp next_loop

dollar_sign:
    call database_skip_string
    jmp next_loop

semicolon:
    call database_skip_string
    jmp next_loop

do_factor:
    ; ── brk allocate ─────────────────────────────────────────────────────────
    mov rax, 12         ; sys_brk
    xor rdi, rdi        ; pass 0 to get current break
    syscall
    mov [input_pointer], rax

    mov rax, 12
    mov rdi, [input_pointer]
    add rdi, [input_size]
    syscall

    ; ── Read file into buffer ────────────────────────────────────────────────
    mov     rax, 0
    mov     rdi, [input_descriptor]                ; input fd
    mov     rsi, [input_pointer]                ; buffer pointer
    mov     rdx, [input_size]                ; read exactly file-size bytes
    syscall
    test     rax, rax
    js      read_error

    ; ── Close input file ─────────────────────────────────────────────────────
    mov rax, 3 ;close
    mov rdi, [input_descriptor]
    syscall

    ; ── brk allocate ─────────────────────────────────────────────────────────
    mov rax, 12         ; sys_brk
    xor rdi, rdi        ; pass 0 to get current break
    syscall
    add rax, 16 ;stops the program from reading into the second allocation.
    mov [output_pointer], rax

    mov rax, 12
    mov rdi, [output_pointer]
    add rdi, [input_size]
    add rdi, [input_size] ;allocating double the length to the output so i dont have to reallocate.
    syscall

    call clear_whitespace
    call factor
    mov     rdi, [rsp+32] ; argv[3] = output file
    jmp factor_end

end:
    call null_to_space
    call full_to_space

    sub r13, [output_pointer]
    mov [output_size], r13
    ; ── Open output file ─────────────────────────────────────────────────────
    mov     rdi, [rsp+40] ; argv[4] = output file


factor_end:
    mov     rax, 2 ;open
    mov     rsi, 0o1101   ; truncate: 0o1000, create: 0o100, write only: 1
    mov     rdx, 0o644    ; rw-r--r-- r=4, w=2, 4+2=6, 4, 4
    syscall

    cmp     rax, 0
    jl      open_output_error
    mov     [output_descriptor], rax



    ; ── Write buffer to output file ──────────────────────────────────────────
    mov     rax, 1 ;write
    mov     rdi, [output_descriptor] ; file descriptor
    mov     rsi, [output_pointer]     ; buffer pointer
    mov     rdx, [output_size]       ; bytes to write
    syscall
    cmp     rax, 0
    jl      write_error

    ; ── Close output file ────────────────────────────────────────────────────
    mov     rax, 3 ;close
    mov     rdi, r14
    syscall

    ; ── Exit success ─────────────────────────────────────────────────────────
    mov     rax, 60 ;exit
    xor     rdi, rdi
    syscall

    ; ── Error handlers ───────────────────────────────────────────────────────
usage_error:
    mov     rsi, usage
    mov     rdx, usage_length
    jmp print_error

open_input_error:
    mov     rsi, open_input
    mov     rdx, open_input_length
    jmp print_error

fstat_error:
    mov     rsi, fstat
    mov     rdx, fstat_length
    jmp print_error

read_error:
    mov     rsi, read
    mov     rdx, read_length
    jmp print_error

open_output_error:
    mov     rsi, open_output
    mov     rdx, open_output_length
    jmp print_error

write_error:
    mov     rsi, write
    mov     rdx, write_length

invalid_database_error:
    mov     rsi, error
    mov     rdx, error_length
    mov     rax, 1; write
    mov     rdi, 2; terminal
    syscall

    mov     rsi, r12
    mov     rdx, 16
    mov     rax, 1; write
    mov     rdi, 2; terminal
    syscall

    mov     rsi, invalid_db
    mov     rdx, invalid_db_length
    jmp print_error

invalid_source_error:
    mov     rsi, error
    mov     rdx, error_length
    mov     rax, 1; write
    mov     rdi, 2; terminal
    syscall

    mov     rsi, rbx
    mov     rdx, 16
    mov     rax, 1; write
    mov     rdi, 2; terminal
    syscall

    mov     rsi, invalid_src
    mov     rdx, invalid_src_length
    jmp print_error

print_error:
    mov rax, 1; write
    mov rdi, 2; terminal
    syscall

exit_error:
    mov     rax, 60 ;exit
    mov     rdi, 1  ;error
    syscall


get_string_length:
    ; ── Setup Registers ──────────────────────────────────────────────────────
    ;clobbers xmm7, rax, rbx, rcx, rdx | string_length
    xor rbx, rbx
    jmp .start

.next_string:
    add rbx, 16
    add rdx, 16

.start:
    movdqu xmm13, [rdx]
    pcmpeqb xmm13, xmm10
    pmovmskb eax, xmm13
    tzcnt cx, ax
    jc .next_string
    add rbx, rcx
    ret

compare:
    pcmpeqb xmm1, xmm0
    pmovmskb eax, xmm1
    not eax
    tzcnt cx, ax
    ret

isolate_string: ; ?
    pxor xmm0, xmm0
    movdqu xmm12, [r14]
    pcmpeqb xmm0, xmm12
    pmovmskb eax, xmm0
    tzcnt cx, ax
    mov rdi, rcx
    inc rdi
    add r14, rdi
    shl ecx, 4
    movdqa xmm0, [bitmask0 + rcx]
    pandn xmm0, xmm12
    ret

isolate_database_string:
    pxor xmm1, xmm1
    movdqu xmm12, [r12]
    pcmpeqb xmm1, xmm12
    pmovmskb eax, xmm1
    tzcnt cx, ax
    mov rsi, rcx
    inc rsi
    add r12, rsi
    shl ecx, 4
    movdqa xmm1, [bitmask0 + rcx]
    pandn xmm1, xmm12
    ret

copy_string: ; ^
    pxor xmm12, xmm12
    movdqu xmm13, [r14]
    pcmpeqb xmm12, xmm13
    pmovmskb eax, xmm12
    tzcnt cx, ax
    jc .next_string
    jz .end
    movdqu [r13], xmm13

.end:
    inc rcx
    add r13, rcx
    add r14, rcx
    add r12, 2
    ret

.next_string:
    movdqu [r13], xmm13
    add r14, 16
    add r13, 16
    jmp copy_string

database_copy_string: ; =
    pxor xmm12, xmm12
    movdqu xmm13, [r12]
    pcmpeqb xmm12, xmm13
    pmovmskb eax, xmm12
    tzcnt cx, ax
    jc .next_string
    jz .end
    movdqu [r13], xmm13
.end:
    inc rcx
    add r13, rcx
    add r12, rcx
    ret

.next_string:
    movdqu [r13], xmm13
    add r12, 16
    add r13, 16
    jmp database_copy_string

skip_string: ; +
    movdqu xmm13, [r14]
    pcmpeqb xmm13, xmm10
    pmovmskb eax, xmm13
    tzcnt cx, ax
    jc .next_string

    inc rcx
    add r14, rcx
    add r12, 2
    ret

.next_string:
    add r14, 16
    jmp skip_string

database_skip_string:
    movdqu xmm13, [r12]
    pcmpeqb xmm13, xmm10
    pmovmskb eax, xmm13
    tzcnt cx, ax
    jc .next_string

    inc rcx
    add r12, rcx
    ret

.next_string:
    add r12, 16
    jmp database_skip_string

null_to_space: ;changes 0x00 bytes to 0x20, 0x20 is space " "
    mov r10, [output_pointer]

.main_loop:
    cmp r10, r13
    jae .end
    pxor xmm0, xmm0
    movdqu xmm1, [r10]
    pcmpeqb xmm0, xmm1
    pblendvb xmm1, xmm9
    movdqu [r10], xmm1
    add r10, 16
    jmp .main_loop
.end:
    ret

full_to_space: ;changes 0xFF bytes to 0x20, 0x20 is space " "
    mov r10, [output_pointer]

.main_loop:
    cmp r10, r13
    jae .end
    movdqu xmm0, [r10]
    movdqa xmm1, xmm0
    pcmpeqb xmm0, xmm6
    pblendvb xmm1, xmm9
    movdqu [r10], xmm1
    add r10, 16
    jmp .main_loop

.end:
    ret

section .data
    jump_table:
        dq open_arrow
        dq close_arrow
        dq open_parenthesis
        dq close_parenthesis
        dq open_bracket
        dq close_bracket
        dq open_curly
        dq close_curly
        dq plus_sign
        dq comma
        dq period
        dq equal_sign
        dq ampersand
        dq exponent
        dq question_mark
        dq colon

    jump_table2:
        dq hashtag
        dq at_sign
        dq backslash
        dq dollar_sign
        dq semicolon
