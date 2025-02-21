#    Sieve of Eratosthenes - finds all prime numbers <= n
#    Copyright (C) 2019  Nicholas Johnson
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <https://www.gnu.org/licenses/>.

.data
  isPrime: .space 4000 # Bytes are boolean array (4 * largest)
  prompt: .asciiz "Input number to stop calculating primes at (Enter to continue): "
  resp: .asciiz "Will calculate all primes up to "
  too_small: .asciiz "The number you entered was too small."
  too_large: .asciiz "The number you entered was too large."
  newline: .asciiz "\n"
  smallest: .word 2 # Smallest allowed n value
  largest: .word 1000 # Largest allowed n value
.text
.globl main

main:
  user_prompt:

  # Ask user for n value
  la $a0, prompt
  li $v0, 4
  syscall

  # Await user input
  li $v0, 5
  syscall # n value is now in register $v0

  move $s0, $v0 # Save n value into register $s0

  # Load smallest and largest n values to registers
  lw $t0, smallest
  lw $t1, largest

  # Error checking n values
  # Check that n value is not too small
  bge $s0, $t0, continue1
  jal user_prompt_small
  j user_prompt

  continue1:

  # Check that n value is not too large
  ble $s0, $t1, continue2
  jal user_prompt_large
  j user_prompt

  continue2:

  # Calculate sqrt(n) result
  move $a0, $s0
  jal isqrt # v0 = sqrt(n)
  move $s1, $v0

  # Print response to user
  la $a0, resp
  li $v0, 4
  syscall

  # Print out user input number n
  move $a0, $s0
  li $v0, 1
  syscall

  # Print new line
  la $a0, newline
  li $v0, 4
  syscall

  la $t0, isPrime # Beginning address of array
  li $t1, 1 # Constant number 1

  # Calculate array offset
  sll $t2, $s0, 2
  add $t2, $t0, $t2 # Base address + offset

  # Initialize isPrime array to 1's
  initializeArray:
    bge $t0, $t2, continue3
    sw $t1, 0($t0) # Save 1 to memory address at $t0
    addi $t0, $t0, 4 # Increment memory address by 4 bytes (4 bytes per integer word)
    j initializeArray

  continue3:
    la $t0, isPrime # Beginning address of array
    move $t5, $t0 # Copy beginning address of array
    li $t1, 2 # $t0 is the starting increment value

  outerloop: # Beginning of outer loop (loops from smallest to root(n))
    bgt $t1, $s1, exitouter

    # OUTER LOOP INSTRUCTIONS IN HERE
    lw $t2, 0($t0) # Contains data inside array memory location

    bne $t2, 1, exitinner # If the number is prime (1), then execute inner loop

    move $t3, $t1 # Copy increment value to $t3 register
    mult $t3, $t3 # Start at $t3 ^ 2
    mflo $t3

    innerloop: # Loop through 2i, 3i, 4i, ..., not exceeding n
      bgt $t3, $s0, exitinner

      # INNER LOOP INSTRUCTIONS IN HERE
      subi $t6, $t3, 2 # Subtract 2 since prime counting starts at 2

      sll $t4, $t6, 2 # Calculate memory address offset for composite number
      add $t4, $t5, $t4 # Base address + offset

      sw $zero, 0($t4) # Set number to not prime

      add $t3, $t3, $t1 # Add multiple of base number
      # INNER LOOP INSTRUCTIONS IN HERE

      j innerloop

    exitinner:
    addi $t0, $t0, 4 # Increment memory address by 4 bytes (4 bytes per integer word)
    addi $t1, $t1, 1
    # OUTER LOOP INSTRUCTIONS IN HERE

    j outerloop

  exitouter:

  la $t0, isPrime # Beginning address of array
  li $t1, 2 # Loop counter
  li $t2, 2 # Number in question (for primality)

  printresults:
    # Print results using loop
    bgt $t1, $s0, continue4

    # PRINT LOOP INSTRUCTIONS IN HERE
    lw $t3, 0($t0) # Load boolean (prime or composite)

    # Skip printing if number is composite
    bne $t3, 1, continue5

    # Print number only if prime
    move $a0, $t2
    li $v0, 1
    syscall
    # PRINT LOOP INSTRUCTIONS IN HERE

    # Print new line
    la $a0, newline
    li $v0, 4
    syscall

    continue5:
    addi $t0, $t0, 4 # Increment memory address
    addi $t1, $t1, 1 # Increment loop counter
    addi $t2, $t2, 1 # Increment number in question
    j printresults

  continue4:
  # End the program
  li $v0, 10
  syscall

user_prompt_small:

  # Print message that input n was too small
  la $a0, too_small
  li $v0, 4
  syscall

  # Print newline
  la $a0, newline
  li $v0, 4
  syscall

  jr $ra # Return to caller

user_prompt_large:

  # Print message that input n was too large
  la $a0, too_large
  li $v0, 4
  syscall

  # Print newline
  la $a0, newline
  li $v0, 4
  syscall

  jr $ra # Return to caller

