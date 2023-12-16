.data
x: .word 0, 0, 50, 50  # x-coordinates of 4 robots
y: .word 0, 50, 0, 50  # y-coordinates of 4 robots

str1: .asciiz "Your coordinates: 25 25\n"
str2: .asciiz "Enter move (1 for +x, -1 for -x, 2 for + y, -2 for -y):"
str3: .asciiz "Your coordinates: "
sp: .asciiz " "
endl: .asciiz "\n"
str4: .asciiz "Robot at "
str5: .asciiz "AAAARRRRGHHHHH... Game over\n"
msg: .asciiz "Game over! You have been caught by a robot.\n" # game over message

.text
main:
    li $s1, 25   # myX = 25
    li $s2, 25   # myY = 25
    li $s4, 1    # status = 1

    la $s5, x
    la $s6, y

    sw $0, 0($s5)   # x[0] = 0; y[0] = 0;
    sw $0, 0($s6)
    sw $0, 4($s5)   # x[1] = 0; y[1] = 50;
    li $s7, 50
    sw $s7, 4($s6)
    sw $s7, 8($s5)   # x[2] = 50; y[2] = 0;
    sw $0, 8($s6)
    sw $s7, 12($s5)  # x[3] = 50; y[3] = 50;
    sw $s7, 12($s6)

main_while:
	bne $s4,1,main_exitw
	# here status == 1
    la $a0, str2     # cout << "Enter move (1 for +x, -1 for -x, 2 for + y, -2 for -y):";
    li $v0, 4
    syscall

    li $v0, 5        # cin >> move;
    syscall
    move $s3, $v0

    bne $s3, 1, main_else1  # if (move == 1)
    addi $s1, $s1, 1         # myX++;
    b main_exitif
main_else1:
    bne $s3, -1, main_else2  # else if (move == -1)
    addi $s1, $s1, -1         # myX--;
    b main_exitif
main_else2:
    bne $s3, 2, main_else3   # else if (move == 2)
    addi $s2, $s2, 1          # myY++;
    b main_exitif
main_else3:
    bne $s3, -2, main_exitif  # else if (move == -2)
    addi $s2, $s2, -1         # myY--;

main_exitif:
    la $a0, x          
    la $a1, y
    move $a2, $s1
    move $a3, $s2
    jal moveRobots
    move $s4, $v0
	# print "Your coordinates: "
    la $a0, str3       
    li $v0, 4          
    syscall
    	# print myX
    move $a0, $s1
    li $v0, 1
    syscall
    	# print space
    la $a0, sp
    li $v0, 4
    syscall
    	# print myY
    move $a0, $s2
    li $v0, 1
    syscall
    	# print '\n'
    la $a0, endl
    li $v0, 4
    syscall

    la $s5, x
    la $s6, y
    li $s0, 0     # i = 0     
main_for:
	bge $s0,4,main_while  # loop again
	# here i < 4
	# print "Robot at "
    la $a0, str4       
    li $v0, 4         
    syscall
    	# print x[i]
    lw $a0, 0($s5) # $a0 = x[i]
    li $v0, 1
    syscall
    	# print ' '
    la $a0, sp
    li $v0, 4
    syscall
    	# print y[i]
    lw $a0, 0($s6)
    li $v0, 1
    syscall
    	# print '\n'
    la $a0, endl
    li $v0, 4
    syscall
    # go to next elemenets 
    addiu $s5, $s5, 4
    addiu $s6, $s6, 4
    addi $s0, $s0, 1 # i++
    j main_for

    j main_while  # loop again

main_exitw:
    la $a0, str5       
    li $v0, 4
    syscall
    li $v0, 10         
    syscall

moveRobots:
    addiu $sp, $sp, -28 # allocate space on stack
    sw $ra, 0($sp) # save return address
    sw $a2, 4($sp) # save user's x move
    sw $a3, 8($sp) # save user's y move
    # 12($sp) # we use it as ptrX
    # 16($sp) # we use ot as ptrY
    sw $s0,20($sp) # we use ot as alive
    sw $s1,24($sp) # we use it as i
    li $s0,1 # alive = 1
    sw $a0,12($sp) # ptrX = arg0;
    sw $a1,16($sp) # ptrY = arg1;
    li $s1,0 # i=0 
    
moveLoop:
	bge $s1,4,moveDone
	# here i<4
	lw $a0,12($sp) # $a0 = ptrX
	lw $a0,0($a0) # $a0 = *ptrX
	lw $a1,4($sp) # $a1 = arg2
	jal getNew
	lw $t0,12($sp) # $t0 = ptrX
	sw $v0,0($t0) # *ptrX = getNew(*ptrX,arg2); // update x-coordinate of robot i
	lw $a0,16($sp) # $a0 = ptrY
	lw $a0,0($a0) # $a0 = *ptrY
	lw $a1,8($sp) # $a1 = arg3
	jal getNew
	lw $t0,16($sp) # $t0 = ptrY
	sw $v0,0($t0) # *ptrY = getNew(*ptrY,arg3); // update y-coordinate of robot i
	lw $t0,8($sp) # $t0 = arg3
	bne $v0,$t0,moveLoopUpdate
	lw $t0,12($sp) # $t0 = ptrX
	lw $t1,0($t0) # $t1 = *ptrX
	lw $t0,4($sp) # $t0 = arg2
	bne $t0,$t1,moveLoopUpdate
	# here (*ptrX == arg2) && (*ptrY == arg3)
	add $s0,$0,$0 # alive = 0;
	j moveDone # break ;
moveLoopUpdate:
	# ptrX++;
	lw $t0,12($sp) # $t0 = ptrX
	addiu $t0,$t0,4
	sw $t0,12($sp)
	lw $t0,16($sp) # ptrY++;
	addiu $t0,$t0,4
	sw $t0,16($sp) 
	addi $s1,$s1,1 # i++
	j moveLoop # jump to move loop
moveDone:
	move $v0,$s0 # return alive;
    lw $ra, 0($sp) # restore return address
    lw $s0,20($sp) 
    lw $s1,24($sp)
    addiu $sp, $sp, 28 # deallocate space on stack
    jr $ra # return to caller
    
getNew:
    sub $t0,$a0,$a1 # temp = arg0 - arg1;
    bge $t0,10,getNew10
    bgtz $t0,getNew_0
    beqz $t0,getNew0
    bgt $t0,-10,getNew_10
	# temp <= -10
	addi $v0,$a0,10 # return arg0 + 10;
	jr $ra # return to caller
getNew10:
	# temp >= 10
	addi $v0,$a0,-10 # return arg0 - 10;
	jr $ra # return to caller
getNew_0:
	# temp > 0
	addi $v0,$a0,-1 # return arg0 - 1;
	jr $ra # return to caller
getNew0:
	# temp == 0
	add $v0,$0,$a0 # return arg0;
	jr $ra # return to caller
getNew_10:
	# temp > -10
	addi $v0,$a0,1 # return arg0 + 1;
	jr $ra # return to caller
	
# Game Over
gameOver:
    li $v0, 4 # print game over message
    la $a0, msg
    syscall
    li $v0, 10 # exit program
    syscall
