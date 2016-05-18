; compile with: nasm -felf64 hello.nasm -o hello.o
; link with: ld hello.o -o hello
; to see the size of each instruction: objdump -M intel -d hello
global _start

section .text

_start:
  ;print on screen
  mov rax, 1 ; syscall for write (we could use just mov al, 1)
  mov rdi, 1 ; stdout file descriptor (we could use just mov dil, 1)
  mov rsi, hello_world
  mov rdx, length ; (we could use just mov dl, length)
  syscall

  ;exit
  mov rax, 60 ; (we could use just mov al, 60)
  mov rdi, 0 ; (we could use just mov dil, 1)
  syscall

section .data
  hello_world: db 'Hello world!', 0xa ; 0xa to insert a line break
  length: equ $-hello_world ; current location ($) - hello_world location
