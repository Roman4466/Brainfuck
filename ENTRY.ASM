.model tiny
.data
    data_pointer dw 0
    filename     db 128 dup(0)      ; Allocate space for the filename, adjust size as needed
    memory       dw 10000 dup(0)    ; Brainfuck memory tape should be bytes
    program      db 10000 dup(0)    ; Placeholder for Brainfuck program code
    count        dw 0
.code
                                      org  0100h
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
                                      mov  ah, 3Dh
                                      lea  dx, filename
                                      mov  al, 0
                                      int  21h
                                      mov  bx, ax
                                      mov  ah, 3Fh
                                      lea  dx, program
                                      mov  cx, 10000
                                      int  21h
                                      mov  [count], ax
    ;   push dx
    ;   push ax
    ;   mov  dx, [count]
    ;   mov  ah, 02h
    ;   int  21h
    ;   pop  ax
    ;   pop  dx

                                      mov  ah, 3Eh
                                      mov  bx, bx
                                      int  21h


    done_reading:                     
                                      xor  bx, bx
                                      xor  si, si
                                      mov  data_pointer, offset memory
                                      jmp  main_program_loop

    input:                            
                                      mov  ah, 3fh                              ; syscall read file
                                      mov  bx, 0                                ; from stdin
                                      mov  cx, 1                                ; bytes to read
                                      mov  dx, data_pointer                     ; to current pointer
                                      int  21h
            
    enter_check:                      
                                      mov  bx, data_pointer
                                      cmp  word ptr ds:[bx], 0Dh
                                      jne  eof_check
    ; if read 0Dh, read again to get only 0Ah
                                      mov  ah, 3fh                              ; syscall read file
                                      mov  bx, 0                                ; from stdin
                                      mov  cx, 1                                ; bytes to read
                                      mov  dx, data_pointer                     ; to current pointer
                                      int  21h

    eof_check:                        
                                      cmp  ax, 0                                ; if EOF - ax == 0
                                      je   if_eof
                                      jmp  main_program_loop
    if_eof:                           
                                      mov  bx, data_pointer
                                      mov  word ptr ds:[bx], -1
                                      jmp  main_program_loop

    main_program_loop:                
                                      cmp  si, [count]
                                      jae  short exit
                                      mov  dl, [program + si]
                                      inc  si
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
                                      mov  dl, [program + si]
                                      inc  si
                                      cmp  dl, '['
                                      je   nested_loop_that_shouldnt_perform
                                      cmp  dl, ']'
                                      je   end_of_loop
                                      jmp  find_end_and_finish

    end_of_loop:                      
                                      cmp  ax, 0
                                      jne  short end_of_nested_loop
                                      pop  dx                                   ; pop the pointer to last [
                                      jmp  short main_program_loop

    end_of_nested_loop:               
                                      dec  ax
                                      jmp  short find_end_and_finish

    exit:                             
                                      mov  ax, 4C00h                            ; Terminate the program
                                      int  21h

    increment:                        
                                      mov  bx, data_pointer
                                      mov  ax, word ptr ds:[bx]
                                      inc  ax
                                      mov  word ptr ds:[bx], ax
                                      jmp  main_program_loop

    decrement:                        
                                      mov  bx, data_pointer
                                      mov  ax, word ptr ds:[bx]
                                      dec  ax
                                      mov  word ptr ds:[bx], ax
                                      jmp  main_program_loop

    output:                           
                                      mov  bx, data_pointer
                                      mov  ax, word ptr ds:[bx]                 ; Load the next character to print
    ;   cmp  ax, 0Ah                              ; Check if it's linefeed
    ;   jne  short print_char                           ; If not, jump to print the character
    ;   mov  dl, 0Dh                              ; Set DL to carriage return
    ;   mov  ah, 02h                              ; DOS function: Print character in DL
    ;   int  21h                                  ; Call DOS interrupt to print carriage return
    print_char:                       
                                      mov  dl, al                               ; Load the character to DL for printing
                                      mov  ah, 02h                              ; DOS function: Print character in DL
                                      int  21h                                  ; Call DOS interrupt to print character
                                      jmp  main_program_loop

    shift_left:                       
                                      add  data_pointer, -2
                                      jmp  main_program_loop

    shift_right:                      
                                      add  data_pointer, 2
                                      jmp  main_program_loop

    begin_loop:                       
                                      mov  bx, data_pointer
                                      cmp  word ptr ds:[bx], 0
                                      je   short loop_should_not_perform
                                      dec  si
                                      push si
                                      inc  si
                                      jmp  main_program_loop
    
    end_loop:                         
                                      pop  si
                                      jmp  main_program_loop

    loop_should_not_perform:          
                                      dec  si
                                      push si
                                      inc  si
                                      xor  ax, ax
                                      jmp  find_end_and_finish

end start