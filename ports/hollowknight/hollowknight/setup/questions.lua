-- Asked by PortMaster's patcher before the setup starts (PATCHER_QUESTIONS in the launcher);
-- each answer reaches setup/patchscript as <id>=<value> in its environment.
-- The picture-shape question only where it changes something (PortMaster's DISPLAY_WIDTH and
-- DISPLAY_HEIGHT): Hollow Knight fills 16:10 screens itself, so none on 16:10 or wider ones; both
-- choices when the screen's size is unknown. The answers to ASPECT and BUTTONS go into aspect.txt
-- and buttons.txt in the port folder, which the launcher reads at each launch.
local function screen_aspect()
  local ok, w, h = pcall(function() return tonumber(os.getenv("DISPLAY_WIDTH")), tonumber(os.getenv("DISPLAY_HEIGHT")) end)
  if ok and w and h and h > 0 then return w / h end
end
local a = screen_aspect()

local questions = {
  {
    id = "TEXTURE_QUALITY",
    question = "Texture quality? Both turn the textures into ASTC, the format the handheld's GPU reads (the same size and memory). High is what this port is tested with. Low makes the setup much shorter, with slightly less exact textures.",
    options = {
      { "medium", "High (recommended)" },
      { "fast", "Low (shorter setup)" },
    },
  },
}
if not a or a < 1.59 then
  table.insert(questions, {
    id = "ASPECT",
    question = "Picture shape? Hollow Knight is 16:9. (Change it later in ports/hollowknight/aspect.txt: fill or bars.)",
    options = {
      { "fill", "Fill the screen: the same width, a little more above and below (recommended)" },
      { "bars", "16:9 with black bars above and below" },
    },
  })
end
table.insert(questions, {
  id = "BUTTONS",
  question = "Which letters are on your handheld's buttons? The game's prompts show them. (Change it later in ports/hollowknight/buttons.txt: nintendo or xbox.)",
  options = {
    { "nintendo", "Nintendo: A on the right, B at the bottom (recommended)" },
    { "xbox", "Xbox: A at the bottom, B on the right" },
  },
})
return questions
