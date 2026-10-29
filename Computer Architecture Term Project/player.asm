.data
	.globl playerLockOut
	playerLockOut: .word 0
	
	playermovemessage: .asciiz "\nSelect the new spot you want to occupy ([column letter] + [row number]) >> "
	invalidmovemessage: .asciiz "\nThat move is not valid: Not surrounded by any of your own.\n"
	alreadyplacedmessage: .asciiz "\nThat move is not valid: Spot is already taken.\n"
	successmessage: .asciiz "\nSpot has been taken by Player.\n"
	outofrange: .asciiz "\nThat move is not valid: The spot ID you inputted is out of range.\n"
	
	playermove: 	   .space 24
	
.text

.globl CheckPlayerLockout
CheckPlayerLockout:
	li $t0, 0 # i = 0
	li $t1, 144 # i < 144 condition
	
PlayerLockoutTraversal:
	bge $t0, $t1, PlayerLockedOut # no valid move found
	
	add $t2, $s1, $t0 # get address (index)
	lw $t3, 0($t2) #load value
	li $t4, 1
	bne $t3, $t4, NextTraversalSpot # if it isnt owned by player, ignore and move on
	
	la $s2, rowOffsets
	la $s3, columnOffsets
	li $t5, 0 # j = 0
	li $t6, 32 # j < 32 condition
	
CheckLockoutSurroundings:
	bge $t5, $t6, NextTraversalSpot
	
	lw $t7, 0($s2) # row offset
	lw $t8, 0($s3) # column offset
	
	div $t9, $t0, 4
	li $t2, 6
	div $t9, $t2
	mflo $t9 # ROW
	mfhi $t2 # COLUMN
	
	add $t9, $t9, $t7 # surrounding row
	add $t2, $t2, $t8 # surrounding column
	
	bltz $t9, PlayerLockoutNextSurrounding # if row < 0
	bltz $t2, PlayerLockoutNextSurrounding # if column < 0
	li $t3, 5
	bgt $t9, $t3, PlayerLockoutNextSurrounding # if row > 5
	bgt $t2, $t3, PlayerLockoutNextSurrounding # if column > 5
	
	#get actual word-addressable index
	mul $t3, $t9, 6
	add $t3, $t3, $t2
	mul $t3, $t3, 4
	
	add $t3, $s1, $t3 # address of surrounding - player grid
	lw $t3, 0($t3) # value of surrounding player grid value
	bnez $t3, PlayerLockoutNextSurrounding # if taken
	
	j PlayerNotLockedOut
	
PlayerLockoutNextSurrounding:
	addi $t5, $t5, 4 # j += 4
	addi $s2, $s2, 4 # row offset += 4
	addi $s3, $s3, 4 # column offset += 4
	j CheckLockoutSurroundings
	
NextTraversalSpot:
	addi $t0, $t0, 4 # i += 4
	j PlayerLockoutTraversal
	
PlayerNotLockedOut:
	#player is now locked out, set to zero and return
	sw $zero, playerLockOut
	jr $ra
	
PlayerLockedOut:
	#player is locked out, set the check variable in static data to 1 to show true
	li $t0, 1
	sw $t0, playerLockOut
	jr $ra

.globl PlayerMove
PlayerMove:
	la $s0, gridValues
	la $s1, playerGrid
	la $s2, rowOffsets
	la $s3, columnOffsets
	
	# print grids beforehand
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	jal PrintGrids
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	
	la $a0, playermovemessage
	li $v0, SysPrintString
	syscall
	
	#input for move
	li $v0, SysReadString
	la $a0, playermove
	li $a1, 3
	syscall
	
	#translate the move correctly
	la $t1, playermove
	lb $t2, 0($t1)
	lb $t3, 1($t1)
	li $t4, 97
	
	#uppercase check (fix automatically)
	slt $t5, $t2, $t4
	beq $t5, $zero, Uppercase
	
	j PrepSurroundings
	
Uppercase:
	subi $t2, $t2, 32
	
PrepSurroundings:
	#translate gridspot to actual 1d index
	subi $t2, $t2, 65
	subi $t3, $t3, 49
	li $t4, 6
	mul $t5, $t4, $t3
	add $t5, $t5, $t2
	mul $t5, $t5, 4
	
	#invalid move out of range checks
	bltz $t5, InvalidMoveOutOfRange
	li $t6, 144
	bge $t5, $t6, InvalidMoveOutOfRange
	li $t6, 6
	bge $t2, $t6, InvalidMoveOutOfRange
	
	# already placed checks
	add $t4, $s1, $t5
	lw $t6, 0($t4)
	
	bnez $t6, InvalidMoveAlreadyPlaced
	
	#prep loop
	li $t0, 0
	li $t1, 32
	li $s4, 0 # saved index
	li $s5, 0 # saved value
	
GetBestSurrounding:
	bge $t0, $t1, CheckValidMove # loop end

	#get coordinate
	add $t4, $s2, $t0
	add $t6, $s3, $t0
	lw $t7, 0($t4)
	lw $t8, 0($t6)
	
	add $t4, $t3, $t7 # neighbor row
	add $t6, $t2, $t8 # neighbor column
	
	#i += 4
	addi $t0, $t0, 4
	
	# invalid surrounding
	blt $t4, $zero, GetBestSurrounding
	li $t9, 6
	bge $t4, $t9, GetBestSurrounding
	blt $t6, $zero, GetBestSurrounding
	bge $t6, $t9, GetBestSurrounding
	
	# get actual 1d index
	mul $t9, $t4, 6
	add $t9, $t9, $t6
	mul $t9, $t9, 4
	
	#checking to see if it is owned by the player
	add $t4, $s1, $t9
	lw $t6, 0($t4)
	li $t7, 1
	
	bne $t6, $t7, GetBestSurrounding
	
	#check to see if there are better surroundings already
	add $t4, $s0, $t9
	lw $t6, 0($t4)
	
	ble $t6, $s5, GetBestSurrounding
	
	#update max best surrounding
	move $s5, $t6
	move $s4, $t9
	
	j GetBestSurrounding
	
CheckValidMove:
	#if there were no valid surroundings around it that the player owns (best was zero), invalid
	beqz $s5, InvalidMoveNoSurroundings
	
	# add one for new spot
	addi $s5, $s5, 1
	
	# calculate and place new spot
    	add $t4, $s0, $t5
	sw $s5, 0($t4)
	add $t4, $s1, $t5
	li $t9, 1
	sw $t9, 0($t4)
	
	#success message and jump return
	la $a0, successmessage
	li $v0, SysPrintString
	syscall
	
	jr $ra
	
InvalidMoveNoSurroundings:
	la $a0, invalidmovemessage
	li $v0, SysPrintString
	syscall
	
	j PlayerMove
	
InvalidMoveAlreadyPlaced:
	la $a0, alreadyplacedmessage
	li $v0, SysPrintString
	syscall
	
	j PlayerMove
	
InvalidMoveOutOfRange:
	la $a0, outofrange
	li $v0, SysPrintString
	syscall
	
	j PlayerMove
