
		machine 68040

NEWCODE EQU 1

		bra.w	initc2p 	; offset 0: initialization routines
		bra.w	doc2p_1X8	; offset 4: one pixel wide version, AGA
		bra.w	doc2p_1X6	; offset 8: one pixel wide version, EHB
		bra.w	doc2p_2X8	; offset 12: two pixel wide version, AGA
		bra.w	doc2p_2X6	; offset 16: two pixel wide version, EHB
		dc.l	string		; offset 20: address of descr string

		dc.b	'$VER: 040_1 1.0 (4/1/96)',0
string		dc.b	'A chunky to planar routine by Peter McGavin. '
		dc.b	'Changes by Iain Barclay. '
		dc.b	'Optimised for 68040 with 32-bit chipmem. '
		dc.b	'Supports 6/8 bitplane, single/double width pixels.',0
		even

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

; 0,4,8,12,16,20,24,28,1,5,9,13,17,21,25,29
; 2,6,10,14,18,22,26,30,3,7,11,15,19,23,27,31
; 32,36,40,...

		move.l	d0,d4
		lsr.w	#5,d4
		subq.w	#1,d4
		moveq	#0,d1
.loop0		moveq	#3,d2
.loop1		moveq	#7,d3
.loop2		move.l	d1,(a0)+
		addq.l	#4,d1
		dbf	d3,.loop2
		sub.l	#31,d1
		dbf	d2,.loop1
		add.l	#28,d1
		dbf	d4,.loop0

; column offsets for 2 wide pixels

; 0,4,8,12,1,5,9,13,2,6,10,14,3,7,11,15,
; 16,20,24,28,17,...

		lsr.w	#4,d0
		subq.w	#1,d0
		moveq	#0,d1
.loop3		moveq	#3,d2
.loop4		moveq	#3,d3
.loop5		move.l	d1,(a1)+
		addq.l	#4,d1
		dbf	d3,.loop5
		sub.l	#15,d1
		dbf	d2,.loop4
		add.l	#12,d1
		dbf	d0,.loop3

		rts

; macros for 1x8 and 1x6 routines
; merge \1,\2, d6/d7 are scratch, \3 = mask, \4 = shift

merge1		macro
		move.l	\1,d6
		and.l	#\3,\1
		eor.l	\1,d6
		move.l	\2,d7
		endm

merge2		macro
		and.l	#\3,d7
		eor.l	d7,\2
		lsr.l	#\4,d7
		endm

merge3		macro
		ifeq	\4-1
		add.l	d6,d6
		else
		lsl.l	#\4,d6
		endc
		or.l	d7,\1
		or.l	d6,\2
		endm

merge		macro
		merge1	\1,\2,\3,\4
		merge2	\1,\2,\3,\4
		merge3	\1,\2,\3,\4
		endm

		cnop	0,8
doc2p_1X8
; inputs:
; a0.l=src chunky buffer
; a1.l=dest chipmem bitmap
; d0.w=width (in pixels - multiple of 32) to convert
; d1.w=height (in pixels - even)
; d2.l=modulo from one bitplane to next (copmod-ish)
; d3.l=modulo from start of one line to start of next (linemod)

; internal:
; a2=bitplane modulo, 1 bp to next
; d6/d7 used as scratch by merge macro

		suba.w	#32,sp
		movea.l d2,a2		; a2 = bpmod
		move.l	d2,d4
		lsl.l	#3,d4
		sub.l	d2,d4		; d4 = 7 * bpmod
		adda.l	d4,a1		; a1 -> plane 7

		addq.l	#4,d4
		movea.l d4,a5		; a5 = 7 * bpmod + 4
		move.l	a5,-(sp)	; (8,sp) = 7 * bpmod + 4

		move.w	d0,d4
		lsr.w	#5,d4		; d4 = num 32 pix per row
		subq.w	#1,d4
		ext.l	d4
		move.l	d4,-(sp)	; (4,sp) = num 32 pix per row - 1

		lsr.w	#3,d0		; num 8 pix per row (bytesperrow)
		ext.l	d0
		sub.l	d0,d3		; linemod - bytesperrow
		add.l	a5,d3
		move.l	d3,-(sp)	; (sp) = linemod-bytesperrow+7*bpmod+4

		move.w	d1,d7
		subq.w	#1,d7		; d7 = height - 1

;------------------------------------------------------------------------
;
; Original pixels
;00	   a7a6a5a4a3a2a1a0 i7i6i5i4i3i2i1i0 q7q6q5q4q3q2q1q0 y7y6y5y4y3y2y1y0
;01	   b7b6b5b4b3b2b1b0 j7j6j5j4j3j2j1j0 r7r6r5r4r3r2r1r0 z7z6z5z4z3z2z1z0
;02	   c7c6c5c4c3c2c1c0 k7k6k5k4k3k2k1k0 s7s6s5s4s3s2s1s0 A7A6A5A4A3A2A1A0
;03	   d7d6d5d4d3d2d1d0 l7l6l5l4l3l2l1l0 t7t6t5t4t3t2t1t0 B7B6B5B4B3B2B1B0
;04	   e7e6e5e4e3e2e1e0 m7m6m5m4m3m2m1m0 u7u6u5u4u3u2u1u0 C7C6C5C4C3C2C1C0
;05	   f7f6f5f4f3f2f1f0 n7n6n5n4n3n2n1n0 v7v6v5v4v3v2v1v0 D7D6D5D4D3D2D1D0
;06	   g7g6g5g4g3g2g1g0 o7o6o5o4o3o2o1o0 w7w6w5w4w3w2w1w0 E7E6E5E4E3E2E1E0
;07	   h7h6h5h4h3h2h1h0 p7p6p5p4p3p2p1p0 x7x6x5x4x3x2x1x0 F7F6F5F4F3F2F1F0
;
; After 4bit merge
;10=00x04a a7a6a5a4e7e6e5e4 i7i6i5i4m7m6m5m4 q7q6q5q4u7u6u5u4 y7y6y5y4C7C6C5C4
;11=00x04b a3a2a1a0e3e2e1e0 i3i2i1i0m3m2m1m0 q3q2q1q0u3u2u1u0 y3y2y1y0C3C2C1C0
;12=01x05a b7b6b5b4f7f6f5f4 j7j6j5j4n7n6n5n4 r7r6r5r4v7v6v5v4 z7z6z5z4D7D6D5D4
;13=01x05b b3b2b1b0f3f2f1f0 j3j2j1j0n3n2n1n0 r3r2r1r0v3v2v1v0 z3z2z1z0D3D2D1D0
;14=02x06a c7c6c5c4g7g6g5g4 k7k6k5k4o7o6o5o4 s7s6s5s4w7w6w5w4 A7A6A5A4E7E6E5E4
;15=02x06b c3c2c1c0g3g2g1g0 k3k2k1k0o3o2o1o0 s3s2s1s0w3w2w1w0 A3A2A1A0E3E2E1E0
;16=03x07a d7d6d5d4h7h6h5h4 l7l6l5l4p7p6p5p4 t7t6t5t4x7x6x5x4 B7B6B5B4F7F6F5F4
;17=03x07b d3d2d1d0h3h2h1h0 l3l2l1l0p3p2p1p0 t3t2t1t0x3x2x1x0 B3B2B1B0F3F2F1F0
;
; After 2bit merge
;20=10x14a a7a6c7c6e7e6g7g6 i7i6k7k6m7m6o7o6 q7q6s7s6u7u6w7w6 y7y6A7A6C7C6E7E6
;21=10x14b a5a4c5c4e5e4g5g4 i5i4k5k4m5m4o5o4 q5q4s5s4u5u4w5w4 y5y4A5A4C5C4E5E4
;22=11x15a a3a2c3c2e3e2g3g2 i3i2k3k2m3m2o3o2 q3q2s3s2u3u2w3w2 y3y2A3A2C3C2E3E2
;23=11x15b a1a0c1c0e1e0g1g0 i1i0k1k0m1m0o1o0 q1q0s1s0u1u0w1w0 y1y0A1A0C1C0E1E0
;24=12x16a b7b6d7d6f7f6h7h6 j7j6l7l6n7n6p7p6 r7r6t7t6v7v6x7x6 z7z6B7B6D7D6F7F6
;25=12x16b b5b4d5d4f5f4h5h4 j5j4l5l4n5n4p5p4 r5r4t5t4v5v4x5x4 z5z4B5B4D5D4F5F4
;26=13x17a b3b2d3d2f3f2h3h2 j3j2l3l2n3n2p3p2 r3r2t3t2v3v2x3x2 z3z2B3B2D3D2F3F2
;27=13x17b b1b0d1d0f1f0h1h0 j1j0l1l0n1n0p1p0 r1r0t1t0v1v0x1x0 z1z0B1B0D1D0F1F0
;
; After 1bit merge
;30=20x24a a7b7c7d7e7f7g7h7 i7j7k7l7m7n7o7p7 q7r7s7t7u7v7w7x7 y7z7A7B7C7D7E7F7
;31=20x24b a6b6c6d6e6f6g6h6 i6j6k6l6m6n6o6p6 q6r6s6t6u6v6w6x6 y6z6A6B6C6D6E6F6
;32=21x25a a5b5c5d5e5f5g5h5 i5j5k5l5m5n5o5p5 q5r5s5t5u5v5w5x5 y5z5A5B5C5D5E5F5
;33=21x25b a4b4c4d4e4f4g4h4 i4j4k4l4m4n4o4p4 q4r4s4t4u4v4w4x4 y4z4A4B4C4D4E4F4
;34=22x26a a3b3c3d3e3f3g3h3 i3j3k3l3m3n3o3p3 q3r3s3t3u3v3w3x3 y3z3A3B3C3D3E3F3
;35=22x26b a2b2c2d2e2f2g2h2 i2j2k2l2m2n2o2p2 q2r2s2t2u2v2w2x2 y2z2A2B2C2D2E2F2
;36=23x27a a1b1c1d1e1f1g1h1 i1j1k1l1m1n1o1p1 q1r1s1t1u1v1w1x1 y1z1A1B1C1D1E1F1
;37=23x27b a0b0c0d0e0f0g0h0 i0j0k0l0m0n0o0p0 q0r0s0t0u0v0w0x0 y0z0A0B0C0D0E0F0
;
;------------------------------------------------------------------------

		swap	d7
		move.w	d4,d7			; number of 32 pixels per row - 1

		exg	d7,a6

		movem.l (a0)+,d0-d5/a3-a4	; read first 32 pixels into regs

		merge	d0,d4,$f0f0f0f0,4	; 00x04 -> 10 11
		merge	d1,d5,$f0f0f0f0,4	; 01x05 -> 12 13
		exg	d1,a3
		exg	d5,a4
		merge	d2,d1,$f0f0f0f0,4	; 02x06 -> 14 15
		merge	d3,d5,$f0f0f0f0,4	; 03x07 -> 16 17

		merge	d0,d2,$cccccccc,2	; 10x14 -> 20 21
		merge	d4,d1,$cccccccc,2	; 11x15 -> 22 23
		exg	d4,a3
		exg	d1,a4
		merge	d4,d3,$cccccccc,2	; 12x16 -> 24 25
		merge	d1,d5,$cccccccc,2	; 13x17 -> 26 27

		merge	d0,d4,$aaaaaaaa,1	; 20x24 -> 30 31
		merge	d2,d3,$aaaaaaaa,1	; 21x25 -> 32 33
		exg	d2,a3
		exg	d3,a4
		merge	d2,d1,$aaaaaaaa,1	; 22x26 -> 34 35

		bra	.same_from_here

		cnop	0,8

.outerloop	swap	d7
		move.w	(6,sp),d7	; number of 32 pixels per row - 1

.innerloop	exg	d7,a6

		move.l	(a0)+,d0	; next 4 pixels
		move.l	(a0)+,d1	; next 4 pixels
		move.l	(a0)+,d2	; next 4 pixels
		move.l	(a0)+,d3	; next 4 pixels
		move.l	(a0)+,d4	; next 4 pixels
		move.l	(a0)+,d5	; next 4 pixels
		move.l	(a0)+,a3	; next 4 pixels
		move.l	(a0)+,a4	; next 4 pixels

		move.l	(6*4+12,sp),(a1)	; plane 6
		suba.l	a2,a1			; -bpmod

		merge	d0,d4,$f0f0f0f0,4	; 00x04 -> 10 11
		merge	d1,d5,$f0f0f0f0,4	; 01x05 -> 12 13

		exg	d1,a3
		exg	d5,a4

		move.l	(5*4+12,sp),(a1)	; plane 5
		suba.l	a2,a1			; -bpmod

		merge	d2,d1,$f0f0f0f0,4	; 02x06 -> 14 15
		merge	d3,d5,$f0f0f0f0,4	; 03x07 -> 16 17
		merge1	d0,d2,$cccccccc,2	; 10x14 -> 20 21
		merge2	d0,d2,$cccccccc,2	; 10x14 -> 20 21

		move.l	(4*4+12,sp),(a1)	; plane 4
		suba.l	a2,a1			; -bpmod

		merge3	d0,d2,$cccccccc,2	; 10x14 -> 20 21
		merge	d4,d1,$cccccccc,2	; 11x15 -> 22 23
		exg	d4,a3
		exg	d1,a4
		merge	d4,d3,$cccccccc,2	; 12x16 -> 24 25

		move.l	(3*4+12,sp),(a1)	; plane 3
		suba.l	a2,a1			; -bpmod

		merge1	d1,d5,$cccccccc,2	; 13x17 -> 26 27
		merge2	d1,d5,$cccccccc,2	; 13x17 -> 26 27
		merge3	d1,d5,$cccccccc,2	; 13x17 -> 26 27
		merge	d0,d4,$aaaaaaaa,1	; 20x24 -> 30 31

		move.l	(2*4+12,sp),(a1)	; plane 2
		suba.l	a2,a1			; -bpmod

		merge	d2,d3,$aaaaaaaa,1	; 21x25 -> 32 33
		exg	d2,a3
		exg	d3,a4
		merge1	d2,d1,$aaaaaaaa,1	; 22x26 -> 34 35
		merge2	d2,d1,$aaaaaaaa,1	; 22x26 -> 34 35

		move.l	(1*4+12,sp),(a1)	; plane 1
		suba.l	a2,a1			; -bpmod

		merge3	d2,d1,$aaaaaaaa,1	; 22x26 -> 34 35

		move.l	(0*4+12,sp),(a1)	; plane 0
		adda.l	a5,a1			; {dest skip}+7*bpmod+4
		move.l	(8,sp),a5		; a5 = 7*bpmod+4

.same_from_here merge	d3,d5,$aaaaaaaa,1	; 23x27 -> 36 37

		move.l	d5,(0*4+12,sp)		; 37 -> plane 0 buffer
		move.l	d3,(1*4+12,sp)		; 36 -> plane 1 buffer
		move.l	d1,(2*4+12,sp)		; 35 -> plane 2 buffer
		move.l	d2,(3*4+12,sp)		; 34 -> plane 3 buffer
		move.l	a4,(4*4+12,sp)		; 33 -> plane 4 buffer
		move.l	a3,(5*4+12,sp)		; 32 -> plane 5 buffer
		move.l	d4,(6*4+12,sp)		; 31 -> plane 6 buffer
		move.l	d0,(a1) 		; 30 -> plane 7
		suba.l	a2,a1

		exg	a6,d7
		dbra	d7,.innerloop

		move.l	(sp),a5 	; a5 = dest skip + 7 * bpmod + 4

		swap	d7
		dbra	d7,.outerloop

		move.l	(6*4+12,sp),(a1)	; plane 6
		suba.l	a2,a1			; -bpmod
		move.l	(5*4+12,sp),(a1)	; plane 5
		suba.l	a2,a1			; -bpmod
		move.l	(4*4+12,sp),(a1)	; plane 4
		suba.l	a2,a1			; -bpmod
		move.l	(3*4+12,sp),(a1)	; plane 3
		suba.l	a2,a1			; -bpmod
		move.l	(2*4+12,sp),(a1)	; plane 2
		suba.l	a2,a1			; -bpmod
		move.l	(1*4+12,sp),(a1)	; plane 1
		suba.l	a2,a1			; -bpmod
		move.l	(0*4+12,sp),(a1)	; plane 0
		adda.w	#12+32,sp
		rts

		cnop	0,8
doc2p_1X6
; inputs:
; a0.l=src chunky buffer
; a1.l=dest chipmem bitmap
; d0.w=width (in pixels - multiple of 32) to convert
; d1.w=height (in pixels - even)
; d2.l=modulo from one bitplane to next (copmod-ish)
; d3.l=modulo from start of one line to start of next (linemod)

; internal:
; a2=bitplane modulo, 1 bp to next
; d6/d7 used as scratch by merge macro

		suba.w	#32,sp
		movea.l d2,a2		; a2 = bpmod
		move.l	d2,d4
		lsl.l	#2,d4
		add.l	d2,d4		; d4 = 5 * bpmod
		adda.l	d4,a1		; a1 -> plane 5

		addq.l	#4,d4
		movea.l d4,a5		; a5 = 5 * bpmod + 4
		move.l	a5,-(sp)	; (8,sp) = 5 * bpmod + 4

		move.w	d0,d4
		lsr.w	#5,d4		; d4 = num 32 pix per row
		subq.w	#1,d4
		ext.l	d4
		move.l	d4,-(sp)	; (4,sp) = num 32 pix per row - 1

		lsr.w	#3,d0		; num 8 pix per row (bytesperrow)
		ext.l	d0
		sub.l	d0,d3		; linemod - bytesperrow
		add.l	a5,d3
		move.l	d3,-(sp)	; (sp) = linemod-bytesperrow+5*bpmod+4

		move.w	d1,d7
		subq.w	#1,d7		; d7 = height - 1

;------------------------------------------------------------------------
;
; Original pixels
;00	   ....a5a4a3a2a1a0 ....i5i4i3i2i1i0 ....q5q4q3q2q1q0 ....y5y4y3y2y1y0
;01	   ....b5b4b3b2b1b0 ....j5j4j3j2j1j0 ....r5r4r3r2r1r0 ....z5z4z3z2z1z0
;02	   ....c5c4c3c2c1c0 ....k5k4k3k2k1k0 ....s5s4s3s2s1s0 ....A5A4A3A2A1A0
;03	   ....d5d4d3d2d1d0 ....l5l4l3l2l1l0 ....t5t4t3t2t1t0 ....B5B4B3B2B1B0
;04	   ....e5e4e3e2e1e0 ....m5m4m3m2m1m0 ....u5u4u3u2u1u0 ....C5C4C3C2C1C0
;05	   ....f5f4f3f2f1f0 ....n5n4n3n2n1n0 ....v5v4v3v2v1v0 ....D5D4D3D2D1D0
;06	   ....g5g4g3g2g1g0 ....o5o4o3o2o1o0 ....w5w4w3w2w1w0 ....E5E4E3E2E1E0
;07	   ....h5h4h3h2h1h0 ....p5p4p3p2p1p0 ....x5x4x3x2x1x0 ....F5F4F3F2F1F0
;
; After 4bit merge
;10=00x04a ....a5a4....e5e4 ....i5i4....m5m4 ....q5q4....u5u4 ....y5y4....C5C4
;11=00x04b a3a2a1a0e3e2e1e0 i3i2i1i0m3m2m1m0 q3q2q1q0u3u2u1u0 y3y2y1y0C3C2C1C0
;12=01x05a ....b5b4....f5f4 ....j5j4....n5n4 ....r5r4....v5v4 ....z5z4....D5D4
;13=01x05b b3b2b1b0f3f2f1f0 j3j2j1j0n3n2n1n0 r3r2r1r0v3v2v1v0 z3z2z1z0D3D2D1D0
;14=02x06a ....c5c4....g5g4 ....k5k4....o5o4 ....s5s4....w5w4 ....A5A4....E5E4
;15=02x06b c3c2c1c0g3g2g1g0 k3k2k1k0o3o2o1o0 s3s2s1s0w3w2w1w0 A3A2A1A0E3E2E1E0
;16=03x07a ....d5d4....h5h4 ....l5l4....p5p4 ....t5t4....x5x4 ....B5B4....F5F4
;17=03x07b d3d2d1d0h3h2h1h0 l3l2l1l0p3p2p1p0 t3t2t1t0x3x2x1x0 B3B2B1B0F3F2F1F0
;
; After 2bit merge
;21=10x14b a5a4c5c4e5e4g5g4 i5i4k5k4m5m4o5o4 q5q4s5s4u5u4w5w4 y5y4A5A4C5C4E5E4
;22=11x15a a3a2c3c2e3e2g3g2 i3i2k3k2m3m2o3o2 q3q2s3s2u3u2w3w2 y3y2A3A2C3C2E3E2
;23=11x15b a1a0c1c0e1e0g1g0 i1i0k1k0m1m0o1o0 q1q0s1s0u1u0w1w0 y1y0A1A0C1C0E1E0
;25=12x16b b5b4d5d4f5f4h5h4 j5j4l5l4n5n4p5p4 r5r4t5t4v5v4x5x4 z5z4B5B4D5D4F5F4
;26=13x17a b3b2d3d2f3f2h3h2 j3j2l3l2n3n2p3p2 r3r2t3t2v3v2x3x2 z3z2B3B2D3D2F3F2
;27=13x17b b1b0d1d0f1f0h1h0 j1j0l1l0n1n0p1p0 r1r0t1t0v1v0x1x0 z1z0B1B0D1D0F1F0
;
; After 1bit merge
;32=21x25a a5b5c5d5e5f5g5h5 i5j5k5l5m5n5o5p5 q5r5s5t5u5v5w5x5 y5z5A5B5C5D5E5F5
;33=21x25b a4b4c4d4e4f4g4h4 i4j4k4l4m4n4o4p4 q4r4s4t4u4v4w4x4 y4z4A4B4C4D4E4F4
;34=22x26a a3b3c3d3e3f3g3h3 i3j3k3l3m3n3o3p3 q3r3s3t3u3v3w3x3 y3z3A3B3C3D3E3F3
;35=22x26b a2b2c2d2e2f2g2h2 i2j2k2l2m2n2o2p2 q2r2s2t2u2v2w2x2 y2z2A2B2C2D2E2F2
;36=23x27a a1b1c1d1e1f1g1h1 i1j1k1l1m1n1o1p1 q1r1s1t1u1v1w1x1 y1z1A1B1C1D1E1F1
;37=23x27b a0b0c0d0e0f0g0h0 i0j0k0l0m0n0o0p0 q0r0s0t0u0v0w0x0 y0z0A0B0C0D0E0F0
;
;------------------------------------------------------------------------

		swap	d7
		move.w	d4,d7			; number of 32 pixels per row - 1

		exg	d7,a6

		movem.l (a0)+,d0-d5/a3-a4	; read first 32 pixels into regs

		merge	d0,d4,$f0f0f0f0,4	; 00x04 -> 10 11
		merge	d1,d5,$f0f0f0f0,4	; 01x05 -> 12 13
		exg	d1,a3
		exg	d5,a4
		merge	d2,d1,$f0f0f0f0,4	; 02x06 -> 14 15
		merge	d3,d5,$f0f0f0f0,4	; 03x07 -> 16 17

		lsl.l	#2,d0
		or.l	d0,d2			; 10x14 ->    21
		merge	d4,d1,$cccccccc,2	; 11x15 -> 22 23
		exg	d4,a3
		exg	d1,a4
		lsl.l	#2,d4
		or.l	d4,d3			; 12x16 ->    25
		merge	d1,d5,$cccccccc,2	; 13x17 -> 26 27

		merge	d2,d3,$aaaaaaaa,1	; 21x25 -> 32 33
		exg	d2,a3
		exg	d3,a4
		merge	d2,d1,$aaaaaaaa,1	; 22x26 -> 34 35
		merge	d3,d5,$aaaaaaaa,1	; 23x27 -> 36 37

		bra	.same_from_here

		cnop	0,8

.outerloop	swap	d7
		move.w	(6,sp),d7	; number of 32 pixels per row - 1

.innerloop	exg	d7,a6

		move.l	(a0)+,d0	; next 4 pixels
		move.l	(a0)+,d1	; next 4 pixels
		move.l	(a0)+,d2	; next 4 pixels
		move.l	(a0)+,d3	; next 4 pixels
		move.l	(a0)+,d4	; next 4 pixels
		move.l	(a0)+,d5	; next 4 pixels
		move.l	(a0)+,a3	; next 4 pixels
		move.l	(a0)+,a4	; next 4 pixels

		move.l	(4*4+12,sp),(a1)	; plane 4
		suba.l	a2,a1			; -bpmod

		merge	d0,d4,$f0f0f0f0,4	; 00x04 -> 10 11
		merge	d1,d5,$f0f0f0f0,4	; 01x05 -> 12 13

		move.l	(3*4+12,sp),(a1)	; plane 3
		suba.l	a2,a1			; -bpmod

		exg	d1,a3
		exg	d5,a4
		merge	d2,d1,$f0f0f0f0,4	; 02x06 -> 14 15
		merge	d3,d5,$f0f0f0f0,4	; 03x07 -> 16 17
		lsl.l	#2,d0
		or.l	d0,d2			; 10x14 ->    21

		move.l	(2*4+12,sp),(a1)	; plane 2
		suba.l	a2,a1			; -bpmod

		merge	d4,d1,$cccccccc,2	; 11x15 -> 22 23
		exg	d4,a3
		exg	d1,a4
		lsl.l	#2,d4
		or.l	d4,d3			; 12x16 ->    25

		move.l	(1*4+12,sp),(a1)	; plane 1
		suba.l	a2,a1			; -bpmod

		merge	d1,d5,$cccccccc,2	; 13x17 -> 26 27
		merge	d2,d3,$aaaaaaaa,1	; 21x25 -> 32 33
		exg	d2,a3
		exg	d3,a4

		move.l	(0*4+12,sp),(a1)	; plane 0
		adda.l	a5,a1			; {dest skip}+5*bpmod+4

		merge	d2,d1,$aaaaaaaa,1	; 22x26 -> 34 35
		merge	d3,d5,$aaaaaaaa,1	; 23x27 -> 36 37

		move.l	(8,sp),a5		; a5 = 5*bpmod+4

.same_from_here move.l	d5,(0*4+12,sp)		; 37 -> plane 0 buffer
		move.l	d3,(1*4+12,sp)		; 36 -> plane 1 buffer
		move.l	d1,(2*4+12,sp)		; 35 -> plane 2 buffer
		move.l	d2,(3*4+12,sp)		; 34 -> plane 3 buffer
		move.l	a4,(4*4+12,sp)		; 33 -> plane 4 buffer
		move.l	a3,(a1) 		; 32 -> plane 5
		suba.l	a2,a1

		exg	a6,d7
		dbra	d7,.innerloop

		move.l	(sp),a5 	; a5 = dest skip + 5 * bpmod + 4

		swap	d7
		dbra	d7,.outerloop

		move.l	(4*4+12,sp),(a1)	; plane 4
		suba.l	a2,a1			; -bpmod
		move.l	(3*4+12,sp),(a1)	; plane 3
		suba.l	a2,a1			; -bpmod
		move.l	(2*4+12,sp),(a1)	; plane 2
		suba.l	a2,a1			; -bpmod
		move.l	(1*4+12,sp),(a1)	; plane 1
		suba.l	a2,a1			; -bpmod
		move.l	(0*4+12,sp),(a1)	; plane 0
		adda.w	#12+32,sp
		rts

		cnop	0,8
doc2p_2X8
; inputs:
; a0.l=src chunky buffer
; a1.l=dest chipmem bitmap
; d0.w=width (in pixels - multiple of 32) to convert
; d1.w=height (in pixels - even)
; d2.l=modulo from one bitplane to next (copmod-ish)
; d3.l=modulo from start of one line to start of next (linemod)

; Pipelined without fastmem buffers

		movea.l d2,a6		; a6 = bpmod
		move.l	d2,d4
		lsl.l	#3,d4
		sub.l	d2,d4
		neg.l	d4
		addq.l	#4,d4
		movea.l d4,a3		; a3 = -7*bpmod+4
		movea.l d4,a4		; a4 = -7*bpmod+4
		lsr.w	#4,d0
		movea.w d0,a2
		subq.l	#1,a2		; a2 = num 16 pix per row - 1
		lsl.w	#2,d0		; d0 = num 4 pix per row (bytesperrow)
		movea.l d3,a5
		suba.w	d0,a5
		adda.l	a3,a5		; a5 = linemod-bytesperrow-7*bpmod+4
		move.w	d1,d7
		subq.w	#1,d7		; d7 = height - 1

;------------------------------------------------------------------------
; original pixels
; 00	    a7a6a5a4a3a2a1a0 e7e6e5e4e3e2e1e0 i7i6i5i4i3i2i1i0 m7m6m5m4m3m2m1m0
; 01	    b7b6b5b4b3b2b1b0 f7f6f5f4f3f2f1f0 j7j6j5j4j3j2j1j0 n7n6n5n4n3n2n1n0
; 02	    c7c6c5c4c3c2c1c0 g7g6g5g4g3g2g1g0 k7k6k5k4k3k2k1k0 o7o6o5o4o3o2o1o0
; 03	    d7d6d5d4d3d2d1d0 h7h6h5h4h3h2h1h0 l7l6l5l4l3l2l1l0 p7p6p5p4p3p2p1p0
;
; after 4bit merge
; 10 00x02a a7a6a5a4c7c6c5c4 e7e6e5e4g7g6g5g4 i7i6i5i4k7k6k5k4 m7m6m5m4o7o6o5o4
; 11 00x02b a3a2a1a0c3c2c1c0 e3e2e1e0g3g2g1g0 i3i2i1i0k3k2k1k0 m3m2m1m0o3o2o1o0
; 12 01x03a b7b6b5b4d7d6d5d4 f7f6f5f4h7h6h5h4 j7j6j5j4l7l6l5l4 n7n6n5n4p7p6p5p4
; 13 01x03b b3b2b1b0d3d2d1d0 f3f2f1f0h3h2h1h0 j3j2j1j0l3l2l1l0 n3n2n1n0p3p2p1p0
;
; after 2bit merge
; 20 10x12a a7a6b7b6c7c6d7d6 e7e6f7f6g7g6h7h6 i7i6j7j6k7k6l7l6 m7m6n7n6o7o6p7p6
; 21 10x12b a5a4b5b4c5c4d5d4 e5e4f5f4g5g4h5h4 i5i4j5j4k5k4l5l4 m5m4n5n4o5o4p5p4
; 22 11x13a a3a2b3b2c3c2d3d2 e3e2f3f2g3g2h3h2 i3i2j3j2k3k2l3l2 m3m2n3n2o3o2p3p2
; 23 11x13b a1a0b1b0c1c0d1d0 e1e0f1f0g1g0h1h0 i1i0j1j0k1k0l1l0 m1m0n1n0o1o0p1p0
;
; after 1bit merge
; 30 20x20a a7a7b7b7c7c7d7d7 e7e7f7f7g7g7h7h7 i7i7j7j7k7k7l7l7 m7m7n7n7o7o7p7p7
; 31 20x20b a6a6b6b6c6c6d6d6 e6e6f6f6g6g6h6h6 i6i6j6j6k6k6l6l6 m6m6n6n6o6o6p6p6
; 32 21x21a a5a5b5b5c5c5d5d5 e5e5f5f5g5g5h5h5 i5i5j5j5k5k5l5l5 m5m5n5n5o5o5p5p5
; 33 21x21b a4a4b4b4c4c4d4d4 e4e4f4f4g4g4h4h4 i4i4j4j4k4k4l4l4 m4m4n4n4o4o4p4p4
; 34 22x22a a3a3b3b3c3c3d3d3 e3e3f3f3g3g3h3h3 i3i3j3j3k3k3l3l3 m3m3n3n3o3o3p3p3
; 35 22x22b a2a2b2b2c2c2d2d2 e2e2f2f2g2g2h2h2 i2i2j2j2k2k2l2l2 m2m2n2n2o2o2p2p2
; 36 23x23a a1a1b1b1c1c1d1d1 e1e1f1f1g1g1h1h1 i1i1j1j1k1k1l1l1 m1m1n1n1o1o1p1p1
; 37 23x23b a0a0b0b0c0c0d0d0 e0e0f0f0g0g0h0h0 i0i0j0j0k0k0l0l0 m0m0n0n0o0o0p0p0
;------------------------------------------------------------------------

		swap	d7
		move.w	a2,d7		; number of 16 (game) pixels per row - 1

		move.l	(a0)+,d0	; read first 4 (game) pixels
		move.l	(a0)+,d1	; read first 4 (game) pixels
		move.l	(a0)+,d2	; read first 4 (game) pixels

		move.l	d0,d4
		move.l	d2,d5

		and.l	#$f0f0f0f0,d0		; $f0f0f0f0
		eor.l	d0,d4
		lsl.l	#4,d4
		and.l	#$f0f0f0f0,d5		; $f0f0f0f0
		eor.l	d5,d2
		lsr.l	#4,d5
		or.l	d5,d0

		or.l	d4,d2		; 00x02 -> 10 11
		move.l	d1,d4
		and.l	#$f0f0f0f0,d1
		eor.l	d1,d4
		lsl.l	#4,d4

		move.l	(a0)+,d3	; read next 4 (game) pixels

		move.l	d3,d5
		and.l	#$f0f0f0f0,d5
		eor.l	d5,d3
		lsr.l	#4,d5
		or.l	d5,d1
		or.l	d4,d3		; 01x03 -> 12 13

		move.l	d0,d4
		and.l	#$cccccccc,d0
		eor.l	d0,d4
		lsl.l	#2,d4
		move.l	d1,d5
		and.l	#$cccccccc,d5
		eor.l	d5,d1
		lsr.l	#2,d5
		or.l	d5,d0
		or.l	d4,d1		; 10x12 -> 20 21

		bra	.same_from_here

		cnop	0,8

.outerloop	swap	d7
		move.w	a2,d7		; number of 16 (game) pixels per row - 1

.innerloop	move.l	(a0)+,d0	; read next 4 (game) pixels
		move.l	(a0)+,d1	; read next 4 (game) pixels
		move.l	(a0)+,d2	; read next 4 (game) pixels

		move.l	d4,(a1) 	; 32 -> plane 5
		adda.l	a6,a1		; +bpmod

		move.l	d0,d4
		and.l	#$f0f0f0f0,d0
		eor.l	d0,d4
		lsl.l	#4,d4
		move.l	d2,d5
		and.l	#$f0f0f0f0,d5
		eor.l	d5,d2
		lsr.l	#4,d5
		or.l	d5,d0
		or.l	d4,d2		; 00x02 -> 10 11
		move.l	d1,d4
		and.l	#$f0f0f0f0,d1
		eor.l	d1,d4
		lsl.l	#4,d4


		move.l	d3,(a1) 	; 31 -> plane 6
		adda.l	a6,a1		; +bpmod

		move.l	(a0)+,d3	; read next 4 (game) pixels

		move.l	d3,d5
		and.l	#$f0f0f0f0,d5
		eor.l	d5,d3
		lsr.l	#4,d5
		or.l	d5,d1
		or.l	d4,d3		; 01x03 -> 12 13

		move.l	d0,d4
		and.l	#$cccccccc,d0
		eor.l	d0,d4
		lsl.l	#2,d4
		move.l	d1,d5
		and.l	#$cccccccc,d5
		eor.l	d5,d1
		lsr.l	#2,d5
		or.l	d5,d0
		or.l	d4,d1		; 10x12 -> 20 21

		move.l	d6,(a1) 	; 30 -> plane 7
		adda.l	a4,a1		; -7*bpmod+4 or
					; +linemod-bytesperrow-7*bpmod+4

.same_from_here move.l	d2,d4
		and.l	#$cccccccc,d2
		eor.l	d2,d4
		lsl.l	#2,d4
		move.l	d3,d5
		and.l	#$cccccccc,d5
		eor.l	d5,d3
		lsr.l	#2,d5
		or.l	d5,d2
		or.l	d4,d3		; 11x13 -> 22 23

		move.l	d3,d4
		and.l	#$aaaaaaaa,d3
		eor.l	d3,d4

		move.l	d4,d5
		add.l	d4,d4
		or.l	d4,d5		; 23x23b -> 37

		move.l	d5,(a1) 	; 37 -> plane 0
		adda.l	a6,a1		; +bpmod

		move.l	d3,d4
		lsr.l	#1,d3
		or.l	d3,d4		; 23x23a -> 36
		move.l	d2,d5
		and.l	#$aaaaaaaa,d2
		eor.l	d2,d5

		move.l	d4,(a1) 	; 36 -> plane 1
		adda.l	a6,a1		; +bpmod

		move.l	d5,d3
		add.l	d5,d5
		or.l	d5,d3		; 22x22b -> 35
		move.l	d2,d5
		lsr.l	#1,d2
		or.l	d2,d5		; 22x22a -> 34

		move.l	d3,(a1) 	; 35 -> plane 2
		adda.l	a6,a1		; +bpmod

		move.l	d1,d4
		and.l	#$aaaaaaaa,d1
		eor.l	d1,d4
		move.l	d4,d2
		add.l	d4,d4
		or.l	d4,d2		; 21x21b -> 33
		move.l	d1,d4

		move.l	d5,(a1) 	; 34 -> plane 3
		adda.l	a6,a1		; +bpmod

		lsr.l	#1,d1
		or.l	d1,d4		; 21x21a -> 32
		move.l	d0,d3
		and.l	#$aaaaaaaa,d0
		eor.l	d0,d3
		move.l	d3,d6

		move.l	d2,(a1) 	; 33 -> plane 4
		adda.l	a6,a1		; +bpmod

		add.l	d3,d3
		or.l	d6,d3		; 20x20b -> 31
		move.l	d0,d6
		lsr.l	#1,d0
		or.l	d0,d6		; 20x20a -> 30

		movea.l a3,a4		; a4 = -7*bpmod+4

		dbra	d7,.innerloop

		movea.l a5,a4		; a4 = linemod-bytesperrow-7*bpmod+4

		swap	d7
		dbra	d7,.outerloop

		move.l	d4,(a1) 	; 32 -> plane 5
		adda.l	a6,a1		; +bpmod
		move.l	d3,(a1) 	; 31 -> plane 6
		adda.l	a6,a1		; +bpmod
		move.l	d6,(a1) 	; 30 -> plane 7
		rts

		cnop	0,8
doc2p_2X6
; inputs:
; a0.l=src chunky buffer
; a1.l=dest chipmem bitmap
; d0.w=width (in pixels - multiple of 32) to convert
; d1.w=height (in pixels - even)
; d2.l=modulo from one bitplane to next (copmod-ish)
; d3.l=modulo from start of one line to start of next (linemod)

; Pipelined without fastmem buffers

		movea.l d2,a6		; a6 = bpmod
		move.l	d2,d4
		lsl.l	#2,d4
		add.l	d2,d4
		neg.l	d4
		addq.l	#4,d4
		movea.l d4,a3		; a3 = -5*bpmod+4
		movea.l d4,a4		; a4 = -5*bpmod+4
		lsr.w	#4,d0
		movea.w d0,a2
		subq.l	#1,a2		; a2 = num 16 pix per row - 1
		lsl.w	#2,d0		; d0 = num 4 pix per row (bytesperrow)
		movea.l d3,a5
		suba.w	d0,a5
		adda.l	a3,a5		; a5 = linemod-bytesperrow-5*bpmod+4
		move.w	d1,d7
		subq.w	#1,d7		; d7 = height - 1

;------------------------------------------------------------------------
; original pixels
; 00	    ....a5a4a3a2a1a0 ....e5e4e3e2e1e0 ....i5i4i3i2i1i0 ....m5m4m3m2m1m0
; 01	    ....b5b4b3b2b1b0 ....f5f4f3f2f1f0 ....j5j4j3j2j1j0 ....n5n4n3n2n1n0
; 02	    ....c5c4c3c2c1c0 ....g5g4g3g2g1g0 ....k5k4k3k2k1k0 ....o5o4o3o2o1o0
; 03	    ....d5d4d3d2d1d0 ....h5h4h3h2h1h0 ....l5l4l3l2l1l0 ....p5p4p3p2p1p0
;
; after 4bit merge
; 10 00x02a ....a5a4....c5c4 ....e5e4....g5g4 ....i5i4....k5k4 ....m5m4....o5o4
; 11 00x02b a3a2a1a0c3c2c1c0 e3e2e1e0g3g2g1g0 i3i2i1i0k3k2k1k0 m3m2m1m0o3o2o1o0
; 12 01x03a ....b5b4....d5d4 ....f5f4....h5h4 ....j5j4....l5l4 ....n5n4....p5p4
; 13 01x03b b3b2b1b0d3d2d1d0 f3f2f1f0h3h2h1h0 j3j2j1j0l3l2l1l0 n3n2n1n0p3p2p1p0
;
; after 2bit merge
; 21 10x12b a5a4b5b4c5c4d5d4 e5e4f5f4g5g4h5h4 i5i4j5j4k5k4l5l4 m5m4n5n4o5o4p5p4
; 22 11x13a a3a2b3b2c3c2d3d2 e3e2f3f2g3g2h3h2 i3i2j3j2k3k2l3l2 m3m2n3n2o3o2p3p2
; 23 11x13b a1a0b1b0c1c0d1d0 e1e0f1f0g1g0h1h0 i1i0j1j0k1k0l1l0 m1m0n1n0o1o0p1p0
;
; after 1bit merge
; 32 21x21a a5a5b5b5c5c5d5d5 e5e5f5f5g5g5h5h5 i5i5j5j5k5k5l5l5 m5m5n5n5o5o5p5p5
; 33 21x21b a4a4b4b4c4c4d4d4 e4e4f4f4g4g4h4h4 i4i4j4j4k4k4l4l4 m4m4n4n4o4o4p4p4
; 34 22x22a a3a3b3b3c3c3d3d3 e3e3f3f3g3g3h3h3 i3i3j3j3k3k3l3l3 m3m3n3n3o3o3p3p3
; 35 22x22b a2a2b2b2c2c2d2d2 e2e2f2f2g2g2h2h2 i2i2j2j2k2k2l2l2 m2m2n2n2o2o2p2p2
; 36 23x23a a1a1b1b1c1c1d1d1 e1e1f1f1g1g1h1h1 i1i1j1j1k1k1l1l1 m1m1n1n1o1o1p1p1
; 37 23x23b a0a0b0b0c0c0d0d0 e0e0f0f0g0g0h0h0 i0i0j0j0k0k0l0l0 m0m0n0n0o0o0p0p0
;------------------------------------------------------------------------

		swap	d7
		move.w	a2,d7		; number of 16 (game) pixels per row - 1

		move.l	(a0)+,d0	; read first 4 (game) pixels
		move.l	(a0)+,d1	; read first 4 (game) pixels
		move.l	(a0)+,d2	; read first 4 (game) pixels

		move.l	d0,d4
		move.l	d2,d5

		and.l	#$f0f0f0f0,d0
		eor.l	d0,d4
		lsl.l	#4,d4
		and.l	#$f0f0f0f0,d5
		eor.l	d5,d2
		lsr.l	#4,d5
		or.l	d5,d0
		or.l	d4,d2		; 00x02 -> 10 11
		move.l	d1,d4
		and.l	#$f0f0f0f0,d1
		eor.l	d1,d4
		lsl.l	#4,d4

		move.l	(a0)+,d3	; read next 4 (game) pixels

		move.l	d3,d5
		and.l	#$f0f0f0f0,d5
		eor.l	d5,d3
		lsr.l	#4,d5
		or.l	d5,d1
		or.l	d4,d3		; 01x03 -> 12 13
		lsl.l	#2,d0
		or.l	d0,d1		; 10x12 ->    21
		move.l	d2,d4
		and.l	#$cccccccc,d2
		eor.l	d2,d4
		lsl.l	#2,d4

		bra	.same_from_here

		cnop	0,8

.outerloop	swap	d7
		move.w	a2,d7		; number of 16 (game) pixels per row - 1

.innerloop	move.l	(a0)+,d0	; read next 4 (game) pixels
		move.l	(a0)+,d1	; read next 4 (game) pixels
		move.l	(a0)+,d2	; read next 4 (game) pixels

		move.l	d5,(a1) 	; 34 -> plane 3
		adda.l	a6,a1		; +bpmod

		move.l	d0,d4
		and.l	#$f0f0f0f0,d0
		eor.l	d0,d4
		lsl.l	#4,d4
		move.l	d2,d5
		and.l	#$f0f0f0f0,d5
		eor.l	d5,d2
		lsr.l	#4,d5
		or.l	d5,d0
		or.l	d4,d2		; 00x02 -> 10 11
		move.l	d1,d4
		and.l	#$f0f0f0f0,d1

		move.l	d3,(a1) 	; 33 -> plane 4
		adda.l	a6,a1		; +bpmod

		eor.l	d1,d4
		lsl.l	#4,d4

		move.l	(a0)+,d3	; read next 4 (game) pixels

		move.l	d3,d5
		and.l	#$f0f0f0f0,d5
		eor.l	d5,d3
		lsr.l	#4,d5
		or.l	d5,d1
		or.l	d4,d3		; 01x03 -> 12 13
		lsl.l	#2,d0
		or.l	d0,d1		; 10x12 ->    21
		move.l	d2,d4
		and.l	#$cccccccc,d2
		eor.l	d2,d4
		lsl.l	#2,d4

		move.l	d6,(a1) 	; 32 -> plane 5
		adda.l	a4,a1		; -5*bpmod+4 or
					; +linemod-bytesperrow-5*bpmod+4

.same_from_here move.l	d3,d5
		and.l	#$cccccccc,d5
		eor.l	d5,d3
		lsr.l	#2,d5
		or.l	d5,d2
		or.l	d4,d3		; 11x13 -> 22 23
		move.l	d3,d4
		and.l	#$aaaaaaaa,d3
		eor.l	d3,d4
		move.l	d4,d5
		add.l	d4,d4
		or.l	d4,d5		; 23x23b -> 37

		move.l	d5,(a1) 	; 37 -> plane 0
		adda.l	a6,a1		; +bpmod

		move.l	d3,d4
		lsr.l	#1,d3
		or.l	d3,d4		; 23x23a -> 36
		move.l	d2,d5
		and.l	#$aaaaaaaa,d2
		eor.l	d2,d5
		move.l	d5,d6
		add.l	d5,d5

		move.l	d4,(a1) 	; 36 -> plane 1
		adda.l	a6,a1		; +bpmod

		or.l	d5,d6		; 22x22b -> 35
		move.l	d2,d5
		lsr.l	#1,d2
		or.l	d2,d5		; 22x22a -> 34
		move.l	d1,d4
		and.l	#$aaaaaaaa,d1
		eor.l	d1,d4
		move.l	d4,d3

		move.l	d6,(a1) 	; 35 -> plane 2
		adda.l	a6,a1		; +bpmod

		add.l	d4,d4
		or.l	d4,d3		; 21x21b -> 33
		move.l	d1,d6
		lsr.l	#1,d1
		or.l	d1,d6		; 21x21a -> 32

		movea.l a3,a4		; a4 = -5*bpmod+4

		dbra	d7,.innerloop

		movea.l a5,a4		; a4 = linemod-bytesperrow-5*bpmod+4

		swap	d7
		dbra	d7,.outerloop

		move.l	d5,(a1) 	; 34 -> plane 3
		adda.l	a6,a1		; +bpmod
		move.l	d3,(a1) 	; 33 -> plane 4
		adda.l	a6,a1		; +bpmod
		move.l	d6,(a1) 	; 32 -> plane 5
		rts

		end
