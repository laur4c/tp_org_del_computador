;##############################################################################
;## TP Intel 80x86: Conversor de numeros
;## Desarrollar en assembler Intel 80x86 un programa que permita el ingreso de
;## numeros enteros en base 10 o base 8 y permita hacer la conversion a esas
;## mismas bases.
;##
;##
;## * falta validar que el numero ingresado este en la base correcta
;## * bug en la validacion de la base, como leo de a byte para ver si la entrada fue
;## 8, 80 es un ingreso valido :/
;##############################################################################

segment pila stack
		resb 64
stacktop:

segment datos data
	resultado db "    $"

	msj_ayuda db 'Utilice la calculadora para convertir numeros de base 10 a base 8, o viceversa ',10,13,'$'
	msj_ingreso_base db 10,13,'Por favor, ingrese la base del numero a convertir: $'
	msj_input_invalido db 10,13,'Puede ingresar 8 o 10, vuelva a ingresar la base por favor.',10,13,'$'
	msj_ingreso_num db 10,13,'Ahora, ingrese el numero a convertir: $'

	msj_base_10_a_8 db 10,13,'El numero en base 8 es: $'
	msj_base_8_a_10 db 10,13,'El numero en base 10 es: $'

				db 3
				db 0
	cadena_base times 3 resb 1

			   db 4
			   db 0
	cadena_num times 4 resb 1

	msj_continuar db 10,13,10,13,'Desea calcular otro numero? (S para continuar): $'

segment codigo code
..start: 	mov ax,datos
			mov ds,ax

			mov ax,pila
			mov ss,ax

			mov sp,stacktop

			mov dx,msj_ayuda
			call ver_msj

;########## ingreso base ######################################################
inicio:		lea dx,[msj_ingreso_base]
			call ver_msj

			lea dx,[cadena_base-2]
			mov ah,0ah
			int 21h

;######### validacion input ###################################################
			; preguntar como hacer validacion de cadena ingresada x teclado
			; mov cx,2
			; mov si,cadena_base
			; mov di,56
			; repe cmpsb

			cmp byte[cadena_base],'8'
			je valido
			cmp word[cadena_base],'10'
			je valido

			mov dx,msj_input_invalido
			call ver_msj
			jmp inicio

;########## ingreso numero ####################################################
valido:		mov dx,0
			lea dx,[msj_ingreso_num]
			call ver_msj

			lea dx,[cadena_num-2]
			mov ah,0ah
			int 21h

			cmp byte[cadena_base],56 ; 56=8

;########## si la base es 8 paso a base 10 ####################################
			je conv_base_10

;########## sino, paso a base 8 ###############################################

;########## Conversion de base 10 a base 8 ####################################
conv_base_8:
			mov dx,msj_base_10_a_8
			call ver_msj

			mov bh,byte[cadena_num]
			sub bh,48

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