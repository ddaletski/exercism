section .text
global square_root
square_root:
    ; x in edi
    ; result in eax

    xor ecx, ecx

.loop:
    inc ecx

    mov eax, ecx
    mul ecx

    cmp eax, edi
    jl .loop

    mov eax, ecx

    ret

%ifidn __OUTPUT_FORMAT__,elf64
section .note.GNU-stack noalloc noexec nowrite progbits
%endif
