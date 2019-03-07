ADD SP, SP, 0x1000 ;;; Get space on the stack
ADR X11, thedata ;;; Read-only data location to be read from

start:
MOV X9, X11 ;;
LDUR X0, [X9, #0]  
BL new             ;;initiate first node
MOV X1, X7         ;;address of head node in X1 

loop:
ADD X9, X9, #8      ;;8 bytes to get next address
LDUR X0, [X9, #0]   
CMP X0, #0          ;;if value is 0x0, don't create node, else create
B.EQ finish
BL new
MOV X0, X7          ;;now new node address in X0, and first head node in X1
BL insert	
MOV X1, X7	        ;;move new head node address into X1
B loop
finish:
MOV X0, X7	        ;;move head address into X0
MOV X1, #0x60000
BL copy
WFI

;;new works, tested
new:
SUB SP, SP, #32
STUR LR, [SP, #24]  ;;NECESSARY cause of sbrk call
STUR X0, [SP, #16]
STUR X1, [SP, #8]
STUR X2, [SP, #0]

MOV X1, X0
MOV X0, #16     ;;for 8 byte value and 8 byte address?? (address + 8)
BL sbrk
STUR X1, [X7, #0]
MOVZ X2, 0x0
STUR X2, [X7, #8]

LDUR X2, [SP, #0]   ;;restore values back
LDUR X1, [SP, #8]   
LDUR X0, [SP, #16]
LDUR LR, [SP, #24]
ADD SP, SP, #32
BR LR


;;preserves arguments X0, X1, nothing else: X2, X3, X4, X7
insert:
MOV X7, X1        ;;store head node's address in X7
MOV X2, X1        ;;store head node's address in X2

SUB SP, SP, #24
STUR LR, [SP, #16]
STUR X0, [SP, #8]
STUR X1, [SP, #0]
traverseList:
LDUR X3, [X0, #0]   ;;new node value
LDUR X4, [X1, #0]   ;;head node value
CMP X3, X4          ;;compare X4 and X3, if link (X3) is larger, head node = next node, recursive call, else insert
B.LE foundSpot

MOV X2, X1         ;;previous node address in X2 
LDUR X1, [X1, #8]  ;;find address of next node (add 8 bytes)
CMP X1, #0         ;;check if end of list, if end branch to end insert
B.EQ end
BL traverseList

foundSpot:  ;;found: X0 is address of link node, X3 value of link, X1 address of node to insert before, X4 value of node 
CMP X1, X2
B.EQ head
;;address of node before(X2) + 8 points to insertedNode address (X0)
;;insertedNode(X0) address+8 points to currentNode (X1)
STUR X0, [X2, #8]
STUR X1, [X0, #8]
B stopTraversal

head:
;;X2 and X1 has address of head, X0 has address of insertNode, X0 + 8 points to X1, update head in X7
STUR X1, [X0, #8]
MOV X7, X0
B stopTraversal

end:
;;X1 holds 0x0, X2 is address of last node, X0 is address of insertNode, X2 + 8 points to insertNode
STUR X0, [X2, #8]
B stopTraversal

stopTraversal:
LDUR X1, [SP, #0]   ;;restore to point back to original head
LDUR X0, [SP, #8]
LDUR LR, [SP, #16]
ADD SP, SP, #24
BR LR

;;preserving argument X0, nothing else: X7
count:
SUB SP, SP, #8
STUR X0, [SP, #0]
MOVZ X7, #1
C1:
LDUR X0, [X0, #8]
CMP X0, #0
B.EQ E2
ADD X7, X7, #1
B C1
E2:
LDUR X0, [SP, #0]
ADD SP, SP, #8
BR LR

;;preserves arguments X0, X1, nothing else: X2, X7
copy:
SUB SP, SP, #24
STUR LR, [SP, #16]  ;;cause we call count later
STUR X1, [SP, #8]
STUR X0, [SP, #0]

;; X0 is address of head, X1 is address in memory where storing, returns length in X0 address call count (8 bytes)
BL count
STUR X7, [X1, #0]
ADD X1, X1, #8   ;;get next address to put array at

CPL1:
LDUR X2, [X0, #0]
STUR X2, [X1, #0]
LDUR X0, [X0, #8]
ADD X1, X1, #8
CMP X0, #0
B.EQ CPE1
B CPL1

CPE1:
LDUR X0, [SP, #0]
LDUR X1, [SP, #8]
LDUR LR, [SP, #16]
ADD SP, SP, #24
BR LR

;;; End of your code
;;; DO NOT MODIFY THIS LINE. 
;;; Modification made below here will NOT be included in your submission!
sbrk:
CBNZ X27,sbkadd
MOV X27,0x60000
ADD X27,X27,0x500
sbkadd:
MOV X7,X27
ADD X27,X27,X0
BR LR

thedata:
.8byte 0x8,0x5,0x16,0x272,0x109,0x9971,0x0
