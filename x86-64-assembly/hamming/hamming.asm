section .text
global distance

; a in rdi
; b in rsi
; result in rax
distance:
    xor eax, eax

.loop_start:
    xor edx, edx
    mov ch, [rdi]
    mov cl, [rsi]

    mov dl, ch
    xor dl, cl
    setnz dl ; chars are different -> increment counter
    add eax, edx

    test ch, cl
    jz .loop_end ; at least one char is '\0'

    inc rdi
    inc rsi
    jmp .loop_start

.loop_end:
    or ch, cl
    jz .end ; both chars are '\0'

.len_mismatch:
    xor eax, eax
    dec eax

.end:
    ret

%ifidn __OUTPUT_FORMAT__,elf64
section .note.GNU-stack noalloc noexec nowrite progbits
%endif
