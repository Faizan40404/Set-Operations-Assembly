org 0x0100
jmp start
; Set A
setA_size: dw 0 
setA_data: db 0,0,0,0,0,0,0,0,0,0

; Set B  
setB_size: dw 0
setB_data: db 0,0,0,0,0,0,0,0,0,0

; Set C (for results)
setC_size: dw 0
setC_data: db 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0     ;union can have 20

; Some basic messages
title_msg1: db 'DISCRETE SET OPERATIONS',0
title_msg2: db '=======================',0

menu_msg1:  db 'A. Add to Set A', 0
menu_msg2:  db 'B. Add to Set B',0
menu_msg3:  db 'C. Delete from A',0
menu_msg4:  db 'D. Delete from B',0
menu_msg5:  db 'E. Check in Set A',0
menu_msg6:  db 'F. Check in Set B',0
menu_msg7:  db 'G. Union',0
menu_msg8:  db 'H. Intersection ',0
menu_msg9:  db 'I. Difference ',0
menu_msg10: db 'J. Symmetric Difference',0
menu_msg11: db 'K. Check A subset B',0
menu_msg12: db 'L. Check A strict subset B',0
menu_msg13: db 'M. Powerset of A',0
menu_msg14: db 'N. Powerset of B',0
menu_msg15: db 'O. Cartesian Product',0
menu_msg16: db 'P. Size of A',0
menu_msg17: db 'Q. Size of B',0
menu_msg18: db 'R. A is Empty?',0
menu_msg19: db 'S. B is Empty?',0
menu_msg20: db 'T. Clear All Sets',0
menu_msg21: db 'Z. Exit',0
menu_msg22: db 'Choice: ',0

setA_msg: db 'Set A: ',0
setB_msg: db 'Set B: ',0
setC_msg: db 'Set C: ',0

; Additional messages for operations
emptyA: db 'A is empty',0
emptyB: db 'B is empty',0
notEmptyA: db 'A is not empty',0
notEmptyB: db 'B is not empty',0
empty: db 'Set is empty',0

isSubset: db 'A is subset of B',0
notSubset: db 'A is NOT subset of B',0
isStrict: db 'A is strict subset of B',0
notStrict: db 'A is NOT strict subset of B',0

sizeA: db 'Size of A is ',0
sizeB: db 'Size of B is ',0

powersetA: db 'Powerset of A:',0
powersetB: db 'Powerset of B:',0

inputPrompt:db 'Enter input: (0-255) ',0
outBounds:db 'Out of Bounds! (Not added/deleted) ',0
duplicate: db 'Set cant have duplicate. (Not added/deleted)',0
inputSuccess: db 'Input added!',0
deleteSuccess:db 'Element deleted!',0

full: db 'Set is full!',0
exists: db 'Element exists',0
notExists: db 'Element not found',0
result: db 'Result: ',0

cartesianProd: db 'Cartesian Product A x B:',0

err_msg: db 'Invalid choice! Press any key to continue...',0
;Clears the screen
clrscr:
   push ax
   push cx
   push es
   push di

   mov ax,0xb800
   mov es,ax
   xor di,di
   mov ax,0x0720
   mov cx,2000
   rep stosw

   pop di
   pop es
   pop cx
   pop ax
   ret

;[bp+4]->str
;[bp+6]->ds
;returns length in ax
strlen:
   push bp
   mov bp,sp
   push es
   push di
   push si
   push cx

   les di,[bp+4]
   mov al,0
   mov cx,0xffff
   repne scasb
   mov ax,0xffff
   sub ax,cx
   dec ax

   pop cx
   pop si
   pop di
   pop es
   pop bp
   ret 4

;[bp+4]->str
;[bp+6]->row
;[bp+8]->col
;[bp+10]->design
;Prints a string
printstr:
   push bp
   mov bp,sp
   push es
   push si
   push di
   push ax
   push cx
   push bx

   mov ax,[bp+6]
   mov cx,80
   mul cx
   add ax,[bp+8]
   shl ax,1
   mov di,ax

   push ds
   mov bx,[bp+4]
   push bx
   call strlen
   mov cx,ax

   mov ax,0xb800
   mov es,ax
   mov ax,[bp+10]
   mov si,[bp+4]
   print:
      lodsb
      stosw
      loop print

   pop bx
   pop cx
   pop ax
   pop di
   pop si
   pop es
   pop bp
   ret 8

;[bp+4]->num
;[bp+6]->row
;[bp+8]->col
;[bp+10]->design
;Prints a number
printnum:
   push bp
   mov bp,sp
   push es
   push si
   push di
   push ax
   push cx
   push bx
   push dx

   mov ax,[bp+6]
   mov cx,80
   mul cx
   add ax,[bp+8]
   shl ax,1
   mov di,ax

   mov ax,[bp+4]
   xor cx,cx
   mov bx,10
   store:
      xor dx,dx
      div bx
      inc cx
      push dx
      cmp ax,0
      jne store
   
   mov bx,[bp+10]
   mov ax,0xb800
   mov es,ax
   show:
      pop ax
      add al,'0'
      mov ah,bh
      stosw
      loop show

   pop dx
   pop bx
   pop cx
   pop ax
   pop di
   pop si
   pop es
   pop bp
   ret 8

;print using interupts. used for cartesian product.    
printNumberInt:
    push ax
    push bx
    push cx
    push dx
    
    xor cx,cx
    mov bl, 10
pushDigit:
    xor ah,ah
    div bl
    inc cx
    push ax
    cmp al,0
    jne pushDigit
    mov bl,7
printDigit:
    pop ax
    mov al,ah
    mov ah,0xE
    add al,'0'
    int 10h
    loop printDigit 
    
done_print:
    pop dx 
    pop cx
    pop bx
    pop ax
    ret
    
clearC:
    push ax
    push di
    push es
    push cx
    
    push ds
    pop es
    mov al,0

    mov di,setC_data
    mov cx,20
    rep stosb


    mov word [setC_size],0
    pop cx
    pop es
    pop di
    pop ax
    ret    
    
getCharInp:
    ; Move cursor
    mov ah,2
    mov bh,0
    mov dh,14
    mov dl,8
    int 10h

    ; Get character
    mov ah,0
    int 16h

    cmp al,'A'
    jb getCharInp        
    cmp al,'z'
    ja getCharInp       
    cmp al,'Z'
    jbe ok

    ; Here AL > Z
    cmp al,'a'
    jb getCharInp

ok:
    cmp al,'Z'
    jbe echo
    sub al,20h
echo:
    mov ah,0Eh
    mov bl,7
    int 10h
    ret

    
;Prints the title
printTitle:
    push word 0x0F00        
    push word 28
    push word 0
    push word  title_msg1
    call printstr
    
    push word 0x0F00        
    push word 28
    push word 1
    push word  title_msg2
    call printstr
    
    ret
    
;Prints the menu options
printMenu:
    push cx
    
    ; Start from row 3
    mov cx, 3
    
    ; Column 1 (A-J)
    push word 0x0700        
    push word 0
    push cx
    push word menu_msg1
    call printstr
    inc cx
    
    push word 0x0700        
    push word 0
    push cx
    push word menu_msg2
    call printstr
    inc cx
    
    push word 0x0700        
    push word 0
    push cx
    push word menu_msg3
    call printstr
    inc cx
    
    push word 0x0700        
    push word 0
    push cx
    push word menu_msg4
    call printstr
    inc cx
    
    push word 0x0700        
    push word 0
    push cx
    push word menu_msg5
    call printstr
    inc cx
    
    push word 0x0700        
    push word 0
    push cx
    push word menu_msg6
    call printstr
    inc cx
    
    push word 0x0700        
    push word 0
    push cx
    push word menu_msg7
    call printstr
    inc cx
    
    push word 0x0700        
    push word 0
    push cx
    push word menu_msg8
    call printstr
    inc cx
    
    push word 0x0700        
    push word 0
    push cx
    push word menu_msg9
    call printstr
    inc cx
    
    push word 0x0700        
    push word 0
    push cx
    push word menu_msg10
    call printstr
    inc cx
    
    ; Column 2 (J-T, 0) - start at row 3 again
    mov cx, 3
    
    push word 0x0700        
    push word 40
    push cx
    push word menu_msg11
    call printstr
    inc cx
    
    push word 0x0700        
    push word 40
    push cx
    push word menu_msg12
    call printstr
    inc cx
    
    push word 0x0700        
    push word 40
    push cx
    push word menu_msg13
    call printstr
    inc cx
    
    push word 0x0700        
    push word 40
    push cx
    push word menu_msg14
    call printstr
    inc cx
    
    push word 0x0700        
    push word 40
    push cx
    push word menu_msg15
    call printstr
    inc cx
    
    push word 0x0700        
    push word 40
    push cx
    push word menu_msg16
    call printstr
    inc cx
    
    push word 0x0700        
    push word 40
    push cx
    push word menu_msg17
    call printstr
    inc cx
    
    push word 0x0700        
    push word 40
    push cx
    push word menu_msg18
    call printstr
    inc cx
    
    push word 0x0700        
    push word 40
    push cx
    push word menu_msg19
    call printstr
    inc cx
    
    push word 0x0700        
    push word 40
    push cx
    push word menu_msg20
    call printstr
    inc cx
    
    push word 0x0700        
    push word 40
    push cx
    push word menu_msg21
    call printstr
    inc cx
    
    push word 0x0A00        
    push word 0
    push cx
    push word menu_msg22
    call printstr
    
    pop cx
    ret

;[bp+4] -> set_data
;[bp+6] -> set_size  
;[bp+8] -> row
;[bp+10] -> col
;[bp+12] -> attr
displaySet:
    push bp
    mov bp, sp
    push es
    push di
    push si
    push ax
    push bx
    push cx
    push dx
    
    ; Video position
    mov ax, [bp+8]
    mov bx, 80
    mul bx
    add ax, [bp+10]
    shl ax, 1
    mov di, ax
    
    mov ax, 0xb800
    mov es, ax
    mov ax, [bp+12]
    
    
    mov al, '{'
    stosw
    
    ; Size
    mov bx, [bp+6]
    mov cx,[bx]
    cmp cx, 0
    je end
    
    mov si, [bp+4]
loopAll:
    push cx
    mov al,[si]
    mov ah,0
    xor cx,cx
    mov bx,10
storeNum:
    xor dx,dx
    div bx
    inc cx
    push dx
    cmp ax,0
    jne storeNum
   
    mov bx,[bp+12]
showNum:
    pop ax
    add al,'0'
    mov ah,bh
    stosw
    loop showNum
    
    pop cx
    cmp cx,1
    je noCom
    mov al,','
    stosw
    mov al,' '
    stosw
noCom:
    inc si
    loop loopAll
    
end:
    ; }
    mov al, '}'
    stosw
    
done:
    pop dx
    pop cx
    pop bx
    pop ax
    pop si
    pop di
    pop es
    pop bp
    ret 10

showAllSets:
    push word 0x0700
    push word 0 
    push word 22 
    push word setA_msg
    call printstr
    
    push word 0x0700        
    push word 6             
    push word 22          
    push word setA_size     
    push word setA_data  
    call displaySet
    
    push word 0x0700
    push word 0 
    push word 23
    push word setB_msg
    call printstr
    
    push word 0x0700        
    push word 6             
    push word 23           
    push word setB_size     
    push word setB_data     
    call displaySet
    
    push word 0x0700
    push word 0 
    push word 24
    push word setC_msg
    call printstr
    
    push word 0x0700        
    push word 6             
    push word 24           
    push word setC_size     
    push word setC_data     
    call displaySet

    ret
    
;Result in AX
takeInput:
    push bx
    push cx
    push dx
    push si
    
    xor bx, bx
    xor si, si          
    
input_loop:
    mov ah, 0x00
    int 0x16
    
    cmp al, 0x0D    ;Enter
    je input_done
    
    cmp al, 0x08    ;Backspace
    je handle_backspace
    
    ; Check if digit '0'-'9'
    cmp al, '0'
    jl input_loop
    cmp al, '9'
    jg input_loop
    
    ; show valid dijit
    mov ah, 0x0E
    int 0x10
    
    ; Increment digit counter
    inc si
    
    ; Convert ASCII to number
    sub al, '0'
    mov ah, 0
    mov cx, ax          ; cx = new digit
    
    ; Multiply current result by 10 and add new digit
    mov ax, bx
    mov dx, 10
    mul dx
    add ax, cx         
    mov bx, ax          
    
    jmp input_loop

handle_backspace:
    
    cmp si, 0
    je input_loop       ; nothing to delete
    
    dec si
    
    ; Move cursor back
    mov ah, 0x0E
    mov al, 0x08        ; backspace
    int 0x10
    mov al, ' '         ; space to erase
    int 0x10
    mov al, 0x08        ; backspace again
    int 0x10
    
    ; Remove last digit from result 
    mov ax, bx
    xor dx, dx
    mov cx, 10
    div cx              
    mov bx, ax
    
    jmp input_loop

input_done:
    mov ah, 0x0E  
    mov al, 0x0D   ;start at current line
    int 0x10
    mov al, 0x0A   ;very next line
    int 0x10
    
    ; Return result in AX
    mov ax, bx
    
    pop si
    pop dx
    pop cx
    pop bx
    ret
;Adds 1 element to set
;[bp+4]->size
;[bp+6]->set
addToSet:
    push bp
    mov bp,sp
    push ax
    push bx
    push cx
    push dx
    push si

    push word 0x0A00        ; Green color
    push word 0             
    push word 18            
    push word inputPrompt
    call printstr
    
    ;cursor at required pos
    mov ah,2
    mov dh,18
    mov dl,21
    mov bx,0
    int 0x10
    call takeInput 

    ; Check if input > 255
    cmp ax, 255
    jg outOfBounds
    
    ; Check if set is full (max 10 elements)
    mov bx, [bp+4]
    mov cx, [bx]
    cmp cx, 10
    jge setFull
    
    ; Check for duplicate if set is not empty
    cmp cx, 0
    je addElement       
    
    mov si, [bp+6]
checkDuplicate:
    cmp al, [si]
    je duplicateFound
    inc si
    loop checkDuplicate
    
addElement:
    mov si, [bp+6]
    add si, [bx]
    mov [si], al
    
    inc word [bx]
    
    ; Success message
    push word 0x0A00        ; Green color
    push word 21
    push word 19           
    push word inputSuccess
    call printstr
    jmp waitAndReturn
    
outOfBounds:
    push word 0x0C00        ; Red color
    push word 21            
    push word 19            
    push word outBounds
    call printstr
    jmp waitAndReturn
    
setFull:
    push word 0x0C00        ; Red color
    push word 21            
    push word 19            
    push word full
    call printstr
    jmp waitAndReturn
    
duplicateFound:
    push word 0x0C00        ; Red color
    push word 21            
    push word 19            
    push word duplicate
    call printstr

waitAndReturn:
    ; Wait for key press
    mov ah, 0x00
    int 0x16
    
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    pop bp
    ret 4


clearAll:
    push ax
    push di
    push es
    push cx

    push ds
    pop es
    mov al,0

    mov di,setA_data
    mov cx,10
    rep stosb

    mov di,setB_data
    mov cx,10
    rep stosb

    mov di,setC_data
    mov cx,20
    rep stosb

    mov word [setA_size],0
    mov word [setB_size],0
    mov word [setC_size],0

    pop cx
    pop es
    pop di
    pop ax
    ret


;[bp+4]->size
;[bp+6]->string
sizeOf:
    push bp
    mov bp,sp
    push ax
    push bx
    
    push word 0x0A00 
    push word 0             
    push word 18            
    push word [bp+6]
    call printstr

    push word 0x0A00 
    push word 13             
    push word 18            
    mov bx, [bp+4]
    mov ax,[bx]
    push ax
    call printnum

    mov ah,00
    int 0x16

    pop bx
    pop ax
    pop bp
    ret 4

emptyOfA:
    cmp word [setA_size],0
    je yesA

    push word 0x0700 
    push word 0             
    push word 18            
    push word notEmptyA
    call printstr
    jmp okA
yesA:
    push word 0x0700 
    push word 0             
    push word 18            
    push word emptyA
    call printstr
okA:
    mov ah,00
    int 0x16

    ret

emptyOfB:
    cmp word [setB_size],0
    je yesB

    push word 0x0700 
    push word 0             
    push word 18           
    push word notEmptyB
    call printstr
    jmp okB
yesB:
    push word 0x0700 
    push word 0             
    push word 18            
    push word emptyB
    call printstr
okB:
    mov ah,00
    int 0x16
    ret
    
intersection:
    push bp
    mov bp,sp
    push si
    push di
    push ax
    push cx 
    push bx
    
    xor bx,bx
    call clearC   
    
    cmp word [setA_size],0
    je intersectionDone
    cmp word [setB_size],0
    je intersectionDone
    
    mov si,setA_data
    mov cx,[setA_size]
intersectionOuter:
    push cx
    mov cx,[setB_size]
    mov di,setB_data
    mov al,[si]
intersectionInner:
    cmp al,[di]
    je same
    jmp notSame
same:
    mov [setC_data+bx],al
    inc bx
    jmp break1
notSame:
    inc di
    loop intersectionInner
break1:
    pop cx
    inc si
    loop intersectionOuter
    mov [setC_size],bx
intersectionDone:    
    pop bx
    pop cx
    pop ax
    pop di
    pop si
    pop bp
    ret

difference:
    push bp
    mov bp,sp
    push si
    push di
    push ax
    push cx 
    push bx
    
    xor bx,bx
    call clearC   
    
    cmp word [setA_size],0
    je differenceDone
    cmp word [setB_size],0
    je copyA
    
    mov si,setA_data
    mov cx,[setA_size]
differenceOuter:
    push cx
    mov cx,[setB_size]
    mov di,setB_data
    mov al,[si]
differenceInner:
    cmp al,[di]
    je match
    inc di
    loop differenceInner
notMatch:
    mov [setC_data+bx],al
    inc bx
match:
    pop cx
    inc si
    loop differenceOuter
    mov [setC_size],bx
    jmp differenceDone
    
copyA:
    mov ax,[setA_size]
    mov [setC_size],ax
    mov cx,ax
    push ds
    pop es
    mov si,setA_data
    mov di,setC_data
    rep movsb
    
differenceDone:    
    pop bx
    pop cx
    pop ax
    pop di
    pop si
    pop bp
    ret
    
symDifference:
    push bp
    mov bp,sp
    push si
    push di
    push ax
    push cx 
    push bx
    
    xor bx,bx
    call clearC   
    
    cmp word [setA_size],0
    je copyBinC
    cmp word [setB_size],0
    je copyAinC
    
    mov si,setA_data
    mov cx,[setA_size]
symDifferenceOuter1:
    push cx
    mov cx,[setB_size]
    mov di,setB_data
    mov al,[si]
symDifferenceInner1:
    cmp al,[di]
    je match1
    inc di
    loop symDifferenceInner1
notMatch1:
    mov [setC_data+bx],al
    inc bx
match1:
    pop cx
    inc si
    loop symDifferenceOuter1
    
    mov si,setB_data
    mov cx,[setB_size]
symDifferenceOuter2:
    push cx
    mov cx,[setA_size]
    mov di,setA_data
    mov al,[si]
symDifferenceInner2:
    cmp al,[di]
    je match2
    inc di
    loop symDifferenceInner2
notMatch2:
    mov [setC_data+bx],al
    inc bx
match2:
    pop cx
    inc si
    loop symDifferenceOuter2
    mov [setC_size],bx
    jmp symDifferenceDone    
    
copyAinC:
    mov ax,[setA_size]
    mov [setC_size],ax
    mov cx,ax
    push ds
    pop es
    mov si,setA_data
    mov di,setC_data
    rep movsb
    jmp symDifferenceDone
copyBinC:
    mov ax,[setB_size]
    mov [setC_size],ax
    mov cx,ax
    push ds
    pop es
    mov si,setB_data
    mov di,setC_data
    rep movsb
    
symDifferenceDone:    
    pop bx
    pop cx
    pop ax
    pop di
    pop si
    pop bp
    ret    

union:
    push bp
    mov bp,sp
    push si
    push di
    push ax
    push cx 
    push bx
    
    cmp word [setA_size],0
    je placeBinC
    
placeAinC:
    mov ax,[setA_size]
    mov [setC_size],ax
    mov cx,ax
    push ds
    pop es
    mov si,setA_data
    mov di,setC_data
    rep movsb
    mov bx,ax
    
    cmp word [setB_size],0
    je unionDone
    
    mov si,setB_data
    mov cx,[setB_size]
unionOuter:
    push cx
    mov cx,[setC_size]
    mov di,setC_data
    mov al,[si]
unionInner:
    cmp al,[di]
    je alike
    inc di
    loop unionInner
notalike:
    mov [setC_data+bx],al
    inc bx
alike:
    pop cx
    inc si
    loop unionOuter
    mov [setC_size],bx
    jmp unionDone
    
placeBinC:
    mov ax,[setB_size]
    mov [setC_size],ax
    mov cx,ax
    push ds
    pop es
    mov si,setB_data
    mov di,setC_data
    rep movsb
    mov bx,ax
    
unionDone:
    pop bx
    pop cx
    pop ax
    pop di
    pop si
    pop bp
    ret
    
cartesianProdPrint:
    push bp
    mov bp,sp
    push es
    push di
    push si
    push cx
    push ax
    push bx
    
    push word 0x0A00        
    push word 0
    push word 15
    push word cartesianProd
    call printstr

    call clearC
    cmp word [setA_size],0
    je near showEmpty
    cmp word [setB_size],0
    je near showEmpty
    
    mov ah,2
    mov dh,15
    mov dl,25
    mov bx,0
    int 0x10     ;bring cursor to position
    
    mov ah,0xE
    mov bl,07
    mov al,'{'
    int 0x10
    
    mov si,setA_data
    mov cx,[setA_size]
cartesian_outer:
    push cx
    mov di,setB_data
    mov cx,[setB_size]
cartesian_inner:

    mov ah,0xE    ;start_bracket
    mov bl,07
    mov al,'('
    int 0x10
    
    mov ah,0xE    
    mov bl,07
    mov al,[si]    ;x-coordinate
    call printNumberInt
    
    mov ah,0xE
    mov bl,07
    mov al,','
    int 0x10
    
    mov ah,0xE    
    mov bl,07
    mov al,[di]   ;y-coordinate
    call printNumberInt
    
    mov ah,0xE    ;print end bracket
    mov bl,07
    mov al,')'
    int 0x10
    
    cmp cx,1
    je noComma1

    mov ah,0xE
    mov bl,07
    mov al,','
    int 0x10
    
    mov ah,0xE
    mov bl,07
    mov al,' '
    int 0x10
noComma1:
    inc di
    loop cartesian_inner
    pop cx
    cmp cx,1
    je noComma2
    mov ah,0xE
    mov bl,07
    mov al,','
    int 0x10
    
    mov ah,0xE
    mov bl,07
    mov al,' '
    int 0x10
noComma2:
    inc si
    loop cartesian_outer
    
    mov ah,0xE
    mov bl,07
    mov al,'}'
    int 0x10
    jmp prodDone
    
showEmpty:
    mov ah,2
    mov dh,15
    mov dl,25
    mov bx,0
    int 0x10     ;bring cursor to position
    
    mov ah,0xE
    mov bl,07
    mov al,'{'
    int 0x10
    
    mov ah,0xE
    mov bl,07
    mov al,'}'
    int 0x10
    jmp prodDone
    
prodDone:  
    mov ah,00
    int 16h
    
    pop bx
    pop ax
    pop cx
    pop si
    pop di
    pop es
    pop bp
    ret

;A subset of B
checkSubset:
    push bp
    mov bp, sp
    push si
    push di
    push cx
    push bx
    
    cmp word [setA_size], 0
    je showIsSubset
    cmp word [setB_size], 0
    je showNotSubset
    
    mov si, setA_data
    mov cx, [setA_size]
subOuter:
    push cx
    mov al, [si]           
    mov di, setB_data
    mov cx, [setB_size]
subInner:
    cmp al, [di]
    je foundInB           
    inc di
    loop subInner

    pop cx
    jmp showNotSubset
    
foundInB:
    pop cx
    inc si
    loop subOuter

    jmp showIsSubset
    
showIsSubset:
    push word 0x0A00        ; Green color
    push word 0
    push word 18
    push word isSubset
    call printstr
    jmp subsetDone
    
showNotSubset:
    push word 0x0C00        ; Red color
    push word 0
    push word 18
    push word notSubset
    call printstr
    
subsetDone:
    ; Wait for key press
    mov ah, 00
    int 0x16
    
    pop bx
    pop cx
    pop di
    pop si
    pop bp
    ret

; A strict subset of B
checkStrictSubset:
    push bp
    mov bp, sp
    push si
    push di
    push cx
    push bx
    
    cmp word [setA_size], 0
    je checkIfBEmpty

    cmp word [setB_size], 0
    je showNotStrict
    
    ; First check if all elements of A are in B
    mov si, setA_data
    mov cx, [setA_size]
strictOuter:
    push cx
    mov al, [si]
    mov di, setB_data
    mov cx, [setB_size]
    
strictInner:
    cmp al, [di]
    je foundElementInB
    inc di
    loop strictInner
    ; Element not found in B
    pop cx
    jmp showNotStrict
    
foundElementInB:
    pop cx
    inc si
    loop strictOuter
 
    mov ax, [setA_size]
    cmp ax, [setB_size]
    jl showIsStrict      

    jmp showNotStrict
    
checkIfBEmpty:
    ; check if A and B both are empty
    cmp word [setB_size], 0
    je showNotStrict      
    jmp showIsStrict
    
showIsStrict:
    push word 0x0A00        ; Green color
    push word 0
    push word 18
    push word isStrict
    call printstr
    jmp strictDone
    
showNotStrict:
    push word 0x0C00        ; Red color
    push word 0
    push word 18
    push word notStrict
    call printstr
    
strictDone:
    ; Wait for key press
    mov ah, 00
    int 0x16
    
    pop bx
    pop cx
    pop di
    pop si
    pop bp
    ret
    
Structure:
    call clrscr
    call printTitle
    call printMenu
    call showAllSets
    ret

; Function to delete element from set B
;[bp+4]->size
;[bp+6]->set
deleteFromSet:
    push bp
    mov bp,sp
    push ax
    push bx
    push cx
    push dx
    push si
    
    mov bx,[bp+4]
    cmp word [bx],0
    je setEmpty
    
    ; Prompt for input
    push word 0x0A00        ; Green color
    push word 0
    push word 18
    push word inputPrompt
    call printstr
    
    ; Position cursor for input
    mov ah, 2
    mov dh, 18
    mov dl, 21
    mov bx, 0
    int 0x10
    
    call takeInput
    
    ; Check if input > 255
    cmp ax, 255
    jg outOfBoundsDel
    
    mov bx,[bp+4]
    mov si, [bp+6]
    mov cx, [bx]
    xor dx,dx
searchElement:
    cmp al, [si]
    je foundElement
    inc si
    inc dx
    loop searchElement
    
    ; Element not found
    push word 0x0C00        ; Red color
    push word 21
    push word 19
    push word notExists
    call printstr
    jmp waitKeyDel
    
foundElement:
    mov di, si            
    inc si                

    mov cx, [bx]
    sub cx, dx
    dec cx                
    
    jcxz lastElement
    
shiftLeftB:
    rep movsb
    
lastElement:
    dec word [bx]
    
    ; Success message
    push word 0x0A00        ; Green color
    push word 21
    push word 19
    push word deleteSuccess
    call printstr
    jmp waitKeyDel
    
setEmpty:
    push word 0x0C00        ; Red color
    push word 0
    push word 18
    push word empty
    call printstr
    jmp waitKeyDel
    
outOfBoundsDel:
    push word 0x0C00        ; Red color
    push word 21
    push word 19
    push word outBounds
    call printstr

waitKeyDel:
    ; Wait for key press
    mov ah, 00
    int 0x16
    
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    pop bp
    ret 4

;[bp+4]->size
;[bp+6]->set
; Function to check if element exists in set A
checkInSet:
    push bp
    mov bp,sp
    push ax
    push bx
    push cx
    push dx
    push si
    
    ; Check if set A is empty
    mov bx,[bp+4]
    cmp word [bx], 0
    je setEmptyCheck
    
    ; Prompt for input
    push word 0x0A00        ; Green color
    push word 0
    push word 18
    push word inputPrompt
    call printstr
    
    ; Position cursor for input
    mov ah, 2
    mov dh, 18
    mov dl, 21
    mov bx, 0
    int 0x10
    
    ; Get input
    call takeInput
    
    ; Check if input > 255
    cmp ax, 255
    jg outOfBoundsCheck
    
    ; Search for element in set A
    mov si, [bp+6]
    mov bx,[bp+4]
    mov cx, [bx]

searchElementIn:
    cmp al, [si]
    je elementFound
    inc si
    loop searchElementIn
    
    ; Element not found
    push word 0x0C00        ; Red color
    push word 21
    push word 19
    push word notExists
    call printstr
    jmp waitKeyCheck
    
elementFound:
    ; Element found
    push word 0x0A00        ; Green color
    push word 21
    push word 19
    push word exists
    call printstr
    jmp waitKeyCheck
    
setEmptyCheck:
    push word 0x0C00        ; Red color
    push word 0
    push word 18
    push word empty
    call printstr
    jmp waitKeyCheck
    
outOfBoundsCheck:
    push word 0x0C00        ; Red color
    push word 21
    push word 19
    push word outBounds
    call printstr

waitKeyCheck:
    ; Wait for key press
    mov ah, 00
    int 0x16
    
    pop si
    pop dx
    pop cx
    pop bx
    pop ax
    pop bp
    ret 4

need_comma: db 0
; ======= POWERSET FOR SET A =======
show_powerset_A:
    mov byte [need_comma],0
    ; Display title
    push word 0x0A00    
    push word 0
    push word 18       
    push word powersetA 
    call printstr
    
    mov ah, 0x02
    mov bh, 0x00
    mov dh, 18         
    mov dl, 14      
    int 0x10
    
    mov ah, 0x0E
    mov al, '{'
    int 0x10
    
    ; Check if set A is empty
    mov ax, [setA_size]
    cmp ax, 0
    je .empty_set
    
    ; Calculate 2^n (n = size of set A)
    mov cx, ax          
    mov ax, 1
    jcxz .no_calc       
    
.calc_power:
    shl ax, 1           ; Multiply by 2
    loop .calc_power
    
.no_calc:
    mov dx, ax          ; DX = total subsets (2^n)
    
    mov bx, 0           ; BX = subset counter
    
.subset_loop:
    mov ah, 0x0E
    mov al, '{'
    int 0x10
    
    cmp bx, 0
    je .empty_subset
    
    mov si, setA_data   ; Start of set data
    mov di, 0           ; DI = bit position (0, 1, 2...)
    mov cx, [setA_size] ; CX = size of set
    mov bp, bx          ; BP = mask copy
    
    mov byte [need_comma], 0  ; Flag for comma between elements
    
.display_elements:
    ; Check if bit at position DI is set
    mov ax, bp          ; Get mask
    push cx             ; Save CX (element counter)
    mov cx, di          ; CX = bit position to check
    shr ax, cl          ; Shift mask right by bit position
    pop cx              ; Restore CX
    test al, 1          ; Check LSB
    jz .skip_element    ; Bit not set, skip
    
    ; Bit is set - print this element
    cmp byte [need_comma], 0
    je .first_element
    
    ; Not first element - print comma
    mov ah, 0x0E
    mov al, ','
    int 0x10
    mov al, ' '
    int 0x10
    
.first_element:
    mov byte [need_comma], 1  ; Set comma flag
    
    ; Print element value
    mov al, [si]
    call printNumberInt
    
.skip_element:
    inc si              ; Next element in set
    inc di              ; Next bit position
    loop .display_elements
    
    jmp .close_subset
    
.empty_subset:
    ; Empty subset - nothing between braces
    
.close_subset:
    ; Display closing brace for this subset
    mov ah, 0x0E
    mov al, '}'
    int 0x10
    
    ; Check if last subset
    inc bx
    cmp bx, dx
    jge .done
    
    ; Not last subset - print comma and space
    mov ah, 0x0E
    mov al, ','
    int 0x10
    mov al, ' '
    int 0x10
    
    jmp .subset_loop
    
.empty_set:
    mov ah, 0x0E
    mov al, '{'
    int 0x10
    mov al, '}'
    int 0x10
    
.done:
    mov ah, 0x0E
    mov al, '}'
    int 0x10
    ; Wait for key press
    mov ah, 0x00
    int 0x16
    
    ret

; ======= POWERSET FOR SET B =======
show_powerset_B:
    mov byte [need_comma],0
    ; Display title
    push word 0x0A00    
    push word 0
    push word 18       
    push word powersetB
    call printstr
    
    mov ah, 0x02
    mov bh, 0x00
    mov dh, 18         
    mov dl, 14      
    int 0x10
    
    mov ah, 0x0E
    mov al, '{'
    int 0x10
    
    ; Check if set A is empty
    mov ax, [setB_size]
    cmp ax, 0
    je .empty_setB
    
    ; Calculate 2^n (n = size of set A)
    mov cx, ax          
    mov ax, 1
    jcxz .no_calcB      
    
.calc_powerB:
    shl ax, 1           ; Multiply by 2
    loop .calc_powerB
    
.no_calcB:
    mov dx, ax          ; DX = total subsets (2^n)
    
    mov bx, 0           ; BX = subset counter
    
.subset_loopB:
    mov ah, 0x0E
    mov al, '{'
    int 0x10
    
    cmp bx, 0
    je .empty_subsetB
    
    mov si, setB_data   ; Start of set data
    mov di, 0           ; DI = bit position (0, 1, 2...)
    mov cx, [setB_size] ; CX = size of set
    mov bp, bx          ; BP = mask copy
    
    mov byte [need_comma], 0  ; Flag for comma between elements
    
.display_elementsB:
    ; Check if bit at position DI is set
    mov ax, bp          ; Get mask
    push cx             ; Save CX (element counter)
    mov cx, di          ; CX = bit position to check
    shr ax, cl          ; Shift mask right by bit position
    pop cx              ; Restore CX
    test al, 1          ; Check LSB
    jz .skip_elementB   ; Bit not set, skip
    
    ; Bit is set - print this element
    cmp byte [need_comma], 0
    je .first_elementB
    
    ; Not first element - print comma
    mov ah, 0x0E
    mov al, ','
    int 0x10
    mov al, ' '
    int 0x10
    
.first_elementB:
    mov byte [need_comma], 1  ; Set comma flag
    
    ; Print element value
    mov al, [si]
    call printNumberInt
    
.skip_elementB:
    inc si              ; Next element in set
    inc di              ; Next bit position
    loop .display_elementsB
    
    jmp .close_subsetB
    
.empty_subsetB:
    ; Empty subset - nothing between braces
    
.close_subsetB:
    ; Display closing brace for this subset
    mov ah, 0x0E
    mov al, '}'
    int 0x10
    
    ; Check if last subset
    inc bx
    cmp bx, dx
    jge .doneB
    
    ; Not last subset - print comma and space
    mov ah, 0x0E
    mov al, ','
    int 0x10
    mov al, ' '
    int 0x10
    
    jmp .subset_loopB
    
.empty_setB:
    mov ah, 0x0E
    mov al, '{'
    int 0x10
    mov al, '}'
    int 0x10
    
.doneB:
    mov ah, 0x0E
    mov al, '}'
    int 0x10
    ; Wait for key press
    mov ah, 0x00
    int 0x16
    
    ret


; Main menu routine that uses getCharInp
mainMenu:
    call Structure
    
menu_loop:
    
    ; Get user choice using getCharInp
    call getCharInp
    
    ; Process the menu choice
    cmp al, 'A'
    je near option_A
    cmp al, 'B'
    je near option_B
    cmp al, 'C'
    je near option_C
    cmp al, 'D'
    je near option_D
    cmp al, 'E'
    je near option_E
    cmp al, 'F'
    je near option_F
    cmp al, 'G'
    je near option_G
    cmp al, 'H'
    je near option_H
    cmp al, 'I'
    je near option_I
    cmp al, 'J'
    je near option_J
    cmp al, 'K'
    je near option_K
    cmp al, 'L'
    je near option_L
    cmp al, 'M'
    je near option_M
    cmp al, 'N'
    je near option_N
    cmp al, 'O'
    je near option_O
    cmp al, 'P'
    je near option_P
    cmp al, 'Q'
    je near option_Q
    cmp al, 'R'
    je near option_R
    cmp al, 'S'
    je near option_S
    cmp al, 'T'
    je near option_T
    cmp al, 'Z'
    je near exit_program
    
    ; Invalid choice - show error message
    push word 0x0C00
    push word 0
    push word 18
    push word err_msg
    call printstr
    
    ; Wait for key press
    mov ah, 00
    int 0x16
    
    ; Redraw and continue
    call Structure
    jmp menu_loop

; Menu option handlers
option_A:
    push word setA_data
    push word setA_size
    call addToSet
    call Structure
    jmp menu_loop

option_B:
    push word setB_data
    push word setB_size
    call addToSet
    call Structure
    jmp menu_loop

option_C:
    push word setA_data
    push word setA_size
    call deleteFromSet
    call Structure
    jmp menu_loop

option_D:
    push word setB_data
    push word setB_size
    call deleteFromSet
    call Structure
    jmp menu_loop

option_E:
    push word setA_data
    push word setA_size
    call checkInSet
    call Structure
    jmp menu_loop

option_F:
    push word setB_data
    push word setB_size
    call checkInSet
    call Structure
    jmp menu_loop

option_G:
    call union
    call Structure
    jmp menu_loop

option_H:
    call intersection
    call Structure
    jmp menu_loop

option_I:
    call difference
    call Structure
    jmp menu_loop

option_J:
    call symDifference
    call Structure
    jmp menu_loop

option_K:
    call checkSubset
    call Structure
    jmp menu_loop

option_L:
    call checkStrictSubset
    call Structure
    jmp menu_loop

option_M:
    call show_powerset_A
    call Structure
    jmp menu_loop

option_N:
    call show_powerset_B
    call Structure
    jmp menu_loop

option_O:
    call cartesianProdPrint
    call Structure
    jmp menu_loop

option_P:
    push word sizeA
    push word setA_size
    call sizeOf
    call Structure
    jmp menu_loop

option_Q:
    push word sizeB
    push word setB_size
    call sizeOf
    call Structure
    jmp menu_loop

option_R:
    call emptyOfA
    call Structure
    jmp menu_loop

option_S:
    call emptyOfB
    call Structure
    jmp menu_loop

option_T:
    call clearAll
    call Structure
    jmp menu_loop

exit_program:
    ret

start:
    call mainMenu
    mov ax,4c00h
    int 21h