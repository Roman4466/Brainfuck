.model small
.stack 100h
.data
    char    db '?'             ; Placeholder for input character
    ; memory  db 10000 dup(0)    ; Brainfuck memory tape should be bytes
    program db 10000 dup(0)    ; Placeholder for Brainfuck program code
    count   dw 0               ; Counter for the number of characters read

.code
    start:          
                    mov ax, @data
                    mov ds, ax
                    xor bx, bx                ; Offset index for the program data

    read_character: 
                    mov ah, 01h               ; DOS function: Read character from standard input
                    int 21h                   ; Call DOS interrupt
                    cmp al, 1Ah               ; Check if input is Ctrl+Z (EOF)
                    je  done_reading          ; If it is EOF, jump to done_reading
                    mov [program + bx], al    ; Store the read character
                    inc bx                    ; Move to the next position in the program array
                    inc [count]               ; Increment the character count
                    cmp bx, 10000             ; Check if we've reached the end of the program buffer
                    jb  read_character        ; If not, read next character

    done_reading:   
                    xor bx, bx                ; Reset offset index for output

    print_character:                          ; Move to the next position in the program array
                    inc bx                    ; Increment the character count
                    cmp bx, [count]           ; Check if we've reached the end of the program buffer
                    ; jb  done                  ; If so, we are done

                    mov dx, [count]
                    xor dh, dh                ; Clear the high byte of DX
                    mov al, dl    ; Load the next character to print
                    mov ah, 02h               ; DOS function: Print character in DL
                    int 21h                   ; Move to the next character
                    ; jmp print_character       ; Continue printing characters


    done:           
                    mov ax, 4C00h             ; Terminate the program
                    int 21h
end start
