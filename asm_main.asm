%include "asm_io.inc"

;These Macros Control the Size of the array and The scalar it is being multiplied by 
%define ARRAY_SIZE DWORD 5
%define SCALAR 5

; initialized data is put in the .data segment
segment .data
        syswrite: equ 4
        stdout: equ 1
        exit: equ 1
        SUCCESS: equ 0
        kernelcall: equ 80h
        
        ;Defining an array of 5 16 bit elements predefined to 1,2,3,4,5
        a1: dw 1,2,3,4,5


; uninitialized data is put in the .bss segment
segment .bss


; code is put in the .text segment
segment .text
        extern printf ;Need access to the printf function to display array 
        global  asm_main
asm_main:
        enter   0,0               ; setup routine
        pusha
        
        mov eax, a1 ;Moving the address of a1 array into eax 
        ;void print_array(int a[], int size);
        ;Calling my print_array function to display how the array originally looks 
        push ARRAY_SIZE ;passing in the size to function
        push eax ;Passing in the address of the first element of the array into function
        call print_array          
        add esp,8 ; Deallocating parameter memory 
        call print_nl ;Print a newline
        
        ;void mult_array(int a[], int size, int scalar)
        push SCALAR ;Passing the scalar to multiply array by to function
        push ARRAY_SIZE ;Passing the size to function 
        push eax ;Passing in the address of the first element of the array into funciton
        call mult_array 
        add esp, 12 ;Deallocating parameter memory 

        ;void print_array(int a[], int size);
        ;Trying to see how array looks after WE Multiply it by Scalar
        push ARRAY_SIZE ;passing in the size to function
        push eax ;Passing in the address of the first element of the array into function
        call print_array          
        add esp,8 ; Deallocating parameter memory 
        call print_nl ;Print a newline


        popa
        mov     eax, SUCCESS       ; return back to the C program
        leave                     
        ret

;void mult_array(int a[], int size, int scalar)
;STACK 
;   Address of Array = ebp +8
;   Size of array = ebp +12
;   Sclar to multiply array by = ebp + 16
mult_array:
enter 0,0 ;Creating stack frame
pusha ;Pushing all registers

XOR ecx, ecx ;Ecx = i = 0 
XOR eax, eax ; eax = a[i] * scalar
mov ebx, DWORD[ebp+8] ; Moving the address of the array into ebx
.for:
    cmp ecx, DWORD[ebp+12] 
    jge .done ;If i >= size of array we are done 
    mov ax, word[ebx + 2 * ecx] ; ax = a[i]
    mul word[ebp+16] ; ax = a[i] *scalar
    mov word[ebx+2 *ecx], ax ; a[i] = ax 
    inc ecx ;i++
    jmp short .for ;Go back to for loop

.done:
popa
leave
ret ;Returning back 


;void print_array(int a[], int size);
;STACK
;   int size = ebp +12 
;   Array Address = ebp + 8 
;   Return Address = ebp +4
print_array:
enter 0,0 ;Creating stack frame
pusha ;pushing all registers
mov ecx, DWORD[ebp+12] ;ecx = Array_size
XOR eax, eax ;Eax = 0 Going to use later
mov ebx, [ebp+8] ;Ebx = The address of the first element of array 
mov edx, 0 ; Edx = offset
for:
mov ax, WORD[ebx + 2 * edx] ; Moving the element value into a 16 bit register
movzx eax, ax ; Extending the answer in ax into a DWORD
push eax;Pushing the elements of array on stack 
call print_int ; Printing the array element 
add esp, 4 ;Deallocating memory 
inc edx ;Going to the next Array element offset++
loop for; Stop the loop once ecx = 0
popa
leave ;Destroying Stack frame
ret ;Return back 


