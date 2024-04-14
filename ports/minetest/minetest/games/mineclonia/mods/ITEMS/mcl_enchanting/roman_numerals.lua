--------------------------------------------------------------------
--! @file
--! @brief Convert from normal numbers to Roman Numerals
---------------------------------------------------------------------
local conversionTable = {
  { number = 1000, symbol = "M" },
  { number = 900, symbol = "CM" },
  { number = 500, symbol = "D" },
  { number = 400, symbol = "CD" },
  { number = 100, symbol = "C" },
  { number = 90, symbol = "XC" },
  { number = 50, symbol = "L" },
  { number = 40, symbol = "XL" },
  { number = 10, symbol = "X" },
  { number = 9, symbol = "IX" },
  { number = 5, symbol = "V" },
  { number = 4, symbol = "IV" },
  { number = 1, symbol = "I" }
}

return{
  toRoman = function(number)
    local romanNumeral = ""

    for _,table in pairs (conversionTable) do
      while(number >= table.number) do
        romanNumeral = romanNumeral .. table.symbol
        number = number - table.number
      end
    end

    return romanNumeral
  end
}
