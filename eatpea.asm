DATAS SEGMENT
    ; �ӳ�ʱ�����ͣ������
    DELAYTIME db 03H ; �ӳ�ʱ�䣬��������
    pause_counter db 0 ; ����һ���ֽ��ͱ��� pause_counter����ʼ��Ϊ 0
    current_position dw ? ; �����洢�Զ��˵ĵ�ǰλ��
    ; ģʽ��ر���
    MODEFLAG db 0   ; ģʽѡ���־
 	MODE1 db 'START' ; ģʽ 1: ��ʼ
    MODE2 db 'QUIT'; ģʽ 2: �˳�
    TIPS3 db 'MODE SELECT' ; ��ʾģʽѡ���ַ���
    
    ; ��ֱ�ո�
    TIPS1 db 'I', 0EH, 'N', 0EH, 'S', 0EH, 'T', 0EH, 'R', 0EH, 'U', 0EH, 'C', 0EH, 'T', 0EH, 'I', 0EH, 'O', 0EH, 'N', 0EH, ':', 0EH
    ; ���ݶδ���
    WELCOME_MSG db 'WELCOME TO THE GAME!', 13, 10, '$'
    GOODBYE_MSG db 'GOOD BYE!', 13, 10, '$'

    temp1 dw ?
	temp2 dw ?;�����temp1��temp2
	STRING  db  'Press Space to Start or Press AnyKey to return',13,10,'$';�����ַ���
      
    mes1 db 'Name:';����
    mes2 db 'Student No:';ѧ��
    mes3 db 'Class:';�༶  
DATAS ENDS

STACKS SEGMENT
STACKS ENDS

CODES SEGMENT
    assume cs:codes,ds:datas,ss:stacks
    ;�Զ��ӹ����м������
	in al,60h  ; ��ȡ��������
	cmp al,57 ;�Ƚ��͵�al������57(��ascll���д���ʮ���Ƶ�9���Ĳ�
	jnz nospace; �������ȣ���ת�� nospace�����ǿո����
	mov cx,1
	nospace:
	mov al,20h  ; ���ո��ַ��� ASCII ֵ�ƶ��� al �Ĵ���
	out 20h,al ; �� al ������˿� 20H
	iret ;�жϷ��س���
    
START:
    mov ax,datas
    mov ds,ax
	; ������ƶ�����Ļ�м�
	mov ah, 02h ; ���ù��λ�ú���
	mov bh, 0   ; ҳ��Ϊ0
	mov dh, 10  ; ��������λ������Ϊ12
	mov dl, 27  ; ��������λ������Ϊ35
	int 10h     ;
	; ��ʾ��ӭ��Ϣ
    mov si, offset WELCOME_MSG
    call PrintStringDelay
    
SELECT:   
	 call Save
	 mov bp, offset TIPS3
	 mov cx, 11d;17���ַ�������
	 mov dh, 7;��ʾ�е�λ��
	 mov dl, 33;��ʾ�е�λ��
	 mov al, 01
	 mov bl, 0EH;�ַ���ʾ����ɫ����ɫ
	 mov ah, 13h;��ʾ�����Ե��ַ���
	 int 10h
	 call MODESELECT;ѡ��ģʽ
	 cmp MODEFLAG, 0
	 je GOGAME1
	 jmp exit
 
GOGAME1:
 	mov ah,02h;���ù��λ��
	mov bh,0
	mov dl,0
	mov dh,10;Ҫ����Ļ�ĵ�ʮ����ʾ�ַ�
	int 10h
	
	mov ah,02H ;���ù��λ��
	mov dl,'.' ;ȡҪ��ʾ���ַ���DL�ж��� 
	mov cx,25*80 ;Ĭ�������ʾ������80*25
	setpoint:
	int 21H 
	loop setpoint ;ѭ��������Ļ����ʾ '.'

	;����һ���ַ����ж��Ƿ���� 
	;����������ʾ
    mov  ax,datas
    mov  ds,ax
    lea  dx,string
    mov  ah,9
    int  21h

	mov ah,07h ;��������
	int 21h 
	cmp al,' ' ;�Ƚ�ָ��,�жϿո�
	jnz SELECT ;��Ϊ�ո�����ת
	
	;cx/dx��ջ�����ֳ�(��֤�ո���ʹ�ã�
	mov ax,0
	mov ds,ax 
	mov ax,datas 
	mov es,ax 
	mov bx,9*4+2 
	mov ax,[bx] 
	mov es:temp1,ax 
	mov ax,codes 
	mov [bx],ax 
	mov bx,9*4  
	mov ax,[bx] 
	mov es:temp2,ax 
	mov word ptr [bx],0 	
	;���ù��λ��
	mov ah,02H  
	mov bh,0 
	xor dx,dx ;��0
	int 10H
 	;�����Ļ����ʾ���ӺͳԶ���
	mov ax,0B800H 
	mov ds,ax
	xor bx,bx
	mov cx,80*25;Ĭ�������ʾ������80*25
eatpea:
	mov si,0B7FFH;������25��80���ı���ʾ��ʽ��
	nextone:
		sub si,1;��si-1��ֵ�͵�si
		jnz nextone;��Ϊ0�ͼ���si-1��������һ������	
		mov byte ptr [bx],' ';�ѡ� ���ĵ�һ���ֽڵ������͵�bx
		mov byte ptr [bx+2],'C';�ѡ�C���ĵ�һ���ֽڵ������͵�bx+2
		add bx,2	
	loop eatpea ;��80*25������
	;���ڳԶ��ӵ�ѭ����ͨ������Ļ���滻�ַ���ģ��Զ��ӵĹ��̡�
;   ��ѭ���У�ÿ�ζ�����ǰλ�õ��ַ��滻Ϊһ���ո񣬱�ʾ���ӱ��Ե��ˡ�
;ͬʱ���ڵ�ǰλ�õ���һ��λ�ã��� `BX+2` ���������ַ��滻Ϊ 'C'����ʾ�Զ��˵�λ�á�
	;ax/dx��ջ�ָ��ֳ�(���ո�����ã�
	mov ax,0
	mov ds,ax
	mov bx,9*4+2
	mov ax,es:temp1
	mov [bx],ax
	mov bx,9*4
	mov ax,es:temp2
	mov [bx],ax
	call pause_game
	
pause_game:
    ; ��ͣ��Ϸ���ȴ��û����ո������
    mov ah, 07H         ; ��������
    int 21H             
    cmp al, ' '         ; ����Ƿ����˿ո��
    jne SELECT          ; ������ǿո������������Ƿ���ͣ
    inc byte ptr [pause_counter] ; ÿ�ΰ��¿ո���������� 1
    call check_space    


check_space:
    mov al, [pause_counter]  ; �����¿ո���Ĵ������ص� al ��
    and al, 0               ; ��� al �����λ�����жϰ��¿ո���Ĵ�������������ż��
    jnz pause_game          ; ������������οո����������ͣ��Ϸ
    jmp GOGAME1          ; �������ż���οո�������� GOGAME1 ��ǩ��

exit:
	call Save
	
goodbye:
	 ; ������ƶ�����Ļ�м�
	 mov ah, 02h ; ���� AH �����ù��λ�ú���
	 mov bh, 0   ; ҳ��Ϊ0
	 mov dh, 10  ; ��������λ������Ϊ12
	 mov dl, 30  ; ��������λ������Ϊ35
	 int 10h     ; ���� BIOS �ж������ù��λ��
 
	 mov si, offset GOODBYE_MSG
	 call PrintStringDelay
	 call Save
	 
end_string:
	 mov bp, offset mes1
	 mov cx, 13d ;��ʾ�ַ����ĳ���
	 mov dh, 5
	 mov dl, 13
	 mov al, 01
	 mov bl, 0Eh
	 mov ah, 13h
	 int 10h
	 
	 mov bp, offset mes2
	 mov cx, 21d
	 mov dh, 6
	 mov dl, 13
	 mov al, 01
	 mov bl, 0Eh
	 mov ah, 13h
	 int 10h
	 
	 mov bp, offset mes3
	 mov cx, 13d
	 mov dh, 7
	 mov dl, 13
	 mov al, 01
	 mov bl, 0Eh
	 mov ah, 13h
	 int 10h
	 
	 mov ax,4C00H;
	 int 21H;����ϵͳ�ж�  

DELAY PROC    ; ��ʱ����
	 mov ah, 0	
	 int 1ah    ; ֱ�Ӷ�ȡʱ�Ӽ�����
	 mov bx, dx
	 mov ax, 0
	 mov al, DELAYTIME  ; ����DELAY���
	 add bx, ax
	DELAYLOP: mov AH, 0
	  int 1ah
	  cmp dx, bx
	  je DELAYNEXT
	  jmp DELAYLOP
	DELAYNEXT: RET
DELAY ENDP   
    
PrintStringDelay PROC
    ; ��ӡ�ַ��������ӳ�Ч��
    NEXT_CHAR:
        mov al, [si]
        cmp al, '$'        ; �ж��ַ�������
        je END_PRINT
        mov ah, 0EH        ; ��ʾ�ַ�
        mov bh, 0
        int 10h
        call Delay
        inc si
        jmp NEXT_CHAR
    END_PRINT:
        RET
PrintStringDelay ENDP    

Save PROC
    mov ax, datas
    mov ds, ax
    mov es, ax
    mov bx, 0       ; ���浱ǰ��ʾ��ʽ
    mov ah, 0FH     ; ��ȡ��Ƶģʽ
    int 10h

    mov al, 03h     ; ������ʾģʽ
    mov ah, 0
    int 10h
    RET             ; ����
Save ENDP

MODESELECT PROC    ; MODEѡ��˵�
	MODESELECTLOP1: 
  		CMP MODEFLAG, 0FFH ; �ж���ǰѡ��
  		JE MODESELECTLOP2   
		MOV AH, 06H ;��ʾ���Ϲ�������
  		MOV AL, 0;�������ڵ�����Ϊ 0
  		MOV BH, 07H
  		MOV CH, 12D;�������ڵ���ʼ�к�
  		MOV CL, 0;�������ڵ���ʼ�к�
  		MOV DH, 13D;�������ڵĽ����к�
  		MOV DL, 79;�������ڵĽ����к�
  		INT 10H
        ; ��ʾģʽѡ��
  		MOV AH, 13H
  		MOV BL, 9EH
  		MOV BH, 0
  		MOV BP, OFFSET MODE1
  		MOV AL, 1
  		MOV CX, 5; ����
  		MOV DH, 11; ��
 		MOV DL, 32D ; ��
  		INT 10H
  		; ��ʾģʽѡ��
  		MOV AH, 13H
  		MOV BL, 08H
  		MOV BH, 0
  		MOV BP, OFFSET MODE2
  		MOV AL, 1
  		MOV CX, 4
  		MOV DH, 11
  		MOV DL, 41D
  		INT 10H
  		JMP MODESELECTNEXT
	
	MODESELECTLOP2: 
		mov ah, 06h ; ��ʾ���Ϲ�������
		mov al, 0   ; ��ʾ�������ڵ�����Ϊ 0
		mov bh, 07h
		mov ch, 12d ; �������ڵ���ʼ�к�
		mov cl, 0   ; �������ڵ���ʼ�к�
		mov dh, 19d
		mov dl, 79
		int 10h
      ; ��ʾģʽѡ��
		mov ah, 13h
		mov bl, 08h
		mov bh, 0
		mov bp, offset MODE1
		mov al, 1
		mov cx, 5
		mov dh, 11
		mov dl, 32d
		int 10h
      ; ��ʾģʽѡ��
		mov ah, 13h
		mov bl, 9eh
		mov bh, 0
		mov bp, offset MODE2
		mov al, 1
		mov cx, 4
		mov dh, 11
		mov dl, 41d
		int 10h
	MODESELECTNEXT:
		mov ah, 00  ; ��ȡ����
		int 16h
		cmp ah, 4bh  ; ������ͷ
		je MODESELECTRESET  ; ������ͷ����ת
		cmp ah, 4dh   ; ����Ҽ�ͷ
		je MODESELECTRESET
		cmp ah, 1ch  ; �س�
		jne MODESELECTNEXT ; ����Ƿ�
  	RET
	MODESELECTRESET:
		not MODEFLAG ; ��־��λȡ�� 
  		jmp MODESELECTLOP1
MODESELECT ENDP
	mov ah, 4ch
	int 21h
CODES ENDS
    END START







