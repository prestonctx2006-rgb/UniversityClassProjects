.include "SysCalls.asm"
.include "gameboard.asm"
.include "player.asm"
.include "computer.asm"

.data
	.align 2
	firstPlayer: .space 4
	secondPlayer: .space 4
	
	openingmessage: .asciiz "\nWELCOME TO: NUMBER CHAIN!\n"
	melodynotes: .word 61, 63, 64
	chordnotes: .word 64, 59, 56, 52, 40
	instrument: .word 61
	volume:     .word 100
	duration:   .word 500
	chordduration: .word 1500
	
	playerselectionmessage1: .asciiz "\nYou have been selected as: Player 1. You go first!\n"
	playerselectionmessage2: .asciiz "\nYou have been selected as: Player 2. You go second!\n"
	
	.globl rowOffsets
	.globl columnOffsets
	rowOffsets:    .word -1, -1, -1, 0, 0, 1, 1, 1
	columnOffsets: .word -1, 0, 1, -1, 1, -1, 0, 1
	
	#player win theme
	playerwinmelody: .word 70, 74, 77
	playerwinchordnotes1: .word 72, 74, 77, 82
	playerwinchordnotes2: .word 70, 74, 77, 82
	playerwinthemenoteduration:   .word 500
	playerwinthemechordduration1: .word 1000
	playerwinthemechordduration2: .word 1500
	
	# computer win theme
	computerwinmelody: .word 65, 64, 63, 62
	computerduration1: .word 750
	computerduration2: .word 1500
	
	# tie theme
	tiechord1: .word 59, 62, 65, 69
	tiechord2: .word 58, 63, 66, 70
	tieduration: .word 2000
	
.text

.globl main
main:
	# OPENING MESSAGE
	la $a0, openingmessage
	li $v0, SysPrintString
	syscall
	
	jal OpeningTheme # little tune to start the game
	jal RandomizePlayers # randomize players to s6 and s7 (i think)
	#jal SetPlayerAsFirstPlayer # test function for rn
	
	la $s0, gridValues # load address of gridValues
	la $s1, playerGrid # load address of playerGrid
	
	# checking surrondings and reset the game board
	la $s2, rowOffsets # load address of the row offsets
	la $s3, columnOffsets # load address of the column offsets
	jal ResetGame
	
	# checks for who goes first
	li $t0, 1
	beq $s6, $t0, PlayerTurn
	j ComputerTurn
	
PlayerTurn:
	#CHECK FOR PLAYER LOCKOUT
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	jal CheckPlayerLockout
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	
	lw $t0, playerLockOut
	bnez $t0, LockoutPlayerMain # no valid moves available, autofill computer

	# preserve registers and call playermove
	addi $sp, $sp, -16
	sw $s0, 0($sp)
	sw $s1, 4($sp)
	sw $s4, 8($sp)
	sw $s5, 12($sp)
	jal PlayerMove
	lw $s5, 12($sp)
	lw $s4, 8($sp)
	lw $s1, 4($sp)
	lw $s0, 0($sp)
	addi $sp, $sp, 16
	
	j RestOfPlayerTurn
	
LockoutPlayerMain:
	jal PlayerLockout
	jal WinnerValidation
	lw $t0, winner
	beqz $t0, TieTheme # if tie, send to music theme
	li $t1, 1
	beq $t0, $t1, PlayerWinTheme # if player wins
	j ComputerWinTheme # if computer wins
	
RestOfPlayerTurn:
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	jal PrintGrids
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	
ComputerTurn:
	# preserve registers and make computer move
	addi $sp, $sp, -20
	sw $s0, 0($sp)
	sw $s1, 4($sp)
	sw $s2, 8($sp)
	sw $s3, 12($sp)
	sw $s7, 16($sp)
	jal ComputerMove
	lw $s7, 16($sp)
	lw $s3, 12($sp)
	lw $s2, 8($sp)
	lw $s1, 4($sp)
	lw $s0, 0($sp)
	addi $sp, $sp, 20
	
	# if the computer was not able to make a move, send to label that will fill in the holes automatically for the player
	lw $t0, computerLockOut
	beqz $t0, PlayerTurn
	
LockoutComputerMain:
	jal ComputerLockout
	jal WinnerValidation
	lw $t0, winner
	beqz $t0, TieTheme # if tie, send to music theme
	li $t1, 1
	beq $t0, $t1, PlayerWinTheme # if player wins
	j ComputerWinTheme # if computer wins
	
OpeningTheme:
	# OPENING THEME
	la $t0, melodynotes
	
	lw $a0, 0($t0)      # $a0 = pitch
    	lw $a1, duration   # $a1 = duration
    	lw $a2, instrument     # $a2 = instrument
    	lw $a3, volume      # $a3 = volume
    	li $v0, SysMidiOutSync
    	syscall
    	
    	addi $t0, $t0, 4
    	
    	lw $a0, 0($t0)      # $a0 = pitch
    	lw $a1, duration   # $a1 = duration
    	lw $a2, instrument     # $a2 = instrument
    	lw $a3, volume      # $a3 = volume
    	li $v0, SysMidiOutSync
    	syscall
    	
    	addi $t0, $t0, 4
    	
    	lw $a0, 0($t0)      # $a0 = pitch
    	lw $a1, duration   # $a1 = duration
    	lw $a2, instrument     # $a2 = instrument
    	lw $a3, volume      # $a3 = volume
    	li $v0, SysMidiOutSync
    	syscall
    	
    	# FINAL CHORD
    	la $t0, chordnotes
    	
    	lw $a0, 0($t0)      # $a0 = pitch
    	lw $a1, chordduration      # $a1 = duration
    	lw $a2, instrument     # $a2 = instrument
    	lw $a3, volume      # $a3 = volume
    	li $v0, 31          # syscall for aggregating notes for later (chords)
    	syscall
    	
    	addi $t0, $t0, 4
    	lw $a0, 0($t0)      # $a0 = pitch
    	lw $a1, chordduration      # $a1 = duration
    	lw $a2, instrument     # $a2 = instrument
    	lw $a3, volume      # $a3 = volume
    	li $v0, 31          # syscall for aggregating notes for later (chords)
    	syscall
    	
    	addi $t0, $t0, 4
    	lw $a0, 0($t0)      # $a0 = pitch
    	lw $a1, chordduration      # $a1 = duration
    	lw $a2, instrument     # $a2 = instrument
    	lw $a3, volume      # $a3 = volume
    	li $v0, 31          # syscall for aggregating notes for later (chords)
    	syscall
    	
    	addi $t0, $t0, 4
    	lw $a0, 0($t0)      # $a0 = pitch
    	lw $a1, chordduration      # $a1 = duration
    	lw $a2, instrument     # $a2 = instrument
    	lw $a3, volume      # $a3 = volume
    	li $v0, 31          # syscall for aggregating notes for later (chords)
    	syscall
    	
    	# HOLD OUT THE CHORD
    	lw $a0, chordduration # $a0 = duration
    	li $v0, 32     # command to play all parts of the chord
    	syscall
    	
    	jr $ra

RandomizePlayers:
	# get 0 or 1 randomly
	li $a0, 0
	li $a1, 2
	li $v0, SysRandIntRange
	syscall
	
	# check and set
	li $t1, 1
	slt $t0, $a0, $t1
	beq $t0, 1, SetPlayerAsFirstPlayer
	j SetComputerAsFirstPlayer
	
SetPlayerAsFirstPlayer:
	#set player 1
	li $s6, 1
	la $t1, firstPlayer
	sw $s6, 0($t1)
	
	# set player 2
	li $s7, 2
	la $t1, secondPlayer
	sw $s7, 0($t1)
	
	# OPENING MESSAGE
	la $a0, playerselectionmessage1
	li $v0, SysPrintString
	syscall
	
	jr $ra

SetComputerAsFirstPlayer:
	# set computer
	li $s6, 2
	la $t1, firstPlayer
	sw $s6, 0($t1)
	
	# set player
	li $s7, 1
	la $t1, secondPlayer
	sw $s7, 0($t1)
	
	# OPENING MESSAGE
	la $a0, playerselectionmessage2
	li $v0, SysPrintString
	syscall
	
	jr $ra
	
ResetGame:
	li $t0, 0 # i = 0
	li $t1, 36 # i < 36 condition
	
	addi $sp, $sp, -12
	sw $s0, 0($sp)
	sw $s1, 4($sp)
	sw $ra, 8($sp)
	jal ResetGrids
	lw $ra, 8($sp)
	lw $s1, 4($sp)
	lw $s0, 0($sp)
	addi $sp, $sp, 12
	
	addi $sp, $sp, -4
	sw $ra, 0($sp)
	jal SetGrids
	lw $ra, 0($sp)
	addi $sp, $sp, 4
	
	jr $ra
	
PlayerWinTheme:
	la $t0, playerwinmelody
	li $t1, 0
	
	lw $a0, 0($t0)      # $a0 = pitch
    	lw $a1, playerwinthemenoteduration   # $a1 = duration
    	lw $a2, instrument     # $a2 = instrument
    	lw $a3, volume      # $a3 = volume
    	li $v0, SysMidiOutSync
    	syscall
    	
    	addi $t0, $t0, 4
    	
    	lw $a0, 0($t0)      # $a0 = pitch
    	lw $a1, playerwinthemenoteduration   # $a1 = duration
    	lw $a2, instrument     # $a2 = instrument
    	lw $a3, volume      # $a3 = volume
    	li $v0, SysMidiOutSync
    	syscall
    	
    	addi $t0, $t0, 4
    	
    	lw $a0, 0($t0)      # $a0 = pitch
    	lw $a1, playerwinthemenoteduration   # $a1 = duration
    	lw $a2, instrument     # $a2 = instrument
    	lw $a3, volume      # $a3 = volume
    	li $v0, SysMidiOutSync
    	syscall
    	
    	# first chord
    	la $t0, playerwinchordnotes1
    	
    	lw $a0, 0($t0)      # $a0 = pitch
    	lw $a1, playerwinthemechordduration1      # $a1 = duration
    	lw $a2, instrument     # $a2 = instrument
    	lw $a3, volume      # $a3 = volume
    	li $v0, 31          # syscall for aggregating notes for later (chords)
    	syscall
    	
    	addi $t0, $t0, 4
    	lw $a0, 0($t0)      # $a0 = pitch
    	lw $a1, playerwinthemechordduration1      # $a1 = duration
    	lw $a2, instrument     # $a2 = instrument
    	lw $a3, volume      # $a3 = volume
    	li $v0, 31          # syscall for aggregating notes for later (chords)
    	syscall
    	
    	addi $t0, $t0, 4
    	lw $a0, 0($t0)      # $a0 = pitch
    	lw $a1, playerwinthemechordduration1      # $a1 = duration
    	lw $a2, instrument     # $a2 = instrument
    	lw $a3, volume      # $a3 = volume
    	li $v0, 31          # syscall for aggregating notes for later (chords)
    	syscall
    	
    	addi $t0, $t0, 4
    	lw $a0, 0($t0)      # $a0 = pitch
    	lw $a1, playerwinthemechordduration1      # $a1 = duration
    	lw $a2, instrument     # $a2 = instrument
    	lw $a3, volume      # $a3 = volume
    	li $v0, 31          # syscall for aggregating notes for later (chords)
    	syscall
    	
    	# HOLD OUT THE CHORD
    	lw $a0, playerwinthemechordduration1 # $a0 = duration
    	li $v0, 32     # command to play all parts of the chord
    	syscall
    	
    	# first chord
    	la $t0, playerwinchordnotes2
    	
    	lw $a0, 0($t0)      # $a0 = pitch
    	lw $a1, playerwinthemechordduration2      # $a1 = duration
    	lw $a2, instrument     # $a2 = instrument
    	lw $a3, volume      # $a3 = volume
    	li $v0, 31          # syscall for aggregating notes for later (chords)
    	syscall
    	
    	addi $t0, $t0, 4
    	lw $a0, 0($t0)      # $a0 = pitch
    	lw $a1, playerwinthemechordduration2      # $a1 = duration
    	lw $a2, instrument     # $a2 = instrument
    	lw $a3, volume      # $a3 = volume
    	li $v0, 31          # syscall for aggregating notes for later (chords)
    	syscall
    	
    	addi $t0, $t0, 4
    	lw $a0, 0($t0)      # $a0 = pitch
    	lw $a1, playerwinthemechordduration2      # $a1 = duration
    	lw $a2, instrument     # $a2 = instrument
    	lw $a3, volume      # $a3 = volume
    	li $v0, 31          # syscall for aggregating notes for later (chords)
    	syscall
    	
    	addi $t0, $t0, 4
    	lw $a0, 0($t0)      # $a0 = pitch
    	lw $a1, playerwinthemechordduration2      # $a1 = duration
    	lw $a2, instrument     # $a2 = instrument
    	lw $a3, volume      # $a3 = volume
    	li $v0, 31          # syscall for aggregating notes for later (chords)
    	syscall
    	
    	# HOLD OUT THE CHORD
    	lw $a0, playerwinthemechordduration2 # $a0 = duration
    	li $v0, 32     # command to play all parts of the chord
    	syscall
    	
	j Exit
	
ComputerWinTheme:
	la $t0, computerwinmelody
	li $t1, 0
	
	lw $a0, 0($t0)      # $a0 = pitch
    	lw $a1, computerduration1   # $a1 = duration
    	lw $a2, instrument     # $a2 = instrument
    	lw $a3, volume      # $a3 = volume
    	li $v0, SysMidiOutSync
    	syscall
    	
    	addi $t0, $t0, 4
    	
    	lw $a0, 0($t0)      # $a0 = pitch
    	lw $a1, computerduration1   # $a1 = duration
    	lw $a2, instrument     # $a2 = instrument
    	lw $a3, volume      # $a3 = volume
    	li $v0, SysMidiOutSync
    	syscall
    	
    	addi $t0, $t0, 4
    	
    	lw $a0, 0($t0)      # $a0 = pitch
    	lw $a1, computerduration1   # $a1 = duration
    	lw $a2, instrument     # $a2 = instrument
    	lw $a3, volume      # $a3 = volume
    	li $v0, SysMidiOutSync
    	syscall
    	
    	addi $t0, $t0, 4
    	
    	lw $a0, 0($t0)      # $a0 = pitch
    	lw $a1, computerduration2   # $a1 = duration
    	lw $a2, instrument     # $a2 = instrument
    	lw $a3, volume      # $a3 = volume
    	li $v0, SysMidiOutSync
    	syscall
    	
	j Exit
	
TieTheme:
	# first chord
    	la $t0, tiechord1
    	
    	lw $a0, 0($t0)      # $a0 = pitch
    	lw $a1, tieduration      # $a1 = duration
    	lw $a2, instrument     # $a2 = instrument
    	lw $a3, volume      # $a3 = volume
    	li $v0, 31          # syscall for aggregating notes for later (chords)
    	syscall
    	
    	addi $t0, $t0, 4
    	lw $a0, 0($t0)      # $a0 = pitch
    	lw $a1, tieduration      # $a1 = duration
    	lw $a2, instrument     # $a2 = instrument
    	lw $a3, volume      # $a3 = volume
    	li $v0, 31          # syscall for aggregating notes for later (chords)
    	syscall
    	
    	addi $t0, $t0, 4
    	lw $a0, 0($t0)      # $a0 = pitch
    	lw $a1, tieduration      # $a1 = duration
    	lw $a2, instrument     # $a2 = instrument
    	lw $a3, volume      # $a3 = volume
    	li $v0, 31          # syscall for aggregating notes for later (chords)
    	syscall
    	
    	addi $t0, $t0, 4
    	lw $a0, 0($t0)      # $a0 = pitch
    	lw $a1, tieduration      # $a1 = duration
    	lw $a2, instrument     # $a2 = instrument
    	lw $a3, volume      # $a3 = volume
    	li $v0, 31          # syscall for aggregating notes for later (chords)
    	syscall
    	
    	# HOLD OUT THE CHORD
    	lw $a0, tieduration # $a0 = duration
    	li $v0, 32     # command to play all parts of the chord
    	syscall
    	
    	# second chord
    	la $t0, tiechord2
    	
    	lw $a0, 0($t0)      # $a0 = pitch
    	lw $a1, tieduration      # $a1 = duration
    	lw $a2, instrument     # $a2 = instrument
    	lw $a3, volume      # $a3 = volume
    	li $v0, 31          # syscall for aggregating notes for later (chords)
    	syscall
    	
    	addi $t0, $t0, 4
    	lw $a0, 0($t0)      # $a0 = pitch
    	lw $a1, tieduration      # $a1 = duration
    	lw $a2, instrument     # $a2 = instrument
    	lw $a3, volume      # $a3 = volume
    	li $v0, 31          # syscall for aggregating notes for later (chords)
    	syscall
    	
    	addi $t0, $t0, 4
    	lw $a0, 0($t0)      # $a0 = pitch
    	lw $a1, tieduration      # $a1 = duration
    	lw $a2, instrument     # $a2 = instrument
    	lw $a3, volume      # $a3 = volume
    	li $v0, 31          # syscall for aggregating notes for later (chords)
    	syscall
    	
    	addi $t0, $t0, 4
    	lw $a0, 0($t0)      # $a0 = pitch
    	lw $a1, tieduration      # $a1 = duration
    	lw $a2, instrument     # $a2 = instrument
    	lw $a3, volume      # $a3 = volume
    	li $v0, 31          # syscall for aggregating notes for later (chords)
    	syscall
    	
    	# HOLD OUT THE CHORD
    	lw $a0, tieduration # $a0 = duration
    	li $v0, 32     # command to play all parts of the chord
    	syscall
    	
	j Exit

Exit:
	li $v0, SysExit
	syscall
