section .text

; extern int append(const int *first_array, const int first_array_size, const int *second_array, const int second_array_size, int *result_array);
global append
append:
    ; rdi - arr1
    ; esi - arr1 size
    ; rdx - arr2
    ; ecx - arr2 size
    ; r8 - result

    xor eax, eax ; result index and arr1 index

.loop1:
    cmp eax, esi
    je .after_loop1

    mov r9d, [rdi + 4 * rax]
    mov [r8 + 4 * rax], r9d
    inc eax
    jmp .loop1

.after_loop1:
    xor rsi, rsi ; arr2 index

.loop2:
    cmp rsi, rcx
    je .after_loop2
    mov r9d, [rdx + 4 * rsi]
    mov [r8 + 4 * rax], r9d
    inc eax
    inc esi
    jmp .loop2

.after_loop2:
    ret

; extern int filter(const int *array, const int array_size, bool (*filter_predicate)(int), int *result_array);
global filter
filter:
    ; rdi - arr
    ; esi - arr size
    ; rdx - predicate
    ; rcx - result

    xor eax, eax ; write index

.loop:
    test esi, esi
    jz .end
    dec esi

    ; TODO: use callee-saved registers
    ; now we push/pop 5 registers each iteration, even if predicate doesn't overwrite them (only C compliler could know that for sure)
    push rdi
    push rsi
    push rdx
    push rcx
    push rax

    mov edi, [rdi] ; set predicate argument
    call rdx

    test al, al
    setnz r8b ; predicate result in r8b

    pop rax
    pop rcx
    pop rdx
    pop rsi
    pop rdi

    add rdi, 4
    test r8b, r8b
    jz .loop ; filtered out, continue

    mov r8d, [rdi - 4]
    mov [rcx + 4 * rax], r8d
    inc eax
    jmp .loop

.end:
    ret

; extern int map(const int *array, const int array_size, int (*map_transform)(int), int *result_array);
global map
map:
    ; rdi - arr
    ; esi - arr size
    ; rdx - transform
    ; rcx - result

    xor eax, eax ; write index

.loop:
    test rsi, rsi
    jz .end
    dec rsi

    ; TODO: use callee-saved registers
    push rdi
    push rsi
    push rdx
    push rcx
    push rax

    mov edi, [rdi]
    call rdx

    mov r8d, eax ; transform result in r8d

    pop rax
    pop rcx
    pop rdx
    pop rsi
    pop rdi

    mov [rcx + 4 * rax], r8d
    add rdi, 4
    inc rax
    jmp .loop

.end:
    ret

;extern int foldl(const int *array, const int array_size, int initial, int (*fold_accumulate)(int, int));
global foldl
foldl:
    ; rdi - arr
    ; esi - arr size
    ; edx - initial
    ; rcx - binary_op

    mov eax, edx ; accumulator in eax

.loop:
    test esi, esi
    jz .end

    ; TODO: use callee-saved registers
    push rdi
    push rsi
    push rcx

    mov esi, [rdi]
    mov edi, eax
    call rcx

    pop rcx
    pop rsi
    pop rdi

    add rdi, 4
    dec esi
    jmp .loop
.end:

    ret

;extern int foldr(const int *array, const int array_size, int initial, int (*fold_accumulate)(int, int));
global foldr
foldr:
    ; rdi - arr
    ; esi - arr size
    ; edx - initial
    ; rcx - binary_op

    mov eax, edx ; accumulator in eax

.loop:
    test esi, esi
    jz .end
    dec esi

    ; TODO: use callee-saved registers
    push rdi
    push rsi
    push rcx

    mov esi, [rdi + 4 * rsi]
    mov edi, eax
    call rcx

    pop rcx
    pop rsi
    pop rdi

    jmp .loop
.end:

    ret

; extern int reverse(const int *array, const int array_size, int *result_array);
global reverse
reverse:
    ; rdi - src
    ; esi - src size
    ; rdx - result

    xor eax, eax
    lea rdi, [rdi + 4 * rsi - 4] ; reading src in reverse

.loop:
    cmp eax, esi
    je .end

    mov ecx, [rdi]
    mov [rdx + 4 * rax], ecx
    sub rdi, 4
    inc eax
    jmp .loop

.end:
    ret

%ifidn __OUTPUT_FORMAT__,elf64
section .note.GNU-stack noalloc noexec nowrite progbits
%endif
