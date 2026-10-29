.data
	.globl gridValues
	.globl playerGrid
	gridValues: .space 144
	playerGrid: .space 144
	
	columnnamerow:    .asciiz "     A   B   C   D   E   F\n"
	topandbottomrow: .asciiz "   +---+---+---+---+---+---+\n"
	side: .asciiz "|"
	space: .asciiz "   "  # space string
	newline:    .asciiz "\n"    # simple newline string
	beginningrow: .asciiz " |"
	
	.globl winner
	winner: .word 0
	
	computerwin: .asciiz "\nThe Computer has won! Better luck next time buddy...\n"
	playerwin: .asciiz "\nThe Player has won! Nice job bro!\n"
	tie: .asciiz "\nWhoops! We have a tie!\n"
	
.text
.globl ResetGrids
ResetGrids:
	sw $zero, 0($s0) # reset the value to zero
	addi $s0, $s0, 4 # go to the next index
	addi $t0, $t0, 1 # i++
	bne $t0, $t1, ResetGrids # if i != 36, loop back again
	
	# this code down here only passes through if i == 36 (loop over)
	li $t0, 0 	# i = 0
	li $t1, 36 	# i < 9 condition

ResetPlayerGrid: # no need to just jumps since this is sequential
	sw $zero, 0($s1)  # reset the value to zero
	addi $s1, $s1, 4     # go to the next index
	addi $t0, $t0, 1 # i++
	bne $t0, $t1, ResetPlayerGrid 	# if i != 36, loop back again
	jr $ra 	# if i == 36, jump back to .text safely
	
.globl SetGrids
SetGrids:
	#set grids manually
	li $t0, 1
	sw $t0, 0($s0)
	sw $t0, 140($s0)
	li $t0, 2
	sw $t0, 28($s0)
	sw $t0, 112($s0)
	li $t0, 3
	sw $t0, 56($s0)
	sw $t0, 84($s0)
	
	li $t0, 1
	sw $t0, 0($s1)
	sw $t0, 28($s1)
	sw $t0, 56($s1)
	li $t0, 2
	sw $t0, 84($s1)
	sw $t0, 112($s1)
	sw $t0, 140($s1)
	
	jr $ra
	
.globl PrintGrids
PrintGrids:
	li $t0, 0 # i = 0
	li $t1, 36 # i < 36 condition
	la $s0, gridValues
	la $s1, playerGrid
	
	li $v0, SysPrintString  # prepping to print the header
	la $a0, columnnamerow
	syscall
	
	li $v0, SysPrintString  # prepping to print the header
	la $a0, topandbottomrow
	syscall
	
	addi $sp, $sp, -4  # allocating 4 bytes of space to the stack to preserve the return address pointer
	sw $ra, 0($sp)     # preverse $ra
	jal PrintOuterLoop           # call Loop to print the grid
	lw $ra, 0($sp)     # restore $ra
	addi $sp, $sp, 4   # restore the 4 bytes
	
	la $s0, gridValues
	la $s1, playerGrid
	
	jr $ra	 # return back to main.asm safely
	
PrintOuterLoop:
	li $a0, ' '
	li $v0, SysPrintChar
	syscall
	
	div $t2, $t0, 6     # divide by three using integer division to get row numbers
	addi $t2, $t2, 1    # add 1 to start at 1 instead of 0
	li $v0, SysPrintInt # prep to print an integer
	move $a0, $t2       # print the row number
	syscall
	
	la $a0, beginningrow
	li $v0, SysPrintString
	syscall
	
	li $t4, 0 # inner loop counter j
	li $t5, 6 # j < 6 condition
	
	addi $sp, $sp, -4  # allocating 4 bytes of space to the stack to preserve the return address pointer
	sw $ra, 0($sp)     # preverse $ra
	jal PrintInnerLoop           # call Loop to print the grid
	lw $ra, 0($sp)     # restore $ra
	addi $sp, $sp, 4   # restore the 4 bytes
	
	la $a0, newline
	li $v0, SysPrintString  # prepping to print a string
	syscall
	
	li $v0, SysPrintString  # prepping to print the header
	la $a0, topandbottomrow # setting the "toprow" variable to be printed
	syscall
	
	addi $t0, $t0, 6     	  # i += 6 (next row)
	blt $t0, $t1, PrintOuterLoop   # check if i == 36. if not, loop back
	jr $ra		     	# if i == 36, then jump return back to PrintLoop
	
PrintInnerLoop:
	lw $t3, 0($s1)       # retrieve the value at the index
	beqz $t3, ZeroSpot # zero spot - fill out with space
	li $t6, 1
	beq $t6, $t3, PlayerSpot # player spot
	
	# Computer Spot
	li $a0, 'C'
	li $v0, SysPrintChar
	syscall
	lw $t2, 0($s0)       # retrieve the value at the index
	div $t6, $t2, 10 # integer division to look for single digit
	beqz $t6, SingleDigit # if single digit, go print
	j DoubleDigit
	
PlayerSpot:
	li $a0, 'P'
	li $v0, SysPrintChar
	syscall
	
	lw $t2, 0($s0)
	div $t6, $t2, 10 # integer division to look for single digit
	beqz $t6, SingleDigit # if single digit, go print
	j DoubleDigit
	
ZeroSpot:
	la $a0, space
	li $v0, SysPrintString
	syscall
	li $a0, '|'
	li $v0, SysPrintChar
	syscall
	
	j RestOfInnerPrintLoop
	
SingleDigit:
	li $a0, ' '
	li $v0, SysPrintChar
	syscall
	li $v0, SysPrintInt  # prep to print an integer
	move $a0, $t2        # print the value from the grid
	syscall
	
	li $a0, '|'
	li $v0, SysPrintChar
	syscall
	
	j RestOfInnerPrintLoop

DoubleDigit:
	li $v0, SysPrintInt  # prep to print an integer
	move $a0, $t2        # print the value from the grid
	syscall
	
	li $a0, '|'
	li $v0, SysPrintChar
	syscall
	
RestOfInnerPrintLoop:
	addi $s0, $s0, 4
	addi $s1, $s1, 4
	
	addi $t4, $t4, 1 # j++
	bne $t4, $t5, PrintInnerLoop # if j != 6, then loop back in the inner loop
	jr $ra
	
.globl PlayerLockout
PlayerLockout:
	li $t0, 2 # set autofill to computer
	li $t1, 0 # i = 0
	li $t2, 144 # i < 36 condition
	la $s0, gridValues # reload address of gridValues
	la $s1, playerGrid # reload address of playerGrid
	la $s2, rowOffsets # reload address of the row offsets
	la $s3, columnOffsets # reload address of the column offsets
	j AutofillTraversal
	
.globl ComputerLockout
ComputerLockout:
	li $t0, 1 # set autofill to player
	li $t1, 0 # i = 0
	li $t2, 144 # i < 36 condition
	la $s0, gridValues # reload address of gridValues
	la $s1, playerGrid # reload address of playerGrid
	la $s2, rowOffsets # reload address of the row offsets
	la $s3, columnOffsets # reload address of the column offsets
	j AutofillTraversal
	
AutofillTraversal:
	bge $t1, $t2, FinishLockout # if i >= 144, jump to let out
	#load grid spot of grid value
	add $t3, $s1, $t1
	lw $t4, 0($t3)
	bnez $t4, AutofillNextCell
	
	li $t4, 0 # j = 0
	li $t5, 32 # j < 8 condition
	li $s4, 0 # best value
	
GetBestAutofillSurrounding:
	bge $t4, $t5, InsertSurrounding # finished checking all 8 directions
	# get offsets
	add $t6, $s2, $t4
	add $t7, $s3, $t4
	lw $t8, 0($t6)
	lw $t9, 0($t7)
	
	move $t6, $t1
	div $t6, $t6, 4
	li $t7, 6
	div $t6, $t7
	mflo $t6 # ROW
	mfhi $t7 # COLUMN
	
	add $t6, $t6, $t8 # surrounding row
	add $t7, $t7, $t9 # surrounding column
	
	bltz $t6, NextAutofillSurrounding # if row < 0
	bltz $t7, NextAutofillSurrounding # if column < 0
	li $t8, 5
	bgt $t6, $t8, NextAutofillSurrounding # if row > 5
	bgt $t7, $t8, NextAutofillSurrounding # if column > 5
	
	# calculate actual index
	mul $t8, $t6, 6
	add $t8, $t8, $t7
	mul $t8, $t8, 4
	
	add $t6, $s1, $t8 # get current address of surrounding from player grid
	lw $t9, 0($t6) # get index of surrounding
	bne $t9, $t0, NextAutofillSurrounding # if the surrounding is not owned by the intended autofill, ignore it
	
	add $t6, $s0, $t8 # get current address of surrounding from player value
	lw $t7, 0($t6) # get value
	
	ble $t7, $s4, NextAutofillSurrounding
	move $s4, $t7
	
NextAutofillSurrounding:
	addi $t4, $t4, 4 # i += 4
	j GetBestAutofillSurrounding # if i != 36, jump back
	
InsertSurrounding:
	beqz $s4, AutofillNextCell # if no good surroundings, leave empty
	
	addi $s4, $s4, 1 # i++
	add $t3, $s0, $t1 # index of new spot - grid value
	add $t6, $s1, $t1 # index of new spot - player grid
	sw $s4, 0($t3) # update player top value
	sw $t0, 0($t6) # update player grid value
	
AutofillNextCell:
	addi $t1, $t1, 4
	j AutofillTraversal

FinishLockout:	
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	jal PrintGrids
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	
	jr $ra #jump back

.globl WinnerValidation
WinnerValidation:
	li $t0, 0 # i = 0
	li $t1, 144 # i < 144 condition
	li $t2, 0 # highest value of player
	li $t3, 0 # highest value of computer
	
WinnerValidationLoop:
	bge $t0, $t1, CheckWinner # traversed through all spots, checking winner
	
	add $t4, $s0, $t0 # address of index - grid values
	lw $t4, 0($t4) # actual value
	add $t5, $s1, $t0 # address of index - player grid
	lw $t5, 0($t5) # actual value
	
	li $t6, 1
	beq $t6, $t5, PlayerMaxCheck # if the spot belongs to the player, check max
	
	#COMPUTER MAX CHECK
	ble $t4, $t3, WinnerValidationTraverseNext # if computer max is still bigger, ignore
	move $t3, $t4 # change maximum for computer
	
	j WinnerValidationTraverseNext
	
PlayerMaxCheck:
	ble $t4, $t2, WinnerValidationTraverseNext # if player max is still bigger, ignore
	move $t2, $t4 # change maximum for player
	
WinnerValidationTraverseNext:
	addi $t0, $t0, 4 # i += 4
	j WinnerValidationLoop
	
CheckWinner:
	blt $t2, $t3, ComputerWins # computer won
	bgt $t2, $t3, PlayerWins # player wins
	
	# TIE
	sw $zero, winner # set winner to zero - no winner
	la $a0, tie
	li $v0, SysPrintString # print text
	syscall
	
	jr $ra
	
PlayerWins:
	li $t0, 1
	sw $t0, winner # set winner to 1 (player)
	la $a0, playerwin
	li $v0, SysPrintString # print text
	syscall
	
	jr $ra

ComputerWins:
	li $t0, 2
	sw $t0, winner # set winner to 2 (computer)
	la $a0, computerwin
	li $v0, SysPrintString # print text
	syscall
	
	jr $ra