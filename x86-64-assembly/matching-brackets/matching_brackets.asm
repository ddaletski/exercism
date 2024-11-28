section .text
global is_paired

is_paired:
    lea rsi, [rel lookup]
    ;; lookup table is alredy initialized
    ;; if the last non-zero entry is already set
    cmp byte [rsi + '}'], '{'
    je .initialized
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; lookup initialization
    mov byte [rsi + '('], 1
    mov byte [rsi + '['], 1
    mov byte [rsi + '{'], 1
    mov byte [rsi + ')'], '('
    mov byte [rsi + ']'], '['
    mov byte [rsi + '}'], '{'
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
.initialized:

    xor rdx, rdx
    xor rax, rax
    inc al ; brackets match until proven otherwise

    mov rcx, rsp ; bracket stack bottom

.loop:
    mov dl, [rdi]
    inc rdi

    test dl, dl
    jz .unwind ; string end reached

    mov ah, byte[rsi + rdx] ; table entry for a given char

    test ah, ah
    jz .loop ; some irrelevant symbol found, skip

    cmp ah, 1 ; check if it was an opening bracket
    jne .closing

    push dx ; dl cointains opening bracket, push it to the stack
    jmp .loop

.closing:
    cmp rsp, rcx
    je .mismatch ; stack is empty, can't pop

    pop dx ; stack top is in `dl`
    ;; expected left bracket is in `ah`
    cmp dl, ah
    je .loop

    ;; won't jump if wrong opening bracked is on the stack

.mismatch:
    xor al, al

.unwind:
    cmp rsp, rcx
    je .end
    mov rsp, rcx ; pop all values from stack
    xor al, al ; brackets are mismatched if stack wasn't empty at the end

.end:
    xor ah, ah ; clean ah to ensure we follow the ABI spec and set `rax=1` for `true` value
    ret

section .bss
;; lookup table for brackets
;; closing brackets lead to their opening counterparts
;; opening brackets lead to 1
;; other chars lead to 0
;;
;;   - lt[']'] = '['
;;   - lt[')'] = '('
;;   - lt['}'] = '{'
;;   - lt['['] = 1
;;   - lt['('] = 1
;;   - lt['{'] = 1
;;   - lt[other] = 0
lookup:
    resb 256

%ifidn __OUTPUT_FORMAT__,elf64
section .note.GNU-stack noalloc noexec nowrite progbits
%endif