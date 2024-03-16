.model tiny 
.data
    program         db 10001 dup(?)  
    memory          dw 10002 dup(?)  
    code_read       dw 1 dup(?)

.code
                                      org  100h

    start:                            

    ; for debug
    ; mov ax, @data
    ; mov ds, ax

    place_null_char:                  
                                      mov  cl, ds:[80h]
                                      xor  ch, ch
                                      mov  bx, 81h
                                      add  bx, cx
                                      mov  byte ptr ds:[bx], 0

    open_file:                        
                                      mov  ah, 3dh                                    ; syscall open file
                                      mov  al, 0                                      ; read-only
                                      mov  dx, 82h                                    ; address at which command line is stored
                                      int  21h
                                      mov  bx, ax
 
    read_file:                        
                                      mov  ah, 3fh                                    ; syscall read file
                                      mov  cx, 10001                                  ; bytes to read
                                      lea  dx, program                                ; to read into code_buffer
                                      int  21h
                                      mov  code_read, ax
    place_null:                       
                                      lea  bx, program
                                      add  bx, code_read
                                      inc  bx
                                      mov  ds:[bx], byte ptr 0
                                      mov  bx, 0
    init_data_buffer_loop:            
                                      mov  byte ptr ds:[memory + bx], 0
                                      inc  bx
                                      cmp  bx, 20000
                                      jne  init_data_buffer_loop
                                      mov  bx, 2
                                      xor  si, si
                                      jmp  short main_program_loop

    input:                            
                                      mov  ah, 3Fh
                                      push bx
                                      mov  bx, 0                                      ; stdin handle
                                      mov  cx, 1                                      ; 1 byte to read
                                      lea  dx, memory                                 ; buffer to read into
                                      int  21h                                        ; read into buffer
                                      cmp  ax, 0                                      ; Check if the number of bytes read is 0 (EOF)
                                      jne  short char_read                            ; If not EOF, continue as before
                                      pop  bx
                                      mov  [memory + bx], 0FFFFh                      ; Set the buffer element at DI to -1 (0xFFFF)
                                      jmp  short main_program_loop

    char_read:                        
                                      mov  ax, [memory]
                                      pop  bx
                                      cmp  ax, 0Dh
                                      je   input                                      ; load the read byte into al
                                      mov  [memory + bx], ax                          ; store the byte into the current tape position
    main_program_loop:                
                                      cmp  si, [code_read]
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
                                      jmp  short main_program_loop

                                      
    nested_loop_that_shouldnt_perform:
                                      inc  ax
    find_end_and_finish:              
                                      mov  dl, [program + si]
                                      inc  si
                                      cmp  dl, '['
                                      je   short nested_loop_that_shouldnt_perform
                                      cmp  dl, ']'
                                      je   short  end_of_loop
                                      jmp  short find_end_and_finish

    end_of_loop:                      
                                      cmp  ax, 0
                                      jne  short end_of_nested_loop
                                      pop  dx                                         ; pop the pointer to last [
                                      jmp  short main_program_loop

    end_of_nested_loop:               
                                      dec  ax
                                      jmp  short find_end_and_finish

    exit:                             
                                      mov  ax, 4C00h                                  ; Terminate the program
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

    output:                           
                                      mov  dx, [memory + bx]                          ; Load the next character to print
                                      cmp  dx, 0Ah                                    ; Check if it's linefeed
                                      jne  short print_char
                                      push dx                                         ; If not, jump to print the character
                                      mov  dl, 0Dh                                    ; Set DL to carriage return
                                      mov  ah, 02h                                    ; DOS function: Print character in DL
                                      int  21h
                                      pop  dx                                         ; Call DOS interrupt to print carriage return
    print_char:                                                                       ; Load the character to DL for printing
                                      mov  ah, 02h                                    ; DOS function: Print character in DL
                                      int  21h                                        ; Call DOS interrupt to print character
                                      jmp  main_program_loop

    shift_left:                       
                                      add  bx, -2
                                      jmp  main_program_loop

    shift_right:                      
                                      add  bx, 2
                                      jmp  main_program_loop

    begin_loop:                       
                                      cmp  [memory + bx], 0
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