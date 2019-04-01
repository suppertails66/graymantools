
;========================================
; basic stuff
;========================================

.nds

; end of arm7 binary, location of our new code
arm7End equ 0x23a86d0

sizeOf256ColorPattern equ 64
strlen equ 0x20124d8

; button state array.
; +0 = buttons triggered
; +2 = buttons pressed
; +4 = ???
buttonStates equ 0x20d7014
buttonStates_pressedOffset equ 0
buttonStates_triggeredOffset equ 2

; 2 = b
skipButtonBitNum equ 2

;========================================
; defines
;========================================

; nonzero to make everything print instantly
INSTANT_TEXT equ 0

; if nonzero, holding the B button fast-forwards text
B_FAST_FORWARD equ 1

;========================================
; overwrites
;========================================

.open "out/romfiles/arm9.bin", 0x02000000
  
  ;===========================================================================
  ; use new credits pointers
  ;===========================================================================
  
  .org 0x203e6f0
  .dw newCreditsPointers
  
  ;===========================================================================
  ; credits centering
  ;===========================================================================
  
  .org 0x203e5a4
  creditsXOffset:
  b creditsXOffset_ext
  creditsXOffset_end:
  
  .if B_FAST_FORWARD
    ;===========================================================================
    ; fast-forward with B
    ;===========================================================================
    
    .org 0x2032c80
    fastForward_waitSkipCheck:
    b fastForward_waitSkipCheck_ext
    
    .org 0x2032b74
    fastForward_bDuringMessageCheck:
    b fastForward_bDuringMessageCheck_ext

    ; fast-forward test
    .org 0x2032d9c
    fastForward_bDuringWaitCheck:
    b fastForward_bDuringWaitCheck_ext
  .endif

  ; fast-forward test
;  .org 0x2032d94
;  ldrh    r0, [r5, #2]
;  tst   r0, #1
  
  ;===========================================================================
  ; extended strings
  ;===========================================================================
  
  ;========================================
  ; trigger expanded string size hack
  ;========================================
  .org 0x201ba6c
  expandStringSize:
    b expandStringSize_ext
  end_expandStringSize:
  
;  ;========================================
;  ; TEST: set character width to 12
;  ;========================================
;  .org 0x201a1cc
;;  mov     r0, #12
  
  ;========================================
  ; trigger char unpacking hack 1
  ;========================================
  .org 0x201b0c0
  unpackChar_targetBuffer:
    b unpackChar_targetBuffer_ext
  end_unpackChar_targetBuffer:
  
  ;========================================
  ; trigger char unpacking hack 2
  ;========================================
  .org 0x201b0d4
  unpackChar_toNextRow:
    b unpackChar_toNextRow_ext
  end_unpackChar_toNextRow:
  
  ;========================================
  ; trigger char unpacking hack 3
  ;========================================
  .org 0x201b23c
  unpackChar_newComposition:
    b unpackChar_newComposition_ext
  end_unpackChar_newComposition:
  
  ;========================================
  ; trigger text color restoration fix
  ;========================================
  .org 0x201b714
  restoreTextColor_newUpdate:
    b restoreTextColor_newUpdate_ext
  
  ;========================================
  ; check for new font change code
  ;========================================
  .org 0x201a5dc
  changeFontOpcodeCheck:
    b changeFontOpcodeCheck_ext
    
  ;========================================
  ; double text speed
  ;========================================
  .org 0x201bacc
  doubleTextSpeed:
    b doubleTextSpeed_ext
  end_doubleTextSpeed:
  
  ;===========================================================================
  ; new font
  ;===========================================================================
  
  ;========================================
  ; overwrite old character encoding table
  ; with new font width table
  ;========================================
  .org 0x2074E54
  fontWidthTable:
    .incbin "out/font/fontwidth.bin"
  fontWidthTable_wide:
    .incbin "out/font/fontwidth_wide.bin"
  
  ;========================================
  ; overwrite font bitmap table with new
  ; one
  ;========================================
  .org 0x2075A84
  fontBitmapTable:
    .incbin "out/font/font.bin"
  fontBitmapTable_wide:
    .incbin "out/font/font_wide.bin"
  
  ;========================================
  ; no special handling for ASCII space
  ;========================================
  .org 0x201a3f0
  b 0x201a438
  
  ;========================================
  ; no special handling for digits or
  ; unrecognized ASCII values, and use
  ; new character lookup
  ;========================================
  .org 0x201a82c
    ; r1 must be low byte of encoding
    mov r1,r2
    b 0x201a88c
;;  b 0x201a88c
;  triggerNewFontLookup:
;    b newFontLookup
;  .org 0x201a894
;  end_triggerNewFontLookup:
  
  ;========================================
  ; do new font lookup/printing
  ;========================================
  .org 0x201a894
  triggerNewFontLookup:
    b newFontLookup
  .org 0x201a954
  end_triggerNewFontLookup:
  
  ;===========================================================================
  ; string width calculation fixes
  ;===========================================================================
  
  ;========================================
  ; initial track name in sound test
  ;========================================
  
  .org 0x204b91c
  triggerTrackNameWidthLookup:
    bl getStringWidth
    mov r1,r0
    nop
  
  ;========================================
  ; updated track name in sound test
  ; when "next" button is pressed
  ;========================================
  
  .org 0x204c67c
  triggerNextTrackNameWidthLookup:
    bl getStringWidth
    mov r1,r0
    ; make up work
    mov r0, r10
    nop
  
  ;========================================
  ; updated track name in sound test
  ; when "previous" button is pressed
  ;========================================
  
  .org 0x204c334
  triggerPrevTrackNameWidthLookup:
    bl getStringWidth
    mov r1,r0
    ; make up work
    mov r0, r10
    nop
  
  ;========================================
  ; scrolling text on music player (1)
  ;========================================
  
  .org 0x204bae4
  triggerMusicTestScrollingTextWidthLookup1:
    bl getStringWidth
    mov r10,r0
  
  ;========================================
  ; scrolling text on music player (2)
  ;========================================
  
  .org 0x204c334
  triggerMusicTestScrollingTextWidthLookup2:
    bl getStringWidth
    mov r1,r0
    mov r0, r10
    nop
  
  ;========================================
  ; dialogue copy
  ;========================================
  
;  .org 0x201a03C
;  triggerDialogueStringCopyWidthLookup:
;    b dialogueStringCopyWidthLookup
;;  end_triggerDialogueStringCopyWidthLookup:
;;  .org 0x201a048
;;  nop
;;  nop
  
  
.close

.open "out/romfiles/arm7.bin", 0x02380000
  
  ;========================================
  ; NEW CODE
  ;========================================
  
  .org arm7End
  
  ;===========================================================================
  ; strings are normally limited to certain
  ; arbitrary output sizes.
  ; expand these limits to allow for longer
  ; strings.
  ;===========================================================================
  
  expandStringSize_ext:
    ;=====
    ; the intended limit is located at sp+36.
    ; multiply it by 4.
    ; TODO: this is just a normal argument-on-stack, right?
    ; the code won't reuse it and call again with the updated value?
    ;=====
    ldr r0, [sp, #36]
    lsl r0, r0, #2
    str r0, [sp, #36]
    
    ; make up work
    ldr r0, [r4]
    b end_expandStringSize
  
  ;===========================================================================
  ; draw characters to their proper positions.
  ; 
  ; despite correctly tracking character placement down to the pixel level,
  ; the original game forces each character to align to a 16x16 grid.
  ; this means we have to manually deal with the pattern alignment.
  ;===========================================================================
  
  ;========================================
  ; hack 1: target our new buffer for
  ; unpacking rather than the intended
  ; destination surface
  ;========================================
  unpackChar_targetBuffer_ext:
    
    push {r0,r1}
      ; save the previously computed target so we can write to
      ; it later
      add r12,r7,r1
;      str r12,[pc,old_targetCharSurfacePointer-.]
      
      ; save charstruct pointer
      ldr r1,=compositionCharStructPointer
      str r0,[r1]
      
      ; save base surface pos
      ldr r0,=old_targetCharSurfacePointer
      str r12,[r0]
      
      ; set r12 to new dstbuffer
      ldr r12,=charUnpackBuffer
      
      ; clear buffer
      mov r0,0
      mov r1,0
      @@charBufClearLoop:
        str r0,[r12, r1]
        add r1,r1,4
        cmp r1,(charUnpackBuffer_end-charUnpackBuffer)
        bne @@charBufClearLoop
    pop {r0,r1}
    
    b end_unpackChar_targetBuffer
  
  ;========================================
  ; hack 2: to move to next row in our
  ; buffer, add 64 instead of 192
  ;========================================
  unpackChar_toNextRow_ext:
;    addeq r12, r12, #192
    addeq r12, r12, #64
    b end_unpackChar_toNextRow
    
  .pool
  
  ; offsets to data in charstruct
  charstruct_size equ 28
  charstruct_absXPos equ 0
  charstruct_absYPos equ 2
  charstruct_color equ 7
  charstruct_charW equ 8
  charstruct_charH equ 10
  charstruct_surfaceXOffset equ 24
  
  charHeight equ 12
  
  ; r4 = printstruct
  ; r5 = charstruct
  ;
  ; returns r0 = pointer to start of next OAM subsurface
  .macro charComposition_deriveNextOamSubsurfacePointer
      ; look up base absolute x-offset from charstruct
      ldr     r3, [r5, charstruct_surfaceXOffset]
      ; r2 = pointer to OAM surface array
      ldr     r2, [r4, 128]
      ; something, ask the compiler
      asr     r1, r3, #4
      add     r1, r3, r1, lsr #27
      asr     r1, r1, #5
      
      ; NEW: increment by 1 to get next OAM index.
      ; this should never run on the last one(?), so it should be valid.
      add r1,1
      ; get count of OAMs
      ldr r0,[r4,124]
      ; if index == count, failure
      cmp r0,r1
      moveq r0,0
      beq @@done
      
      ; r0 = fetch from printstruct+128 using computed offset.
      ; this gets the OAM subsurface index?
      ldrsb   r0, [r2, r1]
      ; r1 = same value * 512 to get OAM subsurface offset
      lsl r1,r0,9
      
      ; now look up the base pointer for the OAM surface
      ; r2 = surface index
      ldr       r2, [r4, 116]
      ; r3 = pointer to static array of OAM surface pointers
      ldr       r3,=0x20d51b8
      ; r0 = pointer to start of target surface
      ldr       r0, [r3, r2, lsl #2]
      ; add subsurface offset to derive subsurface pointer
      add       r0, r0, r1
      
      @@done:
  .endmacro
  
  .macro prepCharTransfer
    ;=====
    ; r4 = printstruct
    ; r5 = charstruct
    ; r6 = dstptr
    ; r7 = current absolute pixel offset
    ; r8 = remaining pixels in source character
    ; r9 = srcptr
    ; r11 = total pixels transferred
    ;=====
    
    ; r0 = number of pixels to end of current target pattern
    ; (8 - (absoluteOffset & 0x7))
    mov r0,r7
    and r0,0x7
    mov r1,8
    sub r0,r1,r0
    
    ; r2 = number of pixels to end of current source pattern
    ; (8 - (totalPixelsTransferred & 0x7))
    mov r2,r11
    and r2,0x7
    sub r2,r1,r2
    ; if total remaining pixels < pixels to end of src pattern,
    ; transfer all remaining pixels
    cmp r8,r2
    movlt r2,r8
    
    ; if (remaining pixels in target character < pixels to end of current
    ; target pattern), transfer only that many pixels
    cmp r2,r0
    movlt r0,r2
    
    ; r10 = width of transfer
    mov r10,r0
      
    ; r0 = transfer width
    
    ; r1 = dstptr
    mov r1,r9
    ; r2 = srcptr
    mov r2,r6
  .endmacro
  
  .macro prepCharTransfer_fill
    ;=====
    ; r4 = printstruct
    ; r5 = charstruct
    ; r6 = dstptr
    ; r7 = current absolute pixel offset
    ; r8 = remaining pixels in source character
    ; r9 = fill value
    ;=====
    
    ; r0 = number of pixels to end of current target pattern
    ; (8 - (absoluteOffset & 0x7))
    mov r0,r7
    and r0,0x7
    mov r1,8
    sub r0,r1,r0
    
    ; if (remaining pixels in source character < pixels to end of current
    ; target pattern), transfer only that many pixels
    cmp r8,r0
    movlt r0,r8
    
    ; r10 = width of transfer
    mov r10,r0
      
    ; r0 = transfer width
    
    ; r1 = fill value
    mov r1,r9
    ; r2 = dst
    mov r2,r6
  .endmacro
  
  .macro updateCharTransferPosData,doneLabel
    ;=====
    ; r4 = printstruct
    ; r5 = charstruct
    ; r6 = dstptr
    ; r7 = current absolute pixel offset
    ; r8 = remaining pixels in source character
    ; r9 = srcptr
    ; r10 = width of current transfer
    ; r11 = total pixels transferred
    ;=====
    
    ; update fields based on width of transfer (r10)
    
    ; remaining pixels
    subs r8,r10
    ; done if no pixels remaining
    beq doneLabel
    
    ; currentPixelOffset
    add r7,r10
    
    ; total pixels transferred
    add r11,r10
    
    ; srcptr (+56 if moving to next pattern)
    add r9,r10
    ; if pixels transferred == 8, move to next pattern
    cmp r11,8
;    bne @@t1_noSrcPatternChange
;      add r9,56
;    @@t1_noSrcPatternChange:
    addeq r9,56
    
    ; dstptr (+56 if moving to next pattern)
    add r6,r10
    ; if updated currentPixelOffset divisible by 8, moving to next pattern
    mov r0,r7
    ands r0,0x7
    addeq r6,56
    
    ; if currentPixelOffset is nonzero and divisible by 32, add 256
    ; to dstptr so we skip past the lower row of the OAM and get a pointer
    ; to the start of the next one
    movs r0,r7
    beq @@t1_noOamBoundaryCrossing
    ands r0,0x1F
    bne @@t1_noOamBoundaryCrossing
;      add r6,256
      
      ;=====
      ; OAM indices are not strictly guaranteed to be contiguous, so
      ; we need to do this lookup "properly"
      ;=====
      
      charComposition_deriveNextOamSubsurfacePointer
      
      ; if returned pointer null, done
      cmp r0,0
      beq doneLabel
      
      ; r6 = new subsurface pointer
      mov r6,r0
      
      ;=====
      ; flag this so we know to send the extra update later on
      ;=====
      ldr r0,=secondCharOamTransferFlag
      mov r1,1
      str r1,[r0]
    @@t1_noOamBoundaryCrossing:
  .endmacro
  
  .macro updateCharTransferPosData_fill,doneLabel
    ;=====
    ; r4 = printstruct
    ; r5 = charstruct
    ; r6 = dstptr
    ; r7 = current absolute pixel offset
    ; r8 = remaining pixels in source character
    ; r9 = fill value
    ; r10 = width of current transfer
    ;=====
    
    ; update fields based on width of transfer (r10)
    
    ; remaining pixels
    subs r8,r10
    ; done if no pixels remaining
    beq doneLabel
    
    ; currentPixelOffset
    add r7,r10
    
    ; dstptr (+56 if moving to next pattern)
    add r6,r10
    ; if updated currentPixelOffset divisible by 8, moving to next pattern
    mov r0,r7
    ands r0,0x7
    addeq r6,56
    
    ; if currentPixelOffset is nonzero and divisible by 32, add 256
    ; to dstptr so we skip past the lower row of the OAM and get a pointer
    ; to the start of the next one
    movs r0,r7
    beq @@t1_noOamBoundaryCrossing
    ands r0,0x1F
    bne @@t1_noOamBoundaryCrossing
;      add r6,256
      
      ;=====
      ; OAM indices are not strictly guaranteed to be contiguous, so
      ; we need to do this lookup "properly"
      ;=====
      
      charComposition_deriveNextOamSubsurfacePointer
      
      ; if returned pointer null, done
      cmp r0,0
      beq doneLabel
      
      ; r6 = new subsurface pointer
      mov r6,r0
      
      ;=====
      ; flag this so we know to send the extra update later on
      ;=====
      ldr r0,=secondCharOamTransferFlag
      mov r1,1
      str r1,[r0]
    @@t1_noOamBoundaryCrossing:
  .endmacro
  
  ;========================================
  ; transfer the character to its proper
  ; area
  ; 
  ; incoming parameters:
  ; r6 = printstruct pointer
  ;========================================
  unpackChar_newComposition_ext:
    push {r0-r12}
    
      ; r4 = printstruct pointer
      mov r4,r6
      ; r5 = charstruct pointer
      ldr r5,=compositionCharStructPointer
      ldr r5,[r5]
    
      ;========================================
      ; god, this shit again.
      ;
      ; ok, we allow characters of up to 16px
      ; width. that means any individual
      ; character can span at most three
      ; 8x8 patterns horizontally, requiring
      ; three separate transfers.
      ;
      ; as an additional source of complexity,
      ; we are dealing not with a single
      ; contiguous array of patterns but with
      ; a series of adjacent 32x16 OAMs.
      ; thus, if we cross a 32px boundary
      ; between transfers, then the next
      ; pattern to the right is found at
      ; (patternstart + 256 + 64) rather than
      ; the usual (patternstart + 64).
      ;
      ; as a source of even more complexity,
      ; the game probably updates only the
      ; one OAM it expects to be modified by
      ; the print, meaning we'll have to
      ; add code to update it too in this case
      ; or else some material will not print
      ; correctly/at all.
      ;========================================
      
      ; r6 = retrieved "old" base surface pointer.
      ; this is a pointer to the target position in the surface, but truncated
      ; to the previous 16px boundary.
      ldr r6,=old_targetCharSurfacePointer
      ldr r6,[r6]
      
      ; r7 = absolute pixel x-offset within current virtual surface.
      ; unlike the pointer, this is accurate.
      ldr r7,[r5,charstruct_surfaceXOffset]
      
      ;=====
      ; compute the actual target base position by adding
      ; (a.) (absolute offset & 0xF) if that value is < 8, or
      ; (b.) ((absolute offset & 0x7) + 64) otherwise
      ; i.e. shift bit 3 left 3 bits and add it to (absolute offset & 0x7).
      ; this operation is guaranteed not to cross over to a new OAM.
      ;=====
      
      ; r0 = (bit 3 of absolute pixel X) << 3
      mov r0,r7,lsl 3
      and r0,0x40
      ; r1 = (absolute offset & 0x7)
      mov r1,r7
      and r1,0x7
      ; r0 = sum of values
      add r0,r0,r1
      ; r6 = old base pointer plus offset, yielding correct base pointer
      add r6,r0,r6
      
      ;========================================
      ; init remaining params
      ;========================================
      
      ; to recap:
      ; r4 = printstruct
      ; r5 = charstruct
      ; r6 = dstptr
      ; r7 = current absolute pixel offset
      ; r8 = remaining pixels in source character
      ; r9 = srcptr
      ; r10 = width of current transfer (eventually)
      ; r11 = total pixels transferred
      
      ; r8 = remaining pixels in source character
      ldrsh r8,[r5,charstruct_charW]
      ; if source character has width of <= 0 pixels, do nothing
      cmp r8,0
      ble @@done
      
      ; r9 = srcptr
      ldr r9,=charUnpackBuffer
      ; r11 = total pixels transferred
      mov r11,0
      
      ;========================================
      ; transfer 1 prep:
      ; from start of buffer to
      ; (a.) end of source data, or
      ; (b.) end of target pattern,
      ; whichever is smaller
      ;========================================
      
/*      ; r0 = number of pixels to end of current target pattern
      ; (8 - (absoluteOffset & 0x7))
      mov r0,r7
      and r0,0x7
      mov r1,8
      sub r0,r1,r0
      
      ; if (remaining pixels in target character < pixels to end of current
      ; target pattern), transfer only that many pixels
      cmp r8,r0
      bge @@t1_srcWillNotFit
        mov r0,r8
      @@t1_srcWillNotFit:
      
      ; r10 = width of transfer
      mov r10,r0 */
      
      prepCharTransfer
      
      ;========================================
      ; do transfer 1
      ;========================================
      
      bl transferCharColumns
      
      ;=====
      ; update position data
      ;=====
      
/*      ; update fields based on width of transfer (r10)
      
      ; remaining pixels
      subs r8,r10
      ; done if no pixels remaining
      beq @@done
      
      ; currentPixelOffset
      add r7,r10
      
      ; total pixels transferred
      add r11,r10
      
      ; srcptr (+56 if moving to next pattern)
      add r9,r10
      ; if pixels transferred == 8, move to next pattern
      cmp r11,8
      bne @@t1_noSrcPatternChange
        add r9,56
      @@t1_noSrcPatternChange:
      
      ; dstptr (+56 to move to next pattern)
      add r6,r10
      add r6,56
      
      ; if currentPixelOffset is divisible by 32, add 256
      ; so we skip past the lower row of the OAM and get a pointer
      ; to the start of the next one
      mov r0,r7
      ands r0,0x1F
      bne @@t1_noOamBoundaryCrossing
        add r7,256
      @@t1_noOamBoundaryCrossing: */
      
      updateCharTransferPosData @@done
      
      ;========================================
      ; transfer 2: from current bufferpos to
      ; (a.) end of source data, or
      ; (b.) end of target pattern,
      ; whichever is smaller
      ;========================================
      
      prepCharTransfer
      
      bl transferCharColumns
      
      updateCharTransferPosData @@done
      
      ;========================================
      ; transfer 3: from current bufferpos to
      ; end of source data
      ;========================================
      
      prepCharTransfer
      
      bl transferCharColumns
    
    @@done:
    
    ;=====
    ; check if a second OAM transfer is needed
    ;=====
    ldr r1,=secondCharOamTransferFlag
    ldr r0,[r1]
    cmp r0,0
    beq @@endCall
      ; clear flag
      mov r0,0
      str r0,[r1]
      
      @@oamUpd:
      
      ; we now need to check one of the parameters to the function that
      ; has been redirected to this one.
      ; this was originally stored at [sp]; with our new pushes,
      ; it's now at [sp+52].
      ;
      ; (actually we probably don't even need to do this)
;      ldr       r0, [sp, 0+52]
;      mov       r3, #0
;      sub       r1, r0, #1
;      ldr       r0, [sp, 4+52]
;      cmp       r0, r1
;      bge @@doPart2Transfer
      
      ; check something else
      
      ; r4 = printstruct
      ; r5 = charstruct
      
      @@doPart2Transfer:
    
      ;=====
      ; derive pointer to second target OAM subsurface
      ;=====
      
      ; look up absolute x-offset from charstruct
/*      ldr     r3, [r5, charstruct_surfaceXOffset]
      ; r2 = pointer to OAM surface array
      ldr     r2, [r4, 128]
      ; something, ask the compiler
      asr     r1, r3, #4
      add     r1, r3, r1, lsr #27
      asr     r1, r1, #5
      ; NEW: increment by 1 to get next OAM index.
      ; this should never run on the last one(?), so it should be valid.
      add r1,1
      
      ; r0 = fetch from printstruct+128 using computed offset.
      ; this gets the OAM subsurface index?
      ldrsb   r0, [r2, r1]
      ; r1 = same value * 512 to get OAM subsurface offset
      lsl r1,r0,9
      
      ; now look up the base pointer for the OAM surface
      ; r2 = surface index
      ldr       r2, [r4, 116]
      ; r3 = pointer to static array of OAM surface pointers
      ldr       r3,=0x20d51b8
      ; r0 = pointer to start of target surface
      ldr       r0, [r3, r2, lsl #2]
      ; add subsurface offset to derive subsurface pointer
      add       r0, r0, r1 */
      
      charComposition_deriveNextOamSubsurfacePointer
      
      ; if returned pointer null, done
      cmp r0,0
      beq @@endCall
    
      ; r6 = subsurface offset
      mov r6,r1
      
      ;=====
      ; call ???
      ;=====
      
      ; r0 = pointer to target subsurface
      ; r1 = hardcoded parameter
      ; r2 probably isn't a parameter, but it's the surface index here
      ; r3 also probably isn't a parameter, but is 1 here
      mov       r1, 512
;      mov       r3, 1
;      bl        0x2003958
      bl 0x2005670
      
      ;=====
      ; call ???
      ;=====
      
      ; fetch OAM surface index again
      ldr       r2, [r4, #116]
      cmp       r2, #0
      bne @@oamUpdateTargetNonzero
      @@oamUpdateTargetZero:
        
        ; r0 = surface array base
        ldr     r0, =0x20d51b8
        ; r1 = subsurface offset
        mov     r1, r6
        ; r0 = pointer to surface
        ldr     r0, [r0, r2, lsl #2]
        ; r2 = hardcoded parameter
        mov     r2, #512
        ; r0 = pointer to subsurface
        add     r0, r0, r6
        
        bl      0x2003958
        
        b @@oamUpdateTargetDone
      @@oamUpdateTargetNonzero:
        
        ; r0 = surface array base
        ldr     r0, =0x20d51b8
        ; r1 = subsurface offset
        mov     r1, r6
        ; r0 = pointer to surface
        ldr     r0, [r0, r2, lsl #2]
        ; r2 = hardcoded parameter
        mov     r2, 512
        ; r0 = pointer to subsurface
        add     r0, r0, r6
        
        bl     0x20038f8
      
      @@oamUpdateTargetDone:
      
      
    ;=====
    ; done
    ;=====
    
    @@endCall:
    
    pop {r0-r12}
    ; make up work
    ldr r0, [sp]
    b end_unpackChar_newComposition
    
    .pool
    
    ;========================================
    ; transfer r0 columns of character data
    ; from r1 to r2.
    ; the transfer must not straddle pattern
    ; boundaries in either the source or the
    ; destination.
    ;
    ; r0 = transfer width in pixels
    ; r1 = srcptr
    ; r2 = dstptr
    ;========================================
    transferCharColumns:
      push {r4-r7, lr}
      
      ; r3 = current row number
      mov r3,0
      ; r4 = transfer width in pixels
      mov r4,r0
      ; r5 = base srcptr
      mov r5,r1
      ; r6 = base dstptr
      mov r6,r2
      
      @@charTransferLoop:
        ; if row number is 8, add 192 to dst and 64 to src so we
        ; target the lower half of the character
        cmp r3,8
        bne @@notShiftingToLowerHalf
          add r5,64
          add r6,192
        @@notShiftingToLowerHalf:
        
        ; r0 = width
        mov r0,r4
        ; r1 = base srcptr
        mov r1,r5
        ; r2 = base dstptr
        mov r2,r6
        
        @@rowTransferLoop:
          ; copy pixel from src to dst
          ldrb r7,[r1]
          ; skip if zero
          cmp r7,0
          beq @@noTransfer
            strb r7,[r2]
          @@noTransfer:
          
          ; move to next column
          add r1,1
          add r2,1
          subs r0,1
          bne @@rowTransferLoop
        
        ; increment row number
        add r3,1
        ; done if limit reached
        cmp r3,charHeight
        beq @@done
        
        ; move base src/dstptr to next row
        add r5,8
        add r6,8
        b @@charTransferLoop
        
        
      @@done:
      pop {r4-r7, pc}
    
    ;========================================
    ; convert r0 columns of data at r2 using
    ; the fill value in r1.
    ; must not straddle pattern boundary.
    ;
    ; r0 = transfer width in pixels
    ; r1 = fill value
    ; r2 = dstptr
    ;========================================
    transferCharColumns_fill:
      push {r4-r7, lr}
      
      ; r3 = current row number
      mov r3,0
      ; r4 = transfer width in pixels
      mov r4,r0
      ; r6 = base dstptr
      mov r6,r2
      
      @@charTransferLoop:
        ; if row number is 8, add 192 to dst and 64 to src so we
        ; target the lower half of the character
        cmp r3,8
        bne @@notShiftingToLowerHalf
          add r6,192
        @@notShiftingToLowerHalf:
        
        ; r0 = width
        mov r0,r4
        ; r2 = base dstptr
        mov r2,r6
        
        @@rowTransferLoop:
          ; copy pixel from src
          ldrb r7,[r2]
          ; mask off high 4 bits
          ands r7,0x0F
          ; skip if zero
;          cmp r7,0
          beq @@noTransfer
            ; OR with fill value
            orr r7,r1
            strb r7,[r2]
          @@noTransfer:
          
          ; move to next column
          add r2,1
          subs r0,1
          bne @@rowTransferLoop
        
        ; increment row number
        add r3,1
        ; done if limit reached
        cmp r3,charHeight
        beq @@done
        
        ; move base src/dstptr to next row
        add r6,8
        b @@charTransferLoop
        
        
      @@done:
      pop {r4-r7, pc}
  
  ;========================================
  ; new character composition RAM
  ;========================================
  
  ; buffer for character unpacking
  charUnpackBuffer:
    .fill sizeOf256ColorPattern*4,0
  charUnpackBuffer_end:
  
  ; temp storage for "old" initial dstptr.
  ; this is a pointer to the OAM surface in memory
  ; which corresponds to the actual target pixel position, but
  ; "snapped" to the previous 16px boundary.
  compositionCharStructPointer:
    .dw 0
  old_targetCharSurfacePointer:
    .dw 0
  secondCharOamTransferFlag:
    .dw 0
  
  ;===========================================================================
  ; correctly restore text colors after being highlighted
  ;===========================================================================
  
  ;========================================
  ; incoming parameters:
  ;
  ; r5 = current charstruct offset
  ; r7 = printstruct
  ; lr = subsurface target pattern pointer
  ;      (truncated to 16px boundary)
  ;========================================
  restoreTextColor_newUpdate_ext:
    push {r0-r12, lr}
    
    ; r4 = printstruct
    mov r4,r7
    ; r5 = current charstruct pointer
    ; add offset to base pointer
    ldr r0, [r7, #72]
;    mov r1,charstruct_size
;    mul r5,r1
    add r5,r0
    ; r6 = base dstptr (with truncation)
    mov r6,lr
    ; r7 = absolute pixel x-offset within current virtual surface.
    ; unlike the pointer, this is accurate.
    ldr r7,[r5,charstruct_surfaceXOffset]
    
    ;=====
    ; compute the actual target base position by adding
    ; (a.) (absolute offset & 0xF) if that value is < 8, or
    ; (b.) ((absolute offset & 0x7) + 64) otherwise
    ; i.e. shift bit 3 left 3 bits and add it to (absolute offset & 0x7).
    ; this operation is guaranteed not to cross over to a new OAM.
    ;=====
    
    ; r0 = (bit 3 of absolute pixel X) << 3
    mov r0,r7,lsl 3
    and r0,0x40
    ; r1 = (absolute offset & 0x7)
    mov r1,r7
    and r1,0x7
    ; r0 = sum of values
    add r0,r1
    ; r6 = old base pointer plus offset, yielding correct base pointer
    add r6,r0
    
    ;=====
    ; set up remaining parmeters
    ;=====
    
    ; r8 = remaining pixels in source character
    ldrsh r8,[r5,charstruct_charW]
    ; if source character has width of <= 0 pixels, do nothing
    cmp r8,0
    ble @@done
    ; r9 = fill value
    ldrb r9,[r5,charstruct_color]
    
    ; r9 = srcptr
;    ldr r9,=charUnpackBuffer
    ; r11 = total pixels transferred
;    mov r11,0
    
    ;=====
    ; same logic applies as for normal transfers, except we no
    ; longer have a source, just a fill value (r9)
    ;=====
    
    ;========================================
    ; transfer 1
    ;========================================
    
    prepCharTransfer_fill
    bl transferCharColumns_fill
    updateCharTransferPosData_fill @@done
    
    ;========================================
    ; transfer 2
    ;========================================
    
    prepCharTransfer_fill
    bl transferCharColumns_fill
    updateCharTransferPosData_fill @@done
    
    ;========================================
    ; transfer 3
    ;========================================
    
    prepCharTransfer_fill
    bl transferCharColumns_fill
    
    @@done:
    
    ;=====
    ; check if a second OAM transfer is needed
    ;=====
    ldr r1,=secondCharOamTransferFlag
    ldr r0,[r1]
    cmp r0,0
    beq @@endCall
      ; clear flag
      mov r0,0
      str r0,[r1]
      
      ; check something else
      
      ; r4 = printstruct
      ; r5 = charstruct
      
      @@doPart2Transfer:
    
      ;=====
      ; derive pointer to second target OAM subsurface
      ;=====
      
      charComposition_deriveNextOamSubsurfacePointer
      
      ; if returned pointer null, done
      cmp r0,0
      beq @@endCall
    
      ; r6 = subsurface offset
      mov r6,r1
      
      ;=====
      ; call ???
      ;=====
      
      ; r0 = pointer to target subsurface
      ; r1 = hardcoded parameter
      ; r2 probably isn't a parameter, but it's the surface index here
      ; r3 also probably isn't a parameter, but is 1 here
      mov       r1, 512
;      bl        0x2003958
      bl        0x2005670
      
      ;=====
      ; call ???
      ;=====
      
      ; fetch OAM surface index again
      ldr       r2, [r4, #116]
      cmp       r2, #0
      bne @@oamUpdateTargetNonzero
      @@oamUpdateTargetZero:
        
        ; r0 = surface array base
        ldr     r0, =0x20d51b8
        ; r1 = subsurface offset
        mov     r1, r6
        ; r0 = pointer to surface
        ldr     r0, [r0, r2, lsl #2]
        ; r2 = hardcoded parameter
        mov     r2, #512
        ; r0 = pointer to subsurface
        add     r0, r0, r6
        
        bl      0x2003958
        
        b @@oamUpdateTargetDone
      @@oamUpdateTargetNonzero:
        
        ; r0 = surface array base
        ldr     r0, =0x20d51b8
        ; r1 = subsurface offset
        mov     r1, r6
        ; r0 = pointer to surface
        ldr     r0, [r0, r2, lsl #2]
        ; r2 = hardcoded parameter
        mov     r2, 512
        ; r0 = pointer to subsurface
        add     r0, r0, r6
        
        bl     0x20038f8
      
      @@oamUpdateTargetDone:
      
    ;=====
    ; done
    ;=====
    
    @@endCall:
    pop {r0-r12, lr}
    b 0x201b800
    
    .pool
  
  ;===========================================================================
  ; look up characters using ASCII + dictionary
  ;===========================================================================
  
  dictionaryBaseValue equ 0x8100
  
  numCopiedDictStackWords equ 14
  totalCopiedDictStackSize equ numCopiedDictStackWords*4
  
  sjisDigitsLow equ 0x824F
  sjisDigitsHigh equ 0x8258
  
  ;========================================
  ; look up characters from new font
  ;
  ; incoming parameters:
  ;   r0 = high byte of incoming codepoint
  ;   r3 = current stringptr
  ;   r4 = ? flag
  ;   r5 = output struct pointer
  ;   r6 = ?
  ;   r8 = ?
  ;   r11 = current target absolute x-pos
  ;
  ;   sp+8  = high 6 bytes of unpacked
  ;           color
  ;   sp+12 = ? bit 1 = flag?
  ;   sp+16 = old hardcoded character
  ;           height
  ;   sp+20 = old hardcoded character
  ;           width
  ;   sp+24 = ?
  ;   sp+28 = ?
  ;   sp+32 = ?
  ;   sp+36 = size of character in bytes
  ;           (initialized to 1 for each
  ;           pass)
  ;   sp+40 = ?
  ;   sp+52 = current stringptr
  ;========================================
  
  newFontLookup:
    
    ;=====
    ; there are two possibilities for what we read:
    ; 1. an ASCII literal
    ; 2. a dictionary lookup
    ;
    ; if (1.), we read the character and jump back to the normal
    ; character handler logic.
    ; if (2.), we have to reimplement the character handler
    ; to deal with recursive dictionary calls.
    ;=====
    
    ;=====
    ; check for literal
    ;=====
    
    cmp r0,(dictionaryBaseValue>>8)
    bge @@dictionaryCheck
    
    ;=====
    ; handle literal
    ;=====
    
    @@literal:
    
    ; look up and set character width
;    ldr r1,=fontWidthTable
;    ldrb r2,[r1,r0]
;    str r2,[sp, 20]
    push {r0}
      bl lookUpCharacterWidth
      mov r2,r0
    pop {r0}
    str r2,[sp, 20]
    
    ; r1 = bitmap pointer
    bl lookUpCharacterBitmap
    mov r1,r0
    
    ; ?
;    push {r0}
;      ldr       r0, [sp, #28]
;      cmp       r0, #1
;      moveq     r0, #1
;      streq     r0, [sp, #32]
;    pop {r0}
    
    ; jump back to the regular handler, skipping the normal
    ; encoding table lookup
    ; (since with the new encoding, encoding == index)
;    b 0x201a898
    ; also skip bitmap table lookup
    b 0x201a8a4
    
    ;========================================
    ; do dictionary lookup
    ;========================================
    
    @@dictionaryCheck:
    
    ; fun times
    
    ;=====
    ; first, we have to deal with the stack variables.
    ; we're going to be doing recursive calls, so using
    ; the stack as the original does is a no-go.
    ; instead, we copy the relevant variables to static
    ; memory and copy them back when done.
    ; this should be fine unless there's some wacky
    ; concurrency going on I don't know about.
    ;=====
    mov r0,0
    ldr r1,=dictStackCopy
    @@copyDictStack1:
      ldr r2,[sp,r0]
      str r2,[r1,r0]
      
      add r0,4
      cmp r0,totalCopiedDictStackSize
      bne @@copyDictStack1
    
    ;=====
    ; check if a SJIS digit
    ;=====
    
    @@sjisCheck:
      
    ; check if a SJIS digit
    ldrb r0,[r3]
    ldrb r1,[r3,1]
    ; r1 = raw 16-bit sequence
    orr r1,r1,r0,lsl 8
    
    ldr r2,=sjisDigitsLow
    cmp r1,r2
    blt @@dictionaryLookup
    ldr r2,=sjisDigitsHigh
    cmp r1,r2
    bgt @@dictionaryLookup
    
      @@sjis:
      ldr r2,=(sjisDigitsLow-0x30)
      ; r0 = digit literal index
      sub r0,r1,r2
      
      ; save stringptr
      push {r7}
        ldr r7,=dictStackCopy
        push {r3}
          bl printDictionaryLiteral
        pop {r3}
        
        ; move stringptr to next character
        add r3,2
        ; update stringptr copy to new target
        str r3,[r7,52]
      pop {r7}
      
      b @@dictionaryLookupDone
    
    ;=====
    ; do (possibly recursive) dictionary lookup
    ;=====
    
    @@dictionaryLookup:
    
    ; r7 is not updated in our logic, so we can use it to store
    ; a pointer to the copied stack.
    ; r12 and lr are also available.
    push {r7}
      ldr r7,=dictStackCopy
      ; r0 = current stringptr
      mov r0,r3
      bl doDictionaryLookup
      
      ; update stringptr copy to new target
      str r0,[r7,52]
    pop {r7}
    
    ;=====
    ; copy updated static variables back to stack
    ;=====
    
    @@dictionaryLookupDone:
    
    mov r0,0
    ldr r1,=dictStackCopy
    @@copyDictStack2:
      ldr r2,[r1,r0]
      str r2,[sp,r0]
      
      add r0,4
      cmp r0,totalCopiedDictStackSize
      bne @@copyDictStack2
    
    ; branch to terminator check
    b 0x201A968
  
;  dictSp8: .dw 0
;  dictSp12: .dw 0
;  dictSp16: .dw 0
;  dictSp20: .dw 0
;  dictSp28: .dw 0
;  dictSp32: .dw 0
;  dictSp36: .dw 0
;  dictSp40: .dw 0
;  dictSp52: .dw 0

  ; to hell with this, just copy everything
  .align 4
  dictStackCopy:
    .fill totalCopiedDictStackSize,0
  
  ;========================================
  ; look up and print a dictionary string
  ;
  ; r0 = stringptr pointing to a
  ;      dictionary identifier
  ;
  ; returns r0 = updated stringptr
  ;========================================
  
  doDictionaryLookup:
    push {lr}
    
    ldrb r1,[r0]
    ldrb r2,[r0,1]
    ; r1 = raw 16-bit dictionary sequence
    orr r1,r2,r1,lsl 8
    
    ; subtract dictionary base value to get dictionary index
    sub r1,dictionaryBaseValue
    
    ; look up string offset from dictionary index
    ldr r2,=scriptDictionary
    add r1,r2,r1,lsl 2
    ldr r1,[r1]
    ; add dictionary base to string offset to get string pointer
;    add r1,r2
    
    push {r0}
      ; r0 = dictionary string pointer
;      ldr r0,[r1]
      add r0,r1,r2
      bl printDictionaryString
    pop {r0}
    
    ; advance stringptr past dictionary sequence
    add r0,2
    
    pop {pc}
  
  ;========================================
  ; print a dictionary string
  ;
  ; r0 = stringptr pointing to start of a
  ;      dictionary string
  ;
  ; returns r0 = updated stringptr
  ;========================================
  
  printDictionaryString:
    push {lr}
    
    @@printLoop:
      ;=====
      ; done if next character is terminator
      ;=====
      
      ldrb r1,[r0]
      cmp r1,0
      beq @@done
    
      ;=====
      ; is next character a literal?
      ;=====
      
      @@dictionaryCheck:
      cmp r1,(dictionaryBaseValue>>8)
      bge @@dictionary
    
      ;========================================
      ; literal
      ;========================================
      
      @@literal:
      
      ; save stringptr
      push {r0}
      
        ; r0 = character index
        mov r0,r1
        bl printDictionaryLiteral
      
      ; restore stringptr
      pop {r0}
      
      ; move stringptr to next character
      add r0,1
      b @@printLoop
      
      ;========================================
      ; recursive dictionary lookup
      ;========================================
      
      @@dictionary:
      bl doDictionaryLookup
      b @@printLoop
    
    @@done:
    pop {pc}
  
  ;========================================
  ; look up a character's width
  ;
  ; r0 = character index
  ;
  ; returns r0 = pixel width
  ;========================================
  
;  lookUpCharacterWidth:
;    ldr r1,=fontWidthTable
;    ldrb r0,[r1,r0]
;    bx lr
  
  lookUpCharacterWidth:
    ldr r1,=fontWidthTablePointers
    ldr r2,=activeFontIndex
    ldr r2,[r2]
    ldr r1,[r1,r2,lsl 2]
    ldrb r0,[r1,r0]
    bx lr
  
  lookUpCharacterBitmap:
    ldr r1,=fontBitmapTablePointers
    ldr r2,=activeFontIndex
    ldr r2,[r2]
    ; r1 = base bitmap table pointer
    ldr r1,[r1,r2,lsl 2]
    
    ; multiply index by 48 to get table offset
    mov     r2, #48 ; 0x30
    mla     r0, r0, r2, r1
    
    bx lr
   
  .pool
  
  .align 4
  
  activeFontIndex:
  ; variable determining which font is currently active
    .dw 0
  
  ; table of font width pointers
  fontWidthTablePointers:
;    .dw fontWidthTable, fontWidthTable_wide
    .dw fontWidthTable_wide, fontWidthTable
  
  ; table of font bitmap pointers
  fontBitmapTablePointers:
;    .dw fontBitmapTable, fontBitmapTable_wide
    .dw fontBitmapTable_wide, fontBitmapTable

  
  ;========================================
  ; print dictionary literal
  ;
  ; r0 = character index
  ; r7 = virtual "stack" pointer
  ; r4-r6, r8-r11 = usual parameters
  ;========================================
  
  printDictionaryLiteral:
    push {lr}
    
    ;=====
    ; recreate full print logic from original function,
    ; except use r7 (our stack copy) instead of sp
    ;=====
    
    ; look up and set character width
;    ldr r1,=fontWidthTable
;    ldrb r2,[r1,r0]
;    str r2,[r7, 20]
    push {r0}
      bl lookUpCharacterWidth
      str r0,[r7, 20]
    pop {r0}
    
    ; r2 = bitmap table pointer
;    ldr     r2,=0x2075a84
    ; r1 = target character source bitmap pointer
;    mov     r1, #48 ; 0x30
;    mla     r1, r0, r1, r2
    bl lookUpCharacterBitmap
    mov r1,r0

    ; save bitmap pointer to [r5, #20]
    str     r1, [r5, #20]
    ldr     r1, [r7, #12]
    ; save x-pos
    strh    r11, [r5]
    add     r0, r6, r8, lsl #5
    ; if r4 flag was set, ???
    cmp     r4, #1
    str     r0, [r5, #24]
    ldrne   r0, [r7, #32]
    and     r1, r1, #2
    cmpne   r0, #1
    ldreq   r0, [r7, #20]
    asreq   r0, r0, #1
    ldrne   r0, [r7, #20]
    cmp     r1, #2
    streqh  r9, [r5, #2]
    beq     @@colorFlagNotSet
      ; if bit 1 of [r7, #12] not set?
      ; override y-pos
      ldr     r1, [r7, #16]
      sub     r1, r1, #16
      sub     r1, r9, r1
      strh    r1, [r5, #2]
    @@colorFlagNotSet:
    ; high 6 bits of unpacked color
    ldr     r1, [r7, #8]
    add     r6, r6, r0
    strb    r1, [r5, #7]
    ldr     r1, [r7, #28]
    strb    r1, [r5, #6]
    ; character width
    ldr     r1, [r7, #20]
    strh    r1, [r5, #8]
    ; character height?
    ldr     r1, [r7, #16]
    strh    r1, [r5, #10]
    ; ?
    ldr     r1, [r7, #12]
    strh    r1, [r5, #12]
    ldr     r1, [r7, #40]   ; 0x28
    cmp     r1, #0
    strh    r1, [r5, #14]
    ldrne   r2, =0x20d51e8  ; 0x201ac70
    moveq   r1, #0
    addne   r1, r2, r1, lsl #1
    ldrnesh r1, [r1, #-2]
    str     r1, [r5, #16]
    ; add character width to x-pos (r11)
    add     r1, r11, r0
    ; increment output size
    ldrsh   r0, [r10, #96]  ; 0x60
    lsl     r1, r1, #16
    asr     r11, r1, #16
    add     r0, r0, #1
    strh    r0, [r10, #96]  ; 0x60
    ; r7+36 = bytesize of character
;        ldr     r0, [r7, #36]   ; 0x24
    ; advance putpos
    add     r5, r5, #28
    
;    bx lr
  pop {pc}
  
  ;========================================
  ; string dictionary
  ;========================================
  
  .pool
  
  .align 4
  scriptDictionary:
    .incbin "out/script/dictionary.bin"
  .align 4
  
  ;===========================================================================
  ; returns pixel width of a string.
  ; source string should not contain
  ; linebreaks.
  ;
  ; r0 = string pointer
  ;
  ; returns r0 = pixel width of string
  ;===========================================================================
  
  getStringWidth:
    push {r1-r3, lr}
    
    ; r1 = running width count
    mov r1,0
;    mov r3,r0
    
    @@countLoop:
      
      ; r2 = next byte in string
      ldrb r2,[r0]
    
      ;=====
      ; check if terminator
      ;=====
      
      cmp r2,0
      beq @@done
    
      ;=====
      ; check for literal
      ;=====
      
      cmp r2,(dictionaryBaseValue>>8)
      bge @@dictionaryCheck
      
      ;=====
      ; handle literal
      ;=====
      
      @@literal:
        
        ; if target character == '#', assume this is a color
        ; command and skip the 2-byte color code
        cmp r2,0x23
        addeq r0,3
        beq @@countLoop
        
        ; advance srcptr
        add r0,1
        
        @@finishLiteral:
      
        ; look up character width
;        ldr r3,=fontWidthTable
;        ldrb r2,[r3,r2]
        push {r0-r1}
          mov r0,r2
          bl lookUpCharacterWidth
          mov r2,r0
        pop {r0-r1}
        
        ; add width to count
        add r1,r2
        b @@countLoop
      
      ;========================================
      ; do dictionary lookup
      ;========================================
      
      @@dictionaryCheck:
      
        ;=====
        ; check if a SJIS digit
        ;=====
        
        @@sjisCheck:
          
        ; check if a SJIS digit
        ldrb r3,[r0,1]
        ; r2 = raw 16-bit sequence
        orr r2,r3,r2,lsl 8
        
        ldr r3,=sjisDigitsLow
        cmp r2,r3
        blt @@dictionaryLookup
        ldr r3,=sjisDigitsHigh
        cmp r2,r3
        bgt @@dictionaryLookup
        
          @@sjis:
          ldr r3,=(sjisDigitsLow-0x30)
          ; r2 = digit literal index
          sub r2,r2,r3
          
          ; move stringptr to next character
          add r0,2
          
          b @@finishLiteral
        
        ;=====
        ; do (possibly recursive) dictionary lookup
        ;=====
        
        @@dictionaryLookup:
        
        push {r0}
          push {r1}
            ; r2 is already the raw 16-bit sequence from the SJIS check
            
            ; subtract dictionary base value to get dictionary index
            sub r2,dictionaryBaseValue
            
            ; look up string offset from dictionary index
            ldr r3,=scriptDictionary
            add r2,r3,r2,lsl 2
            ldr r2,[r2]
            ; add dictionary base to get string pointer
            add r0,r2,r3
            
            ; recur
            bl getStringWidth
            
          pop {r1}
          
          ; add result width to current
          add r1,r0
        pop {r0}
        ; move stringptr to next character
        add r0,2
        
        b @@countLoop
    
    ; done
    @@done:
    ; return width
    mov r0,r1
    pop {r1-r3, pc}
    
    .pool
    
/*    ;========================================
    ; correctly set up dialogue copy
    ; parameters.
    ; * r5 needs to become the actual
    ;   string length in bytes
    ; * r1 needs to become the total
    ;   number of tiles needed by the
    ;   string.
    ;   add 7 to raw width, clear low
    ;   3 bits, then divide by 8.
    ;
    ; r0 = string pointer
    ;========================================
    
    dialogueStringCopyWidthLookup:
      ; save string pointer
      mov r5,r0
        ; get actual byte length
        bl strlen
      ; r1 = string pointer
      mov r1,r5
      
      ; r5 = actual byte length
      mov r5,r0
      
      ; look up true length
      ; r0 = string pointer
      mov r0,r1
      bl getStringWidth
      
      ; tile count calculation:
      ; add 7
      add r0,7
      ; clear low 3 bits (and divide by 8)
      lsr r0,3
      
      ; set up malloc
      ldr r0,=0x20d6f70
      ldr r0,[r0]
;      mov r1,r5
      mov r2,4
      b 0x201a05c
      
    .pool */
  
  ;===========================================================================
  ; check for new change font text code.
  ; format: "<cX>", X = font index
  ;
  ; r3 = pointer to start of a string
  ;      sequence beginning with "<"
  ;===========================================================================
    
    changeFontOpcodeCheck_ext:
      ; check if second character is 'c'
      ldrb r0,[r3,1]
      cmp     r0, 0x43
      cmpne   r0, 0x63
      bne     @@notMatched
      
      ; check if fourth character is '>'
      ldrb r0,[r3,3]
      cmp     r0, 0x3E
      bne     @@notMatched
      
      ; check if third character is a digit
      ldrb r0,[r3,2]
      cmp     r0, 0x30
      blt     @@notMatched
      cmp     r0, 0x39
      bgt     @@notMatched
      
      ; matched!
      
      @@matched:
        ; subtract 0x30 to get index
        sub r0,0x30
        ; save to font index
        ldr r1,=activeFontIndex
        str r0,[r1]
        
        ; advance srcptr
;        add r3,4
        ldr     r0, [sp, #52]
        add     r0, r0, #4
        str     r0, [sp, #52]
        
        ; branch to null check loop
        b 0x201a968
      
      @@notMatched:
        ; make up work
        ldrb    r0, [r3, #1]
        b 0x201a5e0
      
      .pool
  
  ;===========================================================================
  ; double text speed for all new strings
  ;===========================================================================
  
  doubleTextSpeed_ext:
    .if INSTANT_TEXT
    
      mov r0,0
      strh r0,[sp, 32]
      
    .else
      
      ; if B fast-forward is enabled, print text instantly if B is pressed
      .if B_FAST_FORWARD
        ;=====
        ; check if B pressed
        ;=====
        
        ; get button pressed states
        ldr r0,=buttonStates
        ldrh r0,[r0,buttonStates_pressedOffset]
        ; bit 2 = B
        tst r0,skipButtonBitNum
        
        movne r0,0
        strneh r0,[sp, 32]
        bne @@done
      .else
      
      ;=====
      ; double speed if possible
      ;=====
    
      ldrsh       r0, [sp, #32]
      ; 0 = instant printing, so don't divide by 2 if 0 or 1
      cmp r0,1
      ble @@done
      
        ; divide by 2
        lsr r0,1
        ; save to stack
        strh r0,[sp, 32]
      .endif
    .endif
    
    @@done:
    b end_doubleTextSpeed
    
    .pool
  
  .if B_FAST_FORWARD
    ;===========================================================================
    ; skip waiting between dialogue boxes if fast-forward on
    ;===========================================================================
    
    ;========================================
    ; check for wait skip as soon as message
    ; finishes printing
    ;========================================
    
    fastForward_waitSkipCheck_ext:
      ; make up work
      cmp r11, #0
      beq 0x2032c84
      
      ; a wait has been triggered
      
      ;=====
      ; check if B pressed
      ;=====
      
      ; get button pressed states
      ldr r0,=buttonStates
      ldrh r0,[r0,buttonStates_pressedOffset]
      ; bit 2 = B
      tst r0,skipButtonBitNum
      
      ; skip wait if B pressed
      addne   sp, sp, #284    ; 0x11c
      popne   {r4, r5, r6, r7, r8, r9, r10, r11, pc}
      
      ; otherwise, do regular wait logic
      b 0x2032c8c
      
      .pool
    
    ;========================================
    ; check for wait skip during regular
    ; wait loop
    ;========================================
    
    fastForward_bDuringWaitCheck_ext:
      ; make up work
      ; (branch if A pressed)
      bne 0x2032db0
      
      ; check if B pressed
      ldrh r0,[r5,buttonStates_pressedOffset]
      ; bit 2 = B
      tst r0,skipButtonBitNum
      bne 0x2032db0
      b 0x2032da0
      
      .pool
    
    ;========================================
    ; check for wait skip while message is
    ; printing
    ;========================================
      
    fastForward_bDuringMessageCheck_ext:
      ; make up work
      ; (branch if A pressed)
      bne 0x2032b78
      
      ; check if B pressed
      ldrh r0,[r6,buttonStates_pressedOffset]
      ; bit 2 = B
      tst r0,skipButtonBitNum
      bne 0x2032b78
      
      ; neither of the buttons pressed
      b 0x2032ba4
      
      .pool
   .endif
  
  ;===========================================================================
  ; center credits
  ;===========================================================================
   creditsXOffset_ext:
    
    push {r1-r3}
    
      ; fetch pointer to target string
      ldr       r0, [r8]
      ; check if null
      cmp r0,0
      beq @@done
      
      ; get width
      bl getStringWidth
      
      ; subtract string width/2 from screenwidth/2 (128) to get target X
      lsr r0,1
      rsb r0,128
    
    @@done:
    pop {r1-r3}
    
    b creditsXOffset_end
  
  ;===========================================================================
  ; new credits strings
  ;===========================================================================
  
  .loadtable "table/grayman_en.tbl"
  creditsNew01: .string "#glEnglish Conversion:#wh"
  creditsNew02: .string "#cyTranslation#wh"
  creditsNew03: .string "Phantom"
  creditsNew04: .string "#cyHacking#wh"
  creditsNew05: .string "Supper"
  
  ;===========================================================================
  ; new credits pointer list
  ;
  ; nulls are blank lines
  ; terminated by pointer to a string beginning with "@", e.g. 0x20CF44C
  ;===========================================================================
  
  .align 4
  newCreditsPointers:
    ; TEST: first line does not display in original game.
    ;       does this fix it?
    .dw 0x0
    
    .dw 0x20CFFCC
    .dw 0x0
    .dw 0x20CF790
    .dw 0x0
    .dw 0x20D0D1C
    .dw 0x0
    .dw 0x0
    .dw 0x0
    .dw 0x0
    .dw 0x0
    .dw 0x0
    .dw 0x0
    .dw 0x0
    .dw 0x20D000C
    .dw 0x0
    .dw 0x20CFC70
    .dw 0x20D09F8
    .dw 0x0
    .dw 0x20CFF1C
    .dw 0x20D004C
    .dw 0x0
    .dw 0x20CF61C
    .dw 0x20D07C0
    .dw 0x0
    .dw 0x20CFBE0
    .dw 0x20D0694
    .dw 0x0
    .dw 0x20CF9AC
    .dw 0x20CF898
    .dw 0x0
    .dw 0x20CFA60
    .dw 0x20D0C3C
    .dw 0x0
    .dw 0x20CFA9C
    .dw 0x20CF8E0
    .dw 0x0
    .dw 0x20D016C
    .dw 0x20D017C
    .dw 0x0
    .dw 0x20CFAC0
    .dw 0x20D052C
    .dw 0x0
    .dw 0x20CF658
    .dw 0x20D0A8C
    .dw 0x0
    .dw 0x20CFE50
    .dw 0x20D0824
    .dw 0x0
    .dw 0x20CFB2C
    .dw 0x20D020C
    .dw 0x0
    .dw 0x20D0838
    .dw 0x20CF934
    .dw 0x0
    .dw 0x20CFB80
    .dw 0x0
    .dw 0x20D06D0
    .dw 0x0
    .dw 0x20D0B88
    .dw 0x20D02CC
    .dw 0x0
    .dw 0x20D0A10
    .dw 0x20CFC40
    .dw 0x0
    .dw 0x20D0888
    .dw 0x20D033C
    .dw 0x20D034C
    .dw 0x20D035C
    .dw 0x0
    .dw 0x20D089C
    .dw 0x20CF748
    .dw 0x20D037C
    .dw 0x0
    .dw 0x20D09C8
    .dw 0x20D03BC
    .dw 0x20D03CC
    .dw 0x20D03DC
    .dw 0x20D03EC
    .dw 0x20D03FC
    .dw 0x0
    .dw 0x20CF450
    .dw 0x20CF45C
    .dw 0x0
    .dw 0x20D05AC
    .dw 0x20D09E0
    .dw 0x20CFEE0
    .dw 0x0
    .dw 0x20D05BC
    .dw 0x20D032C
    .dw 0x20D048C
    .dw 0x0
    .dw 0x20D04AC
    ; kabushiki kaisha
;    .dw 0x20CF91C
    .dw 0x20D0CFC
    .dw 0x20D061C
    .dw 0x0
    .dw 0x20D0658
    .dw 0x20D0A70
    .dw 0x0
    .dw 0x20D0D3C
    .dw 0x20D006C
    .dw 0x0
    .dw 0x20D005C
    .dw 0x20D00CC
    .dw 0x20CFC88
    .dw 0x20D051C
    .dw 0x0
    .dw 0x20D06A8
    .dw 0x20CFACC
    .dw 0x20CFAF0
    .dw 0x0
    .dw 0x20D01FC
    .dw 0x20CF544
    .dw 0x20D023C
    .dw 0x0
    .dw 0x20D056C
    .dw 0x20D0AC4
    .dw 0x0
    .dw 0x20D0AE0
    .dw 0x20CFCB8
    .dw 0x20CFD00
    .dw 0x0
    .dw 0x20D0A28
    .dw 0x20CFD90
    ; kabushiki kaisha
;    .dw 0x20CF718
    .dw 0x20D0BA4
    .dw 0x0
    .dw 0x20D059C
    .dw 0x20CF94C
    .dw 0x0
    .dw 0x20D0EAC
    .dw 0x0
    .dw 0x20D0E1C
    .dw 0x20CFF8C
    .dw 0x20CFAD8
    .dw 0x0
    .dw 0x20CFF5C
    .dw 0x0
    .dw 0x20D049C
    .dw 0x20D007C
    .dw 0x20D012C
    .dw 0x20D01BC
    .dw 0x0
    .dw 0x20D01EC
    .dw 0x20D024C
    .dw 0x20D025C
    .dw 0x0
    .dw 0x20D0980
    .dw 0x0
    .dw 0x20D036C
    .dw 0x20CFDA8
    .dw 0x0
    .dw 0x20CFEA4
    .dw 0x0
    .dw 0x20D0A40
    .dw 0x0
    .dw 0x20D05E0
    .dw 0x0
    ; kabushiki kaisha
;    .dw 0x20CF610
    .dw 0x20D0B18
    .dw 0x0
    ; kabushiki kaisha
;    .dw 0x20CF7FC
    .dw 0x20D0DBC
    .dw 0x0
    .dw 0x20D09B0
    .dw 0x20CFD0C
    .dw 0x20CFE80
    .dw 0x0
    .dw 0x20D0F18
    .dw 0x20CFAB4
    .dw 0x0
    .dw 0x20CFC7C
    .dw 0x0
    ; kabushiki kaisha
;    .dw 0x20CF970
    .dw 0x20D0E64
    .dw 0x0
    
    ; == NEW CONTENT ==
    .dw 0x0
    .dw 0x0
    .dw 0x0
    .dw 0x0
    .dw 0x0
    .dw 0x0
    .dw 0x0
    .dw creditsNew01
    .dw 0
    .dw creditsNew02
    .dw creditsNew03
    .dw 0
    .dw creditsNew04
    .dw creditsNew05
    .dw 0
    .dw 0
    .dw 0
    
    ; == SCROLL OUT FINAL TEXT ==
    .dw 0x0
    .dw 0x0
    .dw 0x0
    .dw 0x0
    .dw 0x0
    .dw 0x0
    .dw 0x0
    .dw 0x0
    .dw 0x0
    .dw 0x0
    .dw 0x0
    
    ; == END OF LIST ==
    .dw 0x20CF44C

  
.close

/*.open "out/romfiles/arm9.bin", 0x0
  
  .orga 0xD0BE6
  .db 0x81,0xA5
  
  .orga 0xD0C06
  .db 0x81,0xA5
  
.close */


.open "out/romfiles/data/script/stage01.bin", 0x0
  ;===========================================================================
  ; stage 1: fix mistaken use of kanda's nametag instead of allen's
  ;===========================================================================
  .org 0x5E40
  .db 0x00
.close

