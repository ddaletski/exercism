section .text
global square_root
square_root:
    ; x in edi
    ; result in eax

    ; ecx is low = 1
    xor ecx, ecx
    inc ecx

    ; esi is high = x
    mov esi, edi

.loop:
    ; eax is mid = (low + high) / 2
    mov eax, ecx
    add eax, esi
    shr eax, 1

    mov r8d, eax

    mul eax
    cmp eax, edi
    jl .right
    jg .left

    mov eax, r8d
    ret

.left:
    mov esi, r8d
    dec esi
    jmp .loop

.right:
    mov ecx, r8d
    inc ecx
    jmp .loop


%ifidn __OUTPUT_FORMAT__,elf64
section .note.GNU-stack noalloc noexec nowrite progbits
%endif
