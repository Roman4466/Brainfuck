++++++++++ ++++++++++ ++++++++++ ++++++++++ ++++++++++
++++++++++ ++++++++++ ++++++++++ ++++++++++ ++++++++++
++++++++++ ++++++++++ ++++++++++ ++++++++++ ++++++++++
++++++++++ ++++++++++ ++++++++++ ++++++++++ ++++++++++
++++++++++ ++++++++++ ++++++++++ ++++++++++ ++++++++++
now the first cell contains the value 250
>,     ; read a character from stdin (will be 202)
[<->-] ; decrease them both simultaniously in order to
       ; check that 202 is zero extended when read
<.     ; print out the resulting 0

++++++++++ ++++++++++ ++++++++++ ++++++++++ ++++++++++
++++++++++ ++++++++++ ++++++++++ ++++++++++ ++++++++++
++++++++++ ++++++++++ ++++++++++ ++++++++++ ++++++++++
++++++++++ ++++++++++ ++++++++++ ++++++++++ ++++++++++
++++++++++ ++++++++++ ++++++++++ ++++++++++ ++++++++++

now the first cell contains the value 298
>,     ; read a character from stdin (will be 250)
[<->-] ; decrease them both simultaniously in order to
       ; check that values above 255 work
<.     ; print out the resulting 0
