DATAS SEGMENT
    ; 延迟时间和暂停计数器
    DELAYTIME db 03H ; 延迟时间，用于下落
    pause_counter db 0 ; 定义一个字节型变量 pause_counter，初始化为 0
    current_position dw ? ; 用来存储吃豆人的当前位置
    ; 模式相关变量
    MODEFLAG db 0   ; 模式选择标志
 	MODE1 db 'START' ; 模式 1: 开始
    MODE2 db 'QUIT'; 模式 2: 退出
    TIPS3 db 'MODE SELECT' ; 显示模式选择字符串
    
    ; 垂直空格
    TIPS1 db 'I', 0EH, 'N', 0EH, 'S', 0EH, 'T', 0EH, 'R', 0EH, 'U', 0EH, 'C', 0EH, 'T', 0EH, 'I', 0EH, 'O', 0EH, 'N', 0EH, ':', 0EH
    ; 数据段代码
    WELCOME_MSG db 'WELCOME TO THE GAME!', 13, 10, '$'
    GOODBYE_MSG db 'GOOD BYE!', 13, 10, '$'

    temp1 dw ?
	temp2 dw ?;定义段temp1和temp2
	STRING  db  'Press Space to Start or Press AnyKey to return',13,10,'$';定义字符串
      
    mes1 db 'Name:';姓名
    mes2 db 'Student No:';学号
    mes3 db 'Class:';班级  
DATAS ENDS

STACKS SEGMENT
STACKS ENDS

CODES SEGMENT
    assume cs:codes,ds:datas,ss:stacks
    ;吃豆子过程中键入相关
	in al,60h  ; 读取键盘输入
	cmp al,57 ;比较送到al的数与57(在ascll码中代表十进制的9）的差
	jnz nospace; 如果不相等，跳转到 nospace（不是空格键）
	mov cx,1
	nospace:
	mov al,20h  ; 将空格字符的 ASCII 值移动到 al 寄存器
	out 20h,al ; 将 al 输出到端口 20H
	iret ;中断返回程序
    
START:
    mov ax,datas
    mov ds,ax
	; 将光标移动到屏幕中间
	mov ah, 02h ; 设置光标位置函数
	mov bh, 0   ; 页码为0
	mov dh, 10  ; 将光标的行位置设置为12
	mov dl, 27  ; 将光标的列位置设置为35
	int 10h     ;
	; 显示欢迎信息
    mov si, offset WELCOME_MSG
    call PrintStringDelay
    
SELECT:   
	 call Save
	 mov bp, offset TIPS3
	 mov cx, 11d;17，字符串长度
	 mov dh, 7;显示行的位置
	 mov dl, 33;显示列的位置
	 mov al, 01
	 mov bl, 0EH;字符显示的颜色，黄色
	 mov ah, 13h;显示带属性的字符串
	 int 10h
	 call MODESELECT;选择模式
	 cmp MODEFLAG, 0
	 je GOGAME1
	 jmp exit
 
GOGAME1:
 	mov ah,02h;设置光标位置
	mov bh,0
	mov dl,0
	mov dh,10;要在屏幕的第十行显示字符
	int 10h
	
	mov ah,02H ;设置光标位置
	mov dl,'.' ;取要显示的字符到DL中豆子 
	mov cx,25*80 ;默认最大显示量就是80*25
	setpoint:
	int 21H 
	loop setpoint ;循环以在屏幕上显示 '.'

	;输入一个字符，判断是否继续 
	;给出输入提示
    mov  ax,datas
    mov  ds,ax
    lea  dx,string
    mov  ah,9
    int  21h

	mov ah,07h ;键盘输入
	int 21h 
	cmp al,' ' ;比较指令,判断空格
	jnz SELECT ;不为空格则跳转
	
	;cx/dx入栈保护现场(保证空格能使用）
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
	;设置光标位置
	mov ah,02H  
	mov bh,0 
	xor dx,dx ;清0
	int 10H
 	;清空屏幕并显示豆子和吃豆人
	mov ax,0B800H 
	mov ds,ax
	xor bx,bx
	mov cx,80*25;默认最大显示量就是80*25
eatpea:
	mov si,0B7FFH;代表在25×80的文本显示方式下
	nextone:
		sub si,1;将si-1的值送到si
		jnz nextone;不为0就继续si-1，即吃下一个豆子	
		mov byte ptr [bx],' ';把“ ”的第一个字节的内容送到bx
		mov byte ptr [bx+2],'C';把“C”的第一个字节的内容送到bx+2
		add bx,2	
	loop eatpea ;吃80*25个豆子
	;用于吃豆子的循环，通过在屏幕上替换字符来模拟吃豆子的过程。
;   在循环中，每次都将当前位置的字符替换为一个空格，表示豆子被吃掉了。
;同时，在当前位置的下一个位置（即 `BX+2` 处），将字符替换为 'C'，表示吃豆人的位置。
	;ax/dx出栈恢复现场(按空格会重置）
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
    ; 暂停游戏，等待用户按空格键继续
    mov ah, 07H         ; 键盘输入
    int 21H             
    cmp al, ' '         ; 检查是否按下了空格键
    jne SELECT          ; 如果不是空格键，继续检查是否暂停
    inc byte ptr [pause_counter] ; 每次按下空格键计数器加 1
    call check_space    


check_space:
    mov al, [pause_counter]  ; 将按下空格键的次数加载到 al 中
    and al, 0               ; 检查 al 的最低位，以判断按下空格键的次数是奇数还是偶数
    jnz pause_game          ; 如果按下奇数次空格键，继续暂停游戏
    jmp GOGAME1          ; 如果按下偶数次空格键，跳到 GOGAME1 标签处

exit:
	call Save
	
goodbye:
	 ; 将光标移动到屏幕中间
	 mov ah, 02h ; 设置 AH 以设置光标位置函数
	 mov bh, 0   ; 页码为0
	 mov dh, 10  ; 将光标的行位置设置为12
	 mov dl, 30  ; 将光标的列位置设置为35
	 int 10h     ; 调用 BIOS 中断以设置光标位置
 
	 mov si, offset GOODBYE_MSG
	 call PrintStringDelay
	 call Save
	 
end_string:
	 mov bp, offset mes1
	 mov cx, 13d ;表示字符串的长度
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
	 int 21H;调用系统中断  

DELAY PROC    ; 延时函数
	 mov ah, 0	
	 int 1ah    ; 直接读取时钟计数器
	 mov bx, dx
	 mov ax, 0
	 mov al, DELAYTIME  ; 加上DELAY间隔
	 add bx, ax
	DELAYLOP: mov AH, 0
	  int 1ah
	  cmp dx, bx
	  je DELAYNEXT
	  jmp DELAYLOP
	DELAYNEXT: RET
DELAY ENDP   
    
PrintStringDelay PROC
    ; 打印字符串，带延迟效果
    NEXT_CHAR:
        mov al, [si]
        cmp al, '$'        ; 判断字符串结束
        je END_PRINT
        mov ah, 0EH        ; 显示字符
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
    mov bx, 0       ; 保存当前显示方式
    mov ah, 0FH     ; 获取视频模式
    int 10h

    mov al, 03h     ; 设置显示模式
    mov ah, 0
    int 10h
    RET             ; 返回
Save ENDP

MODESELECT PROC    ; MODE选择菜单
	MODESELECTLOP1: 
  		CMP MODEFLAG, 0FFH ; 判定当前选项
  		JE MODESELECTLOP2   
		MOV AH, 06H ;表示向上滚动窗口
  		MOV AL, 0;滚动窗口的行数为 0
  		MOV BH, 07H
  		MOV CH, 12D;滚动窗口的起始行号
  		MOV CL, 0;滚动窗口的起始列号
  		MOV DH, 13D;滚动窗口的结束行号
  		MOV DL, 79;滚动窗口的结束列号
  		INT 10H
        ; 显示模式选项
  		MOV AH, 13H
  		MOV BL, 9EH
  		MOV BH, 0
  		MOV BP, OFFSET MODE1
  		MOV AL, 1
  		MOV CX, 5; 长度
  		MOV DH, 11; 行
 		MOV DL, 32D ; 列
  		INT 10H
  		; 显示模式选项
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
		mov ah, 06h ; 表示向上滚动窗口
		mov al, 0   ; 表示滚动窗口的行数为 0
		mov bh, 07h
		mov ch, 12d ; 滚动窗口的起始行号
		mov cl, 0   ; 滚动窗口的起始列号
		mov dh, 19d
		mov dl, 79
		int 10h
      ; 显示模式选项
		mov ah, 13h
		mov bl, 08h
		mov bh, 0
		mov bp, offset MODE1
		mov al, 1
		mov cx, 5
		mov dh, 11
		mov dl, 32d
		int 10h
      ; 显示模式选项
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
		mov ah, 00  ; 获取输入
		int 16h
		cmp ah, 4bh  ; 检查左箭头
		je MODESELECTRESET  ; 如果左箭头，跳转
		cmp ah, 4dh   ; 检查右箭头
		je MODESELECTRESET
		cmp ah, 1ch  ; 回车
		jne MODESELECTNEXT ; 输入非法
  	RET
	MODESELECTRESET:
		not MODEFLAG ; 标志各位取反 
  		jmp MODESELECTLOP1
MODESELECT ENDP
	mov ah, 4ch
	int 21h
CODES ENDS
    END START







