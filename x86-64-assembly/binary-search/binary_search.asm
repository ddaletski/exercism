section .text
global find

; ptr in rdi
; size in esi
; query in edx
find:
    mov rcx, rdi ; save original pointer
    xor eax, eax

.loop:
    test esi, esi
    jz .not_found

    test sil, 1
    setz al ; size evenness bit (read the description in the end)

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
    ;; decrement size if size was even before dividing by 2
    ;; cause in that case we have one item less on the right of the pivot than on the left
    sub esi, eax
    jmp .loop

.not_found:
    mov eax, -1
    ret


%ifidn __OUTPUT_FORMAT__,elf64
section .note.GNU-stack noalloc noexec nowrite progbits
%endif