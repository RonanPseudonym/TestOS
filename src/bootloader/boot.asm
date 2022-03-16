; MINIMAL BIOS PROGRAM
; Copyright em 2022

%define ENDL 0x0d, 0x0a ; NASM macro, so that you don't have to mess around
                        ; with cryptic ASCII stuff

org 0x7c00              ; Offset to give BIOS space
bits 16                 ; Emit 16-bit code

                        ; FAT12 header
                
jmp short start
nop

                        ; FAT12 HEADER

bdp_oem                    db 'MSWIN4.1' ; 8 bytes
bdp_bytes_per_sector:      dw 512
bdp_sectors_per_cluster:   db 1
bdp_reserved_sectors:      dw 1
bdp_fat_count:             db 2
bdp_dir_entries_count:     dw 0E0h
bdp_total_sectors:         dw 2880 ; 2880 * 512 = 1.44MB
bdp_media_descriptor_type: db 0F0h ; F0 = 3.5" floppy disk
bdp_sectors_per_fat:       dw 9
bdp_sectors_per_track:     dw 18
bdp_heads:                 dw 2
bdp_hidden_sectors:        dd 0
bdp_large_sector_count:    dd 0

                        ; EXTENDED BOOT RECORD

ebr_drive_number:          db 0 ; Useless
			   db 0 ; Reserved
ebr_signiature:            db 29h
ebr_volume_id:             db 1, 2, 3, 4
ebr_volume_layer:          db 'EM/OS'
ebr_system_id:             db 'FAT12   ' ; Padded with spaces


start:
	jmp main        ; Make sure that program starts at main, not puts

puts:                   ; Print string

		        ; Params:
		        ;   ds:si points to string

		        ; Will print characters until it incounters NULL (0)

	push si         ; Pushing si & ax to the stack, where they can be
	push ax         ; referenced in .loop

.loop:
	lodsb           ; Loads bite from ds:si into al register and then
	                ; increments si

	or al, al       ; (0 | 0) is 0, everything else is 1
	                ; So the only time the zero flag gets set is if al == 0

	jz .done        ; Jump if the zero flag is set, jz is "jump zero"

	mov ah, 0x0e    ; Call the BIOS TTY function thing
	mov bh, 0       ; Set the page number to 0, compatibility thing?
	int 0x10        ; Call the video interrupt

	jmp .loop       ; Otherwise loop back, this time with the incremented
	                ; si

.done:
	pop ax          ; Clean up the stack, removing what was added in puts
	pop si          ; Assembly has no garbage collector...
	                ; Because it doesn't need one! It's too based

	ret             ; Return from subroutine
		

main:
                        ; Set up data segments

	mov ax, 0       ; Can't copy directly so have to do this
	mov ds, ax
	mov es, ax

	mov ss, ax
	mov sp, 0x7C00  ; Stack grows downward from where we are loaded
		        ; in memory

		        ; If we set it up at the end of the program, it
		        ; would overrite the code

	mov si, msg_hello
	call puts       ; si is now the address of msg_hello, so when puts
	                ; gets si it will be the location of msg_hello's
			; contents

        hlt
		       

.halt:                  ; Infinite loop in case it doesn't properly halt
	jmp .halt

msg_hello: 
	db 'trans rights <3', ENDL, 0
	                ; Setting the label msg_hello to my string, followed
			; by the newline character denoted in my macro
			; equvilent to \n, followed by a string terminator (0)


                        ; BIOS requires that last two bytes of sector are AA55
                        ; So that's what this is for, 
		        ; going to the end of the sector and storing AA55

times 510-($-$$) db 0   ; Padding file with 0x00
                        ; until 510 where the signiature resides
                        ; $ means current, $$ means size of file
		        ; so this is, in C,

		        ; while(510-(current-file_size) > 0)
		        ; And then just padding

dw 0AA55h               ; dw is like db, but for 2-byte consts called 'words'
                        ; This is the signiature that BIOS needs to identify
		        ; this as a bootable device
		        ; This instruction is little-endian
