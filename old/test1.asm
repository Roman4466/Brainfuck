.model tiny
.code
         org 0100h    ; Counter for the number of characters read

.code
    start:               
                         mov  dx, offset fileName     ; Address filename with ds:dx mov ah, @3Dh ; DOS Open-File function number mov al, Q ; ® = Read-only access
                         mov  ah, 03ch
                         xor  cx, cx
                         int  21h

    print_character:     
                         mov  cx, [count]             ; Load the number of characters to print into CX

    print_next_character:
                         xor  dh, dh
                         mov  dl, [program + bx]      ; Load the next character to print
                         mov  ah, 02h                 ; DOS function: Print character in DL
                         int  21h                     ; Call DOS interrupt

                         inc  bx                      ; Decrement the count
                         loop print_next_character    ; If count is not zero, print the next character

    ; main_program_loop:
    ; ; If so, we are done
    ;                      cmp  cx, [count]
    ;                      jae  exit                    ; If CX is greater or equal to [count], we are done

    ; ; Fetch the current command from the program
    ;                      push bx
    ;                      mov  bl, cl
    ;                      mov  dl, [program + bx]      ; DL is used because it's the lower byte of DX
    ;                      pop  bx
    ;                      inc  cl                      ; Increment the program counter

    ; ;   mov  ah, 02h               ; DOS function: Print character in DL
    ; ;   int  21h
    ; ; Compare the command and jump to the corresponding routine

    ;                      cmp  dl, '+'
    ;                      je   increment
    ;                      cmp  dl, '-'
    ;                      je   decrement
    ;                      cmp  dl, '.'
    ;                      je   output
    ;                      cmp  dl, ','
    ;                      je   input
    ;                      cmp  dl, '>'
    ;                      je   shift_right
    ;                      cmp  dl, '<'
    ;                      je   shift_left
    ;                      cmp  dl, '['
    ;                      je   begin_loop
    ;                      cmp  dl, ']'
    ;                      je   end_loop
    ;                      jmp  main_program_loop

    ; increment:
    ;                      mov  ax, [memory + bx]
    ;                      inc  ax
    ;                      mov  [memory + bx], ax
    ;                      jmp  main_program_loop

    ; decrement:
    ;                      mov  ax, [memory + bx]
    ;                      dec  ax
    ;                      mov  [memory + bx], ax
    ;                      jmp  main_program_loop


    ; input:
    ;                      mov  ah, 01h                 ; DOS function: Read character from standard input
    ;                      int  21h                     ; Call DOS interrupt
    ; ;   xor ah, ah
    ;                      mov  [memory + bx], ax
    ;                      jmp  main_program_loop

    ; output:
    ;                      mov  dx, [memory + bx]       ; Load the next character to print
    ;                      mov  ah, 02h                 ; DOS function: Print character in DL
    ;                      int  21h                     ; Call DOS interrupt
    ;                      jmp  main_program_loop

    ; shift_left:
    ;                      dec  bx
    ;                      jmp  main_program_loop

    ; shift_right:
    ;                      inc  bx
    ;                      jmp  main_program_loop

    ; begin_loop:
    ;                      push cx
    ;                      jmp  main_program_loop
    
    ; end_loop:
    ;                      cmp  [memory + bx], 0        ; Check if the current cell is zero
    ;                      jne  main_program_loop
    ;                      pop  cx
    ;                      jmp  main_program_loop

    exit:                
                         mov  ax, 4C00h               ; Terminate the program
                         int  21h

    memory               dw   10000 dup(0)            ; Brainfuck memory tape should be bytes
    program              db   10000 dup(0)            ; Placeholder for Brainfuck program code
    count                dw   0
    handle               dw   ?
end start