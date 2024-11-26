section .text
global find

; ptr in rdi
; size in esi
; query in edx
find:
    xor rax, rax
    mov rcx, rdi ; save original pointer

    xor r8d, r8d

.loop:
    test esi, esi
    jz .not_found

    test sil, 1
    setz r8b ; size evenness bit

    shr esi, 1 ; size /= 2
    cmp edx, [rdi + 4 * rsi]

    jl .loop ; size is already divided, ptr is the same
    jg .right

    ;; found the value, let's find its offset
    lea rax, [rdi + 4 * rsi]
    sub rax, rcx ; index = curr_ptr - start_ptr
    shr rax, 2
    ret

.right:
    lea rdi, [rdi + 4 * rsi + 4]; ptr = mid + 1
    sub esi, r8d ; decrement size if previous size was even
    jmp .loop

.not_found:
    mov eax, -1
    ret


%ifidn __OUTPUT_FORMAT__,elf64
section .note.GNU-stack noalloc noexec nowrite progbits
%endif
