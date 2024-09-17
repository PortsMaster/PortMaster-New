#define XRES 400
#define YRES 240

dim shared as ubyte TileBuffer(0 to 256*64-1)

Sub GetGeneric256(x As Integer, y As Integer, xSize As Integer, ySize As Integer, p As UByte Ptr)
	Static As Integer dx, dy

    For dy = 0 To ySize - 1
        For dx = 0 To xSize - 1
 
			If x + dx >= 0 Then 
                If x + dx < XRES Then 
                    If y + dy >= 0 Then 
                        If y + dy < YRES Then
						
                       	 'Poke((y + dy) * XRES + x + dx + SCREENPTR()), CGA_Palette((*p Shr smth(dx And 3)) And &h3)
						 *p = peek((y + dy) * XRES + x + dx + SCREENPTR())
                        End If
                    End If
                End If
            End If	
			p += 1
		Next
	Next
	
End Sub

Sub PutGeneric256(x As Integer, y As Integer, xSize As Integer, ySize As Integer, p As UByte Ptr)

    Static As UByte smth(0 To 3) = {6, 4, 2, 0}
    Static As UByte CGA_Palette(0 To 3) = {0, 3, 5, 7}
    
    Static As Integer dx, dy

    For dy = 0 To ySize - 1
        For dx = 0 To xSize - 1
        	
            If x + dx >= 0 Then 
                If x + dx < XRES Then 
                    If y + dy >= 0 Then 
                        If y + dy < YRES Then
						 Poke((y + dy) * XRES + x + dx + SCREENPTR()), *p
                        End If
                    End If
                End If
            End If	
			p += 1
        Next	
    Next 	
End Sub

Sub PutBlank(x As Integer, y As Integer, p As UByte Ptr)
    Dim As Integer dx, dy, xsize, ysize
    
    xsize = *p * 4
    ysize = *(p + 1)
    For dy = 0 To ysize - 1
        For dx = 0 To xsize - 1
            If x + dx >= 0 Then 
                If x + dx < XRES Then 
                    If y + dy >= 0 Then 
                        If y + dy < YRES Then
                       	    Poke((y + dy) * XRES + x + dx + SCREENPTR()), 0
                        End If
                    End If
                End If
            End If	
        Next 
    Next 
End Sub

Sub PutSprite(x As Integer, y As Integer, p As UByte Ptr)
    'PutGeneric x, y, *p Shl 2, *(p + 1), p + 2
End Sub

Sub PutTile(x As Integer, y As Integer, p As UByte Ptr)
    PutGeneric256 x, y, 8, 8, p
End Sub 

Sub GetTile(x As Integer, y As Integer, p As UByte Ptr)
    GetGeneric256 x, y, 8, 8, p
End Sub 

Sub OutputSprite(x as integer, y as integer, xs as integer, ys as integer, seqnum as integer, framenum as integer)
	dim as string buffer
	
	TileBuffer(0) = xs: TileBuffer(1) = ys
	GetGeneric256 x, y, xs, ys, @TileBuffer(2)
	
	Print #2, !"unsigned char Sprite_" + str(seqnum) + "_" + str(framenum) + !"[] ALIGN4 = {\n" + _
		!"\t" + str(xs) + ", " + str(ys) + ","
	
	for y = 0 to ys-1
		buffer = !"\t"
		for x = 0 to xs-1
			buffer += str(TileBuffer(y*xs+x+2))
			if y = ys-1 andalso x = xs-1 then buffer += "" else buffer += ", "
		next
		Print #2, buffer
	next
	Print #2, "};"
	
End Sub

dim shared as integer frame_ubound(0 to 56) = { 6, 1, 2, 2, 2, 3, 1, 2, 3, 3, 3, 3, 1, 2, 1, 1, 1, 1, 1, 3, 1, 0, 3, 3, 3, 5, 1, 3, 3, 3, 5, 3, 5, 3, 3, 3, 3, 5, 3, 1, 1, 1, 3, 0, 0, 0, 5, 0, 0, 3, 1, 6, 0, 6, 3, 4, 3}
dim shared as integer dy = 0, dx = 0
dim shared as string buffer

'' MAIN
screenres XRES, YRES, 8
bload "tilefont.bmp"
Open "m_gfx_data.c" For Output As #2
Print #2, !"#ifndef __GNUC__\r\n#define ALIGN4\r\n#else\r\n#define ALIGN4 __attribute__ ((aligned(4)))\r\n#endif\r\n"

' process tiles
for y as integer = 0 to 6
	for x as integer = 0 to 39
		if y*40+x > 255 then continue for
		GetTile x*8, y*8, @TileBuffer(y*40*64+x*64)
	next
next
Print #2, !"unsigned char Tiles256[256*64] ALIGN4 = {"
for i as integer = 0 to 255
	for y as integer = 0 to 7
		buffer = !"\t"
		for x as integer = 0 to 7	
			buffer += str(TileBuffer(i*64 + y * 8 + x))
			if x = 7 andalso y = 7 andalso i = 255 then buffer += " " else buffer += ", "
		next
		print #2, buffer
		buffer = !""
	next
	print #2, !""
next
print #2, !"};\n"

' process fonts
for y as integer = 8 to 24
	for x as integer = 0 to 39
		if (y-8)*40+x > 88 then continue for
		GetTile x*8, y*8, @TileBuffer((y-8)*40*64+x*64)
	next
next


Print #2, !"unsigned char Font256[89*64] ALIGN4 = {"
for i as integer = 0 to 88
	for y as integer = 0 to 7
		buffer = !"\t"
		for x as integer = 0 to 7	
			buffer += str(TileBuffer(i*64 + y * 8 + x))
			if x = 7 andalso y = 7 andalso i = 88 then buffer += " " else buffer += ", "
		next
		print #2, buffer
		buffer = !""
	next
	print #2, !""
next
print #2, !"};\n"

'generate palette 'maybe later
'print #2, !"// palette in rgba format\nunsigned char[1024] = {\n";
'for i as integer = 0 to 255
'	dim as integer r, g, b
	
'	palette get i, r, g, b 
'	buffer = !"\t 0x" + hex(r, 2) + ", 0x" + hex(g, 2) + ", 0x" + hex(b, 2) + ", 0x00"
'	if i < 255 then buffer += ","
'	print #2, buffer
'next
'print #2, "};"

'generate bg tiles
for i as integer = 0 to 9
	TileBuffer(0) = 16: TileBuffer(1) = 16
	GetGeneric256 i*16, 6*16, 16, 16, @TileBuffer(2)

	Print #2, !"unsigned char BgSprite_" + str(i) + !"[] ALIGN4 = {\n" + !"\t 16, 16,"
	
	for y as integer = 0 to 15
		buffer = !"\t"
		for x as integer = 0 to 15
			buffer += str(TileBuffer(y*16+x+2))
			if y = 15 andalso x = 15 then buffer += "" else buffer += ", "
		next
		Print #2, buffer
	next
	Print #2, "};"	
	
next

print #2, !"unsigned char *pBgSprites[10] = {"
for i as integer = 0 to 9
	buffer = !"\tBgSprite_" + str(i)
	if i <> 9 then buffer += ", "
	print #2, buffer	
next
print #2, !"};\r\n"

cls

bload "sprite.bmp"

' process sprites
for fr as integer = 0 to 6
	OutputSprite 17*16, 3*16 + fr*16, 32, 12, 0, fr
next
for fr as integer = 0 to 1
	OutputSprite 12*16 + fr*40, 13*16, 40, 16, 1, fr
next
for i as integer = 2 to 5
	for fr as integer = 0 to frame_ubound(i)
		OutputSprite fr*16, (i-2)*16, 16, 16, i, fr
	next
next
for fr as integer = 0 to 1
	OutputSprite fr*8, 4*16, 8, 16, 6, fr
next
for i as integer = 7 to 16
	for fr as integer = 0 to frame_ubound(i)
		OutputSprite fr*16, (i-2)*16, 16, 16, i, fr
	next
next
for fr as integer = 0 to 1
	OutputSprite 12*16+fr*16, 5*16, 16, 6, 17, fr
next
for fr as integer = 0 to 1
	OutputSprite 12*16+fr*8, 6*16, 8, 14, 18, fr
next
for i as integer = 19 to 20
	for fr as integer = 0 to frame_ubound(i)
		OutputSprite 5*16+fr*16, (i-19)*16, 16, 16, i, fr
	next
next

OutputSprite 12*16, 7*16, 48, 8, 21, 0

for fr as integer = 0 to frame_ubound(22)
	OutputSprite 5*16+fr*16, 2*16, 16, 16, 22, fr
next

for fr as integer = 0 to frame_ubound(23)
	OutputSprite 12*16+fr*32, 14*16, 32, 12, 23, fr
next

for i as integer = 24 to 35
	for fr as integer = 0 to frame_ubound(i)
		OutputSprite 5*16+fr*16, (i-21)*16, 16, 16, i, fr
	next
next

for i as integer = 36 to 39
	for fr as integer = 0 to frame_ubound(i)
		OutputSprite 12*16+fr*16, (i-36)*16, 16, 16, i, fr
	next
next

for i as integer = 40 to 41
	for fr as integer = 0 to frame_ubound(i)
		OutputSprite 12*16+fr*24, (i-32)*16, 24, 7, i, fr
	next
next

for fr as integer = 0 to frame_ubound(42)
	OutputSprite 12*16+fr*16, 4*16, 16, 16, 42, fr
next

OutputSprite 12*16, 10*16, 4, 4, 43, 0

OutputSprite 12*16, 11*16, 40, 8, 44, 0

OutputSprite 12*16, 12*16, 72, 12, 45, 0

for fr as integer = 0 to frame_ubound(46)
	OutputSprite 117 + 13*fr, 17, 13, 13, 46, fr
next

OutputSprite 151, 33, 15, 15, 47, 0
OutputSprite 167, 33, 15, 15, 48, 0

for fr as integer = 0 to frame_ubound(49)
	OutputSprite 243, 86 + 19*fr, 26, 19, 49, fr
next

' Machine gun bullet
OutputSprite 372, 52, 8, 2, 50, 0
OutputSprite 372, 55, 8, 2, 50, 1

' Machine gun ship
for fr as integer = 0 to 6
	OutputSprite 334, 3*16 + fr*16, 32, 12, 51, fr
next

' extra HP
OutputSprite 165, 91, 11, 12, 52, 0

' Rocket ship
for fr as integer = 0 to 6
	OutputSprite 303, 3*16 + fr*16, 32, 12, 53, fr
next

' Rocket
for fr as integer = 0 to 3
	OutputSprite 309, 12 + fr*8, 14, 8, 54, fr
next

' BFG
for fr as integer = 0 to 4
	OutputSprite 375, 145 + fr*18, 16, 16, 55, fr
next

' BFG shot
for fr as integer = 0 to 3
	OutputSprite 287 + fr*11, 204, 10, 10, 56, fr
next


for i as integer = 0 to 56
	print #2, !"unsigned char *pSpriteFrames_" + str(i) + "[] = {"
	buffer = !"\t "
	for fr as integer = 0 to frame_ubound(i)
		buffer += "Sprite_" + str(i) + "_" + str(fr)
		if fr <> frame_ubound(i) then buffer += ", " else buffer += ", 0"
	next
	print #2, buffer
	print #2, !"};\r\n"
next

print #2, !"unsigned char **pSprites256[57] = {"
for i as integer = 0 to 56
	buffer = !"\tpSpriteFrames_" + str(i)
	if i <> 56 then buffer += ", "
	print #2, buffer
next
print #2, !"};\r\n"

Close #2

sleep
 