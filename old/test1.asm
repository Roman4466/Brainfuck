.model tiny
.code
                                      org  0100h                                ; Counter for the number of characters read
    start:                            

                                      mov  si, offset 082h
                                      mov  ah, 06h
                                      lea  bx, [filename]                       ; Load address of filename buffer

    read_loop:                        
                                      mov  dl, [si]                             ; Load next character from command line
                                      cmp  dl, 0Dh                              ; Check for carriage return (end of input)
                                      je   end_of_filename                      ; If found, end reading loop
                                      mov  [bx], dl                             ; Store character in filename buffer
                                      inc  bx                                   ; Move to next position in buffer
                                      inc  si                                   ; Move to next character in command line
                                      jmp  read_loop                            ; Repeat loop
    ; Call MSDOS

    end_of_filename:                  
    ; Null-terminate the filename
                                      mov  byte ptr [di], 0
                                      mov  ah, 3Dh                              ; DOS function: Open file
                                      lea  dx, filename                         ; DS:DX points to the filename
                                      mov  al, 0                                ; Open file for reading
                                      int  21h                                  ; Call DOS interrupt
                                      mov  bx, ax                               ; File handle is returned in AX

                                      mov  ah, 3Fh                              ; DOS function: Read from file
                                      lea  dx, program                          ; DS:DX points to the program buffer
                                      mov  cx, 10000                            ; Number of bytes to read
                                      int  21h                                  ; Call DOS interrupt
                                      mov  [count], ax                          ; AX contains the number of bytes read

                                      mov  ah, 3Eh                              ; DOS function: Close file
                                      mov  bx, bx                               ; File handle is still in BX
                                      int  21h                                  ; Call DOS interrupt

    done_reading:                     
                                      xor  cx, cx
                                      xor  bx, bx
                                      jmp main_program_loop

    input:                            
                                      mov  ah, 3Fh
                                      push bx
                                      push cx
                                      mov  bx, 0h                               ; stdin handle
                                      mov  cx, 1                                ; 1 byte to read
                                      mov  dx, offset oneChar                   ; read to ds:dx
                                      int  21h                                  ; Call DOS interrupt to read character
                                      cmp  al, 0Dh                              ; Compare read character with carriage return
                                      je   input                                ; Call DOS interrupt
                                      mov  [memory + bx], ax
                                      pop  bx
                                      pop  cx
                                      jmp  main_program_loop
    main_program_loop:                
                                      cmp  cx, [count]
                                      jae  exit
                                      push bx
                                      mov  bx, cx
                                      mov  dl, [program + bx]
                                      pop  bx
                                      inc  cx
    ;   push dx
    ;   mov dx, [memory + bx]
    ;   mov  ah, 02h
    ;   int  21h
    ;   pop  dx
                                      cmp  ax, 0
                                      cmp  dl, '+'
                                      je   increment
                                      cmp  dl, '-'
                                      je   decrement
                                      cmp  dl, '.'
                                      je   output
                                      cmp  dl, ','
                                      je   input
                                      cmp  dl, '>'
                                      je   shift_right
                                      cmp  dl, '<'
                                      je   shift_left
                                      cmp  dl, '['
                                      je   begin_loop
                                      cmp  dl, ']'
                                      je   end_loop
                                      jmp  main_program_loop

                                      
    nested_loop_that_shouldnt_perform:
                                      inc  ax
    find_end_and_finish:              
                                      push bx
                                      mov  bx, cx
                                      mov  dl, [program + bx]
                                      pop  bx
                                      inc  cx
                                      cmp  dl, '['
                                      je   nested_loop_that_shouldnt_perform
                                      cmp  dl, ']'
                                      je   end_of_loop
                                      jmp  find_end_and_finish

    end_of_loop:                      
                                      cmp  ax, 0
                                      jne  end_of_nested_loop
                                      pop  dx                                   ; pop the pointer to last [
                                      jmp  main_program_loop

    end_of_nested_loop:               
                                      dec  ax
                                      jmp  find_end_and_finish

    exit:                             
                                      mov  ax, 4C00h                            ; Terminate the program
                                      int  21h

    increment:                        
                                      mov  ax, [memory + bx]
                                      inc  ax
                                      mov  [memory + bx], ax
                                      jmp  main_program_loop

    decrement:                        
                                      mov  ax, [memory + bx]
                                      dec  ax
                                      mov  [memory + bx], ax
                                      jmp  main_program_loop

    shift_left:                       
                                      dec  bx
                                      jmp  main_program_loop

    shift_right:                      
                                      inc  bx
                                      jmp  main_program_loop

    output:                           
                                      mov   ax, [memory + bx]                    ; Load the next character to print
                                      cmp  ax, 0Ah                              ; Check if it's linefeed
                                      jne  print_char                           ; If not, jump to print the character
                                      mov  dl, 0Dh                              ; Set DL to carriage return
                                      mov  ah, 02h                              ; DOS function: Print character in DL
                                      int  21h                                  ; Call DOS interrupt to print carriage return
    print_char:                       
                                      mov  dl, al                               ; Load the character to DL for printing
                                      mov  ah, 02h                              ; DOS function: Print character in DL
                                      int  21h                                  ; Call DOS interrupt to print character
                                      jmp  main_program_loop

    end_loop:                         
                                      pop  cx
                                      jmp  main_program_loop
    begin_loop:                       
                                      cmp  [memory + bx], 0
                                      je   loop_should_not_perform
                                      dec  cx
                                      push cx
                                      inc  cx
                                      jmp  main_program_loop

    loop_should_not_perform:          
                                      dec  cx
                                      push cx
                                      inc  cx
                                      xor  ax, ax
                                      jmp  find_end_and_finish
    filename                          db   128 dup(0)                           ; Allocate space for the filename, adjust size as needed

    memory                            dw   10000 dup(0)                         ; Brainfuck memory tape should be bytes
    program                           db   10000 dup(0)                         ; Placeholder for Brainfuck program code
    count                             dw   0
    oneChar                           db   ?
end start