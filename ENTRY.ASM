.model tiny 
.data
    program db 10001 dup(?)
    memory  dw 10002 dup(?)
    suck dw ?
.code
                                      org   100h
    start:                            
                                      mov   bl, ds:[80h]
                                      add   bx, 81h
                                      mov   byte ptr ds:[bx], 0

                                      mov   ah, 3dh                                    ; syscall open file
                                      mov   dx, 82h                                    ; address at which command line is stored
                                      int   21h
                                      mov   bx, ax
                                      mov   ah, 3fh                                    ; syscall read file
                                      mov   cx, 10001                                  ; bytes to read
                                      lea   dx, program                                ; to read into code_buffer
                                      int   21h
                                      mov   cx, 20000
                                      lea   bx, memory
    init_data_buffer_loop:            
                                      mov   byte ptr [bx], 0
                                      inc   bx
                                      loop  init_data_buffer_loop
                                      lea   di, memory
                                      lea   si, program
                                      mov   BP, ax
                                      add   BP, si
                                      jmp   short main_program_loop

    input:                            
                                      mov   ah, 3Fh
                                      xor   bx, bx                                     ; stdin handle
                                      mov   cx, 1                                      ; 1 byte to read
                                      lea   dx, suck                                 ; buffer to read into
                                      int   21h                                        ; read into buffer
                                      cmp   al, 0                                      ; Check if the number of bytes read is 0 (EOF)
                                      jnz   short char_read                            ; If not EOF, continue as before
                                      mov   ax, 0FFFFh                      ; Set the buffer element at DI to -1 (0xFFFF)
                                      jmp   short set_char_in_memory

    char_read:                        
                                      mov   ax, [suck]
                                      cmp   al, 0Dh
                                      jz    input
    set_char_in_memory:                                                                ; load the read byte into al
                                      mov   word ptr [di], ax                          ; store the byte into the current tape position
    main_program_loop:                
                                      cmp   si, BP
                                      jae   short exit
                                      lodsb
                                      cmp   al, '+'
                                      jz    increment
                                      cmp   al, '-'
                                      jz    decrement
                                      cmp   al, '.'
                                      jz    output
                                      cmp   al, ','
                                      jz    input
                                      cmp   al, '>'
                                      jz    shift_right
                                      cmp   al, '<'
                                      jz    shift_left
                                      cmp   al, '['
                                      jz    begin_loop
                                      cmp   al, ']'
                                      jz    end_loop
                                      jmp   short main_program_loop
    exit:                             
                                      int   20h
                                      
    nested_loop_that_shouldnt_perform:
                                      inc   dx
    find_end_and_finish:              
                                      lodsb
                                      cmp   al, '['
                                      jz    short nested_loop_that_shouldnt_perform
                                      cmp   al, ']'
                                      jnz   short  find_end_and_finish
                                      cmp   dx, 0
                                      jnz   short end_of_nested_loop
                                      pop   dx                                         ; pop the pointer to last [
                                      jmp   short main_program_loop

    end_of_nested_loop:               
                                      dec   dx
                                      jmp   short find_end_and_finish

    increment:                        
                                      inc   word ptr [di]
                                      jmp   short main_program_loop

    decrement:                        
                                      dec   word ptr [di]
                                      jmp   short main_program_loop

    begin_loop:                       
                                      dec   si
                                      push  si
                                      inc   si
                                      cmp   word ptr [di], 0
                                      jnz   main_program_loop
                                      xor   dx, dx
                                      jmp   find_end_and_finish

    output:                           
                                      mov   dx,  word ptr [di]
                                      mov   ah, 02h                                    ; DOS function: Print character in DL
                                      cmp   dx, 0Ah                                    ; Check if it's linefeed
                                      jnz   short print_char
                                      mov   dl, 0Dh                                    ; Set DL to carriage return
                                      int   21h
                                      mov   dl, 0Ah                                    ; Set DL to carriage return
    print_char:                                                                        ; Load the character to DL for printing
                                      int   21h                                        ; Call DOS interrupt to print character
                                      jmp   main_program_loop

    shift_left:                       
                                      sub   di, 2
                                      jmp   main_program_loop

    shift_right:                      
                                      add   di, 2
                                      jmp   main_program_loop
    
    end_loop:                         
                                      pop   si
                                      jmp   main_program_loop
end start