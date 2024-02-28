.model small
.stack 100h
.data
    char    db '?'             ; Placeholder for input character
    ; memory  db 10000 dup(0)    ; Brainfuck memory tape should be bytes
    program dw 10000 dup(0)    ; Placeholder for Brainfuck program code
    count   dw 0               ; Counter for the number of characters read

.code
    start:               
                         mov  ax, @data
                         mov  ds, ax
                         xor  bx, bx                  ; Offset index for the program data

    read_character:      
                         mov  ah, 01h                 ; DOS function: Read character from standard input
                         int  21h                     ; Call DOS interrupt
                         cmp  al, 1Ah                 ; Check if input is Ctrl+Z (EOF)
                         je   done_reading
                         xor  ah, ah
                         mov  [program + bx], ax
                         inc  bx                      ; Move to the next position in the program array
                         inc  [count]                 ; Increment the character count
                         cmp  bx, 10000               ; Check if we've reached the end of the program buffer
                         jb   read_character          ; If not, read next character

    done_reading:        
                         xor  bx, bx                  ; Reset offset index for output

    print_character:     
                         mov  cx, [count]             ; Load the number of characters to print into CX

    print_next_character:
                         xor  dh, dh
                         mov  dx, [program + bx]      ; Load the next character to print
                         mov  ah, 02h                 ; DOS function: Print character in DL
                         int  21h                     ; Call DOS interrupt

                         inc  bx                      ; Decrement the count
                         loop print_next_character    ; If count is not zero, print the next character


    done:                
                         mov  ax, 4C00h               ; Terminate the program
                         int  21h
end start
