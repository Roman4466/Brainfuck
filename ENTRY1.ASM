.model tiny
.code
             ORG 0100h
    start:   
             mov ah, 0Ah            ; DOS function: Buffered input
             lea dx, buffer         ; Pointer to the input buffer
             int 21h                ; Call DOS interrupt
             mov ax, 4C00h
             int 21h

    buffer   db  255                ; Input buffer size
             db  ?                  ; Actual size read
             db  255 dup(0)         ; Buffer to store the command line input

    filename db  'filename.b', 0    ; Buffer to store the filename, needs to be parsed from command line
    program  db  10000 dup(0)       ; Buffer to store the Brainfuck program

end start

