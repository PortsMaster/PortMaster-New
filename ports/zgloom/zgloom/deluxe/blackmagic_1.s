
	;offset 0: initialization routines
	bra	initc2p

	;offset 4: one pixel wide versions...AGA
	bra	doc2p_1X8

	;offset 8: one pixel wide versions...EHB
	bra	doc2p_1X6

	;offset 12: two pixel wide versions...AGA
	bra	doc2p_2X8

	;offset 16: two pixel wide versions...EHB
	bra	doc2p_2X6

	;offset 20: address of description string
	dc.l	string

string	dc.b	'A Chunky to planar routine by Mark Sibly. '
	dc.b	'Supports 6/8 bitplane, single/double width pixels.',0
	even

initc2p	;create 2 tables for Gloom
	;
	;a0=columns buffer to fill in (array of longs) for 1 wide pixs.
	;a1=columns buffer for 2 wide pixs
	;d0=how many columns (multiple of 32)
	;a2=palette remapping array (do 256)
	;
	move	#255,d1	;#colours
.loop	move.b	d1,0(a2,d1)
	dbf	d1,.loop
	;
	move.l	d0,-(a7)
	;
make1wideoffs	;column offsets for 1 wide pixels
	;
	;0,2,4,6,8,10,12,14
	;1,3,5,7,9,11,13,15
	;16,18,20...
	;
	lsr	#4,d0
	subq	#1,d0
	moveq	#0,d1
	;
.loop2	moveq	#7,d2
	;
.loop3	move.l	d1,(a0)+
	addq.l	#2,d1
	dbf	d2,.loop3
	;
	sub.l	#15,d1
	moveq	#7,d2
	;
.loop4	move.l	d1,(a0)+
	addq.l	#2,d1
	dbf	d2,.loop4
	;
	subq.l	#1,d1
	;
	dbf	d0,.loop2
	;
	move.l	(a7)+,d0
	;
make2wideoffs	;column offsets for 2 wide pixels
	;
	;0,2,4,6,1,3,5,7,8,10,12,14...
	;
	lsr	#3,d0
	subq	#1,d0
	moveq	#0,d1
	;
.loop2	moveq	#3,d2
	;
.loop3	move.l	d1,(a1)+
	addq.l	#2,d1
	dbf	d2,.loop3
	;
	sub.l	#7,d1
	moveq	#3,d2
	;
.loop4	move.l	d1,(a1)+
	addq.l	#2,d1
	dbf	d2,.loop4
	;
	subq.l	#1,d1
	;
	dbf	d0,.loop2
	;
	rts

rotbits	macro	;macro for rotating/merging bits.
	;
	;rotbits	reg1,reg2,shift
	;
	move.l	\1,d4
	and.l	d6,\1
	eor.l	\1,d4
	lsl.l	#\3,\1
	;
	move.l	\2,d5
	and.l	d6,d5
	eor.l	d5,\2
	lsr.l	#\3,\2
	or.l	d4,\2
	or.l	d5,\1
	;
	endm

doc2p_1X8	;
	;inputs:
	;a0.l=src chunky buffer
	;a1.l=dest chipmem bitmap
	;d0.w=width (in pixels - multiple of 32) to convert
	;d1.w=height (in pixels - even)
	;d2.l=modulo from one bitplane to next (copmod-ish)
	;d3.l=modulo from start of one line to start of next (linemod)
	;
	;internal:
	;d6=current and reg.
	;d7=loop counter
	;a2=4 bit and
	;a3=2 bit and
	;a4=1 bit and
	;a5=bitplane modulo, 1 bp to next
	;a6=subtract at end of one loop
	;
	move.l	#$0f0f0f0f,a2
	move.l	#$33333333,a3
	move.l	#$5555aaaa,a4
	move.l	d2,a5	;one bp to next.
	;
	lsl.l	#3,d2	;8 bitplanes
	move.l	d2,a6
	sub.l	a5,a6	;7 * bpmod
	subq.l	#2,a6	;to next word
	;
	lsr	#4,d0	;16 pixels at a time
	move	d0,d2
	ext.l	d2
	add.l	d2,d2
	add.l	a6,d2
	sub.l	d2,d3
	move.l	d3,-(a7)
	;
	subq	#1,d1
	move	d1,d7	;hite dbf
	swap	d7
	subq	#1,d0
	move	d0,d7
	subq	#2,a7	;long align stack
	move	d7,-(a7)
	;
	movem.l	(a0)+,d0-d3	;next 16 pixels.
	move.l	a2,d6	;4 bit and
	bra.s	.here
	;
.loop2	swap	d7
	bra.s	.here
	;
.loop	movem.l	(a0)+,d0-d3	;next 16 pixels.
	move.l	a2,d6	;4 bit and
	;
	swap	d4
	move	d4,(a1)	;plane 7
	sub.l	a6,a1	;back to start of next pixel.
	;
.here	rotbits	d0,d2,4
	rotbits	d1,d3,4
	;
	move.l	a3,d6	;2 bit and
	rotbits	d0,d1,2
	move.l	a4,d6	;1 bit and
	;
	move.l	d0,d4
	and.l	d6,d4
	eor.l	d4,d0
	lsr	#1,d4
	swap	d4
	add	d4,d4
	or.l	d4,d0
	;
	move	d0,(a1)	;plane 0
	add.l	a5,a1
	;
	move.l	d1,d4
	and.l	d6,d4
	eor.l	d4,d1
	;
	swap	d0
	move	d0,(a1)
	add.l	a5,a1
	;
	lsr	#1,d4
	swap	d4
	add	d4,d4
	or.l	d4,d1
	;
	move	d1,(a1)	;plane 2
	add.l	a5,a1
	;
	move.l	a3,d6	;2 bit and
	rotbits	d2,d3,2
	move.l	a4,d6	;1 bit and
	;
	move.l	d2,d4
	and.l	d6,d4
	eor.l	d4,d2
	;
	swap	d1
	move	d1,(a1)	;plane 3
	add.l	a5,a1
	;
	lsr	#1,d4
	swap	d4
	add	d4,d4
	or.l	d4,d2
	;
	move	d2,(a1)	;plane 4
	add.l	a5,a1
	;
	move.l	d3,d4
	and.l	d6,d4
	eor.l	d4,d3
	;
	swap	d2
	move	d2,(a1)	;plane 5
	add.l	a5,a1
	;
	lsr	#1,d4
	swap	d4
	add	d4,d4
	or.l	d3,d4
	;
	move	d4,(a1)	;plane 6
	add.l	a5,a1
	;
	dbf	d7,.loop	;end of width?
	move	(a7),d7
	swap	d7
	;
	movem.l	(a0)+,d0-d3	;get next 16 pixels.
	move.l	a2,d6	;4 bit and
	;
	swap	d4
	move	d4,(a1)	;plane 7.
	add.l	4(a7),a1	;start of next line
	;
	dbf	d7,.loop2
	;
	list
.check	set	*-.loop2	;loop size (<256?)
	nolist
	;
	addq	#8,a7
	;
	rts

doc2p_1X6	;
	;inputs:
	;a0.l=src chunky buffer
	;a1.l=dest chipmem bitmap
	;d0.w=width (in pixels - multiple of 32) to convert
	;d1.w=height (in pixels - even)
	;d2.l=modulo from one bitplane to next (copmod-ish)
	;d3.l=modulo from start of one line to start of next (linemod)
	;
	;internal:
	;d6=current and reg.
	;d7=loop counter
	;a2=4 bit and
	;a3=2 bit and
	;a4=1 bit and
	;a5=bitplane modulo, 1 bp to next
	;a6=subtract at end of one loop
	;
	move.l	#$0f0f0f0f,a2
	move.l	#$33333333,a3
	move.l	#$5555aaaa,a4
	move.l	d2,a5	;one bp to next.
	;
	lsl.l	#2,d2	;*4
	add.l	a5,d2	;*5
	move.l	d2,a6
	subq.l	#2,a6
	;
	lsr	#4,d0	;16 pixels at a time
	move	d0,d2
	ext.l	d2
	add.l	d2,d2	;bytes
	add.l	a6,d2
	sub.l	d2,d3
	move.l	d3,-(a7)
	;
	subq	#1,d1
	move	d1,d7	;hite dbf
	swap	d7
	subq	#1,d0
	move	d0,d7
	subq	#2,a7	;long align
	move	d7,-(a7)
	;
	movem.l	(a0)+,d0-d3	;next 16 pixels.
	move.l	a2,d6	;4 bit and
	bra.s	.here
	;
.loop2	swap	d7
	bra.s	.here
	;
.loop	movem.l	(a0)+,d0-d3	;next 16 pixels.
	move.l	a2,d6	;4 bit and
	;
	swap	d4
	move	d4,(a1)	;plane 7
	sub.l	a6,a1	;back to start of next pixel.
	;
.here	rotbits	d0,d2,4
	rotbits	d1,d3,4
	;
	move.l	a3,d6	;2 bit and
	rotbits	d0,d1,2
	move.l	a4,d6	;1 bit and
	;
	move.l	d0,d4
	and.l	d6,d4
	eor.l	d4,d0
	lsr	#1,d4
	swap	d4
	add	d4,d4
	or.l	d4,d0
	;
	move	d0,(a1)	;plane 0
	add.l	a5,a1
	;
	move.l	d1,d4
	and.l	d6,d4
	eor.l	d4,d1
	;
	swap	d0
	move	d0,(a1)	;plane 1
	add.l	a5,a1
	;
	lsr	#1,d4
	swap	d4
	add	d4,d4
	or.l	d4,d1
	;
	move	d1,(a1)	;plane 2
	add.l	a5,a1
	;
	move.l	a3,d6	;2 bit and
	rotbits	d2,d3,2
	move.l	a4,d6	;1 bit and
	;
	move.l	d2,d4
	and.l	d6,d4
	eor.l	d4,d2
	;
	swap	d1
	move	d1,(a1)	;plane 3
	add.l	a5,a1
	;
	lsr	#1,d4
	swap	d4
	add	d4,d4
	or.l	d2,d4
	;
	move	d4,(a1)	;plane 4
	add.l	a5,a1
	;
	dbf	d7,.loop	;end of width?
	move	(a7),d7
	swap	d7
	;
	movem.l	(a0)+,d0-d3	;get next 16 pixels.
	move.l	a2,d6	;4 bit and
	;
	swap	d4
	move	d4,(a1)	;plane 7.
	add.l	4(a7),a1	;start of next line
	;
	dbf	d7,.loop2
	;
	list
.check	set	*-.loop2	;loop size (<256?)
	nolist
	;
	addq	#8,a7
	;
	rts

expand	macro
	move.l	d1,d2
	swap	d1
	move.l	d1,d3
	move	d2,d3
	move	d1,d2
	move.l	d0,d1
	swap	d1
	move	d1,d5
	move	d0,d1
	move	d5,d0
	endm

doc2p_2X8	;
	;inputs:
	;a0.l=src chunky buffer
	;a1.l=dest chipmem bitmap
	;d0.w=width (in pixels - multiple of 32) to convert
	;d1.w=height (in pixels - even)
	;d2.l=modulo from one bitplane to next (copmod-ish)
	;d3.l=modulo from start of one line to start of next (linemod)
	;
	;internal:
	;d6=current and reg.
	;d7=loop counter
	;a2=4 bit and
	;a3=2 bit and
	;a4=1 bit and
	;a5=bitplane modulo, 1 bp to next
	;a6=subtract at end of one loop
	;
	move.l	#$0f0f0f0f,a2
	move.l	#$33333333,a3
	move.l	#$5555aaaa,a4
	move.l	d2,a5	;one bp to next.
	;
	lsl.l	#3,d2	;8 bitplanes
	move.l	d2,a6
	sub.l	a5,a6	;7 * bpmod
	subq.l	#2,a6	;to next word
	;
	lsr	#3,d0
	move	d0,d2
	ext.l	d2
	add.l	d2,d2
	add.l	a6,d2
	sub.l	d2,d3
	move.l	d3,-(a7)
	;
	subq	#1,d1
	move	d1,d7	;hite dbf
	swap	d7
	subq	#1,d0
	move	d0,d7
	subq	#2,a7	;long align
	move	d7,-(a7)
	;
	movem.l	(a0)+,d0-d1	;next 16 pixels.
	move.l	a2,d6	;4 bit and
	bra.s	.here
	;
.loop2	swap	d7
	bra.s	.here
	;
.loop	movem.l	(a0)+,d0-d1	;next 16 pixels.
	move.l	a2,d6	;4 bit and
	;
	swap	d4
	move	d4,(a1)	;plane 7
	sub.l	a6,a1	;back to start of next pixel.
	;
.here	expand
	rotbits	d0,d2,4
	rotbits	d1,d3,4
	;
	move.l	a3,d6	;2 bit and
	rotbits	d0,d1,2
	move.l	a4,d6	;1 bit and
	;
	move.l	d0,d4
	and.l	d6,d4
	eor.l	d4,d0
	lsr	#1,d4
	swap	d4
	add	d4,d4
	or.l	d4,d0
	;
	move	d0,(a1)	;plane 0
	add.l	a5,a1
	;
	move.l	d1,d4
	and.l	d6,d4
	eor.l	d4,d1
	;
	swap	d0
	move	d0,(a1)
	add.l	a5,a1
	;
	lsr	#1,d4
	swap	d4
	add	d4,d4
	or.l	d4,d1
	;
	move	d1,(a1)	;plane 2
	add.l	a5,a1
	;
	move.l	a3,d6	;2 bit and
	rotbits	d2,d3,2
	move.l	a4,d6	;1 bit and
	;
	move.l	d2,d4
	and.l	d6,d4
	eor.l	d4,d2
	;
	swap	d1
	move	d1,(a1)	;plane 3
	add.l	a5,a1
	;
	lsr	#1,d4
	swap	d4
	add	d4,d4
	or.l	d4,d2
	;
	move	d2,(a1)	;plane 4
	add.l	a5,a1
	;
	move.l	d3,d4
	and.l	d6,d4
	eor.l	d4,d3
	;
	swap	d2
	move	d2,(a1)	;plane 5
	add.l	a5,a1
	;
	lsr	#1,d4
	swap	d4
	add	d4,d4
	or.l	d3,d4
	;
	move	d4,(a1)	;plane 6
	add.l	a5,a1
	;
	dbf	d7,.loop	;end of width?
	move	(a7),d7
	swap	d7
	;
	movem.l	(a0)+,d0-d1	;get next 16 pixels.
	move.l	a2,d6	;4 bit and
	;
	swap	d4
	move	d4,(a1)	;plane 7.
	add.l	4(a7),a1	;start of next line
	;
	dbf	d7,.loop2
	;
	list
.check	set	*-.loop2	;loop size (<256?)
	nolist
	;
	addq	#8,a7
	;
	rts

doc2p_2X6	;
	;inputs:
	;a0.l=src chunky buffer
	;a1.l=dest chipmem bitmap
	;d0.w=width (in pixels - multiple of 32) to convert
	;d1.w=height (in pixels - even)
	;d2.l=modulo from one bitplane to next (bplmod-ish)
	;d3.l=modulo from start of one line to start of next (linemod)
	;
	;internal:
	;d6=current and reg.
	;d7=loop counter
	;a2=4 bit and
	;a3=2 bit and
	;a4=1 bit and
	;a5=bitplane modulo, 1 bp to next
	;a6=subtract at end of one loop
	;
	move.l	#$0f0f0f0f,a2
	move.l	#$33333333,a3
	move.l	#$5555aaaa,a4
	move.l	d2,a5	;one bp to next.
	;
	lsl.l	#2,d2	;*4
	add.l	a5,d2	;*5
	move.l	d2,a6
	subq.l	#2,a6
	;
	lsr	#3,d0	;16 pixels at a time
	move	d0,d2
	ext.l	d2
	add.l	d2,d2	;bytes
	add.l	a6,d2
	sub.l	d2,d3
	move.l	d3,-(a7)
	;
	subq	#1,d1
	move	d1,d7	;hite dbf
	swap	d7
	subq	#1,d0
	move	d0,d7
	subq	#2,a7	;long align
	move	d7,-(a7)
	;
	movem.l	(a0)+,d0-d1	;next 16 pixels.
	move.l	a2,d6	;4 bit and
	bra.s	.here
	;
.loop2	swap	d7
	bra.s	.here
	;
.loop	movem.l	(a0)+,d0-d1	;next 16 pixels.
	move.l	a2,d6	;4 bit and
	;
	swap	d4
	move	d4,(a1)	;plane 7
	sub.l	a6,a1	;back to start of next pixel.
	;
.here	expand
	rotbits	d0,d2,4
	rotbits	d1,d3,4
	;
	move.l	a3,d6	;2 bit and
	rotbits	d0,d1,2
	move.l	a4,d6	;1 bit and
	;
	move.l	d0,d4
	and.l	d6,d4
	eor.l	d4,d0
	lsr	#1,d4
	swap	d4
	add	d4,d4
	or.l	d4,d0
	;
	move	d0,(a1)	;plane 0
	add.l	a5,a1
	;
	move.l	d1,d4
	and.l	d6,d4
	eor.l	d4,d1
	;
	swap	d0
	move	d0,(a1)	;plane 1
	add.l	a5,a1
	;
	lsr	#1,d4
	swap	d4
	add	d4,d4
	or.l	d4,d1
	;
	move	d1,(a1)	;plane 2
	add.l	a5,a1
	;
	move.l	a3,d6	;2 bit and
	rotbits	d2,d3,2
	move.l	a4,d6	;1 bit and
	;
	move.l	d2,d4
	and.l	d6,d4
	eor.l	d4,d2
	;
	swap	d1
	move	d1,(a1)	;plane 3
	add.l	a5,a1
	;
	lsr	#1,d4
	swap	d4
	add	d4,d4
	or.l	d2,d4
	;
	move	d4,(a1)	;plane 4
	add.l	a5,a1
	;
	dbf	d7,.loop	;end of width?
	move	(a7),d7
	swap	d7
	;
	movem.l	(a0)+,d0-d1	;get next 16 pixels.
	move.l	a2,d6	;4 bit and
	;
	swap	d4
	move	d4,(a1)	;plane 7.
	add.l	4(a7),a1	;start of next line
	;
	dbf	d7,.loop2
	;
	list
.check	set	*-.loop2	;loop size (<256?)
	nolist
	;
	addq	#8,a7
	;
	rts
