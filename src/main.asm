; MINIMAL BIOS PROGRAM
; Copyright @em 2022

org 0x7c00            ; Offset to give BIOS space
bits 16               ; Emit 16-bit code

main:
	hlt

.halt:                ; Infinite loop in case it doesn't properly halt
	jmp .halt


                      ; BIOS requires that last two bytes of sector are AA55
                      ; So that's what this is for, 
		      ; going to the end of the sector and storing AA55

times 510-($-$$) db 0 ; Padding file with 0x00
                      ; until 510 where the signiature resides
                      ; $ means current, $$ means size of file
		      ; so this is, in C,

		      ; while(510-(current-file_size) > 0)
		      ; And then just padding

dw 0AA55h             ; dw is like db, but for 2-byte consts called 'words'
                      ; This is the signiature that BIOS needs to identify
		      ; this as a bootable device
		      ; This instruction is little-endian
