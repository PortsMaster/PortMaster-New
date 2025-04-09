--Font Extractor by Adrien Destugues
--Cut the picture in characters and save them
--to a binary file
--
--Copyright 2013, Adrien Destugues <pulkomandy@pulkomandy.tk>
--
--this file is distributed under the terms of the MIT licence

w,h = getpicturesize();

f = io.open("file.bin","w")

for y = 0, h-1, 8 do
	for x = 0, w-1, 8 do
		for y2 = 0, 7, 1 do
			word = 0;
			for x2 = 0,7,1 do
				word = word * 2 + getpicturepixel(x+x2,y+y2);
				-- read one word from the current line
			end
			f:write(string.char(word));
		end
	end
end

f:close()
