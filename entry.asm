.model tiny
.code
                         org  0100h                   ; Counter for the number of characters read
    start:               

                         mov  si, offset 082h
                         mov  ah, 06h
                         lea  bx, [filename]          ; Load address of filename buffer

    read_loop:           
                         mov  dl, [si]                ; Load next character from command line
                         cmp  dl, 0Dh                 ; Check for carriage return (end of input)
                         je   end_of_filename         ; If found, end reading loop
                         mov  [bx], dl                ; Store character in filename buffer
                         inc  bx                      ; Move to next position in buffer
                         inc  si                      ; Move to next character in command line

                         jmp  read_loop               ; Repeat loop
    ; Call MSDOS

    end_of_filename:     
    ; Null-terminate the filename
                         mov  byte ptr [di], 0
                         mov  ah, 3Dh                 ; DOS function: Open file
                         lea  dx, filename            ; DS:DX points to the filename
                         mov  al, 0                   ; Open file for reading
                         int  21h                     ; Call DOS interrupt
                         mov  bx, ax                  ; File handle is returned in AX

                         mov  ah, 3Fh                 ; DOS function: Read from file
                         lea  dx, program             ; DS:DX points to the program buffer
                         mov  cx, 10000               ; Number of bytes to read
                         int  21h                     ; Call DOS interrupt
                         mov  [count], ax             ; AX contains the number of bytes read

                         mov  ah, 3Eh                 ; DOS function: Close file
                         mov  bx, bx                  ; File handle is still in BX
                         int  21h                     ; Call DOS interrupt

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

    ; start:
    ;                   mov  ah, 01h               ; DOS function: Read character from standard input
    ;                   int  21h                   ; Call DOS interrupt
    ;                   cmp  al, 1Ah               ; Check if input is Ctrl+Z (EOF)
    ;                   je   done_reading
    ;                   mov  [program + bx], al
    ;                   inc  bx                    ; Move to the next position in the program array
    ;                   cmp  bx, 10000             ; Check if we've reached the end of the program buffer
    ;                   jb   start                 ; If not, read next character

    ; done_reading:
    ;                   mov  dx, '6'    ; Load the next character to print
    ;                   mov  ah, 02h               ; DOS function: Print character in DL
    ;                   int  21h
    ;                   mov  ax, 4C01h             ; Terminate the program with an error code
    ;                   int  21h
    ;                   mov  [count], bx
    ;                   xor  cx, cx
    ;                   xor  bx, bx
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

    ; exit:
    ;                      mov  ax, 4C00h               ; Terminate the program
    ;                      int  21h

    filename             db   128 dup(0)              ; Allocate space for the filename, adjust size as needed

    memory               dw   10000 dup(0)            ; Brainfuck memory tape should be bytes
    program              dw   10000 dup(0)            ; Placeholder for Brainfuck program code
    count                dw   0

end start