.model tiny 
.data
    program         db 10001 dup(?)  
    memory          dw 10002 dup(?)  
.code
                                      org  100h

    start:                            

    ; for debug
    ; mov ax, @data
    ; mov ds, ax

                                      mov  bl, ds:[80h]
                                      add  bx, 81h
                                      mov  byte ptr ds:[bx], 0

                                      mov  ah, 3dh                                    ; syscall open file
                                      mov  dx, 82h                                    ; address at which command line is stored
                                      int  21h
                                      mov  bx, ax
 
                                      mov  ah, 3fh                                    ; syscall read file
                                      mov  cx, 10001                                  ; bytes to read
                                      lea  dx, program                                ; to read into code_buffer
                                      int  21h
                                      mov  cx, ax
                                      lea  bx, program
                                      add  bx, cx
                                      inc  bx
                                      mov  ds:[bx], byte ptr 0
                                      mov  bx, 0
    init_data_buffer_loop:            
                                      mov  byte ptr ds:[memory + bx], 0
                                      inc  bx
                                      cmp  bx, 20000
                                      jne  short init_data_buffer_loop
                                      mov  bx, 2
                                      xor  si, si
                                      jmp  short main_program_loop

    input:                            
                                      mov  ah, 3Fh
                                      push bx
                                      mov  bx, 0                                      ; stdin handle
                                      push cx
                                      mov  cx, 1                                      ; 1 byte to read
                                      lea  dx, memory                                 ; buffer to read into
                                      int  21h                                        ; read into buffer
                                      pop cx
                                      cmp  al, 0                                      ; Check if the number of bytes read is 0 (EOF)
                                      jne  short char_read                            ; If not EOF, continue as before
                                      pop  bx
                                      mov  [memory + bx], 0FFFFh                      ; Set the buffer element at DI to -1 (0xFFFF)
                                      jmp  short main_program_loop

    char_read:                        
                                      mov  ax, [memory]
                                      pop  bx
                                      cmp  al, 0Dh
                                      je   input                                      ; load the read byte into al
                                      mov  [memory + bx], ax                          ; store the byte into the current tape position
    main_program_loop:                
                                      cmp  si, cx
                                      jae  short exit
                                      mov  al, [program + si]
                                      inc  si
                                      cmp  al, '+'
                                      je   increment
                                      cmp  al, '-'
                                      je   decrement
                                      cmp  al, '.'
                                      je   output
                                      cmp  al, ','
                                      je   input
                                      cmp  al, '>'
                                      je   shift_right
                                      cmp  al, '<'
                                      je   shift_left
                                      cmp  al, '['
                                      je   begin_loop
                                      cmp  al, ']'
                                      je   end_loop
                                      jmp  short main_program_loop

                                      
    nested_loop_that_shouldnt_perform:
                                      inc  dx
    find_end_and_finish:              
                                      mov  al, [program + si]
                                      inc  si
                                      cmp  al, '['
                                      je   short nested_loop_that_shouldnt_perform
                                      cmp  al, ']'
                                      je   short  end_of_loop
                                      jmp  short find_end_and_finish

    end_of_loop:                      
                                      cmp  dx, 0
                                      jne  short end_of_nested_loop
                                      pop  dx                                         ; pop the pointer to last [
                                      jmp  short main_program_loop

    end_of_nested_loop:               
                                      dec  dx
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
                                      xor  dx, dx
                                      jmp  find_end_and_finish
end start