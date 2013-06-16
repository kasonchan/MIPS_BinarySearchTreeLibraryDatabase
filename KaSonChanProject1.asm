#
# Project 1
# CSCE 2610 Section 001, Spring 2012
# Instructor: Michael Mohler 
# Due: March 28, 2012
# Student: Chan, Ka Son
# 
# Description: This is a program implementing a simple library database in MIPS 
# that is structured as a binary search tree.

.data
	root: .word 0			# BookNode *root = NULL;

	promptForID: .asciiz "Please enter the ID of your book: "
	promptForFindID: .asciiz "Please enter the id of the book you want to find: "
	promptForYearPublished: .asciiz "Please enter the year the book was published: "
	promptForTitle: .asciiz "Please enter the title of the book (Maximum 63 characters): "
	promptForDesc: .asciiz "Please enter a description of the book (Maximum 255 characters): "

	printNextline: .asciiz "\n"
	
	printWelcome: .asciiz "Welcome to the 2012 library catalog!!\n"
	printComExplain: .asciiz "\tA - Add a new record\n \tF - Find a record\n \tP - Perform a preorder traversal\n \tI - Perform an inorder traversal\n \tQ - Exit and quit the program\n\n"
	printCommand: .asciiz "Please enter a command (A,F,I,P,Q): "
	printACommand: .asciiz " - Add a new record...\n"
	printFCommand: .asciiz " - Find a record...\n"
	printPCommand: .asciiz " - Perform a preorder traversal...\n"
	printICommand: .asciiz " - Perform an inorder traversal...\n"
	printEndProg: .asciiz "Exit! Thank you for using this BST!\n"
	
	printID: .asciiz "ID: "
	printIDNotFound: .asciiz " - ID not found!\n"
	printIDExist: .asciiz " - ID already exists!\n"
	printYearPublished: .asciiz "Published: "
	printTitle: .asciiz "Title: "
	printDesc: .asciiz "Description: "
	printInvalidCommand: .asciiz "Invalid command.\n\n"
	printIDTitle: .asciiz "ID\tTitle\n"
	printTab: .asciiz "\t"

.text

###############################################################
# Main code 
# Loop to get the commands from user and perform commands
###############################################################

# main
# Prints welcome line and Command Explain line
main:
	li $v0, 4			# Print welcome line
	la $a0, printWelcome
	syscall
	
	li $v0, 4			# Print Command Explain line
	la $a0, printComExplain
	syscall

# End of main

# main_loop
# The main looping for getting commands from user
main_loop:
	li $v0, 4			# Prompt for the command character
	la $a0, printCommand
	syscall
	
	li $v0, 12			# Enter the command character
	syscall
	move $s0, $v0			# Store in $s0

	li $v0, 4			# Print nextline
	la $a0, printNextline
	syscall
	
	beq $s0, 'A', isA		# If command character = A (call isA)
	beq $s0, 'F', isF		# If command character = F (call isF)
	beq $s0, 'P', isP		# If command character = P (call isP)
	beq $s0, 'I', isI		# If command character = I (call isI)
	beq $s0, 'Q', isQ		# If command character = Q (call isQ)
	j invalidCommand		# Else invalid command

# End of main_loop

isA:
	li $v0, 11			# Print the command character
	move $a0, $s0
	syscall
	li $v0, 4			# Print A Command
	la $a0, printACommand
	syscall
	j addFunct			# Call addFunct
	j after				# Call after

isF:
	li $v0, 11			# Print the command character
	move $a0, $s0
	syscall
	li $v0, 4			# Print F Command
	la $a0, printFCommand
	syscall
	li $v0, 4			# Prompt for Find ID
	la $a0, promptForFindID
	syscall
	li $v0, 5			# Enter the Find ID
	syscall
	move $s6, $v0			# Save Find ID into $s6
	lw $s0, root			# curr = root
	jal find			# Call find
	j after				# Call after
	
isP:
	li $v0, 11			# Print the command character
	move $a0, $s0			# $a0 = $s0
	syscall
	li $v0, 4			# Print P Command
	la $a0, printPCommand
	syscall
	li $v0, 4			# PrintIDTitle
	la $a0, printIDTitle
	syscall
	lw $s0, root			# curr = root
	jal preOrder			# Call preOrder
	jal after			# Call after
	
isI:
	li $v0, 11			# Print the command character
	move $a0, $s0
	syscall
	li $v0, 4			# Print A Command
	la $a0, printICommand
	syscall
	li $v0, 4			# PrintIDTitle
	la $a0, printIDTitle
	syscall
	lw $s0, root			# curr = root
	jal inOrder			# Call inOrder
	j after				# Call after
	
isQ:
	li $v0, 4			# Print printEndProg line
	la $a0, printEndProg	
	syscall
	j exit				# Call exit

invalidCommand:
	li $v0, 4			# Print printInvalidCommand line
	la $a0, printInvalidCommand
	syscall
	j main_loop			# Call main_loop
	
after:
	li $v0, 4			# Print Newline
	la $a0, printNextline
	syscall	
	
	j main_loop			# Call main_loop

# exit
# Return to OS
exit:			
	li $v0, 4			# Print nextline
	la $a0, printNextline
	syscall	
									
	li $v0, 10			# Exit
	syscall

# End of exit

# End of main code

###############################################################
# End of Main code
###############################################################

###############################################################
# Add functionality
###############################################################

# AddFunct
# AddFunct manages the special case where root pointer is empty
# defined and get the ID from the user
addFunct:			
	lw $s0, root			# curr = root
	
	li $v0, 4			# Prompt for the ID
	la $a0, promptForID
	syscall
	li $v0, 5			# Enter the ID
	syscall
	move $s5, $v0			# Save ID to $s5
	
	beq $s0, $0, addRoot		# If root == NULL
	j addRecursive			# Call addRecursive

# End of addFunct

# addRoot
# AddRoot is function to add new tree node to the root
addRoot:	
	li $v0, 9			# Allocate memory
	li $a0, 336			# 336 bytes - 4 bytes ID, 4 bytes year, 64 bytes title, 256 bytes description, 4 bytes left pointer, 4 bytes right pointer
	syscall				# to $v0
	move $s0, $v0			# Store allocated memory to $s0, make the new Node the current Node
	sw $s0, root			# And store it in to the root
	j addInput

# End of addRoot

# addInput
# addInput handles user input and output for the book details
# with the given ID
addInput: 
	move $t0, $s5
	sw $t0, 0($s0)			# Store ID into node
	
	li $v0, 4			# Prompt for the Year Published
	la $a0, promptForYearPublished
	syscall
	li $v0, 5			# Enter Year
	syscall
	move $t0, $v0
	sw $t0, 4($s0)			# Store Year into node
	
	li $v0, 4			# Prompt for the Title
	la $a0, promptForTitle
	syscall
	li $v0, 9			# Allocate memory (srbk) syscall
	li $a0, 64			# Allocate 64 bytes for Title
	syscall				# Places the address of those 64 bytes into $v0
	move $v1, $v0
	li $v0, 8			# Read a string
	move $a0, $v1			# Store it in our heap memory
	li $a1, 64			# Maximum string size is 63 (automatically adds the null character)
	syscall
	move $t0, $v1
	sw $t0, 8($s0)			# Store Title into node
	
	li $v0, 4			# Prompt for the Description
	la $a0, promptForDesc
	syscall
	li $v0, 9			# Allocate memory (srbk) syscall
	li $a0, 256			# Allocate 256 bytes for Description
	syscall				# Places the address of those 256 bytes into $v0
	move $v1, $v0
	li $v0, 8			# Read a string
	move $a0, $v1			# Store it in our heap memory
	li $a1, 256			# Maximum string size is 255 (automatically adds the null character)
	syscall
	move $t0, $v1
	sw $t0, 72($s0)			# Store Description into node
	
	sw $0, 328($s0)			# Store NULL in left pointer
        sw $0, 332($s0)			# Store NULL in right pointer
	
	j after

# End of addInput

# addRecursive
# addRecursive positions the element in the tree and creates a 
# new node
addRecursive:
	addi, $sp, $sp, -4		# Allocate 1 register to stack
	sw $a0, 0($sp)			# $a0 is the register
	
	lw $a0, 0($s0)			# $a0 = curr->ID = bPtr->ID
	move $a1, $s5			# #a1 = newID
	
	# if(bPtr->id == newID)
	bne $a0, $a1, ELSEIF1		
	li $v0, 4			# Prompt ID
	la $a0, printID
	syscall
	lw $a0, 0($s0)			# $a1 = curr->ID
	li $v0, 1
	syscall
	li $v0, 4
	la $a0, printIDExist		# Print ID Exist
	syscall
	
	j after				# Call after
	
ELSEIF1:
	# else if(bPtr->id > newID && bPtr->left != NULL)
	ble $a0, $a1, ELSEIF2
	lw $a3, 328($s0)		# bPtr->left
	beq $a3, $0, ELSEIF2
	lw $s0, 328($s0)		# curr = curr->Left
	j addRecursive			# Call addRecursive

ELSEIF2:
	lw $v0, 4($sp)			# Retrieve original curr
	# else if(bPtr->id < newID && bPtr->right != NULL)
	bge $a0, $a1, ELSEIF3
	lw $a3, 332($s0)		# bPtr->right
	beq $a3, $0, ELSEIF3
	lw $s0, 332($s0)		# curr = curr->Right
	j addRecursive			# Call addRecursive

ELSEIF3:
	# else if(bPtr->id > newID)
	ble $a0, $a1, ELSE		
	li $v0, 9			# Allocate memory (srbk) syscall
	li $a0, 336			# 336 bytes
	syscall
	sw $v0, 328($s0)		# curr->left = newNode
	move $s0, $v0
	addi $sp, $sp, 4
	j addInput			# Call addInput

ELSE:
	# else
	li $v0, 9			# Allocate memory (srbk) syscall
	li $a0, 336			# 336 bytes
	syscall
	sw $v0, 332($s0)		# curr->right = newNode
	move $s0, $v0
	addi $sp, $sp, 4
	j addInput			# Call addInput

# End of addRecursive
	
###############################################################
# End of Add functionality
###############################################################

###############################################################
# Traversal functions, using recursion
###############################################################

# preOrder
# Preorder traversal (parent, left, right)
preOrder:
	move $a0, $s0			# $a0 = $s0
	
	# if(bPtr == NULL)
	bne $a0, $0, preOrderRecurse
	jr $ra				# Return to caller
	
preOrderRecurse:
	addi, $sp, $sp, -8		# Allocate 2 registers to stack
	sw $ra, 0($sp)			# $ra is the first register
	sw $a0, 4($sp)			# $a0 is the second register
	
	jal printSmall			# Call printSmall
	
	lw $s0, 328($s0)		# curr = curr->left
	jal preOrder			# Call preOrder
	
	lw $a0, 4($sp)			# Retrieve original value of $a0
	move $s0, $a0			# $s0 = $a0
	lw $s0, 332($s0)		# curr = curr->right
	jal preOrder			# Call preOrder
	
	lw $ra, 0($sp)			# Retrieve original return address
	addi $sp, $sp, 8		# Free the 2 register stack spaces
	jr $ra				# Return to caller

# End of preOrder traversal

# inOrder
# Inorder traversal (left, parent, right)	
inOrder:
	move $a0, $s0			# a0 = $s0

	# if(bPtr == NULL)
	bne $a0, $0, inOrderRecurse
	jr $ra				# Return to caller
	
inOrderRecurse:
	addi, $sp, $sp, -8		# Allocate 2 registers to stack
	sw $ra, 0($sp)			# $ra is the 1st
	sw $a0, 4($sp)			# $a0 is the 2nd
	
	lw $s0, 328($s0)		# curr = curr->left
	jal inOrder			# Call inOrder
	
	lw $a0, 4($sp)			# Retrieve original $a0
	move $s0, $a0			# $s0 = $a0
	jal printSmall			# Call printSmall

	lw $s0, 332($s0)		# curr = curr->right
	jal inOrder			# Call inOrder
	
	lw $ra, 0($sp)			# Retrieve original $ra
	addi $sp, $sp, 8		# Free the 2 register stack spaces 
	jr $ra

# End of inOrder traversal

###############################################################
# End of Traversal functions, using recursion
###############################################################

###############################################################
# Printing functions
###############################################################

# printSmall
# It prints only the title and ID of the pointed to node
printSmall:
	lw $a0, 0($s0)			# get the ID of this node
	li $v0, 1			# print it
	syscall
	
	li $v0, 4			# PrintTab
	la $a0, printTab
	syscall
	
	lw $a0, 8($s0)			# get the Title of this node
	li $v0, 4
	li $a1, 64			# print it
	syscall
	
	jr $ra				# Return to caller

# End of printSmall

# printLarger
# It prints all the data (ID, Title, Description and Year published)
# of the pointed to node
printLarge:
	li $v0, 4			# Print ID
	la $a0, printID
	syscall
	
	lw $a0, 0($s0)			# get the ID of this node
	li $v0, 1			# print it
	syscall
	
	li $v0, 4			# Print nextline
	la $a0, printNextline
	syscall
	
	li $v0, 4			# Print title
	la $a0, printTitle
	syscall
	
	lw $a0, 8($s0)			# get the Title of this node
	li $v0, 4
	li $a1, 64			# print it
	syscall
	
	li $v0, 4			# Print Year Published
	la $a0, printYearPublished
	syscall
	lw $a0, 4($s0)			# get the Year of this node
	li $v0, 1
	syscall
	
	li $v0, 4			# Print nextline
	la $a0, printNextline
	syscall
	
	li $v0, 4			# Print Description
	la $a0, printDesc
	syscall
	lw $a0, 72($s0)			# get the Description of this node
	li $v0, 4
	li $a1, 64			# print it
	syscall
	
	jr $ra				# Return to caller

# End of printLarge

###############################################################
# End of Printing functions
###############################################################

###############################################################
#  Search functionality. Print the book if you find it.
###############################################################

# find
# Find a record in the tree and prints if it exists
# Report to the user if a record is not found in the tree
find:
	addi, $sp, $sp, -8		# Allocate 2 register stack spaces
	sw $ra, 0($sp)			# $ra is the 1st
	sw $v0, 4($sp)			# $v0 is the 2nd
	
	move $v0, $s0			# $v0 = curr
	move $a1, $s6			# a1 = targetID
	
	# if(bPtr == NULL)
	bne $v0, $0, FELSEIF1		
	li $v0, 4			# Prompt ID
	la $a0, printID
	syscall
	move $a0, $a1			# $a0 = $a1
	li $v0, 1
	syscall
	li $v0, 4
	la $a0, printIDNotFound		# Print ID Not Found
	syscall
	
	lw $ra, 0($sp)			# Retrieve original $ra
	addi, $sp, $sp, 8		# Free the 2 register stack spaces
	jr $ra				# Return to caller
	
FELSEIF1:
	lw $a0, 0($v0)			# Retrieve the original $a0
	
	# else if(bPtr->id == targetID)
	bne $a0, $a1, FELSEIF2
	jal printLarge			# Call printLarge
	
	lw $ra, 0($sp)			# Retrieve the original $ra
	addi, $sp, $sp, 8		# Free the 2 register stack spaces
	jr $ra				# Return to caller
	
FELSEIF2:
	# else if(bPtr->id > targetID)
	ble $a0, $a1, FELSE 	
	lw $s0, 328($s0)		# curr = curr->Left
	j find				# Call find

FELSE:
	lw $v0, 4($sp)			# Retrieve original curr
	# else
	lw $s0, 332($s0)		# curr = curr->Right
	j find				# Call find

# End of find

###############################################################
#  End of Search functionality. Print the book if you find it.
###############################################################

###############################################################
# End of program
###############################################################
