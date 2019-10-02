TITLE Combinator!     (Caplain_Story_program_6B.asm)

; Author:                  Story Caplain
; Last Modified:           12/02/18
; OSU email address:       caplains@oregonstate.edu
; Course number/section:   CS 271
; Project Number:          6B   
; Due Date:                12/02/18
; Description:             This program gives the user a combinations problem and asks for their answer. It then tells them the 
;                          correct answer and if their guess matches it.
; CITING:                  This program borrows code from lecture 23.

; Implementation note: Parameters are passed on the system stack.

INCLUDE Irvine32.inc

;This Macro combines the parts of writing a string into one clean line
;receives: a string
;returns: none
;preconditions: none
;registers changed: edx
mString     MACRO buffer
   push     edx
   mov      edx, OFFSET buffer
   call     WriteString
   pop      edx
ENDM

.const
intro_1     DB          "Combinator", 0
intro_2     DB          "Programmed by Story Caplain", 0
greeting_1  DB          "Hello! What is your name?", 0
greeting_2  DB          "Hi, ", 0
greeting_3  DB          "This program will give you a combinations problem which you'll try to solve.", 0 
greeting_4  DB          "It will then tell you if you got it right, and if you didn't, it will show what the correct answer is.", 0
gameCount   DB          "Game Number: ", 0
elements    DB          "Number of elements in the set:               ", 0
choose      DB          "Number of elements to choose from the set:   ", 0
prompt      DB          "How many ways can you choose?:               ", 0
answer_1    DB          "There are ", 0
answer_2    DB          " combinations of ", 0
answer_3    DB          " elements from a set of ", 0
incorrect   DB          "You answered incorrectly... care to try again? ", 0
correct     DB          "You answered correctly! Want more practice? ", 0
again       DB          "Type Y to play again. Press any other key to quit...", 0
goodBye_1   DB          "Thank you for playing Combinator!", 0
goodAns     DB          "Number of correct responses:   ", 0
badAns      DB          "Number of incorrect responses: ", 0
goodBye_2   DB          "Until next time ", 0
error       DB          "Oops, looks like you entered invalid input, try again...", 0

.data
userName    BYTE        33      DUP(0)
input       BYTE        30      DUP(0)
userGuess   DWORD       0
num_N       DWORD       0
num_R       DWORD       0
result      DWORD       0
numRight    DWORD       0
numWrong    DWORD       0
game        DWORD       1
replay      DWORD       0

.code
main PROC
	call	intro

	call    getName
	
	call    Randomize

NewGame:
	push    OFFSET num_N
	push    OFFSET num_R
	call    showProblem

	push    game
	push    OFFSET userGuess
	push    OFFSET input
	call    getData

	push    OFFSET result
	call    combinations

	push    OFFSET numWrong
	push    OFFSET numRight
	push    result
	push    userGuess
	push    num_R
	push    num_N
	push    OFFSET game
	call    showResults

	call    askPlay

	cmp     eax, 1
	je      NewGame

	push    numRight
	push    numWrong
	call    goodBye

	exit	; exit to operating system
main ENDP

;Introduces the program
;receives: none
;returns: none
;preconditions:  none
;registers changed: edx
intro PROC
   mString   intro_1
   call      CrLf
   mString   intro_2
   call      CrLf
   call      CrLf
   ret   
intro	ENDP

;Procedure to get the user's name and greet them
;receives: greetings
;returns: User input string for their name.
;preconditions: User enters name as a string < 32 bytes
;registers changed: edx, ecx, ebp, esp
getName PROC

;Ask for user's name
   mString   greeting_1
   call      CrLf
   call      CrLf

;Get user's name
   mov       edx, OFFSET userName
   mov       ecx, SIZEOF userName
   call      ReadString

;Greet user by name
   call      CrLf
   mString   greeting_2
   mString   userName
   call      CrLf
   call      CrLf
   mString   greeting_3
   call      CrLf
   mString   greeting_4
   call      CrLf
   call      CrLf
   ret       
getName ENDP

;This procedure gives the user an N value and R value to let them solve out a problem 
;receives: num_N, num_R
;returns: num_N and num_R with values
;preconditions: none
;registers changed: ebp, esp, edi, ecx, eax
showProblem PROC
   push      ebp
   mov       ebp, esp
   mov       edi, [ebp + 12]
   mov       ecx, [ebp + 8]

   mString   elements                
   mov       eax, 9                  ;put upper limit in eax
   call      RandomRange             ;get random number in range 0-9
   add       eax, 3                  ;add 3 to number to simulate a range of 3-12
   mov       [edi], eax              ;store n value in num_N
   call      WriteDec                ;write number to screen
   call      CrLf
   call      RandomRange             ;since num_N is still in eax and is the upperLim we call randomrange on it to find R
   inc       eax                     ;inc eax to shift range up to start at 1
   mov       [ecx], eax              ;store eax in num_R
   mString   choose
   call      WriteDec                ;write num_R to screen
   call      CrLf
   call      CrLf

   pop       ebp
   ret       8
showProblem ENDP

;Gets the user's answer
;receives: user's input
;returns: input's new value
;preconditions: none
;registers changed: ebp, esp, eaax, ebx, ec, edx, esi, al
getData PROC
   push      ebp
   mov       ebp, esp

   call      CrLf
   mString   gameCount
   mov       eax, [ebp + 16]         ;Show user which game they are on
   call      WriteDec
   call      CrLf
   mov       ebx, [ebp + 8]
Get:
   mString   prompt
   mov       edx, [ebp + 8]          ;address of input
   mov       ecx, 31                 ;max size of input + 1
   call      ReadString              ;we use readstring to validate via ASCII
   mov       ecx, eax                ;store in ecx
   mov       esi, [ebp + 8]          ;point to first char in string
   cld                               ;set direction
   xor       edx, edx                ;clear edx register
Validating:
   lodsb
   cmp       al, 48
   jl        Redo1                   ;if ASCII value is less than 48 (1) jump to redo
   cmp       al, 57
   jg        Redo1                   ;if ASCII value is greater than 57 (9) jump to redo
   movzx     eax, al                 ;if valid put input into eax
   push      ecx                     ;store ecx's value

   mov       ecx, eax
   mov       ebx, 10
   mov       eax, edx                ;as shown how to do in lecture 23
   mul       ebx
   mov       edx, eax
   sub       ecx, 48
   add       edx, ecx
   pop       ecx                     ;restore register
   loop      Validating

   xor       ecx, ecx
   mov       ecx, [ebp + 12]         ;store valid input in userGuess
   mov       [ecx], edx
   jmp       Finput

Redo1:
   call      CrLf
   mString   error
   call      CrLF
   jmp       Get
Finput:
   pop       ebp
   ret       12
getData ENDP

;Calculates the correct number of combinations using recursion
;receives: user's guess, n value, and r value
;returns: correct answer
;preconditions: none
;registers changed: ebp, esp, ecx, eax, ebx, edx
combinations PROC                             ;N and R can be passed by VALUE, result must be passed by REFERENCE
   push      ebp
   mov       ebp, esp
   xor       ecx, ecx

   mov       eax, num_R
   mov       ebx, eax
   dec       ebx
   call      factorial                        ;Calculate R!

   mov       eax, num_N
   mov       ebx, num_R
   sub       eax, ebx                         ;eax holds (N - R)
   push      ecx
   mov       ebx, eax
   dec       ebx
   call      factorial                        ;Calculate (N - R)!
   pop       ecx

   mul       ecx                              ;ecx holds R!, eax holds (N - R)!, multiply eax by ecx
   mov       ecx, eax                         ;mov product of multiplication into ecx, ecx now holds R! * (N - R)!

   mov       eax, num_N
   push      ecx
   mov       ebx, eax
   dec       ebx
   call      factorial                        ;Calculate N!
   pop       ecx

   xor       edx, edx
   div       ecx                              ;Divide eax by ecx, N! / (R!(N - R)!), this will be our result!
   mov       ebx, [ebp + 8]                   ;put result's address into ebx
   mov       [ebx], eax                       ;put result's calculated value into result

   pop       ebp
   ret       4
combinations ENDP

;Caluculates a factorial via recursion
;recieves: N and R
;returns: N! and (N - R)!
;preconditions: none
;registers changed: eax, ebx, ecx
factorial PROC   
   cmp       eax, 0
   je        ZeroCase
   cmp       ebx, 1
   jle       DoneFac

   mul       ebx
   dec       ebx
   call      factorial

DoneFac:
   mov       ecx, eax
   jmp       SkipZeroCase
ZeroCase:
   mov       eax, 1
SkipZeroCase:
   ret       
factorial ENDP

;Shows the user their guess compared to the correct answer.
;receives: game, result, num_N, num_R
;returns: game, result
;precondtitions: none
;registers changed: ebp, esp, eax, ebx, edx
showResults PROC
   push      ebp
   mov       ebp, esp

   call      CrLf
   call      CrLf
   xor       ebx, ebx
   xor       eax, eax
   mov       ebx, [ebp + 8]                  ;Put game into ebx
   mov       eax, [ebx]
   inc       eax
   mov       [ebx], eax                      ;Store incremented game number back into game
   mstring   answer_1
   mov       eax, [ebp + 24]                 ;Show correct answer
   call      WriteDec
   mstring   answer_2
   mov       eax, [ebp + 16]
   call      WriteDec
   mstring   answer_3
   mov       eax, [ebp + 12]
   call      WriteDec

   call      CrLf
   call      CrLf

   mov       eax, [ebp + 24]
   mov       ebx, [ebp + 20]
   cmp       eax, ebx                       ;check if user's guess and the correct result are equal
   jne       Wrong                          ;If wrong jump to wrong, if correct continue
   mString   correct
   mov       ebx, [ebp + 28]                ;increment numRight
   mov       eax, [ebx]
   inc       eax
   mov       [ebx], eax
   jmp       DoneShowing
Wrong:
   mstring   incorrect
   mov       ebx, [ebp + 32]
   mov       eax, [ebx]
   inc       eax                            ;increment numWrong
   mov       [ebx], eax
DoneShowing:
   pop       ebp
   ret       28
showResults ENDP

;Says goodbye to user
;receives: username
;returns: none
;preconditions: none
;registers changed: edx
goodbye PROC
   push ebp
   mov  ebp, esp

   call      CrLf
   call      CrLf
   mString   goodAns
   mov       eax, [ebp + 12]                     ;numRight
   call      WriteDec
   call      CrLf
   mString   badAns
   mov       eax, [ebp + 8]                      ;numWrong
   call      WriteDec
   call      CrLf
   call      CrLf
   mString   goodBye_1
   call      CrLf
   call      CrLf
   mString   goodbye_2
   mString   userName
   call      CrLf
   call      CrLf

   pop       ebp
   ret       8
goodbye ENDP

;Asks the user if they want to play again
;receives: none
;returns: none
;preconditions: none
;registers changed: al, eax, edx
askPlay PROC
   mstring   again
   call      ReadChar
   cmp       al, 59h                 ;did user enter y?
   je        More                    ;if so, another game
   cmp       al, 79h                 ;did user enter Y?
   je        More                    ;if so, another game
   jmp       NoMore                  ;if not, quit and report
More:
   mov       eax, 1
   call      CrLf
   call      Clrscr                  ;Clear screen for new game
   jmp       Finished
NoMore:
   mov       eax, 0
   call      CrLf
Finished:
   call      CrLf
   ret       
askPlay ENDP

END main