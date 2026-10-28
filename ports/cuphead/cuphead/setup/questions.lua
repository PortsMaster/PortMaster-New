-- Asked by PortMaster's patcher before the setup starts (PATCHER_QUESTIONS in Cuphead.sh); each
-- answer reaches setup/patchscript as <id>=<value> in its environment.
-- The picture-shape question only where it changes something (PortMaster's DISPLAY_WIDTH and
-- DISPLAY_HEIGHT): none on 16:9 or wider screens; on 3:2 and 16:10 fill (the default: the sides
-- cropped a little) or the game's 16:9 with bars; on 4:3 and narrower the bars (the default) or a
-- full-screen crop; all three when the screen's size is unknown.
local function screen_aspect()
  local ok, w, h = pcall(function() return tonumber(os.getenv("DISPLAY_WIDTH")), tonumber(os.getenv("DISPLAY_HEIGHT")) end)
  if ok and w and h and h > 0 then return w / h end
end
local a = screen_aspect()
local shape
if not a then
  shape = {
    { "fill", "Fit the screen (recommended)" },
    { "16:9", "16:9 with bars" },
    { "4:3", "4:3 on square and 4:3 screens: smaller bars, the sides cropped a little" },
    { "crop", "Fill any screen (crops the sides)" },
  }
elseif a < 1.7 and a >= 1.45 then
  shape = {
    { "fill", "Fill the screen, sides cropped a little (recommended)" },
    { "16:9", "16:9 with bars" },
  }
elseif a < 1.45 then
  shape = {
    { "fill", "16:9 with bars (recommended)" },
    { "crop", "Fill the screen (crops the sides)" },
  }
  -- narrower than 4:3 (square): a 4:3 picture between the two, and the crop named as 1:1
  if a < 1.3 then
    shape = {
      { "fill", "16:9 with bars (recommended)" },
      { "4:3", "4:3: smaller bars, the sides cropped a little" },
      { "1:1", "1:1: fill the screen (the sides cropped, the menus and HUD fit)" },
    }
  end
end

local questions = {
  {
    id = "TEXTURE_QUALITY",
    question = "Texture quality? Both look the same at normal size. Sharper keeps the textures closer to the original and makes the setup about a fifth longer.",
    options = {
      { "fast", "Fast (recommended)" },
      { "medium", "Sharper" },
    },
  },
  {
    id = "RESOLUTION",
    question = "Resolution the game renders at? The screen shows it full size either way; lower is softer but faster. (Change it later in ports/cuphead/resolution.txt.)",
    options = {
      { "device", "Device resolution (recommended)" },
      { "0.833", "5/6 of the device's" },
      { "0.75", "3/4 of the device's" },
      { "0.5", "1/2 of the device's" },
    },
  },
  {
    id = "BUTTONS",
    question = "Which letters are on your handheld's buttons? The game's prompts show them (the bottom button always jumps). (Change it later in ports/cuphead/buttons.txt: nintendo or xbox.)",
    options = {
      { "nintendo", "Nintendo: A on the right, B at the bottom (recommended)" },
      { "xbox", "Xbox: A at the bottom, B on the right" },
    },
  },
}
if shape then
  table.insert(questions, 2, {
    id = "ASPECT",
    question = "Picture shape? Cuphead is 16:9. (Change it later in ports/cuphead/aspect.txt: fill, 16:9, crop, 4:3 or 1:1.)",
    options = shape,
  })
end
return questions
