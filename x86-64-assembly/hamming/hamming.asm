section .text
global distance

; a in rdi
; b in rsi
; result in rax
distance:
    xor ecx, ecx
    xor edx, edx ; mismatch counter
    cld

.loop_start:
    mov ah, [rdi]
    lodsb ; al <- [rsi]; rsi++
    scasb ; cmp al, [rdi]; rdi++
    setne cl
    add edx, ecx

    imul ah
    test ax, ax
    jnz .loop_start ; both are not 0

.loop_end:
    ; at least one char was 0
    test cl, cl ; check if chars were different (meaning cl byte set)
    jz .end ; both are 0

.len_mismatch:
    xor edx, edx
    dec edx

.end:
    mov eax, edx
    ret

%ifidn __OUTPUT_FORMAT__,elf64
section .note.GNU-stack noalloc noexec nowrite progbits
%endif
