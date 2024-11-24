section .text
global distance

; a in rdi
; b in rsi
; result in rax
distance:
    xor eax, eax

.loop_start:
    mov r8b, [rdi]
    test r8b, r8b
    jz .loop_end
    mov r9b, [rsi]
    test r9b, r9b
    jz .loop_end

    xor rdx, rdx ; will contain 0 if chars equal or 1 otherwise
    cmp r8b, r9b
    setne dl
    add eax, edx

    inc rdi
    inc rsi
    jmp .loop_start

.loop_end:
    mov ecx, -1 ; return value in case of different lengths (when either last char isn't \0)

    mov r8b, [rdi]
    mov r9b, [rsi]
    or r8b, r9b
    test r8b, r8b
    cmovne eax, ecx;

    ret

%ifidn __OUTPUT_FORMAT__,elf64
section .note.GNU-stack noalloc noexec nowrite progbits
%endif
