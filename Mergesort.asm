; CPSC 232 - Assignment 7
; Author: Ryan Spadt
; Revisions: 0
; Date: 3 December 2020


.386
.model flat, stdcall
.stack 4096
ExitProcess proto, dwExitCode:dword


INCLUDE	Irvine16.inc


.data
welcomeMsg		BYTE	"CPSC 232 - Assignment 7", 0						; Welcome Message
displayUnsorted	BYTE	"The unsorted list is: ", 0							; Text for unsorted list
displaySorted	BYTE	"The sorted list is: ", 0							; Text for sorted list
unSortList		DWORD	35, 20, 10, 30, 40, 10, 25, 20, 
						100, 44, 76, 20, 22, 17, 5, 300,
						26, 32, 81, 63, 21, 1, 3, 29, 92					; unsorted list input
len1=LENGTHOF unSortList													; stores the length of unSortList
spacing			DWORD	",", 0												; a simple spacing text for displaying our list to console
sortList		DWORD	len1	DUP(?)										; declare uninitialized list of size the same as unsorted



.code

; ***************************************************************************************
;								MAIN PROCEDURE
; Description: 
;	Main Procedure of Program
;	Handles procedure calls and send intial stack frame data.
; Receives:
; Returns:
; Pre-conditions:
; Registers Changed:
; ***************************************************************************************
main PROC

	call _initConsole								; call _initConsole procedure

	push	[len1-1]								; pass the length of the array by value onto the stack
	push	0										; pass the value 0 as the start by value onto the stack
	push	OFFSET unSortList						; pass the array by reference onto the stack

	call _mergesort									; call _mergesort procedure
	call _printArray								; call _printArray procedure
	call _close										; call _close procedure

main endp


; ***************************************************************************************
;								_INITCONSOLE PROCEDURE
; Description: Displays welcome message, unsorted array data, and text for sorted array
; Receives:
; Returns: to console
; Pre-conditions:
; Registers Changed: edx, ecx, esi, eax
; ***************************************************************************************
_initConsole PROC

	mov edx, OFFSET welcomeMsg						; move message1 into edx
	call WriteString								; display message1 to console
	call crlf										; new line
	call crlf										; new line

	mov		edx, OFFSET displayUnsorted				; move displayUnsorted into edx register
	call	WriteString								; display to console the edx contents

	mov		ecx, [len1-1]							; move the value of len1-1 (last index of our list) into ecx
	mov		esi, 0									; move 0 into esi register
	L0:		cmp esi, (len1-1)						; compare esi register to len1, which is one less than the size of the list
		je _completed1								; if they are equal meaning esi has ouput the same amount of numbers jump to _completed1
		mov eax, DWORD PTR unSortList[esi*4]		; move into eax a pointer to the desired array index of unSortList
		call WriteDec								; write the value eax is pointing to, to the console
		mov edx, OFFSET spacing						; mov into edx register the spacing
		call WriteString							; write spacing to the console
		inc esi										; increment esi so we know we added another element to output
		loop L0										; loop L0

	_completed1:									; this is just an out label
	mov		eax, DWORD PTR unSortList[(len1-1)*4]	; move the last element of the list into eax register (since we did not want a comma at the end)
	call	WriteDec								; display that element to console
	call	crlf									; new line
	mov		edx, OFFSET displaySorted				; move text for sorted list into the edx register
	call	WriteString								; display the sorted text to the console
	ret												; return to main PROC

_initConsole endp


; ***************************************************************************************
;								_MERGESORT PROCEDURE
; Description: Divides and conquers unsorted array
; Receives: ebp+16 = end, ebp+12 = start, ebp+8 = array
; Returns: Singleton array elements to pass into _merge procedure
; Pre-conditions: Must have initial data on stack frame
; Registers Changed: ebp, esp, eax, ebx, edx
; ***************************************************************************************
; mergeSort(array, start, end) {}
_mergesort PROC	

; create stack frame
; push	ebp
; mov		ebp, esp
; sub esp, 0
; <--------------------------------------------------------------------------------------->
	enter 0, 0
; <--------------------------------------------------------------------------------------->

; if (start >= end) {return}
; <--------------------------------------------------------------------------------------->
	mov	eax, [ebp+16]	; end
	mov	ebx, [ebp+12]	; end - start
	cmp ebx, eax		; is start >= end ?
	jge _done			; if true return
; <--------------------------------------------------------------------------------------->

; int mid = (start + end) / 2;
; <--------------------------------------------------------------------------------------->
	xor	edx, edx		; clear out edx
	mov	eax, [ebp+12]	; move start in eax
	add	eax, [ebp+16]	; start + end
	mov	ebx, 2			; move two into ebx
	div ebx				; (start + end) / 2 --> eax = mid
; <--------------------------------------------------------------------------------------->

; left partition
; mergesort(array, start, mid);
; <--------------------------------------------------------------------------------------->
	push eax			; push the mid
	push [ebp+12]		; push the start
	push [ebp+8]		; push the array
	call _mergesort
	add esp, 12			; move stack pointer up 3
; <--------------------------------------------------------------------------------------->

; right partititon
; mergesort(array, mid+1, end);
; <--------------------------------------------------------------------------------------->
	push [ebp+16]		; push end
	inc eax				
	push eax			; push mid+1
	push [ebp+8]		; push array
	call _mergesort
	add esp, 12			; move stack pointer up 3
; <--------------------------------------------------------------------------------------->

; merge
; merge(input, mid, start, end);
; <--------------------------------------------------------------------------------------->
	push [ebp+16]		; push the end
	push [ebp+12]		; push the start
	dec eax				; we need to decrease mid by 1 otherwise everytime we iterate through we add 1 to mid (throws off merge)
	push eax			; push the mid
	push [ebp+8]		; push the array
	call _merge
	add esp, 16			; move stack pointer up 4
; <--------------------------------------------------------------------------------------->

_done:
	; mov esp, ebp <-- free up local space
	; pop ebp	   <-- pop the frame pointer out
		leave
	ret
 	
_mergesort endp


; ***************************************************************************************
;								_MERGE PROCEDURE
; Description: Merges partitions each pass until a sorted merged array is finished
; Receives:	ebp+20 = end, ebp+16 = start, ebp+12 = mid, ebp+8 = array
; Returns: 
; Pre-conditions:
; Registers Changed: esi, edi, edx, eax, ebx, ecx
; ***************************************************************************************
_merge PROC
	; push ebp
	; mov ebp, esp
		enter 0, 0
	push eax
	push ebx
	push ecx
	push esi
	push edi

	mov esi, [ebp+16]		; esi = start of left partition
	mov edi, [ebp+12]		
	inc edi					; edi = start of right partition or mid+1
	mov edx, [ebp+16]		; edx = indexing for placing elements into array

	; while (esi <= mid && edi <= end)
		while1:
			cmp esi, [ebp+12]		; esi <= mid
			jg while2				; if evaluates to false exit while loop
			cmp edi, [ebp+20]		; edi <= end
			jg while2				; if evaluates to false exit while loop

	; if (array[esi] < array[edi])
		_if1:
			mov eax, DWORD PTR unSortList[esi*4]		; left
			mov ebx, DWORD PTR unSortList[edi*4]		; right
			cmp eax, ebx								; array[esi] < array[edi]
			jge else1									

			xchg [sortList+edx*4], eax					; sort[edx] = unSort[esi]
			inc esi										; raise our left pointer up 1
			inc edx										; raise our index pointer up 1
			jmp while1
	; else
		else1:
			xchg [sortList+edx*4], ebx					; sort[edx] = array[edi]
			inc edx										; raise index pointer up 1
			inc edi										; raise right partition pointer up 1
			jmp while1

	; while (esi <= mid)
		while2:
			cmp esi, [ebp+12]							; esi <= mid
			jg while3

			mov eax, DWORD PTR unSortList[esi*4]		; left
			xchg [sortList+edx*4], eax					; sort[edx] = unsort[esi]
			inc edx										; raise index pointer up 1
			inc esi										; raise left partition pointer up 1
			jmp while2

	; while (edi <= high)
		while3:
			cmp edi, [ebp+20]							; edi <= end
			jg entry4

			mov eax, DWORD PTR unSortList[edi*4]		; right
			xchg [sortList+edx*4], eax					; sort[edx] = unSort[edi]
			inc edx										; raise index pointer up 1
			inc edi										; raise right partition pointer up 1
			jmp while3

	entry4:
		mov esi, [ebp+16]								; esi = start

	; for (esi = low; esi < edx; esi++)
		for1:
			cmp esi, edx								; esi < edx
			jge _end

			mov eax, DWORD PTR sortList[esi*4]			
			mov unSortList[esi*4], eax					; unSort[esi] = Sort[esi]
			inc esi
			jmp for1

	_end:
		pop edi
		pop esi
		pop ecx
		pop ebx
		pop eax

		; mov esp, ebp
		; pop ebp
			leave
		ret

_merge endp


; ***************************************************************************************
;								_PRINTARRAY PROCEDURE
; Description: Prints the sorted array to console
; Receives: from .data
; Returns: array elements to console
; Pre-conditions: N/A
; Registers Changed: ecx, esi, eax
; ***************************************************************************************
_printArray PROC

	mov		ecx, [len1-1]							; move the value of len1-1 (last index of list) into ecx
	mov		esi, 0									; move 0 into esi register
	L0:		cmp esi, (len1-1)						; compare esi register to len1-1, which is one less than the size of the list
		je _completed1								; if they are equal meaning esi has ouput the same amount of numbers jump to _completed1
		mov eax, DWORD PTR unSortList[esi*4]		; move into eax a pointer to the desired array index of unSortList
		call WriteDec								; write the value eax is pointing to, to the console
		mov edx, OFFSET spacing						; mov into edx register the spacing
		call WriteString							; write spacing to the console
		inc esi										; increment esi so we know we added another element to output
		loop L0										; loop L0

	_completed1:									; this is just an out label
	mov		eax, DWORD PTR unSortList[(len1-1)*4]	; move the last element of the list into eax register (since we did not want a comma at the end)
	call	WriteDec								; display that element to console
	ret												; return to main PROC
	
_printArray endp


_close PROC
	invoke ExitProcess, 0							; close down program
_close endp

END main
