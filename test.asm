.model small
.stack 100h
.data
    char    db '?$'            ; Placeholder for input character
    memory  dw 10000 dup(0)    ; Brainfuck memory tape
    program dw 10000 dup(0)    ; Placeholder for Brainfuck program code

.code
    start:          
                    mov ax, @data
                    mov ds, ax
                    xor bx, bx
                    xor cx, cx                ; Set loop counter for columns (Y)

    read_charachter:
                    mov ah, 01h               ; DOS function: Read character from standard input
                    int 21h
    ; mov char, al ; Store the read character
                    xor ah, ah
                    mov [program + bx], ax
                    inc bx
    
                    inc cx
                    cmp cx, 4
                    jne read_charachter       ; Repeat if cx != 16

                    xor bx, bx                ; Reset offset index for output
    ; Now, let's print the character back to the console
    print_character:
                    cmp bx, 4                ; Check if we have printed 16 characters
                    je  done                  ; If so, we are done

                    xor dh, dh
                    mov dx, [program + bx]    ; Load the next character to print
                    mov ah, 02h               ; DOS function: Print character in DL
                    int 21h                   ; Call DOS interrupt

                    inc bx                    ; Move to the next character
                    jmp print_character       ; Continue printing characters

    done:           
                    mov ax, 4C00h             ; Terminate the program
                    int 21h
end start
