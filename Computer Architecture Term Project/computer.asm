.data	
	.globl computerLockOut
	computerLockOut: .word 0
	
	computerMoveMessage: .asciiz "Computer to "
	computerLockedOut: .asciiz "Computer is out of moves. Filling in player's moves...\n"
	computernewline:    .asciiz "\n"

.text
.globl ComputerMove
ComputerMove:
	la $s2, rowOffsets
	la $s3, columnOffsets
	li $t0, 0 # i = 0
	li $t1, 144 # i < 36 condition
	li $t2, -1 # best index
	li $t3, 0 # best value
	li $s7, 0 # num valid surroundings
	
FindHighestValue:
	bge $t0, $t1, EvaluateSurrounding # if i >= 144, exit loop
	
	add $t4, $s0, $t0 # get the address of the next index for array value - grid values
	add $t5, $s1, $t0 # get the address of the next index for array value - player grid
	lw $t6, 0($t4) # get value of grid value at index
	lw $t7, 0($t5) # get value of player value at index
	
	li $t4, 2
	bne $t7, $t4, FindHighestValue_NextIteration # if the spot doesn't belong to the computer, ignore this iteration and move on
	
	#resert addresses os s2 and s3
	la $s2, rowOffsets
	la $s3, columnOffsets
	
	li $t8, 0 # temp variable for getting number of valid surroundings
	li $t4, 0 # j = 0
	li $t5, 32 # j < 32 condition
	
	addi $sp, $sp, -4 # move stack pointer to allocate space to temporarily store the old return address
	sw $ra, 0($sp) # store return address
	jal GetNumValidSurroundings
	lw $ra, 0($sp) # load return address back
	addi $sp, $sp, 4 # move stack pointer back where it was
	
	beqz $t8, FindHighestValue_NextIteration # no valid surroundings
	
	ble $t6, $t3, FindHighestValue_NextIteration # if the spot is not greater than the maximum currently found, ignore this iteration and move on and move on
	
UpdateComputerBest:
	# update the maximums
	move $t2, $t0
	move $t3, $t6
	move $s7, $t8

FindHighestValue_NextIteration:
	addi $t0, $t0, 4
	j FindHighestValue
	
GetNumValidSurroundings:
	# preserve $t0 and other registers (make space for new register space)
	addi $sp, $sp, -16
	sw $t0, 0($sp)
	sw $t1, 4($sp)
	sw $t2, 8($sp)
	sw $s7, 12($sp)
	
GetNumValidSurroundingsLoop:
	bge $t4, $t5, GetNumValidSurroundingsDone
	
	lw $t7, 0($s2) # load in the row offset
	lw $t9, 0($s3) # load in the column offset
	
	# get $t0 back from the stack and calculate it
	lw $t0, 0($sp)
	div $t0, $t0, 4
	li $s7, 6
	div $t0, $s7
	mflo $t1 # ROW
	mfhi $t2 # COLUMN
	
	add $t1, $t1, $t7 # surrounding row
	add $t2, $t2, $t9 # surrounding column
	
	bltz $t1, InvalidSurrounding # if row < 0
	bltz $t2, InvalidSurrounding # if column < 0
	
	li $v1, 5
	bgt $t1, $v1, InvalidSurrounding # if row > 5
	bgt $t2, $v1, InvalidSurrounding # if column > 5
	
	#calculate actual index
	mul $t7, $t1, 6
	add $t7, $t7, $t2
	mul $t7, $t7, 4
	
	add $t7, $s1, $t7 # get current address of surrounding from player grid
	lw $t9, 0($t7) # get index of surrounding
	bnez $t9, InvalidSurrounding # if the surrounding is owned by somebody, ignore it
	
	addi $t8, $t8, 1 # add another to valid surroundings
	
NextSurrounding:
	addi $t4, $t4, 4 # j += 4
	addi $s2, $s2, 4 # increment address
	addi $s3, $s3, 4 # increment the address
	j GetNumValidSurroundingsLoop

InvalidSurrounding:
	j NextSurrounding # immediately jump without incrementing twice
	
GetNumValidSurroundingsDone:
	# allocate back to stack. restore original values
	lw $s7, 12($sp)
	lw $t2, 8($sp)
	lw $t1, 4($sp)
	lw $t0, 0($sp)
	addi $sp, $sp, 16
	jr $ra
	
EvaluateSurrounding:
	bltz $t2, ComputerLockedOut # if there were no valid spots with available surroundings, call the computer 'locked out'
	
	move $t0, $t2 # restore move tile to $t0
	
	# randomize which valid surrounding to use
	li $a0, 0
	move $a1, $s7
	li $v0, SysRandIntRange
	syscall
	
	#prep for loop ($t3 is the value)
	li $t1, 0 # i = 0
	li $t2, 32 # i < 8 condition
	addi $t3, $t3, 1 # value to place move
	move $t4, $a0 # valid surrounding number (random seed)
	li $t5, 0 # surrounding seed counter
	
	# reset addresses back to index 0
	la $s2, rowOffsets
	la $s3, columnOffsets
	
	
EvaluateMove:
	lw $t6, 0($s2) # load in the row offset
	lw $t7, 0($s3) # load in the column offset
	
	addi $sp, $sp, -4
	sw $s7, 0($sp)
	
	# get actual grid spot, calculate the offset, and evaluate
	div $t0, $t0, 4
	li $s7, 6
	div $t0, $s7
	
	lw $s7, 0($sp)
	addi $sp, $sp, 4
	
	mflo $t8 # ROW
	mfhi $t9 # COLUMN
	mul $t0, $t0, 4
	add $t8, $t8, $t6 # surrounding row
	add $t9, $t9, $t7 # surrounding column
	
	bltz $t8, NextEvaluateMove # if row < 0
	bltz $t9, NextEvaluateMove # if column < 0
	li $t6, 5
	bgt $t8, $t6, NextEvaluateMove # if row > 5
	bgt $t9, $t6, NextEvaluateMove # if column > 5
	
	# convert to real index
	mul $t6, $t8, 6
	add $t6, $t6, $t9
	mul $t6, $t6, 4
	
	add $t6, $s1, $t6 # get current address of surrounding from player grid
	lw $t7, 0($t6) # get index of surrounding
	bnez $t7, NextEvaluateMove # if the surrounding is owned by somebody, ignore it
	
	beq $t5, $t4, PlaceMove # if this is the correct random seed number for surroundings, place move
	
	addi $t5, $t5, 1 # add 1 to the seed number
	
NextEvaluateMove:
	addi $t1, $t1, 4 # i += 4
	addi $s2, $s2, 4 # increment address
	addi $s3, $s3, 4 # increment the address
	bne $t1, $t2, EvaluateMove # loop back around
	j ComputerLockedOut # if it somehow breaks, default to locked out
	
PlaceMove: # ($t3 value to place, $t8 row to place, $t9 column to place)
	# get exact spot
	mul $t0, $t8, 6
	add $t0, $t0, $t9
	mul $t0, $t0, 4
	
	# get index and change grid value
	add $t1, $s0, $t0
	sw $t3, 0($t1)
	
	addi $t9, $t9, 65 # convert to ascii character
	addi $t8, $t8, 1 # change from 0 scale to 1 scale
	
	# get index and change computer value
	li $t3, 2
	add $t1, $s1, $t0
	sw $t3, 0($t1)

	la $a0, computerMoveMessage
	li $v0, SysPrintString
	syscall
	
	move $a0, $t9
	li $v0, SysPrintChar
	syscall
	
	move $a0, $t8
	li $v0, SysPrintInt
	syscall
	
	la $a0, computernewline
	li $v0, SysPrintString
	syscall
	
	jr $ra # jump back to main.asm
	
ComputerLockedOut:
	# print lockout message
	la $a0, computerLockedOut
	li $v0, SysPrintString
	syscall
	
	# turn the lockedOut variable true
	li $t9, 1
	sw $t9, computerLockOut
	
	jr $ra # jump back to main.asm