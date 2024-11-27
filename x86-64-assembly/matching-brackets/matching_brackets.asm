section .text
global is_paired

is_paired:
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; lookup initialization
    lea rsi, [rel lookup]
    mov byte [rsi + '('], 1
    mov byte [rsi + '['], 1
    mov byte [rsi + '{'], 1
    mov byte [rsi + ')'], '('
    mov byte [rsi + ']'], '['
    mov byte [rsi + '}'], '{'
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    xor rdx, rdx
    xor rax, rax
    inc al ; brackets match until proven otherwise

    push rbp
    mov rbp, rsp ; bracket stack bottom

.loop:
    mov dl, [rdi]
    inc rdi

    test dl, dl
    jz .unwind ; string end reached

    mov cl, byte[rsi + rdx] ; table entry for a given char

    test cl, cl
    jz .loop ; some irrelevant symbol found, skip

    cmp cl, 1 ; check if it was an opening bracket
    jne .closing

    push dx ; dl cointains opening bracket, push it to the stack
    jmp .loop

.closing:
    cmp rsp, rbp
    je .mismatch ; stack is empty, can't pop

    pop dx ; stack top is in `dl`
    ;; expected left bracket is in `cl`
    cmp dl, cl
    je .loop

    ;; won't jump if wrong opening bracked is on the stack

.mismatch:
    xor al, al

.unwind:
    cmp rsp, rbp
    je .end
    mov rsp, rbp ; pop all values from stack
    xor al, al ; brackets are mismatched if stack wasn't empty at the end

.end:
    pop rbp
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