
		machine 68020

_LVOOpenLibrary EQU -552
_LVOCloseLibrary EQU -414

		bra.w	initc2p 	; offset 0: initialization routines
		bra.w	doc2p_1X8	; offset 4: one pixel wide version, AGA
		bra.w	doc2p_1X6	; offset 8: one pixel wide version, EHB
		bra.w	doc2p_2X8	; offset 12: two pixel wide version, AGA
		bra.w	doc2p_2X6	; offset 16: two pixel wide version, EHB
		dc.l	string		; offset 20: address of descr string

gfxbase 	dc.l	0		; GfxBase
c2p_ptr 	dc.l	0		; hardware address of Akiko register

		dc.b	'$VER: akiko_1 1.0 (4/1/96)',0
string		dc.b	'A chunky to planar routine by Peter McGavin. '
		dc.b	'Changes by Iain Barclay. '
		dc.b	'REQUIRES AKIKO CHIP, e.g, as in CD32. '
		dc.b	'Supports 6/8 bitplane, single/double width pixels.',0
gfxname 	dc.b	'graphics.library',0
		even

gb_ChunkyToPlanarPtr equ 508

initc2p

; create 2 tables for Gloom

; a0=columns buffer to fill in (array of longs) for 1 wide pixs.
; a1=columns buffer for 2 wide pixs
; d0=how many columns (multiple of 32)
; a2=palette remapping array (do 256)

		move.w	#255,d1 ;#colours-1
.loop		move.b	d1,(a2,d1.w)
		dbf	d1,.loop

; column offsets for 1 wide pixels

; 0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,
; 16,17,18,19,20...

		move.w	d0,d1
		ext.l	d1
		subq.l	#1,d1
.loop2		move.l	d1,(a0,d1.w*4)
		dbf	d1,.loop2

; column offsets for 2 wide pixels

; 0,2,4,6,8,10,12,14,16,18,20,22,24,26,28,30
; 1,3,5,7,9,11,13,15,17,19,21,23,25,27,29,31
; 32,34,36,38,40,...

		lsr.w	#5,d0
		subq.w	#1,d0
		moveq	#0,d1
.loop3		moveq	#15,d2
.loop4		move.l	d1,(a1)+
		addq.l	#2,d1
		dbf	d2,.loop4
		sub.l	#31,d1
		moveq	#15,d2
.loop5		move.l	d1,(a1)+
		addq.l	#2,d1
		dbf	d2,.loop5
		subq.l	#1,d1
		dbf	d0,.loop3

; open graphics.library and retrieve gb_ChunkyToPlanarPtr

		lea	(gfxname,pc),a1
		moveq	#40,d0
		move.l	(4).w,a6
		jsr	(_LVOOpenLibrary,a6)
		lea	(gfxbase,pc),a0
		move.l	d0,(a0) 	; save gfxbase
		beq	.end
		movea.l d0,a1		; a1 = gfxbase
		move.l	(gb_ChunkyToPlanarPtr,a1),(c2p_ptr-gfxbase,a0)
		jsr	(_LVOCloseLibrary,a6)
.end
		rts

		cnop	0,4
doc2p_1X8
; inputs:
; a0.l=src chunky buffer
; a1.l=dest chipmem bitmap
; d0.w=width (in pixels - multiple of 32) to convert
; d1.w=height (in pixels - even)
; d2.l=modulo from one bitplane to next (copmod-ish)
; d3.l=modulo from start of one line to start of next (linemod)

; internal:
; a2=subtract at end of one loop
; a3=akiko hardware register ptr
; a5=bitplane modulo, 1 bp to next
; d3=add at end of line
; d5=counter

		move.l	(c2p_ptr,pc),d4
		beq	.return
		movea.l d4,a3	; a3 -> akiko hardware register

		movea.l d2,a5	; a5 = bpmod

		lsl.l	#3,d2	; 8 bitplanes
		movea.l d2,a2	; 8 * bpmod
		suba.l	a5,a2	; 7 * bpmod
		subq.l	#4,a2	; a2 = 7 * bpmod - 4

		lsr.w	#5,d0	; num 32 pixels per row
		move.w	d0,d2
		lsl.w	#2,d2	; num 8 pixels per row (dest bytesperrow)
		ext.l	d2	; bytesperrow
		sub.l	d2,d3	; d3 = linemod - bytesperrow

		subq.w	#1,d1	; d1 = height - 1
		subq.w	#1,d0	; d0 = num 32 pixels per row - 1

.rowloop	move.w	d0,d5		; num 32 pixels per row - 1

.innerloop	move.l	(a0)+,(a3)	; next 4 pixels -> Akiko
		move.l	(a0)+,(a3)	; next 4 pixels -> Akiko
		move.l	(a0)+,(a3)	; next 4 pixels -> Akiko
		move.l	(a0)+,(a3)	; next 4 pixels -> Akiko
		move.l	(a0)+,(a3)	; next 4 pixels -> Akiko
		move.l	(a0)+,(a3)	; next 4 pixels -> Akiko
		move.l	(a0)+,(a3)	; next 4 pixels -> Akiko
		move.l	(a0)+,(a3)	; next 4 pixels -> Akiko

		move.l	(a3),(a1)	; plane 0
		adda.l	a5,a1		; +bpmod
		move.l	(a3),(a1)	; plane 1
		adda.l	a5,a1		; +bpmod
		move.l	(a3),(a1)	; plane 2
		adda.l	a5,a1		; +bpmod
		move.l	(a3),(a1)	; plane 3
		adda.l	a5,a1		; +bpmod
		move.l	(a3),(a1)	; plane 4
		adda.l	a5,a1		; +bpmod
		move.l	(a3),(a1)	; plane 5
		adda.l	a5,a1		; +bpmod
		move.l	(a3),(a1)	; plane 6
		adda.l	a5,a1		; +bpmod
		move.l	(a3),(a1)	; plane 7
		suba.l	a2,a1		; -7*bpmod+4

		dbra	d5,.innerloop

		adda.l	d3,a1		; dest skip

		dbra	d1,.rowloop	; next row

.return
		rts

		cnop	0,4
doc2p_1X6
; inputs:
; a0.l=src chunky buffer
; a1.l=dest chipmem bitmap
; d0.w=width (in pixels - multiple of 32) to convert
; d1.w=height (in pixels - even)
; d2.l=modulo from one bitplane to next (copmod-ish)
; d3.l=modulo from start of one line to start of next (linemod)

; internal:
; a2=subtract at end of one loop
; a3=akiko hardware register ptr
; a5=bitplane modulo, 1 bp to next
; d3=add at end of line
; d5=counter

		move.l	(c2p_ptr,pc),d4
		beq	.return
		movea.l d4,a3	; a3 -> akiko hardware register

		movea.l d2,a5	; a5 = bpmod

		lsl.l	#2,d2	; 6 bitplanes
		movea.l d2,a2	; 4 * bpmod
		adda.l	a5,a2	; 5 * bpmod
		subq.l	#4,a2	; a2 = 5 * bpmod - 4

		lsr.w	#5,d0	; num 32 pixels per row
		move.w	d0,d2
		lsl.w	#2,d2	; num 8 pixels per row (dest bytesperrow)
		ext.l	d2	; bytesperrow
		sub.l	d2,d3	; d3 = linemod - bytesperrow

		subq.w	#1,d1	; d1 = height - 1
		subq.w	#1,d0	; d0 = num 32 pixels per row - 1

.rowloop	move.w	d0,d5		; num 32 pixels per row - 1

.innerloop	move.l	(a0)+,(a3)	; next 4 pixels -> Akiko
		move.l	(a0)+,(a3)	; next 4 pixels -> Akiko
		move.l	(a0)+,(a3)	; next 4 pixels -> Akiko
		move.l	(a0)+,(a3)	; next 4 pixels -> Akiko
		move.l	(a0)+,(a3)	; next 4 pixels -> Akiko
		move.l	(a0)+,(a3)	; next 4 pixels -> Akiko
		move.l	(a0)+,(a3)	; next 4 pixels -> Akiko
		move.l	(a0)+,(a3)	; next 4 pixels -> Akiko

		move.l	(a3),(a1)	; plane 0
		adda.l	a5,a1		; +bpmod
		move.l	(a3),(a1)	; plane 1
		adda.l	a5,a1		; +bpmod
		move.l	(a3),(a1)	; plane 2
		adda.l	a5,a1		; +bpmod
		move.l	(a3),(a1)	; plane 3
		adda.l	a5,a1		; +bpmod
		move.l	(a3),(a1)	; plane 4
		adda.l	a5,a1		; +bpmod
		move.l	(a3),(a1)	; plane 5
		suba.l	a2,a1		; -5*bpmod+4

		dbra	d5,.innerloop

		adda.l	d3,a1		; dest skip

		dbra	d1,.rowloop	; next row

.return
		rts

		cnop	0,4
doc2p_2X8
; inputs:
; a0.l=src chunky buffer
; a1.l=dest chipmem bitmap
; d0.w=width (in pixels - multiple of 32) to convert
; d1.w=height (in pixels - even)
; d2.l=modulo from one bitplane to next (copmod-ish)
; d3.l=modulo from start of one line to start of next (linemod)

; internal:
; a2=subtract at end of one loop
; a3=akiko hardware register ptr
; a5=bitplane modulo, 1 bp to next
; d3=add at end of line
; d5=counter

		move.l	(c2p_ptr,pc),d4
		beq	.return
		movea.l d4,a3	; a3 -> akiko hardware register

		movea.l d2,a5	; a5 = bpmod

		lsl.l	#3,d2	; 8 bitplanes
		movea.l d2,a2	; 8 * bpmod
		suba.l	a5,a2	; 7 * bpmod
		subq.l	#4,a2	; a2 = 7 * bpmod - 4

		lsr.w	#5,d0	; num 32 pixels per row
		move.w	d0,d2
		lsl.w	#3,d2	; num 4 pixels per row (dest bytesperrow)
		ext.l	d2	; bytesperrow
		sub.l	d2,d3	; d3 = linemod - bytesperrow

		subq.l	#4,a5	; a5 = bpmod - 4

		move.l	#$aaaaaaaa,d7

		subq.w	#1,d1	; d1 = height - 1
		subq.w	#1,d0	; d0 = num 32 pixels per row - 1

.rowloop	move.w	d0,d5		; num 32 pixels per row - 1

.innerloop	move.l	(a0)+,(a3)	; next 4 pixels -> Akiko
		move.l	(a0)+,(a3)	; next 4 pixels -> Akiko
		move.l	(a0)+,(a3)	; next 4 pixels -> Akiko
		move.l	(a0)+,(a3)	; next 4 pixels -> Akiko
		move.l	(a0)+,(a3)	; next 4 pixels -> Akiko
		move.l	(a0)+,(a3)	; next 4 pixels -> Akiko
		move.l	(a0)+,(a3)	; next 4 pixels -> Akiko
		move.l	(a0)+,(a3)	; next 4 pixels -> Akiko

		move.l	(a3),d2 	; plane 0 from Akiko
		move.l	d2,d4
		and.l	d7,d2		; d2 = a.b.c.d.e.f.g.h.i.j.k.l.m.n.o.p.
		eor.l	d2,d4		; d4 = .q.r.s.t.u.v.w.x.y.z.A.B.C.D.E.F
		move.l	d2,d6
		lsr.l	#1,d6
		or.l	d6,d2		; d2 = aabbccddeeffgghhiijjkkllmmnnoopp
		move.l	d2,(a1)+	; plane 0
		move.l	d4,d6
		add.l	d6,d6
		or.l	d4,d6		; d6 = qqrrssttuuvvwwxxyyzzAABBCCDDEEFF
		move.l	(a3),d2 	; plane 1 from Akiko
		move.l	d6,(a1) 	; plane 0
		adda.l	a5,a1

		move.l	d2,d4
		and.l	d7,d2		; d2 = a.b.c.d.e.f.g.h.i.j.k.l.m.n.o.p.
		eor.l	d2,d4		; d4 = .q.r.s.t.u.v.w.x.y.z.A.B.C.D.E.F
		move.l	d2,d6
		lsr.l	#1,d6
		or.l	d6,d2		; d2 = aabbccddeeffgghhiijjkkllmmnnoopp
		move.l	d2,(a1)+	; plane 1
		move.l	d4,d6
		add.l	d6,d6
		or.l	d4,d6		; d6 = qqrrssttuuvvwwxxyyzzAABBCCDDEEFF
		move.l	(a3),d2 	; plane 2 from Akiko
		move.l	d6,(a1) 	; plane 1
		adda.l	a5,a1

		move.l	d2,d4
		and.l	d7,d2		; d2 = a.b.c.d.e.f.g.h.i.j.k.l.m.n.o.p.
		eor.l	d2,d4		; d4 = .q.r.s.t.u.v.w.x.y.z.A.B.C.D.E.F
		move.l	d2,d6
		lsr.l	#1,d6
		or.l	d6,d2		; d2 = aabbccddeeffgghhiijjkkllmmnnoopp
		move.l	d2,(a1)+	; plane 2
		move.l	d4,d6
		add.l	d6,d6
		or.l	d4,d6		; d6 = qqrrssttuuvvwwxxyyzzAABBCCDDEEFF
		move.l	(a3),d2 	; plane 3 from Akiko
		move.l	d6,(a1) 	; plane 2
		adda.l	a5,a1

		move.l	d2,d4
		and.l	d7,d2		; d2 = a.b.c.d.e.f.g.h.i.j.k.l.m.n.o.p.
		eor.l	d2,d4		; d4 = .q.r.s.t.u.v.w.x.y.z.A.B.C.D.E.F
		move.l	d2,d6
		lsr.l	#1,d6
		or.l	d6,d2		; d2 = aabbccddeeffgghhiijjkkllmmnnoopp
		move.l	d2,(a1)+	; plane 3
		move.l	d4,d6
		add.l	d6,d6
		or.l	d4,d6		; d6 = qqrrssttuuvvwwxxyyzzAABBCCDDEEFF
		move.l	(a3),d2 	; plane 4 from Akiko
		move.l	d6,(a1) 	; plane 3
		adda.l	a5,a1

		move.l	d2,d4
		and.l	d7,d2		; d2 = a.b.c.d.e.f.g.h.i.j.k.l.m.n.o.p.
		eor.l	d2,d4		; d4 = .q.r.s.t.u.v.w.x.y.z.A.B.C.D.E.F
		move.l	d2,d6
		lsr.l	#1,d6
		or.l	d6,d2		; d2 = aabbccddeeffgghhiijjkkllmmnnoopp
		move.l	d2,(a1)+	; plane 4
		move.l	d4,d6
		add.l	d6,d6
		or.l	d4,d6		; d6 = qqrrssttuuvvwwxxyyzzAABBCCDDEEFF
		move.l	(a3),d2 	; plane 5 from Akiko
		move.l	d6,(a1) 	; plane 4
		adda.l	a5,a1

		move.l	d2,d4
		and.l	d7,d2		; d2 = a.b.c.d.e.f.g.h.i.j.k.l.m.n.o.p.
		eor.l	d2,d4		; d4 = .q.r.s.t.u.v.w.x.y.z.A.B.C.D.E.F
		move.l	d2,d6
		lsr.l	#1,d6
		or.l	d6,d2		; d2 = aabbccddeeffgghhiijjkkllmmnnoopp
		move.l	d2,(a1)+	; plane 5
		move.l	d4,d6
		add.l	d6,d6
		or.l	d4,d6		; d6 = qqrrssttuuvvwwxxyyzzAABBCCDDEEFF
		move.l	(a3),d2 	; plane 6 from Akiko
		move.l	d6,(a1) 	; plane 5
		adda.l	a5,a1

		move.l	d2,d4
		and.l	d7,d2		; d2 = a.b.c.d.e.f.g.h.i.j.k.l.m.n.o.p.
		eor.l	d2,d4		; d4 = .q.r.s.t.u.v.w.x.y.z.A.B.C.D.E.F
		move.l	d2,d6
		lsr.l	#1,d6
		or.l	d6,d2		; d2 = aabbccddeeffgghhiijjkkllmmnnoopp
		move.l	d2,(a1)+	; plane 6
		move.l	d4,d6
		add.l	d6,d6
		or.l	d4,d6		; d6 = qqrrssttuuvvwwxxyyzzAABBCCDDEEFF
		move.l	(a3),d2 	; plane 7 from Akiko
		move.l	d6,(a1) 	; plane 6
		adda.l	a5,a1

		move.l	d2,d4
		and.l	d7,d2		; d2 = a.b.c.d.e.f.g.h.i.j.k.l.m.n.o.p.
		eor.l	d2,d4		; d4 = .q.r.s.t.u.v.w.x.y.z.A.B.C.D.E.F
		move.l	d2,d6
		lsr.l	#1,d6
		or.l	d6,d2		; d2 = aabbccddeeffgghhiijjkkllmmnnoopp
		move.l	d2,(a1)+	; plane 7
		move.l	d4,d6
		add.l	d6,d6
		or.l	d4,d6		; d6 = qqrrssttuuvvwwxxyyzzAABBCCDDEEFF
		move.l	d6,(a1) 	; plane 7
		suba.l	a2,a1		; -7*bpmod+4

		dbra	d5,.innerloop

		adda.l	d3,a1		; dest skip

		dbra	d1,.rowloop	; next row
.return
		rts

		cnop	0,4
doc2p_2X6
; inputs:
; a0.l=src chunky buffer
; a1.l=dest chipmem bitmap
; d0.w=width (in pixels - multiple of 32) to convert
; d1.w=height (in pixels - even)
; d2.l=modulo from one bitplane to next (copmod-ish)
; d3.l=modulo from start of one line to start of next (linemod)

; internal:
; a2=subtract at end of one loop
; a3=akiko hardware register ptr
; a5=bitplane modulo, 1 bp to next
; d3=add at end of line
; d5=counter

		move.l	(c2p_ptr,pc),d4
		beq	.return
		movea.l d4,a3	; a3 -> akiko hardware register

		movea.l d2,a5	; a5 = bpmod

		lsl.l	#2,d2	; 6 bitplanes
		movea.l d2,a2	; 4 * bpmod
		adda.l	a5,a2	; 5 * bpmod
		subq.l	#4,a2	; a2 = 5 * bpmod - 4

		lsr.w	#5,d0	; num 32 pixels per row
		move.w	d0,d2
		lsl.w	#3,d2	; num 4 pixels per row (dest bytesperrow)
		ext.l	d2	; bytesperrow
		sub.l	d2,d3	; d3 = linemod - bytesperrow

		subq.l	#4,a5	; a5 = bpmod - 4

		move.l	#$aaaaaaaa,d7

		subq.w	#1,d1	; d1 = height - 1
		subq.w	#1,d0	; d0 = num 32 pixels per row - 1

.rowloop	move.w	d0,d5		; num 32 pixels per row - 1

.innerloop	move.l	(a0)+,(a3)	; next 4 pixels -> Akiko
		move.l	(a0)+,(a3)	; next 4 pixels -> Akiko
		move.l	(a0)+,(a3)	; next 4 pixels -> Akiko
		move.l	(a0)+,(a3)	; next 4 pixels -> Akiko
		move.l	(a0)+,(a3)	; next 4 pixels -> Akiko
		move.l	(a0)+,(a3)	; next 4 pixels -> Akiko
		move.l	(a0)+,(a3)	; next 4 pixels -> Akiko
		move.l	(a0)+,(a3)	; next 4 pixels -> Akiko

		move.l	(a3),d2 	; plane 0 from Akiko
		move.l	d2,d4
		and.l	d7,d2		; d2 = a.b.c.d.e.f.g.h.i.j.k.l.m.n.o.p.
		eor.l	d2,d4		; d4 = .q.r.s.t.u.v.w.x.y.z.A.B.C.D.E.F
		move.l	d2,d6
		lsr.l	#1,d6
		or.l	d6,d2		; d2 = aabbccddeeffgghhiijjkkllmmnnoopp
		move.l	d2,(a1)+	; plane 0
		move.l	d4,d6
		add.l	d6,d6
		or.l	d4,d6		; d6 = qqrrssttuuvvwwxxyyzzAABBCCDDEEFF
		move.l	(a3),d2 	; plane 1 from Akiko
		move.l	d6,(a1) 	; plane 0
		adda.l	a5,a1

		move.l	d2,d4
		and.l	d7,d2		; d2 = a.b.c.d.e.f.g.h.i.j.k.l.m.n.o.p.
		eor.l	d2,d4		; d4 = .q.r.s.t.u.v.w.x.y.z.A.B.C.D.E.F
		move.l	d2,d6
		lsr.l	#1,d6
		or.l	d6,d2		; d2 = aabbccddeeffgghhiijjkkllmmnnoopp
		move.l	d2,(a1)+	; plane 1
		move.l	d4,d6
		add.l	d6,d6
		or.l	d4,d6		; d6 = qqrrssttuuvvwwxxyyzzAABBCCDDEEFF
		move.l	(a3),d2 	; plane 2 from Akiko
		move.l	d6,(a1) 	; plane 1
		adda.l	a5,a1

		move.l	d2,d4
		and.l	d7,d2		; d2 = a.b.c.d.e.f.g.h.i.j.k.l.m.n.o.p.
		eor.l	d2,d4		; d4 = .q.r.s.t.u.v.w.x.y.z.A.B.C.D.E.F
		move.l	d2,d6
		lsr.l	#1,d6
		or.l	d6,d2		; d2 = aabbccddeeffgghhiijjkkllmmnnoopp
		move.l	d2,(a1)+	; plane 2
		move.l	d4,d6
		add.l	d6,d6
		or.l	d4,d6		; d6 = qqrrssttuuvvwwxxyyzzAABBCCDDEEFF
		move.l	(a3),d2 	; plane 3 from Akiko
		move.l	d6,(a1) 	; plane 2
		adda.l	a5,a1

		move.l	d2,d4
		and.l	d7,d2		; d2 = a.b.c.d.e.f.g.h.i.j.k.l.m.n.o.p.
		eor.l	d2,d4		; d4 = .q.r.s.t.u.v.w.x.y.z.A.B.C.D.E.F
		move.l	d2,d6
		lsr.l	#1,d6
		or.l	d6,d2		; d2 = aabbccddeeffgghhiijjkkllmmnnoopp
		move.l	d2,(a1)+	; plane 3
		move.l	d4,d6
		add.l	d6,d6
		or.l	d4,d6		; d6 = qqrrssttuuvvwwxxyyzzAABBCCDDEEFF
		move.l	(a3),d2 	; plane 4 from Akiko
		move.l	d6,(a1) 	; plane 3
		adda.l	a5,a1

		move.l	d2,d4
		and.l	d7,d2		; d2 = a.b.c.d.e.f.g.h.i.j.k.l.m.n.o.p.
		eor.l	d2,d4		; d4 = .q.r.s.t.u.v.w.x.y.z.A.B.C.D.E.F
		move.l	d2,d6
		lsr.l	#1,d6
		or.l	d6,d2		; d2 = aabbccddeeffgghhiijjkkllmmnnoopp
		move.l	d2,(a1)+	; plane 4
		move.l	d4,d6
		add.l	d6,d6
		or.l	d4,d6		; d6 = qqrrssttuuvvwwxxyyzzAABBCCDDEEFF
		move.l	(a3),d2 	; plane 5 from Akiko
		move.l	d6,(a1) 	; plane 4
		adda.l	a5,a1

		move.l	d2,d4
		and.l	d7,d2		; d2 = a.b.c.d.e.f.g.h.i.j.k.l.m.n.o.p.
		eor.l	d2,d4		; d4 = .q.r.s.t.u.v.w.x.y.z.A.B.C.D.E.F
		move.l	d2,d6
		lsr.l	#1,d6
		or.l	d6,d2		; d2 = aabbccddeeffgghhiijjkkllmmnnoopp
		move.l	d2,(a1)+	; plane 5
		move.l	d4,d6
		add.l	d6,d6
		or.l	d4,d6		; d6 = qqrrssttuuvvwwxxyyzzAABBCCDDEEFF
		move.l	d6,(a1) 	; plane 5
		suba.l	a2,a1		; -5*bpmod+4

		dbra	d5,.innerloop

		adda.l	d3,a1		; dest skip

		dbra	d1,.rowloop	; next row
.return
		rts

		end
