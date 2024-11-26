;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; A bit slower version using dynamic lookup table
;;
;; .text is 40% larger this way, but the 256-byte lookup table is now in .bss instead of .data,
;; saving way more in return.
;;
;; The downside is that lookup table (well, only 6 of its entries) is now initialized at runtime on every `is_paired` call,
;; which is probably negligible (it's just `O(1)`) for long enough test cases
;;
;; This solution also assumes .bss section is initialized with zeros at load time, which is required by ELF spec AFAIK
;;
;; Also, in multithreaded context, multiple threads share the lookup table and can write to it concurrently. But it shouldn't break
;; anything as they'll write the same bytes anyway

section .text
global is_paired

is_paired:
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    ;; lookup initialization
    lea rcx, [rel lookup]
    mov byte [rcx + left_paren], 1
    mov byte [rcx + left_sq], 1
    mov byte [rcx + left_brace], 1
    mov byte [rcx + right_paren], left_paren
    mov byte [rcx + right_sq], left_sq
    mov byte [rcx + right_brace], left_brace
    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

    xor rdx, rdx
    xor rax, rax
    inc al ; brackets match until proven otherwise

    mov rsi, rsp ; bracket stack bottom

.loop:
    mov dl, [rdi]
    inc rdi

    test dl, dl
    jz .unwind ; string end reached

    lea rcx, [rel lookup] ; lookup table address
    mov cl, byte[rcx + rdx] ; table entry for a given char

    test cl, cl
    jz .loop ; some irrelevant symbol found, skip

    cmp cl, 1 ; check if it was an opening bracket
    jne .closing

    push dx ; dl cointains opening bracket, push it to the stack
    jmp .loop

.closing:
    cmp rsp, rsi
    je .mismatch ; stack is empty, can't pop

    pop dx ; stack top is in `dl`
    ;; expected left bracket is in `cl`
    cmp dl, cl
    je .loop

    ;; won't jump if wrong opening bracked is on the stack

.mismatch:
    xor al, al

.unwind:
    cmp rsp, rsi
    je .end
    mov rsp, rsi ; pop all values from stack
    xor al, al ; brackets are mismatched if stack wasn't empty at the end

.end:
    ret

section .bss
    left_paren: equ '('
    right_paren: equ ')'
    left_sq: equ '['
    right_sq: equ ']'
    left_brace: equ '{'
    right_brace: equ '}'

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