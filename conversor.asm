;##############################################################################
;## TP Intel 80x86: Conversor de numeros
;## Desarrollar en assembler Intel 80x86 un programa que permita el ingreso de
;## numeros enteros en base 10 o base 8 y permita hacer la conversion a esas
;## mismas bases.
;##
;##
;## * falta validar que el numero ingresado este en la base correcta
;## * preguntar como debuguear cuando espero input x teclado
;##############################################################################

segment pila stack
		resb 64
stacktop:

segment datos data
	resultado db '    $'

	msj_ayuda db 'Utilice la calculadora para convertir numeros de base 10 a base 8, o viceversa ',10,13,'$'
	msj_ingreso_base db 10,13,'Por favor, ingrese la base del numero a convertir: $'

	msj_base_invalido db 10,13,'Puede ingresar 8 o 10, vuelva a ingresar la base por favor.',10,13,'$'
	msj_num_invalido db 10,13,'Rango permitido: 0 - 255, vuelva a ingresar el numero por favor.',10,13,'$'

	msj_ingreso_num db 10,13,'Por favor, ingrese el numero a convertir: $'

	msj_base_10_a_8 db 10,13,'El numero en base 8 es: $'
	msj_base_8_a_10 db 10,13,'El numero en base 10 es: $'

	numero resb 1
	numero_base resb 1

		   db 4
		   db 0
	cadena times 4 resb 1

	msj_continuar db 10,13,10,13,'Desea calcular otro numero? (S para continuar): $'

segment codigo code
..start: 	mov ax,datos
			mov ds,ax
			mov es,ax

			mov ax,pila
			mov ss,ax

			mov sp,stacktop

			mov dx,msj_ayuda
			call ver_msj

;########## ingreso base ######################################################
inicio:		lea dx,[msj_ingreso_base]
			call ver_msj

			lea dx,[cadena-2]
			mov ah,0ah
			int 21h

			; paso cadena a numero. en bl seteo la base del numero ingresado x teclado
			mov bx,0
			mov bl,10
			call cadena_a_num

			mov dl,byte[numero]
			mov byte[numero_base],dl

;######### validacion base ####################################################

			cmp byte[numero_base],8
			je ing_num
			cmp byte[numero_base],10
			je ing_num

			mov dx,msj_base_invalido
			call ver_msj
			jmp inicio

;########## ingreso numero ####################################################
ing_num:	mov dx,0
			lea dx,[msj_ingreso_num]
			call ver_msj

			lea dx,[cadena-2]
			mov ah,0ah
			int 21h

;######### validacion numero ####################################################
			cmp byte[cadena],2dh ; es negativo?
			je invalido

			cmp byte[cadena-1],3
			jb num_valido

			cmp byte[cadena],50
			ja invalido

			cmp byte[cadena+1],53
			ja invalido
			cmp byte[cadena+2],53
			ja invalido

			jmp num_valido

invalido:	mov dx,msj_num_invalido
			call ver_msj
			jmp ing_num

num_valido:
			; paso cadena a numero. en bl seteo la base del numero ingresado x teclado
			mov bx,0
			mov bl,byte[numero_base]
			call cadena_a_num

			cmp byte[numero_base],8

;########## si la base es 8 paso a base 10 ####################################
			je conv_base_10

;########## sino, paso a base 8 ###############################################

;########## Conversion de base 10 a base 8 ####################################
conv_base_8:
			mov dx,msj_base_10_a_8
			call ver_msj

			mov bh,byte[numero]

			; tengo que pasar a base 8 (2^3=8), por lo tanto como tomo de a 3 bits
			; y 8 bits/3 bits=2,66, entonces, itero 3 veces
			mov cx,3

			mov si,2

sig: 		; corrimiento a derecha
			mov bl,0
			shr bx,3
			; corrimiento a derecha
			shr bl,5

			; sumo 48 para imprimir caracter
			mov ah,bl
			add ah,48

			mov byte[resultado+si],ah
			dec si

			loop sig

			mov dx,resultado
			call ver_msj

			jmp continuar

;########## Conversion de base 8 a base 10 ####################################
conv_base_10:
			mov dx,msj_base_8_a_10
			call ver_msj

			mov bl,byte[numero]

			mov byte[resultado],32
			mov byte[resultado+1],32
			mov byte[resultado+2],32
			mov byte[resultado+3],32

			mov ax,0
			mov al,bl
			mov bx,10

			div bl

			add al,48
			add ah,48

			mov byte[resultado],al
			mov byte[resultado+1],ah

			mov dx,resultado
			call ver_msj

			jmp continuar

;########## consulto si desea continuar usando el conversor ###################
continuar:	mov dx,msj_continuar
			call ver_msj

;########## leo caracter ######################################################
			mov ah,1
			int 21h

			cmp al,'S'
			je inicio

fin:		mov ax,4c00h
			int 21h

ver_msj:	mov ah,9
			int 21h
			ret

cadena_a_num:   ;en bl se guarda la base, en numero queda el resultado
				mov cx,0
				mov dx,0

				mov cl,[cadena-1]
				mov si,0
				mov byte[numero],0

				mov dh,bl

calcular:		mov dl,cl
				dec dl
				mov bl,dh
				call calcular_potencia

				; resto 48 para obtener el num decimal
				sub byte[cadena+si],48
				; multiplico por potencia de diez ^ posicion
				mov al,byte[cadena+si]
				mul bl

				add [numero],ax
				inc si

				loop calcular

				ret

calcular_potencia:  ; en bl la base, en dl el exponente, en bx queda el resultado
				push cx

				mov cl,bl
				mov bl,1

				cmp dl,0
				je fin_calc_pot

sumar:			mov al,cl
				mul bl

				mov bx,0
				add bx,ax

				dec dl
				cmp dl,0
				jne sumar

fin_calc_pot:	pop cx
				ret
