local roman_conversion = {
	{1000, "M"},
	{900, "CM"},
	{500, "D"},
	{400, "CD"},
	{100, "C"},
	{90, "XC"},
	{50, "L"},
	{40, "XL"},
	{10, "X"},
	{9, "IX"},
	{5, "V"},
	{4, "IV"},
	{1, "I"}
}

function mcl_util.to_roman(number)
	local r = ""
	local a = number
	local i = 1
	while a > 0 do
		if a >= roman_conversion[i][1] then
			a = a - roman_conversion[i][1]
			r = r.. roman_conversion[i][2]
		else
			i = i + 1
		end
	end
	return r
end
