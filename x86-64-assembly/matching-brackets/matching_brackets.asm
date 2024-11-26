;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; fast version using lookup table

section .text
global is_paired

is_paired:
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
    ; expected left bracket is in `cl`
    cmp dl, cl
    je .loop

    ; won't jump if wrong opening bracked is on the stack

.mismatch:
    xor al, al

.unwind:
    cmp rsp, rsi
    je .end
    mov rsp, rsi ; pop all values from stack
    xor al, al ; brackets are mismatched if stack wasn't empty at the end

.end:
    ret

section .data
    left_paren: equ '('
    right_paren: equ ')'
    left_sq: equ '['
    right_sq: equ ']'
    left_brace: equ '{'
    right_brace: equ '}'

; lookup table for brackets
; closing brackets lead to their opening counterparts
; opening brackets lead to 1
; other chars lead to 0

;   - lt[']'] = '['
;   - lt[')'] = '('
;   - lt['}'] = '{'
;   - lt['['] = 1
;   - lt['('] = 1
;   - lt['{'] = 1
;   - lt[other] = 0
lookup:
    times left_paren db 0

    db 1                                        ; '(' => 1
    times right_paren - left_paren - 1 db 0
    db left_paren                               ; ')' => '('

    times left_sq - right_paren - 1 db 0
    db 1                                        ; '[' = > 1
    times right_sq - left_sq - 1 db 0
    db left_sq                                  ; ')' => '('

    times left_brace - right_sq - 1 db 0
    db 1                                        ; '{' = > 1
    times right_brace - left_brace - 1 db 0
    db left_brace                               ; '}' => '{'

    times 256 - right_brace - 1 db 0



%ifidn __OUTPUT_FORMAT__,elf64
section .note.GNU-stack noalloc noexec nowrite progbits
%endif